const std = @import("std");
const Pkg = std.build.Pkg;

pub fn build(b: *std.build.Builder) void {
    const target = std.zig.CrossTarget{ .os_tag = .linux };     // Because zCord doesn't work in windows enviroment
    const mode = b.standardReleaseOptions();

    const exe = b.addExecutable("kazusa-bot", "src/main.zig");
    defer exe.install();

    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.strip = b.option(bool, "strip", "Omit debug information") orelse false;

    exe.addPackage(packages.zCord);
    std.log.notice(
        \\`zCord` doesn't work in windows enviroment
        \\so generate linux binary by default
    , .{});
}

const packages = struct {
    pub const zCord = Pkg{
        .name = "zCord",
        .path = "lib/zCord/src/main.zig",
        .dependencies = &[_]Pkg{ iguanaTLS, hzzp, wz },
    };
    pub const iguanaTLS = Pkg{
        .name = "iguanaTLS",
        .path = "lib/iguanaTLS/src/main.zig",
    };
    pub const hzzp = Pkg{
        .name = "hzzp",
        .path = "lib/hzzp/src/main.zig",
    };
    pub const wz = Pkg{
        .name = "wz",
        .path = "lib/wz/src/main.zig",
        .dependencies = &[_]Pkg{ hzzp },
    };
};
