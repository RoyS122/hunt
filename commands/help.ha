use fmt;
use strings;

export fn help(args: []str) void = {
    args = args[1..];
    if (len(args) == 0 ) {
        fmt::println("Usage: hunt <command> [subcommand] {arguments}\n")!;
        fmt::println("Commands:")!;
        for (let cmd .. COMMAND_LIST) {
            fmt::printfln("  {} ({}) - {}", cmd.name, cmd.short, cmd.desc)!;
        };
        fmt::println("\nRun 'hunt help <command>' for more information on a specific command.")!;
    } else {
        let target = args[0];
        let found = false;
        for (let cmd .. COMMAND_LIST) {
            if (cmd.name == target || cmd.short == target) {
                found = true;
                fmt::printfln("Command: {} ({})", cmd.name, cmd.short)!;
                fmt::printfln("Usage:   {}", cmd.usage)!;
                fmt::printfln("Description: {}", cmd.desc)!;

                if (len(cmd.examples) > 0) {
                    fmt::println("\nExamples:")!;
                    for (let ex .. cmd.examples) {
                        fmt::printfln("  {}", ex.0)!;
                        fmt::printfln("    -> {}", ex.1)!;
                    };
                };

                if (len(cmd.flags) > 0) {
                    fmt::println("\nFlags:")!;
                    for (let flag .. cmd.flags) {
                        fmt::printfln("  {}, {}    {}", flag.0, flag.1, flag.2)!;
                    };
                };

                if (len(cmd.subcommands) > 0) {
                    if (len(args) > 1) {
                        let sub_target = args[1];
                        let sub_found = false;
                        for (let sub .. cmd.subcommands) {
                            if (sub.name == sub_target || sub.short == sub_target) {
                                sub_found = true;
                                fmt::printfln("\nSubcommand: {}::{} ({})", cmd.name, sub.name, sub.short)!;
                                fmt::printfln("Usage:      {}", sub.usage)!;
                                fmt::printfln("Description: {}", sub.desc)!;

                                if (len(sub.examples) > 0) {
                                    fmt::println("\nExamples:")!;
                                    for (let ex .. sub.examples) {
                                        fmt::printfln("  {}", ex.0)!;
                                        fmt::printfln("    -> {}", ex.1)!;
                                    };
                                };

                                if (len(sub.flags) > 0) {
                                    fmt::println("\nFlags:")!;
                                    for (let flag .. sub.flags) {
                                        fmt::printfln("  {}, {}    {}", flag.0, flag.1, flag.2)!;
                                    };
                                };
                                break;
                            };
                        };
                        if (!sub_found) {
                            fmt::printfln("Unknown subcommand '{}' for command '{}'", sub_target, target)!;
                        };
                    } else {
                        fmt::println("\nSubcommands:")!;
                        for (let sub .. cmd.subcommands) {
                            fmt::printfln("  {} ({}) - {}", sub.name, sub.short, sub.desc)!;
                        };
                        fmt::println("\nRun 'hunt help <command> <subcommand>' for details.")!;
                    };
                };
                break;
            };
        };
        if (!found) {
            fmt::printfln("Unknown command '{}'", target)!;
        };
    };
};
