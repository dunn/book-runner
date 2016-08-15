TMPDIR ?= /tmp
SECONDS := $(shell date "+%s")
TMPPATH := ${TMPDIR}/book-runner_${SECONDS}

${TMPPATH}:
	mkdir -p ${TMPDIR}/book-runner_${SECONDS}

${TMPPATH}/%: ${TMPPATH}
	bin/build test/fixtures/mansfield_park/input.txt ${TMPPATH}

${TMPDIR}/decon.txt: ${TMPPATH}/text.js
	bin/deconstruct ${TMPPATH}/text.js > ${TMPDIR}/decon.txt



.PHONY: check test test-format test-deconstruct test-output

check: test

test: test-format test-deconstruct test-output

test-format: ${TMPPATH}/cast.js ${TMPPATH}/text.js ${TMPPATH}/freq.csv
	test/bin/compare.sh test/fixtures/mansfield_park/formatted/cast.js ${TMPPATH}/cast.js
	test/bin/compare.sh test/fixtures/mansfield_park/formatted/text.js ${TMPPATH}/text.js
	test/bin/compare.sh test/fixtures/mansfield_park/formatted/freq.csv ${TMPPATH}/freq.csv

test-deconstruct: ${TMPDIR}/decon.txt
	test/bin/compare.sh test/fixtures/mansfield_park/input.txt ${TMPDIR}/decon.txt

test-output: test-format
	for n in $$(seq 0 4); do \
		bin/run --dry=true --dbfile=${TMPDIR}/${SECONDS}.status ${TMPPATH}/text.js \
			> ${TMPDIR}/${SECONDS}_$$n.log && \
		test/bin/compare.sh test/fixtures/mansfield_park/console/$$n.log ${TMPDIR}/${SECONDS}_$$n.log || exit 1; \
	done

clean:
	rm -rf ${TMPDIR}/book-runner_*
