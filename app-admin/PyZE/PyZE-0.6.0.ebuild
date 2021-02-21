# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python3_{5,6,7,8} )

inherit distutils-r1

DESCRIPTION="Unofficial client and API for Renault ZE"
HOMEPAGE="https://github.com/jamesremuscat/pyze"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86"

RDEPEND="
	dev-python/pyjwt
	dev-python/wheel
	dev-python/simplejson
"
BDEPEND=""

PATCHES=(
	"${FILESDIR}/${PN}-no-pytest-runner.patch"
)

python_install_all() {
    distutils-r1_python_install_all
	doenvd "${FILESDIR}"/99"${PN}"
}