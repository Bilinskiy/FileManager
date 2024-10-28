//
//  ManagerFile.swift
//  FileManager
//
//  Created by Дмитрий Билинский on 25.10.24.
//

import Foundation

protocol ManagerFileProtocol {
  var fileManager: FileManager {get}
  var currentCatalog: URL {get set}
  func createFolder(_ nameFolder: String) -> Bool
  func directoryContent() -> [URL]
  func addImage(URL: String, data: Data?)
}

class ManagerFile: ManagerFileProtocol {
  
  var fileManager = FileManager.default
  var currentCatalog = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
  
  func createFolder(_ nameFolder: String) -> Bool {
    let newFolder = currentCatalog.appending(path: nameFolder)
    
    do {
      try fileManager.createDirectory(at: newFolder, withIntermediateDirectories: false)
      return false
    } catch {
      return true
    }
  }
  
  func directoryContent() -> [URL] {
    do {
      let directoryContent = try fileManager.contentsOfDirectory(at: currentCatalog, includingPropertiesForKeys: nil).filter({$0.lastPathComponent != ".DS_Store"})
      return directoryContent
    } catch {
        fatalError()
    }
    
  }
  
  func addImage(URL: String, data: Data?) {
    let newImageURL = currentCatalog.appending(path: URL)

    do {
      try data?.write(to: newImageURL)
    } catch {
      fatalError()
    }
    
  }
  
}
