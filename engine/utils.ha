use strings;
use time;
use time::date;

export fn normalize(s: str) str = {
    let bs: []u8 = strings::toutf8(s);
    let ns: []u8 = alloc([0u8...], len(s))!;

    let off: size = 0;

    for (let i: size = 0; i < len(bs); i += 1) {
        if ((bs[i] >= 'a') && (bs[i] <= 'z')) {
            ns[i - off] = bs[i];
            continue;
        };
        if((bs[i] >= 'A') && (bs[i]<= 'Z')) {
            ns[i-off] = bs[i] - 'A' + 'a';
            continue;
        };

        off += 1;
    };


    return strings::fromutf8_unsafe(ns[..len(bs) - off]);
};


export fn formatdate(ts: i64) str = {
    let instant = time::instant { sec = ts, nsec = 0 };
    let d = date::from_instant(date::LOCAL, instant);

    return date::asformat(date::STAMP, &d)!;
};


export fn companyStatusMatch(s: str) CompanyStatus = {
    return switch(s) {
        case "PROSPECT", "P", "p", "prospect" => yield CompanyStatus::PROSPECT;
        case "CLIENT", "C", "c", "client" => yield CompanyStatus::CLIENT;
        case "STALE", "S", "s", "stale" => yield CompanyStatus::STALE;
        case "DEAD", "D", "d", "dead" => yield CompanyStatus::DEAD;
        case => yield CompanyStatus::NONE;
    };
};
