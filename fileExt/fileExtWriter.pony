use "files"
use "collections"

actor FileExtWriter

	var fd:I32
	var errno:I32
	
	fun _tag():USize => 113
	
	new create (filePath:String) =>
		fd = FileExt.open(filePath, FileExt.pReadWrite())
		errno = @pony_os_errno[I32]()
	
	be close() =>
		if fd >= 0 then
			FileExt.close(fd)
			fd = 0
		end
	
	be writeAll (fileContents:CPointer val, completionVal: {(FileExtWriter tag, FileExtError val)} val) =>
		if fd < 0 then
			completionVal(this, "Failed to write to file")
			return
		end
		FileExt.write(fd, fileContents.cpointer(), fileContents.size())
		FileExt.close(fd)
		completionVal(this, None)
	
	be write (fileContents:CPointer val, completionVal: {(FileExtWriter tag, FileExtError val)} val) =>
		if fd < 0 then
			completionVal(this, "Failed to write to file")
			return
		end
		FileExt.write(fd, fileContents.cpointer(), fileContents.size())
		completionVal(this, None)
		