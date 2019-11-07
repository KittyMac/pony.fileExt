use @open[I32](path:Pointer[U8] tag, oflag:U32, omode:U32)
use @write[ISize](fildes:I32, bytes:Pointer[U8] tag, nbyte:USize)
use @read[ISize](fildes:I32, bytes:Pointer[U8] tag, nbyte:USize)
use @lseek[USize](fd: I32, offset: I64, base: I32)
use @close[U32](fildes:I32)
use @memset[Pointer[None]](dst: Pointer[None], set: U32, len: USize)

type FileExtError is (String|None)

interface CPointer
	fun cpointer(offset: USize = 0): Pointer[U8] tag
	fun size(): USize
	

// just a straight wrapper around unix open/write/close; seems to kicks 
// the pants off of Pony's File class in terms of performance
primitive FileExt
	fun pCRW():U32 => (0x0200 or 0x0002)
	fun pR():U32 => (0x0000)
	fun sSET():I32 => 0 // set file offset to offset
	fun sCUR():I32 => 1 // set file offset to current plus offset
	fun sEND():I32 => 2 // set file offset to EOF plus offset
	
	fun _sharedToFile(content:CPointer box, filePath:String box)? =>
		let fd = @open(filePath.cstring(), pCRW(), 0x1B6)
		if fd < 0 then
			error
		end
		@write(fd, content.cpointer(), content.size())
		@close(fd)
	
	fun stringToFile(content:String box, filePath:String box)? =>
		_sharedToFile(content, filePath)?
	
	fun arrayToFile(content:Array[U8] box, filePath:String box)? =>
		_sharedToFile(content, filePath)?
	
	fun byteBlockToFile(content:ByteBlock box, filePath:String box)? =>
		_sharedToFile(content, filePath)?
		
	fun bitmapToFile(content:Bitmap box, filePath:String box)? =>
		_sharedToFile(content, filePath)?
			
	
	fun fileToString(filePath:String box):String ref? =>
		let fd = @open(filePath.cstring(), pR(), 0755)
		if fd < 0 then
			error
		end
		
		let totalSize = @lseek(fd, 0, sEND())
		let content = String(totalSize + 1)
		@lseek(fd, 0, sSET())
		
		var p:USize = 0
		var r:ISize = 0
		while p < totalSize do
			r = @read(fd, content.cpointer(p), totalSize - p)
			if r < 0 then
				break
			end
			p = p + r.usize()
		end
		
		// null terminate and recalc the size of the string
		@memset(content.cpointer(p), U32(0), 1)
		content.recalc()
		
		@close(fd)
				
		content
	
	fun fileToArray(filePath:String box):Array[U8] ref? =>
		let fd = @open(filePath.cstring(), pR(), 0755)
		if fd < 0 then
			error
		end
	
		let totalSize = @lseek(fd, 0, sEND())
		let content = Array[U8](totalSize)
		@lseek(fd, 0, sSET())
	
		var p:USize = 0
		var r:ISize = 0
		while p < totalSize do
			r = @read(fd, content.cpointer(p), totalSize - p)
			if r < 0 then
				break
			end
			p = p + r.usize()
		end
	
		content.undefined(p)
	
		@close(fd)
			
		content
	
	fun fileToByteBlock(filePath:String box):ByteBlock ref? =>
		let fd = @open(filePath.cstring(), pR(), 0755)
		if fd < 0 then
			error
		end

		let totalSize = @lseek(fd, 0, sEND())
		let content = ByteBlock(totalSize)
		@lseek(fd, 0, sSET())

		var p:USize = 0
		var r:ISize = 0
		while p < totalSize do
			r = @read(fd, content.cpointer(p), totalSize - p)
			if r < 0 then
				break
			end
			p = p + r.usize()
		end

		@close(fd)
		
		content
	
	fun fileToBitmap(w:USize, h:USize, filePath:String box):Bitmap ref? =>
		let fd = @open(filePath.cstring(), pR(), 0755)
		if fd < 0 then
			error
		end

		let totalSize = @lseek(fd, 0, sEND())
		let content = Bitmap(w, h)
		@lseek(fd, 0, sSET())

		var p:USize = 0
		var r:ISize = 0
		while p < totalSize do
			r = @read(fd, content.cpointer(p), totalSize - p)
			if r < 0 then
				break
			end
			p = p + r.usize()
		end

		@close(fd)
	
		content
	

// 0x1ED == 0755
// 0x1B6 == 0666

/*
	let kO_CREATE:U32 = 0x0200
	let kO_RDONLY:U32 = 0x0000
	let kO_WRONLY:U32 = 0x0001
	let kO_RDWR:U32 = 0x0002

	let kS_IRWXU:U32 = 0000700
	let kS_IRUSR:U32 = 0000400
	let kS_IWUSR:U32 = 0000200
	let kS_IXUSR:U32 = 0000100
	let kS_IRWXO:U32 = 0000007
	let kS_IROTH:U32 = 0000004
	let kS_IWOTH:U32 = 0000002
	let kS_IXOTH:U32 = 0000001
*/