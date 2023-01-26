const Builder = @import("std").build.Builder;
const builtin = @import("builtin");
const std = @import("std");

const plat="qemu_rv64";
const stdout = std.io.getStdOut().writer();

pub fn build(b: *Builder) !void {
    const target = .{
        .cpu_arch = .riscv64,
        .cpu_model = .{ .explicit = &std.Target.riscv.cpu.baseline_rv64 },
        .os_tag = .freestanding,
        .abi = .none,
    };


	// .1
    const src = b.addExecutable("out.elf", "main.zig");
    src.addAssemblyFile("boot.S");
    src.setTarget(target);
    src.setBuildMode(std.builtin.Mode.Debug);
    //src.want_lto = false;
    src.code_model = .medium;//medium;
    src.setLinkerScriptPath(.{ .path = "linker.ld" });


    //.2
    const elf = b.addInstallArtifact(src);
    elf.step.dependOn(&src.step);

    const bin = b.addInstallRaw(src, "out.bin", .{});
    bin.step.dependOn(&src.step);


    //.3
    const build_elf = b.step("elf", "elf file");
    build_elf.dependOn(&elf.step);

    const build_bin = b.step("bin", "bin file");
    build_bin.dependOn(&bin.step);


    b.default_step = build_elf;
}
