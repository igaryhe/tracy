const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

const version: std.SemanticVersion = .{ .major = 0, .minor = 12, .patch = 2 };

pub fn build(b: *std.Build) Allocator.Error!void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const linkage = b.option(
        std.builtin.LinkMode,
        "linkage",
        "Prefer building statically or dynamically linked libraries (default: static)",
    ) orelse .static;
    const lto = b.option(
        std.zig.LtoMode,
        "lto",
        "Enable Link-Time optimization",
    ) orelse .none;
    const on_demand = b.option(
        bool,
        "on_demand",
        "On-demand profiling",
    ) orelse false;
    const callstack = b.option(
        bool,
        "callstack",
        "Enforce callstack collection for tracy regions",
    ) orelse false;
    const no_callstack = b.option(
        bool,
        "no_callstack",
        "Disable all callstack related functionality",
    ) orelse false;
    const no_callstack_inlines = b.option(
        bool,
        "no_callstack_inlines",
        "Disables the inline functions in callstacks",
    ) orelse false;
    const only_localhost = b.option(
        bool,
        "only_localhost",
        "Only listen on the localhost interface",
    ) orelse false;
    const no_broadcast = b.option(
        bool,
        "no_broadcast",
        "Disable client discovery by broadcast to local network",
    ) orelse false;
    const only_ipv4 = b.option(
        bool,
        "only_ipv4",
        "Tracy will only accept connections on IPv4 addresses (disable IPv6)",
    ) orelse false;
    const no_code_transfer = b.option(
        bool,
        "no_code_transfer",
        "Disable collection of source code",
    ) orelse false;
    const no_context_switch = b.option(
        bool,
        "no_context_switch",
        "Disable capture of context switches",
    ) orelse false;
    const no_exit = b.option(
        bool,
        "no_exit",
        "Client executable does not exit until all profile data is sent to server",
    ) orelse false;
    const no_sampling = b.option(bool, "no_sampling", "Disable call stack sampling") orelse false;
    const no_verify = b.option(bool, "no_verify", "Disable zone validation for C API") orelse false;
    const no_vsync_capture = b.option(
        bool,
        "no_vsync_capture",
        "Disable capture of hardware Vsync events",
    ) orelse false;
    const no_frame_image = b.option(
        bool,
        "no_frame_image",
        "Disable the frame image support and its thread",
    ) orelse false;
    const no_system_tracing = b.option(
        bool,
        "no_system_tracing",
        "Disable systrace sampling",
    ) orelse false;
    const patchable_nopsleds = b.option(
        bool,
        "patchable_nopsleds",
        "Enable nopsleds for efficient patching by system-level tools (e.g. rr)",
    ) orelse false;
    const timer_fallback = b.option(
        bool,
        "timer_fallback",
        "Use lower resolution timers",
    ) orelse false;
    const libunwind_backtrace = b.option(
        bool,
        "libunwind_backtrace",
        "Use libunwind backtracing where supported",
    ) orelse false;
    const symbol_offline_resolve = b.option(
        bool,
        "symbol_offline_resolve",
        "Instead of full runtime symbol resolution, only resolve the image path and offset to enable offline symbol resolution",
    ) orelse false;
    const libbacktrace_elf_dynload_support = b.option(
        bool,
        "libbacktrace_elf_dynload_support",
        "Enable libbacktrace to support dynamically loaded elfs in symbol resolution resolution after the first symbol resolve operation",
    ) orelse false;
    const delayed_init = b.option(
        bool,
        "delayed_init",
        "Enable delayed initialization of the library (init on first call)",
    ) orelse false;
    const manual_lifetime = b.option(
        bool,
        "manual_lifetime",
        "Enable the manual lifetime management of the profile",
    ) orelse false;
    const fibers = b.option(bool, "fibers", "Enable fibers support") orelse false;
    const no_crash_handler = b.option(bool, "no_crash_handler", "Disable crash handling") orelse false;
    const verbose = b.option(bool, "verbose", "Enable verbose logging") orelse false;
    const debuginfod = b.option(bool, "debuginfod", "Enable debuginfod support") orelse false;

    const mod = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .link_libcpp = true,
    });

    const lib = b.addLibrary(.{
        .linkage = linkage,
        .name = "tracy",
        .root_module = mod,
        .version = version,
    });
    lib.lto = lto;

    var flags: ArrayList([]const u8) = try .initCapacity(b.allocator, 8);
    defer flags.deinit(b.allocator);

    flags.appendAssumeCapacity("-std=c++11");
    flags.appendAssumeCapacity("-DTRACY_ENABLE");
    if (linkage == .dynamic) {
        try flags.append(b.allocator, "-DTRACY_EXPORTS");
    }
    if (on_demand) {
        try flags.append(b.allocator, "-DTRACY_ON_DEMAND");
    }
    if (callstack) {
        try flags.append(b.allocator, "-DTRACY_CALLSTACK");
    }
    if (no_callstack) {
        try flags.append(b.allocator, "-DTRACY_NO_CALLSTACK");
    }
    if (no_callstack_inlines) {
        try flags.append(b.allocator, "-DTRACY_NO_CALLSTACK_INLINES");
    }
    if (only_localhost) {
        try flags.append(b.allocator, "-DTRACY_ONLY_LOCALHOST");
    }
    if (no_broadcast) {
        try flags.append(b.allocator, "-DTRACY_NO_BROADCAST");
    }
    if (only_ipv4) {
        try flags.append(b.allocator, "-DTRACY_ONLY_IPV4");
    }
    if (no_code_transfer) {
        try flags.append(b.allocator, "-DTRACY_NO_CODE_TRANSFER");
    }
    if (no_context_switch) {
        try flags.append(b.allocator, "-DTRACY_NO_CONTEXT_SWITCH");
    }
    if (no_exit) {
        try flags.append(b.allocator, "-DTRACY_NO_EXIT");
    }
    if (no_sampling) {
        try flags.append(b.allocator, "-DTRACY_NO_SAMPLING");
    }
    if (no_verify) {
        try flags.append(b.allocator, "-DTRACY_NO_VERIFY");
    }
    if (no_vsync_capture) {
        try flags.append(b.allocator, "-DTRACY_NO_VSYNC_CAPTURE");
    }
    if (no_frame_image) {
        try flags.append(b.allocator, "-DTRACY_NO_FRAME_IMAGE");
    }
    if (no_system_tracing) {
        try flags.append(b.allocator, "-DTRACY_NO_SYSTEM_TRACING");
    }
    if (patchable_nopsleds) {
        try flags.append(b.allocator, "-DTRACY_PATCHABLE_NOPSLEDS");
    }
    if (delayed_init) {
        try flags.append(b.allocator, "-DTRACY_DELAYED_INIT");
    }
    if (manual_lifetime) {
        try flags.append(b.allocator, "-DTRACY_MANUAL_LIFETIME");
    }
    if (fibers) {
        try flags.append(b.allocator, "-DTRACY_FIBERS");
    }
    if (timer_fallback) {
        try flags.append(b.allocator, "-DTRACY_TIMER_FALLBACK");
    }
    if (no_crash_handler) {
        try flags.append(b.allocator, "-DTRACY_NO_CRASH_HANDLER");
    }
    if (libunwind_backtrace) {
        try flags.append(b.allocator, "-DTRACY_LIBUNWIND_BACKTRACE");
        lib.root_module.linkSystemLibrary("libunwind", .{});
    }
    if (symbol_offline_resolve) {
        try flags.append(b.allocator, "-DTRACY_SYMBOL_OFFLINE_RESOLVE");
    }
    if (libbacktrace_elf_dynload_support) {
        try flags.append(b.allocator, "-DTRACY_LIBBACKTRACE_ELF_DYNLOAD_SUPPORT");
    }
    if (verbose) {
        try flags.append(b.allocator, "-DTRACY_VERBOSE");
    }
    if (debuginfod) {
        try flags.append(b.allocator, "-DTRACY_DEBUGINFOD");
        lib.root_module.linkSystemLibrary("libdebuginfod", .{});
    }

    switch (target.result.os.tag) {
        .windows => {
            lib.root_module.linkSystemLibrary("ws2_32", .{});
            lib.root_module.linkSystemLibrary("advapi32", .{});
            lib.root_module.linkSystemLibrary("user32", .{});
            lib.root_module.linkSystemLibrary("dbghelp", .{});
            try flags.append(b.allocator, "-DWINVER=0x0601");
            try flags.append(b.allocator, "-DWIN32_WINNT=0x0601");
        },
        else => {},
    }

    mod.addIncludePath(b.path("public"));
    mod.addCSourceFile(.{
        .flags = flags.items,
        .file = b.path("public/TracyClient.cpp"),
    });

    lib.installHeadersDirectory(b.path("public/tracy"), "tracy/tracy", .{});
    lib.installHeadersDirectory(b.path("public/common"), "tracy/common", .{});
    b.installArtifact(lib);
}
