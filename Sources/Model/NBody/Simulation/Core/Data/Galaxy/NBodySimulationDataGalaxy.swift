//
//  NBodySimulationDataGalaxy.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/12/30.
//
//
/*
 <codex>
 <abstract>
 Functor for generating random packed data sets for the cpu or gpu bound simulator.
 </abstract>
 </codex>
 */

import Foundation
import OpenGL.GL

extension NBody.Simulation.Data {
    class Galaxy {
        
        var mnParticles: size_t = 0
        var mpData: CF.DataFile
        
        private static let kGalaxyDataFileExt = "dat"
        
        private static let kGalaxyDataFileName: [String] = [
            "particles_16k",
            "particles_24k",
            "particles_32k",
            "particles_64k",
            "particles_80k"
        ]
        
        private static func create(nParticles: size_t = 16384) -> CF.DataFile {
            let pFileName: String
            
            switch nParticles {
            case 24576:
                pFileName = kGalaxyDataFileName[1]
                
            case 32768:
                pFileName = kGalaxyDataFileName[2]
                
            case 65536:
                pFileName = kGalaxyDataFileName[3]
                
            case 81920:
                pFileName = kGalaxyDataFileName[4]
                
            case 16384:
                fallthrough
            default:
                pFileName = kGalaxyDataFileName[0]
            }
            
            return CF.DataFile(pFileName, kGalaxyDataFileExt)
        }
        
        // Acquire the galaxy file using properties
        init(_ nParticles: size_t) {
            mnParticles = nParticles
            mpData   = Galaxy.create(mnParticles)
        }
        
        // Copy constructor for deep-copy
        init(_ rGalaxy: Galaxy) {
            mnParticles = rGalaxy.mnParticles
            mpData = CF.DataFile(rGalaxy.mpData)
        }
        
        //// Assignment operator for deep object copy
        //Galaxy& Galaxy::operator=(const Galaxy& rGalaxy)
        //{
        //    if(this != &rGalaxy)
        //    {
        //        mnParticles = rGalaxy.mnParticles;
        //
        //        CF::DataFile* pData = new (std::nothrow) CF::DataFile(*rGalaxy.mpData);
        //
        //        if(pData != nullptr)
        //        {
        //            if(mpData != nullptr)
        //            {
        //                delete mpData;
        //            } // if
        //
        //            mpData = pData;
        //        } // if
        //    } // if
        //
        //    return *this;
        //} // Assignment Operator
        
        // End-of-File
        var eof: Bool {
            return mpData.eof
        }
        
        // Row count
        var rows: size_t {
            return mpData.rows
        }
        
        // Column count
        var columns: size_t {
            return mpData.columns
        }
        
        // File length, or the number of bytes
        var length: size_t {
            return mpData.length
        }
        
        // Current line
        var line: size_t {
            return mpData.line
        }
        
        // Reset the file content pointer to the beginning, past the header
        func reset() {
            mpData.reset()
        }
        
        // Float vector from a line in the data file
        func floats() -> [Float] {
            return mpData.floats()
        }
        
        // Double vector from a line in the data file
        func doubles() -> [Double] {
            return mpData.doubles()
        }
    }
}
