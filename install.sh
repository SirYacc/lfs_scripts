file="./system_tmp";
tmp_file="tmp.$$";
gcc_step=0;
true >| "$tmp_file";
binutNbPass="0";
gccNbPass="0";

function gcc_lib_init (){

	tar -xf ../mpfr-3.1.3.tar.xz;
	mv -v mpfr-3.1.3 mpfr;
	tar -xf ../gmp-6.0.0.a.tar.xz;
	mv -v gmp-6.0.0 gmp;
	tar -xf ../mpc-1.0.3.tar.gz;
	mv -v mpc-1.0.3 mpc;

	for elt in \
	$(find gcc/config -name linux64.h -o -name linux.h -o -name sysv4.h)
	do
	cp -uv $elt{,.orig}
	sed -e 's@/lib\(64\)\?\(32\)\?/ld@/tools&@g' \
	-e 's@/usr@/tools@g' $elt.orig > $elt
	echo '
#undef STANDARD_STARTFILE_PREFIX_1
#undef STANDARD_STARTFILE_PREFIX_2
#define STANDARD_STARTFILE_PREFIX_1 "/tools/lib/"
#define STANDARD_STARTFILE_PREFIX_2 ""' >> $elt
	touch $elt.orig
	done
}
function binut_preconf (){
	case $1 in
	1) buildDir="binutils-build";
	listOfDir="$listOfDir $buildDir"
	mkdir -v ../"$buildDir";
	cd ../"$buildDir";
	confPath="../$2"
	confParams="--prefix=/tools --with-sysroot=$LFS --with-lib-path=/tools/lib --target=$LFS_TGT --disable-nls --disable-werror";;
	2) buildDir="binutils-build";
	listOfDir="$listOfDir $buildDir"
	mkdir -v ../"$buildDir";
	cd ../"$buildDir";
	confVar="CC=$LFS_TGT-gcc; AR=$LFS_TGT-ar; RANLIB=$LFS_TGT-ranlib;";
	confPath="../$2";
	confParams="--prefix=/tools --with-sysroot=$LFS --with-lib-path=/tools/lib --target=$LFS_TGT --disable-nls --disable-werror";;
	esac
}

function gcc_preconf (){
	case $1 in
	1) gcc_lib_init;
	buildDir="gcc-build";
	listOfDir="$listOfDir $buildDir"
	mkdir -v ../"$buildDir";
	cd ../"$buildDir";
	confPath="../$2"
	confParams="--target=$LFS_TGT --prefix=/tools --with-glibc-version=2.11 --with-sysroot=$LFS --with-newlib --without-headers --with-local-prefix=/tools --with-native-system-header-dir=/tools/include --disable-nls --disable-shared --disable-multilib --disable-decimal-float --disable-threads --disable-libatomic --disable-libgomp --disable-libquadmath --disable-libssp --disable-libvtv --disable-libstdcxx --enable-languages=c,c++";;
	2) buildDir="gcc-build";
	listOfDir="$listOfDir $buildDir";
	mkdir -v ../"$buildDir";
	cd ../"$buildDir";
	confPath="../$2/libstdc++-v3";
	confParams="--host=$LFS_TGT --prefix=/tools --disable-multilib --disable-nls --disable-libstdcxx-threads --disable-libstdcxx-pch --with-gxx-include-dir=/tools/$LFS_TGT/include/c++/5.2.0";;
	3) cat gcc/limitx.h gcc/glimits.h gcc/limity.h > `dirname $($LFS_TGT-gcc -print-libgcc-file-name)`/include-fixed/limits.h;
	gcc_lib_init;
	buildDir="gcc-build";
	listOfDir="$listOfDir $buildDir"
	mkdir -v ../"$buildDir";
	cd ../"$buildDir";
	confVar="CC=$LFS_TGT-gcc; CXX=$LFS_TGT-g++; AR=$LFS_TGT-ar; RANLIB=$LFS_TGT-ranlib;";
	confPath="../$2";
	confParams="--prefix=/tools --with-local-prefix=/tools --with-native-system-header-dir=/tools/include --enable-languages=c,c++ --disable-libstdcxx-pch --disable-multilib --disable-bootstrap --disable-libgomp";;
	esac
}

function glibc_preconf (){
	patch -Np1 -i ../glibc-2.22-upstream_i386_fix-1.patch;
	buildDir="glibc-build";
	listOfDir="$listOfDir $buildDir";
	mkdir -v ../"$buildDir";
	cd ../"$buildDir";
	confPath="../$1"
	confParams="--prefix=/tools --host=$LFS_TGT --build=$(../"$buildDir"/scripts/config.guess) --disable-profile --enable-kernel=2.6.32 --enable-obsolete-rpc --with-headers=/tools/include libc_cv_forced_unwind=yes libc_cv_ctors_header=yes libc_cv_c_cleanup=yes";
}

function tcl_preconf (){
	cd unix;
	confPath=".";
	confParams="--prefix=/tools";
}

function expect_preconf (){
	cp -v configure{.,orig};
	sed 's:/usr/local/bin:/bin:' configure.orig > configure;
	confPath=".";
	confParams="--prefix=/tools --with-tcl=/tools/lib --with-tclinclude=/tools/include";
}

function dejagnu_preconf (){
	confPath=".";
	confParams="--prefix=/tools";
}

function check_preconf (){
	confVar="PKG_CONFIG=\"\";";
	confPath=".";
	confParams="--prefix=/tools";
}

function ncurses_preconf (){
	sed -i s/mawk// configure
	confPath=".";
	confParams="--prefix=/tools --with-shared --without-debug --without-ada --enable-widec --enable-overwrite"
}

function bash_preconf (){
	confPath=".";
	confParams="--prefix=/tools --without-bash-malloc";
}

function coreutils_preconf (){
	confPath=".";
	confParams="--prefix=/tools --enable-install-program=hostname";
}

function default_preconf (){
	confPath=".";
	confParams="--prefix=/tools";
}

function gettext_preconf (){
	cd gettext-tools
	confVar="EMACS=no;";
	confPath=".";
	confParams="--prefix/tools --disable-shared";
}

function make_preconf(){
	confPath=".";
	confParams="--prefix=/tools --without-guile";
}

function perl_preconf(){
	confParams="-des -Dprefix=/tools -Dlibs=-lm";
}

function util_linux_preconf(){
	confVar=".";
	confParams="--prefix=/tools --without-python --disable-makeinstall-chown --without-systemdsystemunitdir PKG_CONFIG=\"\"";
}

function preconf (){
	case $1 in
	binutils-2.25.1) let binutNbPass++; binut_preconf $binutNbPass $2;;
	gcc-5.2.0) let gccNbPass++; gcc_preconf $gccNbPass $2;; 
	glibc-2.22) glibc_preconf $2;;
	tcl-core8.6.4) tcl_preconf $2;;
	expect5.45) expect_preconf $2;;
	dejagnu-1.5.3) dejagnu_preconf $2;;
	check-0.10.0) check_preconf $2;;
	ncurses-6.0) ncurses_preconf $2;;
	bash-4.3.30) bash_preconf $2;;
	coreutils-8.24) coreutils_preconf $2;;
	diffutils-3.3|file-5.24|findutils-4.4.2|gawk-4.1.3|\
	grep-2.21|gzip-1.6|m4-1.4.17|patch-2.7.5|sed-4.2.2|\
	tar-1.28|texinfo-6.0|xz-5.2.1) default_preconf;;
	gettext-0.19.5.1) gettext_preconf $2;;
	make-4.1) make_preconf $2;;
	perl-5.22.0) perl_preconf $2;;
	util-linux-2.27) util_linux_preconf;;
	*) true;;
	esac
}

function install (){
	preconf "$1" "$2"
}

for packet in $(cat $listOfPackets)
do
listOfDir="";
#step 1: extract the packet
tar -xf "$packet"

#step 2: go to the packet directory
tmp_path=$(tar -tf $packet | head -n1)
packetDir=${tmp_path%%/*}
cd "$packetDir"
listOfDir="$packetDir";

#step 3: packet installation (variable)
packetName=$(echo "$packet" | sed -r 's/a?[-.](src|tar).*') 
install "$packetName" "$packetDir"

#step 4: go back to sources directory
cd ..

#step 5: remove all directories created during the process
rm -fr "$listOfDir"

done
