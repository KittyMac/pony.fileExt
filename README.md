# pony.fileExt

**WARNING: [THIS ONLY WORKS WITH MY FORK OF PONY](https://github.com/KittyMac/ponyc/tree/roc)**

### Purpose

This repository is just me hacking around with [Pony](https://www.ponylang.io). It should not be used as an example of good Pony programming practices.

### Why does this require a forked Pony?

As I understand it, the way memory management in Pony works is it will allocate (from the operating system) as much memory as your program needs while it is running.  However, it will **never** return that memory to the operating system even after your program has properly allowed all of its allocations to be disposed of (ie when the garbage collector "frees" memory from a garbage collected object, the gc keeps holding on to that memory and never releases it).  This means that your Pony program will always retain the maximum amount of memory it has used at any point in its execution.

When attempting to stream large amounts of data, memory spikes can lead to your program holding on to many more operating system resources than it actually needs.

To combat this, I have written a ByteBlock class in the Pony collections package. A ByteBlock is a non-resizeable chunk of memory which exists outside of the context of the garbage collector (ie it is just malloc'd and free'd). This is them used by the streaming actors here to allow large chunks of memory to be passed around and cleaned up immediately when they are done being used. This avoids the "memory bloat" described above.

### Streaming reading and writing

For optimal usage you should use the Streamable interface. This will process data in chunks, with each chunk calling one behaviour on the actor. This should allow for optimal scheduling in Pony, as we're not blocking on super large IO operations.

The Streamable interface support chaining modules together. For example, you can combine chain the file stream reader to the [bzip2 stream decompressor](https://github.com/KittyMac/pony.bzip2) and the file stream writer very simply.

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