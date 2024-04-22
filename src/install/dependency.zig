const bun = @import("root").bun;
const logger = bun.logger;
const Environment = @import("../env.zig");
const Install = @import("./install.zig");
const PackageManager = Install.PackageManager;
const ExternalStringList = Install.ExternalStringList;
const Features = Install.Features;
const PackageNameHash = Install.PackageNameHash;
const Repository = @import("./repository.zig").Repository;
const Semver = @import("./semver.zig");
const ExternalString = Semver.ExternalString;
const SlicedString = Semver.SlicedString;
const String = Semver.String;
const std = @import("std");
const string = @import("../string_types.zig").string;
const strings = @import("../string_immutable.zig");
const Dependency = @This();

const URI = union(Tag) {
    local: String,
    remote: String,

    pub fn eql(lhs: URI, rhs: URI, lhs_buf: []const u8, rhs_buf: []const u8) bool {
        if (@as(Tag, lhs) != @as(Tag, rhs)) {
            return false;
        }

        if (@as(Tag, lhs) == .local) {
            return strings.eqlLong(lhs.local.slice(lhs_buf), rhs.local.slice(rhs_buf), true);
        } else {
            return strings.eqlLong(lhs.remote.slice(lhs_buf), rhs.remote.slice(rhs_buf), true);
        }
    }

    pub const Tag = enum {
        local,
        remote,
    };
};

name_hash: PackageNameHash = 0,
name: String = .{},
version: Dependency.Version = .{},

/// This is how the dependency is specified in the package.json file.
/// This allows us to track whether a package originated in any permutation of:
/// - `dependencies`
/// - `devDependencies`
/// - `optionalDependencies`
/// - `peerDependencies`
/// Technically, having the same package name specified under multiple fields is invalid
/// But we don't want to allocate extra arrays for them. So we use a bitfield instead.
behavior: Behavior = Behavior.uninitialized,

/// Sorting order for dependencies is:
/// 1. [ `peerDependencies`, `optionalDependencies`, `devDependencies`, `dependencies` ]
/// 2. name ASC
/// "name" must be ASC so that later, when we rebuild the lockfile
/// we insert it back in reverse order without an extra sorting pass
pub fn isLessThan(string_buf: []const u8, lhs: Dependency, rhs: Dependency) bool {
    const behavior = lhs.behavior.cmp(rhs.behavior);
    if (behavior != .eq) {
        return behavior == .lt;
    }

    const lhs_name = lhs.name.slice(string_buf);
    const rhs_name = rhs.name.slice(string_buf);
    return strings.cmpStringsAsc({}, lhs_name, rhs_name);
}

pub fn countWithDifferentBuffers(this: *const Dependency, name_buf: []const u8, version_buf: []const u8, comptime StringBuilder: type, builder: StringBuilder) void {
    builder.count(this.name.slice(name_buf));
    builder.count(this.version.literal.slice(version_buf));
}

pub fn count(this: *const Dependency, buf: []const u8, comptime StringBuilder: type, builder: StringBuilder) void {
    this.countWithDifferentBuffers(buf, buf, StringBuilder, builder);
}

pub fn clone(this: *const Dependency, buf: []const u8, comptime StringBuilder: type, builder: StringBuilder) !Dependency {
    return this.cloneWithDifferentBuffers(buf, buf, StringBuilder, builder);
}

pub fn cloneWithDifferentBuffers(this: *const Dependency, name_buf: []const u8, version_buf: []const u8, comptime StringBuilder: type, builder: StringBuilder) !Dependency {
    const out_slice = builder.lockfile.buffers.string_bytes.items;
    const new_literal = builder.append(String, this.version.literal.slice(version_buf));
    const sliced = new_literal.sliced(out_slice);
    const new_name = builder.append(String, this.name.slice(name_buf));

    return Dependency{
        .name_hash = this.name_hash,
        .name = new_name,
        .version = Dependency.parseWithTag(
            builder.lockfile.allocator,
            new_name,
            String.Builder.stringHash(new_name.slice(out_slice)),
            new_literal.slice(out_slice),
            this.version.tag,
            &sliced,
            null,
        ) orelse Dependency.Version{},
        .behavior = this.behavior,
    };
}

pub const External = [size]u8;

const size = @sizeOf(Dependency.Version.External) +
    @sizeOf(PackageNameHash) +
    @sizeOf(Dependency.Behavior) +
    @sizeOf(String);

pub const Context = struct {
    allocator: std.mem.Allocator,
    log: *logger.Log,
    buffer: []const u8,
};

/// Get the name of the package as it should appear in a remote registry.
pub inline fn realname(this: *const Dependency) String {
    return switch (this.version.tag) {
        .dist_tag => this.version.value.dist_tag.name,
        .git => this.version.value.git.package_name,
        .github => this.version.value.github.package_name,
        .npm => this.version.value.npm.name,
        .tarball => this.version.value.tarball.package_name,
        else => this.name,
    };
}

pub inline fn isAliased(this: *const Dependency, buf: []const u8) bool {
    return switch (this.version.tag) {
        .npm => !this.version.value.npm.name.eql(this.name, buf, buf),
        .dist_tag => !this.version.value.dist_tag.name.eql(this.name, buf, buf),
        .git => !this.version.value.git.package_name.eql(this.name, buf, buf),
        .github => !this.version.value.github.package_name.eql(this.name, buf, buf),
        .tarball => !this.version.value.tarball.package_name.eql(this.name, buf, buf),
        else => false,
    };
}

pub fn toDependency(
    this: External,
    ctx: Context,
) Dependency {
    const name = String{
        .bytes = this[0..8].*,
    };
    const name_hash: u64 = @bitCast(this[8..16].*);
    return Dependency{
        .name = name,
        .name_hash = name_hash,
        .behavior = @bitCast(this[16]),
        .version = Dependency.Version.toVersion(name, name_hash, this[17..this.len].*, ctx),
    };
}

pub fn toExternal(this: Dependency) External {
    var bytes: External = undefined;
    bytes[0..this.name.bytes.len].* = this.name.bytes;
    bytes[8..16].* = @as([8]u8, @bitCast(this.name_hash));
    bytes[16] = @bitCast(this.behavior);
    bytes[17..bytes.len].* = this.version.toExternal();
    return bytes;
}

pub inline fn isSCPLikePath(dependency: string) bool {
    // Shortest valid expression: h:p
    if (dependency.len < 3) return false;

    var at_index: ?usize = null;

    for (dependency, 0..) |c, i| {
        switch (c) {
            '@' => {
                if (at_index == null) at_index = i;
            },
            ':' => {
                if (strings.hasPrefixComptime(dependency[i..], "://")) return false;
                return i > if (at_index) |index| index + 1 else 0;
            },
            '/' => return if (at_index) |index| i > index + 1 else false,
            else => {},
        }
    }

    return false;
}

pub inline fn isGitHubRepoPath(dependency: string) bool {
    // Shortest valid expression: u/r
    if (dependency.len < 3) return false;

    var hash_index: usize = 0;

    // the branch could have slashes
    // - oven-sh/bun#brach/name
    var first_slash_index: usize = 0;

    for (dependency, 0..) |c, i| {
        switch (c) {
            '/' => {
                if (i == 0) return false;
                if (first_slash_index == 0) {
                    first_slash_index = i;
                }
            },
            '#' => {
                if (i == 0) return false;
                if (hash_index > 0) return false;
                if (first_slash_index == 0) return false;
                hash_index = i;
            },
            // Not allowed in username
            '.', '_' => {
                if (first_slash_index == 0) return false;
            },
            // Must be alphanumeric
            '-', 'a'...'z', 'A'...'Z', '0'...'9' => {},
            else => return false,
        }
    }

    return hash_index != dependency.len - 1 and first_slash_index > 0 and first_slash_index != dependency.len - 1;
}

/// Github allows for the following format of URL:
/// https://github.com/<org>/<repo>/tarball/<ref>
/// This is a legacy (but still supported) method of retrieving a tarball of an
/// entire source tree at some git reference. (ref = branch, tag, etc. Note: branch
/// can have arbitrary number of slashes)
///
/// This also checks for a github url that ends with ".tar.gz"
pub inline fn isGitHubTarballPath(dependency: string) bool {
    if (isTarball(dependency)) return true;

    var parts = strings.split(dependency, "/");

    var n_parts: usize = 0;

    while (parts.next()) |part| {
        n_parts += 1;
        if (n_parts == 3) {
            return strings.eqlComptime(part, "tarball");
        }
    }

    return false;
}

// This won't work for query string params, but I'll let someone file an issue
// before I add that.
pub inline fn isTarball(dependency: string) bool {
    return strings.endsWithComptime(dependency, ".tgz") or strings.endsWithComptime(dependency, ".tar.gz");
}

/// the input is assumed to be either a remote or local tarball
pub inline fn isRemoteTarball(dependency: string) bool {
    return strings.hasPrefixComptime(dependency, "https://") or strings.hasPrefixComptime(dependency, "http://");
}

pub const Version = struct {
    tag: Tag = .uninitialized,
    literal: String = .{},
    value: Value = .{ .uninitialized = {} },

    pub fn deinit(this: *Version) void {
        switch (this.tag) {
            .npm => {
                this.value.npm.version.deinit();
            },
            else => {},
        }
    }

    pub const zeroed = Version{};

    pub fn clone(
        this: *const Version,
        buf: []const u8,
        comptime StringBuilder: type,
        builder: StringBuilder,
    ) !Version {
        return Version{
            .tag = this.tag,
            .literal = builder.append(String, this.literal.slice(buf)),
            .value = try this.value.clone(buf, builder),
        };
    }

    pub fn isLessThan(string_buf: []const u8, lhs: Dependency.Version, rhs: Dependency.Version) bool {
        if (comptime Environment.allow_assert) bun.assert(lhs.tag == rhs.tag);
        return strings.cmpStringsAsc({}, lhs.literal.slice(string_buf), rhs.literal.slice(string_buf));
    }

    pub fn isLessThanWithTag(string_buf: []const u8, lhs: Dependency.Version, rhs: Dependency.Version) bool {
        const tag_order = lhs.tag.cmp(rhs.tag);
        if (tag_order != .eq)
            return tag_order == .lt;

        return strings.cmpStringsAsc({}, lhs.literal.slice(string_buf), rhs.literal.slice(string_buf));
    }

    pub const External = [9]u8;

    pub fn toVersion(
        alias: String,
        alias_hash: PackageNameHash,
        bytes: Version.External,
        ctx: Dependency.Context,
    ) Dependency.Version {
        const slice = String{ .bytes = bytes[1..9].* };
        const tag = @as(Dependency.Version.Tag, @enumFromInt(bytes[0]));
        const sliced = &slice.sliced(ctx.buffer);
        return Dependency.parseWithTag(
            ctx.allocator,
            alias,
            alias_hash,
            sliced.slice,
            tag,
            sliced,
            ctx.log,
        ) orelse Dependency.Version.zeroed;
    }

    pub inline fn toExternal(this: Version) Version.External {
        var bytes: Version.External = undefined;
        bytes[0] = @intFromEnum(this.tag);
        bytes[1..9].* = this.literal.bytes;
        return bytes;
    }

    pub inline fn eql(
        lhs: *const Version,
        rhs: *const Version,
        lhs_buf: []const u8,
        rhs_buf: []const u8,
    ) bool {
        if (lhs.tag != rhs.tag) {
            return false;
        }

        return switch (lhs.tag) {
            // if the two versions are identical as strings, it should often be faster to compare that than the actual semver version
            // semver ranges involve a ton of pointer chasing
            .npm => strings.eqlLong(lhs.literal.slice(lhs_buf), rhs.literal.slice(rhs_buf), true) or
                lhs.value.npm.eql(rhs.value.npm, lhs_buf, rhs_buf),
            .folder, .dist_tag => lhs.literal.eql(rhs.literal, lhs_buf, rhs_buf),
            .git => lhs.value.git.eql(&rhs.value.git, lhs_buf, rhs_buf),
            .github => lhs.value.github.eql(&rhs.value.github, lhs_buf, rhs_buf),
            .tarball => lhs.value.tarball.eql(rhs.value.tarball, lhs_buf, rhs_buf),
            .symlink => lhs.value.symlink.eql(rhs.value.symlink, lhs_buf, rhs_buf),
            .workspace => lhs.value.workspace.eql(rhs.value.workspace, lhs_buf, rhs_buf),
            else => true,
        };
    }

    pub const Tag = enum(u8) {
        uninitialized = 0,

        /// Semver range
        npm = 1,

        /// NPM dist tag, e.g. "latest"
        dist_tag = 2,

        /// URI to a .tgz or .tar.gz
        tarball = 3,

        /// Local folder
        folder = 4,

        /// link:path
        /// https://docs.npmjs.com/cli/v8/commands/npm-link#synopsis
        /// https://stackoverflow.com/questions/51954956/whats-the-difference-between-yarn-link-and-npm-link
        symlink = 5,

        /// Local path specified under `workspaces`
        workspace = 6,

        /// Git Repository (via `git` CLI)
        git = 7,

        /// GitHub Repository (via REST API)
        github = 8,

        pub fn cmp(this: Tag, other: Tag) std.math.Order {
            // TODO: align with yarn
            return std.math.order(@intFromEnum(this), @intFromEnum(other));
        }

        pub inline fn isNPM(this: Tag) bool {
            return @intFromEnum(this) < 3;
        }

        pub fn infer(dependency: string) Tag {
            // empty string means `latest`
            if (dependency.len == 0) return .dist_tag;

            if (strings.startsWithWindowsDriveLetter(dependency) and dependency[2] == '\\' or dependency[2] == '/') {
                return .folder;
            }

            switch (dependency[0]) {
                // =1
                // >1.2
                // >=1.2.3
                // <1
                // <=1.2
                // ^1.2.3
                // *
                // || 1.x
                '=', '>', '<', '^', '*', '|' => return .npm,
                // ./foo.tgz
                // ./path/to/foo
                // ../path/to/bar
                '.' => {
                    if (isTarball(dependency)) return .tarball;
                    return .folder;
                },
                // ~1.2.3
                // ~/foo.tgz
                // ~/path/to/foo
                '~' => {
                    // https://docs.npmjs.com/cli/v8/configuring-npm/package-json#local-paths
                    if (dependency.len > 1 and dependency[1] == '/') {
                        if (isTarball(dependency)) return .tarball;
                        return .folder;
                    }
                    return .npm;
                },
                // /path/to/foo
                // /path/to/foo.tgz
                '/' => {
                    if (isTarball(dependency)) return .tarball;
                    return .folder;
                },
                // 1.2.3
                // 123.tar.gz
                '0'...'9' => {
                    if (isTarball(dependency)) return .tarball;
                    return .npm;
                },
                // foo.tgz
                // foo/repo
                // file:path/to/foo
                // file:path/to/foo.tar.gz
                'f' => {
                    if (strings.hasPrefixComptime(dependency, "file:")) {
                        if (isTarball(dependency)) return .tarball;
                        return .folder;
                    }
                },
                // git_user/repo
                // git_tarball.tgz
                // github:user/repo
                // git@example.com/repo.git
                // git://user@example.com/repo.git
                'g' => {
                    if (strings.hasPrefixComptime(dependency, "git")) {
                        var url = dependency["git".len..];
                        if (url.len > 2) {
                            switch (url[0]) {
                                ':' => {
                                    if (strings.hasPrefixComptime(url, "://")) {
                                        url = url["://".len..];
                                        if (strings.hasPrefixComptime(url, "github.com/")) {
                                            if (isGitHubRepoPath(url["github.com/".len..])) return .github;
                                        }
                                        return .git;
                                    }
                                },
                                '+' => {
                                    if (strings.hasPrefixComptime(url, "+ssh:") or
                                        strings.hasPrefixComptime(url, "+file:"))
                                    {
                                        return .git;
                                    }
                                    if (strings.hasPrefixComptime(url, "+http")) {
                                        url = url["+http".len..];
                                        if (url.len > 2 and switch (url[0]) {
                                            ':' => brk: {
                                                if (strings.hasPrefixComptime(url, "://")) {
                                                    url = url["://".len..];
                                                    break :brk true;
                                                }
                                                break :brk false;
                                            },
                                            's' => brk: {
                                                if (strings.hasPrefixComptime(url, "s://")) {
                                                    url = url["s://".len..];
                                                    break :brk true;
                                                }
                                                break :brk false;
                                            },
                                            else => false,
                                        }) {
                                            if (strings.hasPrefixComptime(url, "github.com/")) {
                                                if (isGitHubRepoPath(url["github.com/".len..])) return .github;
                                            }
                                            return .git;
                                        }
                                    }
                                },
                                'h' => {
                                    if (strings.hasPrefixComptime(url, "hub:")) {
                                        if (isGitHubRepoPath(url["hub:".len..])) return .github;
                                    }
                                },
                                else => {},
                            }
                        }
                    }
                },
                // hello/world
                // hello.tar.gz
                // https://github.com/user/repo
                'h' => {
                    if (strings.hasPrefixComptime(dependency, "http")) {
                        var url = dependency["http".len..];
                        if (url.len > 2) {
                            switch (url[0]) {
                                ':' => {
                                    if (strings.hasPrefixComptime(url, "://")) {
                                        url = url["://".len..];
                                    }
                                },
                                's' => {
                                    if (strings.hasPrefixComptime(url, "s://")) {
                                        url = url["s://".len..];
                                    }
                                },
                                else => {},
                            }

                            if (strings.hasPrefixComptime(url, "github.com/")) {
                                const path = url["github.com/".len..];
                                if (isGitHubTarballPath(path)) return .tarball;
                                if (isGitHubRepoPath(path)) return .github;
                            }

                            if (strings.indexOfChar(url, '.')) |dot| {
                                if (Repository.Hosts.has(url[0..dot])) return .git;
                            }

                            return .tarball;
                        }
                    }
                },
                's' => {
                    if (strings.hasPrefixComptime(dependency, "ssh")) {
                        var url = dependency["ssh".len..];
                        if (url.len > 2) {
                            if (url[0] == ':') {
                                if (strings.hasPrefixComptime(url, "://")) {
                                    url = url["://".len..];
                                }
                            }

                            if (strings.indexOfChar(url, '.')) |dot| {
                                if (Repository.Hosts.has(url[0..dot])) return .git;
                            }
                        }
                    }
                },
                // lisp.tgz
                // lisp/repo
                // link:path/to/foo
                'l' => {
                    if (strings.hasPrefixComptime(dependency, "link:")) return .symlink;
                },
                // newspeak.tgz
                // newspeak/repo
                // npm:package@1.2.3
                'n' => {
                    if (strings.hasPrefixComptime(dependency, "npm:") and dependency.len > "npm:".len) {
                        const remain = dependency["npm:".len + @intFromBool(dependency["npm:".len] == '@') ..];
                        for (remain, 0..) |c, i| {
                            if (c == '@') {
                                return infer(remain[i + 1 ..]);
                            }
                        }

                        return .npm;
                    }
                },
                // v1.2.3
                // verilog
                // verilog.tar.gz
                // verilog/repo
                // virt@example.com:repo.git
                'v' => {
                    if (isTarball(dependency)) return .tarball;
                    if (isGitHubRepoPath(dependency)) return .github;
                    if (isSCPLikePath(dependency)) return .git;
                    if (dependency.len == 1) return .dist_tag;
                    return switch (dependency[1]) {
                        '0'...'9' => .npm,
                        else => .dist_tag,
                    };
                },
                // workspace:*
                // w00t
                // w00t.tar.gz
                // w00t/repo
                'w' => {
                    if (strings.hasPrefixComptime(dependency, "workspace:")) return .workspace;
                },
                // x
                // xyz.tar.gz
                // xyz/repo#main
                'x', 'X' => {
                    if (dependency.len == 1) return .npm;
                    if (dependency[1] == '.') return .npm;
                },
                'p' => {
                    // TODO(dylan-conway): apply .patch files on packages. In the future this could
                    // return `Tag.git` or `Tag.npm`.
                    if (strings.hasPrefixComptime(dependency, "patch:")) return .npm;
                },
                else => {},
            }

            // foo.tgz
            // bar.tar.gz
            if (isTarball(dependency)) return .tarball;
            // user/repo
            // user/repo#main
            if (isGitHubRepoPath(dependency)) return .github;
            // git@example.com:path/to/repo.git
            if (isSCPLikePath(dependency)) return .git;
            // beta

            if (!strings.containsChar(dependency, '|')) {
                return .dist_tag;
            }

            return .npm;
        }
    };

    pub const NpmInfo = struct {
        name: String,
        version: Semver.Query.Group,
        is_alias: bool = false,

        fn eql(this: NpmInfo, that: NpmInfo, this_buf: []const u8, that_buf: []const u8) bool {
            return this.name.eql(that.name, this_buf, that_buf) and this.version.eql(that.version);
        }
    };

    pub const TagInfo = struct {
        name: String,
        tag: String,

        fn eql(this: TagInfo, that: TagInfo, this_buf: []const u8, that_buf: []const u8) bool {
            return this.name.eql(that.name, this_buf, that_buf) and this.tag.eql(that.tag, this_buf, that_buf);
        }
    };

    pub const TarballInfo = struct {
        uri: URI,
        package_name: String = .{},

        fn eql(this: TarballInfo, that: TarballInfo, this_buf: []const u8, that_buf: []const u8) bool {
            return this.uri.eql(that.uri, this_buf, that_buf);
        }
    };

    pub const Value = union {
        uninitialized: void,

        npm: NpmInfo,
        dist_tag: TagInfo,
        tarball: TarballInfo,
        folder: String,

        /// Equivalent to npm link
        symlink: String,

        workspace: String,
        git: Repository,
        github: Repository,
    };
};

pub fn eql(
    a: *const Dependency,
    b: *const Dependency,
    lhs_buf: []const u8,
    rhs_buf: []const u8,
) bool {
    return a.name_hash == b.name_hash and a.name.len() == b.name.len() and a.version.eql(&b.version, lhs_buf, rhs_buf);
}

pub fn isWindowsAbsPathWithLeadingSlashes(dep: string) ?string {
    var i: usize = 0;
    if (dep.len > 2 and dep[i] == '/') {
        while (dep[i] == '/') {
            i += 1;

            // not possible to have windows drive letter and colon
            if (i > dep.len - 3) return null;
        }
        if (strings.startsWithWindowsDriveLetter(dep[i..])) {
            return dep[i..];
        }
    }

    return null;
}

pub inline fn parse(
    allocator: std.mem.Allocator,
    alias: String,
    alias_hash: ?PackageNameHash,
    dependency: string,
    sliced: *const SlicedString,
    log: ?*logger.Log,
) ?Version {
    const dep = std.mem.trimLeft(u8, dependency, " \t\n\r");
    return parseWithTag(allocator, alias, alias_hash, dep, Version.Tag.infer(dep), sliced, log);
}

pub fn parseWithOptionalTag(
    allocator: std.mem.Allocator,
    alias: String,
    alias_hash: ?PackageNameHash,
    dependency: string,
    tag: ?Dependency.Version.Tag,
    sliced: *const SlicedString,
    log: ?*logger.Log,
) ?Version {
    const dep = std.mem.trimLeft(u8, dependency, " \t\n\r");
    return parseWithTag(
        allocator,
        alias,
        alias_hash,
        dep,
        tag orelse Version.Tag.infer(dep),
        sliced,
        log,
    );
}

pub fn parseWithTag(
    allocator: std.mem.Allocator,
    alias: String,
    alias_hash: ?PackageNameHash,
    dependency: string,
    tag: Dependency.Version.Tag,
    sliced: *const SlicedString,
    log_: ?*logger.Log,
) ?Version {
    switch (tag) {
        .npm => {
            var input = dependency;

            var is_alias = false;
            const name = brk: {
                if (strings.hasPrefixComptime(input, "npm:")) {
                    is_alias = true;
                    var str = input["npm:".len..];
                    var i: usize = @intFromBool(str.len > 0 and str[0] == '@');

                    while (i < str.len) : (i += 1) {
                        if (str[i] == '@') {
                            input = str[i + 1 ..];
                            break :brk sliced.sub(str[0..i]).value();
                        }
                    }

                    input = str[i..];

                    break :brk sliced.sub(str[0..i]).value();
                }

                break :brk alias;
            };

            is_alias = is_alias and alias_hash != null;

            // Strip single leading v
            // v1.0.0 -> 1.0.0
            // note: "vx" is valid, it becomes "x". "yarn add react@vx" -> "yarn add react@x" -> "yarn add react@17.0.2"
            if (input.len > 1 and input[0] == 'v') {
                input = input[1..];
            }

            const version = Semver.Query.parse(
                allocator,
                input,
                sliced.sub(input),
            ) catch |err| {
                if (log_) |log| log.addErrorFmt(
                    null,
                    logger.Loc.Empty,
                    allocator,
                    "{s} parsing version \"{s}\"",
                    .{
                        @errorName(err),
                        dependency,
                    },
                ) catch unreachable;
                return null;
            };

            const result = Version{
                .literal = sliced.value(),
                .value = .{
                    .npm = .{
                        .is_alias = is_alias,
                        .name = name,
                        .version = version,
                    },
                },
                .tag = .npm,
            };

            if (is_alias) {
                PackageManager.instance.known_npm_aliases.put(
                    allocator,
                    alias_hash.?,
                    result,
                ) catch unreachable;
            }

            return result;
        },
        .dist_tag => {
            var tag_to_use = sliced.value();

            const actual = if (strings.hasPrefixComptime(dependency, "npm:") and dependency.len > "npm:".len)
                // npm:@foo/bar@latest
                sliced.sub(brk: {
                    var i = "npm:".len;

                    // npm:@foo/bar@latest
                    //     ^
                    i += @intFromBool(dependency[i] == '@');

                    while (i < dependency.len) : (i += 1) {
                        // npm:@foo/bar@latest
                        //             ^
                        if (dependency[i] == '@') {
                            break;
                        }
                    }

                    tag_to_use = sliced.sub(dependency[i + 1 ..]).value();
                    break :brk dependency["npm:".len..i];
                }).value()
            else
                alias;

            // name should never be empty
            if (comptime Environment.allow_assert) bun.assert(!actual.isEmpty());

            return .{
                .literal = sliced.value(),
                .value = .{
                    .dist_tag = .{
                        .name = actual,
                        .tag = if (tag_to_use.isEmpty()) String.from("latest") else tag_to_use,
                    },
                },
                .tag = .dist_tag,
            };
        },
        .git => {
            var input = dependency;
            if (strings.hasPrefixComptime(input, "git+")) {
                input = input["git+".len..];
            }
            const hash_index = strings.lastIndexOfChar(input, '#');

            return .{
                .literal = sliced.value(),
                .value = .{
                    .git = .{
                        .owner = String.from(""),
                        .repo = sliced.sub(if (hash_index) |index| input[0..index] else input).value(),
                        .committish = if (hash_index) |index| sliced.sub(input[index + 1 ..]).value() else String.from(""),
                    },
                },
                .tag = .git,
            };
        },
        .github => {
            var from_url = false;
            var input = dependency;
            if (strings.hasPrefixComptime(input, "github:")) {
                input = input["github:".len..];
            } else if (strings.hasPrefixComptime(input, "git://github.com/")) {
                input = input["git://github.com/".len..];
                from_url = true;
            } else {
                if (strings.hasPrefixComptime(input, "git+")) {
                    input = input["git+".len..];
                }
                if (strings.hasPrefixComptime(input, "http")) {
                    var url = input["http".len..];
                    if (url.len > 2) {
                        switch (url[0]) {
                            ':' => {
                                if (strings.hasPrefixComptime(url, "://")) {
                                    url = url["://".len..];
                                }
                            },
                            's' => {
                                if (strings.hasPrefixComptime(url, "s://")) {
                                    url = url["s://".len..];
                                }
                            },
                            else => {},
                        }
                        if (strings.hasPrefixComptime(url, "github.com/")) {
                            input = url["github.com/".len..];
                            from_url = true;
                        }
                    }
                }
            }

            if (comptime Environment.allow_assert) bun.assert(isGitHubRepoPath(input));

            var hash_index: usize = 0;
            var slash_index: usize = 0;
            for (input, 0..) |c, i| {
                switch (c) {
                    '/' => {
                        slash_index = i;
                    },
                    '#' => {
                        hash_index = i;
                        break;
                    },
                    else => {},
                }
            }

            var repo = if (hash_index == 0) input[slash_index + 1 ..] else input[slash_index + 1 .. hash_index];
            if (from_url and strings.endsWithComptime(repo, ".git")) {
                repo = repo[0 .. repo.len - ".git".len];
            }

            return .{
                .literal = sliced.value(),
                .value = .{
                    .github = .{
                        .owner = sliced.sub(input[0..slash_index]).value(),
                        .repo = sliced.sub(repo).value(),
                        .committish = if (hash_index == 0) String.from("") else sliced.sub(input[hash_index + 1 ..]).value(),
                    },
                },
                .tag = .github,
            };
        },
        .tarball => {
            if (isRemoteTarball(dependency)) {
                return .{
                    .tag = .tarball,
                    .literal = sliced.value(),
                    .value = .{ .tarball = .{ .uri = .{ .remote = sliced.sub(dependency).value() } } },
                };
            } else if (strings.hasPrefixComptime(dependency, "file://")) {
                return .{
                    .tag = .tarball,
                    .literal = sliced.value(),
                    .value = .{ .tarball = .{ .uri = .{ .local = sliced.sub(dependency[7..]).value() } } },
                };
            } else if (strings.hasPrefixComptime(dependency, "file:")) {
                return .{
                    .tag = .tarball,
                    .literal = sliced.value(),
                    .value = .{ .tarball = .{ .uri = .{ .local = sliced.sub(dependency[5..]).value() } } },
                };
            } else if (strings.contains(dependency, "://")) {
                if (log_) |log| log.addErrorFmt(null, logger.Loc.Empty, allocator, "invalid or unsupported dependency \"{s}\"", .{dependency}) catch unreachable;
                return null;
            }

            return .{
                .tag = .tarball,
                .literal = sliced.value(),
                .value = .{ .tarball = .{ .uri = .{ .local = sliced.value() } } },
            };
        },
        .folder => {
            if (strings.indexOfChar(dependency, ':')) |protocol| {
                if (strings.eqlComptime(dependency[0..protocol], "file")) {
                    const folder = folder: {

                        // from npm:
                        //
                        // turn file://../foo into file:../foo
                        // https://github.com/npm/cli/blob/fc6e291e9c2154c2e76636cb7ebf0a17be307585/node_modules/npm-package-arg/lib/npa.js#L269
                        //
                        // something like this won't behave the same
                        // file://bar/../../foo
                        const maybe_dot_dot = maybe_dot_dot: {
                            if (dependency.len > protocol + 1 and dependency[protocol + 1] == '/') {
                                if (dependency.len > protocol + 2 and dependency[protocol + 2] == '/') {
                                    if (dependency.len > protocol + 3 and dependency[protocol + 3] == '/') {
                                        break :maybe_dot_dot dependency[protocol + 4 ..];
                                    }
                                    break :maybe_dot_dot dependency[protocol + 3 ..];
                                }
                                break :maybe_dot_dot dependency[protocol + 2 ..];
                            }
                            break :folder dependency[protocol + 1 ..];
                        };

                        if (maybe_dot_dot.len > 1 and maybe_dot_dot[0] == '.' and maybe_dot_dot[1] == '.') {
                            return .{
                                .literal = sliced.value(),
                                .value = .{ .folder = sliced.sub(maybe_dot_dot).value() },
                                .tag = .folder,
                            };
                        }

                        break :folder dependency[protocol + 1 ..];
                    };

                    // from npm:
                    //
                    // turn /C:/blah info just C:/blah on windows
                    // https://github.com/npm/cli/blob/fc6e291e9c2154c2e76636cb7ebf0a17be307585/node_modules/npm-package-arg/lib/npa.js#L277
                    if (comptime Environment.isWindows) {
                        if (isWindowsAbsPathWithLeadingSlashes(folder)) |dep| {
                            return .{
                                .literal = sliced.value(),
                                .value = .{ .folder = sliced.sub(dep).value() },
                                .tag = .folder,
                            };
                        }
                    }

                    return .{
                        .literal = sliced.value(),
                        .value = .{ .folder = sliced.sub(folder).value() },
                        .tag = .folder,
                    };
                }

                // check for absolute windows paths
                if (comptime Environment.isWindows) {
                    if (protocol == 1 and strings.startsWithWindowsDriveLetter(dependency)) {
                        return .{
                            .literal = sliced.value(),
                            .value = .{ .folder = sliced.sub(dependency).value() },
                            .tag = .folder,
                        };
                    }

                    // from npm:
                    //
                    // turn /C:/blah info just C:/blah on windows
                    // https://github.com/npm/cli/blob/fc6e291e9c2154c2e76636cb7ebf0a17be307585/node_modules/npm-package-arg/lib/npa.js#L277
                    if (isWindowsAbsPathWithLeadingSlashes(dependency)) |dep| {
                        return .{
                            .literal = sliced.value(),
                            .value = .{ .folder = sliced.sub(dep).value() },
                            .tag = .folder,
                        };
                    }
                }

                if (log_) |log| log.addErrorFmt(null, logger.Loc.Empty, allocator, "Unsupported protocol {s}", .{dependency}) catch unreachable;
                return null;
            }

            return .{
                .value = .{ .folder = sliced.value() },
                .tag = .folder,
                .literal = sliced.value(),
            };
        },
        .uninitialized => return null,
        .symlink => {
            if (strings.indexOfChar(dependency, ':')) |colon| {
                return .{
                    .value = .{ .symlink = sliced.sub(dependency[colon + 1 ..]).value() },
                    .tag = .symlink,
                    .literal = sliced.value(),
                };
            }

            return .{
                .value = .{ .symlink = sliced.value() },
                .tag = .symlink,
                .literal = sliced.value(),
            };
        },
        .workspace => {
            var input = dependency;
            if (strings.hasPrefixComptime(input, "workspace:")) {
                input = input["workspace:".len..];
            }
            return .{
                .value = .{ .workspace = sliced.sub(input).value() },
                .tag = .workspace,
                .literal = sliced.value(),
            };
        },
    }
}

pub const Behavior = packed struct(u8) {
    pub const uninitialized: Behavior = .{};

    // these padding fields are to have compatibility
    // with older versions of lockfile v2
    _unused_1: u1 = 0,

    normal: bool = false,
    optional: bool = false,
    dev: bool = false,
    peer: bool = false,
    workspace: bool = false,

    _unused_2: u2 = 0,

    pub const normal = Behavior{ .normal = true };
    pub const optional = Behavior{ .optional = true };
    pub const dev = Behavior{ .dev = true };
    pub const peer = Behavior{ .peer = true };
    pub const workspace = Behavior{ .workspace = true };

    pub inline fn isNormal(this: Behavior) bool {
        return this.normal;
    }

    pub inline fn isOptional(this: Behavior) bool {
        return this.optional and !this.isPeer();
    }

    pub inline fn isOptionalPeer(this: Behavior) bool {
        return this.optional and this.isPeer();
    }

    pub inline fn isDev(this: Behavior) bool {
        return this.dev;
    }

    pub inline fn isPeer(this: Behavior) bool {
        return this.peer;
    }

    pub inline fn isWorkspace(this: Behavior) bool {
        return this.workspace;
    }

    pub inline fn setNormal(this: Behavior, value: bool) Behavior {
        var b = this;
        b.normal = value;
        return b;
    }

    pub inline fn setOptional(this: Behavior, value: bool) Behavior {
        var b = this;
        b.optional = value;
        return b;
    }

    pub inline fn setDev(this: Behavior, value: bool) Behavior {
        var b = this;
        b.dev = value;
        return b;
    }

    pub inline fn setPeer(this: Behavior, value: bool) Behavior {
        var b = this;
        b.peer = value;
        return b;
    }

    pub inline fn setWorkspace(this: Behavior, value: bool) Behavior {
        var b = this;
        b.workspace = value;
        return b;
    }

    pub inline fn eq(lhs: Behavior, rhs: Behavior) bool {
        return @as(u8, @bitCast(lhs)) == @as(u8, @bitCast(rhs));
    }

    pub inline fn cmp(lhs: Behavior, rhs: Behavior) std.math.Order {
        if (eq(lhs, rhs)) {
            return .eq;
        }

        if (lhs.isNormal() != rhs.isNormal()) {
            return if (lhs.isNormal())
                .gt
            else
                .lt;
        }

        if (lhs.isDev() != rhs.isDev()) {
            return if (lhs.isDev())
                .gt
            else
                .lt;
        }

        if (lhs.isOptional() != rhs.isOptional()) {
            return if (lhs.isOptional())
                .gt
            else
                .lt;
        }

        if (lhs.isPeer() != rhs.isPeer()) {
            return if (lhs.isPeer())
                .gt
            else
                .lt;
        }

        if (lhs.isWorkspace() != rhs.isWorkspace()) {
            return if (lhs.isWorkspace())
                .gt
            else
                .lt;
        }

        return .eq;
    }

    pub inline fn isRequired(this: Behavior) bool {
        return !isOptional(this);
    }

    pub fn isEnabled(this: Behavior, features: Features) bool {
        return this.isNormal() or
            (features.optional_dependencies and this.isOptional()) or
            (features.dev_dependencies and this.isDev()) or
            (features.peer_dependencies and this.isPeer()) or
            this.isWorkspace();
    }

    pub fn format(self: Behavior, comptime _: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
        const fields = std.meta.fields(Behavior);
        var num_fields: u8 = 0;
        inline for (fields) |f| {
            if (f.type == bool and @field(self, f.name)) {
                num_fields += 1;
            }
        }
        switch (num_fields) {
            0 => try writer.writeAll("Behavior.uninitialized"),
            1 => {
                inline for (fields) |f| {
                    if (f.type == bool and @field(self, f.name)) {
                        try writer.writeAll("Behavior." ++ f.name);
                        break;
                    }
                }
            },
            else => {
                try writer.writeAll("Behavior{");
                inline for (fields) |f| {
                    if (f.type == bool and @field(self, f.name)) {
                        try writer.writeAll(" " ++ f.name);
                    }
                }
                try writer.writeAll(" }");
            },
        }
    }

    comptime {
        bun.assert(@as(u8, @bitCast(Behavior.normal)) == (1 << 1));
        bun.assert(@as(u8, @bitCast(Behavior.optional)) == (1 << 2));
        bun.assert(@as(u8, @bitCast(Behavior.dev)) == (1 << 3));
        bun.assert(@as(u8, @bitCast(Behavior.peer)) == (1 << 4));
        bun.assert(@as(u8, @bitCast(Behavior.workspace)) == (1 << 5));
    }
};
