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
    private var pickersData = [UIPickerView : [(Int, String)]]()
    
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
        if viewsOrder[indexPath.row] is MyPickerView {
            self.tableView.reloadData()
        }
        self.tableView.deselectRow(at: indexPath, animated: true)
        var viewName = String()
        let obj = viewsOrder[indexPath.row]
        switch obj {
        case is MyLabel:
            viewName += (obj as! MyLabel).sectionName!
        case is MyImageView:
            viewName += (obj as! MyImageView).sectionName!
        case is MyPickerView:
            viewName += (obj as! MyPickerView).sectionName!
        default:
            break
        }
        let alert = UIAlertController(title: "View name:", message: viewName, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default))
        self.present(alert, animated: true, completion: nil)
    }
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewsOrder.count
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
            pickersData[cell.picker] = oldPV.variants
            cell.picker.delegate = self
            cell.picker.dataSource = self
            if let selected = oldPV.selectedId {
                for index in 0..<oldPV.variants.count {
                    if selected == oldPV.variants[index].0 {
                        cell.picker.selectRow(index, inComponent: 0, animated: true)
                        break
                    }
                }
                
            }
            cell.addSubview(cell.picker)
            
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
            } else if let selectedId = $0.data.selectedId {
                let pickerView = MyPickerView()
                pickerView.sectionName = $0.name
                $0.data.variants?.forEach({ variant in
                    pickerView.variants.append((variant.id, variant.text))
                })
                pickerView.selectedId = selectedId
                if var _ = views[$0.name] {
                    views[$0.name]!.append(pickerView)
                } else {
                    views[$0.name] = [pickerView]
                }
            } else {
                let label = MyLabel()
                label.sectionName = $0.name
                label.text = $0.data.text
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
        return pickersData[pickerView]?.count ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let str = "\(pickersData[pickerView]![row].1)"
        return str
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print(#function)
    }
}
