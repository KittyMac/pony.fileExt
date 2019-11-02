use "files"
use "flow"

actor FileExtFlowWriter is (FlowConsumerAck)
	
	var file:File

	new create (filePath:FilePath) =>
		if filePath.exists() then
			filePath.remove()
		end
		file = File(filePath)
	
	be flowFin() =>
		file.dispose()
		
	be flowAck(sender:FlowProducer tag, dataIso:Any iso) =>
		let data:Any ref = consume dataIso
		try
			file.write_byteblock(data as ByteBlock)
		end
		sender.ackFlow()
		
