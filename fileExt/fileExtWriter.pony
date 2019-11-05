use "files"
use "collections"

actor FileExtWriter
	
	be writeString (env:Env, filePath:String, fileContents:String, completionVal: {(FileExtError val)} val) =>
		try
			FileExt.stringToFile(fileContents, filePath)?
			completionVal(None)
		else
			completionVal("Failed to write file " + filePath)
		end
	
	be writeArray (env:Env, filePath:String, fileContents:Array[U8] val, completionVal: {(FileExtError val)} val) =>
		try
			FileExt.arrayToFile(fileContents, filePath)?
			completionVal(None)
		else
			completionVal("Failed to write file " + filePath)
		end
	
	be writeByteBlock (env:Env, filePath:String, fileContents:ByteBlock val, completionVal: {(FileExtError val)} val) =>
		try
			FileExt.byteBlockToFile(fileContents, filePath)?
			completionVal(None)
		else
			completionVal("Failed to write file " + filePath)
		end
