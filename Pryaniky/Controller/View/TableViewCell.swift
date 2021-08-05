//
//  TableViewCell.swift
//  Pryaniky
//
//  Created by Анна Заблуда on 04.08.2021.
//

import UIKit
import AVKit

class TableViewCell: UITableViewCell {
    
    private let height = UIScreen.main.bounds.height
    private let width = UIScreen.main.bounds.width
    
    var mediaUrl: URL?
    var playerLayer: AVPlayerLayer?
    var player: AVPlayer?
    
    var playButton: MyPlayButton? {
        didSet {
            playButton!.isHidden = true
            contentView.addSubview(playButton!)
        }
    }
    
    lazy var media: UIView = {
        let view = UIView(frame: CGRect(x: 0,
                                        y: 0,
                                        width: width,
                                        height: width * 0.6))
        return view
    }()
    
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
        addSubview(media)
        return img
    }()
    
    lazy var picker: UIPickerView = {
        let pick = UIPickerView(frame: CGRect(x: width * 0.15,
                                              y: height * 0.01,
                                              width: width * 0.7,
                                              height: height * 0.28))
        pick.isHidden = true
        
        contentView.addSubview(pick)
        return pick
    }()

}
