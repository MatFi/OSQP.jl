using BinaryProvider # requires BinaryProvider 0.3.0 or later
if VERSION < v"1.3"
    # Parse some basic command-line arguments
    const verbose = "--verbose" in ARGS
    const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
    products = [
        LibraryProduct(prefix, ["libqdldl"], :qdldl),
        LibraryProduct(prefix, ["libosqp"], :osqp),
    ]

    # Download binaries from hosted location
    bin_prefix = "https://github.com/JuliaBinaryWrappers/OSQP_jll.jl/releases/download/OSQP-v0.6.2+0"

    # Listing of files generated by BinaryBuilder:
    download_info = Dict(
        Linux(:aarch64, libc=:glibc) => ("$bin_prefix/OSQP.v0.6.2.aarch64-linux-gnu.tar.gz", "93c57bf7fd36c37293f36e1d72d427d1c8149d28badc766490952c34049e34d1"),
        Linux(:aarch64, libc=:musl) => ("$bin_prefix/OSQP.v0.6.2.aarch64-linux-musl.tar.gz", "cea0d0ce128d7bae5ca679c3edb153305b4d1f4419f81a579db79dfe9b85e9e1"),
        Linux(:armv7l, libc=:glibc, call_abi=:eabihf) => ("$bin_prefix/OSQP.v0.6.2.armv7l-linux-gnueabihf.tar.gz", "25f22cdcf58c106797afaebe676db18c71d9ac806808d3cc08b53919511e4ed1"),
        Linux(:armv7l, libc=:musl, call_abi=:eabihf) => ("$bin_prefix/OSQP.v0.6.2.armv7l-linux-musleabihf.tar.gz", "511ff1974f471d8e5bc66ed7433bcedc40246c05e6aebc6ff6a369e05776a283"),
        Linux(:i686, libc=:glibc) => ("$bin_prefix/OSQP.v0.6.2.i686-linux-gnu.tar.gz", "c46f394223b334eec606dbf5712864e03cfafd54ad98df4e50da21ea591e3582"),
        Linux(:i686, libc=:musl) => ("$bin_prefix/OSQP.v0.6.2.i686-linux-musl.tar.gz", "db0ca4bb1110496af5f82a242e30afe2396ef3a995367e5133bf9f2e46caa5c7"),
        Windows(:i686) => ("$bin_prefix/OSQP.v0.6.2.i686-w64-mingw32.tar.gz", "0eaa202df481f1ae4a3613cda6e0b0caeb9e5fcc00cfdd89b45bf0a553d2ed9f"),
        Linux(:powerpc64le, libc=:glibc) => ("$bin_prefix/OSQP.v0.6.2.powerpc64le-linux-gnu.tar.gz", "e466b5c93a05d1ff3a629184fc6e42ea3f8aff4c69fba7cc79641d7121d30471"),
        MacOS(:x86_64) => ("$bin_prefix/OSQP.v0.6.2.x86_64-apple-darwin.tar.gz", "68e45febd50991f9d147e4383f2e567c267c74defd09c7bac4d4234bc945b737"),
        Linux(:x86_64, libc=:glibc) => ("$bin_prefix/OSQP.v0.6.2.x86_64-linux-gnu.tar.gz", "1e8dabe6b6a608c464c93ab18e503042c10f0316884bcb08309adb4968efc6d2"),
        Linux(:x86_64, libc=:musl) => ("$bin_prefix/OSQP.v0.6.2.x86_64-linux-musl.tar.gz", "d07af642fffe0d222cb0eef6ca312abccc3c5b4161e1395448479e2daa7d4abc"),
        FreeBSD(:x86_64) => ("$bin_prefix/OSQP.v0.6.2.x86_64-unknown-freebsd.tar.gz", "0e44aa7f915ed10a58e6fef75884d8423d03b53f9a24c20a75e187336412e1a9"),
        Windows(:x86_64) => ("$bin_prefix/OSQP.v0.6.2.x86_64-w64-mingw32.tar.gz", "0adb4e084b7c9f3619bf82b2301a7494160359723a9231328accab34c47ce772"),
    )

    # Install unsatisfied or updated dependencies:
    unsatisfied = any(!satisfied(p; verbose=verbose) for p in products)
    dl_info = choose_download(download_info, platform_key_abi())
    if dl_info === nothing && unsatisfied
        # If we don't have a compatible .tar.gz to download, complain.
        # Alternatively, you could attempt to install from a separate provider,
        # build from source or something even more ambitious here.
        error("Your platform (\"$(Sys.MACHINE)\", parsed as \"$(triplet(platform_key_abi()))\") is not supported by this package!")
    end

    # If we have a download, and we are unsatisfied (or the version we're
    # trying to install is not itself installed) then load it up!
    if unsatisfied || !isinstalled(dl_info...; prefix=prefix)
        # Download and install binaries
        install(dl_info...; prefix=prefix, force=true, verbose=verbose)
    end

    # Write out a deps.jl file that will contain mappings for our products
    write_deps_file(joinpath(@__DIR__, "deps.jl"), products, verbose=verbose)
end
