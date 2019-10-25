use "files"

actor FileExtStreamWriter is Streamable
	
	var file:(File|None)
	let target:Streamable tag
	let env:Env

	new create (env':Env, filePath:String, target':Streamable tag) =>
		file = None
		target = target'
		env = env'
		
		try
			var fromPath = FilePath(env.root as AmbientAuth, filePath, FileCaps.>all())?
			if fromPath.exists() then
				fromPath.remove()
			end
			file = File(fromPath)
		end
		
	be stream(fileArrayIso:ByteBlock iso) =>		
		try
			let actualFile = (file as File)
			if fileArrayIso.size() == 0 then
				actualFile.dispose()
				target.stream(consume fileArrayIso)
			else
				let nextfileArrayIso = actualFile.write_byteblock_iso(consume fileArrayIso)
				target.stream(consume nextfileArrayIso)
			end
		end

actor FileExtStreamWriterEnd is Streamable

	var file:(File|None)
	let env:Env

	new create (env':Env, filePath:String) =>
		file = None
		env = env'

		try
			var fromPath = FilePath(env.root as AmbientAuth, filePath, FileCaps.>all())?
			if fromPath.exists() then
				fromPath.remove()
			end
			file = File(fromPath)
		end

	be stream(fileArrayIso:ByteBlock iso) =>		
		try
			let actualFile = (file as File)
			if fileArrayIso.size() == 0 then
				actualFile.dispose()
			else
				actualFile.write_byteblock(consume fileArrayIso)
			end
		end

	
	

		
		

