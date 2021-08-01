//
//  ApiWorking.swift
//  Pryaniky
//
//  Created by Анна Заблуда on 31.07.2021.
//

import Foundation
import Moya
import Alamofire

final class ApiManager {
    
    private let userProvider = MoyaProvider<UserService>()
    var delegate: ApiManagerDelegate?
    
    func loadingData() {
        userProvider.request(.getUser) { result in
            switch result {
            case .success(let response) :
                if let user = try? JSONDecoder().decode(JsonModel.self, from: response.data) {
                    self.delegate?.updateData(user)
                }
            case .failure(let error) : print(error)
            }
        }
    }
    
    func downloadImages(imageURL: String, completion: @escaping (UIImage?) -> Void) {
        AF.request(imageURL, method: .get)
            .validate()
            .responseData(completionHandler: { (responseData) in
                guard let _ = responseData.data else {print("no image"); return}
                let image = UIImage(data: responseData.data!)
                    completion(image)
            })
    }
}
