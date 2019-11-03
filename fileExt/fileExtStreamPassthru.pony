use "files"
use "flow"

actor FileExtFlowPassthru is Flowable
	
	let target:Flowable tag

	new create(target':Flowable tag) =>
		target = target'
	
	be flowFinished() =>
		target.flowFinished()
	
	be flowReceived(dataIso:Any iso) =>
		target.flowReceived(consume dataIso)