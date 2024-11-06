//
//  ViewController.swift
//  FileManager
//
//  Created by Дмитрий Билинский on 24.10.24.
//

import UIKit
import SnapKit

enum ViewMode {
  case select
  case view
}

class ViewController: UIViewController {
  
  private var viewMode: ViewMode = .view {
    didSet {
      switch viewMode {
      case .select:
        rightBarButtonSelectItem.image = UIImage(systemName: "checkmark.circle.fill")
        settingsNavigationController()
      case .view:
        rightBarButtonSelectItem.image = UIImage(systemName: "checkmark.circle")
        settingsNavigationController()
        tableView.indexPathsForSelectedRows?.forEach({tableView.deselectRow(at: $0, animated: true)})
        collectionView.indexPathsForVisibleItems.forEach({collectionView.deselectItem(at: $0, animated: true)})
        arrayDelURL.removeAll()
      }
    }
  }
  
  private var fileManager: ManagerFileProtocol = ManagerFile()
  private let fullImageView = FullImageViewController()
  private var arrayDelURL: [URL] = [] {
    didSet {
      rightBarButtonTrash.isEnabled = !arrayDelURL.isEmpty
    }
  }

  lazy var emptyDirectoryLabel: UILabel = {
    var label = UILabel()
    label.font = label.font.withSize(25)
    label.textColor = .colorBlackNav
    label.text = "КАТАЛОГ ПУСТОЙ"
    label.layer.opacity = 0.4
    return label
  }()
  
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
    table.allowsMultipleSelection = true
    table.dataSource = self
    table.delegate = self
    return table
  }()
  
  lazy var collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .vertical
    layout.minimumLineSpacing = 16
    layout.minimumInteritemSpacing = 16
    var collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collection.register(FolderCollectionViewCell.self, forCellWithReuseIdentifier: FolderCollectionViewCell.key)
    collection.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: ImageCollectionViewCell.key)
    collection.register(HeaderCollectionView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderCollectionView.key)
    collection.backgroundColor = .clear
    collection.showsVerticalScrollIndicator = false
    collection.allowsMultipleSelection = true
    collection.dataSource = self
    collection.delegate = self
    return collection
  }()
  
  lazy var rightBarButtonPlusFolder: UIBarButtonItem = {
    var button = UIBarButtonItem(image: UIImage(systemName: "plus.circle"), style: .plain, target: self, action: #selector(plusFolder))
    return button
  }()
  
  lazy var rightBarButtonSelectItem: UIBarButtonItem = {
    var button = UIBarButtonItem(image: UIImage(systemName: "checkmark.circle"), style: .plain, target: self, action: #selector(selectItem))
    return button
  }()
  
  lazy var rightBarButtonTrash: UIBarButtonItem = {
    var button = UIBarButtonItem(image: UIImage(systemName: "trash.circle"), style: .plain, target: self, action: #selector(trashItem))
    button.isEnabled = false
    return button
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .colorBackground
    
    settingsSwipeSegment()
    
    asSelectView()
     
    addSubview()
    
    settingsNavigationController()

    fileManager.fetchDirectoryContent()
    
    updateViewConstraints()
  }
  
  @objc func updateSwipeTable() {
    fileManager.fetchDirectoryContent()
    tableView.reloadData()
    collectionView.reloadData()
    tableView.refreshControl?.endRefreshing()
  }
  
  @objc func plusFolder() { addFileAlert() }
  
  @objc func selectItem() { viewMode = (viewMode == .select) ? .view : .select }
 
  @objc func trashItem() {
    fileManager.removeContent(arrayDelURL)
    tableView.reloadData()
    collectionView.reloadData()
    arrayDelURL.removeAll()
    viewMode = .view
  }
  
  @objc func isSegmentSwipe(_ gesture: UISwipeGestureRecognizer) {
    switch gesture.direction {
    case .left:
      segmentControl.selectedSegmentIndex = 1
    case .right:
      segmentControl.selectedSegmentIndex = 0
    default:
      break
    }

    isSegment()
  }
  
  @objc func isSegment() {
    UserDefaults.standard.set(segmentControl.selectedSegmentIndex, forKey: "selectedSegmentIndex")
    collectionView.isHidden.toggle()
    tableView.isHidden.toggle()
  }
  
  func settingsSwipeSegment() {
    let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(isSegmentSwipe))
    let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(isSegmentSwipe))
    swipeLeft.direction = .left
    swipeRight.direction = .right

    tableView.addGestureRecognizer(swipeLeft)
    collectionView.addGestureRecognizer(swipeRight)
  }
  
  func asSelectView() {
    if UserDefaults.standard.object(forKey: "selectedSegmentIndex") == nil {
      segmentControl.selectedSegmentIndex = 0
      UserDefaults.standard.set(segmentControl.selectedSegmentIndex, forKey: "selectedSegmentIndex")
    } else {
      segmentControl.selectedSegmentIndex = UserDefaults.standard.integer(forKey: "selectedSegmentIndex")
    }
    
    collectionView.isHidden = UserDefaults.standard.integer(forKey: "selectedSegmentIndex") == 0
    tableView.isHidden = UserDefaults.standard.integer(forKey: "selectedSegmentIndex") != 0
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

      self.fileManager.createFolder(textFields) ? nil : self.errorAlert("Такая папка существует")
       
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
    view.addSubview(emptyDirectoryLabel)
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

    switch viewMode {
    case .view:
      navigationItem.rightBarButtonItems = [rightBarButtonPlusFolder, rightBarButtonSelectItem]
    case .select:
      navigationItem.rightBarButtonItems = [rightBarButtonTrash, rightBarButtonSelectItem]
    }
  }
  
  override func updateViewConstraints() {
    super.updateViewConstraints()
    emptyDirectoryLabel.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.centerY.equalToSuperview()
    }
    
    segmentControl.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).inset(16)
    }
    
    tableView.snp.makeConstraints { make in
      make.top.equalTo(self.segmentControl.snp.bottom).inset(-16)
      make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
      make.leading.equalToSuperview().inset(16)
      make.trailing.equalToSuperview().inset(16)
    }
    
    collectionView.snp.makeConstraints { make in
      make.top.equalTo(self.segmentControl.snp.bottom).inset(-16)
      make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
      make.leading.equalToSuperview().inset(16)
      make.trailing.equalToSuperview().inset(16)
    }
    
  }

}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    emptyDirectoryLabel.isHidden = !(fileManager.filterContent(.folder).isEmpty && fileManager.filterContent(.image).isEmpty)
    return fileManager.content.count
  }
  
  func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
    guard let header = view as? UITableViewHeaderFooterView else { return }
    header.textLabel?.font = header.textLabel?.font.withSize(16)
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch TypeDirectory(rawValue: section) {
    case .folder:
      return !fileManager.filterContent(.folder).isEmpty ? "Folder" : ""
    case .image:
      return !fileManager.filterContent(.image).isEmpty ? "Image" : ""
    default:
      return ""
    }
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch TypeDirectory(rawValue: section) {
    case .folder:
      return fileManager.filterContent(.folder).count
    case .image:
      return fileManager.filterContent(.image).count
    default:
      return 0
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch TypeDirectory(rawValue: indexPath.section) {
    case .folder:
      guard let folderCell = tableView.dequeueReusableCell(withIdentifier: FolderTableViewCell.key, for: indexPath) as? FolderTableViewCell else {return UITableViewCell()}
      folderCell.nameFolderLabel.text = "\(fileManager.filterContent(.folder)[indexPath.row].lastPathComponent)"
      return folderCell
    case .image:
      guard let imageCell = tableView.dequeueReusableCell(withIdentifier: ImageTableViewCell.key, for: indexPath) as? ImageTableViewCell else {return UITableViewCell()}
      let image = UIImage(contentsOfFile: fileManager.filterContent(.image)[indexPath.row].path())
      imageCell.image.image = image?.preparingThumbnail(of: CGSize(width: 60, height: 60))
      return imageCell
    default:
      return UITableViewCell()
    }
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    switch viewMode {
    case .select:
      collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .bottom)
      
      switch TypeDirectory(rawValue: indexPath.section) {
      case .folder:
      arrayDelURL.append(fileManager.filterContent(.folder)[indexPath.row])
 
      case .image:
      arrayDelURL.append(fileManager.filterContent(.image)[indexPath.row])

      default:
        break
      }
      
    case .view:
      tableView.deselectRow(at: indexPath, animated: true)
      switch TypeDirectory(rawValue: indexPath.section) {
      case .folder:
        let folder = fileManager.filterContent(.folder)[indexPath.row]
        let viewFolder = ViewController()
        viewFolder.fileManager.currentCatalog = folder
        navigationController?.pushViewController(viewFolder, animated: true)
      case .image:
        let image = UIImage(contentsOfFile: fileManager.filterContent(.image)[indexPath.row].path())
        fullImageView.imageView.image = image
        fullImageView.modalPresentationStyle = .formSheet
        present(fullImageView, animated: true)
      default:
        break
      }
    }
    
  }
  
  func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    switch viewMode {
    case .select:
      collectionView.deselectItem(at: indexPath, animated: true)
    
      switch TypeDirectory(rawValue: indexPath.section) {
      case .folder:
        arrayDelURL = arrayDelURL.filter({$0 != fileManager.filterContent(.folder)[indexPath.row]})

      case .image:
        arrayDelURL = arrayDelURL.filter({$0 != fileManager.filterContent(.image)[indexPath.row]})
        
      default:
        break
      }
    case .view:
      tableView.deselectRow(at: indexPath, animated: true)
    }
  }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    fileManager.content.count
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsets(top: 3.0, left: 0.0, bottom: 25, right: 0.0)
  }
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderCollectionView.key, for: indexPath) as? HeaderCollectionView else {return UICollectionReusableView()}
    if kind == UICollectionView.elementKindSectionHeader {
      switch TypeDirectory(rawValue: indexPath.section) {
      case .folder:
        header.nameHeaderLabel.text = !fileManager.filterContent(.folder).isEmpty ? "FOLDER" : ""
        return header
      case .image:
        header.nameHeaderLabel.text = !fileManager.filterContent(.image).isEmpty ? "IMAGE" : ""
        return header
      default:
        return UICollectionReusableView()
      }
    }
    return UICollectionReusableView()
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    CGSize(width: 50, height: 40)
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    switch TypeDirectory(rawValue: section) {
    case .folder:
      return fileManager.filterContent(.folder).count
    case .image:
      return fileManager.filterContent(.image).count
    default:
      return 0
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    switch TypeDirectory(rawValue: indexPath.section) {
    case .folder:
      guard let folderCell = collectionView.dequeueReusableCell(withReuseIdentifier: FolderCollectionViewCell.key, for: indexPath) as? FolderCollectionViewCell else {return UICollectionViewCell()}
      folderCell.nameFolderLabel.text = "\(fileManager.filterContent(.folder)[indexPath.row].lastPathComponent)"
      return folderCell
    case .image:
      guard let imageCell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.key, for: indexPath) as? ImageCollectionViewCell else {return UICollectionViewCell()}
      let image = UIImage(contentsOfFile: fileManager.filterContent(.image)[indexPath.row].path())
      imageCell.image.image = image?.preparingThumbnail(of: CGSize(width: 200, height: 200))
      return imageCell
    default:
      return UICollectionViewCell()
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    switch TypeDirectory(rawValue: indexPath.section) {
    case .folder:
      return CGSize(width: ((collectionView.frame.width-48)/4), height: ((collectionView.frame.width-48)/4))
    case .image:
      return CGSize(width: ((collectionView.frame.width-32)/3), height: ((collectionView.frame.width-32)/3))
    default:
      return CGSize()
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    switch viewMode {
    case .select:
      tableView.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
      
      switch TypeDirectory(rawValue: indexPath.section) {
        case .folder:
          arrayDelURL.append(fileManager.filterContent(.folder)[indexPath.row])
    
        case .image:
          arrayDelURL.append(fileManager.filterContent(.image)[indexPath.row])
    
        default:
            break
      }
    case .view:
      collectionView.deselectItem(at: indexPath, animated: false)
      switch TypeDirectory(rawValue: indexPath.section) {
      case .folder:
        let folder = fileManager.filterContent(.folder)[indexPath.row]
        let viewFolder = ViewController()
        viewFolder.fileManager.currentCatalog = folder
        navigationController?.pushViewController(viewFolder, animated: true)
      case .image:
        let image = UIImage(contentsOfFile: fileManager.filterContent(.image)[indexPath.row].path())
        fullImageView.imageView.image = image
        fullImageView.modalPresentationStyle = .formSheet
        present(fullImageView, animated: true)
      default:
        break
      }
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
    switch viewMode {
    case .select:
      tableView.deselectRow(at: indexPath, animated: true)

      switch TypeDirectory(rawValue: indexPath.section) {
      case .folder:
        arrayDelURL = arrayDelURL.filter({$0 != fileManager.filterContent(.folder)[indexPath.row]})
        
      case .image:
        arrayDelURL = arrayDelURL.filter({$0 != fileManager.filterContent(.image)[indexPath.row]})
        
      default:
        break
      }
    case .view:
      collectionView.deselectItem(at: indexPath, animated: false)
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
    collectionView.reloadData()
    dismiss(animated: true)
  }

}

