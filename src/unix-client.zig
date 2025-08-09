const std = @import("std");
const posix = std.posix;
const net = std.net;

const wl = @import("wayland-client.zig");

pub fn main() !void {
    var da: std.heap.DebugAllocator(.{}) = .init;
    defer _ = da.deinit();
    const allocator = da.allocator();

    var display = try wl.Display.init(allocator, .{});
    defer display.deinit();

    try display.getRegistry();

    std.Thread.sleep(1000);

    try display.read();

    // const registry = c.wl_display_get_registry(display);
    // _ = c.wl_registry_add_listener(registry, &registry_listener, null);
    // _ = c.wl_display_roundtrip(display);

    // const hello = "Hello from client";
    //
    // const stream = try std.net.connectUnixSocket("./test");
    // defer stream.close();
    //
    // var writer = stream.writer(&.{});
    // _ = try writer.interface.writeVec(&.{hello});
    // std.debug.print("Hello message sent\n", .{});
    //
    // var flat_buf = std.mem.zeroes([1024]u8);
    // var buf: [1][]u8 = .{&flat_buf};
    // var reader = stream.reader(&.{});
    // _ = try reader.interface().readVec(&buf);
    // std.debug.print("{s}\n", .{flat_buf});
}
