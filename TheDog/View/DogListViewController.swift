//
//  ViewController.swift
//  TheDog
//
//  Created by 山本雅浩 on 2024/02/02.
//

import UIKit

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    
    @IBOutlet weak var dogList: UITableView!
    
    var dogResponse: DogResponse?
    var dog = Dog()
    
    private var breeds = [String]()
    private var selectedBreed: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dogList.delegate = self
        dogList.dataSource = self
        
        fetchDogList()
    }
    
    func fetchDogList() {
        Task {
            let result = await dog.dogList()
            switch result {
            case .success(let dogResponse):
                self.dogResponse = dogResponse
                self.breeds = dogResponse.message.keys.sorted()
                self.dogList.reloadData()
            case .failure(let error):
                print("Error fetching dog list: \(error)")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dogResponse?.message.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if breeds.indices.contains(indexPath.row) {
            let breed = breeds[indexPath.row]
            cell.textLabel?.text = breed
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        print(breeds[indexPath.row])
        selectedBreed = breeds[indexPath.row]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDogPhoto" {
            if let destinationVC = segue.destination as? DogPhotoViewController {
                destinationVC.selectedBreed = selectedBreed
            }
        }
    }
    
}

