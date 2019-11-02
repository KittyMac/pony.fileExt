use "flow"
use "files"

actor FileExtFlowReader is FlowProducer
	
	let rateLimiter:FlowRateLimiter
	let target:FlowConsumerAck tag
	
	var file:File
	let bufferSize:USize
		
	be ackFlow() =>
		rateLimiter.ack()
	
	new create (filePath:FilePath, bufferSize':USize, rateLimit:USize, target':FlowConsumerAck tag) =>
		bufferSize = bufferSize'
		target = target'
		
		file = File.open(filePath)
		
		let sender = this
		rateLimiter = FlowRateLimiter(rateLimit, {ref () =>
			// produce the next block of data from the file. return TRUE is there is more data
			// to be produced.
			var endOfStreamReached = true
			
			let fileContentIso = file.read_byteblock(bufferSize)
			if fileContentIso.size() > 0 then
				target.flowAck(sender, consume fileContentIso)
				endOfStreamReached = false
			end
			
			if endOfStreamReached then
				file.dispose()
				target.flowFin()
			end
		
			(endOfStreamReached == false)
		})
	