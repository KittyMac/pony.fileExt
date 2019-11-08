use "files"
use "flow"

interface Freeable
	fun free()

actor FileExtFlowEnd is Flowable
	
	be flowFinished() =>
		true
	
	be flowReceived(dataIso:Any iso) =>
		try
			(dataIso as Freeable iso).free()
		end
	