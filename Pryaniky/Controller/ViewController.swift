//
//  ViewController.swift
//  Pryaniky
//
//  Created by Анна Заблуда on 30.07.2021.
//

import UIKit
import AVKit

protocol ApiManagerDelegate {
    func updateData(_ loadedUser: JsonModel)
}

final class ViewController: UITableViewController {

    private let apiManager = ApiManager()
    private var JsonModel: JsonModel?
    private var views = [String : [UIView]]()
    private var viewsOrder = [UIView]()
    private var viewsToLoad = [UIView]()
    private var loadPortion = 5
    private var additionalLoadingIsAllowed = false
    
    private var pickersData = [UIPickerView : PickersData]()
    private var cashedCells = [Int : TableViewCell]()
    
    private let height = UIScreen.main.bounds.height
    private let width = UIScreen.main.bounds.width

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        apiManager.delegate = self
        apiManager.loadingData()
        
        tableView.register(TableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.separatorStyle = .none
    }
    
    
    // MARK : - TableView
    
    @objc func playAndPauseMedia(sender: UIButton!) {
        let but = sender as! MyPlayButton
        let cell = tableView.cellForRow(at: but.cellIndex) as! TableViewCell
        guard !but.isPlayed else {
            but.isPlayed = false
            cell.player?.pause()
            return
        }
        if cell.player == nil {
            cell.player = AVPlayer(url: cell.mediaUrl!)
            let playerLayer = AVPlayerLayer(player: cell.player)
            playerLayer.frame = cell.media.frame
            cell.media.layer.addSublayer(playerLayer)
        }
        cell.player!.play()
        but.isPlayed = true
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewsToLoad.count
    }
    
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == viewsToLoad.count &&
            viewsOrder.count != 0 {
            if additionalLoadingIsAllowed {
                addViewsToLoad()
                tableView.reloadData()
            } else {
                additionalLoadingIsAllowed = true
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let obj = viewsToLoad[indexPath.row]
        switch obj {
        case is MyLabel:
            return height * 0.15
        case is MyImageView:
            return width * 0.6
        case is MyPickerView:
            return height * 0.3
        default:
            break
        }
        return height * 0.1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard cashedCells[indexPath.row] == nil else { return cashedCells[indexPath.row]! }
        let cell = TableViewCell(style: .default, reuseIdentifier: "Cell")
        
        switch viewsToLoad[indexPath.row] {
        case is MyLabel:
            let oldLabel = viewsToLoad[indexPath.row] as! UILabel
            cell.label.text = oldLabel.text
            
        case is MyImageView:
            let iv = viewsToLoad[indexPath.row] as! MyImageView
            var url: String?
            
            if let media = iv.mediaUrl { cell.mediaUrl = URL(string: media) }
            if iv.mediaUrl != nil {
                cell.playButton = MyPlayButton(frame: cell.image.frame, cell: indexPath)
                cell.playButton!.addTarget(self, action: #selector(playAndPauseMedia), for: .touchUpInside)
            }
            url = iv.coverUrl != nil ? iv.coverUrl : iv.imageURL
            apiManager.downloadImages(imageURL: url!) { image in
                cell.image.image = image
                if cell.playButton != nil {
                    cell.playButton?.isHidden = false
                }
            }
        case is MyPickerView:
            cell.picker.isHidden = false
            let oldPV = viewsToLoad[indexPath.row] as! MyPickerView
            let pd = PickersData(variants: oldPV.variants, selectedID: oldPV.selectedId, selectedIndex: oldPV.selectedIndex)
            pickersData[cell.picker] = pd
            cell.picker.delegate = self
            cell.picker.dataSource = self
            guard let selected = oldPV.selectedIndex else { break }
            cell.picker.selectRow(selected, inComponent: 0, animated: true)
            
        default:
            break
        }
        
        cashedCells[indexPath.row] = cell
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        var viewName = "View name: "
        var data = ""
        let obj = viewsToLoad[indexPath.row]
        switch obj {
        case is MyLabel:
            viewName += (obj as! MyLabel).sectionName!
        case is MyImageView:
            let iv = obj as! MyImageView
            viewName += iv.sectionName!
            data += "Text: \(iv.text ?? "")"
        case is MyPickerView:
            let pv = obj as! MyPickerView
            viewName += pv.sectionName!
            tableView.allowsSelectionDuringEditing = false
            guard let cell = self.tableView.cellForRow(at: indexPath) as? TableViewCell,
                let id = pickersData[cell.picker]?.selectedID else {break}
            data = "SelectedID: \(id)"
        default:
            break
        }
        let alert = UIAlertController(title: viewName, message: data, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default))
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - ApiManagerDelegate

extension ViewController: ApiManagerDelegate {
    
    func updateData(_ loadedModel: JsonModel) {
        self.JsonModel = loadedModel
        createViews()
        createViewsOrder()
        addViewsToLoad()
        tableView.reloadData()
    }
    
    private func createViews() {
        JsonModel?.data.forEach({
            if $0.data.url != nil || $0.data.coverUrl != nil {
                let imageView = MyImageView()
                imageView.imageURL = $0.data.url
                imageView.coverUrl = $0.data.coverUrl
                imageView.mediaUrl = $0.data.mediaUrl
                imageView.sectionName = $0.name
                imageView.text = $0.data.text
                if var _ = views[$0.name] {
                    views[$0.name]!.append(imageView)
                } else {
                    views[$0.name] = [imageView]
                }
            } else if let variants = $0.data.variants {
                let pickerView = MyPickerView()
                pickerView.sectionName = $0.name
                variants.forEach({ variant in
                    pickerView.variants.append((variant.id, variant.text))
                })
                if let selected = $0.data.selectedId {
                    for index in 0..<pickerView.variants.count {
                        guard selected == pickerView.variants[index].0 else { continue }
                        pickerView.selectedIndex = index
                        pickerView.selectedId = selected
                        break
                    }
                }
                if var _ = views[$0.name] {
                    views[$0.name]!.append(pickerView)
                } else {
                    views[$0.name] = [pickerView]
                }
            } else if let text = $0.data.text {
                let label = MyLabel()
                label.sectionName = $0.name
                label.text = text
                if var _ = views[$0.name] {
                    views[$0.name]!.append(label)
                } else {
                    views[$0.name] = [label]
                }
            }
        })
    }
    
    private func createViewsOrder() {
        JsonModel?.view.forEach({
            if let view = views[$0] {
                view.forEach { item in
                    viewsOrder.append(item)
                }
            }
        })
    }
    
    private func addViewsToLoad() {
        for _ in 0..<loadPortion {
            if let item = viewsOrder.first {
                viewsToLoad.append(item)
                viewsOrder.remove(at: 0)
            } else { break }
        }
        additionalLoadingIsAllowed = false
    }
}



// MARK : - PickerView

extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickersData[pickerView]?.variants.count ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let str = "\(pickersData[pickerView]!.variants[row].1)"
        return str
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickersData[pickerView]?.selectedIndex = row
        pickersData[pickerView]!.selectedID = pickersData[pickerView]?.variants[row].0
    }
}
