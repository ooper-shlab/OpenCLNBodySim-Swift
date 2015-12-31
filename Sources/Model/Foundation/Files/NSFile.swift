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
//
//#import <Cocoa/Cocoa.h>
import Cocoa
//
//@interface NSFile : NSObject <NSCopying>
@objc(NSFile)
class NSFile: NSObject, NSCopying {
//
//@property (nonatomic, readonly) id plist;
//
//@property (nonatomic, readonly) NSURL*          url;
//@property (nonatomic, readonly) NSMutableData*  data;
//@property (nonatomic, readonly) NSString*       string;
//
//@property (nonatomic, readonly) const char*    cstring;
//@property (nonatomic, readonly) const uint8_t* bytes;
//
//@property (nonatomic, readonly) BOOL                   isPList;
//@property (nonatomic, readonly) NSInteger              length;
//@property (nonatomic, readonly) NSPropertyListFormat   format;
//@property (nonatomic, readonly) NSSearchPathDirectory  directory;
//@property (nonatomic, readonly) NSSearchPathDomainMask domain;
//
//- (instancetype) initWithPathname:(NSString *)pathname;
//
//- (instancetype) initWithResourceInAppBundle:(NSString *)fileName
//                                   extension:(NSString *)fileExt;
//
//- (instancetype) initWithDomain:(NSSearchPathDomainMask)domain
//                         search:(NSSearchPathDirectory)directory
//                      directory:(NSString *)dirName
//                           file:(NSString *)fileName
//                      extension:(NSString *)fileExt;
//
//- (instancetype) initWithFile:(NSFile *)file;
//
//+ (instancetype) fileWithPathname:(NSString *)pathname;
//
//+ (instancetype) fileWithResourceInAppBundle:(NSString *)fileName
//                                   extension:(NSString *)fileExt;
//
//+ (instancetype) fileWithDomain:(NSSearchPathDomainMask)domain
//                         search:(NSSearchPathDirectory)directory
//                      directory:(NSString *)dirName
//                           file:(NSString *)fileName
//                      extension:(NSString *)fileExt;
//
//+ (instancetype) fileWithFile:(NSFile *)file;
//
//- (void) replace:(id)plist;
//
//- (BOOL) write;
//
//- (BOOL) write:(NSString *)pathname;
//
//- (BOOL) write:(NSString *)fileName
//     extension:(NSString *)fileExt;
//
//@end
//
//#import "CFFile.h"
//#import "NSFile.h"
//
//typedef NSURL*          NSURLRef;
//typedef NSMutableData*  NSMutableDataRef;
//
//@implementation NSFile
//{
//@private
//    CF::File* mpFile;
    private var mpFile: CF.File
//}
//
//- (instancetype) initWithPathname:(NSString *)pathname
//{
    init(pathname: String) {
//    self = [super init];
//
//    if(self)
//    {
//        mpFile = new (std::nothrow) CF::File(CFStringRef(pathname));
        self.mpFile = CF.File(pathname)
        super.init()
//    } // if
//
//    return self;
//} // initWithPathname
    }
//
//- (instancetype) initWithResourceInAppBundle:(NSString *)name
    init(resourceInAppBundle name: String,
//                                   extension:(NSString *)ext
        ofExtension ext: String)
//{
    {
//    self = [super init];
//
//    if(self)
//    {
//        mpFile = new (std::nothrow) CF::File(CFStringRef(name),
        mpFile = CF.File(name, ext)
        super.init()
//                                             CFStringRef(ext));
//    } // if
//
//    return self;
//} // initWithResourceInAppBundle
    }
//
//- (instancetype) initWithDomain:(NSSearchPathDomainMask)domain
    init(domain: NSSearchPathDomainMask,
//                         search:(NSSearchPathDirectory)directory
        search directory: NSSearchPathDirectory,
//                      directory:(NSString *)dirName
        directory dirName: String,
//                           file:(NSString *)fileName
        file fileName: String,
//                      extension:(NSString *)fileExt
        ofExtension fileExt: String)
//{
    {
//    self = [super init];
//
//    if(self)
//    {
//        mpFile = new (std::nothrow) CF::File(domain,
        mpFile = CF.File(domain,
//                                             directory,
            directory,
//                                             CFStringRef(dirName),
            dirName,
//                                             CFStringRef(fileName),
            fileName,
//                                             CFStringRef(fileExt));
            fileExt)
        super.init()
//    } // if
//
//    return self;
//} // initWithSearchPathDirectory
    }
//
//- (instancetype) initWithFile:(NSFile *)file
//{
    init(file: NSFile) {
//    self = [super init];
//
//    if(self)
//    {
//        mpFile = new (std::nothrow) CF::File(CFURLRef(file.url));
        mpFile = CF.File(URL: file.url!)
//    } // if
//
//    return self;
//} // initWithFile
    }
//
//- (instancetype) copyWithZone:(NSZone *)zone
//{
    func copyWithZone(zone: NSZone) -> AnyObject {
//    return [[NSFile allocWithZone:zone] initWithFile:self];
        return NSFile(file: self)
//} // copyWithZone
    }
//
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
//
//- (void) dealloc
//{
//    if(mpFile != nullptr)
//    {
//        delete mpFile;
//
//        mpFile = nullptr;
//    } // if
//
//    [super dealloc];
//} // dealloc
//
//- (void) replace:(id)plist
//{
    func replace(plist: AnyObject) {
//    *mpFile = CFPropertyListRef(plist);
        mpFile.clone(plist: plist)
//} // replace
    }
//
//- (NSSearchPathDirectory) directory
//{
    var directory: NSSearchPathDirectory {
//    return mpFile->directory();
        return mpFile.directory
//} // directory
    }
//
//- (NSSearchPathDomainMask) domain
//{
    var domain: NSSearchPathDomainMask {
//    return mpFile->domain();
        return mpFile.domain
//} // domain
    }
//
//- (NSPropertyListFormat) format
//{
    var format: NSPropertyListFormat {
//    return NSPropertyListFormat(mpFile->format());
        return NSPropertyListFormat(rawValue: mpFile.format.rawValue.ul)!
//} // format
    }
//
//- (NSInteger) length
//{
    var length: Int {
//    return mpFile->length();
        return mpFile.length
//} // length
    }
//
//- (BOOL) isPList
//{
    var isPList: Bool {
//    return mpFile->isPList();
        return mpFile.isPList
//} // isPlist
    }
//
//- (id) plist
//{
    var plist: AnyObject? {
//    return id(mpFile->plist());
        return mpFile.plist
//} // plist
    }
//
//- (NSURL *) url
//{
    var url: NSURL? {
//    return NSURLRef(mpFile->url());
        return mpFile.url
//} // url
    }
//
//- (NSMutableData *) data
//{
    var data: NSMutableData? {
//    return NSMutableDataRef(mpFile->data());
        return mpFile.data as! NSMutableData?
//} // data
    }
//
//- (const uint8_t *) bytes
//{
    var bytes: UnsafePointer<UInt8> {
//    return mpFile->bytes();
        return mpFile.bytes
//} // bytes
    }
//
//- (const char *) cstring
//{
    var cstring: UnsafePointer<CChar> {
//    return mpFile->cstring();
        return mpFile.cstring
//} // cstring
    }
//
//- (NSString *) string
//{
    var string: String? {
//    return [NSString stringWithCString:mpFile->cstring()
        return mpFile.string
//                              encoding:NSASCIIStringEncoding];
//} // string
    }
//
//- (BOOL) write
//{
    func write() -> Bool {
//    return mpFile->write();
        return mpFile.write()
//} // write
    }
//
//- (BOOL) write:(NSString *)pathname
//{
    func write(pathname: String) -> Bool {
//    return mpFile->write(CFStringRef(pathname));
        return mpFile.write(pathname)
//} // write
    }
//
//- (BOOL) write:(NSString *)fileName
    func write(fileName: String,
//     extension:(NSString *)fileExt
        ofExtension fileExt: String) -> Bool
//{
    {
//    return mpFile->write(CFStringRef(fileName),
        return mpFile.write(fileName, fileExt)
//                         CFStringRef(fileExt));
//} // write
    }
//
//@end
}