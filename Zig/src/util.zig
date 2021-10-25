const std = @import("std");
const zCord = @import("zCord");

pub fn debugPrintElement(data: zCord.JsonElement) !void {
    const stderr = std.io.getStdErr().writer();
    try data.debugDump(stderr);
}

pub fn isBot(data: zCord.JsonElement) !bool {
    try debugPrintElement(data);
    return true;
}
