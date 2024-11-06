//
//  ImageTableViewCell.swift
//  FileManager
//
//  Created by Дмитрий Билинский on 27.10.24.
//

import UIKit
import SnapKit

class ImageTableViewCell: UITableViewCell {

  static let key = "ImageTableViewCell"
  
  lazy var image: UIImageView = {
    var image = UIImageView()
    image.contentMode = .scaleAspectFill
    image.layer.masksToBounds = true
    image.layer.cornerRadius = 15
    return image
  }()
  
    override func awakeFromNib() {
        super.awakeFromNib()
     
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

      contentView.backgroundColor = selected ?  .red : .clear
      
      contentView.addSubview(image)
 
      updateConstraints()
    }
  
  override func updateConstraints() {
    super.updateConstraints()
    
    image.snp.makeConstraints { make in
      make.width.equalTo(60)
      make.height.equalTo(30)
      make.centerY.equalToSuperview()
      make.leading.equalToSuperview().inset(16)
    }
  }

}
