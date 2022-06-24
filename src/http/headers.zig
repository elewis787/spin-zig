const std = @import("std");
const mem = std.mem;
const ArrayList = std.ArrayList;
const StringHashMap = std.StringHashMap;
const Allocator = mem.Allocator;
const test_allocator = std.testing.allocator;

pub const Headers = struct {
    const HeaderMap = StringHashMap(ArrayList([]const u8));
    header_map: HeaderMap,
    allocator: Allocator,

    pub fn init(allocator: Allocator) Headers {
        return Headers{
            .allocator = allocator,
            .header_map = HeaderMap.init(allocator),
        };
    }

    pub fn deinit(self: *Headers) void {
        var iterator = self.header_map.iterator();
        while (iterator.next()) |entry| {
            entry.value_ptr.deinit();
        }
        self.header_map.deinit();
    }

    pub fn add(self: *Headers, key: []const u8, value: []const u8) !void {
        var v = try self.header_map.getOrPut(key);
        //new key
        if (!v.found_existing) {
            var list = ArrayList([]const u8).init(self.allocator);
            try list.append(value);
            v.value_ptr.* = list;
        } else {
            try v.value_ptr.*.append(value);
        }
    }

    pub fn set(self: *Headers, key: []const u8, value: []const u8) !void{
        var v = try self.header_map.getOrPut(key);
        //new key
        if (!v.found_existing) {
            var list = ArrayList([]const u8).init(self.allocator);
            try list.append(value);
            v.value_ptr.* = list;
        } else {
            try v.value_ptr.*.dinit();
            var list = ArrayList([]const u8).init(self.allocator);
            try list.append(value);
            v.value_ptr.* = list;
        }
    }

    pub fn get(self: Headers, key: []const u8) ?[]const u8 {
        // return first value found at key
        var list = self.header_map.get(key).?;
        if (list.items.len > 0) {
            return list.items[0];
        }
        return null;
    }

    pub fn values(self: Headers, key: []const u8) [][]const u8 {
        var list = self.header_map.get(key).?;
        return list.items;
    }

    pub fn del(self: *Headers, key: []const u8) bool{
        return self.header_map.remove(key);
    }

};

test "multiple headers" {
    var headers = Headers.init(test_allocator);
    defer headers.deinit();

    try headers.add("Accept", "Application/json,Application/xml");
    try headers.add("Accept", "Application/xml");
    try std.testing.expect(headers.header_map.count() == 1);
    try std.testing.expect(headers.header_map.contains("Accept"));

    var values = headers.values("Accept");
    try std.testing.expect(values.len == 2);
    var arStr: [2][]const u8 = [_][]const u8{ "Application/json,Application/xml", "Application/xml" };
    var test_slice = arStr[0..];
    try std.testing.expect(std.mem.eql(u8, values[0], test_slice[0]));
    try std.testing.expect(std.mem.eql(u8, values[1], test_slice[1]));
}

test "get with multi header" {
    var headers = Headers.init(test_allocator);
    defer headers.deinit();

    try headers.add("Accept", "Application/json,Application/xml");
    try headers.add("Accept", "Application/xml");
    try std.testing.expect(headers.header_map.count() == 1);
    try std.testing.expect(headers.header_map.contains("Accept"));

    try std.testing.expect(std.mem.eql(u8,headers.get("Accept").?,"Application/json,Application/xml"));
}
