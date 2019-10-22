use "ponytest"

actor Main is TestList
	new create(env: Env) => PonyTest(env, this)
	new make() => None

	fun tag tests(test: PonyTest) =>
		test(_TestFileReadArray)
		test(_TestFileReadString)
		test(_TestFileReadError)
		test(_TestFileExtStreamer)

actor StreamCounter is Streamable
	var bytesRead:USize = 0
	let bytesExpected:USize
	let env:Env
	
	new create(env':Env, bytesExpected':USize) =>
		bytesExpected = bytesExpected'
		env = env'

	be receiveStream(fileArrayIso:Array[U8] iso) =>
		bytesRead = bytesRead + fileArrayIso.size()
		if fileArrayIso.size() == 0 then
			env.out.print("File stream completed, read " + bytesRead.string() + " of " + bytesExpected.string() + " bytes")
		end

class iso _TestFileExtStreamer is UnitTest
	fun name(): String => "read file as stream"

	fun apply(h: TestHelper) =>
		FileExtStreamer (h.env, "test_large.txt", 512, StreamCounter(h.env, 206051))


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

		