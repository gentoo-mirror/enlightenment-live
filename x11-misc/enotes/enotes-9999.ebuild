# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson xdg git-r3

DESCRIPTION="Sticky notes based on EFL"
HOMEPAGE="https://github.com/jf-simon/enotes"
EGIT_REPO_URI="https://github.com/jf-simon/${PN}.git"

S="${WORKDIR}/${P/_/-}"
LICENSE="GPL-2"
[ "${PV}" = 9999 ] || KEYWORDS="~amd64 ~x86"
SLOT="0"
IUSE="X"

RDEPEND="
	dev-libs/efl"
BDEPEND="${RDEPEND}
	dev-build/meson"

PATCHES=(
	"${FILESDIR}/enotes_fix.patch"
)
