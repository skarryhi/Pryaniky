//
//  MyPlayButton.swift
//  Pryaniky
//
//  Created by Анна Заблуда on 05.08.2021.
//

import UIKit

final class MyPlayButton: UIButton {
    let cellIndex: IndexPath
    var isPlayed = false {
        didSet {
            if isPlayed {
                self.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            } else {
                self.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            }
        }
    }
    
    init(frame: CGRect, cell index: IndexPath) {
        cellIndex = index
        super.init(frame: frame)
        self.setImage(#imageLiteral(resourceName: "play"), for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
