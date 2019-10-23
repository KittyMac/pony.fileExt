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
		
	be stream(fileArrayIso:Array[U8] iso) =>		
		try
			let actualFile = (file as File)
			if fileArrayIso.size() == 0 then
				actualFile.dispose()
				target.stream(consume fileArrayIso)
			else
				// Note: I really don't like this, but for the life of me I cannot
				// figure out a better mechanism for making a copy of fileArrayIso
				// to send off
				let hardCopyString1 = String.from_iso_array(consume fileArrayIso)
				let hardCopyString2 = hardCopyString1.clone().iso_array()
				
				target.stream(consume hardCopyString2)
				actualFile.write(consume hardCopyString1)
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

	be stream(fileArrayIso:Array[U8] iso) =>		
		try
			let actualFile = (file as File)
			if fileArrayIso.size() == 0 then
				actualFile.dispose()
			else
				actualFile.write(consume fileArrayIso)
			end
		end

	
	

		
		

