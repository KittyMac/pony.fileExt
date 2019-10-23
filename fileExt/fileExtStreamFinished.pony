use "files"

interface StreamFinished	
	fun streamFinished()

actor FileExtStreamFinished is Streamable
	
	let target:Streamable tag
	let sender:StreamFinished val

	new create(sender':StreamFinished val, target':Streamable tag) =>
		target = target'
		sender = sender'

	be stream(chunkIso:Array[U8] iso) =>
		if chunkIso.size() == 0 then
			sender.streamFinished()
		end
		target.stream(consume chunkIso)
	