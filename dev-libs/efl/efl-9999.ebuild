# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

LUA_REQ_USE="deprecated(+)"
LUA_COMPAT=( lua5-{1,2} luajit )
PYTHON_COMPAT=( python3_{11..14} )

inherit flag-o-matic git-r3 lua-single meson python-any-r1 xdg

DESCRIPTION="Enlightenment Foundation Core Libraries"
HOMEPAGE="https://www.enlightenment.org/"
EGIT_REPO_URI="https://git.enlightenment.org/enlightenment/${PN}.git"
# EGIT_REPO_URI="file:   ///data/projects/efl"

S="${WORKDIR}/${P/_/-}"
LICENSE="BSD-2 GPL-2 LGPL-2.1 ZLIB"

SLOT="0"
[ "${PV}" = 9999 ] || KEYWORDS="amd64 x86"

IUSE="+X avif bmp connman cpu_flags_arm_neon dds debug doc drm +eet elogind examples fbcon"
IUSE+=" +fontconfig fribidi gif glib +gstreamer harfbuzz heif hyphen ibus ico jpeg2k jpegxl json"
IUSE+=" nls mono opengl +pdf physics pmaps postscript psd pulseaudio raw scim sdl +sound +svg"
IUSE+=" systemd test tga tgv tiff tslib unwind v4l vnc wayland webp xcf xim xpm xpresent zeroconf"

REQUIRED_USE="${LUA_REQUIRED_USE}
	?? ( elogind systemd )
	?? ( fbcon tslib )
	drm? ( wayland )
	examples? ( eet svg )
	gstreamer? ( sound )
	ibus? ( glib )
	opengl? ( X )
	pulseaudio? ( sound )
	xim? ( X )
	xpresent? ( X )"

# Requires everything to be enabled unconditionally.
RESTRICT="test"

RDEPEND="${LUA_DEPS}
	dev-libs/libinput:=
	dev-libs/libunibreak:=
	dev-libs/openssl:0=
	net-misc/curl
	media-libs/giflib:=
	media-libs/libjpeg-turbo:=
	media-libs/libpng:=
	sys-apps/dbus
	sys-apps/util-linux
	sys-libs/zlib
	X? (
		!opengl? ( media-libs/libglvnd )
		media-libs/freetype
		x11-libs/libX11
		x11-libs/libXScrnSaver
		x11-libs/libXcomposite
		x11-libs/libXcursor
		x11-libs/libXdamage
		x11-libs/libXext
		x11-libs/libXfixes
		x11-libs/libXi
		x11-libs/libXinerama
		x11-libs/libXrandr
		x11-libs/libXrender
		x11-libs/libXtst
		x11-libs/libxkbcommon
		wayland? ( x11-libs/libxkbcommon[X] )
	)
	avif? ( media-libs/libavif:= )
	connman? ( net-misc/connman )
	drm? (
		dev-libs/libinput:=
		dev-libs/wayland
		media-libs/mesa[gbm(+)]
		x11-libs/libdrm
		x11-libs/libxkbcommon
	)
	elogind? (
		sys-auth/elogind
		virtual/libudev:=
	)
	fontconfig? (
		media-libs/fontconfig
		media-libs/freetype
	)
	fribidi? ( dev-libs/fribidi )
	glib? ( dev-libs/glib:2 )
	gstreamer? (
		media-libs/gstreamer:1.0
		media-libs/gst-plugins-base:1.0
	)
	harfbuzz? ( media-libs/harfbuzz:= )
	heif? ( media-libs/libheif:= )
	hyphen? ( dev-libs/hyphen )
	ibus? ( app-i18n/ibus )
	jpeg2k? ( media-libs/openjpeg:= )
	jpegxl? ( media-libs/libjxl:= )
	json? ( >=media-libs/rlottie-0.0.1_pre20200424:= )
	mono? ( dev-lang/mono )
	opengl? ( virtual/opengl )
	pdf? ( app-text/poppler:=[cxx] )
	physics? ( sci-physics/bullet:= )
	postscript? ( app-text/libspectre )
	pulseaudio? ( media-libs/libpulse )
	raw? ( media-libs/libraw:= )
	scim? ( app-i18n/scim )
	sdl? ( media-libs/libsdl2 )
	sound? ( media-libs/libsndfile )
	svg? ( gnome-base/librsvg:2 )
	systemd? ( sys-apps/systemd:= )
	tiff? ( media-libs/tiff:= )
	tslib? ( x11-libs/tslib:= )
	unwind? ( sys-libs/libunwind:= )
	v4l? ( media-libs/libv4l )
	vnc? ( net-libs/libvncserver )
	wayland? (
		dev-libs/wayland
		media-libs/libglvnd
		media-libs/mesa[wayland]
		x11-libs/libxkbcommon
	)
	webp? ( media-libs/libwebp:= )
	xpm? ( x11-libs/libXpm )
	xpresent? ( x11-libs/libXpresent )
	zeroconf? ( net-dns/avahi )"

DEPEND="${RDEPEND}
	X? ( x11-base/xorg-proto )
	wayland? ( dev-libs/wayland-protocols )"

BDEPEND="${PYTHON_DEPS}
	virtual/pkgconfig
	doc? ( app-text/doxygen )
	examples? ( sys-devel/gettext )
	mono? ( dev-build/cmake )
	nls? ( sys-devel/gettext )
	wayland? ( dev-util/wayland-scanner )"

pkg_setup() {
	# Deprecated, provided for backward-compatibility. Everything is moved to libefreet.so.
	QA_FLAGS_IGNORED="/usr/$(get_libdir)/libefreet_trash.so.${PV}
		/usr/$(get_libdir)/libefreet_mime.so.${PV}"

	python-any-r1_pkg_setup
}

src_prepare() {
	default

	# Remove automagic unwind configure option, #743154
	if ! use unwind; then
		sed -i "/config_h.set('HAVE_UNWIND/,/eina_ext_deps += unwind/d" src/lib/eina/meson.build ||
			die "Failed to remove libunwind dep"
	fi

	# Fix python shebangs for python-exec[-native-symlinks], #764086
	local shebangs=($(grep -rl "#!/usr/bin/env python3" || die))
	python_fix_shebang -q ${shebangs[*]}
}

src_configure() {
	if use ssl && use gnutls ; then
		einfo "You enabled both USE=ssl and USE=gnutls, but only one can be used;"
		einfo "ssl has been selected for you."
	fi

	local emesonargs=(
	    -Dbuffer=false
		-Dcocoa=false
		-Ddrm-deprecated=false
		-Dembedded-libunibreak=false
		-Dg-mainloop=false
		-Dmono-beta=false
		-Ddotnet=false
		-Dwl-deprecated=false

		-Dedje-sound-and-video=true
		-Deeze=true
		-Dinput=true
		-Dinstall-eo-files=true
		-Dlibmount=true
		-Dnative-arch-optimization=true

	    $(meson_use fbcon fb)
		$(meson_use v4l v4l2)
		$(meson_use vnc vnc-server)
	    $(meson_use doc docs)

		$(meson_use lua_single_target_luajit elua)

		$(meson_use drm drm)
		$(meson_use fontconfig fontconfig)
		$(meson_use fribidi fribidi)
		$(meson_use gstreamer gstreamer)
		$(meson_use glib glib)
		$(meson_use harfbuzz harfbuzz)
		$(meson_use nls nls)
		$(meson_use physics physics)
		$(meson_use pulseaudio pulseaudio)
		$(meson_use sdl sdl)
		$(meson_use sound audio)
		$(meson_use systemd systemd)
		$(meson_use tslib tslib)
		$(meson_use zeroconf avahi)

		-Dnetwork-backend=$(usex connman connman none)
		-Dcrypto=$(usex ssl openssl $(usex gnutls gnutls none))

		$(meson_use test build-tests)
		$(meson_use examples build-examples)
		$(meson_use debug debug-threads)
		$(meson_use debug eina-magic-debug)

		$(meson_use X x11)
		$(meson_use wayland wl)
	)
	local bindingsList="cxx,"
	use lua_single_target_luajit && bindingsList+="lua,"
	[[ ! -z "$bindingsList" ]] && bindingsList=${bindingsList::-1}
	emesonargs+=( -D bindings="${bindingsList}" )

	local luaChoice="lua"
	if use lua_single_target_luajit; then
		luaChoice="luajit"
	fi
	emesonargs+=( -D lua-interpreter="${luaChoice}")

	# Options dependant on others
	if use X; then
		emesonargs+=(
			-Dxinput2=true
			-Dxinput22=true
			$(meson_use xpresent xpresent)
		)
	fi

	# Checking imf
	combind_imf=""
	for token in xim ibus scim ; do
		if use !$token ; then
			combined_imf="${combined_imf}${combined_imf:+,}$token"
		fi
	done

	# Checking evas loaders
	combined_evas_loaders="avif"
	for token in bmp dds eet gif heif ico json pdf psd raw svg tga tiff xcf xpm webp; do
		if use !$token ; then
			combined_evas_loaders="${combined_evas_loaders}${combined_evas_loaders:+,}$token"
		fi
	done

	# Checking for other evas loaders
	if use !jpeg2k ; then
		combined_evas_loaders="${combined_evas_loaders}${combined_evas_loaders:+,}jp2k"
	fi
	if use !gstreamer ; then
		combined_evas_loaders="${combined_evas_loaders}${combined_evas_loaders:+,}gst"
	fi
	if use !ppm ; then
		combined_evas_loaders="${combined_evas_loaders}${combined_evas_loaders:+,}pmaps"
	fi
	if use !postscript; then
		combined_evas_loaders="${combined_evas_loaders}${combined_evas_loaders:+,}ps"
	fi

	emesonargs+=(
		-Decore-imf-loaders-disabler="$combined_imf"
		-Devas-loaders-disabler="$combined_evas_loaders"
	)

	if use wayland; then
		einfo "Using es-egl as a backend because you selected wayland."
		emesonargs+=( -D opengl=es-egl )
	elif ! use wayland && use opengl; then
		einfo "Using full as a backend."
		emesonargs+=( -D opengl=full )
	elif ! use wayland && use X && ! use opengl; then
		einfo "Using es-egl as a backend."
		emesonargs+=( -D opengl=es-egl )
	else
		ewarn "Disabling gl for all backends."
		emesonargs+=( -D opengl=none )
	fi

	# Not all arm CPU's have neon instruction set, #722552
	if use arm && ! use cpu_flags_arm_neon; then
		emesonargs+=( -D native-arch-optimization=false )
	fi

	if use elibc_musl ; then
		append-cflags -D_LARGEFILE64_SOURCE
	fi

	# https://bugs.gentoo.org/944215
	# https://git.enlightenment.org/enlightenment/efl/issues/93
	append-cflags -std=gnu17

	meson_src_configure
}

src_compile() {
	meson_src_compile
}

src_test() {
	MAKEOPTS+=" -j1"
	meson_src_test
}

src_install() {
	MAKEOPTS+=" -j1"

	meson_src_install
	find "${ED}" -name '*.la' -delete || die
	if use examples; then
		docompress -x /usr/share/doc/${PF}/examples/
		dodoc -r "${BUILD_DIR}"/src/examples/
	fi
}
