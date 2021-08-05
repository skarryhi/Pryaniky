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
//            return URL(string: "https://global-exchange.store/test.json")!
//            return URL(string: "https://pryaniky.com")!
//            return URL(string: "https://pryaniky.com/static/json/much-more-items-in-data.json")!
        return URL(string: "https://pryaniky.com/static/json/custom-data-in-view.json")!
        }
    }
    
    var path: String {
        switch self {
        case .getUser:
            return ""
//            return "/static/json/sample.json"
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
