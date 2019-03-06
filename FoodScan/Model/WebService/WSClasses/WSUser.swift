//
//  WSUser.swift
//
//  Created by C110 on 13/02/19
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public final class WSUser: NSObject, NSCoding, JSONable {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let email = "email"
    static let isTest = "is_test"
    static let isDelete = "is_delete"
    static let createdDate = "created_date"
    static let guid = "guid"
    static let modifiedDate = "modified_date"
    static let deviceType = "device_type"
    static let lastName = "last_name"
    static let userId = "id"
    static let firstName = "first_name"
    static let password = "password"
    static let deviceToken = "device_token"
    static let facebookId = "facebook_id"
    static let userImage = "user_image"
  }

  // MARK: Properties
  public var email: String?
  public var isTest: String?
  public var isDelete: String?
  public var createdDate: String?
  public var guid: String?
  public var modifiedDate: String?
  public var deviceType: String?
  public var lastName: String?
  public var userId: String?
  public var firstName: String?
  public var password: String?
  public var deviceToken: String?
  public var facebookId: String?
  public var userImage: String?

  // MARK: SwiftyJSON Initializers
  /// Initiates the instance based on the object.
  ///
  /// - parameter object: The object of either Dictionary or Array kind that was passed.
  /// - returns: An initialized instance of the class.
  public convenience init(object: Any) {
    self.init(parameter: JSON(object))
  }

  /// Initiates the instance based on the JSON that was passed.
  ///
  /// - parameter json: JSON object from SwiftyJSON.
  public required init(parameter json: JSON) {
    email = json[SerializationKeys.email].string
    isTest = json[SerializationKeys.isTest].string
    isDelete = json[SerializationKeys.isDelete].string
    createdDate = json[SerializationKeys.createdDate].string
    guid = json[SerializationKeys.guid].string
    modifiedDate = json[SerializationKeys.modifiedDate].string
    deviceType = json[SerializationKeys.deviceType].string
    lastName = json[SerializationKeys.lastName].string
    userId = json[SerializationKeys.userId].string
    firstName = json[SerializationKeys.firstName].string
    password = json[SerializationKeys.password].string
    deviceToken = json[SerializationKeys.deviceToken].string
    facebookId = json[SerializationKeys.facebookId].string
    userImage = json[SerializationKeys.userImage].string
  }

  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = email { dictionary[SerializationKeys.email] = value }
    if let value = isTest { dictionary[SerializationKeys.isTest] = value }
    if let value = isDelete { dictionary[SerializationKeys.isDelete] = value }
    if let value = createdDate { dictionary[SerializationKeys.createdDate] = value }
    if let value = guid { dictionary[SerializationKeys.guid] = value }
    if let value = modifiedDate { dictionary[SerializationKeys.modifiedDate] = value }
    if let value = deviceType { dictionary[SerializationKeys.deviceType] = value }
    if let value = lastName { dictionary[SerializationKeys.lastName] = value }
    if let value = userId { dictionary[SerializationKeys.userId] = value }
    if let value = firstName { dictionary[SerializationKeys.firstName] = value }
    if let value = password { dictionary[SerializationKeys.password] = value }
    if let value = deviceToken { dictionary[SerializationKeys.deviceToken] = value }
    if let value = facebookId { dictionary[SerializationKeys.facebookId] = value }
    if let value = userImage { dictionary[SerializationKeys.userImage] = value }
    return dictionary
  }

  // MARK: NSCoding Protocol
  required public init(coder aDecoder: NSCoder) {
    self.email = aDecoder.decodeObject(forKey: SerializationKeys.email) as? String
    self.isTest = aDecoder.decodeObject(forKey: SerializationKeys.isTest) as? String
    self.isDelete = aDecoder.decodeObject(forKey: SerializationKeys.isDelete) as? String
    self.createdDate = aDecoder.decodeObject(forKey: SerializationKeys.createdDate) as? String
    self.guid = aDecoder.decodeObject(forKey: SerializationKeys.guid) as? String
    self.modifiedDate = aDecoder.decodeObject(forKey: SerializationKeys.modifiedDate) as? String
    self.deviceType = aDecoder.decodeObject(forKey: SerializationKeys.deviceType) as? String
    self.lastName = aDecoder.decodeObject(forKey: SerializationKeys.lastName) as? String
    self.userId = aDecoder.decodeObject(forKey: SerializationKeys.userId) as? String
    self.firstName = aDecoder.decodeObject(forKey: SerializationKeys.firstName) as? String
    self.password = aDecoder.decodeObject(forKey: SerializationKeys.password) as? String
    self.deviceToken = aDecoder.decodeObject(forKey: SerializationKeys.deviceToken) as? String
    self.facebookId = aDecoder.decodeObject(forKey: SerializationKeys.facebookId) as? String
    self.userImage = aDecoder.decodeObject(forKey: SerializationKeys.userImage) as? String
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(email, forKey: SerializationKeys.email)
    aCoder.encode(isTest, forKey: SerializationKeys.isTest)
    aCoder.encode(isDelete, forKey: SerializationKeys.isDelete)
    aCoder.encode(createdDate, forKey: SerializationKeys.createdDate)
    aCoder.encode(guid, forKey: SerializationKeys.guid)
    aCoder.encode(modifiedDate, forKey: SerializationKeys.modifiedDate)
    aCoder.encode(deviceType, forKey: SerializationKeys.deviceType)
    aCoder.encode(lastName, forKey: SerializationKeys.lastName)
    aCoder.encode(userId, forKey: SerializationKeys.userId)
    aCoder.encode(firstName, forKey: SerializationKeys.firstName)
    aCoder.encode(password, forKey: SerializationKeys.password)
    aCoder.encode(deviceToken, forKey: SerializationKeys.deviceToken)
    aCoder.encode(facebookId, forKey: SerializationKeys.facebookId)
    aCoder.encode(userImage, forKey: SerializationKeys.userImage)
  }

}
