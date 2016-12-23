//
//  ViewController.swift
//  airesizer
//
//  Created by Abdulbaki Erbaş on 22/12/2016.
//  Copyright © 2016 Best Yazılım. All rights reserved.
//

import AppKit
import Cocoa

class ViewController: NSViewController, NSTextFieldDelegate {

    @IBOutlet var lblImgH: NSTextField!
    @IBOutlet var lblImgW: NSTextField!
    @IBOutlet var imgImage: NSImageView!
    @IBOutlet var txtPath: NSTextField!
    
    @IBOutlet var rWidth: NSTextField!
    @IBOutlet var rHeight: NSTextField!
    
    @IBOutlet var txtMinW: NSTextField!
    @IBOutlet var txtMinH: NSTextField!
    
    @IBOutlet var txtFileName: NSTextField!
    @IBOutlet var txtResPath: NSTextField!
    var image:NSImage!
    var oWidth:Int!
    var oHeight:Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let onlyIntFormatter = OnlyIntegerValueFormatter()
        rWidth.formatter = onlyIntFormatter
        rHeight.formatter = onlyIntFormatter
    }
    
    override func controlTextDidChange(_ obj: Notification) {
        txtMinW.stringValue = "Min Image Width \(Int(CGFloat(rWidth.intValue) * 4))"
        txtMinH.stringValue = "Min Image Height \(Int(CGFloat(rHeight.intValue) * 4))"
    }

    @IBAction func btnSec(_ sender: Any) {
        let dialog: NSOpenPanel = NSOpenPanel()
        dialog.title = "Choose a file"
        dialog.allowedFileTypes = ["jpg","jpeg","png"]
        dialog.canChooseDirectories = true
        if (dialog.runModal() == NSModalResponseOK) {
            let path = dialog.url?.path
            txtFileName.stringValue = (NSURL(fileURLWithPath: path!).deletingPathExtension?.lastPathComponent)!
            let fileExtension = NSURL(fileURLWithPath: path!).pathExtension
            if fileExtension == "" {
                return
            }
            txtPath.stringValue = path!
            image = NSImage(contentsOf: dialog.url!)
            oWidth = Int(image.size.width * 4.16666667)
            oHeight = Int(image.size.height * 4.16666667)
            lblImgW.stringValue = "W - \(oWidth!)"
            lblImgH.stringValue = "H - \(oHeight!)"
            imgImage.image = image
        }
    }
    
    @IBAction func btnSelectFolder(_ sender: Any) {
        let myFileDialog: NSOpenPanel = NSOpenPanel()
        myFileDialog.canChooseDirectories = true
        myFileDialog.canChooseFiles = false
        myFileDialog.runModal()
        let path = myFileDialog.directoryURL?.path
        if (path != nil) {
            txtResPath.stringValue = path!
        }
    }
    
    @IBAction func btnProcess(_ sender: Any) {
        let alert:NSAlert = NSAlert();
        if image == nil {
            alert.messageText = "You did not select a image";
            alert.runModal();
            return
        }
        if rWidth.stringValue == "" || rHeight.stringValue == "" {
            alert.messageText = "You did not enter image dimensions";
            alert.runModal();
            return
        }
        if txtFileName.stringValue == "" {
            alert.messageText = "You did not enter the image name";
            alert.runModal();
            return
        }
        if txtResPath.stringValue.isEmpty {
            alert.messageText = "You did not select a project folder";
            alert.runModal();
            return
        }
        let left = "/app/src/main/res/"
        let drcs = ["drawable-ldpi","drawable-hdpi","drawable-mdpi","drawable-xhdpi","drawable-xxhdpi","drawable-xxxhdpi"]
        let fileManager = FileManager.default
        var isDir : ObjCBool = false
        for folder in drcs {
            let path = "\(txtResPath.stringValue)\(left)\(folder)"
            if fileManager.fileExists(atPath: path, isDirectory:&isDir) {
                if !isDir.boolValue {
                    CreateFolder(path: path)
                }
            } else {
                CreateFolder(path: path)
            }
            switch folder {
            case "drawable-ldpi":
                let img = ResizedImage(image: image, w: Int(CGFloat(rWidth.intValue) * 0.75), h: Int(CGFloat(rHeight.intValue) * 0.75))
                SaveImage(image: img, path: path)
                break
            case "drawable-mdpi":
                let img = ResizedImage(image: image, w: Int(CGFloat(rWidth.intValue) * 1), h: Int(CGFloat(rHeight.intValue) * 1))
                SaveImage(image: img, path: path)
                break
            case "drawable-hdpi":
                let img = ResizedImage(image: image, w: Int(CGFloat(rWidth.intValue) * 1.5), h: Int(CGFloat(rHeight.intValue) * 1.5))
                SaveImage(image: img, path: path)
                break
            case "drawable-xhdpi":
                let img = ResizedImage(image: image, w: Int(CGFloat(rWidth.intValue) * 2), h: Int(CGFloat(rHeight.intValue) * 2))
                SaveImage(image: img, path: path)
                break
            case "drawable-xxhdpi":
                let img = ResizedImage(image: image, w: Int(CGFloat(rWidth.intValue) * 3), h: Int(CGFloat(rHeight.intValue) * 3))
                SaveImage(image: img, path: path)
                break
            case "drawable-xxxhdpi":
                let img = ResizedImage(image: image, w: Int(CGFloat(rWidth.intValue) * 4), h: Int(CGFloat(rHeight.intValue) * 4))
                SaveImage(image: img, path: path)
                break
            default: break
            }
        }
        alert.messageText = "Creation Successful";
        alert.runModal();
    }
    
    func CreateFolder(path: String) {
        do {
            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            print(error.localizedDescription);
        }
    }
    
    func SaveImage(image: NSImage, path: String) {
        if let bits = image.representations.first as? NSBitmapImageRep {
            let data = bits.representation(using: NSBitmapImageFileType.PNG, properties: [:])!
            do {
                let folderurl = NSURL(fileURLWithPath: path)
                let destinationURL = folderurl.appendingPathComponent("\(txtFileName.stringValue).png")
                try data.write(to: destinationURL!, options: .atomic)
            } catch let error as NSError {
                print(error.localizedDescription);
            }
        }
    }
    
    func ResizedImage(image: NSImage, w: Int, h: Int) -> NSImage {
        let size = image.size
        
        let widthRatio  = CGFloat(w)  / image.size.width
        let heightRatio = CGFloat(h) / image.size.height
        
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = NSMakeSize(size.width * heightRatio, size.height * heightRatio)
        } else {
            newSize = NSMakeSize(size.width * widthRatio,  size.height * widthRatio)
        }
        
        let newImage = NSImage(size: newSize)
        newImage.lockFocus()
        image.draw(in: NSMakeRect(0, 0, newSize.width, newSize.height), from: NSMakeRect(0, 0, image.size.width, image.size.height), operation: .destinationOver, fraction: CGFloat(1))
        newImage.unlockFocus()
        newImage.size = newSize
        return NSImage(data: newImage.tiffRepresentation!)!
    }
}

class OnlyIntegerValueFormatter: NumberFormatter {
    override func isPartialStringValid(_ partialString: String, newEditingString newString: AutoreleasingUnsafeMutablePointer<NSString?>?, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        if partialString.isEmpty {
            return true
        }
        return Int(partialString) != nil
    }
}
















