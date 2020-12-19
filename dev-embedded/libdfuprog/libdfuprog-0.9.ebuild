# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit toolchain-funcs flag-o-matic

# The recentmost 0.9 release is untagged
GIT_COMMIT="15d3d928e750f0db577ace2493105d3403508d2d"
S="${WORKDIR}/${PN}-${GIT_COMMIT}"

DESCRIPTION="dfu-programmer, but with build scripts to make it buildable as a dynamic lib"
HOMEPAGE="https://github.com/EspoTek/libdfuprog"
# TODO: how to deal with mirrors properly?
SRC_URI="https://github.com/EspoTek/libdfuprog/archive/${GIT_COMMIT}.zip -> ${P}.zip"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm"

# Partly taken from dfu-programmer ebuild, except for the plugdev group, since it's out of scope
# of the library. The udev rules are installed in Labrador package.
RDEPEND="
	virtual/libusb:1
	virtual/udev"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

# Basically re-doing libdfuprog-make-linux steps to separate into stages
# TODO: more Gentoo-friendly way of doing this?
src_prepare() {
	default
	./bootstrap.sh
	cp "${S}/src/altmain/desktop/main.c" "${S}/src"
	cp "${S}/src/altmain/desktop/main.h" "${S}/src"
	cp "${S}/src/altmain/desktop/dfu.c" "${S}/src"
	cp "${S}/src/altmain/desktop/dfu.h" "${S}/src"
}

src_configure() {
	append-flags -fPIC
	econf
}

# from libudev-compat
echo_and_run() {
	echo "$@"
	"$@"
}

src_compile() {
	default
	
	# Gather object files into a library
	echo_and_run $(tc-getCC) \
		${CFLAGS} ${CPPFLAGS} ${LDFLAGS} \
		-shared \
		-Wl,-soname,${P}.so \
		-o ${P}.so \
		"${S}"/src/main.o \
		"${S}"/src/arguments.o \
		"${S}"/src/atmel.o \
		"${S}"/src/commands.o \
		"${S}"/src/dfu.o \
		"${S}"/src/intel_hex.o \
		"${S}"/src/stm32.o \
		"${S}"/src/util.o \
		-Wl,--no-as-needed \
		-lusb-1.0 || die
}

src_install() {
	# Don't do default here in order not to clash with actual dfu-programmer which is implicitly built
	# This also skips the README, but that's probably irrelevant since it's a hack of a package anyway
	dolib.so ${P}.so
}
