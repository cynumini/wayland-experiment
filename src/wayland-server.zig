const std = @import("std");

const lock_suffix = ".lock";

pub const Socket = struct {
    name: []const u8,
    path: []const u8,
    lock_path: []const u8,
    address: std.net.Address,
};

pub const Display = struct {
    allocator: std.mem.Allocator,
    socket: Socket,

    pub fn init(allocator: std.mem.Allocator) !Display {
        var env_map = try std.process.getEnvMap(allocator);
        defer env_map.deinit();

        const runtime_dir = env_map.get("XDG_RUNTIME_DIR") orelse return error.CantGetXdgRuntimeDir;

        const socket: Socket = blk: for (0..32) |i| {
            const lock_path = try std.fmt.allocPrint(
                allocator,
                "{s}/wayland-{}{s}",
                .{ runtime_dir, i, lock_suffix },
            );
            const path = lock_path[0 .. lock_path.len - lock_suffix.len];
            const name = path[runtime_dir.len + 1 ..];

            const lock_file: ?std.fs.File = std.fs.openFileAbsolute(lock_path, .{}) catch |err| switch (err) {
                error.FileNotFound => null,
                else => return err,
            };

            if (lock_file) |lf| {
                defer lf.close();
                if (try lf.tryLock(.exclusive) == false) {
                    std.debug.print("unable to lock lockfile {s}, maybe another compositor is running\n", .{
                        lock_path,
                    });
                    allocator.free(lock_path);
                    continue;
                }
                try std.fs.deleteFileAbsolute(path);
            }

            break :blk .{
                .name = name,
                .path = path,
                .lock_path = lock_path,
                .address = try std.net.Address.initUnix(path),
            };
        } else return error.NoSuitableSocketPath;

        return .{ .allocator = allocator, .socket = socket };
    }

    pub fn deinit(self: *Display) void {
        std.fs.deleteFileAbsolute(self.socket.path) catch |err| switch (err) {
            error.FileNotFound => {},
            else => unreachable,
        };
        std.fs.deleteFileAbsolute(self.socket.lock_path) catch |err| switch (err) {
            error.FileNotFound => {},
            else => unreachable,
        };
        self.allocator.free(self.socket.lock_path);
    }

    pub fn run(self: *Display) !void {
        var server = try self.socket.address.listen(.{});
        defer server.deinit();

        const new_socket = try server.accept();

        const stream = new_socket.stream;
        defer stream.close();

        for (0..100) |_| {
            var flat_buf = std.mem.zeroes([4]u8);
            var buf: [1][]u8 = .{flat_buf[0..4]};
            var reader = stream.reader(&.{});
            _ = reader.interface().readVec(&buf) catch {};
            // const u32_value = std.mem.bytesAsSlice(u32, flat_buf[0..])[0];
            const u32_value = @as(u32, @bitCast(flat_buf));
            // const buf = reader.interface().take(1) catch "";
            std.debug.print("byte {x:0>8}\n", .{u32_value});
            for (flat_buf) |value|{
                std.debug.print("{x}", .{value});
            }
            std.debug.print("\n", .{});
        }
    }
};
