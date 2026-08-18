const std = @import("std");
const Tuple = struct {
    a: i32,
    b: i32,
};
const Command = union(enum) {
    Ping,
    Echo: []u8,
    Add: Tuple,
    Quit,
};

pub fn main() void {
    const command: Command = .{ .Add = .{ .a = 2, .b = 3 } };
    switch (command) {
        Command.Ping => std.debug.print("I am Ping\n", .{}),
        Command.Echo => std.debug.print("I am Echo\n", .{}),
        Command.Add => |add| std.debug.print("I am Add, adding {} and {}\n", .{ add.a, add.b }),
        Command.Quit => std.debug.print("I am Quit\n", .{}),
    }
}
