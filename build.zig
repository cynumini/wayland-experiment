const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});

    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const exe = b.addExecutable(.{
        .name = "wayland_experiment",
        .root_module = exe_mod,
    });

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const exe_unit_tests = b.addTest(.{
        .root_module = exe_mod,
    });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);

    // TODO: remove sever
    const exe_server_mod = b.createModule(.{
        .root_source_file = b.path("src/server.zig"),
        .target = target,
        .optimize = optimize,
    });

    const exe_server = b.addExecutable(.{
        .name = "wayland_experiment_server",
        .root_module = exe_server_mod,
    });

    b.installArtifact(exe_server);

    const run_server_cmd = b.addRunArtifact(exe_server);

    run_server_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_server_cmd.addArgs(args);
    }

    const run_step_server = b.step("run-server", "Run the server");
    run_step_server.dependOn(&run_server_cmd.step);

    const exe_server_unit_tests = b.addTest(.{
        .root_module = exe_server_mod,
    });

    const run_exe_server_unit_tests = b.addRunArtifact(exe_server_unit_tests);

    test_step.dependOn(&run_exe_server_unit_tests.step);
}
