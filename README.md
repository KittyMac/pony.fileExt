# pony.fileExt

Some extensions to simplify File IO for Pony.

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