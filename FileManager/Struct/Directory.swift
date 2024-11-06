//
//  Directory.swift
//  FileManager
//
//  Created by Дмитрий Билинский on 29.10.24.
//

import Foundation

enum TypeDirectory: Int {
  case folder = 0
  case image = 1
}

struct Directory {
  
  private(set) var type: TypeDirectory
  private(set) var arrayURL: [URL]
  
  mutating func appendNewFile(_ URL: URL) {
    arrayURL.append(URL)
  }
  
  mutating func removeFile(_ URL: URL) {
    arrayURL = arrayURL.filter({$0 != URL})
  }
  
}


