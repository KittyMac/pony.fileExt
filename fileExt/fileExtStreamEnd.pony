use "files"

actor FileExtStreamEnd is Streamable
	
	be stream(chunkIso:ByteBlock iso) =>
		chunkIso.free()
	