//
//  String.swift
//  Bazinga
//
//  Created by C110 on 15/12/17.
//  Copyright © 2017 C110. All rights reserved.
//

import UIKit

extension String: Error {}

extension String {

    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }


    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return ""
        }

        return String(data: data, encoding: .utf8)
    }

    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }

    func isValid() -> Bool {
        return (self.isEmpty || self == "" || self == nil || self == "(null)") ? false : true

    }

    func isBegin(with string:NSString) -> Bool {
        return self.hasPrefix(string as String) ? true : false
    }

    func isEnd(With string : NSString) -> Bool {
        return self.hasSuffix(string as String) ? true : false
    }

    /**
     Check email
     */
    func isValidEmail() -> Bool {
        let regex : NSString = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)

        return predicate.evaluate(with: self)
    }

    /**
     phone number
     */
    func isValidPhoneNumber() -> Bool {
        let regex : NSString = "[235689][0-9]{6}([0-9]{3})?"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)

        return predicate.evaluate(with: self)
    }

    /**
     url
     */
    func isValidUrl() -> Bool {
        let regex : NSString = "(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)

        return predicate.evaluate(with: self)
    }

    func substring(_ startIndex: Int, length: Int) -> String {
        let start = self.characters.index(self.startIndex, offsetBy: startIndex)
        let end = self.characters.index(self.startIndex, offsetBy: startIndex + length)
        return String(self[start..<end])
    }
}

public func stringToNumber(string: String) -> NSNumber{
    let strNumber = "0"
    if string.count == 0{
        return NumberFormatter().number(from: strNumber)!.decimalValue as NSNumber
    }else {
        return NumberFormatter().number(from: string)!.decimalValue as NSNumber
    }

}
/*
 Will generate radom string based on length
 */
public func randomString(length: Int) -> String {

    let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    let len = UInt32(letters.length)
    var randomString = ""
    for _ in 0 ..< length {
        let rand = arc4random_uniform(len)
        var nextChar = letters.character(at: Int(rand))
        randomString += NSString(characters: &nextChar, length: 1) as String
    }
    return randomString
}

public func convertToDictionary(text: String) -> [String: Any]? {
    if let data = text.data(using: .utf8) {
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } catch {
            print(error.localizedDescription)
        }
    }
    return nil
}

public func convertToArray(text: String) -> [[String: Any]]? {
    if let data = text.data(using: .utf8) {
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]]
        } catch {
            print(error.localizedDescription)
        }
    }
    return nil
}
