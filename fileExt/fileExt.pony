
interface Streamable	
	// new create(target:Streamable tag)
	be stream(chunkIso:Array[U8] iso)
	

type FileExtError is (String|None)

/*
primitive FileExt
	
	fun foo ():U64 =>
	    0
*/