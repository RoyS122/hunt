use bytes;
use errors;
use fs;
use path;
use endian;
use types;
use time::date;
use fmt;
use io;

export fn companyadd(name: str, adress: str = "", status: CompanyStatus = CompanyStatus::PROSPECT, tags_in: str = "") (u32 | errors::error) = {

    let buf = match (path::init(HUNT_GLOBAL_DIR)) {
        case let b: path::buffer => yield b;
        case let e: path::error  => return errors::invalid;
    };

    match (path::push(&buf, HUNT_DIRS[4])) {
        case => yield;
        case let e: path::error => return errors::invalid;
    };

    match (path::push(&buf, "index.ht"])) {
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

    company.name_size = len(name) as u8;
    company.name = name;

    if(len(adress) < types::U16_MAX) {
        fmt::println("Adress of the company is too long.")!;
        return errors::invalid;
    };

    company.adress_size = len(adress) as u16;
    company.adress = adress;

    let tags: []str = strings::split(tags_in, ",");
    let tagstructs: []Tag = [];
    let totaltagsize: u64 = 0;
    for(let t .. tags) {
        if (len(t) > types::U8_MAX) {
            continue;
        };
        let ntag: Tag = Tag{titlesize = len(t), title = t};
        totaltagsize += 1 + len(t);
    };

    company.tags_length = len(tagstructs);
    company.tags = tagstructs;

    company.status = status;

    company.created_at = date::now();

    company.head.chunksize = 4 + 4 + 1 + company.name_size + 2 + company.adress_size + 1 + totaltagsize + 1 + 8;

    let cindex: CompanyIndex = indexEntryFromCompany(&company);

    let newcompanyindexbytes: []u8 = companyindexToBytes(&cindex);
    defer free(newcompanyindexbytes);
    filebytes = append(filebytes, newcompanybytes);
    let indexfile: io::file = os::open(target_path);

    io::write(indexfile, filebytes);
    return company.head.id;
};


export fn companyToBytes(c: *Company) []u8 = {
    let buff: []u8 = alloc([0...], c.head.chunksize);

    let cursor: size= 0;

    endian::leputu32(buff[..4], c.head.chunksize);
    cursor += 4;

    endian::leputu32(buff[cursor..cursor+4], c.head.id);
    cursor += 4;

    buff[cursor] = c.name_size;
    cursor += 1;

    buff[cursor..cursor + c.name_size] = strings::toutf8(c.name);
    cursor += c.name_size;

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

    endian::leputu64(buff[cursor..cursor + 8], c.created_at);

    return buff;
};

export fn indexEntryFromCompany(c: *Company) CompanyIndex = {
    let indexheader: ChunkHeader = ChunkHeader{
        chunksize =  8 + 1 + c.name_size + 1 + 8,
        id = c.head.id
    };
    return CompanyIndex{head = indexheader, namesize = c.name_size, name = c.name, status = c.status, created_at = c.created_at };
};

export fn companyindexToBytes(c: *CompanyIndex) []u8 = {
    let buff: []u8 = alloc([0...], c.head.chunksize);

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

    endian::leputu64(buff[cursor..cursor + 8], c.created_at);

    return buff;
};
