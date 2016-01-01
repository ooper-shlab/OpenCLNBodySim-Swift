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
    
    init(domain: NSSearchPathDomainMask,
        search directory: NSSearchPathDirectory,
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
        
        mpFile = CF.File(URL: file.url!)
        
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject {
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
    
    func replace(plist: AnyObject) {
        mpFile.clone(plist: plist)
    }
    
    var directory: NSSearchPathDirectory {
        return mpFile.directory
    }
    
    var domain: NSSearchPathDomainMask {
        return mpFile.domain
    }
    
    var format: NSPropertyListFormat {
        return NSPropertyListFormat(rawValue: mpFile.format.rawValue.ul)!
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
    
    var url: NSURL? {
        return mpFile.url
    }
    
    var data: NSMutableData? {
        return mpFile.data as! NSMutableData?
    }
    
    var bytes: UnsafePointer<UInt8> {
        return mpFile.bytes
    }
    
    var cstring: UnsafePointer<CChar> {
        return mpFile.cstring
    }
    
    var string: String? {
        return mpFile.string
    }
    
    func write() -> Bool {
        return mpFile.write()
    }
    
    func write(pathname: String) -> Bool {
        return mpFile.write(pathname)
    }
    
    func write(fileName: String,
        ofExtension fileExt: String) -> Bool
    {
        return mpFile.write(fileName, fileExt)
    }
    
}