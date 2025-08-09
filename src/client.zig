const std = @import("std");

const c = @cImport({
    @cInclude("wayland-client.h");
});

fn registry_handle_global(data: ?*anyopaque, registry: ?*c.wl_registry, name: u32, interface: [*c]const u8, version: u32) callconv(.c) void {
    _ = data;
    _ = registry;
    std.debug.print("interface: '{s}', version: {}, name: {}\n", .{ interface, version, name });
}

fn registry_handle_global_remove(data: ?*anyopaque, registry: ?*c.wl_registry, name: u32) callconv(.c) void {
    _ = data;
    _ = registry;
    _ = name;
    // This space deliberately left blank
}

const registry_listener = c.wl_registry_listener{
    .global = registry_handle_global,
    .global_remove = registry_handle_global_remove,
};

pub fn main() !void {
    const display = c.wl_display_connect(null) orelse return error.FailedToConnectDisplay;
    const registry = c.wl_display_get_registry(display);
    _ = c.wl_registry_add_listener(registry, &registry_listener, null);
    _ = c.wl_display_roundtrip(display);
}
