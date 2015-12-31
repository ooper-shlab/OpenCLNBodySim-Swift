//
//  CFDataFile.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/12/28.
//
//
///*
// <codex>
// <abstract>
// Utility methods for reading data from a text file.  The file's header contains the number of rows & columns.
// </abstract>
// </codex>
// */
//
//#ifndef _CF_DATA_FILE_H_
//#define _CF_DATA_FILE_H_
//
//#import <vector>
import Foundation
//
//#import "CFFile.h"
//
//#ifdef __cplusplus
//
//namespace CF
//{
extension CF {
//    class DataFile
//    {
    class DataFile {
//    public:
//        // Constructor for reading from a data file with an absolute pathname
//        DataFile(CFStringRef pPathname,
        init(_ pPathname: String,
//                 const char& nTerminator = '\n');
            terminator nTerminator: CChar = "\n") {
                construct(pPathname, nTerminator)
        }
//
//        // Constructor for reading from a data file in an application's bundle
//        DataFile(CFStringRef pName,
        init(_ pName: String,
//                 CFStringRef pExt,
            _ pExt: String,
//                 const char& nTerminator = '\n');
            terminator nTerminator: CChar = "\n") {
                construct(pName, pExt, nTerminator)
        }
//
//        // Constructor for reading from a data file in a domain
//        DataFile(const CFSearchPathDomainMask& domain,
        init(_ domain: CFSearchPathDomainMask,
//                 const CFSearchPathDirectory& directory,
            _ directory: CFSearchPathDirectory,
//                 CFStringRef pDirName,
            _ pDirName: String,
//                 CFStringRef pFileName,
            _ pFileName: String,
//                 CFStringRef pFileExt,
            _ pFileExt: String,
//                 const char& nTerminator = '\n');
            terminator nTerminator: CChar = "\n")
        {
            construct(domain, directory, pDirName, pFileName, pFileExt, nTerminator)
        }
//
//        // Copy constructor for deep-copy
//        DataFile(const DataFile& rDataFile);
        init(_ rDataFile: DataFile) {
            construct(rDataFile)
        }
//
//        // Destructor
//        virtual ~DataFile();
        deinit {
            destruct()
        }
//
//        // Assignment operator for deep object copy
//        DataFile& operator=(const DataFile& rDataFile);
//
//        // End-of-File
//        const bool eof() const;
//
//        // Row count
//        const size_t rows() const;
//
//        // Column count
//        const size_t columns() const;
//
//        // File length, or the number of bytes
//        const size_t length()  const;
//
//        // Current line
//        const size_t line() const;
//
//        // Float vector from a line in the data file
//        std::vector<float> floats();
//
//        // Double vector from a line in the data file
//        std::vector<double> doubles();
//
//        // Reset the file content pointer to the beginning, past the header
//        void reset();
//
//    private:
//        // Initialize with a input data file
//        void initialize(const char& nTerminator,
//                        File* mpFile);
//
//        // Make a deep-copy from an input data file object
//        void clone(const DataFile& rDataFile);
//
//        // Clear the ivars
//        void clear();
//
//        // Delete the file object and clear all other ivars
//        void erase();
//
//        // Create a new float or double vector from a string
//        template<typename T>
//        std::vector<T> create(const std::string& rString);
//
//        // Read a single line of data from the file
//        template<typename T>
//        std::vector<T> readline();
//
//    private:
//        size_t      mnLength;
        private var mnLength: size_t = 0
//        size_t      mnRows;
        private var mnRows: size_t = 0
//        size_t      mnColumns;
        private var mnColumns: size_t = 0
//        size_t      mnLine;
        private var mnLine: size_t = 0
//        char        mnTerminator;
        private var mnTerminator: CChar = "\n"
//        char*       mpBufferPos;
        private var mpBufferPos: UnsafeMutablePointer<CChar> = nil
//        const char* mpBuffer;
        private var mpBuffer: UnsafePointer<CChar> = nil
//        CF::File*   mpFile;
        private var mpFile: CF.File?
//    }; // DataFile
//} // CF
//
//#endif
//
//#endif
//
///*
// <codex>
// <import>CFDataFile.h</import>
// </codex>
// */
//
//#pragma mark -
//#pragma mark Private - Headers
//
//#import <algorithm>
//#import <iterator>
//#import <iostream>
//#import <sstream>
//
//#import "CFDataFile.h"
//
//#pragma mark -
//#pragma mark Private - Namespaces
//
//using namespace CF;
//
//#pragma mark -
//#pragma mark Private - Utilities
//
//// Initialize with a input data file
//void DataFile::initialize(const char& nTerminator,
//                          CF::File* pFile)
//{
        private func construct(nTerminator: CChar, _ pFile: File) {
//    mpBuffer = pFile->cstring();
            mpBuffer = pFile.cstring
//
//    if(mpBuffer != nullptr)
//    {
            if mpBuffer != nil {
//        mnTerminator = nTerminator;
                mnTerminator = nTerminator
//        mnLength     = std::strlen(mpBuffer);
                mnLength     = strlen(mpBuffer).l
//        mpBufferPos  = std::strchr(mpBuffer, mnTerminator);
                mpBufferPos  = strchr(mpBuffer, Int32(mnTerminator))
//
//        std::vector<size_t> vec = readline<size_t>();
                let vec: [size_t] = readline()
//
//        if(vec.size() > 1)
//        {
                if vec.count > 1 {
//            mnRows    = vec[0];
                    mnRows    = vec[0]
//            mnColumns = vec[1];
                    mnColumns = vec[1]
//        } // if
                }
//    } // if
            }
//} // initialize
        }
//
//// Make a deep-copy from an input data file object
//void DataFile::clone(const DataFile& rDataFile)
//{
        private func clone(rDataFile: DataFile) {
//    if(rDataFile.mpFile != nullptr)
//    {
            if rDataFile.mpFile != nil {
//        CF::File* pFile = new (std::nothrow) CF::File(*rDataFile.mpFile);
                let pFile = File(file: rDataFile.mpFile!)
//
//        if(pFile != nullptr)
//        {
//            if(mpFile != nullptr)
//            {
//                delete mpFile;
//            } // if
//
//            mpFile = pFile;
                mpFile = pFile
//
//            initialize(rDataFile.mnTerminator, mpFile);
                construct(rDataFile.mnTerminator, mpFile!)
//        } // if
//    } // kif
            }
//} // clone
        }
//
//// Clear the ivars
//void DataFile::clear()
//{
        private func clear() {
//    mnRows       = 0;
            mnRows       = 0
//    mnColumns    = 0;
            mnColumns    = 0
//    mnTerminator = 0;
            mnTerminator = 0
//    mnLine       = 0;
            mnLine       = 0
//    mnLength     = 0;
            mnLength     = 0
//    mpFile       = nullptr;
            mpFile       = nil
//    mpBuffer     = nullptr;
            mpBuffer     = nil
//    mpBufferPos  = nullptr;
            mpBufferPos  = nil
//} // clear
        }
//
//// Delete the file object and clear all other ivars
//void DataFile::erase()
//{
        private func erase() {
//    if(mpFile != nullptr)
//    {
            if mpFile != nil {
//        delete mpFile;
                mpFile = nil
//    } // if
            }
//
//    clear();
            clear()
//} // erase
        }
//
//// Create a new float or double vector from a string
//template<typename T>
//std::vector<T> DataFile::create(const std::string& rString)
//{
        private func create<T: StringScannable>(rString: String) -> [T] {
//    // Always prefer std::vector to std::valarray or std::array
//    std::vector<T> vec;
            var vec: [T] = []
//
//    // Build an istream that holds the input string
//    std::istringstream iss(rString);
            let scanner = NSScanner(string: rString)
//
//    // Iterate over the istream, using >> to grab floats, or
//    // doubles, and push_back to store them in the vector
//    std::copy(std::istream_iterator<T>(iss),
//              std::istream_iterator<T>(),
//              std::back_inserter(vec));
            while let result = T.scan(scanner) {
                vec.append(result)
            }
//
//    return vec;
            return vec
//} // create
        }
//
//// Read a single line of data from the file
//template<typename T>
//std::vector<T> DataFile::readline()
//{
        private func readline<T: StringScannable>() -> [T] {
//    std::string string;
            var string: String = ""
//
//    if(mpBufferPos != nullptr)
//    {
            if mpBufferPos != nil {
//        // Number of bytes to create a c-string
//        size_t nBytes = mpBufferPos - mpBuffer;
                let nBytes = mpBuffer.distanceTo(mpBufferPos)
//
//        // Create c-string with a specified length (or number of bytes)
//        string = std::string(mpBuffer, nBytes);
                let data = NSData(bytes: mpBuffer, length: nBytes)
                string = String(data: data, encoding: NSUTF8StringEncoding)!
//
//        // Advance the buffer to the beginning of the next line
//        mpBuffer += nBytes + 1;
                mpBuffer += nBytes + 1
//
//        // Advance the buffer position to the end of the next line
//        mpBufferPos = std::strchr(mpBufferPos + 1, mnTerminator);
                mpBufferPos = strchr(mpBufferPos + 1, Int32(mnTerminator))
//    } // if
//    else
//    {
            } else {
//        // The length of the last line of the input data file
//        size_t nLength = (mpBuffer != nullptr) ? std::strlen(mpBuffer) : 0;
                let nLength = (mpBuffer != nil) ? strlen(mpBuffer).l : 0
//
//        if(nLength)
//        {
                if nLength != 0 {
//            // Create a string with the specified length
//            string = std::string(mpBuffer, nLength);
                    let data = NSData(bytes: mpBuffer, length: nLength)
                    string = String(data: data, encoding: NSUTF8StringEncoding)!
//        } // if
                }
//    } // else
            }
//
//    // Advance the counter for the line count
//    mnLine++;
            mnLine++
//
//    // Create a vector of floats or double from the string
//    return create<T>(string);
            return create(string)
//} // readline
        }
//
//#pragma mark -
//#pragma mark Public - Interfaces
//
//// Constructor for reading from a data file with an absolute pathname
//DataFile::DataFile(CFStringRef pPathname,
//                   const char& nTerminator)
//{
        private func construct(pPathname: String, _ nTerminator: CChar) {
//    clear();
            clear()
//
//    mpFile = new (std::nothrow) CF::File(pPathname);
            mpFile = CF.File(pPathname)
//
//    if(mpFile != nullptr)
//    {
            if mpFile != nil {
//        initialize(nTerminator, mpFile);
                construct(nTerminator, mpFile!)
//    } // if
            }
//} // Constructor
        }
//
//// Constructor for reading from a data file in an application's bundle
//DataFile::DataFile(CFStringRef pName,
//                   CFStringRef pExt,
//                   const char& nTerminator)
//{
        private func construct(pName: String, _ pExt: String, _ nTerminator: CChar) {
//    clear();
            clear()
//
//    mpFile = new (std::nothrow) CF::File(pName, pExt);
            mpFile = File(pName, pExt)
//
//    if(mpFile != nullptr)
//    {
            if mpFile != nil {
//        initialize(nTerminator, mpFile);
                construct(nTerminator, mpFile!)
//    } // if
            }
//} // Constructor
        }
//
//// Constructor for reading from a data file in a domain
//DataFile::DataFile(const CFSearchPathDomainMask& domain,
        private func construct(domain: CFSearchPathDomainMask,
//                   const CFSearchPathDirectory& directory,
            _ directory: CFSearchPathDirectory,
//                   CFStringRef pDirName,
            _ pDirName: String,
//                   CFStringRef pFileName,
            _ pFileName: String,
//                   CFStringRef pFileExt,
            _ pFileExt: String,
//                   const char& nTerminator)
            _ nTerminator: CChar)
//{
        {
//    clear();
            clear()
//
//    mpFile = new (std::nothrow) CF::File(domain, directory, pDirName, pFileName, pFileExt);
            mpFile = File(domain, directory, pDirName, pFileName, pFileExt)
//
//    if(mpFile != nullptr)
//    {
            if mpFile != nil {
//        initialize(nTerminator, mpFile);
                construct(nTerminator, mpFile!)
//    } // if
            }
//} // Constructor
        }
//
//// Copy constructor
//DataFile::DataFile(const DataFile& rDataFile)
//{
        private func construct(rDataFile: DataFile) {
//    clone(rDataFile);
            clone(rDataFile)
//} // Copy constructor
        }
//
//// Assignment operator for deep object copy
//DataFile& DataFile::operator=(const DataFile& rDataFile)
//{
//    if(this != &rDataFile)
//    {
//        clone(rDataFile);
//    } // if
//
//    return *this;
//} // Assignment Operator
//
//// Destructor
//DataFile::~DataFile()
//{
        private func destruct() {
//    DataFile::erase();
            erase()
//} // Destructor
        }
//
//// End-of-File
//const bool DataFile::eof() const
//{
        var eof: Bool {
//    return mnLine > mnRows;
            return mnLine > mnRows
//} // eof
        }
//
//// Row count
//const size_t DataFile::rows() const
//{
        var rows: Int {
//    return mnRows;
            return mnRows
//} // rows
        }
//
//// Column count
//const size_t DataFile::columns() const
//{
        var columns: Int {
//    return mnColumns;
            return mnColumns
//} // columns
        }
//
//// File length, or the number of bytes
//const size_t DataFile::length() const
//{
        var length: Int {
//    return mnLength;
            return mnLength
//} // length
        }
//
//// Current line
//const size_t DataFile::line() const
//{
        var line: Int {
//    return mnLine;
            return mnLine
//} // line
        }
//
//// Reset the file content pointer to the beginning, past the header
//void DataFile::reset()
//{
        func reset() {
//    // Reset to the beginning of the file
//    mpBuffer = mpFile->cstring();
            mpBuffer = mpFile!.cstring
//
//    if(mpBuffer != nullptr)
//    {
            if mpBuffer != nil {
//        char* pBufferPos = std::strchr(mpBuffer, mnTerminator);
                let pBufferPos = strchr(mpBuffer, Int32(mnTerminator))
//
//        if(pBufferPos != nullptr)
//        {
                if pBufferPos != nil {
//            // Skip the data file header line
//            mnLine       = 1;
                    mnLine       = 1
//            mpBuffer    += (pBufferPos - mpBuffer + 1);
                    mpBuffer    += (mpBuffer.distanceTo(pBufferPos) + 1)
//            mpBufferPos  = std::strchr(pBufferPos + 1, mnTerminator);
                    mpBufferPos  = strchr(pBufferPos + 1, Int32(mnTerminator))
//        } // if
                }
//    } // if
            }
//} // reset
        }
//
//// Float vector from a line in the data file
//std::vector<float> DataFile::floats()
        func floats() -> [Float] {
//{
//    return DataFile::readline<float>();
            return readline()
//} // floats
        }
//
//// Double vector from a line in the data file
//std::vector<double> DataFile::doubles()
//{
        func doubles() -> [Double] {
//    return DataFile::readline<double>();
            return readline()
//} // doubles
        }
    }
}