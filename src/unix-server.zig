const std = @import("std");
const wl = @import("wayland-server.zig");
const posix = std.posix;
const net = std.net;

// pub fn main() !void {
// const WAYLAND_SOCKET;
// const WAYLAND_DISPLAY = 0;
// const XDG_RUNTIME_DIR = 0;
// const hello = "Hello from server";
//
// std.fs.cwd().deleteFile("./test") catch {};
//
// const address = try net.Address.initUnix("./test");
//
// var server = try address.listen(.{});
// defer server.deinit();
//
// while (true) {
//     const new_socket = try server.accept();
//
//     const stream = new_socket.stream;
//     defer stream.close();
//
//     var writer = stream.writer(&.{});
//     _ = try writer.interface.writeVec(&.{hello});
//     _ = try writer.interface.writeVec(&.{hello});
//     std.debug.print("Hello message sent\n", .{});
//
//     var flat_buf = std.mem.zeroes([512]u8);
//     var buf: [1][]u8 = .{flat_buf[0..512]};
//     var reader = stream.reader(&.{});
//     _ = try reader.interface().readVec(&buf);
//     std.debug.print("{s}\n", .{flat_buf});
// }
// }

pub fn main() !void {
    var da: std.heap.DebugAllocator(.{}) = .init;
    defer _ = da.deinit();
    const allocator = da.allocator();

    var display = try wl.Display.init(allocator);
    defer display.deinit();

    std.debug.print("Running Wayland display on {s}\n", .{display.socket.name});
    try display.run();

    std.debug.print("Connection established\n", .{});
}
