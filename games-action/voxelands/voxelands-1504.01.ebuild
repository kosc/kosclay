EAPI=5
inherit vcs-snapshot games cmake-utils gnome2-utils
DESCRIPTION="A fork of Minetest, an Infiniminer/Minecraft inspired game"
SRC_URI="http://voxelands.com/downloads/${PN}-${PV}-src.tar.bz2"
HOMEPAGE="http://www.voxelands.com/"
LICENSE="GPL-3 CC-BY-SA-3.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="dedicated +server +truetype +sound"
DEPEND="dev-db/sqlite:3
		sys-libs/zlib
		virtual/libintl
		!dedicated? (
			>=dev-games/irrlicht-1.8
			sound? (
				media-libs/libogg
				media-libs/libvorbis
				media-libs/openal
			)	
			truetype? ( media-libs/freetype:2 )
		)"
S="${WORKDIR}/${PN}"

src_prepare() {
	if [[ -n "${LINGUAS+x}" ]] ; then
		for i in $(cd po ; echo *) ; do
			if ! has ${i} ${LINGUAS} ; then
				rm -r po/${i} || die
			fi
		done
	fi
}

src_configure() {
	 local mycmakeargs=(
		$(usex dedicated "-DBUILD_SERVER=ON -DBUILD_CLIENT=OFF" "$(cmake-utils_use_build server SERVER) -DBUILD_CLIENT=ON")
		-DCUSTOM_BINDIR="${GAMES_BINDIR}"
		-DCUSTOM_DOCDIR="/usr/share/doc/${PF}"
		-DCUSTOM_LOCALEDIR="/usr/share/locale"
		-DCUSTOM_SHAREDIR="${GAMES_DATADIR}/${PN}"
		$(cmake-utils_use_enable truetype FREETYPE)
		$(cmake-utils_use_enable sound AUDIO)
		-DRUN_IN_PLACE=0
		$(use dedicated && {
			echo "-DIRRLICHT_SOURCE_DIR=/the/irrlicht/source"
			echo "-DIRRLICHT_INCLUDE_DIR=/usr/include/irrlicht"
		})
	)

	cmake-utils_src_configure
}
src_install() {
	cmake-utils_src_install
}
pkg_preinst() {
	games_pkg_preinst
	gnome2_icon_savelist
}