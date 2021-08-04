//
//  TableViewCell.swift
//  Pryaniky
//
//  Created by Анна Заблуда on 04.08.2021.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    private let height = UIScreen.main.bounds.height
    private let width = UIScreen.main.bounds.width
    
    lazy var label: UILabel = {
        let lbl = UILabel(frame: CGRect(x: width * 0.02,
                                        y: height * 0.01,
                                        width: width * 0.96,
                                        height: height * 0.13))
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        lbl.backgroundColor = .yellow
        addSubview(lbl)
        return lbl
    }()
    
    lazy var image: UIImageView = {
        let img = UIImageView(frame: CGRect(x: width * 0.2,
                                            y: height * 0.01,
                                            width: width * 0.6,
                                            height: width * 0.56))
        addSubview(img)
        return img
    }()
    
    lazy var picker: UIPickerView = {
        let pick = UIPickerView(frame: CGRect(x: width * 0.02,
                                              y: height * 0.01,
                                              width: width * 0.96,
                                              height: height * 0.28))
        pick.isHidden = true
        
        addSubview(pick)
        return pick
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setupConstraints(_ myView: UIView) {
        myView.anchor(top:  topAnchor,
                            left: leftAnchor,
                            bottom: bottomAnchor,
                            right: rightAnchor,
                            paddingTop: height * 0.01,
                            paddingLeft: width * 0.2,
                            paddingBottom: height * 0.01,
                            paddingRight: width * 0.2)
    }

}
