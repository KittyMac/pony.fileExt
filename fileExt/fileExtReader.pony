use "files"

actor FileExtReader
	"""
	FileExtReader is an actor which provides quick and simple functionality for reading files
	"""
	
	fun _readAsArray(env:Env, filePath:String):Array[U8] iso^ ? =>
		let caps = recover val FileCaps.>set(FileRead).>set(FileStat) end

		let fromPath = FilePath(env.root as AmbientAuth, filePath, caps)?

	    let file = File.open(fromPath)
	    let err = file.errno()

	    match err
	    | FileOK =>
			let fileContentIso = file.read(file.size())
			file.dispose()
			return fileContentIso
	    else
			error
	    end
	
	be readAsString (env:Env, filePath:String, completionVal: {(String iso, FileExtError val)} val) =>
		try
			completionVal(String.from_iso_array(_readAsArray(env, filePath)?), None)
		else
			completionVal(recover iso String end, "Failed to read file " + filePath)
		end
	
	be readAsArray (env:Env, filePath:String, completionVal: {(Array[U8] iso, FileExtError val)} val) =>
		try
			completionVal(_readAsArray(env, filePath)?, None)
		else
			completionVal(recover iso Array[U8] end, "Failed to read file " + filePath)
		end
	
	
actor FileExtStreamer
	"""
	FileExtStreamer provides automated chunked reading for streaming of files
	"""
	
	var file:(File|None) = None
	let bufferSize:USize
	let target:Streamable tag
	
	new create (env:Env, filePath:String, bufferSize':USize, target':Streamable tag) =>
		let caps = recover val FileCaps.>set(FileRead).>set(FileStat) end
		
		bufferSize = bufferSize'
		target = target'
		
		try
			var fromPath = FilePath(env.root as AmbientAuth, filePath, caps)?
			file = File.open(fromPath)
			
		    let err = (file as File).errno()

		    match err
		    | FileOK =>
				_streamNextChunk()
		    else
				target.receiveStream(recover iso Array[U8] end)
		    end
		else
			file = None
			target.receiveStream(recover iso Array[U8] end)
		end
		
	    
	
	be _streamNextChunk() =>
		try
			let fileContentIso = (file as File).read(bufferSize)
			if fileContentIso.size() == 0 then
				(file as File).dispose()
				target.receiveStream(consume fileContentIso)
			else
				target.receiveStream(consume fileContentIso)
				_streamNextChunk()
			end
		else
			target.receiveStream(recover iso Array[U8] end)
		end
		
	
	

		
		

