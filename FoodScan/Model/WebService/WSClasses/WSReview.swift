//
//  Product.swift
//
//  Created by C100-168 on 06/11/19
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public final class WSReview: NSObject,NSCoding,JSONable {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let totalReview = "total_review"
    static let totalUser = "total_user"
    static let userReview = "user_review"
    static let customerReview = "customer_review"
    static let avgReview = "avg_review"
  }

  // MARK: Properties
  public var totalReview: String?
  public var totalUser: String?
  public var userReview: [UserReview]?
  public var customerReview: [CustomerReview]?
  public var avgReview: String?

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
    totalReview = json[SerializationKeys.totalReview].string
    totalUser = json[SerializationKeys.totalUser].string
        if let items = json[SerializationKeys.userReview].array { userReview = items.map { UserReview(parameter: $0) } }
        if let items = json[SerializationKeys.customerReview].array { customerReview = items.map { CustomerReview(parameter: $0) } }
    avgReview = json[SerializationKeys.avgReview].string
  }

  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = totalReview { dictionary[SerializationKeys.totalReview] = value }
    if let value = totalUser { dictionary[SerializationKeys.totalUser] = value }
    if let value = userReview { dictionary[SerializationKeys.userReview] = value.map { $0.dictionaryRepresentation() } }
    if let value = customerReview { dictionary[SerializationKeys.customerReview] = value.map { $0.dictionaryRepresentation() } }
    if let value = avgReview { dictionary[SerializationKeys.avgReview] = value }
    return dictionary
  }

  // MARK: NSCoding Protocol
  required public init(coder aDecoder: NSCoder) {
    self.totalReview = aDecoder.decodeObject(forKey: SerializationKeys.totalReview) as? String
    self.totalUser = aDecoder.decodeObject(forKey: SerializationKeys.totalUser) as? String
    self.userReview = aDecoder.decodeObject(forKey: SerializationKeys.userReview) as? [UserReview]
    self.customerReview = aDecoder.decodeObject(forKey: SerializationKeys.customerReview) as? [CustomerReview]
    self.avgReview = aDecoder.decodeObject(forKey: SerializationKeys.avgReview) as? String
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(totalReview, forKey: SerializationKeys.totalReview)
    aCoder.encode(totalUser, forKey: SerializationKeys.totalUser)
    aCoder.encode(userReview, forKey: SerializationKeys.userReview)
    aCoder.encode(customerReview, forKey: SerializationKeys.customerReview)
    aCoder.encode(avgReview, forKey: SerializationKeys.avgReview)
  }

}
