//
//  ManagerFile.swift
//  FileManager
//
//  Created by Дмитрий Билинский on 25.10.24.
//

import Foundation

protocol ManagerFileProtocol {
  var content: [Directory] {get set}
  var fileManager: FileManager {get}
  var currentCatalog: URL {get set}
  func createFolder(_ nameFolder: String) -> URL?
  func fetchDirectoryContent()
  func addImage(URL: String, data: Data?)
  func filterContent(_ type: TypeDirectory) -> [URL]
}

class ManagerFile: ManagerFileProtocol {
 
  var content: [Directory] = []
  var fileManager = FileManager.default
  var currentCatalog = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

  func filterContent(_ type: TypeDirectory) -> [URL]  {
    return content.filter({$0.type == type})[0].arrayURL
  }

  func createFolder(_ nameFolder: String) -> URL? {
    let newFolder = currentCatalog.appending(path: nameFolder)
    
    do {
      try fileManager.createDirectory(at: newFolder, withIntermediateDirectories: false)
    } catch {
      return nil
    }
    
    return newFolder
  }

  func fetchDirectoryContent() {
    do {
      let directoryContent = try fileManager.contentsOfDirectory(at: currentCatalog, includingPropertiesForKeys: nil).filter({$0.lastPathComponent != ".DS_Store"})
      content.removeAll()
      content.append(Directory(type: .folder, arrayURL: directoryContent.filter({$0.hasDirectoryPath})))
      content.append(Directory(type: .image, arrayURL:  directoryContent.filter({!$0.hasDirectoryPath})))
      print (currentCatalog)
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
