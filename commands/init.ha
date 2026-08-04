use fmt;
use os;
use fs;
use path;
use io;

use engine;


export fn huntinit(args: []str) void = {

    let flags: []engine::Flag = engine::parseflags(args)!;
    let huntDataPath: str = "./";

    match (engine::checkflag(flags, "path", 'p')) {
        case let f: engine::Flag => {
            if(f.input == "") {
                fmt::println("Path flag can't be empty.")!;
                os::exit(2);
            };
            huntDataPath = f.input;
        };
        case => yield;
    };

    let p: path::buffer = match(path::init(huntDataPath)) {
        case let b: path::buffer => yield b;
        case => {fmt::println("Invalid path!")!; os::exit(2);};
    };

    let pstat: fs::filestat = match(os::stat(huntDataPath)) {
        case let st: fs::filestat => yield st;
        case => {fmt::println("Path not available!")!; os::exit(2);};
    };

    if (fs::isdir(pstat.mode)) {
        path::push(&p, engine::HUNT_GLOBAL_DIR)!;
        os::mkdir(path::string(&p), 0o755)!;

        for(let dir .. engine::HUNT_DIRS) {
            let cp: path::buffer = p;
            path::push(&cp, dir)!;
            os::mkdir(path::string(&cp), 0o755)!;
            path::push(&cp, engine::INDEX_FILE)!;
            let file: io::file = os::create(path::string(&cp), 0o755)!;
            io::write(file, engine::FILE_HEADER)!;
        };
        fmt::println("Hunt directory created at:", path::string(&p))!;
        os::exit(1);
    }else{
        fmt::println("The path is not a directory.")!;
        os::exit(2);
    };
};
