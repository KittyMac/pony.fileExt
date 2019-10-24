use "files"

actor FileExtWriter
	
	fun _writeArray(env:Env, filePath:String, fileContentVal:Array[U8] val) ? =>
		let fromPath = FilePath(env.root as AmbientAuth, filePath, FileCaps.>all())?
		
		if fromPath.exists() then
			fromPath.remove()
		end
		
	    let file = File(fromPath)
	    let err = file.errno()

	    match err
	    | FileOK =>
			file.write(fileContentVal)
			file.dispose()
		else
			error
	    end
	
	be writeString (env:Env, filePath:String, fileContents:String, completionVal: {(FileExtError val)} val) =>
		try
			_writeArray(env, filePath, fileContents.array()) ?
			completionVal(None)
		else
			completionVal("Failed to write file " + filePath)
		end
	
	be writeArray (env:Env, filePath:String, fileContents:Array[U8] val, completionVal: {(FileExtError val)} val) =>
		try
			_writeArray(env, filePath, fileContents) ?
			completionVal(None)
		else
			completionVal("Failed to write file " + filePath)
		end
