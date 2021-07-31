//
//  MoyaService.swift
//  Pryaniky
//
//  Created by Анна Заблуда on 31.07.2021.
//

import Moya

enum UserService {
    case getUser
}

extension UserService: TargetType {
    var baseURL: URL {
        switch self {
        case .getUser:
            return URL(string: "https://pryaniky.com")!
        }
    }
    
    var path: String {
        switch self {
        case .getUser:
            return "/static/json/sample.json"
        }
    }
    
    var method: Method {
        switch self {
        case .getUser:
            return .get
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .getUser:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .getUser:
            return nil
        }
    }
    
    
}
