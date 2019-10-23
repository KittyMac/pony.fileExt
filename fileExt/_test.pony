use "ponytest"

actor Main is TestList
	new create(env: Env) => PonyTest(env, this)
	new make() => None

	fun tag tests(test: PonyTest) =>
	
		test(_TestFileReadArray)
		test(_TestFileReadString)
		test(_TestFileReadError)
		
		test(_TestFileWriteArray)
		test(_TestFileWriteString)
		
		test(_TestFileExtStreaming)
		
		


class iso _TestFileExtStreaming is UnitTest
	fun name(): String => "read file as stream"
	
	
	
	fun apply(h: TestHelper) =>
	
		let callback = object val is StreamFinished
			fun streamFinished() =>
				h.env.out.print("Stream finished!")
				true
		end
		
		FileExtStreamReader(h.env, "test_large.txt", 512,
			FileExtStreamPassthru(
				FileExtStreamByteCounter(h.env,
					FileExtStreamPassthru(
						FileExtStreamWriter(h.env, "/tmp/test_large.txt",
							FileExtStreamFinished(callback, FileExtStreamEnd)
						)
					)
				)
			)
		)


class iso _TestFileReadError is UnitTest
	fun name(): String => "readAsString returning an error"

	fun apply(h: TestHelper) =>

		FileExtReader.readAsString(h.env, "some_file_does_not_exist.txt", {(fileStringIso:String iso, err: FileExtError val) =>
			match (err)
			| let errorString: String val =>
				h.env.out.print("readAsString ended with error: " + errorString.string())
			| None =>
				//This is a test document.
				let fileString:String ref = consume fileStringIso
				h.env.out.print("readAsString read: " + fileString)
	        end
		} val)

class iso _TestFileReadString is UnitTest
	fun name(): String => "readAsString"

	fun apply(h: TestHelper) =>

		FileExtReader.readAsString(h.env, "test.txt", {(fileStringIso:String iso, err: FileExtError val) =>
			match (err)
			| let errorString: String val =>
				h.env.out.print("readAsString ended with error: " + errorString.string())
			| None =>
				//This is a test document.
				let fileString:String ref = consume fileStringIso
				h.env.out.print("readAsString read: " + fileString)
	        end
		} val)

class iso _TestFileReadArray is UnitTest
	fun name(): String => "readAsArray"

	fun apply(h: TestHelper) =>

		FileExtReader.readAsArray(h.env, "test.txt", {(fileArrayIso:Array[U8] iso, err: FileExtError val) =>
			match (err)
			| let errorString: String val =>
				h.env.out.print("readAsArray ended with error: " + errorString.string())
			| None =>
				let fileArray:Array[U8] ref = consume fileArrayIso
				h.env.out.print("readAsArray read " + fileArray.size().string() + " bytes")
	        end
		} val)





class iso _TestFileWriteString is UnitTest


	fun name(): String => "writeString"

	fun apply(h: TestHelper) =>
				
		FileExtWriter.writeString(h.env, "/tmp/test.txt", "Hello, World!", {(err: FileExtError val) =>
			match (err)
			| let errorString: String val =>
				h.env.out.print("writeString ended with error: " + errorString.string())
			| None =>
				
			// Read the file back in and confirm it worked
			FileExtReader.readAsString(h.env, "/tmp/test.txt", {(fileStringIso:String iso, err: FileExtError val) =>
				if fileStringIso == "Hello, World!" then
					h.env.out.print("writeString completed successfully")
				else
					h.env.out.print("writeString/readAsString comparison failed")
				end
			} val)
				
	        end
		} val)

class iso _TestFileWriteArray is UnitTest
	fun name(): String => "readAsArray"

	fun apply(h: TestHelper) =>

		FileExtWriter.writeArray(h.env, "/tmp/test.txt", "Hello, World!".array(), {(err: FileExtError val) =>
			match (err)
			| let errorString: String val =>
				h.env.out.print("writeString ended with error: " + errorString.string())
			| None =>
			
			// Read the file back in and confirm it worked
			FileExtReader.readAsArray(h.env, "/tmp/test.txt", {(fileArrayIso:Array[U8] iso, err: FileExtError val) =>
				let fileString = String.from_iso_array(consume fileArrayIso)
				if fileString == "Hello, World!" then
					h.env.out.print("writeArray completed successfully")
				else
					h.env.out.print("writeArray/readAsArray comparison failed")
				end
			} val)
			
	        end
		} val)
