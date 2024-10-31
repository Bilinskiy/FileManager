//
//  FolderCollectionViewCell.swift
//  FileManager
//
//  Created by Дмитрий Билинский on 30.10.24.
//

import UIKit
import SnapKit

class FolderCollectionViewCell: UICollectionViewCell {
    
  static let key = "FolderCollectionViewCell"
  
  lazy var imageFolder: UIImageView = {
    var image =  UIImageView(image: UIImage(systemName: "folder"))
    image.contentMode = .scaleAspectFit
    image.tintColor = .black
    return image
  }()
  
  lazy var nameFolderLabel: UILabel = {
    var label = UILabel()
    label.textColor = .black
    label.font = UIFont.systemFont(ofSize: 10, weight: .semibold)
    label.textAlignment = .center
  
    return label
  }()
  
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    contentView.backgroundColor = .lightGray
    contentView.layer.cornerRadius = 35
    contentView.addSubview(imageFolder)
    contentView.addSubview(nameFolderLabel)
    
    updateConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  override func updateConstraints() {
    super.updateConstraints()
    
    imageFolder.snp.makeConstraints { make in
      make.width.equalTo(25)
      make.height.equalTo(25)
      make.centerX.equalToSuperview()
      make.centerY.equalToSuperview().offset(-8)
    }
    
    nameFolderLabel.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(self.imageFolder.snp.bottom)
      make.leading.equalToSuperview().inset(2)
      make.trailing.equalToSuperview().inset(2)

    }
  }
  
}
