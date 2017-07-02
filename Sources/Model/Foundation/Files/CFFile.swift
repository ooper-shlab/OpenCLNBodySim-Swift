//
//  CFFile.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/7/4.
//
//
/*
<codex>
<abstract>
Utility methods for managing input file streams.
</abstract>
</codex>
 */


import Foundation

//MARK: -
//MARK: Private - Type Definitions

typealias CFSearchPathDirectory = FileManager.SearchPathDirectory
typealias CFSearchPathDomainMask = FileManager.SearchPathDomainMask

extension CF {
    class File {
        // Constructor for reading a file with an absolute pathname
        init(_ pPathname: String) {
            construct(pPathname)
        }
        
        // Constructor for reading a file in an application's bundle
        init(_ pName: String, _ pExt: String) {
            construct(pName, pExt)
        }
        
        // Constructor for reading a file in a domain
        init(_ domain: CFSearchPathDomainMask,
            _ directory: CFSearchPathDirectory,
            _ pDirName: String,
            _ pFileName: String,
            _ pFileExt: String)
        {
            construct(domain, directory, pDirName, pFileName, pFileExt)
        }
        
        // Constructor for reading a file using a URL
        init(url pURL: CFURL) {
            construct(pURL)
        }
        
        // Copy constructor for deep-copy
        init(file rFile: File) {
            construct(rFile)
        }
        
        private var mnLength: CFIndex = 0
        private var mpURL: CFURL?
        private var mpData: CFData?
        private var mpPList: CFPropertyList?
        private var mnFormat: CFPropertyListFormat = CFPropertyListFormat.xmlFormat_v1_0
        private var mnOptions: CFOptionFlags = CFPropertyListMutabilityOptions.mutableContainers.rawValue
        private var mpError: String?
        private var mnDirectory: CFSearchPathDirectory = CFSearchPathDirectory(rawValue: 0)!
        private var mnDomain: CFSearchPathDomainMask = CFSearchPathDomainMask.allDomainsMask
        
        
        //MARK: -
        //MARK: Private - Utilities - Files
        
        private static func getFileSize(_ pURL: CFURL, _ pFileSize: UnsafeMutablePointer<CFIndex>) -> Bool {
            var pError: Unmanaged<CFError>? = nil
            var pSize: CFNumber? = nil
            
            var bSuccess = CFURLCopyResourcePropertyForKey(pURL,
                kCFURLFileSizeKey,
                &pSize,
                &pError)
            
            if bSuccess {
                bSuccess = CFNumberGetValue(pSize, CFNumberType.sInt64Type, pFileSize)
                
                if !bSuccess {
                    pFileSize.pointee = 0
                }
            }
            
            return bSuccess
        }
        
        private static func acquire(_ nSize: CFIndex,
            _ pBuffer: UnsafeMutablePointer<UInt8>,
            _ pURL: CFURL) -> CFIndex
        {
            var nLength: CFIndex = 0
            if let pStream = CFReadStreamCreateWithFile(kCFAllocatorDefault, pURL) {
                
                if CFReadStreamOpen(pStream) {
                    nLength = CFReadStreamRead(pStream, pBuffer, nSize)
                    
                    CFReadStreamClose(pStream)
                }
                
            }
            
            return nLength
        }
        
        private static func createBuffer(_ nLength: inout CFIndex,
            _ pURL: CFURL) -> [UInt8]
        {
            var nSize: CFIndex = 0
            var pBuffer: [UInt8] = []
            
            if getFileSize(pURL, &nSize) {
                pBuffer = Array(repeating: 0, count: nSize)
                
                let nReadSz = acquire(nSize, &pBuffer, pURL)
                
                nLength = (nReadSz == nSize) ? nReadSz : -1
            }
            
            return pBuffer
        }
        
        private static func create(_ pURL: CFURL?) -> CFData? {
            var pData: CFData? = nil
            
            if pURL != nil {
                var nLength: CFIndex = 0
                var pBuffer = createBuffer(&nLength, pURL!)
                
                pData = CFDataCreate(kCFAllocatorDefault,
                    &pBuffer,
                    nLength)
                
            }
            
            return pData
        }
        
        //MARK: -
        //MARK: Private - Utilities - URLs
        
        private static func createURL(_ pPathname: String?) -> CFURL? {
            var pURL: CFURL? = nil
            
            if pPathname != nil {
                pURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, pPathname as CFString?, CFURLPathStyle.cfurlposixPathStyle, false)
            }
            
            return pURL
        }
        
        private static func createURL(_ pName: String?,
            _ pExt: String?) -> CFURL?
        {
            var pURL: CFURL? = nil
            
            if pName != nil {
                if let pBundle = CFBundleGetMainBundle() {
                    
                    pURL = CFBundleCopyResourceURL(pBundle, pName as CFString?, pExt as CFString?, nil)
                }
            }
            
            return pURL
        }
        
        private static func createURL(_ domain: CFSearchPathDomainMask,
            _ directory: CFSearchPathDirectory,
            _ pDirName: String?,
            _ pFileName: String?,
            _ pFileExt: String?) -> CFURL?
        {
            var pURL: CFURL? = nil
            
            if pFileName != nil && pDirName != nil {
                let pLibPaths = NSSearchPathForDirectoriesInDomains(directory, domain, true)
                
                let pDirPath = pLibPaths[0]
                let pComponents = [pDirPath, pDirName!, pFileName!]
                
                let pPathname = pComponents.joined(separator: "/")
                
                if pFileExt != nil {
                    
                    let pFullPath = "\(pPathname).\(pFileExt!)"
                    
                    pURL = createURL(pFullPath)
                    
                } else {
                    pURL = createURL(pPathname)
                }
                
            }
            
            return pURL
        }
        
        //MARK: -
        //MARK: Private - Utilities - Writing
        
        private static func write(_ pURL: CFURL?,
            _ pData: CFData?) -> Bool
        {
            var bSuccess = (pURL != nil) && (pData != nil)
            
            if bSuccess {
                let nLength = CFDataGetLength(pData)
                let pBuffer = CFDataGetBytePtr(pData)
                
                bSuccess = (nLength > 0) && (pBuffer != nil)
                
                if bSuccess {
                    if let pStream = CFWriteStreamCreateWithFile(kCFAllocatorDefault, pURL) {
                        
                        bSuccess = CFWriteStreamOpen(pStream)
                        
                        if bSuccess {
                            let nSize = CFWriteStreamWrite(pStream, pBuffer, nLength)
                            
                            bSuccess = nLength == nSize
                            
                            CFWriteStreamClose(pStream)
                        }
                        
                    }
                }
            }
            
            return bSuccess
        }
        
        //MARK: -
        //MARK: Private - Utilities - Strings
        
        private static func stringHasPropertyListExt(_ pPathname: String) -> Bool {
            var foundRange: CFRange = CFRange()
            let searchRange   = CFRangeMake(0, pPathname.utf16.count)
            let searchStr = "plist"
            let searchOptions = CFStringCompareFlags.compareCaseInsensitive
            
            return CFStringFindWithOptions(pPathname as CFString, searchStr as CFString, searchRange, searchOptions, &foundRange)
        }
        
        private static func stringIsPropertyListExt(_ pExt: String) -> Bool {
            let searchRange   = CFRangeMake(0, pExt.utf16.count)
            let searchStr = "plist"
            let searchOptions = CFStringCompareFlags.compareCaseInsensitive
            
            let result = CFStringCompareWithOptions(pExt as CFString, searchStr as CFString, searchRange, searchOptions)
            
            return result == CFComparisonResult.compareEqualTo
        }
        
        private static func stringHasPropertyListExt(_ pName: String, _ pExt: String?) -> Bool {
            return (pExt != nil) ? stringIsPropertyListExt(pExt!) : stringHasPropertyListExt(pName)
        }
        
        //MARK: -
        //MARK: Private - Methods
        
        // Initialize all instance variables
        private func construct() {
            mnFormat    = CFPropertyListFormat.xmlFormat_v1_0
            mnOptions   = CFPropertyListMutabilityOptions.mutableContainers.rawValue
            mnDirectory = CFSearchPathDirectory(rawValue: 0)!
            mnDomain    = .allDomainsMask
            mnLength    = 0
            mpPList     = nil
            mpError     = nil
            mpData      = nil
            mpURL       = nil
        }
        
        // Create and initialize all ivars
        func acquire(_ isPList: Bool)  {
            mpData  = CF.File.create(mpURL)
            
            if mpData != nil {
                mnLength = CFDataGetLength(mpData)
                
                if isPList {
                    var pError: CFError? = nil
                    var umError: Unmanaged<CFError>? = nil
                    
                    mpPList = CFPropertyListCreateWithData(kCFAllocatorDefault,
                        mpData,
                        mnOptions,
                        &mnFormat,
                        &umError)?.takeRetainedValue()
                    
                    if umError != nil {
                        pError = umError!.takeUnretainedValue()
                        mpError = CFErrorCopyDescription(pError) as String?
                        
                    }
                }
            }
        }
        
        // Create a deep-copy
        func clone(_ rFile: File) {
            mnOptions = rFile.mnOptions
            mnFormat  = rFile.mnFormat
            
            if rFile.mpData != nil {
                let pData = CFDataCreateCopy(kCFAllocatorDefault, rFile.mpData)
                
                if pData != nil {
                    
                    mpData = pData
                }
            }
            
            if rFile.mpPList != nil {
                let pPList = CFPropertyListCreateDeepCopy(kCFAllocatorDefault, rFile.mpPList, mnOptions)
                
                if pPList != nil {
                    
                    mpPList = pPList
                }
            }
            
            mpError = rFile.mpError
            
            if rFile.mpURL != nil {
                let pURL = CFURLCreateWithString(kCFAllocatorDefault,
                    CFURLGetString(rFile.mpURL),
                    CFURLGetBaseURL(rFile.mpURL))
                
                if pURL != nil {
                    
                    mpURL = pURL
                }
            }
        }
        
        // Create a deep-copy of the property list
        func clone(plist pPListSrc: CFPropertyList?) {
            let pPListDst = CFPropertyListCreateDeepCopy(kCFAllocatorDefault, pPListSrc, mnOptions)
            
            if pPListDst != nil {
                
                mpPList = pPListDst
                
                var umError: Unmanaged<CFError>? = nil
                var pError: CFError? = nil
                
                let umData = CFPropertyListCreateData(kCFAllocatorDefault, mpPList, mnFormat, mnOptions, &umError)
                
                if umError != nil {
                    pError = umError!.takeUnretainedValue()
                    let pDescription = CFErrorCopyDescription(pError) as String?
                    
                    if pDescription != nil {
                        
                        mpError = pDescription
                    }
                    
                }
                
                if umData != nil {
                    
                    mpData   = umData!.takeRetainedValue()
                    mnLength = CFDataGetLength(mpData)
                }
            }
        }
        
        // Write the file to a location using url
        func write(_ pURL: CFURL?) -> Bool {
            var bSuccess = false
            
            mpURL = pURL
            
            bSuccess = CF.File.write(mpURL, mpData)
            
            return bSuccess
        }
        
        //MARK: -
        //MARK: Public - Constructors
        
        // Constructor for reading a file with an absolute pathname
        private func construct(_ pPathname: String) {
            construct()
            
            mpURL = CF.File.createURL(pPathname)
            
            if mpURL != nil {
                let isPList = CF.File.stringHasPropertyListExt(pPathname)
                
                acquire(isPList)
            }
        }
        
        // Constructor for reading a file in an application's bundle
        private func construct(_ pFileName: String,
            _ pFileExt: String)
        {
            construct()
            
            mpURL = CF.File.createURL(pFileName, pFileExt)
            
            if mpURL != nil {
                let isPList = CF.File.stringHasPropertyListExt(pFileName, pFileExt)
                
                acquire(isPList)
            }
        }
        
        // Constructor for reading a file in a domain
        private func construct(_ domain: CFSearchPathDomainMask,
            _ directory: CFSearchPathDirectory,
            _ pDirName: String,
            _ pFileName: String,
            _ pFileExt: String)
        {
            construct()
            
            mpURL = CF.File.createURL(domain, directory, pDirName, pFileName, pFileExt)
            
            if mpURL != nil {
                mnDirectory = directory
                mnDomain    = domain
                
                let isPList = CF.File.stringHasPropertyListExt(pFileName, pFileExt)
                
                acquire(isPList)
            }
        }
        
        // Constructor for reading a file using a URL
        private func construct(_ pURL: CFURL?) {
            construct()
            
            if pURL != nil {
                mpURL = CFURLCreateWithString(kCFAllocatorDefault,
                    CFURLGetString(pURL),
                    CFURLGetBaseURL(pURL))
                
                if mpURL != nil {
                    let isPList = CF.File.stringHasPropertyListExt(CFURLGetString(mpURL) as String)
                    
                    acquire(isPList)
                }
            }
        }
        
        //MARK: -
        //MARK: Public - Copy Constructor
        
        // Copy constructor for deep-copy
        private func construct(_ rFile: File) {
            clone(rFile)
        }
        
        //MARK: -
        //MARK: Public - Assignment Operators
        
        //// Assignment operator for deep object copy
        //File& File::operator=(const File& rFile)
        //{
        //    if(this != &rFile)
        //    {
        //        clone(rFile);
        //    } // if
        //
        //    return *this;
        //} // Operator =
        //
        //// Assignment operator for propert list deep-copy
        //File& File::operator=(CFPropertyListRef pPListSrc)
        //{
        //    if(pPListSrc != nullptr)
        //    {
        //        clone(pPListSrc);
        //    } // if
        //
        //    return *this;
        //} // Operator =
        
        //MARK: -
        //MARK: Public - Accessors
        
        // Accessor to return a c-string representation of the read file
        var cstring: UnsafePointer<CChar>? {
            return ((mpData != nil) ? UnsafeRawPointer(CFDataGetBytePtr(mpData))?.assumingMemoryBound(to: CChar.self) : nil)!
        }
        
        // Accessor, if the read file was a data file
        var bytes: UnsafePointer<UInt8>? {
            return ((mpData != nil) ? CFDataGetBytePtr(mpData) : nil)!
        }
        
        // Length of the data or the string
        var length: CFIndex {
            return mnLength
        }
        
        // Options used for reading the property list
        var options: CFOptionFlags {
            return mnOptions
        }
        
        // Options used for reading the property list
        var format: CFPropertyListFormat {
            return mnFormat
        }
        
        // Domain mask for searching for a file
        var domain: CFSearchPathDomainMask {
            return mnDomain
        }
        
        // Directory enumerated type for seaching for a file
        var directory: CFSearchPathDirectory {
            return mnDirectory
        }
        
        // File's representation as data
        var data: CFData? {
            return mpData
        }
        
        // Property list
        var plist: CFPropertyList? {
            return mpPList
        }
        
        // Error associated with creating a property list
        var error: String? {
            return mpError
        }
        
        // File's url
        var url: CFURL? {
            return mpURL
        }
        
        //MARK: -
        //MARK: Public - Strings
        
        // Create a text string from the contents of a file
        var string: String? {
            var result: String? = nil
            
            if let data = mpData as Data? {
                result = String(data: data, encoding: String.Encoding.utf8)
            }
            
            return result
        }
        
        //// Create a cf string from the contents of a file
        //CFStringRef File::cfstring()
        //{
        //    CFStringRef string = nullptr;
        //
        //    const UInt8 *pBytes = CFDataGetBytePtr(mpData);
        //
        //    if(pBytes != nullptr)
        //    {
        //        CFIndex numBytes = CFDataGetLength(mpData);
        //
        //        string = CFStringCreateWithBytes(kCFAllocatorDefault, pBytes, numBytes, kCFStringEncodingUTF8, true);
        //    } // if
        //
        //    return string;
        //} // cfstring
        
        //MARK: -
        //MARK: Public - Query
        
        // Query for if the file was a property list
        var isPList: Bool {
            return (mpPList != nil) ? CFPropertyListIsValid(mpPList, mnFormat) : false
        }
        
        //MARK: -
        //MARK: Public - Write
        
        // Write to the original location
        func write() -> Bool {
            return CF.File.write(mpURL, mpData)
        }
        
        // Write the file to a location using an absolute pathname
        func write(_ pPathname: String) -> Bool {
            guard let pURL = CF.File.createURL(pPathname) else {return false}
            
            return write(pURL)
            
        }
        
        // Write the file to the application's bundle
        func write(_ pName: String, _ pExt: String) -> Bool {
            guard let pURL = CF.File.createURL(pName, pExt) else {return false}
            
            return write(pURL)
            
        }
    }
}
