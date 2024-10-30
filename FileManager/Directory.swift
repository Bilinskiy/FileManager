//
//  Directory.swift
//  FileManager
//
//  Created by Дмитрий Билинский on 29.10.24.
//

import Foundation

enum TypeDirectory {
  case image
  case folder
}

struct Directory {
  
  private(set) var type: TypeDirectory
  private(set) var arrayURL: [URL]
  
  mutating func appendNewFile(_ URL: URL) {
    arrayURL.append(URL)
  }
  
}


