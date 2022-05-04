#if canImport(UIKit)

import Foundation

internal protocol ClientSessionServiceProtocol {
    func requestPrimerConfigurationWithActions(actionsRequest: ClientSessionUpdateRequest, completion: @escaping (PrimerConfiguration?, Error?) -> Void)
    func requestPrimerConfigurationWithActions(actionsRequest: ClientSessionUpdateRequest) -> Promise<PrimerConfiguration>
}

internal class ClientSessionService: ClientSessionServiceProtocol {
    
    func requestPrimerConfigurationWithActions(actionsRequest: ClientSessionUpdateRequest, completion: @escaping (PrimerConfiguration?, Error?) -> Void) {
        self.requestPrimerConfigurationWithActions(actionsRequest, completion: completion)
    }
    
    func requestPrimerConfigurationWithActions(actionsRequest: ClientSessionUpdateRequest) -> Promise<PrimerConfiguration> {
        return Promise { seal in
            self.requestPrimerConfigurationWithActions(actionsRequest, completion: { configuration, err in
                if let err = err {
                    seal.reject(err)
                } else if let configuration = configuration {
                    seal.fulfill(configuration)
                }
            })
        }
    }
}

extension ClientSessionService {
    
    // MARK: - API Request
    
    private func requestPrimerConfigurationWithActions(_ request: ClientSessionUpdateRequest, completion: @escaping (PrimerConfiguration?, Error?) -> Void) {
        
        guard let decodedClientToken = ClientTokenService.decodedClientToken else {
            let err = PrimerError.invalidClientToken(userInfo: ["file": #file, "class": "\(Self.self)", "function": #function, "line": "\(#line)"])
            ErrorHandler.handle(error: err)
            completion(nil, err)
            return
        }
        
        let api: PrimerAPIClientProtocol = DependencyContainer.resolve()
        api.requestPrimerConfigurationWithActions(clientToken: decodedClientToken, request: request) { result in
            switch result {
            case .success(let configuration):
                completion(configuration, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
}

#endif
