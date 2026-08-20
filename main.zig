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

fn parseIntFromNext(tokens: *std.mem.TokenIterator(u8, .any)) ParseError!i32 {
    const str = tokens.next() orelse return ParseError.InvalidNumber;
    const num = std.fmt.parseInt(i32, str, 10) catch return ParseError.InvalidNumber;
    return num;
}

fn parse(input: []const u8) ParseError!Command {
    var tokens = std.mem.tokenizeAny(u8, input, " ");
    // empty input
    const name_token = tokens.next() orelse return ParseError.UnknownCommand;
    // not a Command Name
    const name = std.meta.stringToEnum(Name, name_token) orelse return ParseError.UnknownCommand;
    return switch (name) {
        .Ping => Command.Ping,
        .Quit => Command.Quit,
        .Echo => Command{ .Echo = tokens.rest() },
        .Add => blk: {
            const a = try parseIntFromNext(&tokens);
            const b = try parseIntFromNext(&tokens);
            break :blk Command{ .Add = .{ .a = a, .b = b } };
        },
    };
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

test "parse Ping" {
    const command = try parse("Ping");
    try std.testing.expectEqual(Command.Ping, command);
}

test "parse Quit" {
    const command = try parse("Quit");
    try std.testing.expectEqual(Command.Quit, command);
}

test "parse empty Echo" {
    const command = try parse("Echo");
    switch (command) {
        .Echo => |pl| try std.testing.expectEqualStrings("", pl),
        else => return error.WrongVariant,
    }
}

test "parse Echo more words" {
    const command = try parse("Echo Hi! It's me.");
    switch (command) {
        .Echo => |pl| try std.testing.expectEqualStrings("Hi! It's me.", pl),
        else => return error.WrongVariant,
    }
}

test "parse Add with two args" {
    const command = try parse("Add 2 33");
    switch (command) {
        .Add => |arg| {
            try std.testing.expectEqual(2, arg.a);
            try std.testing.expectEqual(33, arg.b);
        },
        else => return error.WrongVariant,
    }
}

test "parse Add drops extra args" {
    const command = try parse("Add 1 2 199");
    switch (command) {
        .Add => |arg| {
            try std.testing.expectEqual(1, arg.a);
            try std.testing.expectEqual(2, arg.b);
        },
        else => return error.WrongVariant,
    }
}

test "parse rejects unknown command" {
    try std.testing.expectError(ParseError.UnknownCommand, parse("What?"));
}

test "parse rejects Add without operands" {
    try std.testing.expectError(ParseError.InvalidNumber, parse("Add"));
}

test "parse rejects Add with one operand" {
    try std.testing.expectError(ParseError.InvalidNumber, parse("Add 123"));
}

test "parse rejects Add with an invalid first operand" {
    try std.testing.expectError(ParseError.InvalidNumber, parse("Add bannana 11"));
}

test "parse rejects Add with an invalid second operand" {
    try std.testing.expectError(ParseError.InvalidNumber, parse("Add 11 bannana"));
}
test "parse rejects empty input" {
    try std.testing.expectError(ParseError.UnknownCommand, parse(""));
}
