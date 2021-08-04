//
//  ViewController.swift
//  Pryaniky
//
//  Created by Анна Заблуда on 30.07.2021.
//

import UIKit

protocol ApiManagerDelegate {
    func updateData(_ loadedUser: JsonModel)
}

final class ViewController: UITableViewController {

    private let apiManager = ApiManager()
    private var JsonModel: JsonModel?
    private var views = [String : [UIView]]()
    private var viewsOrder = [UIView]()
    private var pickersData = [UIPickerView : PickersData]()
    
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
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewsOrder.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let obj = viewsOrder[indexPath.row]
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if viewsOrder[indexPath.row] is MyPickerView {
//            (viewsOrder[indexPath.row] as! UIPickerView).reloadAllComponents()
//        }
        self.tableView.deselectRow(at: indexPath, animated: true)
        var viewName = "View name: "
        var data = ""
        let obj = viewsOrder[indexPath.row]
        switch obj {
        case is MyLabel:
            viewName += (obj as! MyLabel).sectionName!
        case is MyImageView:
            let iv = obj as! MyImageView
            viewName += iv.sectionName!
            data += "Image text: \(iv.text ?? "")"
        case is MyPickerView:
            let pv = obj as! MyPickerView
            viewName += pv.sectionName!
            print(indexPath.row)
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
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = TableViewCell(style: .default, reuseIdentifier: "Cell")
        
        switch viewsOrder[indexPath.row] {
        case is MyLabel:
            let oldLabel = viewsOrder[indexPath.row] as! UILabel
            cell.label.text = oldLabel.text
            
        case is MyImageView:
            let imageURL = (viewsOrder[indexPath.row] as! MyImageView).imageURL
            apiManager.downloadImages(imageURL: imageURL!) { image in
                cell.image.image = image
            }
            
        case is MyPickerView:
            cell.picker.isHidden = false
            let oldPV = viewsOrder[indexPath.row] as! MyPickerView
            let pd = PickersData(variants: oldPV.variants, selectedID: oldPV.selectedId, selectedIndex: oldPV.selectedIndex)
            pickersData[cell.picker] = pd
            cell.picker.delegate = self
            cell.picker.dataSource = self
            guard let selected = oldPV.selectedIndex else { break }
            cell.picker.selectRow(selected, inComponent: 0, animated: true)
        default:
            break
        }
        
        return cell
    }
}

// MARK: - ApiManagerDelegate

extension ViewController: ApiManagerDelegate {
    
    func updateData(_ loadedModel: JsonModel) {
        self.JsonModel = loadedModel
        createViews()
        createViewsOrder()
        tableView.reloadData()
    }
    
    private func createViews() {
        JsonModel?.data.forEach({
            if let url = $0.data.url {
                let imageView = MyImageView()
                imageView.imageURL = url
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
