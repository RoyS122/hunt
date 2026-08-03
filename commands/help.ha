use fmt;


export fn help(args: []str) void = {
    if (len(args) > 0) {
        fmt::println("Print help for a command")!;
    }else{
        fmt::println("Print global help")!;
    };
};
