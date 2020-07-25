//
//  CipherService.swift
//  Demo_RxSwift
//
//  Created by Maksims Peļņa on 07/05/2020.
//  Copyright © 2020 Maksims Peļņa. All rights reserved.
//

import Foundation

final class CipherService {
    private static let salt = [UInt8](repeating: 1, count: 255)

    class func encrypt(string: String) -> String {
        let text = [UInt8](string.utf8)
        var encrypted = [UInt8]()
        for (i, v) in text.enumerated() {
            encrypted.append(v ^ salt[i])
        }

        let data = Data(encrypted)
        return data.base64EncodedString()
    }

    class func decrypt(string: String) -> String? {
        guard let data = Data(base64Encoded: string) else { return nil }
        let encrypted = [UInt8](data)
        var decrypted = [UInt8]()

        for (i, v) in encrypted.enumerated() {
            decrypted.append(v ^ salt[i])
        }
        return String(bytes: decrypted, encoding: .utf8)
    }
}
