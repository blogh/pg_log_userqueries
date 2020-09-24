#!/bin/bash

log () {
	echo "LOG $*"
}

die () {
	echo "FATAL $*"
	exit 1
}

compile_pg() {
	local version="$1"

	local srcdir="$(make_source_dir $version)"
	local bindir="$(make_bin_dir $version)"

	[[ ! -d "$srcdir" ]] && die "$srcdir n'est pas un répertoire"
	[[ -z "$version" ]] && die "il n'y a pas de version en parametre"

	log "Install $version from $srcdir in $bindir"
	cd $srcdir
	log "-- configure"
	./configure --prefix="$bindir" &>${version}_configure.log
	log "-- configure ($?)"
	log "-- make"
	make &>${version}_make.log
	log "-- make ($?)"
	log "-- make install"
	make install &>${version}_makeinstall.log
	log "-- make install ($?)"
	cd -
}

get_pg() {
	local version="$1"

	local version_source_dir=$(make_source_dir $version)
	local version_archive=$(make_archive $version)
	local version_url=$(make_url $version)

	log "Getting PostgreSQL $version sources from the web" 
	[[ -d "$version_source_dir" ]] && rm -Rf "$version_source_dir"
	[[ -f "$version_archive" ]] && rm -f "$version_archive"

	cd "$source_dir"
	log "-- wget $version_url"
	wget --no-verbose "$version_url"
	log "-- uncompress $version_archive"
	tar zxvf "$version_archive" 1>/dev/null
	cd -
}

make_url() {
	echo "https://ftp.postgresql.org/pub/source/v$1/postgresql-$1.tar.gz"
}

make_archive() {
	echo "$source_dir/postgresql-$1.tar.gz"
}

make_source_dir() {
	echo "$source_dir/postgresql-$1"
}

make_bin_dir() {
	echo "$bin_dir/$1"
}

main() {
	[[ ! -d "$source_dir" ]] && mkdir "$source_dir"

	if [[ "$#" -eq 1 ]]; then
		get_pg $1
		compile_pg $1
	else
		for version in "${version_list[@]}"; do
			get_pg "$version"
			compile_pg "$version"
		done
	fi
}

declare -a version_list
version_list[0]="9.1.24"
version_list[1]="9.2.24"
version_list[2]="9.3.25"
version_list[3]="9.4.26"
version_list[4]="9.5.23"
version_list[5]="9.6.19"
version_list[6]="10.14"
version_list[7]="11.9"
version_list[8]="12.4"
version_list[9]="13.0"

bin_dir="/usr/local/postgres"
source_dir="$HOME/source"

main "$@"
