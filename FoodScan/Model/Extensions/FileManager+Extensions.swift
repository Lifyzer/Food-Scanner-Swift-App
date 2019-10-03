//
//  FileManager+Extensions.swift
//  Bazinga
//
//  Created by C110 on 27/12/17.
//  Copyright © 2017 C110. All rights reserved.
//

import Foundation
import UIKit

class FileManagerFunctions {
    static let sharedFileManager = FileManagerFunctions()

    //MARK:- Documents Directory Methods

    //MARK: File Methods

    func saveImageInDocumentsDirectory(imageNameWithExtension:String,andImage:UIImage) {

        let documentsDirectoryURL = getDocumentDirectoryPath()
        let fileURL = documentsDirectoryURL.appendingPathComponent(imageNameWithExtension)

        if !FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try  UIImageJPEGRepresentation(andImage, 0.8)!.write(to: fileURL)
                //try UIImagePNGRepresentation(andImage)!.write(to: fileURL) //Uncomment if PNG Image
            } catch {
                print("FILE MANAGER - ERROR CREATING IMAGE ",error)
            }
        } else {
            print("FILE MANAGER - Image Not Added")
        }
    }

    func deleteImageFromDocumentsDirectory(imageNameWithExtension:String) {
        let documentDirectory = getDocumentDirectoryPath()
        let fileURL = documentDirectory.appendingPathComponent(imageNameWithExtension)
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(atPath: fileURL.absoluteString)
            } catch {
                print("FILE MANAGER - ERROR DELETING IMAGE ", error)
            }
        } else {
            print("FILE MANAGER - Image Not Added")
        }
    }

    func getImageFromDocumentDirectory(imageNameWithExtension:String) -> UIImage? {
        let documentsDirectoryURL = getDocumentDirectoryPath()
        let imageURL = URL(fileURLWithPath: documentsDirectoryURL.absoluteString).appendingPathComponent(imageNameWithExtension)
        let image = UIImage(contentsOfFile: imageURL.path)
        return image
    }

    //MARK: Directory Methods

    func getDocumentDirectoryPathWithDirectory(directoryName:String) -> URL {
        let documentsDirectoryURL = try! FileManager().url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let pathWithDirectory = documentsDirectoryURL.appendingPathComponent(directoryName)
        return pathWithDirectory
    }

    func clearAllFilesFromDirectory(directoryName:String){

        let tempFolderPath = getDocumentDirectoryPathWithDirectory(directoryName: directoryName)
        do {
            let filePaths = try FileManager.default.contentsOfDirectory(atPath: tempFolderPath.absoluteString)
            for filePath in filePaths {
                try FileManager.default.removeItem(atPath: tempFolderPath.absoluteString + filePath)
            }
        } catch {
            print("FILE MANAGER - Could not clear temp folder: \(error)")
        }
    }

    func clearAllFiles(){
        let tempFolderPath = getDocumentDirectoryPath()
        let replaceString = tempFolderPath.absoluteString.replacingOccurrences(of: "file://", with: "", options: .literal, range: nil)
        do {
            let filePaths = try FileManager.default.contentsOfDirectory(atPath: replaceString)
            for filePath in filePaths {
                try FileManager.default.removeItem(atPath: replaceString + filePath)
            }
        } catch {
            print("FILE MANAGER - Could not clear temp folder: \(error)")
        }
    }

    //MARK: Path Methods

    func getDocumentDirectoryPath() -> URL {
        let documentsDirectoryURL = try! FileManager().url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        print("FILE MANAGER - \(documentsDirectoryURL.absoluteString)")
        return documentsDirectoryURL
    }

    func getPathByAddingDirectory(directoryName:String) -> URL? {
        let logsPath = getDocumentDirectoryPathWithDirectory(directoryName: directoryName)
        do {
            try FileManager.default.createDirectory(atPath: logsPath.path, withIntermediateDirectories: true, attributes: nil)
            return logsPath
        } catch let error as NSError {
            NSLog("FILE MANAGER - Unable to create directory \(error.debugDescription)")
        }
        return nil
    }


    //MARK:- Cache Directory Methods

    //MARK: Path Methods

    func getCacheDirectoryPath() -> URL {
        let cacheDirectoryURL = try! FileManager().url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        return cacheDirectoryURL
    }

}
