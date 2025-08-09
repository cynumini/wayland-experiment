const std = @import("std");

const c = @cImport({
    @cInclude("wayland-server.h");
});

pub fn main() !void {
    const display = c.wl_display_create() orelse return error.UnableToCreateDisplay;
    defer c.wl_display_destroy(display);

    const socket = c.wl_display_add_socket_auto(display);
    if (socket[0] != 0) {
        std.debug.print("Unable to add socket to Wayland display.\n", .{});
    }
    std.debug.print("Running Wayland display on {s}\n", .{socket});
    c.wl_display_run(display);

    std.debug.print("Connection established\n", .{});
}
