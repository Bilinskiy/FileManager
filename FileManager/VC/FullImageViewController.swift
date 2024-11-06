//
//  FullImageViewController.swift
//  FileManager
//
//  Created by Дмитрий Билинский on 28.10.24.
//

import UIKit
import SnapKit

class FullImageViewController: UIViewController {
   
  var arrayImage: [UIImage] = []

  static let key = "FullImageViewController"
  
  lazy var scrollView: UIScrollView = {
    var scroll = UIScrollView()
    scroll.showsHorizontalScrollIndicator = false
    scroll.showsVerticalScrollIndicator = false
 
    scroll.minimumZoomScale = 1
    scroll.maximumZoomScale = 5
    
    scroll.isPagingEnabled = true
    scroll.delegate = self
    scroll.addSubview(containerScrollStackView)
    return scroll
  }()
  
  lazy var containerScrollStackView: UIStackView = {
    var stack = UIStackView()
    stack.distribution = .fillEqually
    stack.axis = .horizontal
    stack.spacing = 0
    return stack
  }()
  
    override func viewDidLoad() {
        super.viewDidLoad()
      view.backgroundColor = .colorBackground
      
      view.addSubview(scrollView)

      for image in arrayImage {
        let imageStack = UIImageView()
        imageStack.contentMode = .scaleAspectFit
        imageStack.image = image
        containerScrollStackView.addArrangedSubview(imageStack)
        
        imageStack.snp.makeConstraints { make in
          make.width.equalTo(view)
        }
      }

      updateViewConstraints()
    }
  
  override func updateViewConstraints() {
    super.updateViewConstraints()
    
    scrollView.snp.makeConstraints { make in
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
      make.top.equalToSuperview()
      make.bottom.equalToSuperview()
    }
    
    containerScrollStackView.snp.makeConstraints { make in
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
      make.top.equalToSuperview()
      make.bottom.equalToSuperview()
      make.height.equalToSuperview()

    }
  }

}

extension FullImageViewController: UIScrollViewDelegate {  
  func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    containerScrollStackView
  }
}
