const std = @import("std");

pub fn main() !void {
    var buffer: [1024]u8 = undefined;
    buffer = std.mem.zeroes([1024]u8);

    const stream = try std.net.connectUnixSocket("/tmp/wayland-experiment");
    defer stream.close();

    _ = try stream.writeAll("I love you!\n");
    _ = try stream.read(&buffer);

    std.debug.print("Received: {s}", .{buffer});
}
