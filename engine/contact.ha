use strings;
use endian;
use errors;
use path;
use types;
use fmt;
use fs;
use bytes;
use time::date;
use io;
use os;

export fn contactToBytes(c: *Contact) []u8 = {
    let cb: []u8 = alloc([0...], c.head.chunksize)!;

    let cursor: u32 = 0;

    endian::leputu32(cb[..4], c.head.chunksize);
    endian::leputu32(cb[4..8], c.head.id);
    cursor += 8;

    endian::leputu32(cb[cursor..cursor + 4], c.company_id);
    cursor += 4;

    cb[cursor] = c.first_name_size;
    cursor += 1;

    cb[cursor..cursor + c.first_name_size] = strings::toutf8(c.first_name);
    cursor += c.first_name_size;

    cb[cursor] = c.last_name_size;
    cursor += 1;

    cb[cursor..cursor + c.last_name_size] = strings::toutf8(c.last_name);
    cursor += c.last_name_size;

    endian::leputu16(cb[cursor..cursor + 2], c.email_size);
    cursor += 2;

    cb[cursor..cursor + c.email_size] = strings::toutf8(c.email);
    cursor += c.email_size;

    cb[cursor] = c.phone_size;
    cursor += 1;

    cb[cursor..cursor + c.phone_size] = strings::toutf8(c.phone);
    cursor += c.phone_size;

    cb[cursor] = c.position_size;
    cursor += 1;

    cb[cursor..cursor + c.position_size] = strings::toutf8(c.position);
    cursor += c.position_size;

    endian::leputu64(cb[cursor..cursor + 8], c.created_at: u64);

    return cb;
};

export fn contactIndexToBytes(c: *ContactIndex) []u8 = {
    let cb: []u8 = alloc([0...], c.head.chunksize)!;

    let cursor: u32 = 0;

    endian::leputu32(cb[..4], c.head.chunksize);
    endian::leputu32(cb[4..8], c.head.id);
    cursor += 8;

    endian::leputu32(cb[cursor..cursor + 4], c.company_id);
    cursor += 4;

    cb[cursor] = c.first_name_size;
    cursor += 1;

    cb[cursor..cursor + c.first_name_size] = strings::toutf8(c.first_name);
    cursor += c.first_name_size;

    cb[cursor] = c.last_name_size;
    cursor += 1;

    cb[cursor..cursor + c.last_name_size] = strings::toutf8(c.last_name);
    cursor += c.last_name_size;

    cb[cursor] = c.position_size;
    cursor += 1;

    cb[cursor..cursor + c.position_size] = strings::toutf8(c.position);
    cursor += c.position_size;

    endian::leputu64(cb[cursor..cursor + 8], c.created_at: u64);

    return cb;
};

export fn getContactIndexPath() (path::buffer | errors::error) = {

    let buf = match (path::init("./")) {
          case let b: path::buffer => yield b;
          case let e: path::error  => return errors::invalid;
      };
      match (path::push(&buf, HUNT_GLOBAL_DIR)) {
          case => yield;
          case let e: path::error => return errors::invalid;
      };
      match (path::push(&buf, HUNT_DIRS[3])) {
          case => yield;
          case let e: path::error => return errors::invalid;
      };
      match (path::push(&buf, INDEX_FILE)) {
          case => yield;
          case let e: path::error => return errors::invalid;
      };
      return buf;
};

export fn getContactPath(id: u32, fname: str, lname: str) (path::buffer | errors::error) = {

    let buf = match (path::init("./")) {
          case let b: path::buffer => yield b;
          case let e: path::error  => return errors::invalid;
      };
      match (path::push(&buf, HUNT_GLOBAL_DIR)) {
          case => yield;
          case let e: path::error => return errors::invalid;
      };

      match (path::push(&buf, HUNT_DIRS[3])) {
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
      let contactsegment = fmt::asprintf("ctc-{}{}-{}{}{}", prefix, id, fname, lname, ENTRY_EXT)!;
      defer free(contactsegment);
      match (path::push(&buf, contactsegment)) {
          case => yield;
          case let e: path::error => return errors::invalid;
      };
      return buf;
};

export fn contactadd(firstname: str, lastname: str, company: CompanyQuery, email: str, phone: str, position: str) (u32 | errors::error) = {

    let indexbuff = match (getContactIndexPath()) {
        case let b: path::buffer => yield b;
        case let e: errors::error => return errors::invalid;
    };

    let target_path = path::string(&indexbuff);

    let filebytes = match (readfile(target_path)) {
        case let b: []u8 => yield b;
        case let e: fs::error  => return errors::invalid;
    };
    defer free(filebytes);

    if (! bytes::equal(filebytes[..4], MAGIC))  {
        return errors::invalid;
    };

    let contactlength: u32 = endian::legetu32(filebytes[7..11]);
    let cursor: u64 = 12;
    for(let i: u32 = 0; i < contactlength; i += 1) {
        cursor += endian::legetu32(filebytes[cursor..cursor + 4]);
    };

    let contact: Contact = Contact{...};
    let contactHeader: ChunkHeader = ChunkHeader{...};

    contact.head.id = contactlength;


    if (len(firstname) > types::U8_MAX) {
        fmt::println("Name of contact have to be shorter than 255 characters!")!;
        return errors::invalid;
    };

    contact.first_name_size = len(firstname): u8;
    contact.first_name = firstname;

    if (len(lastname) > types::U8_MAX) {
        fmt::println("Name of contact have to be shorter than 255 characters!")!;
        return errors::invalid;
    };

    contact.last_name_size = len(lastname): u8;
    contact.last_name = lastname;

    let cid = match(companyGet(company)) {
        case let c: Company => yield c.head.id;
        case let none: void => yield types::U32_MAX;
    };

    contact.company_id = cid;

    if (len(email) > types::U16_MAX) {
        fmt::println("Mail of contact have to be shorter than 65535 characters!")!;
        return errors::invalid;
    };

    contact.email_size = len(email): u16;
    contact.email = email;

    if (len(phone) > types::U8_MAX) {
        fmt::println("Phone number of contact have to be shorter than 255 characters!")!;
        return errors::invalid;
    };
    contact.phone_size = len(phone): u8;
    contact.phone = phone;

    if (len(position) > types::U8_MAX) {
        fmt::println("Position of contact have to be shorter than 255 characters!")!;
        return errors::invalid;
    };
    contact.position_size = len(position): u8;
    contact.position = position;

    contact.created_at = date::to_instant(date::now()).sec;

    updatecontactchunksize(&contact);

    let cindex: ContactIndex = indexEntryFromContact(&contact);

    let newcontactindexbytes: []u8 = contactIndexToBytes(&cindex);
    defer free(newcontactindexbytes);

    append(filebytes, newcontactindexbytes...)!;
    endian::leputu32(filebytes[7..11], contactlength + 1);

    let indexfile: io::file = os::open(target_path, fs::flag::WRONLY)!;
    io::writeall(indexfile, filebytes)!;
    io::close(indexfile)!;


    let contactbuff = match (getContactPath(contact.head.id, contact.first_name, contact.last_name)) {
            case let b: path::buffer => yield b;
            case let e: errors::error => return errors::invalid;
    };

    let contact_filepath: str = path::string(&contactbuff);
    let contactfile: io::file = os::create(contact_filepath, 0o755)!;
    let contactfilecontent: []u8 = [];
    append(contactfilecontent, FILE_HEADER...)!;
    append(contactfilecontent, contactToBytes(&contact)...)!;
    contactfilecontent[8] = 1;
    io::writeall(contactfile, contactfilecontent)!;
    io::close(contactfile)!;
    return contact.head.id;
};

export fn updatecontactchunksize(c: *Contact) void = {
    c.head.chunksize = 8 + 4 + 1 + c.first_name_size + 1 + c.last_name_size + 2 + c.email_size + 1 + c.phone_size + 1 + c.position_size + 8;
};

export fn indexEntryFromContact(c: *Contact) ContactIndex = {
    return ContactIndex {
        head = ChunkHeader {
            chunksize = 8 + 4 + 1 + c.first_name_size + 1 + c.last_name_size + 1 + c.position_size + 8,
            id = c.head.id
        },
        company_id = c.company_id,
        first_name_size = c.first_name_size,
        first_name = c.first_name,
        last_name_size = c.last_name_size,
        last_name = c.last_name,
        position_size = c.position_size,
        position = c.position,
        created_at = c.created_at,
    };
};

export fn getContactIndexList() []ContactIndex = {
    let contacts: []ContactIndex = [];

    let indexp: path::buffer = match(getContactIndexPath()) {
        case let b: path::buffer => yield b;
        case => {
            fmt::println("Can't reach index path, did you already init ?")!;
            return contacts;
        };
    };

    let fb: []u8 = match (readfile(path::string(&indexp))) {
        case let b: []u8 => yield b;
        case => yield [];
    };

    if(len(fb) <= 12) {
        return contacts;
    };

    if(! bytes::equal(fb[..4], MAGIC)) {
         return contacts;
    };

    let contact_count: u32 = endian::legetu32(fb[7..11]);

    let cursor: u32 = 12;
    for(let i: size = 0;i < contact_count; i+= 1) {
        cursor += 4;

        let cIndex: ContactIndex = ContactIndex{...};

        cIndex.head.id = endian::legetu32(fb[cursor..cursor + 4]);
        cursor += 4;

        cIndex.company_id = endian::legetu32(fb[cursor..cursor+4]);
        cursor += 4;

        cIndex.first_name_size = fb[cursor];
        cursor += 1;

        cIndex.first_name = strings::fromutf8_unsafe(fb[cursor..cursor + cIndex.first_name_size]);
        cursor += cIndex.first_name_size;

        cIndex.last_name_size = fb[cursor];
        cursor += 1;

        cIndex.last_name = strings::fromutf8_unsafe(fb[cursor..cursor + cIndex.last_name_size]);
        cursor += cIndex.last_name_size;

        cIndex.position_size = fb[cursor];
        cursor += 1;

        cIndex.position = strings::fromutf8_unsafe(fb[cursor..cursor + cIndex.position_size]);
        cursor += cIndex.position_size;

        cIndex.created_at = endian::legetu64(fb[cursor..cursor + 8]): i64;
        cursor += 8;
        append(contacts, cIndex)!;
    };
    return contacts;
};
