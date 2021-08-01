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

final class ViewController: UIViewController {

    private let apiManager = ApiManager()
    private var JsonModel: JsonModel?
    private var views = [String : UIView]()
    private var viewsOrder = [UIView]()
    private var pickers = [UIPickerView : [String]]()
    
    private lazy var scrollView: UIScrollView =  {
        let sv = UIScrollView(frame: view.frame)
        sv.alwaysBounceVertical = true
        sv.backgroundColor = .white
        return sv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        apiManager.delegate = self
        apiManager.loadingData()
    }
}

extension ViewController: ApiManagerDelegate {
    
    func updateData(_ loadedModel: JsonModel) {
        self.JsonModel = loadedModel
        createViews()
        createViewsOrder()
        setupConstraints()
    }
    
    private func createViews() {
        JsonModel?.data.forEach({
            if let url = $0.data.url {
                let imageView = MyImageView()
                imageView.imageURL = url
                views[$0.name] = imageView
            } else if let selectedId = $0.data.selectedId {
                let pickerView = MyPickerView()
                $0.data.variants?.forEach({ variant in
                    pickerView.variants.append("\(variant.id) \(variant.text)")
                })
                pickerView.selectedId = selectedId
                views[$0.name] = pickerView
            } else {
                let label = UILabel()
                label.text = $0.data.text
                views[$0.name] = label
            }
        })
    }
    
    private func createViewsOrder() {
        view.addSubview(scrollView)
        JsonModel?.view.forEach({
            if let view = views[$0] {
                switch view {
                case is UILabel:
                    let oldLabel = views[$0] as! UILabel
                    let label = UILabel()
                    label.text = oldLabel.text
                    label.textAlignment = .center
                    label.numberOfLines = 0
                    viewsOrder.append(label)
                case is MyPickerView:
                    let oldPv = views[$0] as! MyPickerView
                    let pv = MyPickerView()
                    pickers[pv] = oldPv.variants
                    pv.delegate = self
                    pv.dataSource = self
                    pv.selectRow(oldPv.selectedId - 1, inComponent: 0, animated: true)
                    viewsOrder.append(pv)
                case is MyImageView:
                    let oldImageView = views[$0] as! MyImageView
                    let iv = MyImageView()
                    apiManager.downloadImages(imageURL: oldImageView.imageURL!) { image in
                        iv.image = image
                    }
                    iv.largeContentTitle = "hi"
                    viewsOrder.append(iv)
                default:
                    break
                }
                self.scrollView.addSubview(viewsOrder.last!)
            }
        })
    }

    
    private func setupConstraints() {
        let height = UIScreen.main.bounds.height
        let width = UIScreen.main.bounds.width
        let ident = height * 0.02
        var lastBottom: CGFloat = 0
        var itemHeight: CGFloat = 0
        
        for index in 0..<viewsOrder.count {
            switch viewsOrder[index] {
            case is UILabel:
                itemHeight = height * 0.1
            case is MyImageView:
                itemHeight = width * 0.6
            case is MyPickerView:
                itemHeight = width * 0.3
            default:
                break
            }
            viewsOrder[index].anchor(top: scrollView.topAnchor,
                                left: scrollView.leftAnchor,
                                bottom: index == viewsOrder.count - 1 ? scrollView.bottomAnchor : nil,
                                paddingTop: lastBottom + ident,
                                paddingLeft: width * 0.2,
                                width: width * 0.6,
                                height: itemHeight)
            lastBottom += itemHeight + ident
        }
    }
}

extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickers[pickerView]?.count ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickers[pickerView]![row]
    }
}
