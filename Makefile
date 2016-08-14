.PHONY: test test-format

TMPDIR ?= /tmp
SUBTMP ?= $(shell date "+%s")

test: test-format

test-format:
	mkdir -p ${TMPDIR}/book-runner_${SUBTMP}
	bin/format-book test/fixtures/mansfield_park/input.txt ${TMPDIR}/book-runner_${SUBTMP}
	test/bin/format_test.sh test/fixtures/mansfield_park/output ${TMPDIR}/book-runner_${SUBTMP}

clean:
	rm -rf ${TMPDIR}/book-runner_*
