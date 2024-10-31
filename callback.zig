//------------------------------------------------------------------------------
// Copyright (c) 2024 Andreas Thorsén
//
// This code is released into the public domain.
// You can redistribute it and/or modify it without any restrictions.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED.
//------------------------------------------------------------------------------
const std = @import("std");

const CPU = struct {
    pub fn runWithCallback(_: *const CPU, callback: fn (*const i32) void, value: *const i32) void {
        callback(value);
    }
};

pub fn main() !void {
    const value: i32 = 42;
    const cpu = CPU{};

    cpu.runWithCallback(struct {
        fn call(v: *const i32) void {
            std.debug.print("Value: {}\n", .{v.*});
        }
    }.call, &value);
}