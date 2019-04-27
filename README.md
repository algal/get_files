# Fast Swift file enumeration on Linux?

This directory contains two files I used to make an _extremely crude_ measure of the speed of recursively enumerating a large numbers of files on Linux, comparing Python3 versus Swift for TensorFlow.

This [for the FastAI library](https://forums.fast.ai/t/fast-file-enumeration-in-swift/44709).

Both scripts here take a single command line argument, which should be a directory path, and then count all files under that path. The swift script does this ten times and times itself.

The Python script `get_files.py` has a function extracted from the fastai library. This is based on `os.walk`.

The Swift script `get_files.swift` has an implementation based on the Foundation method `enumerator(at url: URL, includingPropertiesForKeys keys: [URLResourceKey]?, options mask: FileManager.DirectoryEnumerationOptions = [], errorHandler handler: ((URL, Error) -> Bool)? = nil) -> FileManager.DirectoryEnumerator?`. This is probably the method that one is supposed to use for a fast recursive enumeration. I have not checked other methods like `contentsOfDirectory(atPath:)`, which don't handle the recursion for you but might be faster.


## How to run

To run the Python:

```
python3 get_files.py /path/to/a/directory/
```

To run the Swift:

```
swiftc -O get_files.swift && ./get_files /path/to/a/directory/
```


## Findings

I've been getting very inconsistent results, in tests pointing both scripts at the collection 13,394 imagenette files.

In my most recent tests, the Python script is faster on both macOS and Linux. 

In earlier tests, Python was faster on Linux and Swift was faster on the mac. In that earlier test, this
is what I found:

- On macOS, the Swift implementation is faster than the fastai Python one.
- On Linux, the fastai Python one is faster than the Swift one.
- The Linux Swift implementation is based on `fts_open` API [source code](https://github.com/apple/swift-corelibs-foundation/blob/9678f2d4dc914355108c09b3732da8bcce647c3b/Foundation/FileManager%2BPOSIX.swift). This seems to be a piece of BSD-originated API which is also available on Linux.
- The Python implementation is due to `os.walk` being fast, which is based on `scandir`. [source code](https://github.com/python/cpython/blob/3.7/Lib/os.py)
- Also, in the fastai_docs version of `fetchFiles` (not included here), which uses mxcl's Path library, and which is not included here, the  `Path.Path()` initializer adds significant overhead (~33%).

So what is going on here?

My guess: maybe `scandir` is fast on Linux, and `fts_open` etc is fast on macOS. So to get a faster file enumeration in Swift on Linux, one should just wrap scandir instead of relying on Foundatin which wraps `fts_open`. Or we should update the Swift Foundation implementation to use scandir on Linux.

## Logs 
### measures

Runs on Linux:

```
(swift-tensorflow) alexis@topobigbox:~/fetchFilesFaster/PythonVersion$ time python3 get_files.py ../testData/imagenette-160
13394

real	0m0.125s
user	0m0.113s
sys	0m0.013s
(swift-tensorflow) alexis@topobigbox:~/fetchFilesFaster/PythonVersion$ ./get_files ../testData/imagenette-160
Hello, world!
images.count = 13416
images.count = 13416
images.count = 13416
images.count = 13416
images.count = 13416
images.count = 13416
images.count = 13416
images.count = 13416
images.count = 13416
images.count = 13416
images.count = 13416
average: 260.3321267 ms,   min: 258.313183 ms,   max: 270.064363 ms
```

Runs on macOS:

```
⋊> ~/w/f/f/PythonVersion ./get_files ../testData/imagenette-160/
Hello, world!
images.count = 13416
images.count = 13416
images.count = 13416
images.count = 13416
images.count = 13416
images.count = 13416
images.count = 13416
images.count = 13416
images.count = 13416
images.count = 13416
images.count = 13416
average: 62.5279228 ms,   min: 60.785797 ms,   max: 65.018292 ms
⋊> ~/w/f/f/PythonVersion time python3 get_files.py ../testData/imagenette-160/

I will read the first command line argument, interpret it as a path to a directory,
recursively search the names of all files and directories under that directory,
and print the number of items found.

I do this once.

I need python3. I have been extracted from the fastai_docs library as of 2019-04-26T2331.


13394
        0.13 real         0.10 user         0.02 sys
```
        
### 2019-04-27T1155 measures

```
⋊> ~/w/f/f/PythonVersion on master ⨯ python3 get_files.py ../testData/imagenette-160/

I will read the first command line argument, interpret it as a path to a directory,
recursively search the names of all files and directories under that directory,
and print the number of items found.

I do this ten times. I have no external dependencies beyond Python3.

I need python3. I have been extracted from the fastai_docs library as of 2019-04-26T2331.


13394
13394
13394
13394
13394
13394
13394
13394
13394
13394
iterations: 10
min time: 86.295175 ms
⋊> ~/w/f/f/PythonVersion on master ⨯ swiftc -O get_files.swift && ./get_files ../testData/imagenette-160/
        I will read the first command line argument, interpret it as a path to a directory,
        recursively search the names of all files and directories under that directory,
        and print the number of items found.

        In fact, I will do this ten times and then print stats on how fast this happened.

        I have no dependencies. I do all of this using the built-in libraries, Foundation and Dispatch
13416
13416
13416
13416
13416
13416
13416
13416
13416
13416
13416
average: 135.494526 ms,   min: 127.906133 ms,   max: 144.145931 ms
```
