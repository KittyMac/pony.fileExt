use "files"

actor FileExtStreamPassthru is Streamable
	
	let target:Streamable tag

	new create(target':Streamable tag) =>
		target = target'
	
	be stream(chunkIso:Array[U8] iso) =>
		target.stream(consume chunkIso)
	