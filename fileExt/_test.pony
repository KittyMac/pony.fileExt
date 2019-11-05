use "ponytest"
use "files"

actor Main is TestList
	new create(env: Env) => PonyTest(env, this)
	new make() => None

	fun tag tests(test: PonyTest) =>
	/*
		test(_TestFileReadArray)
		test(_TestFileReadString)
		test(_TestFileReadByteBlock)
		test(_TestFileReadError)
		*/
		test(_TestFileWriteArray)
		test(_TestFileWriteString)
		test(_TestFileWriteByteBlock)
		
		//test(_TestFileExtFlowing)


// ******************* Non-Streaming Tests *******************

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

class iso _TestFileReadByteBlock is UnitTest
	fun name(): String => "readAsByteBlock"

	fun apply(h: TestHelper) =>

		FileExtReader.readAsByteBlock(h.env, "test.txt", {(fileByteBlockIso:ByteBlock iso, err: FileExtError val) =>
			match (err)
			| let errorString: String val =>
				h.env.out.print("readAsByteBlock ended with error: " + errorString.string())
			| None =>
				let fileByteBlock:ByteBlock ref = consume fileByteBlockIso
				h.env.out.print("readAsByteBlock read " + fileByteBlock.size().string() + " bytes")
	        end
		} val)

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



class iso _TestFileWriteArray is UnitTest
	fun name(): String => "writeAsArray"

	fun apply(h: TestHelper) =>

		FileExtWriter.writeArray(h.env, "/tmp/test1.txt", "Hello, World!".array(), {(err: FileExtError val) =>
			match (err)
			| let errorString: String val =>
				h.env.out.print("writeString ended with error: " + errorString.string())
			| None =>
			
			// Read the file back in and confirm it worked
			FileExtReader.readAsArray(h.env, "/tmp/test1.txt", {(fileArrayIso:Array[U8] iso, err: FileExtError val) =>
				let fileString = String.from_iso_array(consume fileArrayIso)
				if fileString == "Hello, World!" then
					h.env.out.print("writeArray completed successfully")
				else
					h.env.out.print("writeArray/readAsArray comparison failed")
				end
			} val)
			
	        end
		} val)

class iso _TestFileWriteString is UnitTest


	fun name(): String => "writeString"

	fun apply(h: TestHelper) =>
		
		FileExtWriter.writeString(h.env, "/tmp/test2.txt", "Hello, World!", {(err: FileExtError val) =>
			match (err)
			| let errorString: String val =>
				h.env.out.print("writeString ended with error: " + errorString.string())
			| None =>
		
			// Read the file back in and confirm it worked
			FileExtReader.readAsString(h.env, "/tmp/test2.txt", {(fileStringIso:String iso, err: FileExtError val) =>
				if fileStringIso == "Hello, World!" then
					h.env.out.print("writeString completed successfully")
				else
					h.env.out.print("writeString/readAsString comparison failed")
				end
			} val)
		
	        end
		} val)

class iso _TestFileWriteByteBlock is UnitTest
	fun name(): String => "writeAsByteBlock"

	fun apply(h: TestHelper) =>
	
		let bb = recover val 
			let b = ByteBlock(14)
			b.set('A')
			b
		end
		
		FileExtWriter.writeByteBlock(h.env, "/tmp/test3.txt", bb, {(err: FileExtError val) =>
			match (err)
			| let errorString: String val =>
				h.env.out.print("writeString ended with error: " + errorString.string())
			| None =>
	
			// Read the file back in and confirm it worked
			FileExtReader.readAsByteBlock(h.env, "/tmp/test3.txt", {(fileByteBlockIso:ByteBlock iso, err: FileExtError val) =>
				let fileString = fileByteBlockIso.string()
				if fileString == "AAAAAAAAAAAAAA" then
					h.env.out.print("writeByteBlock completed successfully")
				else
					h.env.out.print("writeByteBlock/readAsByteBlock comparison failed")
				end
			} val)
	
	        end
		} val)

// ********************************************************

class iso _TestFileExtFlowing is UnitTest
	fun name(): String => "read file as stream"
	
	
	
	fun apply(h: TestHelper) =>	
	/*
		try
			var inFilePath = FilePath(h.env.root as AmbientAuth, "test_large.txt", FileCaps.>all())?
			var outFilePath = FilePath(h.env.root as AmbientAuth, "/tmp/test_large.txt", FileCaps.>all())?
			FileExtFlowReader(inFilePath, 512,
				FileExtFlowWriter(outFilePath, FileExtFlowEnd)
			)
		end
	*/
		
		try
			let callback = object val is FlowFinished
				fun flowFinished() =>
					h.env.out.print("Flow finished!")
					true
			end
			
			var inFilePath = FilePath(h.env.root as AmbientAuth, "test_large.txt", FileCaps.>all())?
			var outFilePath = FilePath(h.env.root as AmbientAuth, "/tmp/test_large.txt", FileCaps.>all())?
			
			FileExtFlowReader(inFilePath, 512,
				FileExtFlowPassthru(
					FileExtFlowByteCounter(
						FileExtFlowPassthru(
							FileExtFlowWriter(outFilePath,
								FileExtFlowByteCounter(
									FileExtFlowFinished(callback, FileExtFlowEnd)
								)
							)
						)
					)
				)
			)
		end
