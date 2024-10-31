//
//  ViewController.swift
//  FileManager
//
//  Created by Дмитрий Билинский on 24.10.24.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
  
  private var fileManager: ManagerFileProtocol = ManagerFile()
  private let fullImageView = FullImageViewController()
  
  lazy var segmentControl: UISegmentedControl = {
    var segment = UISegmentedControl()
    segment.insertSegment(withTitle: "TableView", at: 0, animated: true)
    segment.insertSegment(withTitle: "CollectionView", at: 1, animated: true)
    segment.addTarget(self, action: #selector(isSegment), for: .valueChanged)
    return segment
  }()
  
  lazy var tableView: UITableView = {
    var table = UITableView(frame: .zero, style: .insetGrouped)
    table.backgroundColor = .clear
    table.showsVerticalScrollIndicator = false
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
  
  lazy var collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .vertical
    layout.minimumLineSpacing = 8
    layout.minimumInteritemSpacing = 8
    var collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collection.register(FolderCollectionViewCell.self, forCellWithReuseIdentifier: FolderCollectionViewCell.key)
    collection.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: ImageCollectionViewCell.key)
    collection.register(HeaderCollectionView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderCollectionView.key)
    collection.showsVerticalScrollIndicator = false
    collection.dataSource = self
    collection.delegate = self
    return collection
  }()
  
  lazy var rightBarButtonPlusFolder: UIBarButtonItem = {
    var button = UIBarButtonItem(image: UIImage(systemName: "plus.circle"), style: .plain, target: self, action: #selector(plusFolder))
    return button
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    
    asSelectView()
    
    addSubview()
    
    settingsNavigationController()

    fileManager.fetchDirectoryContent()
    
    updateViewConstraints()
  }
  
  @objc func updateSwipeTable() {
    fileManager.fetchDirectoryContent()
    tableView.reloadData()
    tableView.refreshControl?.endRefreshing()
  }
  
  @objc func plusFolder() { addFileAlert() }
  
  @objc func isSegment() {
    UserDefaults.standard.set(segmentControl.selectedSegmentIndex, forKey: "selectedSegmentIndex")
    collectionView.isHidden.toggle()
    tableView.isHidden.toggle()
  }
  
  func asSelectView() {
    if UserDefaults.standard.object(forKey: "selectedSegmentIndex") == nil {
      segmentControl.selectedSegmentIndex = 0
      UserDefaults.standard.set(segmentControl.selectedSegmentIndex, forKey: "selectedSegmentIndex")
    } else {
      segmentControl.selectedSegmentIndex = UserDefaults.standard.integer(forKey: "selectedSegmentIndex")
    }
    
    if UserDefaults.standard.integer(forKey: "selectedSegmentIndex") == 0 {
      collectionView.isHidden = true
      tableView.isHidden = false
    } else {
      tableView.isHidden = true
      collectionView.isHidden = false
    }
  
  }
  
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

     if let folderURL = self.fileManager.createFolder(textFields) {
       
       for i in 0..<self.fileManager.content.count {
         if self.fileManager.content[i].type == .folder {
           self.fileManager.content[i].appendNewFile(folderURL)
         }
       }
       
     } else {
       self.errorAlert("Такая папка существует")
     }
      
      self.tableView.reloadData()
      self.collectionView.reloadData()
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
    view.addSubview(segmentControl)
    view.addSubview(collectionView)
  }
  
  func presentImagePicker() {
    let imagePicker = UIImagePickerController()
    imagePicker.sourceType = .photoLibrary
    imagePicker.delegate = self
    
    present(imagePicker, animated: true)
  }
  
  func settingsNavigationController() {
    navigationItem.title = fileManager.currentCatalog.lastPathComponent
    navigationItem.rightBarButtonItems = [rightBarButtonPlusFolder]
    navigationController?.navigationBar.tintColor = .black
    
    navigationController?.navigationBar.scrollEdgeAppearance = UINavigationBarAppearance()
    navigationController?.navigationBar.scrollEdgeAppearance?.backgroundColor = .green
   
  }
  
  override func updateViewConstraints() {
    super.updateViewConstraints()
    segmentControl.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).inset(8)
    }
    
    tableView.snp.makeConstraints { make in
      make.top.equalTo(self.segmentControl.snp.bottom).inset(-8)
      make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
      make.leading.equalToSuperview().inset(16)
      make.trailing.equalToSuperview().inset(16)
    }
    
    collectionView.snp.makeConstraints { make in
      make.top.equalTo(self.segmentControl.snp.bottom).inset(-8)
      make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
      make.leading.equalToSuperview().inset(16)
      make.trailing.equalToSuperview().inset(16)
    }
    
  }

}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    fileManager.content.count
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if !fileManager.filterContent(.folder).isEmpty, section == 0 {
      return "Folder"
    } else if !fileManager.filterContent(.image).isEmpty, section == 1  {
      return "Image"
    } else {
      return ""
    }
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return fileManager.filterContent(.folder).count
    } else {
      return fileManager.filterContent(.image).count
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    if indexPath.section == 0 {
      guard let folderCell = tableView.dequeueReusableCell(withIdentifier: FolderTableViewCell.key, for: indexPath) as? FolderTableViewCell else {return UITableViewCell()}
      
      folderCell.nameFolderLabel.text = "\(fileManager.filterContent(.folder)[indexPath.row].lastPathComponent)"
      return folderCell
    } else {
      guard let imageCell = tableView.dequeueReusableCell(withIdentifier: ImageTableViewCell.key, for: indexPath) as? ImageTableViewCell else {return UITableViewCell()}
      
      let image = UIImage(contentsOfFile: fileManager.filterContent(.image)[indexPath.row].path())
      imageCell.image.image = image?.preparingThumbnail(of: CGSize(width: 60, height: 60))
      return imageCell
    }
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    if indexPath.section == 1  {
      let image = UIImage(contentsOfFile: fileManager.filterContent(.image)[indexPath.row].path())
      fullImageView.imageView.image = image
      fullImageView.modalPresentationStyle = .formSheet
      present(fullImageView, animated: true)
    } else {
      let folder = fileManager.filterContent(.folder)[indexPath.row]
      let viewFolder = ViewController()
      viewFolder.fileManager.currentCatalog = folder
      navigationController?.pushViewController(viewFolder, animated: true)
    }
  }
  
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    fileManager.content.count
  }
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderCollectionView.key, for: indexPath) as? HeaderCollectionView else {return UICollectionReusableView()}
    if kind == UICollectionView.elementKindSectionHeader {
      if !fileManager.filterContent(.folder).isEmpty, indexPath.section == 0 {
        header.nameHeaderLabel.text = "Folder"
        return header
      } else if !fileManager.filterContent(.image).isEmpty, indexPath.section == 1 {
        header.nameHeaderLabel.text = "Image"
        return header
      } else {
        return header
      }
    }
    return UICollectionReusableView()
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    CGSize(width: 50, height: 40)
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if section == 0 {
      return fileManager.filterContent(.folder).count
    } else {
      return fileManager.filterContent(.image).count
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    if indexPath.section == 0 {
      guard let folderCell = collectionView.dequeueReusableCell(withReuseIdentifier: FolderCollectionViewCell.key, for: indexPath) as? FolderCollectionViewCell else {return UICollectionViewCell()}
    
      folderCell.nameFolderLabel.text = "\(fileManager.filterContent(.folder)[indexPath.row].lastPathComponent)"
      
      return folderCell
    } else {
      guard let imageCell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.key, for: indexPath) as? ImageCollectionViewCell else {return UICollectionViewCell()}
     
      let image = UIImage(contentsOfFile: fileManager.filterContent(.image)[indexPath.row].path())
      imageCell.image.image = image?.preparingThumbnail(of: CGSize(width: 200, height: 200))

      return imageCell
    }
  

  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    if indexPath.section == 0 {
      return CGSize(width: 70, height: 70)
    } else {
      return CGSize(width: 100, height: 100)
    }
    
    
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if indexPath.section == 1  {
      let image = UIImage(contentsOfFile: fileManager.filterContent(.image)[indexPath.row].path())
      fullImageView.imageView.image = image
      fullImageView.modalPresentationStyle = .formSheet
      present(fullImageView, animated: true)
    } else {
      let folder = fileManager.filterContent(.folder)[indexPath.row]
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
    
    for i in 0..<self.fileManager.content.count {
      if self.fileManager.content[i].type == .image {
        self.fileManager.content[i].appendNewFile(imageURL)
      }
    }
    
    tableView.reloadData()
    collectionView.reloadData()
    dismiss(animated: true)
  }

}

