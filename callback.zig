// Simple callback example
// Goal is to highlight how to use callbacks with zig
// in the most simple way possible
const std = @import("std");

// Define the type for the callback function
const Callback = *const fn (context: *anyopaque, value: i32) callconv(.C) void;

// A mock CPU structure with method to run with a callback
const CPU = struct {
    fn Calc(_: *CPU) void {
        std.debug.print("calc\n", .{});
    }
    pub fn runWithCallback(cpu: *CPU, callback: Callback, context: *anyopaque) void {
        // This is where CPU would perform operations
        // Here, just calling the callback with some value
        callback(context, 42);
        cpu.Calc();
    }
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var x: i32 = 10;
    var y: i32 = 20;

    var cpu = CPU{};

    // Define the callback inline
    const callback: Callback = struct {
        pub fn callbackFn(context: *anyopaque, value: i32) callconv(.C) void {
            // Cast the context back to our known type
            const ctx = @as(*struct { x: *i32, y: *i32 }, @alignCast(@ptrCast(context)));
            // Access and modify variables through pointers
            ctx.x.* += value;
            ctx.y.* *= value;
            std.debug.print("Callback called with value {d}. x = {d}, y = {d}\n", .{ value, ctx.x.*, ctx.y.* });
        }
    }.callbackFn;

    // Create a context that holds pointers to x and y
    const context = try allocator.create(struct { x: *i32, y: *i32 });
    context.* = .{ .x = &x, .y = &y };

    // Call the runWithCallback method, passing the callback and context
    cpu.runWithCallback(callback, @ptrCast(context));

    // Print final values
    std.debug.print("After callback, x = {d}, y = {d}\n", .{ x, y });

    // Free the memory we allocated for context
    allocator.destroy(context);
}
