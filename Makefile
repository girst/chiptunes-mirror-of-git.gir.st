a.out: foo.c
	gcc foo.c
	./a.out |head -c31457280 |diff -s - full-orig.pcm
	# NOTE: starts to diverge after 33423360 bytes
	git add foo.c
	git commit -m "new version"

.PHONY: test
test:
	gcc foo.c
	./a.out |head -c31457280 |diff -s - full-orig.pcm
