//
//  TableViewCell.swift
//  FileManager
//
//  Created by Дмитрий Билинский on 25.10.24.
//

import UIKit

class TableViewCell: UITableViewCell {
  
  static let key = "TableViewCell"

  lazy var imageFolder: UIImageView = {
    var image =  UIImageView(image: UIImage(systemName: "folder"))
    image.frame = CGRect(x: 0, y: 0, width: 36, height: 36)
    image.tintColor = .black
    return image
  }()
  
  lazy var nameFolderLabel: UILabel = {
    var label = UILabel()
    label.textColor = .black
    return label
  }()
  
    override func awakeFromNib() {
        super.awakeFromNib()
      
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

      contentView.addSubview(imageFolder)
      contentView.addSubview(nameFolderLabel)

      updateConstraints()
    }
  
  
  override func updateConstraints() {
    super.updateConstraints()
    
    imageFolder.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.leading.equalToSuperview()
    }
    
    nameFolderLabel.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.leading.equalTo(imageFolder.snp.trailing).inset(-8)
    }
    
  }
    
}
