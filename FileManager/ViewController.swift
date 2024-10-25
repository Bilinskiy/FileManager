//
//  ViewController.swift
//  FileManager
//
//  Created by Дмитрий Билинский on 24.10.24.
//

import UIKit
import SnapKit

class ViewController: UIViewController {

  lazy var tableView: UITableView = {
    var table = UITableView()
    table.rowHeight = 40
    table.layer.cornerRadius = 15
    table.dataSource = self
    table.delegate = self
    return table
  }()
  
  lazy var rightBarButtonPlusFolder: UIBarButtonItem = {
    var button = UIBarButtonItem(image: UIImage(systemName: "folder.badge.plus"), style: .plain, target: self, action: #selector(plusFolder))
    return button
  }()
  

  
  override func viewDidLoad() {
    super.viewDidLoad()
 
    view.backgroundColor = .white
    settingsNavigationController()
    
    view.addSubview(tableView)
    
    updateViewConstraints()
  }
  
  @objc func plusFolder() {
    print ("plus folder")
  }
  
  func settingsNavigationController () {
    navigationItem.title = "Просмотр каталога"
    navigationItem.rightBarButtonItems = [rightBarButtonPlusFolder]
    navigationController?.navigationBar.tintColor = .black
    
    navigationController?.navigationBar.scrollEdgeAppearance = UINavigationBarAppearance()
    navigationController?.navigationBar.scrollEdgeAppearance?.backgroundColor = .orange
   
  }
  
  override func updateViewConstraints() {
    super.updateViewConstraints()

    tableView.snp.makeConstraints { make in
      make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).inset(16)
      make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
      make.leading.equalToSuperview().inset(16)
      make.trailing.equalToSuperview().inset(16)

    }
    
  }


}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    8
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return UITableViewCell()
  }
  
  
  
  
  
  
}

