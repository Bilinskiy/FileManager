//
//  ImageCollectionViewCell.swift
//  FileManager
//
//  Created by Дмитрий Билинский on 30.10.24.
//

import UIKit
import SnapKit

class ImageCollectionViewCell: UICollectionViewCell {
    
  static let key = "ImageCollectionViewCell"

  lazy var image: UIImageView = {
    var image = UIImageView()
    image.contentMode = .scaleAspectFill
    image.layer.masksToBounds = true
    image.layer.cornerRadius = 50
    return image
  }()
  
  override var isSelected: Bool {
    didSet {
  
      image.layer.borderColor = isSelected ? UIColor.red.cgColor : UIColor.clear.cgColor
      image.layer.borderWidth = isSelected ? 4 : 0
      
    }
  }
  
  override init(frame: CGRect) {
    super .init(frame: frame)
    
    contentView.backgroundColor = .black
    contentView.layer.cornerRadius = 50
    contentView.addSubview(image)
    
    updateConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func updateConstraints() {
    super.updateConstraints()
    
    image.snp.makeConstraints { make in
      make.width.equalTo(contentView.frame.width)
      make.height.equalTo(contentView.frame.height)
      make.centerY.equalToSuperview()
      make.centerX.equalToSuperview()
    }
  }
  
}
