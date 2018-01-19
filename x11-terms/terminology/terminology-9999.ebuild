# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit meson
[ "${PV}" = 9999 ] && inherit git-r3

DESCRIPTION="Feature rich terminal emulator using the Enlightenment Foundation Libraries"
HOMEPAGE="https://www.enlightenment.org/p.php?p=about/terminology"
EGIT_REPO_URI="https://git.enlightenment.org/apps/${PN}.git"
[ "${PV}" = 9999 ] || SRC_URI="http://download.enlightenment.org/rel/apps/${PN}/${P/_/-}.tar.xz"

LICENSE="BSD-2"
[ "${PV}" = 9999 ] || KEYWORDS="~amd64 ~x86"
SLOT="0"

IUSE=""

RDEPEND="|| ( >=dev-libs/efl-1.18.0 ( <dev-libs/efl-1.18.0 >=media-libs/elementary-1.15.1 ) )"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	dev-util/meson"

S="${WORKDIR}/${P/_/-}"

src_configure() {
	local emesonargs=(
		-Dnls=true
	)
	meson_src_configure
}

src_install() {
	meson_src_install
}
