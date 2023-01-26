
const std = @import("std");
const math = std.math;

const UART_REG_TXFIFO  = @intToPtr(*volatile u32, 0x10000000);
pub fn putc(ch:u8) void
{
	while (UART_REG_TXFIFO.* < 0) {}
	UART_REG_TXFIFO.* = ch;
}

pub fn puts(msg: []const u8) void {
	for(msg) |c| {
		putc(c);
	}
}

export fn main() void {
	puts("AAA");

	var a:usize = 1;
	var b:usize = 666;
	var m = @mod(a, 100);			// 
	var x:usize = @ptrToInt(&b) + m;
	var y:i64 = @intCast(i64, x);

	puts("===");

	var tmpBuff:[100:0]u8 = undefined;
	var tmpstr = std.fmt.bufPrintZ(&tmpBuff, "hello {} world!", .{y} ) catch "999";  // <=  HANG HERE!
	// var tmpstr = std.fmt.bufPrintZ(&tmpBuff, "hello {} world!", .{cast_test(y)} ) catch "999";  // <=  HANG HERE!
	for(tmpstr) |c| {
		putc(c);
	}
	puts("BBB");


	while(true) {}
}

pub fn panic(msg: []const u8, error_return_trace: ?*std.builtin.StackTrace, ret_addr: ?usize) noreturn {
	putc('P');
	puts(msg);
	//_ = msg;
	_ = error_return_trace;
	_ = ret_addr;
	while (true) {
		@breakpoint();
	}
}

