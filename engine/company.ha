use bytes;
use errors;
use fs;
use path;
use endian;
use types;
use time::date;
use fmt;
use io;
use strings;
use os;

export fn companyadd(name: str, adress: str, status: str, tags_in: str) (u32 | errors::error) = {

    let buf = match (path::init("./")) {
        case let b: path::buffer => yield b;
        case let e: path::error  => return errors::invalid;
    };
    match (path::push(&buf, HUNT_GLOBAL_DIR)) {
        case => yield;
        case let e: path::error => return errors::invalid;
    };

    match (path::push(&buf, HUNT_DIRS[4])) {
        case => yield;
        case let e: path::error => return errors::invalid;
    };

    match (path::push(&buf, INDEX_FILE)) {
        case => yield;
        case let e: path::error => return errors::invalid;
    };

    let target_path = path::string(&buf);

    let filebytes = match (readfile(target_path)) {
        case let b: []u8 => yield b;
        case let e: fs::error  => return errors::invalid;
    };
    defer free(filebytes);

    if (! bytes::equal(filebytes[..4], MAGIC))  {
        return errors::invalid;
    };

    let companylength: u32 = endian::legetu32(filebytes[7..11]);
    let cursor: u64 = 12;
    for(let i: u32 = 0; i < companylength; i += 1) {
        cursor += endian::legetu32(filebytes[cursor..cursor + 4]);
    };

    let company: Company = Company{...};
    let companyHeader: ChunkHeader = ChunkHeader{...};

    companyHeader.id = companylength;

    company.head = companyHeader;


    if (len(name) > types::U8_MAX) {
        fmt::println("Name of company have to be shorter than 255 characters!")!;
        return errors::invalid;
    };

    company.name_size = len(name): u8;
    company.name = name;

    if(len(adress) > types::U16_MAX) {
        fmt::println("Adress of the company is too long.")!;
        return errors::invalid;
    };

    company.adress_size = len(adress): u16;
    company.adress = adress;

    let tags: []str = strings::split(tags_in, ",")!;
    // fmt::println(tags)!;
    let tagstructs: []Tag = [];
    let totaltagsize: u64 = 0;
    for(let t .. tags) {
        if (len(t) > types::U8_MAX) {
            continue;
        };
        let ntag: Tag = Tag{titlesize = len(t): u8, title = t};
        append(tagstructs, ntag)!;
        totaltagsize += 1 + len(t);
    };

    company.tags_length = len(tagstructs): u8;
    company.tags = tagstructs;

    let statusTyped: CompanyStatus = companyStatusMatch(status);

    company.status = statusTyped;

    company.created_at = date::to_instant(date::now()).sec;

    company.head.chunksize = (4 + 4 + 1 + company.name_size + 2 + company.adress_size + 1 + totaltagsize + 1 + 8): u32;

    let cindex: CompanyIndex = indexEntryFromCompany(&company);

    let newcompanyindexbytes: []u8 = companyindexToBytes(&cindex);
    defer free(newcompanyindexbytes);
    append(filebytes, newcompanyindexbytes...)!;
    endian::leputu32(filebytes[7..11], companylength + 1);
    let indexfile: io::file = os::open(target_path, fs::flag::WRONLY)!;

    fmt::println(target_path)!;
    io::writeall(indexfile, filebytes)!;
    io::close(indexfile)!;


    path::pop(&buf);
    let prefix = if (company.head.id < 10) {
        yield "00";
    } else if (company.head.id < 100) {
        yield "0";
    } else {
        yield "";
    };
    let companysegment = fmt::asprintf("cmp-{}{}-{}{}", prefix, company.head.id, company.name, ENTRY_EXT)!;
    defer free(companysegment);
    match (path::push(&buf, companysegment)) {
        case => yield;
        case let e: path::error => return errors::invalid;
    };

    let company_filepath: str = path::string(&buf);
    fmt::println(company_filepath)!;

    let companyfile: io::file = os::create(company_filepath, 0o755)!;
    let companyfilecontent: []u8 = [];
    append(companyfilecontent, FILE_HEADER...)!;
    append(companyfilecontent, companyToBytes(&company)...)!;
    companyfilecontent[8] = 1;
    io::writeall(companyfile, companyfilecontent)!;
    io::close(companyfile)!;
    return company.head.id;
};

export fn getCompanyIndexPath() (path::buffer | errors::error) = {

    let buf = match (path::init("./")) {
          case let b: path::buffer => yield b;
          case let e: path::error  => return errors::invalid;
      };
      match (path::push(&buf, HUNT_GLOBAL_DIR)) {
          case => yield;
          case let e: path::error => return errors::invalid;
      };

      match (path::push(&buf, HUNT_DIRS[4])) {
          case => yield;
          case let e: path::error => return errors::invalid;
      };

      match (path::push(&buf, INDEX_FILE)) {
          case => yield;
          case let e: path::error => return errors::invalid;
      };

      return buf;
};

export fn getCompanyPath(id: u32, name: str) (path::buffer | errors::error) = {

    let buf = match (path::init("./")) {
          case let b: path::buffer => yield b;
          case let e: path::error  => return errors::invalid;
      };
      match (path::push(&buf, HUNT_GLOBAL_DIR)) {
          case => yield;
          case let e: path::error => return errors::invalid;
      };

      match (path::push(&buf, HUNT_DIRS[4])) {
          case => yield;
          case let e: path::error => return errors::invalid;
      };

      let prefix = if (id < 10) {
          yield "00";
      } else if (id < 100) {
          yield "0";
      } else {
          yield "";
      };
      let companysegment = fmt::asprintf("cmp-{}{}-{}{}", prefix, id, name, ENTRY_EXT)!;
      defer free(companysegment);
      match (path::push(&buf, companysegment)) {
          case => yield;
          case let e: path::error => return errors::invalid;
      };
      return buf;
};


export fn companyToBytes(c: *Company) []u8 = {
    let buff: []u8 = alloc([0...], c.head.chunksize)!;

    let cursor: size= 0;

    endian::leputu32(buff[..4], c.head.chunksize);
    cursor += 4;

    endian::leputu32(buff[cursor..cursor+4], c.head.id);
    cursor += 4;

    buff[cursor] = c.name_size;
    cursor += 1;

    buff[cursor..cursor + c.name_size] = strings::toutf8(c.name);
    cursor += c.name_size;

    endian::leputu16(buff[cursor..cursor+2], c.adress_size);
    cursor += 2;

    buff[cursor..cursor + c.adress_size] = strings::toutf8(c.adress);
    cursor += c.adress_size;

    buff[cursor] = c.tags_length;
    cursor += 1;

    for(let t .. c.tags) {
        buff[cursor] = t.titlesize;
        cursor += 1;
        buff[cursor..cursor+t.titlesize] = strings::toutf8(t.title);
        cursor += t.titlesize;
    };

    buff[cursor] = c.status;
    cursor += 1;

    endian::leputu64(buff[cursor..cursor + 8], c.created_at: u64);

    return buff;
};

export fn indexEntryFromCompany(c: *Company) CompanyIndex = {
    let indexheader: ChunkHeader = ChunkHeader{
        chunksize =  8 + 1 + c.name_size + 1 + 8,
        id = c.head.id
    };
    return CompanyIndex{head = indexheader, name_size = c.name_size, name = c.name, status = c.status, created_at = c.created_at };
};

export fn companyindexToBytes(c: *CompanyIndex) []u8 = {
    let buff: []u8 = alloc([0...], c.head.chunksize)!;

    let cursor: size= 0;

    endian::leputu32(buff[..4], c.head.chunksize);
    cursor += 4;

    endian::leputu32(buff[cursor..cursor+4], c.head.id);
    cursor += 4;

    buff[cursor] = c.name_size;
    cursor += 1;

    buff[cursor..cursor + c.name_size] = strings::toutf8(c.name);
    cursor += c.name_size;

    buff[cursor] = c.status;
    cursor += 1;

    endian::leputu64(buff[cursor..cursor + 8], c.created_at: u64);

    return buff;
};

export fn companyGet(cquery: CompanyQuery) (Company | void) = {
    let indexpath: path::buffer = getCompanyIndexPath()!;

    let fb: []u8 = readfile(path::string(&indexpath))!;
    let entrycount: u32 = endian::legetu32(fb[7..11]);
    let cursor: u64 = 12;

    return match(cquery) {
        case let sq: str => {
            let nsq: str = normalize(sq);
            for(let i: size = 0; i < entrycount; i += 1) {
                let csize: u32 = endian::legetu32(fb[cursor.. cursor + 4]);
                let nsize: u8 = fb[cursor+8];
                let name: str = strings::fromutf8_unsafe(fb[cursor+9..cursor + 9 + nsize]);
                if (normalize(name) == nsq) {
                    return getCompanyDetails(endian::legetu32(fb[cursor+4..cursor+8]), name);
                };
            };
        };
        case let uq: u32 => {
            if (uq >= entrycount) {
                return;
            };
            for(let i: size = 0; i < uq; i += 1) {
                let csize: u32 = endian::legetu32(fb[cursor.. cursor + 4]);
                cursor += csize;
            };
            let nsize: u8 = fb[cursor+8];
            let name: str = strings::fromutf8_unsafe(fb[cursor+9..cursor + 9 + nsize]);
            return getCompanyDetails(uq, name);
        };
    };
};

export fn getCompanyDetails(id: u32, name: str) (Company | void) = {

    let indexpath: path::buffer = match(getCompanyPath(id, name)) {
        case let b: path::buffer => yield b;
        case => return;
    };

    let fb: []u8 = match(readfile(path::string(&indexpath))) {
        case let b: []u8 => yield b;
        case => return;
    };

    let c: Company = Company{...};
    let cursor: u64 = 12;
    c.head.chunksize = endian::legetu32(fb[cursor..cursor + 4]);
    cursor += 4;
    c.head.id =  endian::legetu32(fb[cursor..cursor + 4]);
    cursor += 4;
    c.name_size = fb[cursor];
    cursor += 1;
    c.name = strings::fromutf8_unsafe(fb[cursor..cursor + c.name_size]);
    cursor += c.name_size;
    c.adress_size = endian::legetu16(fb[cursor..cursor+2]);
    cursor += 2;
    c.adress = strings::fromutf8_unsafe(fb[cursor..cursor+c.adress_size]);
    cursor += c.adress_size;
    c.tags_length = fb[cursor];
    cursor += 1;
    c.tags = alloc([Tag{...}...],  c.tags_length)!;

    for(let i: size = 0; i < c.tags_length; i += 1) {
        c.tags[i].titlesize = fb[cursor];
        c.tags[i].title = strings::fromutf8_unsafe(fb[cursor + 1.. cursor + 1 + c.tags[i].titlesize]);
        cursor += 1 + c.tags[i].titlesize;
    };

    c.status = fb[cursor]: CompanyStatus;
    cursor += 1;
    c.created_at = endian::legetu64(fb[cursor..cursor+8]): i64;
    return c;
};

export fn getCompanyIndexList() []CompanyIndex = {
    let companies: []CompanyIndex = [];

    let indexp: path::buffer = match(getCompanyIndexPath()) {
        case let b: path::buffer => yield b;
        case => {
            fmt::println("Can't reach index path, did you already init ?")!;
            return [];
        };
    };

    let fb: []u8 = match (readfile(path::string(&indexp))) {
        case let b: []u8 => yield b;
        case => yield [];
    };

    if(len(fb) <= 12) {
        return companies;
    };

    if(! bytes::equal(fb[..4], MAGIC)) {
         return companies;
    };

    let company_count: u32 = endian::legetu32(fb[7..11]);

    let cursor: u32 = 12;
    for(let i: size = 0;i < company_count; i+= 1) {
        cursor += 4;

        let cIndex: CompanyIndex = CompanyIndex{...};

        cIndex.head.id = endian::legetu32(fb[cursor..cursor + 4]);
        cursor += 4;

        cIndex.name_size = fb[cursor];
        cursor += 1;

        cIndex.name = strings::fromutf8_unsafe(fb[cursor..cursor + cIndex.name_size]);
        cursor += cIndex.name_size;

        cIndex.status = fb[cursor]: CompanyStatus;
        cIndex.created_at = endian::legetu64(fb[cursor..cursor + 8]): i64;

        append(companies, cIndex)!;
    };
    return companies;
};

export fn companyupdate(id: u32, name: str, adress: str, status: str, tags_in: str) void = {
    fmt::println("machin")!;
};
