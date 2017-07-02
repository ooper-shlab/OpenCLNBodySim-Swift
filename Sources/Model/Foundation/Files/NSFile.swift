//
//  NSFile.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/7/4.
//
//
/*
<codex>
<abstract>
Objective-C language binding for CFFile utilities.
</abstract>
</codex>
 */

import Cocoa

@objc(NSFile)
class NSFile: NSObject, NSCopying {
    
    private var mpFile: CF.File
    
    init(pathname: String) {
        
        self.mpFile = CF.File(pathname)
        super.init()
        
    }
    
    init(resourceInAppBundle name: String,
        ofExtension ext: String)
    {
        
        mpFile = CF.File(name, ext)
        super.init()
        
    }
    
    init(domain: FileManager.SearchPathDomainMask,
        search directory: FileManager.SearchPathDirectory,
        directory dirName: String,
        file fileName: String,
        ofExtension fileExt: String)
    {
        
        mpFile = CF.File(domain,
            directory,
            dirName,
            fileName,
            fileExt)
        super.init()
        
    }
    
    init(file: NSFile) {
        
        mpFile = CF.File(url: file.url! as CFURL)
        
    }
    
    func copy(with zone: NSZone?) -> Any {
        return NSFile(file: self)
    }
    
    //+ (instancetype) fileWithPathname:(NSString *)pathname
    //{
    //    return [[[NSFile allocWithZone:[self zone]] initWithPathname:pathname] autorelease];
    //} // fileWithPathname
    //
    //+ (instancetype) fileWithResourceInAppBundle:(NSString *)fileName
    //                                   extension:(NSString *)fileExt
    //{
    //    return [[[NSFile allocWithZone:[self zone]] initWithResourceInAppBundle:fileName
    //                                                                  extension:fileExt] autorelease];
    //} // fileWithResourceInAppBundle
    //
    //+ (instancetype) fileWithDomain:(NSSearchPathDomainMask)domain
    //                         search:(NSSearchPathDirectory)directory
    //                      directory:(NSString *)dirName
    //                           file:(NSString *)fileName
    //                      extension:(NSString *)fileExt
    //{
    //    return [[[NSFile allocWithZone:[self zone]] initWithDomain:domain
    //                                                        search:directory
    //                                                     directory:dirName
    //                                                          file:fileName
    //                                                     extension:fileExt] autorelease];
    //} // fileWithDomain
    //
    //+ (instancetype) fileWithFile:(NSFile *)file
    //{
    //    return [[[NSFile allocWithZone:[self zone]] initWithFile:file] autorelease];
    //} // fileWithFile
    
    func replace(_ plist: Any) {
        mpFile.clone(plist: plist as CFPropertyList)
    }
    
    var directory: FileManager.SearchPathDirectory {
        return mpFile.directory
    }
    
    var domain: FileManager.SearchPathDomainMask {
        return mpFile.domain
    }
    
    var format: PropertyListSerialization.PropertyListFormat {
        return PropertyListSerialization.PropertyListFormat(rawValue: mpFile.format.rawValue.ul)!
    }
    
    var length: Int {
        return mpFile.length
    }
    
    var isPList: Bool {
        return mpFile.isPList
    }
    
    var plist: AnyObject? {
        return mpFile.plist
    }
    
    var url: URL? {
        return mpFile.url as URL?
    }
    
    var data: NSMutableData? {
        return mpFile.data as! NSMutableData?
    }
    
//    var bytes: UnsafePointer<UInt8> {
//        return mpFile.bytes
//    }
//    
//    var cstring: UnsafePointer<CChar> {
//        return mpFile.cstring
//    }
    
    var string: String? {
        return mpFile.string
    }
    
    @discardableResult
    func write() -> Bool {
        return mpFile.write()
    }
    
    func write(_ pathname: String) -> Bool {
        return mpFile.write(pathname)
    }
    
    func write(_ fileName: String,
        ofExtension fileExt: String) -> Bool
    {
        return mpFile.write(fileName, fileExt)
    }
    
}
