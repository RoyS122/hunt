use fmt;
use engine;
use strings;
use errors;
use os;
use strconv;
use texts;
use types;

export fn company(args: []str) void = {

    if(len(args) < 2) {
        help(args);
        os::exit(1);
    };

    switch(args[1]) {
        case "list", "l" => list(args[1..]);
        case "add", "a" => add(args[1..]);
        case "edit", "e" => edit(args[1..]);
        case "show", "s" => show(args[1..]);
        case => { const hargs: []str = ["company"]; help(hargs);};
    };
    os::exit(1);
};


fn list(args: []str) void = {

     let flags: []engine::Flag = engine::parseflags(args)!;
     let onlystatus: engine::CompanyStatus = engine::CompanyStatus::NONE;
     let tags: []str = [];

     match (engine::checkflag(flags, "tags", 't')) {
        case let f: engine::Flag => {
            tags = strings::split(f.input, ",")!;
            yield;
        };
        case => yield;
     };


     match (engine::checkflag(flags, "status", 's')) {
         case let f: engine::Flag => {
            onlystatus = engine::companyStatusMatch(f.input);

         };
        case => yield;
     };


    let companies: []engine::CompanyIndex = engine::getCompanyIndexList();
    fmt::println("List of the companies:\n ID | Company Name | Status")!;
    for (let c .. companies) {

        if (onlystatus != engine::CompanyStatus::NONE && c.status != onlystatus) {
            continue;
        };

        if (len(tags) > 0) {
            let checkcompany: engine::Company = match(engine::getCompanyDetails(c.head.id, c.name)) {
                case let cc: engine::Company => yield cc;
                case => continue;
            };

            let tagfit: u8 = 0;
            for (let tagc..tags) {
                for(let t..checkcompany.tags) {
                    if (tagc == t.title) {
                        tagfit += 1;
                    };
                };
            };
            if (tagfit != len(tags)) {
                continue;
            };

        };

        let company_status_str: str = "";

        if(c.status != engine::CompanyStatus::NONE) {
            company_status_str = engine::CompanyStatusText[c.status: u8];
        };



        fmt::println(c.head.id, " | ", c.name, " | ", company_status_str)!;
    };
};

fn add(args: []str) void = {

    if(len(args) < 2) {
        fmt::println("You should give a name for the new company.")!;
        return;
    };

    if(strings::hasprefix(args[1], "-")) {
        fmt::println("You should use first argument of the add command to give a name for the company.")!;
        return;
    };

    let flags: []engine::Flag = engine::parseflags(args)!;

    let adress: str = match (engine::checkflag(flags, "adress", 'a')) {
        case let f: engine::Flag => yield f.input;
        case => yield "";
    };

    let tags: str = match (engine::checkflag(flags, "tags", 't')) {
        case let f: engine::Flag => yield f.input;
        case => yield "";
    };

    let status: str = match (engine::checkflag(flags, "status", 's')) {
        case let f: engine::Flag => yield f.input;
        case => yield "";
    };

   match(engine::companyadd(args[1], adress, status, tags)) {
        case let e: errors::error => fmt::println("Fail to add company.")!;
        case let id: u32 => fmt::printfln("La company {} a bien été ajoutée à l'id {}", args[1], id)!;
   };
};

fn edit(args: []str) void = {

    if(len(args) < 2) {
        fmt::println("You should give at least the id of the company to edit.")!;
        return;
    };

    if(strings::hasprefix(args[1], "-")) {
        fmt::println("You should use first argument of the add command to give a name for the company.")!;
        return;
    };

    let flags: []engine::Flag = engine::parseflags(args)!;

    let name: str = match (engine::checkflag(flags, "name", 'n')) {
        case let f: engine::Flag => yield f.input;
        case => yield "";
    };

    let adress: str = match (engine::checkflag(flags, "adress", 'a')) {
        case let f: engine::Flag => yield f.input;
        case => yield "";
    };

    let tags: str = match (engine::checkflag(flags, "tags", 't')) {
        case let f: engine::Flag => yield f.input;
        case => yield "";
    };

    let status: str = match (engine::checkflag(flags, "status", 's')) {
        case let f: engine::Flag => yield f.input;
        case => yield "";
    };

    let id: u32 = match(strconv::stou32(args[1])) {
        case let u: u32 => yield u;
        case => fmt::println("Id should be a number between 0 and {}", types::U32_MAX)!; os::exit(2);
    };

    let res: u32 = engine::companyedit(id, name, adress, status, tags);
    if (res != 0) {
        fmt::println("Fail to edit company: \nid: {}, \nerror: {}", id, res)!;
        os::exit(1);
    };

    fmt::println("Company at index,", id, "has been updated")!;

};

fn show(args: []str) void = {
    if(len(args) < 2) {
        fmt::println("You should give a name or an id for the company to show.")!;
        return;
    };

    if(strings::hasprefix(args[1], "-")) {
        fmt::println("You should use first argument of the add command to give a name for the company.")!;
        return;
    };

    let cquery: engine::CompanyQuery = match(strconv::stou32(args[1])) {
        case let id: u32 => yield id;
        case => yield args[1];
    };

    let c: engine::Company = match (engine::companyGet(cquery)) {
        case let c: engine::Company => yield c;
        case void => {
            fmt::println("Company not recognized (Not registered yet or wrong name or id).")!;
            return;
        };
    };
    let tagstr: str = "";
    for(let tag .. c.tags) {
        tagstr = strings::concat(tagstr, fmt::asprintf("\n      - {}", tag.title)!)!;
    };
    let statusstr: str = "";
    if(c.status: u8 < 4) {
        statusstr = engine::CompanyStatusText[c.status: u8];
    };
    let datestr: str = engine::formatdate(c.created_at);
    defer free(datestr);
    fmt::printfln(texts::SHOW_COMPANY, c.name, c.head.id, c.adress, tagstr, statusstr, datestr)!;
};
