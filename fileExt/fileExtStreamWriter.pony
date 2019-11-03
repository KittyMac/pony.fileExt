use "files"
use "flow"

actor FileExtFlowWriterEnd is Flowable
	
	var file:File

	new create (filePath:FilePath) =>
		file = File(filePath)
	
	be flowFinished() =>
		file.dispose()
		
	be flowReceived(dataIso:Any iso) =>
		let data:Any ref = consume dataIso
		try
			file.write_byteblock(data as ByteBlock)
		end


actor FileExtFlowWriter is Flowable

	var file:File
	let target:Flowable tag
	
	fun _batch():USize => 4

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