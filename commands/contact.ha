use fmt;
use os;
use strings;
use engine;
use strconv;
use errors;
use types;

export fn contact(args: []str) void = {
    if(len(args) < 2) {
        help(args);
        os::exit(1);
    };
    switch(args[1]) {
        // case "list", "l" => list(args[1..]);
        case "add", "a" => addcont(args[1..]);
        // case "edit", "e" => edit(args[1..]);
        // case "show", "s" => show(args[1..]);
        case => { const hargs: []str = ["contact"]; help(hargs);};
    };
    os::exit(1);
};



fn addcont(args: []str) void = {

    if(len(args) < 3) {
        fmt::println("You should give a first and last name for the new contact.")!;
        return;
    };

    if(strings::hasprefix(args[1], "-") ||strings::hasprefix(args[2], "-")) {
        fmt::println("You should use first and second argument of the add command to give the names for the contact.")!;
        return;
    };

    let flags: []engine::Flag = engine::parseflags(args)!;

    let phone: str = match (engine::checkflag(flags, "phone", 'p')) {
        case let f: engine::Flag => yield f.input;
        case => yield "";
    };

    let email: str = match (engine::checkflag(flags, "email", 'e')) {
        case let f: engine::Flag => yield f.input;
        case => yield "";
    };

    let position: str = match (engine::checkflag(flags, "position", 'P')) {
        case let f: engine::Flag => yield f.input;
        case => yield "";
    };

    let company: str = match (engine::checkflag(flags, "company", 'c')) {
        case let f: engine::Flag => yield f.input;
        case => yield "";
    };


    let cquery: engine::CompanyQuery = match(strconv::stou32(company)) {
        case let id: u32 => yield id;
        case => yield company;
    };

    if (company == "") {
        cquery = types::U32_MAX;
    };
   match(engine::contactadd(args[1], args[2], cquery, email, phone, position)) {
        case let e: errors::error => fmt::println("Fail to add contact.")!;
        case let id: u32 => fmt::printfln("Le contact {} {} a bien été ajoutée à l'id {}", args[1], args[2], id)!;
   };
};


fn listcont(args: []str) void = {
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
