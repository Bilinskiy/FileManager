//
//  ViewController.swift
//  FileManager
//
//  Created by Дмитрий Билинский on 24.10.24.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    
  let fileManager: ManagerFileProtocol = ManagerFile()
  
  lazy var tableView: UITableView = {
    var table = UITableView()
    table.rowHeight = 40
    table.layer.cornerRadius = 15
    let refresh = UIRefreshControl()
    table.refreshControl = refresh
    refresh.addTarget(self, action: #selector(updateSwipeTable), for: .valueChanged)
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
    addSubview()
    
    settingsNavigationController()

    
    
    updateViewConstraints()
  }
  
  @objc func updateSwipeTable() {
    tableView.reloadData()
    tableView.refreshControl?.endRefreshing()
  }
  
  @objc func plusFolder() { addCreateFolderAlert() }
  
  func addCreateFolderAlert() {
    let alertCreateFolder = UIAlertController(title: "Создание нового каталога", message: "Введите имя", preferredStyle: .alert)
    alertCreateFolder.addTextField()
    alertCreateFolder.textFields?.first?.placeholder = "Имя"
    
    let okButton = UIAlertAction(title: "Создать", style: .cancel) { _ in
      guard let textFields = alertCreateFolder.textFields?.first?.text, !textFields.isEmpty else {
        self.errorAlert("Заполните поле Имя")
        return}
      
     if self.fileManager.createFolder(textFields) {
        self.errorAlert("Такая папка существует")
      }
      
      self.tableView.reloadData()
    }
    let cancelButton = UIAlertAction(title: "Отмена", style: .destructive)
    
    alertCreateFolder.addAction(okButton)
    alertCreateFolder.addAction(cancelButton)
    present(alertCreateFolder, animated: true)
  }
  
  func errorAlert(_ massage: String) {
    let alertError = UIAlertController(title: "Ошибка", message: massage, preferredStyle: .alert)
    let okButton = UIAlertAction(title: "Хорошо", style: .default) { _ in
      self.addCreateFolderAlert()
    }
    alertError.addAction(okButton)
    present(alertError, animated: true)
  }
  
  func addSubview() {
    view.addSubview(tableView)
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
      make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
      make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
      make.leading.equalToSuperview().inset(16)
      make.trailing.equalToSuperview().inset(16)
    }
    
  }


}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    fileManager.directoryContent().count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let f = UITableViewCell()
    f.textLabel?.text = "\(fileManager.directoryContent()[indexPath.row].lastPathComponent)"
    return f
  }
  
  
  
  
  
  
}

