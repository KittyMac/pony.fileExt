# pony.fileExt

### Purpose

Note: This repository is just me hacking around with [Pony](https://www.ponylang.io). It should not be used as an example of good Pony programming practices.

The purpose of this library is to provide one line solutions for reading and writing data to files, concurrently using actors, either all in one or streaming solutions using the [pony.flow](https://github.com/KittyMac/pony.flow) library.

### Streaming reading and writing

For optimal usage you should use the Flow interface. This will process data in chunks, with each chunk calling one behaviour on the actor. This should allow for optimal scheduling in Pony, as we're not blocking on super large IO operations.

The Flow interface supports chaining modules together generically. For example, you can combine chain the file stream reader to the [bzip2 stream decompressor](https://github.com/KittyMac/pony.bzip2) and the file stream writer very simply.

```
FileExtStreamReader(h.env, "test_large.bz2", 1024*1024*16,
	BZ2StreamDecompress(h.env,
		FileExtStreamWriterEnd(h.env, "/tmp/test_bzip_decompress.txt")
	)
)
```


### One shot reading and writing

Note that this is synchronous IO in the actor, so reading or writing large files will cause the actor block while it waits on the file system to deliver.

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
FileExtReader.readAsArray(h.env, "test.txt", {(fileArrayIso:ByteBlock iso, err: FileExtError val) =>
		match (err)
		| let errorString: String val =>
			h.env.out.print("readAsArray ended with error: " + errorString.string())
		| None =>
			let fileArray:ByteBlock ref = consume fileArrayIso
			h.env.out.print("readAsArray read " + fileArray.size().string() + " bytes")
	    end
	} val)
```


## License

pony.fileExt is free software distributed under the terms of the MIT license, reproduced below. pony.fileExt may be used for any purpose, including commercial purposes, at absolutely no cost. No paperwork, no royalties, no GNU-like "copyleft" restrictions. Just download and enjoy.

Copyright (c) 2019 Rocco Bowling

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.