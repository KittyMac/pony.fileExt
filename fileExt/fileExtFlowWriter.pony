use "files"
use "flow"

actor FileExtFlowWriter is (FlowConsumerAck)
	
	var file:File

	new create (filePath:FilePath) =>
		file = File(filePath)
	
	be flowFin() =>
		file.dispose()
		
	be flowAck(sender:FlowProducer tag, dataIso:Any iso) =>
		let data:Any ref = consume dataIso
		try
			file.write_byteblock(data as ByteBlock)
		end
		
