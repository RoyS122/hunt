use fmt;
use engine;
use strings;
use errors;
use os;
use strconv;
use texts;

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

    match (engine::checkflag(flags, "test", 't')) {
        case let f: engine::Flag => {
            fmt::printfln("Flag test trouvé !")!;
            fmt::printfln("Valeur : {}", f.input)!;
        };
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
    fmt::println("Company edit called!")!;
};


fn show(args: []str) void = {
    fmt::println("Company show called!")!;

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
        case => {
            fmt::println("Company not recognized (Not registered yet or wrong name or id).")!;
            return;
        };
    };
    let tagstr: str = "";
    for(let tag .. c.tags) {
        tagstr = strings::concat(tagstr, fmt::asprintf("      - {}\n", tag.title)!)!;
    };
    let statusstr: str = "";
    if(c.status: u8 < 4) {
        statusstr = engine::CompanyStatusText[c.status: u8];
    };
    let datestr: str = engine::formatdate(c.created_at);
    defer free(datestr);
    fmt::printfln(texts::SHOW_COMPANY, c.name, c.head.id, c.adress, tagstr, statusstr, datestr)!;
};
