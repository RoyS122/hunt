use os;
use fmt;
use commands;


export fn main() void = {


    if (len(os::args) < 2) {
        commands::help(os::args[1..]);
        os::exit(1);
    };

    switch (os::args[1]) {
        case "company", "comp" => commands::company(os::args[1..]);
        case "contact", "cont" => commands::contact(os::args[1..]);
        case "action", "a" => commands::action(os::args[1..]);
        case "interaction", "i" => commands::interaction(os::args[1..]);
        case "next", "n" => commands::next(os::args[1..]);
        case "due", "d" => commands::due(os::args[1..]);
        case "init"  => commands::huntinit(os::args[1..]);
        case => commands::help(os::args[1..]);
    };


};
