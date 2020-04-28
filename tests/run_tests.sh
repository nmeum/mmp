#!/bin/sh

cd "${0%/*}"

export MMP_TEST_ADDR="${MMP_TEST_ADDR:-localhost}"
export MMP_TEST_PORT="${MMP_TEST_PORT:-6600}"

export BEET_TEST_ADDR="${BEET_TEST_ADDR:-localhost}"
export BEET_TEST_PORT="${BEET_TEST_PORT:-8080}"

mkdir -p "${testdir:=${TMPDIR:-/tmp}/mmp-tests}"
trap 'rm -rf ${testdir} ; kill $(jobs -p) 2>/dev/null' INT EXIT

export MMP_MUISC_DIRECTORY="${testdir}/music"
mkdir -p "${MMP_MUISC_DIRECTORY}"

export BEETSDIR="$(pwd)/testdata/beets"
sed -e "s|@MMP_TEST_DIRECTORY@|${testdir}|g" \
	-e "s|@MMP_MUISC_DIRECTORY@|${MMP_MUISC_DIRECTORY}|g" \
	-e "s|@BEET_TEST_ADDR@|${BEET_TEST_ADDR}|g" \
	-e "s|@BEET_TEST_PORT@|${BEET_TEST_PORT}|g" \
	< "${BEETSDIR}/config.yaml.in" > "${BEETSDIR}/config.yaml"
beet import --nowrite --noautotag --quiet \
	./testdata/music >"${testdir}/beet-import-log" 2>&1
beet web >"${testdir}/beet-web-log" 2>&1 &

for test in *; do
	[ -e "${test}/commands" ] || continue
	printf "Running test case '%s': " "${test##*/}"

	hy ../mmp.hy -a "${MMP_TEST_ADDR}" -p "${MMP_TEST_PORT}" \
		"http://${BEET_TEST_ADDR}:${BEET_TEST_PORT}/" &
	./wait_port.hy "${MMP_TEST_ADDR}" "${MMP_TEST_PORT}"

	output="${testdir}/output"
	env -i HOST="${MMP_TEST_ADDR}" PORT="${MMP_TEST_PORT}" \
		MUSICDIR="${MMP_MUISC_DIRECTORY}" \
		PATH="$(pwd):${PATH}" sh "${test}/commands" >"${output}" 2>&1

	expected="${testdir}/expected"
	sed "/./!d" < "${test}/output" > "${expected}"

	if ! cmp -s "${output}" "${expected}"; then
		printf "FAIL: Output didn't match.\n\n"
		diff -u "${output}" "${expected}"
		exit 1
	fi

	kill %2; wait %2
	printf "OK.\n"
done
