use strings;
use os;
use fmt;

export fn parseflags(args: []str) ([]Flag | nomem) = {
    let flags: []Flag = [];
    let started: bool = false;

    for(let a .. args) {

        if(!strings::hasprefix(a, '-') ||len(a) < 2) {
            if (started) {
                flags[len(flags) - 1].input = a;
            };
            started = false;

            continue;
        };

        let f: Flag = Flag{...};

        let argsplit: []str = strings::split(a, "=")!;


        if(strings::hasprefix(argsplit[0], "--")) {
             f.name = strings::sub(argsplit[0], 2);
        }else{
            let arunes: []rune = strings::torunes(argsplit[0])!;
            f.short = arunes[1];
        };

        if (len(argsplit) > 1) {
            f.input = argsplit[1];
        }else{
            started = true;
        };
        append(flags, f)?;

    };

    return flags;
};

export fn checkflagbyshort(array: []Flag, short: rune) (Flag|void)  = {

    for(let f .. array) {
        if ( f.short == short ) {
            return f;
        };
    };

};

export fn checkflagbyname(array: []Flag, name: str) (Flag|void) = {

    for(let f .. array) {
        if ( f.name == name ) {
            return f;
        };
    };

};

export fn checkflag(array: []Flag, name: str, short: rune) (Flag|void) = {
    for(let f .. array) {
        if ( f.name == name || f.short == short) {
            return f;
        };
    };
};
