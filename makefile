all:
	stable env /Volumes/Development/Development/pony/ponyc/build/release/ponyc -o ./build/ ./fileExt
	time ./build/fileExt

test:
	stable env /Volumes/Development/Development/pony/ponyc/build/release/ponyc -V=0 -o ./build/ ./fileExt
	./build/fileExt