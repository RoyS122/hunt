use strings;
use endian;

export fn contactToBytes(c: *Contact) []u8 = {
    let cb: u8 = alloc([0...], c.head.chunksize)!;

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

    endian::leputu64(cb[cursor..cursor + 8], created_at: u64);

    return cb;
};

export fn contactIndexToBytes(c: *ContactIndex) []u8 = {
    let cb: u8 = alloc([0...], c.head.chunksize)!;

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

    endian::leputu64(cb[cursor..cursor + 8], created_at: u64);

    return cb;
};
