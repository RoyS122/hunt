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
        case "list", "l" => listcont(args[1..]);
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

     let positionFlag: str = match (engine::checkflag(flags, "position", 'p')) {
        case let f: engine::Flag => yield f.input;
        case => yield "";
     };


     let company: engine::Company = engine::Company{...};
     let companyFlagged: bool = false;
     match (engine::checkflag(flags, "company", 'c')) {
         case let f: engine::Flag => {
            let cquery: engine::CompanyQuery = match(strconv::stou32(f.input)) {
                case let id: u32 => yield id;
                case => yield f.input;
            };

            match(engine::companyGet(cquery)) {
                case let c: engine::Company => {
                    company = c;
                    companyFlagged = true;
                };
                case => yield;
            };
         };
        case => yield;
     };


    let contacts: []engine::ContactIndex = engine::getContactIndexList();
    fmt::println("List of the contacts:\n ID | Company Name (ID) | Contact Name | Position")!;
    for (let c .. contacts) {
        if ( companyFlagged ) {
            if (c.company_id != company.head.id) {
                continue;
            };
        };

        if ( positionFlag != "") {
            if(c.position == "") {
                if (engine::normalize(positionFlag) != engine::normalize("none")) {
                    continue;
                };
            }else{
                if (engine::normalize(positionFlag) == engine::normalize("none")) {
                    continue;
                };
                if (engine::normalize(positionFlag) != engine::normalize(c.position)) {
                    continue;
                };
            };
        };


        let curr_company_show: str = match (engine::companyGet(c.company_id)) {
            case let c: engine::Company => yield fmt::asprintf("{} ({})", c.name, c.head.id)!;
            case void => yield "none";
        };

        let positionDisp: str = c.position;
        if (positionDisp == "") {
            positionDisp = "none";
        };


        fmt::println("", c.head.id, " | ", curr_company_show," | ", c.first_name, c.last_name, " | ", positionDisp)!;
    };
};
