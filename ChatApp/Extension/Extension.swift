//
//  Extensions.swift
//  ChatApp
//
//  Created by Sovorn on 9/13/18.
//  Copyright © 2018 Sovorn. All rights reserved.
//

import UIKit

let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
    func loadImageViewCacheWithUrlString(urlString: String){
        
        self.image = nil
        
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            self.image = cachedImage
            return
        }
        
        
        let myUrl = URL(string: urlString)
        let requestUrl = URLRequest(url: myUrl!)
        
        URLSession.shared.dataTask(with: requestUrl) { (data, response, error) in
            
            if error != nil {
                print(error!)
                return
            }
            
            DispatchQueue.main.async {
                if let downloadImage = UIImage(data: data!) {
                    imageCache.setObject(downloadImage, forKey: urlString as NSString)
                    self.image = downloadImage
                }
                //                    cell.imageView?.image = UIImage(data: data!)
                
            }
            }.resume()
    }
}
