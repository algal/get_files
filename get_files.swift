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

// public func fetchFiles(path: Path, recurse: Bool = false, extensions: [String]? = nil) -> [Path] {
//     var res: [Path] = []
//     for p in try! path.ls(){
//         if p.kind == .directory && recurse { 
//             res += fetchFiles(path: p.path, recurse: recurse, extensions: extensions)
//         } else if extensions == nil || extensions!.contains(p.path.extension.lowercased()) {
//             res.append(p.path)
//         }
//     }
//     return res
// }

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

  var result:[URL] = []
  for  p in ee {
      result.append(p as! URL)
  }
//  let result = ee.allObjects as! [URL]
  
  return result
}



print("Hello, world!")

// time(repeating:10) {
//     let images = fetchFiles(path:datapath,recurse:true,extensions:["jpeg","jpg"])
//     print("images.count = \(images.count)")
// }

let p:String = CommandLine.arguments[1]
let u = URL.init(fileURLWithPath:p)

time(repeating:10) {
    let images = recursiveContentsOfDirectoryAtURL(u)
    print("images.count = \(images.count)")
}
