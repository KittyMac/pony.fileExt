use "flow"
use "files"

actor FileExtFlowReader
	
	let target:Flowable tag
	
	var fd:I32
	let bufferSize:USize
	
	fun _tag():USize => 109
	
	fun _freed(wasRemote:Bool) =>
		if wasRemote then
			_readNextChunk()
		end
	
	new create (filePath:String, bufferSize':USize, target':Flowable tag) =>
		bufferSize = bufferSize'
		target = target'

		fd = FileExt.open(filePath)
		
		// We "prime the pump" by reading the first few chunks and sending them along.
		// After that, we rely on the _freed() method to tell us when a chunk has
		// finished processing.  When it has, then we read a chunk to replace it.
		_readNextChunk()
		_readNextChunk()
		_readNextChunk()
	
	be _readNextChunk() =>
		if fd > 0 then
			var bufferIso = recover iso Array[U8](bufferSize) end
		
			let bytesRead = FileExt.read(fd, bufferIso.cpointer(0), bufferSize)
			if bytesRead >= 0 then
				bufferIso.undefined(bytesRead.usize())
			else
				bufferIso.undefined(0)
			end
		
			if bufferIso.size() > 0 then
				target.flowReceived(consume bufferIso)
			else
				FileExt.close(fd)
				fd = 0
				target.flowFinished()
			end
		end
