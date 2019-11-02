use "flow"
use "files"

actor FileExtFlowEnd is (FlowConsumer & FlowConsumerAck)
	
	be flowFin() =>
		true
	
	be flow(dataIso: Any iso) =>
		consume dataIso

	be flowAck(sender:FlowProducer tag, dataIso:Any iso) =>
		consume dataIso
		sender.ackFlow()
	