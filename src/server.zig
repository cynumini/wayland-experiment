const std = @import("std");

pub fn main() !void {
    std.fs.deleteFileAbsolute("/tmp/wayland-experiment") catch {};
    const address = try std.net.Address.initUnix("/tmp/wayland-experiment");
    var server = try address.listen(.{ .kernel_backlog = 1 });
    defer server.deinit();
    std.debug.print("Server is listening\n", .{});


    var buffer: [1024]u8 = undefined;
    buffer = std.mem.zeroes([1024]u8);

    while (true) {
        const connection = try server.accept();
        std.debug.print("Client connected\n", .{});
        while (true) {
            const size = try connection.stream.read(&buffer);
            if (size == 0) break;
            std.debug.print("Received: {s}", .{buffer});
            _ = try connection.stream.writeAll("I love you too!\n");
        }
        connection.stream.close();
    }
}
