.PHONY: test test-format

TMPDIR ?= /tmp
SUBTMP ?= $(shell date "+%s")

test: test-format test-deconstruct

test-format:
	mkdir -p ${TMPDIR}/book-runner_${SUBTMP}
	bin/format-book test/fixtures/mansfield_park/input.txt ${TMPDIR}/book-runner_${SUBTMP}
	test/bin/format_test.sh test/fixtures/mansfield_park/output ${TMPDIR}/book-runner_${SUBTMP}

test-deconstruct:
	bin/deconstruct ${TMPDIR}/book-runner_${SUBTMP}/text.js > ${TMPDIR}/book-runner_${SUBTMP}/decon.txt
	test/bin/deconstruct_test.sh test/fixtures/mansfield_park/input.txt ${TMPDIR}/book-runner_${SUBTMP}/decon.txt

clean:
	rm -rf ${TMPDIR}/book-runner_*
