const std = @import("std");
const Args = struct {
    a: i32,
    b: i32,
};
const Name = enum {
    Ping,
    Echo,
    Add,
    Quit,
};
const Command = union(Name) {
    Ping,
    Echo: []const u8,
    Add: Args,
    Quit,
};

const ParseError = error{ UnknownCommand, InvalidNumber };

fn parse(input: []const u8) ParseError!Command {
    var tokens = std.mem.tokenizeAny(u8, input, " ");
    if (tokens.next()) |name_token| {
        const name = std.meta.stringToEnum(Name, name_token) orelse {
            return ParseError.UnknownCommand;
        };
        return switch (name) {
            .Ping => Command.Ping,
            .Quit => Command.Quit,
            .Echo => blk: {
                const s = tokens.rest();
                break :blk Command{ .Echo = s };
            },
            .Add => blk: {
                const aStr = tokens.next() orelse {
                    break :blk ParseError.InvalidNumber;
                };
                const a = std.fmt.parseInt(i32, aStr, 10) catch {
                    break :blk ParseError.InvalidNumber;
                };

                const bStr = tokens.next() orelse {
                    break :blk ParseError.InvalidNumber;
                };
                const b = std.fmt.parseInt(i32, bStr, 10) catch {
                    break :blk ParseError.InvalidNumber;
                };
                break :blk Command{ .Add = .{ .a = a, .b = b } };
            },
        };
    }
    // first call for tokens.next() == null
    return ParseError.UnknownCommand;
}

pub fn main() !void {
    const commands = [_][]const u8{ "Quit", "Ping", "Echo", "Echo HI! It's me", "Add 2 33", "What?", "Add 222", "Add banana 3" };
    for (commands) |commandStr| {
        if (parse(commandStr)) |command| {
            switch (command) {
                .Ping => std.debug.print("I am Ping\n", .{}),
                .Echo => |pl| std.debug.print("I am Echo, saying {s}\n", .{pl}),
                .Add => |add| std.debug.print("I am Add, adding {} and {}\n", .{ add.a, add.b }),
                .Quit => std.debug.print("I am Quit\n", .{}),
            }
        } else |err| {
            std.debug.print("Input: {s} gives: {}\n", .{ commandStr, err });
        }
    }
}
