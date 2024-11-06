//
//  FullImageViewController.swift
//  FileManager
//
//  Created by Дмитрий Билинский on 28.10.24.
//

import UIKit
import SnapKit

class FullImageViewController: UIViewController {

  static let key = "FullImageViewController"
  
  lazy var imageView: UIImageView = {
    var image = UIImageView()
    image.contentMode = .scaleAspectFit
    return image
  }()
  
    override func viewDidLoad() {
        super.viewDidLoad()
      view.backgroundColor = .colorBackground
      
      view.addSubview(imageView)

      updateViewConstraints()
    }
  
  override func updateViewConstraints() {
    super.updateViewConstraints()
    
    imageView.snp.makeConstraints { make in
      make.width.equalTo(view.frame.width)
      make.centerX.equalToSuperview()
      make.centerY.equalToSuperview()
    }
  }

}
