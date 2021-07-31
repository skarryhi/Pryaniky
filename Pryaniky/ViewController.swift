//
//  ViewController.swift
//  Pryaniky
//
//  Created by Анна Заблуда on 30.07.2021.
//

import UIKit

protocol ApiManagerDelegate {
    func updateData(_ loadedUser: User)
    func updateImage(_ image: UIImage?)
}

final class ViewController: UIViewController {

    private let apiManager = ApiManager()
    private var views = [UIView]()
    private var imageView: UIImageView?
    private var user: User?
    
    private var scrollView: UIScrollView =  {
        let sv = UIScrollView()
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
    
    @IBAction func buttonAction(_ button: Button) {
        let alert = UIAlertController(title: String(button.id!), message: button.titleLabel?.text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default))
        self.present(alert, animated: true, completion: nil)
    }
}

extension ViewController: ApiManagerDelegate {
    
    func updateData(_ loadedUser: User) {
        self.user = loadedUser
        createViews()
        setupConstraints()
    }
    
    func updateImage(_ image: UIImage?) {
        imageView?.image = image
    }
    
    private func createViews() {
        var hz: String?
        var picture: (String, UIImage?)?
        var selector: [Variants]?
        
        
        view.addSubview(scrollView)
        user?.data.forEach({
            switch $0.name {
            case "hz": hz = $0.data.text!
            case "picture": picture = ($0.data.url!, nil)
            case "selector": selector = $0.data.variants
            default:
                return
            }
        })
        
        for i in user?.view ?? [String]() {
            switch i {
            case "hz":
                let label = UILabel()
                label.text = hz
                label.textAlignment = .center
                label.numberOfLines = 0
                self.views.append(label)
            case "picture":
                let imageView = UIImageView()
                self.imageView = imageView
                apiManager.downloadImages(imageURL: picture!.0)
                self.views.append(imageView)
            case "selector":
                selector?.forEach({
                    let but = Button()
                    but.id = $0.id
                    but.information = $0.text
                    self.views.append(but)
                })
            default:
                return
            }
        }
    }
    
    private func setupConstraints() {
        let height = UIScreen.main.bounds.height
        let width = UIScreen.main.bounds.width
        let ident = height * 0.02
        var lastBottom: CGFloat = 0
        
        scrollView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                                 left: view.leftAnchor,
                                 bottom: view.bottomAnchor,
                                 right: view.rightAnchor,
                                 paddingTop: view.safeAreaInsets.top)
        
        for index in 0..<views.count {
            switch views[index] {
            case is UILabel:
                let paddingTop = index == 0 ? lastBottom : lastBottom + ident
                self.scrollView.addSubview(views[index])
                views[index].anchor(top: scrollView.topAnchor,
                                    left: scrollView.leftAnchor,
                                    paddingTop: paddingTop,
                                    paddingLeft: width * 0.05,
                                    width: width * 0.9,
                                    height: height * 0.1)
                
                lastBottom = height * 0.1 + paddingTop
            case is Button:
                let but = views[index] as! Button
                let newButton = Button(frame: CGRect(x: width * 0.2,
                                                      y: lastBottom + ident,
                                                      width: width * 0.6,
                                                      height: height * 0.05))
                setupButton(newButton, but, height * 0.05 / 4)
                self.scrollView.addSubview(newButton)
                views[index] = newButton
                
                lastBottom += height * 0.05 + ident
            case is UIImageView:
                self.scrollView.addSubview(views[index])
                views[index].anchor(top: scrollView.topAnchor,
                                    left: scrollView.leftAnchor,
                                    paddingTop: lastBottom + ident,
                                    paddingLeft: width * 0.2,
                                    width: width * 0.6,
                                    height: width * 0.6)
                
                lastBottom += width * 0.6 + ident
            default:
                break
            }
        }
    }
    
    private func setupButton(_ button: Button, _ oldButton: Button, _ cornerRadius: CGFloat) {
        
        button.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
        button.layer.cornerRadius = cornerRadius
        button.setTitle(oldButton.information, for: .normal)
        button.id = oldButton.id
        button.addTarget(self,
                            action: #selector(buttonAction),
                            for: .touchUpInside)
    }
}
