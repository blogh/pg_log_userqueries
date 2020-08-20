#!/bin/bash

PORT=7654

log() {
	echo "$(date) LOG $*"
}

warn() {
	echo "$(date) LOG $*"
}

die() {
	echo "$(date) FATAL $*"
	exit 1
}

bootstrap_instance (){
	local PGBIN=$1
	local PGDATA=$2
	local TESTFILE=$3

	local CUSTOM_VARIABLE_CLASS=""
	local SOCKET_DIR="unix_socket_directories"

	log "initdb -D $PGDATA"
	"$PGBIN"/initdb -D "$PGDATA" --username postgres &>/dev/null
	#"$PGBIN"/initdb -D "$PGDATA" --username postgres

	VERSION=$(cat "$PGDATA/PG_VERSION")
	if [[ "$VERSION" == "9.1" ]] || [[ "$VERSION" == "9.0" ]]; then
		CUSTOM_VARIABLE_CLASS="custom_variable_classes = 'pg_log_userqueries'"
	fi
	if [[ "$VERSION" == "9.1" ]] || [[ "$VERSION" == "9.0" ]]  \
	|| [[ "$VERSION" == "9.2" ]] ;  then
		SOCKET_DIR="unix_socket_directory"
	fi

	cat >>"$PGDATA"/postgresql.conf <<EOF

## ports
port = $PORT
$SOCKET_DIR = '/tmp'

## Tests pg_log_userqueries
shared_preload_libraries = 'pg_log_userqueries'
$CUSTOM_VARIABLE_CLASS
pg_log_userqueries.log_level = 'INFO'
pg_log_userqueries.log_label = 'LOG_UQ'
EOF
	cat ./sql/${TESTFILE}.conf >> "$PGDATA"/postgresql.conf

	log "pgstart $PGDATA"
	"$PGBIN"/pg_ctl start -D "$PGDATA" -w &>/dev/null
	#"$PGBIN"/pg_ctl start -D "$PGDATA" -w
}

scratch_instance (){
	local PGBIN=$1
	local PGDATA=$2

	if [[ ! -f "$PGDATA/PG_VERSION" ]]; then
		die "$PGDATA is not a valid PGDATA"
	fi

	log "pgstop $PGDATA"
	"$PGBIN"/pg_ctl stop -D "$PGDATA" -w -m fast &>/dev/null
	#"$PGBIN"/pg_ctl stop -D "$PGDATA" -w -m fast
	log "removing $PGDATA"
	rm -Rf "$PGDATA"
}

status_instance (){
	log "pgstatus $PGDATA"
	"$PGBIN"/pg_ctl status -D "$PGDATA"
}

run_test (){
	local PGBIN=$1
	local TESTFILE=$2

#	local VERSION=""
	log "test"

	$PGBIN/psql -Xe -p $PORT -U postgres -d postgres -f ./sql/${TESTFILE}.sql

#	VERSION=$($PGBIN/psql -p $PORT -U postgres -d postgres -XtA -c "SELECT substring(lpad(current_setting('server_version_num'),6,'0'), 1, 4)")
#	$PGBIN/psql -Xe -p $PORT -U postgres -d postgres -f ./sql/${TESTFILE}.sql 2>./test.log

#	diff ./sql/${TESTFILE}_${VERSION}.log ./test.log 2>/dev/null
#	[[ "$?" -ne "0" ]] && warn "Test $TESTFILE for version $VERSION failed"
}

instance_test() {
	local PGBIN="$1"
	local PGDATA="$2"
	local TESTFILE="$3"

	log "==== test version : $($PGBIN/postmaster -V)"

	bootstrap_instance "$PGBIN" "$PGDATA" "$TESTFILE"
	status_instance "$PGBIN" "$PGDATA"
	run_test "$PGBIN" "$TESTFILE"
	scratch_instance "$PGBIN" "$PGDATA"
}

usage() {
	cat <<EOF
usage:	$0 -f TEST_NAME
	$0 -a
EOF
	exit 1
}

main() {
	set -o errexit
	set -o nounset
	set -o pipefail

	local TEST=""
	while getopts "f:a" option; do
		case "${option}" in
			f) TEST="${OPTARG}";;
			a) TEST="@ll tests please";;
			*) usage;;
		esac
	done
	[[ -z "$TEST" ]] && usage

	for d in $(find /usr/local/postgres -maxdepth 2 -type d -name bin); do
		BIN_ROOT=$d
		DATA_ROOT=/home/vagrant/postgres

		if [[ "$TEST" == "@ll tests please" ]]; then
			for f in $(find ./sql -name "*.conf" | sed -e "s/\.\/sql\/\(.*\)\.conf/\1/g"); do
				instance_test "$BIN_ROOT" "$DATA_ROOT" "$f"
			done
		else
			instance_test "$BIN_ROOT" "$DATA_ROOT" "$TEST"
		fi
	done
}

main "$@"
