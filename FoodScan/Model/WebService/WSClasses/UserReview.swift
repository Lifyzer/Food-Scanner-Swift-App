//
//  UserReview.swift
//
//  Created by C100-168 on 06/11/19
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public final class UserReview: NSObject,NSCoding,JSONable {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let ratting = "ratting"
    static let lastName = "last_name"
    static let id = "id"
    static let firstName = "first_name"
    static let descriptionValue = "description"
    static let title = "title"
    static let modifiedDate = "modified_date"
  }

  // MARK: Properties
  public var ratting: String?
  public var lastName: String?
  public var id: String?
  public var firstName: String?
  public var descriptionValue: String?
  public var title: String?
  public var modifiedDate: String?

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
    ratting = json[SerializationKeys.ratting].string
    lastName = json[SerializationKeys.lastName].string
    id = json[SerializationKeys.id].string
    firstName = json[SerializationKeys.firstName].string
    descriptionValue = json[SerializationKeys.descriptionValue].string
    title = json[SerializationKeys.title].string
    modifiedDate = json[SerializationKeys.modifiedDate].string
  }

  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = ratting { dictionary[SerializationKeys.ratting] = value }
    if let value = lastName { dictionary[SerializationKeys.lastName] = value }
    if let value = id { dictionary[SerializationKeys.id] = value }
    if let value = firstName { dictionary[SerializationKeys.firstName] = value }
    if let value = descriptionValue { dictionary[SerializationKeys.descriptionValue] = value }
    if let value = title { dictionary[SerializationKeys.title] = value }
    if let value = modifiedDate { dictionary[SerializationKeys.modifiedDate] = value }
    return dictionary
  }

  // MARK: NSCoding Protocol
  required public init(coder aDecoder: NSCoder) {
    self.ratting = aDecoder.decodeObject(forKey: SerializationKeys.ratting) as? String
    self.lastName = aDecoder.decodeObject(forKey: SerializationKeys.lastName) as? String
    self.id = aDecoder.decodeObject(forKey: SerializationKeys.id) as? String
    self.firstName = aDecoder.decodeObject(forKey: SerializationKeys.firstName) as? String
    self.descriptionValue = aDecoder.decodeObject(forKey: SerializationKeys.descriptionValue) as? String
    self.title = aDecoder.decodeObject(forKey: SerializationKeys.title) as? String
    self.modifiedDate = aDecoder.decodeObject(forKey: SerializationKeys.modifiedDate) as? String
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(ratting, forKey: SerializationKeys.ratting)
    aCoder.encode(lastName, forKey: SerializationKeys.lastName)
    aCoder.encode(id, forKey: SerializationKeys.id)
    aCoder.encode(firstName, forKey: SerializationKeys.firstName)
    aCoder.encode(descriptionValue, forKey: SerializationKeys.descriptionValue)
    aCoder.encode(title, forKey: SerializationKeys.title)
    aCoder.encode(modifiedDate, forKey: SerializationKeys.modifiedDate)
  }

}
