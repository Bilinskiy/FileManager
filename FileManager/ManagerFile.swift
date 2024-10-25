//
//  ManagerFile.swift
//  FileManager
//
//  Created by Дмитрий Билинский on 25.10.24.
//

import Foundation

protocol ManagerFileProtocol {
  func createFolder(_ nameFolder: String) -> Bool
  func directoryContent() -> [URL]
}

class ManagerFile: ManagerFileProtocol {
  
  let fileManager = FileManager.default

  func createFolder(_ nameFolder: String) -> Bool {
    let currentCatalog = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let newFolder = currentCatalog.appending(path: nameFolder)
    
    do {
      try fileManager.createDirectory(at: newFolder, withIntermediateDirectories: false)
      return false
    } catch {
      return true
    }
  }
  
  func directoryContent() -> [URL] {
    let currentCatalog = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    do {
      let directoryContent = try fileManager.contentsOfDirectory(at: currentCatalog, includingPropertiesForKeys: nil)
      return directoryContent.filter({$0.lastPathComponent != ".DS_Store"})
    } catch {
        fatalError("Unable to read directory")
    }
    
  }
  
}
