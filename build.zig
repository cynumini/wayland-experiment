const std = @import("std");

pub fn build_exe(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    comptime name: []const u8,
    comptime src: []const u8,
    library: ?[]const u8,
) void {
    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/" ++ src),
        .target = target,
        .optimize = optimize,
    });

    const exe = b.addExecutable(.{
        .name = name,
        .root_module = exe_mod,
    });

    if (library) |lib| {
        exe.linkSystemLibrary(lib);
        exe.linkLibC();
    }

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run-" ++ name, "Run the app");
    run_step.dependOn(&run_cmd.step);

    const exe_unit_tests = b.addTest(.{
        .root_module = exe_mod,
    });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    const test_step = b.step("test-" ++ name, "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);
}

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    build_exe(b, target, optimize, "client", "client.zig", "wayland-client");
    build_exe(b, target, optimize, "server", "server.zig", "wayland-server");
    build_exe(b, target, optimize, "unix-client", "unix-client.zig", null);
    build_exe(b, target, optimize, "unix-server", "unix-server.zig", null);
}
