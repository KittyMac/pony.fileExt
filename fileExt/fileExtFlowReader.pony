use "flow"
use "files"

actor FileExtFlowReader
	
	let target:Flowable tag
	
	var file:File
	let bufferSize:USize
	
	fun _tag():USize => 109
	
	new create (filePath:FilePath, bufferSize':USize, target':Flowable tag) =>
		bufferSize = bufferSize'
		target = target'
		
		file = File.open(filePath)
		_readNextChunk()
	
	be _readNextChunk() =>
		let fileContentIso = file.read_byteblock(bufferSize)		
		if fileContentIso.size() > 0 then
			target.flowReceived(consume fileContentIso)
			_readNextChunkAgain()
		else
			file.dispose()
			target.flowFinished()
		end

	
	be _readNextChunkAgain() =>
		_readNextChunk()
