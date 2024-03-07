//
//  DogPhotoViewController.swift
//  TheDog
//
//  Created by 山本雅浩 on 2024/02/03.
//

import UIKit
import Alamofire
import AlamofireImage

class DogPhotoViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var dogPhoto: UICollectionView!
    
    var imageURLs: [URL] = []
    var selectedBreed: String?
    
    private let itemsPerRow: CGFloat = 2
    private var selectedIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dogPhoto.delegate = self
        dogPhoto.dataSource = self
        
        Task {
            await fetchDogPhotos()
        }
    }
    
    func fetchDogPhotos() async {
        guard let selectedBreed = selectedBreed else {
            print("Error: selectedBreed is nil.")
            return
        }
        
        let apiUrl = "https://dog.ceo/api/breed/\(selectedBreed)/images"
        print(apiUrl)
        
        do {
            let photoResponse = try await AF.request(apiUrl).serializingDecodable(PhotoResponse.self).value
            
            imageURLs = photoResponse.message.compactMap { URL(string: $0) }
            dogPhoto.reloadData()
        } catch {
            print("Error fetching dog photos: \(error)")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageURLs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dogPhoto", for: indexPath) as! DogPhotoCell
        cell.configure(with: imageURLs[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = UIScreen.main.bounds.width / 2
        let height = width
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetail" {
            if let destinationVC = segue.destination as? DogDetailViewController {
                destinationVC.imageURLs = imageURLs
                destinationVC.selectedIndex = selectedIndex
            }
        }
    }
}
