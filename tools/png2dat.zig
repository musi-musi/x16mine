const std = @import("std");
const img = @import("zigimg");

const Allocator = std.mem.Allocator;

const File = std.fs.File;
const Image = img.Image;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    try genWallTiles(try Files.init(allocator, "wall_tiles"));
    try genWallTiles(try Files.init(allocator, "wall_tiles_flat"));
    try genPalette(try Files.init(allocator, "palette"));
    try gen4bpp(allocator, "floor_tiles");
    try gen4bpp(allocator, "player_sprite");
}

// pub fn convert(allocator: Allocator, in_name: []const u8, out_name: []const u8) !void {
//     var image = try img.Image.fromFilePath(allocator, in_name);
//     defer image.deinit();
//     std.log.info("format: {s}", .{@tagName(image.pixelFormat())});
//     var out_file = try std.fs.cwd().createFile(out_name, .{});
//     defer out_file.close();
//     const out = out_file.writer();
//     try out.writeByte(0xB0);
//     try out.writeByte(0x0B);
//     var iter = image.iterator();
//     while (iter.next()) |color| {
//         try out.writeByte(color.toRgba(u8).r);
//     }
// }

const Files = struct {
    allocator: Allocator,
    image: img.Image,
    out_file: File,
    writer: File.Writer,

    fn init(allocator: Allocator, comptime name: []const u8) !Files {
        var image = try img.Image.fromFilePath(allocator, name ++ ".png");
        errdefer image.deinit();
        const out_file = try std.fs.cwd().createFile(name ++ ".dat", .{});
        return Files{
            .allocator = allocator,
            .image = image,
            .out_file = out_file,
            .writer = out_file.writer(),
        };
    }

    fn deinit(self: *Files) void {
        self.image.deinit();
        self.out_file.close();
    }
};

fn genPalette(files: Files) !void {
    var iter = files.image.iterator();
    while (iter.next()) |pixel| {
        const r: u8 = @intFromFloat(pixel.r * 15);
        const g: u8 = @intFromFloat(pixel.g * 15);
        const b: u8 = @intFromFloat(pixel.b * 15);
        try files.writer.writeByte((g << 4) + b);
        try files.writer.writeByte(r);
    }
}

fn toIndexed(image: Image) ![]u8 {
    const len = image.width * (image.height - 1);
    const data = try image.allocator.alloc(u8, len / 2);
    var palette: [16]u32 = undefined;
    var pixels = image.pixels.rgba32;
    for (palette[0..], 0..) |*p, i| {
        p.* = @bitCast(pixels[i]);
    }
    pixels = pixels[image.width..];
    var p: usize = 0;
    while (p < pixels.len) : (p += 2) {
        const msb = indexFromPixel(@bitCast(pixels[p]), palette);
        const lsb = indexFromPixel(@bitCast(pixels[p + 1]), palette);
        data[p / 2] = lsb + (msb << 4);
    }
    return data;
}

fn indexFromPixel(pixel: u32, palette: [16]u32) u8 {
    for (palette[0..], 0..) |p, i| {
        if (pixel == p) {
            return @intCast(i);
        }
    }
    return 0;
}

fn genWallTiles(files: Files) !void {
    const size = (files.image.width * (files.image.height - 1)) & (~@as(usize, 0b111));
    _ = size;

    // const data = try files.allocator.alloc([4][8]u8, size * 16 * 16);
    // defer files.allocator.free(data);

    var pixels = files.image.pixels.rgba32;
    var palette: [16]u32 = undefined;
    for (palette[0..], 0..) |*p, i| {
        p.* = @bitCast(pixels[i]);
    }
    pixels = pixels[files.image.width..];
    while (pixels.len > 0) : (pixels = pixels[16 * 16 ..]) {
        var tile: [16 * 16 / 2]u8 = undefined;
        var p: usize = 0;
        while (p < 16 * 16) : (p += 2) {
            const msb = indexFromPixel(@bitCast(pixels[p]), palette);
            const lsb = indexFromPixel(@bitCast(pixels[p + 1]), palette);
            tile[p / 2] = lsb + (msb << 4);
        }
        for (0..4) |subtile| {
            for (0..8) |row| {
                for (0..4) |col| {
                    if (subtile % 2 == 0) {
                        try files.writer.writeByte(tile[subtile * 8 * 4 + row * 8 + col]);
                    } else {
                        try files.writer.writeByte(tile[(subtile - 1) * 8 * 4 + row * 8 + col + 4]);
                    }
                }
            }
        }
    }
    // try files.writer.writeAll(std.mem.asBytes(&tile));
}

fn gen4bpp(allocator: Allocator, comptime name: []const u8) !void {
    var files = try Files.init(allocator, name);
    defer files.deinit();
    const data = try toIndexed(files.image);
    defer allocator.free(data);
    try files.writer.writeAll(data);
}

/// turn the first 8 pixels into a packed byte
fn byteFromPixels(pixels: anytype) u8 {
    var byte: u8 = 0;
    for (0..8) |i| {
        byte <<= 1;
        if (pixels[i].r != 0) {
            byte += 1;
        }
    }
    return byte;
}
