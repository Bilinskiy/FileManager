//
//  HeaderCollectionView.swift
//  FileManager
//
//  Created by Дмитрий Билинский on 30.10.24.
//

import UIKit
import SnapKit

class HeaderCollectionView: UICollectionReusableView {
       
  static let key = "HeaderCollectionView"
  
  lazy var nameHeaderLabel: UILabel = {
    var label = UILabel()
    label.font = label.font.withSize(16)
    label.textColor = .colorHeaderCollection
    return label
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.addSubview(nameHeaderLabel)
    updateConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func updateConstraints() {
    super.updateConstraints()
    
    nameHeaderLabel.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.leading.equalToSuperview().offset(16)
    }
  }
  
}
