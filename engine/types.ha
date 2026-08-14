
export type Command = struct {
    name: str,
    short: str,

    desc: str,
    usage: str,
    examples: [](str, str),
    subcommands: []Command,
    flags: [](str, str, str),
};

export type Flag = struct {
    name: str,
    short: rune,
    input: str,
};



export type CompanyQuery = (u32|str);
