#!/bin/bash

log () {
	echo "LOG $*"
}

die () {
	echo "FATAL $*"
	exit 1
}

make_pgbin_dir() {
	echo "$bin_dir/$1"
}

get_loguq() {
	local repo="$1"
	local branch="$2"
	
	local oldpath="$(pwd)"

	[[ -d "$source_dir/pg_log_userqueries" ]] && rm -Rf "$source_dir/pg_log_userqueries"
	cd "$source_dir"
	log "Getting pg_log_userquerries"
	git clone "$repo"
	cd pg_log_userqueries
	log "Switching branch"
	git checkout "$branch"
	cd "$oldpath"
}

compile_loguq() {
	local pg_version=$1

	loguq_src_dir="$source_dir/pg_log_userqueries"
	pg_bin_dir="$bin_dir/$pg_version/bin"
	pg_lib_dir="$bin_dir/$pg_version/lib"
	export PATH=$pg_bin_dir:$PATH

	cd $loguq_src_dir
	log "Version $pg_version"
	log "-- make clean"
	make clean &> "$loguq_src_dir/${pg_version}_make_clean.log"
	log "-- make clean ($?)"
	log "-- make"
	make &> "$loguq_src_dir/${pg_version}_make.log"
	log "-- make ($?)"
	log "-- copying  binaries to $loguq_src_dir/pg_log_userqueries.so"
	sudo cp "$loguq_src_dir/pg_log_userqueries.so" "$pg_lib_dir"
}

main() {
	local repopath=""
	local branch=""

	if [[ "$2" ]]; then
		repopath="$2"
	else
		repopath="https://github.com/gleu/pg_log_userqueries.git"
	fi

	if [[ "$3" ]]; then
		branch="$3"
	else
		branch="master"
	fi

	[[ ! -d "$source_dir" ]] && mkdir "$source_dir"
	
	get_loguq "$repopath" "$branch"
	if [[ "$1" != "all" ]]; then
		compile_loguq $1
	else
		for version in "${version_list[@]}"; do
			compile_loguq "$version"
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
version_list[9]="13beta3"

bin_dir="/usr/local/postgres"
source_dir="/$USER/source"

main "$@"
