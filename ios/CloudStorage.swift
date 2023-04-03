import Foundation

@objc(CloudStorage)
class CloudStorage: NSObject {
  @objc(fileExists:withScope:withResolver:withRejecter:)
  func fileExists(path: String, scope: String, resolve:RCTPromiseResolveBlock,reject:RCTPromiseRejectBlock) -> Void {
    let fileManager = FileManager.default
    let directory = getDirectory(scope)
    if (directory == nil) {
      reject("ERR_NO_DIRECTORY_FOUND", "No directory found for scope \(scope)", nil)
      return
    }
    let filePath = directory?.appendingPathComponent(path)
    let fileExists = fileManager.fileExists(atPath: filePath!.path)
    resolve(fileExists)
  }

  @objc(createFile:withData:withScope:withOverwrite:withResolver:withRejecter:)
  func createFile(path: String, data: String, scope: String, overwrite: Bool, resolve:RCTPromiseResolveBlock,reject:RCTPromiseRejectBlock) -> Void {
    let fileManager = FileManager.default
    let directory = getDirectory(scope)
    if (directory == nil) {
      reject("ERR_NO_DIRECTORY_FOUND", "No directory found for scope \(scope)", nil)
      return
    }
    let filePath = directory?.appendingPathComponent(path)
    let fileExists = fileManager.fileExists(atPath: filePath!.path)
    if (fileExists && !overwrite) {
      reject("ERR_FILE_EXISTS", "File \(path) already exists", nil)
      return
    }
    do {
      try data.write(to: filePath!, atomically: true, encoding: .utf8)
      resolve(true)
    } catch {
      reject("ERR_WRITE_ERROR", "Error writing file \(path)", error)
    }
  }

  @objc(readFile:withScope:withResolver:withRejecter:)
  func readFile(path: String, scope: String, resolve:RCTPromiseResolveBlock,reject:RCTPromiseRejectBlock) -> Void {
    let fileManager = FileManager.default
    let directory = getDirectory(scope)
    if (directory == nil) {
      reject("ERR_NO_DIRECTORY_FOUND", "No directory found for scope \(scope)", nil)
      return
    }
    let filePath = directory?.appendingPathComponent(path)
    let fileExists = fileManager.fileExists(atPath: filePath!.path)
    if (!fileExists) {
      reject("ERR_FILE_NOT_FOUND", "File \(path) not found", nil)
      return
    }
    do {
      let fileContents = try String(contentsOf: filePath!, encoding: .utf8)
      resolve(fileContents)
    } catch {
      reject("ERR_READ_ERROR", "Error reading file \(path)", error)
    }
  }

  /// Returns the iCloud directory URL for the given scope.
  ///
  /// - Parameter scope: The scope of the directory. Can be either "visible" or "hidden".
  /// - Returns: The URL of the iCloud directory.
  private func getDirectory(_ scope: String) -> URL? {
    let fileManager = FileManager.default
    let isDocumentDirectory = scope.caseInsensitiveCompare("visible") == .orderedSame
    let ubiquityURL = fileManager.url(forUbiquityContainerIdentifier: nil)
    if (isDocumentDirectory) {
      return fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
    } else {
      return ubiquityURL
    }
  }
}
