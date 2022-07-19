const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const exe = b.addExecutable("spin-example", "example/main.zig");
    exe.addPackagePath("spin", "src/spin.zig");
    exe.addCSourceFile("src/spin-http.c", &.{});
    exe.addIncludeDir("src");
    exe.linkLibC();
    exe.setTarget(.{ .cpu_arch = .wasm32, .os_tag = .wasi });
    exe.setBuildMode(mode);
    exe.install();

    const lib = b.addStaticLibrary("spin-zig", "src/spin.zig");
    lib.addIncludeDir("src");
    lib.linkLibC();
    lib.addCSourceFile("src/spin-http.c", &.{});
    lib.setBuildMode(mode);
    lib.install();

    const main_tests = b.addTest("src/spin.zig");
    main_tests.setBuildMode(mode);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&main_tests.step);
}
