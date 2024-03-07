//
//  File.swift
//  TheDog
//
//  Created by 山本雅浩 on 2024/02/04.
//

import Foundation
import UIKit
import Alamofire
import AlamofireImage

class DogPhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var dogImageView: UIImageView!
    
    func configure(with url: URL) {
        AF.request(url).responseImage { [weak self] response in
            switch response.result {
            case .success(let image):
                self?.dogImageView.image = image
            case .failure(let error):
                print("Error loading image: \(error)")
            }
        }
    }
}
