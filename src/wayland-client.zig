const std = @import("std");

fn write(array: *std.ArrayList(u8), value: anytype) void {
    const size = @sizeOf(@TypeOf(value));
    const bytes = @as([size]u8, @bitCast(value));
    // std.debug.print("value: {}\n", .{value});
    array.insertSlice(0, &bytes) catch unreachable;
    // std.debug.print("start\n", .{});
    // for (array.items) |i| {
    //     std.debug.print("i: {}\n", .{i});
    // }
    // std.debug.print("end\n", .{});
}

pub const Display = struct {
    allocator: std.mem.Allocator,
    stream: std.net.Stream,
    id: u32 = 1,
    current_id: u32 = 1,

    pub fn init(allocator: std.mem.Allocator, options: struct { name: ?[]const u8 = null }) !Display {
        var env_map = try std.process.getEnvMap(allocator);
        defer env_map.deinit();

        const runtime_dir = env_map.get("XDG_RUNTIME_DIR") orelse return error.CantGetXdgRuntimeDir;

        const name = blk: {
            if (options.name) |options_name| {
                break :blk options_name;
            } else {
                if (env_map.get("WAYLAND_DISPLAY")) |env_name| {
                    break :blk env_name;
                } else break :blk "wayland-0";
            }
        };

        const path = try std.fmt.allocPrint(allocator, "{s}/{s}", .{ runtime_dir, name });
        defer allocator.free(path);

        // std.debug.print("path: {s}\n", .{path});

        return .{
            .allocator = allocator,
            .stream = try std.net.connectUnixSocket(path),
        };
    }

    pub fn deinit(self: *Display) void {
        self.stream.close();
    }

    // opcode = 1
    pub fn getRegistry(self: *Display) !void {
        var message = std.ArrayList(u8).init(self.allocator);
        defer message.deinit();
        self.current_id += 1;
        const new_id = self.current_id;
        {
            defer write(&message, self.id); // object id
            defer {
                write(&message, @as(u16, @intCast(message.items.len + 8))); // length
                write(&message, @as(u16, 1)); // opcode
            }
            defer write(&message, new_id); // new_id
        }
        var writer = self.stream.writer(&.{});
        _ = try writer.interface.writeVec(&.{message.items});
        std.debug.print("Hello message sent\n", .{});
    }

    pub fn read(self: *Display) !void {
        for (0..100) |_| {
            var flat_buf = std.mem.zeroes([4]u8);
            var buf: [1][]u8 = .{flat_buf[0..4]};
            buf[0] = buf[0];

            // var reader = self.stream.reader(&.{});

            std.debug.print("a\n", .{});
            _ = try std.posix.read(self.stream.handle, &flat_buf);
            std.debug.print("b\n", .{});

            // _ = reader.interface().readVec(&buf) catch {};
            // const u32_value = std.mem.bytesAsSlice(u32, flat_buf[0..])[0];
            const u32_value = @as(u32, @bitCast(flat_buf));
            // const buf = reader.interface().take(1) catch "";
            std.debug.print("byte {x:0>8}\n", .{u32_value});
            for (flat_buf) |value| {
                std.debug.print("{x}", .{value});
            }
            std.debug.print("\n", .{});
        }
    }
};
