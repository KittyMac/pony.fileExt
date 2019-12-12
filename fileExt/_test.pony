use "ponytest"
use "files"

actor Main is TestList
	new create(env: Env) => PonyTest(env, this)
	new make() => None

	fun tag tests(test: PonyTest) =>
		test(_TestFileReadArray)
		test(_TestFileReadString)
		test(_TestFileReadError)
        
		test(_TestFileWriteArray)
		test(_TestFileWriteString)
		
		test(_TestFileStreaming)
	
 	fun @runtime_override_defaults(rto: RuntimeOptions) =>
		rto.ponyminthreads = 2
		rto.ponynoblock = true
		rto.ponygcinitial = 0
		rto.ponygcfactor = 1.0


// ******************* Non-Streaming Tests *******************

class iso _TestFileReadArray is UnitTest
	fun name(): String => "readAsArray"

	fun apply(h: TestHelper) =>
		h.long_test(2_000_000_000_000)
		FileExtReader("test.txt").readAsArray({ (fileArrayIso:Array[U8] iso, err: FileExtError val) =>
			match (err)
			| let errorString: String val =>
				h.complete(false)
			| None =>
				let fileArray:Array[U8] ref = consume fileArrayIso
				h.complete(fileArray.size() == 24)
	        end
		} val)

class iso _TestFileReadString is UnitTest
	fun name(): String => "readAsString"

	fun apply(h: TestHelper) =>
		h.long_test(2_000_000_000_000)
		FileExtReader("test.txt").readAsString({ (fileStringIso:String iso, err: FileExtError val) =>
			match (err)
			| let errorString: String val =>
				h.complete(false)
			| None =>
				let fileString:String ref = consume fileStringIso
				h.complete(fileString == "This is a test document.")
	        end
		} val)

class iso _TestFileReadError is UnitTest
	fun name(): String => "readAsString returning an error"

	fun apply(h: TestHelper) =>
		h.long_test(2_000_000_000_000)
		FileExtReader("some_file_does_not_exist.txt").readAsString({ (fileStringIso:String iso, err: FileExtError val) =>
			match (err)
			| let errorString: String val =>
				h.complete(true)
			| None =>
				h.complete(false)
	        end
		} val)



class iso _TestFileWriteArray is UnitTest
	fun name(): String => "writeAsArray"

	fun apply(h: TestHelper) =>
		h.long_test(2_000_000_000_000)
		
		FileExtWriter("/tmp/test1.txt").writeAll("Hello, World!".array(), { (writer:FileExtWriter, err: FileExtError val) =>
			match (err)
			| let errorString: String val =>
				h.complete(false)
				return
			| None =>
				FileExtReader("/tmp/test1.txt").readAsArray({ (fileArrayIso:Array[U8] iso, err: FileExtError val) =>
					let fileString = String.from_iso_array(consume fileArrayIso)
					h.complete(fileString == "Hello, World!")
				} val)
				end
		} val)

class iso _TestFileWriteString is UnitTest
	fun name(): String => "writeString"

	fun apply(h: TestHelper) =>
		h.long_test(2_000_000_000_000)
		
		FileExtWriter("/tmp/test2.txt").writeAll("Hello, World!", {(writer:FileExtWriter, err: FileExtError val) =>
			match (err)
			| let errorString: String val =>
				h.complete(false)
				return
			| None =>
				// Read the file back in and confirm it worked
				FileExtReader("/tmp/test2.txt").readAsString({ (fileStringIso:String iso, err: FileExtError val) =>
					let fileString:String ref = consume fileStringIso
					h.complete(fileString == "Hello, World!")
				} val)
	        end
		} val)




class iso _TestFileStreaming is UnitTest
	fun name(): String => "streaming"
	fun apply(h: TestHelper) =>
		h.long_test(2_000_000_000_000)
		
		_TestFileStreamingActual(h)
		

actor _TestFileStreamingActual
	let chunkSize:USize = 64
	let reader:FileExtReader
	let writer:FileExtWriter
	let h:TestHelper
	var bytesTransferred:USize = 0
	
	new create(h': TestHelper) =>
		h = h'
		
		// read large file in chunks and write those chunks to another file
		reader = FileExtReader("test_large.txt")
		writer = FileExtWriter("/tmp/test_large.txt")
		
		// start off the reading		
		reader.read (chunkSize, this)
	
	be fileExtReaderDataReceived(sender:FileExtReader tag, dataIso:Array[U8] iso) =>
		let dataVal:Array[U8] val = consume dataIso
		bytesTransferred = bytesTransferred + dataVal.size()
		reader.read (chunkSize, this)
		writer.write(dataVal, {(writer:FileExtWriter, err: FileExtError val) => None })
	
	be fileExtReaderDataComplete(sender:FileExtReader tag) =>
		writer.close()
		reader.close()
		h.complete(bytesTransferred == 206051)
		
	be fileExtReaderError(sender:FileExtReader tag, errorno:I32 val) =>
		h.complete(false)


