use os;
use fmt;
use engine;


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
    fmt::println("company add")!;
};


fn edit(args: []str) void = {
    fmt::println("Company edit called!")!;
};


fn show(args: []str) void = {
    fmt::println("Company show called!")!;
};
