//
//  FolderTableViewCell.swift
//  FileManager
//
//  Created by Дмитрий Билинский on 25.10.24.
//

import UIKit

class FolderTableViewCell: UITableViewCell {
  
  static let key = "FolderTableViewCell"

  lazy var imageFolder: UIImageView = {
    var image =  UIImageView(image: UIImage(systemName: "folder"))
    image.contentMode = .scaleAspectFit
    image.tintColor = .colorNavBar
    return image
  }()
  
  lazy var nameFolderLabel: UILabel = {
    var label = UILabel()
    label.textColor = .colorLabel
    return label
  }()
  
    override func awakeFromNib() {
        super.awakeFromNib()
      
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
      
      contentView.backgroundColor = selected ?  .red : .bgColorFolderCollection
      
      contentView.addSubview(imageFolder)
      contentView.addSubview(nameFolderLabel)

      updateConstraints()
    }
  
  
  override func updateConstraints() {
    super.updateConstraints()
    
    imageFolder.snp.makeConstraints { make in
      make.width.equalTo(30)
      make.height.equalTo(30)
      make.centerY.equalToSuperview()
      make.leading.equalToSuperview().inset(16)
    }
    
    nameFolderLabel.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.leading.equalTo(imageFolder.snp.trailing).inset(-8)
    }
    
  }
    
}
