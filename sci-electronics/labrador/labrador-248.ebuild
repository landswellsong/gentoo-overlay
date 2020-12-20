# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit qmake-utils udev

GIT_TAG="continuous-win32-build248"
S="${WORKDIR}/Labrador-${GIT_TAG}/Desktop_Interface"

DESCRIPTION="USB device that transforms your PC or smartphone into a fully-featured electronics lab"
HOMEPAGE="https://espotek.com/labrador/"
SRC_URI="https://github.com/EspoTek/Labrador/archive/${GIT_TAG}.zip -> ${P}.zip"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm"

DEPEND="
	>=dev-embedded/libdfuprog-0.9
	dev-qt/qtcore:5
	dev-qt/qtgui:5
	dev-qt/qtwidgets:5
	dev-qt/qtprintsupport:5
	virtual/libusb:1
	virtual/udev
"
RDEPEND="${DEPEND}"

src_prepare() {
	# Comment out the bundled library binary
	# TODO: use flag to use one?
	sed -i -e 's/\(INSTALLS += lib_deploy\)/# \1/g' Labrador.pro

	# Remove the udev reload step, and override rules installation
	# They aren't being installed in a correct folder for Gentoo anyway
	sed -i -e 's/\(INSTALLS += udevextra\)/# \1/g' Labrador.pro
	sed -i -e 's/\(INSTALLS += udev\)/# \1/g' Labrador.pro

	# Place the executable directly as /usr/bin/labrador instead of nesting folders under /usr/bin
	# TODO: maybe just install to /opt/?
	sed -i -e 's/\(INSTALLS += symlink\)/# \1/g' Labrador.pro
	sed -i -e 's/EspoTek-Labrador\/Labrador/labrador/g' resources/espotek-labrador.desktop
	sed -i -e 's/\(target.path = \/usr\/bin\).*/\1/g' Labrador.pro
	sed -i -e 's/\(TARGET = \)L/\1l/g' Labrador.pro

	# Place the assets under /usr/share/EspoTek-Labrador, I mean seriously, under bin?
	# TODO: can/should we build firmware as part of installation?
	sed -i -e 's/\(\/usr\/\)bin\(\/EspoTek-Labrador\)/\1share\2/g' Labrador.pro
	sed -i -e 's/QCoreApplication::applicationDirPath()/QString("\/usr\/share\/EspoTek-Labrador")/g' functiongencontrol.cpp
	sed -i -e 's/QCoreApplication::applicationDirPath()/QString("\/usr\/share\/EspoTek-Labrador")/g' unixusbdriver.cpp
	sed -i -e 's/QCoreApplication::applicationDirPath()/QString("\/usr\/share\/EspoTek-Labrador")/g' ui_elements/espocombobox.cpp

	# Honor prefix for the sandbox installation
	sed -i -e 's/= \//= \$\$PREFIX\//g' Labrador.pro

	# TODO: do we need additional plugdev rules for firmware update?
	eapply_user
}

src_configure() {
	eqmake5 PREFIX="${D}" Labrador.pro
}

src_install() {
	default
	udev_dorules rules.d/69-labrador.rules
}
