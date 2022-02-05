const std = @import("std");
const argsParser = @import("args.zig");

pub fn main() !u8 {
    var argsAllocator = std.heap.page_allocator;

    const options = argsParser.parseWithVerbForCurrentProcess(
        struct {},
        union(enum) {
            compact: struct {
                // This declares long options for double hyphen
                host: ?[]const u8 = null,
                port: u16 = 3420,
                mode: enum { default, special, slow, fast } = .default,

                // This declares short-hand options for single hyphen
                pub const shorthands = .{
                    .H = "host",
                    .p = "port",
                };
            },
            reload: struct {
                // This declares long options for double hyphen
                force: bool = false,

                // This declares short-hand options for single hyphen
                pub const shorthands = .{
                    .f = "force",
                };
            },
        },
        argsAllocator,
        .print,
    ) catch return 1;
    defer options.deinit();

    std.debug.print("executable name: {s}\n", .{options.executable_name});

    switch (options.verb.?) {
        .compact => |opts| {
            inline for (std.meta.fields(@TypeOf(opts))) |fld| {
                std.debug.print("\t{s} = {any}\n", .{
                    fld.name,
                    @field(opts, fld.name),
                });
            }
        },
        .reload => |opts| {
            inline for (std.meta.fields(@TypeOf(opts))) |fld| {
                std.debug.print("\t{s} = {any}\n", .{
                    fld.name,
                    @field(opts, fld.name),
                });
            }
        },
    }

    std.debug.print("parsed positionals:\n", .{});
    for (options.positionals) |arg| {
        std.debug.print("\t'{s}'\n", .{arg});
    }

    return 0;
}
