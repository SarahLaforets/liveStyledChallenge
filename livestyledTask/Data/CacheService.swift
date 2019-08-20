//
//  CacheService.swift
//  livestyledTask
//
//  Created by Sarah LAFORETS on 20/08/2019.
//  Copyright © 2019 Sarah LAFORETS. All rights reserved.
//

import Foundation

enum ErrorState {
    case network
    case parsing
}

enum Result<T> {
    case success(T)
    case failure(ErrorState)
}

protocol CacheFetching {
    func getCache(from fileName: String, completion: @escaping ((Result<Data>) -> Void))
    func saveDataToCache(with data: Data, fileName: String)
}

class CacheService: CacheFetching {
    
    static let path = "Cache/"
    static let fileExtension = ".json"
    
    func saveDataToCache(with data: Data, fileName: String) {
        let file: FileHandle? = FileHandle(forWritingAtPath: "\(fileName)\(CacheService.fileExtension)")
        
        if let file = file {
            file.write(data)
            file.closeFile()
        } else {
            let writeResult = writeToFile(fileName: fileName, data: data)
            switch writeResult {
            case .success(_):
                break
            case .failure(let errorState):
                assertionFailure("\(errorState)")
                break
            }
        }
    }
    
    func getCache(from fileName: String, completion: @escaping ((Result<Data>) -> Void)) {
        let readResult = readFromFile(fileName: fileName)
        
        switch readResult {
        case .success(let data):
            completion(.success(data))
        case .failure(let error):
            completion(.failure(error))
        }
    }
    
    private func readFromFile(fileName: String) -> Result<Data> {
        
        let path = try! FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        
        let fileURL = path.appendingPathComponent(fileName).appendingPathExtension("json")
        
        if !(fileExist(path: fileURL.path)) {
            return .failure(.parsing)
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            return .success(data)
        } catch {
            return .failure(.parsing)
        }
    }
    
    private func fileExist(path: String) -> Bool {
        var isDirectory: ObjCBool = false
        let fm = FileManager.default
        return (fm.fileExists(atPath: path, isDirectory: &isDirectory))
    }
    
    private func writeToFile(fileName: String, data: Data) -> Result<Bool> {
        let path = try! FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let fileURL = path.appendingPathComponent(fileName).appendingPathExtension("json")
        
        do {
            try data.write(to: fileURL, options: .atomic)
        } catch let error as NSError {
            print("Error: fileURL failed to write: \n\(error)" )
            return .failure(.parsing)
        }
        return .success(true)
    }
}
