import Foundation
import Dispatch

// ⏰Time how long it takes to run the specified function, optionally taking
// the average across a number of repetitions.
public func time(repeating: Int = 1, _ f: () -> ())
{
    guard repeating > 0 else { return }
    
    // Warmup
    if repeating > 1 { f() }
    
    var times = [Double]()
    for _ in 1...repeating {
        let start = DispatchTime.now()
        f()
        let end = DispatchTime.now()
        let nanoseconds = Double(end.uptimeNanoseconds - start.uptimeNanoseconds)
        let milliseconds = nanoseconds / 1e6
        times.append(milliseconds)
    }
    print("average: \(times.reduce(0.0, +)/Double(times.count)) ms,   " +
          "min: \(times.reduce(times[0], min)) ms,   " +
          "max: \(times.reduce(times[0], max)) ms")
}

public extension FileManager {
  /// Returns true if file exists and is a directory
  func fileExistsAndIsDirectory(_ file:URL) -> Bool {
    var isDirectory:ObjCBool = false
    let doesExist = self.fileExists(atPath: file.path, isDirectory: &isDirectory)
    return doesExist && isDirectory.boolValue
  }
}

/**
 Lists recursive contents of file URL `directoryURL`.
 
 Returns empty array if:
 - `directoryURL` is not an existing directory
 - there were internal errors
 
 */
public func recursiveContentsOfDirectoryAtURL(_ directoryURL:URL) -> [URL]
{
  let fm = FileManager.default
  
  guard fm.fileExistsAndIsDirectory(directoryURL) == true else {
    print("recursiveContentsOfDirectoryAtURL: passed a directoryURL which is not an existing directory")
    return []
  }
  
  let e = fm.enumerator(at: directoryURL, includingPropertiesForKeys: [URLResourceKey.nameKey], options: [], errorHandler: nil)
  guard let ee = e else {
    print("failed to build directory enumerator")
    return []
  }

  let result = ee.allObjects as! [URL]
  return result
}

print("""
        I will read the first command line argument, interpret it as a path to a directory,
        recursively search the names of all files and directories under that directory,
        and print the number of items found.

        In fact, I will do this ten times and then print stats on how fast this happened.

        I have no dependencies. I do all of this using the built-in libraries, Foundation and Dispatch
""")

let p:String = CommandLine.arguments[1]
let u = URL(fileURLWithPath:p)

time(repeating:10) {
    let filesFound = recursiveContentsOfDirectoryAtURL(u)
    print(filesFound.count)
}
