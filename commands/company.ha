use os;
use fmt;


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
    fmt::println("Company list called!")!;
};



fn add(args: []str) void = {
    fmt::println("Company add called!")!;
};


fn edit(args: []str) void = {
    fmt::println("Company edit called!")!;
};


fn show(args: []str) void = {
    fmt::println("Company show called!")!;
};
