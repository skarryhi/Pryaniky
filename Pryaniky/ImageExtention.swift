//
//  ImageExtention.swift
//  Pryaniky
//
//  Created by Анна Заблуда on 31.07.2021.
//

import Foundation
import UIKit
import Alamofire

extension UIImageView {
    public func imageFromUrl(urlString: String) {
        if let url = NSURL(string: urlString) {
            let request = NSURLRequest(url: url as URL)
            NSURLConnection.sendAsynchronousRequest(request as URLRequest, queue: NSOperationQueue.mainQueue) {
                (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
                self.image = UIImage(data: data as Data)
            }
        }
    }
}
