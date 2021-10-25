const std = @import("std");
const zCord = @import("zCord");

const util = @import("util.zig");

pub fn main() !void {
    try zCord.root_ca.preload(std.heap.page_allocator);

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();


    var auth_buf: [0x100]u8 = undefined;
    const auth = try std.fmt.bufPrint(&auth_buf, "Bot {s}", .{ std.os.getenv("DISCORD_AUTH") orelse return error.AuthNotFound });

    const c = try zCord.Client.create(.{
        .allocator = &gpa.allocator,
        .auth_token = auth,
        .intents = .{ .guild_messages = true },
    });
    defer c.destroy();

    try c.ws(struct {
        pub fn handleDispatch(client: *zCord.Client, name: []const u8, data: zCord.JsonElement) !void {
            if (!std.mem.eql(u8, name, "MESSAGE_CREATE")) return;

            _ = try util.isBot(data);
        }
    });
}
