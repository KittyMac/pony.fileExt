use "files"
use "flow"

actor FileExtFlowEnd is Flowable
	
	be flowFinished() =>
		true
	
	be flowReceived(dataIso:Any iso) =>
		try
			(dataIso as ByteBlock iso).free()
		end
	