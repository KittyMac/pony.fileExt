use "files"

actor FileExtStreamReader is Streamable
	
	var file:(File|None) = None
	
	let target:Streamable tag
	let bufferSize:USize
	let env:Env
	let filePath:String
	
	new create (env':Env, filePath':String, bufferSize':USize, target':Streamable tag) =>
		bufferSize = bufferSize'
		env = env'
		filePath = filePath'
		target = target'
		
		let caps = recover val FileCaps.>set(FileRead).>set(FileStat) end
		try
			var fromPath = FilePath(env.root as AmbientAuth, filePath, caps)?
			file = File.open(fromPath)
		
		    let err = (file as File).errno()
		    match err
		    | FileOK =>
				_streamNextChunk()
		    else
				target.stream(recover iso ByteBlock end)
		    end
		else
			file = None
			target.stream(recover iso ByteBlock end)
		end
	
	be stream(fileByteBlockIso:ByteBlock iso) =>
		target.stream(consume fileByteBlockIso)
	
	be _streamNextChunk() =>
		try
			let fileContentIso = (file as File).read_byteblock(bufferSize)
						
			if fileContentIso.size() == 0 then
				(file as File).dispose()
				target.stream(consume fileContentIso)
			else
				target.stream(consume fileContentIso)
				_streamNextChunk()
			end
		else
			try
				(file as File).dispose()
			end
			target.stream(recover iso ByteBlock end)
		end
		
	
	