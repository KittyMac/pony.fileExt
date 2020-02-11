all:
	corral run -- ponyc -o ./build/ ./fileExt
	./build/fileExt

test:
	corral run -- ponyc -V=0 -o ./build/ ./fileExt
	./build/fileExt




corral-fetch:
	@corral clean -q
	@corral fetch -q

corral-local:
	-@rm corral.json
	-@rm lock.json
	@corral init -q
	@corral add /Volumes/Development/Development/pony/pony.flow -q

corral-git:
	-@rm corral.json
	-@rm lock.json
	@corral init -q
	@corral add github.com/KittyMac/pony.flow.git -q

ci: corral-git corral-fetch all
	
dev: corral-local corral-fetch all
