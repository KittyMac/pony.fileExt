# pony.fileExt

Some extensions to simplify File IO for Pony

```
FileExtReader.readAsString(h.env, "test.txt", {(fileStringIso:String iso, err: FileExtError val) =>
			match (err)
			| let errorString: String val =>
				h.env.out.print("readAsString ended with error: " + errorString.string())
			| None =>
				let fileString:String ref = consume fileStringIso
				h.env.out.print("readAsString read: " + fileString)
	        end
		} val)
```

```
FileExtReader.readAsArray(h.env, "test.txt", {(fileArrayIso:Array[U8] iso, err: FileExtError val) =>
			match (err)
			| let errorString: String val =>
				h.env.out.print("readAsArray ended with error: " + errorString.string())
			| None =>
				let fileArray:Array[U8] ref = consume fileArrayIso
				h.env.out.print("readAsArray read " + fileArray.size().string() + " bytes")
	        end
		} val)
```