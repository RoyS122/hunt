use engine;

export const COMMAND_LIST: [1]engine::Command = [
        engine::Command{
            name = "help",
            short = "h",
            desc = "Show the list of the commands or explain how to use a command.",
            examples = [("hunt help company", "Show the help page for company commands"), ("hunt h", "Show the list of the commands")],
            subcommands = [],
            flags = []
        },

        // engine::Command{},
        // engine::Command{},
        // engine::Command{},
        // engine::Command{},
        // engine::Command{},
        // engine::Command{},
        // engine::Command{},
    ];
