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
    image.tintColor = .colorNavBar
    return image
  }()
  
  lazy var nameFolderLabel: UILabel = {
    var label = UILabel()
    label.textColor = .colorLabel
    label.font = label.font.withSize(16)
    label.textAlignment = .center
    label.numberOfLines = 2
    return label
  }()
  
  override var isSelected: Bool {
    didSet {
      contentView.backgroundColor = isSelected ? .red : .bgColorFolderCollection
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    contentView.backgroundColor = .bgColorFolderCollection
    contentView.layer.cornerRadius = 15
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
      make.centerY.equalToSuperview().offset(-16)
    }
    
    nameFolderLabel.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(self.imageFolder.snp.bottom).offset(8)
      make.leading.equalToSuperview().inset(2)
      make.trailing.equalToSuperview().inset(2)

    }
  }
  
}
