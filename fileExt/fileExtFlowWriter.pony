use "files"
use "flow"

actor FileExtFlowWriterEnd is Flowable
	
	var file:File
	
	fun _batch():USize => 4
	fun _tag():USize => 110

	new create (filePath:FilePath) =>
		file = File(filePath)
	
	be flowFinished() =>
		file.dispose()
		
	be flowReceived(dataIso:Any iso) =>
		let data:Any ref = consume dataIso
		try
			let block = data as ByteBlock
			file.write_byteblock(block)
			block.free()
		end


actor FileExtFlowWriter is Flowable

	var file:File
	let target:Flowable tag
	
	fun _batch():USize => 4
	fun _tag():USize => 111

	new create (filePath:FilePath, target':Flowable tag) =>
		target = target'
		file = File(filePath)

	be flowFinished() =>
		file.dispose()
		target.flowFinished()
	
	be flowReceived(dataIso:Any iso) =>
		try
			let nextBlockIso = file.write_byteblock_iso((consume dataIso) as ByteBlock iso^)
			target.flowReceived(consume nextBlockIso)
		end