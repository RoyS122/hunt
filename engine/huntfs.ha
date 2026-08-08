use fs;
use io;
use os;

export fn readfile(path: str) ([]u8 | fs::error) = {
    let file = match (os::open(path)) {
        case let b: io::file =>  yield b;
        case let err: fs::error => return err;
    };

    defer io::close(file)!;

    let stat = os::fstat(file)!;

    let filebytes = alloc([0u8...], stat.sz)!;

    io::readall(file, filebytes)!;
    return filebytes;
};
