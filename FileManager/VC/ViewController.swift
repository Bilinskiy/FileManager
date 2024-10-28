//
//  ViewController.swift
//  FileManager
//
//  Created by Дмитрий Билинский on 24.10.24.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    
  var fileManager: ManagerFileProtocol = ManagerFile()
  
  let fullImageView = FullImageViewController()
  
  lazy var tableView: UITableView = {
    var table = UITableView()
   // table.separatorInset = .zero
    table.layer.cornerRadius = 15
    table.rowHeight = 44
    let refresh = UIRefreshControl()
    table.refreshControl = refresh
    refresh.addTarget(self, action: #selector(updateSwipeTable), for: .valueChanged)
    table.register(FolderTableViewCell.self, forCellReuseIdentifier: FolderTableViewCell.key)
    table.register(ImageTableViewCell.self, forCellReuseIdentifier: ImageTableViewCell.key)
    table.dataSource = self
    table.delegate = self
    return table
  }()
  
  lazy var rightBarButtonPlusFolder: UIBarButtonItem = {
    var button = UIBarButtonItem(image: UIImage(systemName: "plus.circle"), style: .plain, target: self, action: #selector(plusFolder))
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
  
  @objc func plusFolder() { addFileAlert() }
  
  func addFileAlert() {
    let alert = UIAlertController(title: "Выбирите действие", message: nil, preferredStyle: .alert)
    
    let createFolder = UIAlertAction(title: "Создать дирикторию", style: .default) { _ in
      self.addCreateFolderAlert()
    }
    let addImage = UIAlertAction(title: "Добавить изображение", style: .default) { _ in
      self.presentImagePicker()
    }
    let cancel = UIAlertAction(title: "Отмена", style: .destructive)
    
    alert.addAction(createFolder)
    alert.addAction(addImage)
    alert.addAction(cancel)

    present(alert, animated: true)
  }
  
  func addCreateFolderAlert() {
    let alertCreateFolder = UIAlertController(title: "Создание нового каталога", message: "Введите имя", preferredStyle: .alert)
    alertCreateFolder.addTextField()
    alertCreateFolder.textFields?.first?.placeholder = "Имя"
    
    let okButton = UIAlertAction(title: "Создать", style: .cancel) { _ in
      guard let textFields = alertCreateFolder.textFields?.first?.text?.trimmingCharacters(in: .whitespaces), !textFields.isEmpty else {
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
  
  func presentImagePicker() {
    let imagePicker = UIImagePickerController()
    imagePicker.sourceType = .photoLibrary
    imagePicker.delegate = self
    
    present(imagePicker, animated: true)
  }
  
  func settingsNavigationController() {
    let color: [UIColor] = [.red, .yellow, .green, .orange, .brown]
    navigationItem.title = fileManager.currentCatalog.lastPathComponent
    navigationItem.rightBarButtonItems = [rightBarButtonPlusFolder]
    navigationController?.navigationBar.tintColor = .black
    
    navigationController?.navigationBar.scrollEdgeAppearance = UINavigationBarAppearance()
    navigationController?.navigationBar.scrollEdgeAppearance?.backgroundColor = color.randomElement()
   
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
    guard let folderCell = tableView.dequeueReusableCell(withIdentifier: FolderTableViewCell.key, for: indexPath) as? FolderTableViewCell, let imageCell = tableView.dequeueReusableCell(withIdentifier: ImageTableViewCell.key, for: indexPath) as? ImageTableViewCell else {return UITableViewCell()}
 
    if let image = UIImage(contentsOfFile: fileManager.directoryContent()[indexPath.row].path()) {
     
      imageCell.image.image = image.preparingThumbnail(of: CGSize(width: 60, height: 60))
      return imageCell
      
    } else {
      
      folderCell.nameFolderLabel.text = "\(fileManager.directoryContent()[indexPath.row].lastPathComponent)"
      return folderCell
      
    }
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    if let image = UIImage(contentsOfFile: fileManager.directoryContent()[indexPath.row].path()) {
      fullImageView.imageView.image = image
      fullImageView.modalPresentationStyle = .formSheet
      present(fullImageView, animated: true)
    
    } else {
      
      let folder = fileManager.directoryContent()[indexPath.row]
      let viewFolder = ViewController()
      viewFolder.fileManager.currentCatalog = folder
      
      navigationController?.pushViewController(viewFolder, animated: true)
    }
  }
  
  
  
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    
    guard let imageURL = info[.imageURL] as? URL,
          let originalImage = info[.originalImage] as? UIImage
      else {return}
    
    let data = originalImage.jpegData(compressionQuality: 1)
      
    fileManager.addImage(URL: imageURL.lastPathComponent, data: data)
    
    tableView.reloadData()
    
    dismiss(animated: true)
  }
  
  
}

