//
//  DogListDetail.swift
//  TheDog
//
//  Created by 山本雅浩 on 2024/02/02.
//

import Foundation

class Dog {
    func dogList() async -> Result<DogResponse, DogError> {
        guard let url = URL(string: "https://dog.ceo/api/breeds/list/all") else {
            return .failure(.invalidURL)
        }

        do {
            let (data,_) = try await URLSession.shared.data(from: url)
            let decoder = JSONDecoder()
            let dogResponse = try decoder.decode(DogResponse.self, from: data)
            print(dogResponse)
            return .success(dogResponse)
        } catch {
            return .failure(.decodingError)
        }
    }
    
    func printDogList(dogResponse: DogResponse) {
        print("Dog Breeds:")
        for breed in dogResponse.message.keys {
            print("- \(breed)")
        }
    }
}


