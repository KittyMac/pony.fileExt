use "files"

actor FileExtStreamByteCounter is Streamable
	
	var bytesRead:USize = 0
	let env:Env
	var target:Streamable tag
	
	new create(env':Env, target':Streamable tag) =>
		env = env'
		target = target'
	
	be stream(fileArrayIso:ByteBlock iso) =>
		bytesRead = bytesRead + fileArrayIso.size()
		if fileArrayIso.size() == 0 then
			env.out.print("Stream closed, " + bytesRead.string() + " bytes were read")
		end
		target.stream(consume fileArrayIso)
	
		