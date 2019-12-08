//
//  ImagesExtension.swift
//  Anime List
//
//  Created by Aaron Treinish on 12/5/19.
//  Copyright © 2019 Aaron Treinish. All rights reserved.
//

import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()

class CustomImageView: UIImageView {

    var imageUrlString: String?

    func loadImageUsingCacheWithUrlString(urlString: String) {

        imageUrlString = urlString

        guard let url = NSURL(string: urlString) else { return }

        // Check cache for image
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            self.image = cachedImage
            return
        }

        // Otherwise download images
        URLSession.shared.dataTask(with: url as URL, completionHandler: {(data, response, error) in
            guard let data = data, let imageToCache = UIImage(data: data) else { return }

            if error != nil {
                print(error?.localizedDescription ?? "Error")
                return
            }
            DispatchQueue.main.async {
                if self.imageUrlString == urlString {
                    self.image = imageToCache
                }
                imageCache.setObject(imageToCache, forKey: urlString as AnyObject)
            }
        }).resume()
    }
}

