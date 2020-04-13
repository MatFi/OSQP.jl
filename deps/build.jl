if VERSION < v"1.3"
using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
products = [
    LibraryProduct(["libqdldl"], :qdldl),
    LibraryProduct(["libosqp"], :osqp),
]

# Download binaries from hosted location
bin_prefix = "https://github.com/JuliaBinaryWrappers/OSQP_jll.jl/releases/download/OSQP-v0.6.0+0"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:aarch64, libc=:glibc) => ("$bin_prefix/OSQP.v0.6.0.aarch64-linux-gnu.tar.gz", "139e7bb6c2210c1b5d792960e2229185ac94289cf7fd55c86c73bf44ca38013f"),
    Linux(:aarch64, libc=:musl) => ("$bin_prefix/OSQP.v0.6.0.aarch64-linux-musl.tar.gz", "78ad77311ebe6d621a226f63a6920877ea8393d62e5abdb201964c4ca580edfc"),
    Linux(:armv7l, libc=:glibc, call_abi=:eabihf) => ("$bin_prefix/OSQP.v0.6.0.armv7l-linux-gnueabihf.tar.gz", "4fb74c6519a13fe5a75da80c2b44ce45262b474dca8d2021c9dcdbe20e680118"),
    Linux(:armv7l, libc=:musl, call_abi=:eabihf) => ("$bin_prefix/OSQP.v0.6.0.armv7l-linux-musleabihf.tar.gz", "c3a841bdac8c037df4eca5082828aa90638d5ba2a28bf8f22899a83b537a13ab"),
    Linux(:i686, libc=:glibc) => ("$bin_prefix/OSQP.v0.6.0.i686-linux-gnu.tar.gz", "6e5e613c26ba0736ac4018f1bf8c91fc660f9fd2288fb5770d711e32dbb0da52"),
    Linux(:i686, libc=:musl) => ("$bin_prefix/OSQP.v0.6.0.i686-linux-musl.tar.gz", "0d8ea9dcacf58ec745c970b251c16c4cb27d26e30af3c8e75935c165ca3b3d44"),
    Windows(:i686) => ("$bin_prefix/OSQP.v0.6.0.i686-w64-mingw32.tar.gz", "1b5886d77b142bb5c85176277c8bcf363ec21a83aedffb827d5a8ffd7ed56ef1"),
    Linux(:powerpc64le, libc=:glibc) => ("$bin_prefix/OSQP.v0.6.0.powerpc64le-linux-gnu.tar.gz", "fc937a5f877cb17ab1b9126de75ecf4eb877a4020ab301a78a54b57c50d37856"),
    MacOS(:x86_64) => ("$bin_prefix/OSQP.v0.6.0.x86_64-apple-darwin14.tar.gz", "0b0c6e606827b3ee771a489d180a7979eb6a6134519ad590d5881d10c29c6cfb"),
    Linux(:x86_64, libc=:glibc) => ("$bin_prefix/OSQP.v0.6.0.x86_64-linux-gnu.tar.gz", "86734eb074eabc12287ea94bdc04045cefbc78c7fe39148489545648723c0dae"),
    Linux(:x86_64, libc=:musl) => ("$bin_prefix/OSQP.v0.6.0.x86_64-linux-musl.tar.gz", "934b618c3e825fd772640fce820bc4745456de579bbddaeb4eb844391534af1c"),
    FreeBSD(:x86_64) => ("$bin_prefix/OSQP.v0.6.0.x86_64-unknown-freebsd11.1.tar.gz", "9f3cfb392085ccef8ce4ca5d76ad2ba6b44fd471040c13527ed1e377b98ff76e"),
    Windows(:x86_64) => ("$bin_prefix/OSQP.v0.6.0.x86_64-w64-mingw32.tar.gz", "77b7969e5eb719fb75686b896398b19ab36ead406498bd19c9b451ca3e1d9807"),
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
