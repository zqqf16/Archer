//
//  Rule.swift
//  Archer
//
//  Created by zqqf16 on 2017/3/8.
//  Copyright © 2017年 zorro.im. All rights reserved.
//

import Foundation


extension HttpServer {
    static let shared = HttpServer()
}

extension Dictionary {
    static func contentsOf(path: URL) -> [String: AnyObject]? {
        if let data = try? Data(contentsOf: path) {
            if let result = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: AnyObject] {
                return result
            }
        }
        return nil
    }
    
    func writeTo(path: URL) {
        if let data = try? PropertyListSerialization.data(fromPropertyList: self, format: .xml, options: 0) {
            try? data.write(to: path)
        }
    }
}


protocol RuleManagerDelegate: class {
    func didAddRule() -> Void
}

enum MockResponse {
    case json(String)
    case xml(String)
    case file(String)
    
    func contentType() -> String {
        switch self {
        case .json(_):
            return "application/json"
        case .xml(_):
            return "application/xml"
        case .file(let path):
            return path.contentTypeByPath()
        }
    }
    
    func handler() -> ((HttpRequest) -> HttpResponse) {
        switch self {
        case .json(let content):
            return { r in
                .ok(.text(content))
            }
        case .xml(let content):
            return { r in
                .ok(.text(content))
            }
        case .file(let path):
            return { r in
                do {
                    guard try path.exists() else {
                        return .notFound
                    }
                } catch {
                    return .internalServerError
                }
                
                if let file = try? path.openForReading() {
                    return .raw(200, "OK", ["Content-Type": self.contentType()], { writer in
                        try? writer.write(file)
                        file.close()
                    })
                }
                
                return .notFound
            }
        }
    }
    
    func serialize() -> [String] {
        switch self {
        case .json(let content):
            return ["JSON", content]
        case .xml(let content):
            return ["XML", content]
        case .file(let path):
            return ["FILE", path]
        }
    }
    
    static func deserialize(_ raw: AnyObject) -> MockResponse? {
        guard let list = raw as? [String], list.count > 1 else {
            return nil
        }
        
        let type = list[0].uppercased()
        if type == "JSON" {
            return .json(list[1])
        } else if type == "XML" {
            return .xml(list[1])
        } else if type == "FILE" {
            return .file(list[1])
        }
        
        return nil
    }
}


class RuleManager {
    
    static let shared = RuleManager()
    
    var rules: [String: MockResponse] = [:]
    
    weak var delegate: RuleManagerDelegate?
    
    private let fileURL = URL(fileURLWithPath: NSHomeDirectory()+String.pathSeparator+".archer.plist")
    
    init() {
        self.load()
    }
    
    func add(_ path: String, mock: MockResponse) {
        self.rules[path] = mock
        HttpServer.shared[path] = mock.handler()
        
        self.save()
        
        if let delegate = self.delegate {
            delegate.didAddRule()
        }
    }
    
    func remove(_ path: String) {
        HttpServer.shared[path] = nil
        self.rules[path] = nil
        
        self.save()
    }
    
    func save() {
        DispatchQueue.global().async {
            var rules: [String: AnyObject] = [:]
            for (k, v) in self.rules {
                rules[k] = v.serialize() as AnyObject
            }

            rules.writeTo(path: self.fileURL)
        }
    }
    
    func load() {
        let rules = Dictionary<String, AnyObject>.contentsOf(path: self.fileURL) ?? [:]
        self.rules = [:]

        for (k, v) in rules {
            if let mock = MockResponse.deserialize(v as AnyObject) {
                self.add(k, mock: mock)
            }
        }
    }
}
