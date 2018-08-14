# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "Shoco"
version = v"0.1.0" # NOTE: Shoco itself has no tagged versions

version_sha = "4dee0fc850cdec2bdb911093fe0a6a56e3623b71"

# Collection of sources required to build Shoco
sources = [
    "https://github.com/Ed-von-Schleck/shoco/archive/$version_sha.tar.gz" =>
        "20caed48304d4dcafd04dff6db2f4adaba21943811400da5b8008f14edab7667",
]

# Bash recipe for building across all platforms
script = raw"""
    cd ${WORKSPACE}/srcdir/shoco-*
    if [[ ${target} == *apple* ]]; then
        flag=-dynamiclib
    else
        flag=-shared
    fi
    ${CC} shoco.c -o libshoco.${dlext} -fPIC -std=c99 ${flag}
    if [ ! -d ${prefix}/lib ]; then
        mkdir -p ${prefix}/lib
    fi
    cp libshoco.* ${prefix}/lib
    """

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    FreeBSD(:x86_64),
    Linux(:aarch64, :glibc),
    Linux(:aarch64, :musl),
    Linux(:armv7l, :glibc, :eabihf),
    Linux(:armv7l, :musl, :eabihf),
    Linux(:i686, :glibc),
    Linux(:i686, :musl),
    Linux(:powerpc64le, :glibc),
    Linux(:x86_64, :glibc),
    Linux(:x86_64, :musl),
    MacOS(:x86_64),
]

# The products that we will ensure are always built
products(prefix) = [LibraryProduct(prefix, "libshoco", :libshoco)]

# Dependencies that must be installed before this package can be built
dependencies = []

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)
