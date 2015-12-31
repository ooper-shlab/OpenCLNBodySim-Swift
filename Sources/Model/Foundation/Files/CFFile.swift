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

typealias CFSearchPathDirectory = NSSearchPathDirectory
typealias CFSearchPathDomainMask = NSSearchPathDomainMask

extension CF {
    class File {
//    public:
//        // Constructor for reading a file with an absolute pathname
//        File(CFStringRef pPathname);
        init(_ pPathname: String) {
            construct(pPathname)
        }
//
//        // Constructor for reading a file in an application's bundle
//        File(CFStringRef pName, CFStringRef pExt);
        init(_ pName: String, _ pExt: String) {
            construct(pName, pExt)
        }
//
//        // Constructor for reading a file in a domain
//        File(const CFSearchPathDomainMask& domain,
        init(_ domain: CFSearchPathDomainMask,
//             const CFSearchPathDirectory& directory,
            _ directory: CFSearchPathDirectory,
//             CFStringRef pDirName,
            _ pDirName: String,
//             CFStringRef pFileName,
            _ pFileName: String,
//             CFStringRef pFileExt);
            _ pFileExt: String)
        {
            construct(domain, directory, pDirName, pFileName, pFileExt)
        }
//
//        // Constructor for reading a file using a URL
//        File(CFURLRef pURL);
        init(URL pURL: CFURLRef) {
            construct(pURL)
        }
//
//        // Copy constructor for deep-copy
//        File(const File& rFile);
        init(file rFile: File) {
            construct(rFile)
        }
//
//        // Delete the object
//        virtual ~File();
        deinit {
            destruct()
        }
//
//        // Assignment operator for deep object copy
//        File& operator=(const File& rFile);
//
//        // Assignment operator for property list deep-copy
//        File& operator=(CFPropertyListRef pPListSrc);
//
//        // Accessor to return a c-string representation of the read file
//        const char* cstring() const;
//
//        // Accessor, if the read file was a data file
//        const uint8_t* bytes() const;
//
//        // Length of the data or the string
//        const CFIndex length() const;
//
//        // Options used for reading the property list
//        const CFOptionFlags options() const;
//
//        // Format used for reading the property list
//        const CFPropertyListFormat format() const;
//
//        // Domain mask for searching for a file
//        const CFSearchPathDomainMask domain() const;
//
//        // Directory enumerated type for seaching for a file
//        const CFSearchPathDirectory directory() const;
//
//        // File's representation as data
//        CFDataRef data() const;
//
//        // Error associated with creating a property list
//        CFStringRef error() const;
//
//        // Property list
//        CFPropertyListRef plist() const;
//
//        // File's url
//        CFURLRef url() const;
//
//        // Query for if the file was a property list
//        const bool isPList() const;
//
//        // Create a text string from the contents of a file
//        std::string string();
//
//        // Create a cf string from the contents of a file
//        CFStringRef cfstring();
//
//        // Write to the original location
//        bool write();
//
//        // Write the file to a location using an absolute pathname
//        bool write(CFStringRef pPathname);
//
//        // Write the file to the application's bundle
//        bool write(CFStringRef pName, CFStringRef pExt);
//
//    private:
//        // Initialize all instance variables
//        void initialize();
//
//        // Create and initialize all ivars
//        void acquire(const bool& isPList);
//
//        // Create a deep-copy
//        void clone(const File& rFile);
//
//        // Create a deep-copy of the property list
//        void clone(CFPropertyListRef pPListSrc);
//
//        // Write the file to a location using url
//        bool write(CFURLRef pURL);
//
//    private:
//        CFIndex                 mnLength;
        private var mnLength: CFIndex = 0
//        CFURLRef                mpURL;
        private var mpURL: CFURL?
//        CFDataRef               mpData;
        private var mpData: CFData?
//        CFPropertyListRef       mpPList;
        private var mpPList: CFPropertyList?
//        CFPropertyListFormat    mnFormat;
        private var mnFormat: CFPropertyListFormat = CFPropertyListFormat.XMLFormat_v1_0
//        CFOptionFlags           mnOptions;
        private var mnOptions: CFOptionFlags = CFPropertyListMutabilityOptions.MutableContainers.rawValue
//        CFStringRef             mpError;
        private var mpError: String?
//        CFSearchPathDirectory   mnDirectory;
        private var mnDirectory: CFSearchPathDirectory = CFSearchPathDirectory(rawValue: 0)!
//        CFSearchPathDomainMask  mnDomain;
        private var mnDomain: CFSearchPathDomainMask = CFSearchPathDomainMask.AllDomainsMask
//    };
//} // CF
//
//#endif
//
//#endif
//
//
//#pragma mark -
//#pragma mark Private - Headers
//
//#import "CFFile.h"
//
//#pragma mark -
//#pragma mark Private - Namespaces
//
//using namespace CF;
//
//#pragma mark -
//#pragma mark Private - Type Definitions
//
//typedef NSArray*  NSArrayRef;
//typedef NSString* NSStringRef;
//
//#pragma mark -
//#pragma mark Private - Utilities - Files
//
//static bool CFFileGetFileSize(CFURLRef pURL,
//                              CFIndex* pFileSize)
//{
        private static func getFileSize(pURL: CFURL, _ pFileSize: UnsafeMutablePointer<CFIndex>) -> Bool {
//    CFErrorRef  pError = nullptr;
            var pError: Unmanaged<CFError>? = nil
//    CFNumberRef pSize  = nullptr;
            var pSize: CFNumber? = nil
//
//    bool bSuccess = CFURLCopyResourcePropertyForKey(pURL,
            var bSuccess = CFURLCopyResourcePropertyForKey(pURL,
//                                                    kCFURLFileSizeKey,
                kCFURLFileSizeKey,
//                                                    &pSize,
                &pSize,
//                                                    &pError);
                &pError)
//
//    if(bSuccess)
//    {
            if bSuccess {
//        bSuccess = CFNumberGetValue(pSize, kCFNumberSInt64Type, pFileSize);
                bSuccess = CFNumberGetValue(pSize, CFNumberType.SInt64Type, pFileSize)
//
//        if(!bSuccess)
//        {
                if !bSuccess {
//            *pFileSize = 0;
                    pFileSize.memory = 0
//        } // if
                }
//    } // if
            }
//
//    if(pSize != nullptr)
//    {
//        CFRelease(pSize);
//    } // if
//
//    return bSuccess;
            return bSuccess.boolValue
//} // CFFileGetFileSize
        }
//
//static CFIndex CFFileAcquire(const CFIndex& nSize,
        private static func acquire(nSize: CFIndex,
//                             UInt8* pBuffer,
            _ pBuffer: UnsafeMutablePointer<UInt8>,
//                             CFURLRef pURL)
            _ pURL: CFURL) -> CFIndex
//{
        {
//    CFIndex          nLength = 0;
            var nLength: CFIndex = 0
//    CFReadStreamRef  pStream = CFReadStreamCreateWithFile(kCFAllocatorDefault, pURL);
            if let pStream = CFReadStreamCreateWithFile(kCFAllocatorDefault, pURL) {
//
//    if(pStream != nullptr)
//    {
//        if(CFReadStreamOpen(pStream))
//        {
                if CFReadStreamOpen(pStream) {
//            nLength = CFReadStreamRead(pStream, pBuffer, nSize);
                    nLength = CFReadStreamRead(pStream, pBuffer, nSize)
//
//            CFReadStreamClose(pStream);
                    CFReadStreamClose(pStream)
//        } // if
                }
//
//        CFRelease(pStream);
//    } // if
            }
//
//    return nLength;
            return nLength
//} // CFFileAcquire
        }
//
//static UInt8* CFFileCreateBuffer(CFIndex& nLength,
        private static func createBuffer(inout nLength: CFIndex,
//                                 CFURLRef pURL)
            _ pURL: CFURL) -> [UInt8]
//{
        {
//    CFIndex  nSize   = 0;
            var nSize: CFIndex = 0
//    UInt8*   pBuffer = nullptr;
            var pBuffer: [UInt8] = []
//
//    if(CFFileGetFileSize(pURL, &nSize))
//    {
            if getFileSize(pURL, &nSize) {
//        pBuffer = (UInt8 *)calloc(nSize, sizeof(UInt8));
                pBuffer = Array(count: nSize, repeatedValue: 0)
//
//        if(pBuffer != nullptr)
//        {
//            CFIndex nReadSz = CFFileAcquire(nSize, pBuffer, pURL);
                let nReadSz = acquire(nSize, &pBuffer, pURL)
//
//            nLength = (nReadSz == nSize) ? nReadSz : -1;
                nLength = (nReadSz == nSize) ? nReadSz : -1
//        } // if
//    } // if
            }
//
//    return pBuffer;
            return pBuffer
//} // CFFileCreateBuffer
        }
//
//static CFDataRef CFFileCreate(CFURLRef pURL)
//{
        private static func create(pURL: CFURL?) -> CFData? {
//    CFDataRef pData = nullptr;
            var pData: CFData? = nil
//
//    if(pURL != nullptr)
//    {
            if pURL != nil {
//        CFIndex  nLength = 0;
                var nLength: CFIndex = 0
//        UInt8*   pBuffer = CFFileCreateBuffer(nLength, pURL);
                var pBuffer = createBuffer(&nLength, pURL!)
//
//        if(pBuffer != nullptr)
//        {
//            pData = CFDataCreate(kCFAllocatorDefault,
                pData = CFDataCreate(kCFAllocatorDefault,
//                                 pBuffer,
                    &pBuffer,
//                                 nLength);
                    nLength)
//
//            free(pBuffer);
//        } // if
//    } // if
            }
//
//    return pData;
            return pData
//} // CFFileCreate
        }
//
//#pragma mark -
//#pragma mark Private - Utilities - URLs
//
//static CFURLRef CFFileCreateURL(CFStringRef pPathname)
//{
        private static func createURL(pPathname: String?) -> CFURL? {
//    CFURLRef pURL = nullptr;
            var pURL: CFURL? = nil
//
//    if(pPathname != nullptr)
//    {
            if pPathname != nil {
//        pURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, pPathname, kCFURLPOSIXPathStyle, false);
                pURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, pPathname, CFURLPathStyle.CFURLPOSIXPathStyle, false)
//    } // if
            }
//
//    return pURL;
            return pURL
//} // CFFileCreateURL
        }
//
//static CFURLRef CFFileCreateURL(CFStringRef pName,
        private static func createURL(pName: String?,
//                                CFStringRef pExt)
            _ pExt: String?) -> CFURL?
//{
        {
//    CFURLRef pURL = nullptr;
            var pURL: CFURL? = nil
//
//    if(pName != nullptr)
//    {
            if pName != nil {
//        CFBundleRef pBundle = CFBundleGetMainBundle();
                if let pBundle = CFBundleGetMainBundle() {
//
//        if(pBundle != nullptr)
//        {
//            pURL = CFBundleCopyResourceURL(pBundle, pName, pExt, nullptr);
                    pURL = CFBundleCopyResourceURL(pBundle, pName, pExt, nil)
//        } // if
                }
//    } // if
            }
//
//    return pURL;
            return pURL
//} // CFFileCreate
        }
//
//static CFURLRef CFFileCreateURL(const CFSearchPathDomainMask& domain,
        private static func createURL(domain: CFSearchPathDomainMask,
//                                const CFSearchPathDirectory& directory,
            _ directory: CFSearchPathDirectory,
//                                CFStringRef pDirName,
            _ pDirName: String?,
//                                CFStringRef pFileName,
            _ pFileName: String?,
//                                CFStringRef pFileExt)
            _ pFileExt: String?) -> CFURL?
//{
        {
//    CFURLRef pURL = nullptr;
            var pURL: CFURL? = nil
//
//    if(pFileName && pDirName)
//    {
            if pFileName != nil && pDirName != nil {
//        CFArrayRef pLibPaths = CFArrayRef(NSSearchPathForDirectoriesInDomains(directory, domain, YES));
                let pLibPaths = NSSearchPathForDirectoriesInDomains(directory, domain, true)
//
//        if(pLibPaths != nullptr)
//        {
//
//            CFStringRef pDirPath   = CFStringRef(CFArrayGetValueAtIndex(pLibPaths, 0));
                let pDirPath = pLibPaths[0]
//            CFStringRef pValues[3] = {pDirPath, pDirName, pFileName};
                let pComponents = [pDirPath, pDirName!, pFileName!]
//
//            CFArrayRef pComponents = CFArrayCreate(kCFAllocatorDefault,
//                                                   (const void **)&pValues,
//                                                   3,
//                                                   &kCFTypeArrayCallBacks);
//
//            if(pComponents)
//            {
//                CFStringRef pPathname = CFStringCreateByCombiningStrings(kCFAllocatorDefault,
                let pPathname = pComponents.joinWithSeparator("/")
//                                                                         pComponents,
//                                                                         CFSTR("/"));
//
//                if(pPathname)
//                {
//                    if(pFileExt != nullptr)
//                    {
                if pFileExt != nil {
//                        CFStringRef pFormat = CFSTR("%@.%@");
//
//                        CFStringRef pFullPath = CFStringCreateWithFormat(kCFAllocatorDefault,
                    let pFullPath = "\(pPathname).\(pFileExt!)"
//                                                                         nullptr,
//                                                                         pFormat,
//                                                                         pPathname,
//                                                                         pFileExt);
//
//                        if(pFullPath)
//                        {
//                            pURL = CFFileCreateURL(pFullPath);
                    pURL = createURL(pFullPath)
//
//                            CFRelease(pFullPath);
//                        } // if
//                    } // if
//                    else
//                    {
                } else {
//                        pURL = CFFileCreateURL(pPathname);
                    pURL = createURL(pPathname)
//                    } // else
                }
//
//                    CFRelease(pPathname);
//                } // if
//
//                CFRelease(pComponents);
//            } // if
//        } // if
//    } // if
            }
//
//    return pURL;
            return pURL
//} // CFFileCreateURL
        }
//
//#pragma mark -
//#pragma mark Private - Utilities - Writing
//
//static bool CFFileWrite(CFURLRef pURL,
        private static func write(pURL: CFURL?,
//                        CFDataRef pData)
            _ pData: CFData?) -> Bool
//{
        {
//    bool bSuccess = (pURL != nullptr) && (pData != nullptr);
            var bSuccess = (pURL != nil) && (pData != nil)
//
//    if(bSuccess)
//    {
            if bSuccess {
//        const CFIndex  nLength = CFDataGetLength(pData);
                let nLength = CFDataGetLength(pData)
//        const UInt8*   pBuffer = CFDataGetBytePtr(pData);
                let pBuffer = CFDataGetBytePtr(pData)
//
//        bSuccess = (nLength > 0) && (pBuffer != nullptr);
                bSuccess = (nLength > 0) && (pBuffer != nil)
//
//        if(bSuccess)
//        {
                if bSuccess {
//            CFWriteStreamRef pStream = CFWriteStreamCreateWithFile(kCFAllocatorDefault, pURL);
                    if let pStream = CFWriteStreamCreateWithFile(kCFAllocatorDefault, pURL) {
//
//            if(pStream != nullptr)
//            {
//                bSuccess = CFWriteStreamOpen(pStream);
                        bSuccess = CFWriteStreamOpen(pStream).boolValue
//
//                if(bSuccess)
//                {
                        if bSuccess {
//                    CFIndex nSize = CFWriteStreamWrite(pStream, pBuffer, nLength);
                            let nSize = CFWriteStreamWrite(pStream, pBuffer, nLength)
//
//                    bSuccess = nLength == nSize;
                            bSuccess = nLength == nSize
//
//                    CFWriteStreamClose(pStream);
                            CFWriteStreamClose(pStream)
//                } // if
                        }
//
//                CFRelease(pStream);
//            } // if
                    }
//        } // if
                }
//    } // if
            }
//
//    return bSuccess;
            return bSuccess
//} // CFFileWrite
        }
//
//#pragma mark -
//#pragma mark Private - Utilities - Strings
//
//static bool CFFileStringHasPropertyListExt(CFStringRef pPathname)
//{
        private static func stringHasPropertyListExt(pPathname: String) -> Bool {
//    CFRange              foundRange;
            var foundRange: CFRange = CFRange()
//    CFRange              searchRange   = CFRangeMake(0, CFStringGetLength(pPathname));
            let searchRange   = CFRangeMake(0, pPathname.utf16.count)
//    CFStringRef          searchStr     = CFSTR("plist");
            let searchStr = "plist"
//    CFStringCompareFlags searchOptions = kCFCompareCaseInsensitive;
            let searchOptions = CFStringCompareFlags.CompareCaseInsensitive
//
//    return CFStringFindWithOptions(pPathname, searchStr, searchRange, searchOptions, &foundRange);
            return CFStringFindWithOptions(pPathname, searchStr, searchRange, searchOptions, &foundRange).boolValue
//} // CFFileStringHasPropertyListExt
        }
//
//static bool CFFileStringIsPropertyListExt(CFStringRef pExt)
//{
        private static func stringIsPropertyListExt(pExt: String) -> Bool {
//    CFRange              searchRange   = CFRangeMake(0, CFStringGetLength(pExt));
            let searchRange   = CFRangeMake(0, pExt.utf16.count)
//    CFStringRef          searchStr     = CFSTR("plist");
            let searchStr = "plist"
//    CFStringCompareFlags searchOptions = kCFCompareCaseInsensitive;
            let searchOptions = CFStringCompareFlags.CompareCaseInsensitive
//
//    CFComparisonResult result = CFStringCompareWithOptions(pExt, searchStr, searchRange, searchOptions);
            let result = CFStringCompareWithOptions(pExt, searchStr, searchRange, searchOptions)
//
//    return result == kCFCompareEqualTo;
            return result == CFComparisonResult.CompareEqualTo
//} // CFFileStringIsPropertyListExt
        }
//
//static bool CFFileStringHasPropertyListExt(CFStringRef pName, CFStringRef pExt)
//{
        private static func stringHasPropertyListExt(pName: String, _ pExt: String?) -> Bool {
//    return (pExt != nullptr) ? CFFileStringIsPropertyListExt(pExt) : CFFileStringHasPropertyListExt(pName);
            return (pExt != nil) ? stringIsPropertyListExt(pExt!) : stringHasPropertyListExt(pName)
//} // CFFileStringHasPropertyListExt
        }
//
//#pragma mark -
//#pragma mark Private - Methods
//
        //// Initialize all instance variables
        //void File::initialize()
        //{
        //    mnFormat    = kCFPropertyListXMLFormat_v1_0;
        //    mnOptions   = kCFPropertyListMutableContainers;
        //    mnDirectory = CFSearchPathDirectory(0);
        //    mnDomain    = NSAllDomainsMask;
        //    mnLength    = 0;
        //    mpPList     = nullptr;
        //    mpError     = nullptr;
        //    mpData      = nullptr;
        //    mpURL       = nullptr;
        //} // initialize
//// Initialize all instance variables
//void File::initialize()
        private func construct() {
//{
//    mnFormat    = kCFPropertyListXMLFormat_v1_0;
            mnFormat    = CFPropertyListFormat.XMLFormat_v1_0
//    mnOptions   = kCFPropertyListMutableContainers;
            mnOptions   = CFPropertyListMutabilityOptions.MutableContainers.rawValue
//    mnDirectory = CFSearchPathDirectory(0);
            mnDirectory = CFSearchPathDirectory(rawValue: 0)!
//    mnDomain    = NSAllDomainsMask;
            mnDomain    = .AllDomainsMask
//    mnLength    = 0;
            mnLength    = 0
//    mpPList     = nullptr;
            mpPList     = nil
//    mpError     = nullptr;
            mpError     = nil
//    mpData      = nullptr;
            mpData      = nil
//    mpURL       = nullptr;
            mpURL       = nil
//} // initialize
        }
//
//// Create and initialize all ivars
//void File::acquire(const bool& isPList)
//{
        func acquire(isPList: Bool)  {
//    mpData  = CFFileCreate(mpURL);
            mpData  = CF.File.create(mpURL)
//
//    if(mpData != nullptr)
//    {
            if mpData != nil {
//        mnLength = CFDataGetLength(mpData);
                mnLength = CFDataGetLength(mpData)
//
//        if(isPList)
//        {
                if isPList {
//            CFErrorRef pError = nullptr;
                    var pError: CFError? = nil
                    var umError: Unmanaged<CFError>? = nil
//
//            mpPList = CFPropertyListCreateWithData(kCFAllocatorDefault,
                    mpPList = CFPropertyListCreateWithData(kCFAllocatorDefault,
//                                                   mpData,
                        mpData,
//                                                   mnOptions,
                        mnOptions,
//                                                   &mnFormat,
                        &mnFormat,
//                                                   &pError);
                        &umError)?.takeRetainedValue()
//
//            if(pError != nullptr)
//            {
                    if umError != nil {
                        pError = umError!.takeUnretainedValue()
//                mpError = CFErrorCopyDescription(pError);
                        mpError = CFErrorCopyDescription(pError) as String?
//
//                CFRelease(pError);
//            } // if
                    }
//        } // if
                }
//    } // if
            }
//} // acquire
        }
//
//// Create a deep-copy
//void File::clone(const File& rFile)
//{
        func clone(rFile: File) {
//    mnOptions = rFile.mnOptions;
            mnOptions = rFile.mnOptions
//    mnFormat  = rFile.mnFormat;
            mnFormat  = rFile.mnFormat
//
//    if(rFile.mpData != nullptr)
//    {
            if rFile.mpData != nil {
//        CFDataRef pData = CFDataCreateCopy(kCFAllocatorDefault, rFile.mpData);
                let pData = CFDataCreateCopy(kCFAllocatorDefault, rFile.mpData)
//
//        if(pData != nullptr)
//        {
                if pData != nil {
//            if(mpData != nullptr)
//            {
//                CFRelease(mpData);
//            } // if
//
//            mpData = pData;
                mpData = pData
//        } // if
                }
//    } // if
            }
//
//    if(rFile.mpPList != nullptr)
//    {
            if rFile.mpPList != nil {
//        CFPropertyListRef pPList = CFPropertyListCreateDeepCopy(kCFAllocatorDefault, rFile.mpPList, mnOptions);
                let pPList = CFPropertyListCreateDeepCopy(kCFAllocatorDefault, rFile.mpPList, mnOptions)
//
//        if(pPList != nullptr)
//        {
                if pPList != nil {
//            if(mpPList != nullptr)
//            {
//                CFRelease(mpPList);
//            } // if
//
//            mpPList = pPList;
                    mpPList = pPList
//        } // if
                }
//    } // if
            }
//
//    if(rFile.mpError != nullptr)
//    {
//        CFStringRef pError = CFStringCreateCopy(kCFAllocatorDefault, rFile.mpError);
//
//        if(pError != nullptr)
//        {
//            if(mpError != nullptr)
//            {
//                CFRelease(mpError);
//            } // if
//
//            mpError = pError;
                    mpError = rFile.mpError
//        } // if
//    } // if
//
//    if(rFile.mpURL != nullptr)
//    {
            if rFile.mpURL != nil {
//        CFURLRef pURL = CFURLCreateWithString(kCFAllocatorDefault,
                let pURL = CFURLCreateWithString(kCFAllocatorDefault,
//                                              CFURLGetString(rFile.mpURL),
                    CFURLGetString(rFile.mpURL),
//                                              CFURLGetBaseURL(rFile.mpURL));
                    CFURLGetBaseURL(rFile.mpURL))
//
//        if(pURL != nullptr)
//        {
                if pURL != nil {
//            if(mpURL != nullptr)
//            {
//                CFRelease(mpURL);
//            } // if
//
//            mpURL = pURL;
                    mpURL = pURL
//        } // if
                }
//    } // if
            }
//} // clone
        }
//
//// Create a deep-copy of the property list
//void File::clone(CFPropertyListRef pPListSrc)
//{
        func clone(plist pPListSrc: CFPropertyList?) {
//    CFPropertyListRef pPListDst = CFPropertyListCreateDeepCopy(kCFAllocatorDefault, pPListSrc, mnOptions);
            let pPListDst = CFPropertyListCreateDeepCopy(kCFAllocatorDefault, pPListSrc, mnOptions)
//
//    if(pPListDst != nullptr)
//    {
            if pPListDst != nil {
//        if(mpPList != nullptr)
//        {
//            CFRelease(mpPList);
//        } // if
//
//        mpPList = pPListDst;
                mpPList = pPListDst
//
//        CFErrorRef pError = nullptr;
                var umError: Unmanaged<CFError>? = nil
                var pError: CFError? = nil
//
//        CFDataRef pData = CFPropertyListCreateData(kCFAllocatorDefault, mpPList, mnFormat, mnOptions, &pError);
                let umData = CFPropertyListCreateData(kCFAllocatorDefault, mpPList, mnFormat, mnOptions, &umError)
//
//        if(pError != nullptr)
//        {
                if umError != nil {
                    pError = umError!.takeUnretainedValue()
//            CFStringRef pDescription = CFErrorCopyDescription(pError);
                    let pDescription = CFErrorCopyDescription(pError) as String?
//
//            if(pDescription != nullptr)
//            {
                    if pDescription != nil {
//                if(mpError != nullptr)
//                {
//                    CFRelease(mpError);
//                } // if
//
//                mpError = pDescription;
                        mpError = pDescription
//            } // if
                    }
//
//            CFRelease(pError);
//        } // if
                }
//
//        if(pData != nullptr)
//        {
                if umData != nil {
//            if(mpData != nullptr)
//            {
//                CFRelease(mpData);
//            } // if
//
//            mpData   = pData;
                    mpData   = umData!.takeRetainedValue()
//            mnLength = CFDataGetLength(mpData);
                    mnLength = CFDataGetLength(mpData)
//        } // else
                }
//    } // if
            }
//} // clone
        }
//
//// Write the file to a location using url
//bool File::write(CFURLRef pURL)
//{
        func write(pURL: CFURL?) -> Bool {
//    bool bSuccess = false;
            var bSuccess = false
//
//    if(mpURL != nullptr)
//    {
//        CFRelease(mpURL);
//    } // if
//
//    mpURL = pURL;
            mpURL = pURL
//
//    bSuccess = CFFileWrite(mpURL, mpData);
            bSuccess = CF.File.write(mpURL, mpData)
//
//    return bSuccess;
            return bSuccess
//} // write
        }
//
//#pragma mark -
//#pragma mark Public - Constructors
//
//// Constructor for reading a file with an absolute pathname
//File::File(CFStringRef pPathname)
//{
        private func construct(pPathname: String) {
//    initialize();
            construct()
//
//    mpURL = CFFileCreateURL(pPathname);
            mpURL = CF.File.createURL(pPathname)
//
//    if(mpURL != nullptr)
//    {
            if mpURL != nil {
//        bool isPList = CFFileStringHasPropertyListExt(pPathname);
                let isPList = CF.File.stringHasPropertyListExt(pPathname)
//
//        acquire(isPList);
                acquire(isPList)
//    } // if
            }
//} // Constructor
        }
//
//// Constructor for reading a file in an application's bundle
//File::File(CFStringRef pFileName,
        private func construct(pFileName: String,
//           CFStringRef pFileExt)
            _ pFileExt: String)
        {
//{
//    initialize();
            construct()
//
//    mpURL = CFFileCreateURL(pFileName, pFileExt);
                mpURL = CF.File.createURL(pFileName, pFileExt)
//
//    if(mpURL != nullptr)
//    {
            if mpURL != nil {
//        bool isPList = CFFileStringHasPropertyListExt(pFileName, pFileExt);
                let isPList = CF.File.stringHasPropertyListExt(pFileName, pFileExt)
//
//        acquire(isPList);
                acquire(isPList)
//    } // if
            }
//} // Constructor
        }
//
//// Constructor for reading a file in a domain
//File::File(const CFSearchPathDomainMask& domain,
        private func construct(domain: CFSearchPathDomainMask,
//           const CFSearchPathDirectory& directory,
            _ directory: CFSearchPathDirectory,
//           CFStringRef pDirName,
            _ pDirName: String,
//           CFStringRef pFileName,
            _ pFileName: String,
//           CFStringRef pFileExt)
            _ pFileExt: String)
//{
        {
//    initialize();
            construct()
//
//    mpURL = CFFileCreateURL(domain, directory, pDirName, pFileName, pFileExt);
            mpURL = CF.File.createURL(domain, directory, pDirName, pFileName, pFileExt)
//
//    if(mpURL != nullptr)
//    {
            if mpURL != nil {
//        mnDirectory = directory;
                mnDirectory = directory
//        mnDomain    = domain;
                mnDomain    = domain
//
//        bool isPList = CFFileStringHasPropertyListExt(pFileName, pFileExt);
                let isPList = CF.File.stringHasPropertyListExt(pFileName, pFileExt)
//
//        acquire(isPList);
                acquire(isPList)
//    } // if
            }
//} // Constructor
        }
//
//// Constructor for reading a file using a URL
//File::File(CFURLRef pURL)
//{
        private func construct(pURL: CFURL?) {
//    initialize();
            construct()
//
//    if(pURL != nullptr)
//    {
            if pURL != nil {
//        mpURL = CFURLCreateWithString(kCFAllocatorDefault,
                mpURL = CFURLCreateWithString(kCFAllocatorDefault,
//                                      CFURLGetString(pURL),
                    CFURLGetString(pURL),
//                                      CFURLGetBaseURL(pURL));
                    CFURLGetBaseURL(pURL))
//
//        if(mpURL != nullptr)
//        {
                if mpURL != nil {
//            bool isPList = CFFileStringHasPropertyListExt(CFURLGetString(mpURL));
                    let isPList = CF.File.stringHasPropertyListExt(CFURLGetString(mpURL) as String)
//
//            acquire(isPList);
                    acquire(isPList)
//        } // if
                }
//    } // if
            }
//} // Constructor
        }
//
//#pragma mark -
//#pragma mark Public - Destructor
//
//// Delete the object
//File::~File()
//{
        private func destruct() {
//    if(mpData != nullptr)
//    {
//        CFRelease(mpData);
//
//        mpData = nullptr;
//    } // if
//
//    if(mpPList != nullptr)
//    {
//        CFRelease(mpPList);
//
//        mpPList = nullptr;
//    } // if
//
//    if(mpError != nullptr)
//    {
//        CFRelease(mpError);
//
//        mpError = nullptr;
//    } // if
//
//    if(mpURL != nullptr)
//    {
//        CFRelease(mpURL);
//
//        mpURL = nullptr;
//    } // if
//} // Destructor
        }
//
//#pragma mark -
//#pragma mark Public - Copy Constructor
//
//// Copy constructor for deep-copy
//File::File(const File& rFile)
//{
        private func construct(rFile: File) {
//    clone(rFile);
            clone(rFile)
//} // Copy Constructor
        }
//
//#pragma mark -
//#pragma mark Public - Assignment Operators
//
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
//
//#pragma mark -
//#pragma mark Public - Accessors
//
//// Accessor to return a c-string representation of the read file
//const char* File::cstring() const
//{
        var cstring: UnsafePointer<CChar> {
//    return (mpData != nullptr) ? reinterpret_cast<const char*>(CFDataGetBytePtr(mpData)) : nullptr;
            return (mpData != nil) ? UnsafePointer(CFDataGetBytePtr(mpData)) : nil
//} // cstring
        }
//
//// Accessor, if the read file was a data file
//const uint8_t* File::bytes() const
//{
        var bytes: UnsafePointer<UInt8> {
//    return (mpData != nullptr) ? CFDataGetBytePtr(mpData) : nullptr;
            return (mpData != nil) ? CFDataGetBytePtr(mpData) : nil
//} // bytes
        }
//
//// Length of the data or the string
//const CFIndex File::length() const
//{
        var length: CFIndex {
//    return mnLength;
            return mnLength
//} // length
        }
//
//// Options used for reading the property list
//const CFOptionFlags File::options() const
//{
        var options: CFOptionFlags {
//    return mnOptions;
            return mnOptions
//} // options
        }
//
//// Options used for reading the property list
//const CFPropertyListFormat File::format() const
//{
        var format: CFPropertyListFormat {
//    return mnFormat;
            return mnFormat
//} // format
        }
//
//// Domain mask for searching for a file
//const CFSearchPathDomainMask File::domain() const
//{
        var domain: CFSearchPathDomainMask {
//    return mnDomain;
            return mnDomain
//} // domain
        }
//
//// Directory enumerated type for seaching for a file
//const CFSearchPathDirectory File::directory() const
//{
        var directory: CFSearchPathDirectory {
//    return mnDirectory;
            return mnDirectory
//} // directory
        }
//
//// File's representation as data
//CFDataRef File::data() const
//{
        var data: CFData? {
//    return mpData;
            return mpData
//} // data
        }
//
//// Property list
//CFPropertyListRef File::plist() const
//{
        var plist: CFPropertyList? {
//    return mpPList;
            return mpPList
//} // plist
        }
//
//// Error associated with creating a property list
//CFStringRef File::error() const
//{
        var error: String? {
//    return mpError;
            return mpError
//} // error
        }
//
//// File's url
//CFURLRef File::url() const
//{
        var url: CFURL? {
//    return mpURL;
            return mpURL
//} // url
        }
//
//#pragma mark -
//#pragma mark Public - Strings
//
//// Create a text string from the contents of a file
//std::string File::string()
//{
        var string: String? {
//    std::string string;
            var result: String? = nil
//
//    const UInt8 *pBytes = CFDataGetBytePtr(mpData);
//
//    if(pBytes != nullptr)
//    {
            if mpData != nil {
//        string = reinterpret_cast<const char*>(pBytes);
                result = String(data: mpData!, encoding: NSUTF8StringEncoding)
//    } // if
            }
//
//    return string;
            return result
//} // string
        }
//
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
//
//#pragma mark -
//#pragma mark Public - Query
//
//// Query for if the file was a property list
//const bool File::isPList() const
        var isPList: Bool {
//{
//    return (mpPList != nullptr) ? bool(CFPropertyListIsValid(mpPList, mnFormat)) : false;
            return (mpPList != nil) ? CFPropertyListIsValid(mpPList, mnFormat).boolValue : false
//} // isPList
        }
//
//#pragma mark -
//#pragma mark Public - Write
//
//// Write to the original location
//bool File::write()
//{
        func write() -> Bool {
//    return CFFileWrite(mpURL, mpData);
            return CF.File.write(mpURL, mpData)
//} // write
        }
//
//// Write the file to a location using an absolute pathname
//bool File::write(CFStringRef pPathname)
//{
        func write(pPathname: String) -> Bool {
//    CFURLRef pURL = CFFileCreateURL(pPathname);
            guard let pURL = CF.File.createURL(pPathname) else {return false}
//
//    bool bSuccess = pURL != nullptr;
//
//    if(bSuccess)
//    {
//        bSuccess = write(pURL);
            return write(pURL)
//    } // if
//
//    return bSuccess;
//} // write
        }
//
//// Write the file to the application's bundle
//bool File::write(CFStringRef pName, CFStringRef pExt)
//{
        func write(pName: String, _ pExt: String) -> Bool {
//    CFURLRef pURL = CFFileCreateURL(pName, pExt);
            guard let pURL = CF.File.createURL(pName, pExt) else {return false}
//
//    bool bSuccess = pURL != nullptr;
//
//    if(bSuccess)
//    {
//        bSuccess = write(pURL);
            return write(pURL)
//    } // if
//
//    return bSuccess;
//} // write
        }
    }
}
