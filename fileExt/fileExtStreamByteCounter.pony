use "files"
use "flow"

actor FileExtFlowByteCounter is Flowable
	
	var bytesRead:USize = 0
	var target:Flowable tag
	
	new create(target':Flowable tag) =>
		target = target'
	
	be flowFinished() =>
		@fprintf[I64](@pony_os_stdout[Pointer[U8]](), "Flow closed, %d bytes were read\n".cstring(), bytesRead)
		target.flowFinished()

	be flowReceived(dataIso:Any iso) =>
		try
			bytesRead = bytesRead + (dataIso as ByteBlock iso).size()
		end
		target.flowReceived(consume dataIso)
	
		