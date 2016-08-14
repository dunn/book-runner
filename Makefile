TMPDIR ?= /tmp
SUBTMP ?= $(shell date "+%s")
TMPPATH := ${TMPDIR}/book-runner_${SUBTMP}

${TMPPATH}:
	mkdir -p ${TMPDIR}/book-runner_${SUBTMP}

${TMPPATH}/%: ${TMPPATH}
	bin/format-book test/fixtures/mansfield_park/input.txt ${TMPPATH}

${TMPDIR}/decon.txt: ${TMPPATH}/text.js
	bin/deconstruct ${TMPPATH}/text.js > ${TMPDIR}/decon.txt



.PHONY: check test test-format test-deconstruct

check: test

test: test-format test-deconstruct

test-format: ${TMPPATH}/cast.js ${TMPPATH}/text.js ${TMPPATH}/freq.csv
	test/bin/format_test.sh test/fixtures/mansfield_park/output ${TMPPATH}

test-deconstruct: ${TMPDIR}/decon.txt
	test/bin/deconstruct_test.sh test/fixtures/mansfield_park/input.txt ${TMPDIR}/decon.txt

clean:
	rm -rf ${TMPDIR}/book-runner_*
