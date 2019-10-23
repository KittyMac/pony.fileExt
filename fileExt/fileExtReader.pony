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
