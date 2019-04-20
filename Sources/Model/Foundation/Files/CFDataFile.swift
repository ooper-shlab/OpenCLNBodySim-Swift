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

import Foundation

extension CF {
    class DataFile {
        // Constructor for reading from a data file with an absolute pathname
        init(_ pPathname: String,
            terminator nTerminator: CChar = "\n") {
                construct(pPathname, nTerminator)
        }
        
        // Constructor for reading from a data file in an application's bundle
        init(_ pName: String,
            _ pExt: String,
            terminator nTerminator: CChar = "\n") {
                construct(pName, pExt, nTerminator)
        }
        
        // Constructor for reading from a data file in a domain
        init(_ domain: CFSearchPathDomainMask,
            _ directory: CFSearchPathDirectory,
            _ pDirName: String,
            _ pFileName: String,
            _ pFileExt: String,
            terminator nTerminator: CChar = "\n")
        {
            construct(domain, directory, pDirName, pFileName, pFileExt, nTerminator)
        }
        
        // Copy constructor for deep-copy
        init(_ rDataFile: DataFile) {
            construct(rDataFile)
        }
        
        // Destructor
        deinit {
            destruct()
        }
        
        private var mnLength: size_t = 0
        private var mnRows: size_t = 0
        private var mnColumns: size_t = 0
        private var mnLine: size_t = 0
        private var mnTerminator: CChar = "\n"
        private var mpBufferPos: UnsafeMutablePointer<CChar>? = nil
        private var mpBuffer: UnsafePointer<CChar>? = nil
        private var mpFile: CF.File?
        
        //MARK: -
        //MARK: Private - Utilities
        
        // Initialize with a input data file
        private func construct(_ nTerminator: CChar, _ pFile: File) {
            mpBuffer = pFile.cstring
            
            if mpBuffer != nil {
                mnTerminator = nTerminator
                mnLength     = (mpBuffer != nil) ? strlen(mpBuffer!) : 0
                mpBufferPos  = strchr(mpBuffer, Int32(mnTerminator))
                
                let vec: [size_t] = readline()
                
                if vec.count > 1 {
                    mnRows    = vec[0]
                    mnColumns = vec[1]
                }
            }
        }
        
        // Make a deep-copy from an input data file object
        private func clone(_ rDataFile: DataFile) {
            if rDataFile.mpFile != nil {
                let pFile = File(file: rDataFile.mpFile!)
                
                mpFile = pFile
                
                construct(rDataFile.mnTerminator, mpFile!)
            }
        }
        
        // Clear the ivars
        private func clear() {
            mnRows       = 0
            mnColumns    = 0
            mnTerminator = 0
            mnLine       = 0
            mnLength     = 0
            mpFile       = nil
            mpBuffer     = nil
            mpBufferPos  = nil
        }
        
        // Delete the file object and clear all other ivars
        private func erase() {
            if mpFile != nil {
                mpFile = nil
            }
            
            clear()
        }
        
        // Create a new float or double vector from a string
        private func create<T: StringScannable>(_ rString: String) -> [T] {
            // Always prefer std::vector to std::valarray or std::array
            var vec: [T] = []
            
            // Build an istream that holds the input string
            let scanner = Scanner(string: rString)
            
            // Iterate over the istream, using >> to grab floats, or
            // doubles, and push_back to store them in the vector
            while let result = T.scan(scanner) {
                vec.append(result)
            }
            
            return vec
        }
        
        // Read a single line of data from the file
        private func readline<T: StringScannable>() -> [T] {
            var string: String = ""
            
            if mpBufferPos != nil {
                // Number of bytes to create a c-string
                let nBytes = mpBuffer!.distance(to: mpBufferPos!)
                
                // Create c-string with a specified length (or number of bytes)
                let data = Data(bytes: mpBuffer!, count: nBytes)
                string = String(data: data, encoding: .utf8)!
                
                // Advance the buffer to the beginning of the next line
                mpBuffer! += nBytes + 1
                
                // Advance the buffer position to the end of the next line
                mpBufferPos = strchr(mpBufferPos! + 1, Int32(mnTerminator))
            } else {
                // The length of the last line of the input data file
                let nLength = (mpBuffer != nil) ? strlen(mpBuffer!) : 0
                
                if nLength != 0 {
                    // Create a string with the specified length
                    let data = Data(bytes: mpBuffer!, count: nLength)
                    string = String(data: data, encoding: .utf8)!
                }
            }
            
            // Advance the counter for the line count
            mnLine += 1
            
            // Create a vector of floats or double from the string
            return create(string)
        }
        
        //MARK: -
        //MARK: Public - Interfaces
        
        // Constructor for reading from a data file with an absolute pathname
        private func construct(_ pPathname: String, _ nTerminator: CChar) {
            clear()
            
            mpFile = CF.File(pPathname)
            
            if mpFile != nil {
                construct(nTerminator, mpFile!)
            }
        }
        
        // Constructor for reading from a data file in an application's bundle
        private func construct(_ pName: String, _ pExt: String, _ nTerminator: CChar) {
            clear()
            
            mpFile = File(pName, pExt)
            
            if mpFile != nil {
                construct(nTerminator, mpFile!)
            }
        }
        
        // Constructor for reading from a data file in a domain
        private func construct(_ domain: CFSearchPathDomainMask,
            _ directory: CFSearchPathDirectory,
            _ pDirName: String,
            _ pFileName: String,
            _ pFileExt: String,
            _ nTerminator: CChar)
        {
            clear()
            
            mpFile = File(domain, directory, pDirName, pFileName, pFileExt)
            
            if mpFile != nil {
                construct(nTerminator, mpFile!)
            }
        }
        
        // Copy constructor
        private func construct(_ rDataFile: DataFile) {
            clone(rDataFile)
        }
        
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
        
        // Destructor
        private func destruct() {
            erase()
        }
        
        // End-of-File
        var eof: Bool {
            return mnLine > mnRows
        }
        
        // Row count
        var rows: Int {
            return mnRows
        }
        
        // Column count
        var columns: Int {
            return mnColumns
        }
        
        // File length, or the number of bytes
        var length: Int {
            return mnLength
        }
        
        // Current line
        var line: Int {
            return mnLine
        }
        
        // Reset the file content pointer to the beginning, past the header
        func reset() {
            // Reset to the beginning of the file
            mpBuffer = mpFile!.cstring
            
            if mpBuffer != nil {
                let pBufferPos = strchr(mpBuffer, Int32(mnTerminator))
                
                if pBufferPos != nil {
                    // Skip the data file header line
                    mnLine       = 1
                    mpBuffer!   += (mpBuffer!.distance(to: pBufferPos!) + 1)
                    mpBufferPos  = strchr(pBufferPos! + 1, Int32(mnTerminator))
                }
            }
        }
        
        // Float vector from a line in the data file
        func floats() -> [Float] {
            return readline()
        }
        
        // Double vector from a line in the data file
        func doubles() -> [Double] {
            return readline()
        }
    }
}
