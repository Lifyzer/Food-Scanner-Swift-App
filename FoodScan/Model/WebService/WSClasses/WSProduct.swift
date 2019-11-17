//
//  WSProduct.swift
//
//  Created by C110 on 18/02/19
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public final class WSProduct: NSObject, NSCoding, JSONable {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let ingredients = "ingredients"
    static let licenseNo = "license_no"
    static let isDelete = "is_delete"
    static let dietaryFiber = "dietary_fiber"
    static let favouriteId = "favourite_id"
    static let categoryId = "category_id"
    static let sodium = "sodium"
    static let sugar = "sugar"
    static let modifiedDate = "modified_date"
    static let favouriteCreatedDate = "favourite_created_date"
    static let isOrganic = "is_organic"
    static let barcodeId = "barcode_id"
    static let fatAmount = "fat_amount"
    static let id = "id"
    static let proteinAmount = "protein_amount"
    static let companyName = "company_name"
    static let isFavourite = "is_favourite"
    static let saturatedFats = "saturated_fats"
    static let protein = "protein"
    static let salt = "salt"
    static let isTest = "is_test"
    static let carbohydrate = "carbohydrate"
    static let isHealthy = "is_healthy"
    static let createdDate = "created_date"
    static let productName = "product_name"
    static let calories = "calories"
    static let productId = "product_id"
    static let userId = "user_id"
    static let productImage = "product_image"
    static let alcohol = "alcohol"
    static let historyCreatedDate = "history_created_date"
    static let historyId = "history_id"
    static let totalReview = "total_review"
    static let avgReview = "avg_review"
  }

  // MARK: Properties
  public var ingredients: String?
  public var licenseNo: String?
  public var isDelete: String?
  public var dietaryFiber: String?
  public var favouriteId: String?
  public var categoryId: String?
  public var sodium: String?
  public var sugar: String?
  public var modifiedDate: String?
  public var favouriteCreatedDate: String?
  public var isOrganic: String?
  public var barcodeId: String?
  public var fatAmount: String?
  public var id: String?
  public var proteinAmount: String?
  public var companyName: String?
  public var isFavourite: Int?
  public var saturatedFats: String?
  public var protein: String?
  public var salt: String?
  public var isTest: String?
  public var carbohydrate: String?
  public var isHealthy: String?
  public var createdDate: String?
  public var productName: String?
  public var calories: String?
  public var productId: String?
  public var userId: String?
  public var productImage: String?
  public var alcohol: String?
  public var historyCreatedDate: String?
  public var historyId: String?
  public var totalReview: String?
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
    ingredients = json[SerializationKeys.ingredients].string
    licenseNo = json[SerializationKeys.licenseNo].string
    isDelete = json[SerializationKeys.isDelete].string
    dietaryFiber = json[SerializationKeys.dietaryFiber].string
    favouriteId = json[SerializationKeys.favouriteId].string
    categoryId = json[SerializationKeys.categoryId].string
    sodium = json[SerializationKeys.sodium].string
    sugar = json[SerializationKeys.sugar].string
    modifiedDate = json[SerializationKeys.modifiedDate].string
    favouriteCreatedDate = json[SerializationKeys.favouriteCreatedDate].string
    isOrganic = json[SerializationKeys.isOrganic].string
    barcodeId = json[SerializationKeys.barcodeId].string
    fatAmount = json[SerializationKeys.fatAmount].string
    id = json[SerializationKeys.id].string
    proteinAmount = json[SerializationKeys.proteinAmount].string
    companyName = json[SerializationKeys.companyName].string
    isFavourite = json[SerializationKeys.isFavourite].int
    saturatedFats = json[SerializationKeys.saturatedFats].string
    protein = json[SerializationKeys.protein].string
    salt = json[SerializationKeys.salt].string
    isTest = json[SerializationKeys.isTest].string
    carbohydrate = json[SerializationKeys.carbohydrate].string
    isHealthy = json[SerializationKeys.isHealthy].string
    createdDate = json[SerializationKeys.createdDate].string
    productName = json[SerializationKeys.productName].string
    calories = json[SerializationKeys.calories].string
    productId = json[SerializationKeys.productId].string
    userId = json[SerializationKeys.userId].string
    productImage = json[SerializationKeys.productImage].string
    alcohol = json[SerializationKeys.alcohol].string
    historyId = json[SerializationKeys.historyId].string
    historyCreatedDate = json[SerializationKeys.historyCreatedDate].string
    totalReview = json[SerializationKeys.totalReview].string
    avgReview = json[SerializationKeys.avgReview].string

  }

  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = ingredients { dictionary[SerializationKeys.ingredients] = value }
    if let value = licenseNo { dictionary[SerializationKeys.licenseNo] = value }
    if let value = isDelete { dictionary[SerializationKeys.isDelete] = value }
    if let value = dietaryFiber { dictionary[SerializationKeys.dietaryFiber] = value }
    if let value = favouriteId { dictionary[SerializationKeys.favouriteId] = value }
    if let value = categoryId { dictionary[SerializationKeys.categoryId] = value }
    if let value = sodium { dictionary[SerializationKeys.sodium] = value }
    if let value = sugar { dictionary[SerializationKeys.sugar] = value }
    if let value = modifiedDate { dictionary[SerializationKeys.modifiedDate] = value }
    if let value = favouriteCreatedDate { dictionary[SerializationKeys.favouriteCreatedDate] = value }
    if let value = isOrganic { dictionary[SerializationKeys.isOrganic] = value }
    if let value = barcodeId { dictionary[SerializationKeys.barcodeId] = value }
    if let value = fatAmount { dictionary[SerializationKeys.fatAmount] = value }
    if let value = id { dictionary[SerializationKeys.id] = value }
    if let value = proteinAmount { dictionary[SerializationKeys.proteinAmount] = value }
    if let value = companyName { dictionary[SerializationKeys.companyName] = value }
    if let value = isFavourite { dictionary[SerializationKeys.isFavourite] = value }
    if let value = saturatedFats { dictionary[SerializationKeys.saturatedFats] = value }
    if let value = protein { dictionary[SerializationKeys.protein] = value }
    if let value = salt { dictionary[SerializationKeys.salt] = value }
    if let value = isTest { dictionary[SerializationKeys.isTest] = value }
    if let value = carbohydrate { dictionary[SerializationKeys.carbohydrate] = value }
    if let value = isHealthy { dictionary[SerializationKeys.isHealthy] = value }
    if let value = createdDate { dictionary[SerializationKeys.createdDate] = value }
    if let value = productName { dictionary[SerializationKeys.productName] = value }
    if let value = calories { dictionary[SerializationKeys.calories] = value }
    if let value = productId { dictionary[SerializationKeys.productId] = value }
    if let value = userId { dictionary[SerializationKeys.userId] = value }
    if let value = productImage { dictionary[SerializationKeys.productImage] = value }
    if let value = alcohol { dictionary[SerializationKeys.alcohol] = value }
    if let value = historyId { dictionary[SerializationKeys.historyId] = value }
    if let value = historyCreatedDate { dictionary[SerializationKeys.historyCreatedDate] = value }
    if let value = totalReview { dictionary[SerializationKeys.totalReview] = value }
    if let value = avgReview { dictionary[SerializationKeys.avgReview] = value }
   
    return dictionary
  }

  // MARK: NSCoding Protocol
  required public init(coder aDecoder: NSCoder) {
    self.ingredients = aDecoder.decodeObject(forKey: SerializationKeys.ingredients) as? String
    self.licenseNo = aDecoder.decodeObject(forKey: SerializationKeys.licenseNo) as? String
    self.isDelete = aDecoder.decodeObject(forKey: SerializationKeys.isDelete) as? String
    self.dietaryFiber = aDecoder.decodeObject(forKey: SerializationKeys.dietaryFiber) as? String
    self.favouriteId = aDecoder.decodeObject(forKey: SerializationKeys.favouriteId) as? String
    self.categoryId = aDecoder.decodeObject(forKey: SerializationKeys.categoryId) as? String
    self.sodium = aDecoder.decodeObject(forKey: SerializationKeys.sodium) as? String
    self.sugar = aDecoder.decodeObject(forKey: SerializationKeys.sugar) as? String
    self.modifiedDate = aDecoder.decodeObject(forKey: SerializationKeys.modifiedDate) as? String
    self.favouriteCreatedDate = aDecoder.decodeObject(forKey: SerializationKeys.favouriteCreatedDate) as? String
    self.isOrganic = aDecoder.decodeObject(forKey: SerializationKeys.isOrganic) as? String
    self.barcodeId = aDecoder.decodeObject(forKey: SerializationKeys.barcodeId) as? String
    self.fatAmount = aDecoder.decodeObject(forKey: SerializationKeys.fatAmount) as? String
    self.id = aDecoder.decodeObject(forKey: SerializationKeys.id) as? String
    self.proteinAmount = aDecoder.decodeObject(forKey: SerializationKeys.proteinAmount) as? String
    self.companyName = aDecoder.decodeObject(forKey: SerializationKeys.companyName) as? String
    self.isFavourite = aDecoder.decodeObject(forKey: SerializationKeys.isFavourite) as? Int
    self.saturatedFats = aDecoder.decodeObject(forKey: SerializationKeys.saturatedFats) as? String
    self.protein = aDecoder.decodeObject(forKey: SerializationKeys.protein) as? String
    self.salt = aDecoder.decodeObject(forKey: SerializationKeys.salt) as? String
    self.isTest = aDecoder.decodeObject(forKey: SerializationKeys.isTest) as? String
    self.carbohydrate = aDecoder.decodeObject(forKey: SerializationKeys.carbohydrate) as? String
    self.isHealthy = aDecoder.decodeObject(forKey: SerializationKeys.isHealthy) as? String
    self.createdDate = aDecoder.decodeObject(forKey: SerializationKeys.createdDate) as? String
    self.productName = aDecoder.decodeObject(forKey: SerializationKeys.productName) as? String
    self.calories = aDecoder.decodeObject(forKey: SerializationKeys.calories) as? String
    self.productId = aDecoder.decodeObject(forKey: SerializationKeys.productId) as? String
    self.userId = aDecoder.decodeObject(forKey: SerializationKeys.userId) as? String
    self.productImage = aDecoder.decodeObject(forKey: SerializationKeys.productImage) as? String
    self.alcohol = aDecoder.decodeObject(forKey: SerializationKeys.alcohol) as? String
     self.historyId = aDecoder.decodeObject(forKey: SerializationKeys.historyId) as? String
     self.historyCreatedDate = aDecoder.decodeObject(forKey: SerializationKeys.historyCreatedDate) as? String
    self.totalReview = aDecoder.decodeObject(forKey: SerializationKeys.totalReview) as? String
    self.avgReview = aDecoder.decodeObject(forKey: SerializationKeys.avgReview) as? String
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(ingredients, forKey: SerializationKeys.ingredients)
    aCoder.encode(licenseNo, forKey: SerializationKeys.licenseNo)
    aCoder.encode(isDelete, forKey: SerializationKeys.isDelete)
    aCoder.encode(dietaryFiber, forKey: SerializationKeys.dietaryFiber)
    aCoder.encode(favouriteId, forKey: SerializationKeys.favouriteId)
    aCoder.encode(categoryId, forKey: SerializationKeys.categoryId)
    aCoder.encode(sodium, forKey: SerializationKeys.sodium)
    aCoder.encode(sugar, forKey: SerializationKeys.sugar)
    aCoder.encode(modifiedDate, forKey: SerializationKeys.modifiedDate)
    aCoder.encode(favouriteCreatedDate, forKey: SerializationKeys.favouriteCreatedDate)
    aCoder.encode(isOrganic, forKey: SerializationKeys.isOrganic)
    aCoder.encode(barcodeId, forKey: SerializationKeys.barcodeId)
    aCoder.encode(fatAmount, forKey: SerializationKeys.fatAmount)
    aCoder.encode(id, forKey: SerializationKeys.id)
    aCoder.encode(proteinAmount, forKey: SerializationKeys.proteinAmount)
    aCoder.encode(companyName, forKey: SerializationKeys.companyName)
    aCoder.encode(isFavourite, forKey: SerializationKeys.isFavourite)
    aCoder.encode(saturatedFats, forKey: SerializationKeys.saturatedFats)
    aCoder.encode(protein, forKey: SerializationKeys.protein)
    aCoder.encode(salt, forKey: SerializationKeys.salt)
    aCoder.encode(isTest, forKey: SerializationKeys.isTest)
    aCoder.encode(carbohydrate, forKey: SerializationKeys.carbohydrate)
    aCoder.encode(isHealthy, forKey: SerializationKeys.isHealthy)
    aCoder.encode(createdDate, forKey: SerializationKeys.createdDate)
    aCoder.encode(productName, forKey: SerializationKeys.productName)
    aCoder.encode(calories, forKey: SerializationKeys.calories)
    aCoder.encode(productId, forKey: SerializationKeys.productId)
    aCoder.encode(userId, forKey: SerializationKeys.userId)
    aCoder.encode(productImage, forKey: SerializationKeys.productImage)
    aCoder.encode(alcohol, forKey: SerializationKeys.alcohol)
     aCoder.encode(historyId, forKey: SerializationKeys.historyId)
     aCoder.encode(historyCreatedDate, forKey: SerializationKeys.historyCreatedDate)
    aCoder.encode(totalReview, forKey: SerializationKeys.totalReview)
    aCoder.encode(avgReview, forKey: SerializationKeys.avgReview)
  }

}
