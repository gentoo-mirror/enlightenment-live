# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
PYTHON_COMPAT=( python{2_7,3_2,3_4} pypy2_0 )

inherit distutils-r1
[ "${PV}" = 9999 ] && inherit git-r3

DESCRIPTION="Enlightenment photo browser"
HOMEPAGE="https://github.com/DaveMDS/eluminance"
EGIT_REPO_URI="https://github.com/DaveMDS/eluminance.git"

LICENSE="GPL-3"
[ "${PV}" = 9999 ] || KEYWORDS="~amd64 ~x86"
SLOT="0"

IUSE=""
RDEPEND=">=dev-libs/efl-1.18.0
		dev-python/python-efl
		dev-python/pyxdg
		${PYTHON_DEPS}"

DEPEND="${RDEPEND}"

S="${WORKDIR}/${P/_/-}"
