use "files"

interface FileExtReaderCallback
	be fileExtReaderDataReceived(sender:FileExtReader tag, data:Array[U8] iso)
	be fileExtReaderDataComplete(sender:FileExtReader tag)
	be fileExtReaderError(sender:FileExtReader tag, errorno:I32 val)

actor FileExtReader
	"""
	Read from a file asynchronously in chunks
	"""
	
	var fd:I32
	var errno:I32
	
	fun _tag():USize => 112
			
	new create (filePath:String) =>
		fd = FileExt.open(filePath, FileExt.pRead())
		errno = @pony_os_errno[I32]()
	
	be close() =>
		if fd >= 0 then
			FileExt.close(fd)
			fd = 0
		end
	
	be read (bufferSize:USize, callback:FileExtReaderCallback tag) =>
		if fd >= 0 then
			var bufferIso = recover iso Array[U8](bufferSize) end
	
			let bytesRead = FileExt.read(fd, bufferIso.cpointer(0), bufferSize)
			if bytesRead >= 0 then
				bufferIso.undefined(bytesRead.usize())
			else
				bufferIso.undefined(0)
			end
	
			if bufferIso.size() > 0 then
				callback.fileExtReaderDataReceived(this, consume bufferIso)
			else
				FileExt.close(fd)
				fd = 0
				callback.fileExtReaderDataComplete(this)
			end
		else
			callback.fileExtReaderError(this, errno)
		end
	
	be readAsString (completionVal: {(String iso, FileExtError val)} val) =>
		try
			completionVal(recover iso FileExt.fileDescriptorToString(fd)? end, None)
		else
			completionVal(recover iso String end, "Failed to read file")
		end
	
	be readAsArray (completionVal: {(Array[U8] iso, FileExtError val)} val) =>
		try
			completionVal(recover iso FileExt.fileDescriptorToArray(fd)? end, None)
		else
			completionVal(recover iso Array[U8] end, "Failed to read file")
		end
	