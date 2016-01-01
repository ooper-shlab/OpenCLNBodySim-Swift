//
//  NBodySimulationProperties.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/12/29.
//
//
/*
 <codex>
 <abstract>
 N-Body simulation Properties.
 </abstract>
 </codex>
 */

//MARK: -
//MARK: Headers

import Cocoa
import OpenGL.GL

//MARK: -
//MARK: Private - Namespace

extension NBody.Simulation {
    public class Properties {
        init(_ demoType: Int = 1) {construct(demoType)}
        init(_ pDictionary: [String: AnyObject]) {construct(pDictionary)}
        init(_ pPreferences: NBodyPreferences) {construct(pPreferences)}
        
        init(_ rProperties: Properties) {construct(rProperties)}
        
        deinit {destruct()}
        
        var mbIsGPUOnly: Bool = false
        var mnDemos: Int = 0
        var mnDemoType: Int = 0
        var mnParticles: Int = 0
        var mnConfig: NBody.Config = .Random
        var mnTimeStep: Float = 0.0
        var mnClusterScale: Float = 0.0
        var mnVelocityScale: Float = 0.0
        var mnSoftening: Float = 0.0
        var mnDamping: Float = 0.0
        var mnPointSize: Float = 0.0
        var mnViewDistance: Float = 0.0
        var mnRotateX: CGFloat = 0.0
        var mnRotateY: CGFloat = 0.0
        
        //MARK: -
        //MARK: Private - Type Definitions
        
        static let DefaultDemoType = 1
        
        //MARK: -
        //MARK: Private - Utilities
        
        static func setValue(pNumber: AnyObject?, inout _ value: Int) {
            if let integerValue = pNumber as? Int {
                value = integerValue
            }
        }
        
        static func setValue(pNumber: AnyObject?, inout _ value: NBody.Config) {
            if let
                integerValue = pNumber as? Int,
                configValue = NBody.Config(rawValue: integerValue)
            {
                value = configValue
            }
        }
        
        static func setValue(pNumber: AnyObject?, inout _ value: UInt32) {
            if let pNumber = pNumber as? NSNumber {
                value = pNumber.unsignedIntValue
            }
        }
        
        static func setValue(pNumber: AnyObject?, inout _ value: CGFloat) {
            if let cgFloatValue = pNumber as? CGFloat {
                value = cgFloatValue
            }
        }
        static func setValue(pNumber: AnyObject?, inout _ value: Double) {
            if let doubleValue = pNumber as? Double {
                value = doubleValue
            }
        }
        
        static func setValue(pNumber: AnyObject?, inout _ value: Float) {
            if let floatValue = pNumber as? Float {
                value = floatValue
            }
        }
        
        static func setValue(pNumber: AnyObject?, inout _ value: Bool) {
            if let boolValue = pNumber as? Bool {
                value = boolValue   //###
            }
        }
        
        // Note: We're using NSNumber here as the equivalent CFNumberRef does not
        //       have representations of unsigned numbers.
        static func setData(pDictionary: [String: AnyObject], _ properties: Properties) {
            setValue(pDictionary[kNBodyPrefIsGPUOnly],     &properties.mbIsGPUOnly)
            setValue(pDictionary[kNBodyPrefDemos],         &properties.mnDemos)
            setValue(pDictionary[kNBodyPrefDemoType],      &properties.mnDemoType)
            setValue(pDictionary[kNBodyPrefParticles],        &properties.mnParticles)
            setValue(pDictionary[kNBodyPrefConfig],        &properties.mnConfig)
            setValue(pDictionary[kNBodyPrefTimeStep],      &properties.mnTimeStep)
            setValue(pDictionary[kNBodyPrefClusterScale],  &properties.mnClusterScale)
            setValue(pDictionary[kNBodyPrefVelocityScale], &properties.mnVelocityScale)
            setValue(pDictionary[kNBodyPrefSoftening],     &properties.mnSoftening)
            setValue(pDictionary[kNBodyPrefDamping],       &properties.mnDamping)
            setValue(pDictionary[kNBodyPrefPointSize],     &properties.mnPointSize)
            setValue(pDictionary[kNBodyPrefViewDistance],  &properties.mnViewDistance)
            setValue(pDictionary[kNBodyPrefRotateX],       &properties.mnRotateX)
            setValue(pDictionary[kNBodyPrefRotateY],       &properties.mnRotateY)
        }
        
        static func setDefaults(nDemoType: Int, _ properties: Properties) {
            properties.mbIsGPUOnly     = false
            properties.mnDemos         = 7
            properties.mnDemoType      = nDemoType
            properties.mnParticles        = NBody.Particles.kCount
            properties.mnConfig        = NBody.Config.Shell
            properties.mnTimeStep      = NBody.Scale.kTime.f * 0.016
            properties.mnClusterScale  = 1.54
            properties.mnVelocityScale = 8.0
            properties.mnSoftening     = NBody.Scale.kSoftening.f * 0.1
            properties.mnDamping       = 1.0
            properties.mnPointSize     = 1.0
            properties.mnViewDistance  = 30.0
            properties.mnRotateX       = 0.0
            properties.mnRotateY       = 0.0
        }
        
        static func setDefaults(properties: Properties) {
            setDefaults(DefaultDemoType, properties)
        }
        
        static func copyData(propertiesSrc: Properties,
            to propertiesDst: Properties)
        {
            propertiesDst.mbIsGPUOnly     = propertiesSrc.mbIsGPUOnly
            propertiesDst.mnDemos         = propertiesSrc.mnDemos
            propertiesDst.mnParticles        = propertiesSrc.mnParticles
            propertiesDst.mnConfig        = propertiesSrc.mnConfig
            propertiesDst.mnTimeStep      = propertiesSrc.mnTimeStep
            propertiesDst.mnClusterScale  = propertiesSrc.mnClusterScale
            propertiesDst.mnVelocityScale = propertiesSrc.mnVelocityScale
            propertiesDst.mnSoftening     = propertiesSrc.mnSoftening
            propertiesDst.mnDamping       = propertiesSrc.mnDamping
            propertiesDst.mnPointSize     = propertiesSrc.mnPointSize
            propertiesDst.mnViewDistance  = propertiesSrc.mnViewDistance
            propertiesDst.mnRotateX       = propertiesSrc.mnRotateX
            propertiesDst.mnRotateY       = propertiesSrc.mnRotateY
        }
        
        static func setData(demoType: Int,
            _ properties: Properties) -> Int
        {
            var nDemos = 0
            
            let file = CF.File("NBodySimulationProperties", "plist")
            
            if let pArray = file.plist as? NSArray {
                
                nDemos = pArray.count
                
                var isValid  = demoType < nDemos
                
                if isValid {
                    if let pDictionary = pArray[demoType] as? [String: NSNumber] {
                        
                        NBody.Simulation.Properties.setDefaults(properties)
                        NBody.Simulation.Properties.setData(pDictionary, properties)
                    } else {
                        isValid = false
                    }
                }
                
                if !isValid {
                    nDemos = -1
                }
            }
            
            return nDemos
        }
        
        static func create(nCount: Int) -> [Properties] {
            var pProperties: [Properties] = []
            
            let file = CF.File("NBodySimulationProperties", "plist")
            
            if let pArray = file.plist as? NSArray {
                
                let nMax = pArray.count
                let iMax = (nCount <= nMax) ? nCount : nMax
                
                pProperties.reserveCapacity(iMax)
                
                for i in 0..<iMax {
                    let prop = Properties()
                    setDefaults(prop)
                    setData(pArray[i] as! [String: AnyObject], prop)
                    pProperties.append(prop)
                }
            }
            
            return pProperties
        }
        
        static func create(pFilename: String) -> [Properties] {
            var pProperties: [Properties] = []
            
            let file = CF.File(pFilename, "plist")
            
            if let pArray = file.plist {
                
                let iMax = pArray.count
                
                pProperties = (0..<iMax).map{i in
                    Properties()
                }
                
                if !pProperties.isEmpty {
                    var i = 0
                    
                    for pDictionary in pArray as! [[String: AnyObject]] {
                        setDefaults(pProperties[i])
                        setData(pDictionary, pProperties[i])
                        
                        i++
                    }
                }
            }
            
            return pProperties
        }
        
        //static NSDictionary* NBodySimulationPropertiesCreateDictionary(const Properties& properties)
        //{
        //    NSArray* pKeys = @[kNBodyPrefIsGPUOnly,
        //                       kNBodyPrefDemos,
        //                       kNBodyPrefDemoType,
        //                       kNBodyPrefParticles,
        //                       kNBodyPrefConfig,
        //                       kNBodyPrefTimeStep,
        //                       kNBodyPrefClusterScale,
        //                       kNBodyPrefVelocityScale,
        //                       kNBodyPrefSoftening,
        //                       kNBodyPrefDamping,
        //                       kNBodyPrefPointSize,
        //                       kNBodyPrefViewDistance,
        //                       kNBodyPrefRotateX,
        //                       kNBodyPrefRotateY];
        //
        //    NSArray* pObjects = @[@(properties.mbIsGPUOnly),
        //                          @(properties.mnDemos),
        //                          @(properties.mnDemoType),
        //                          @(properties.mnParticles),
        //                          @(properties.mnConfig),
        //                          @(properties.mnTimeStep),
        //                          @(properties.mnClusterScale),
        //                          @(properties.mnVelocityScale),
        //                          @(properties.mnSoftening),
        //                          @(properties.mnDamping),
        //                          @(properties.mnPointSize),
        //                          @(properties.mnViewDistance),
        //                          @(properties.mnRotateX),
        //                          @(properties.mnRotateY)];
        //
        //    return [NSDictionary dictionaryWithObjects:pObjects
        //                                       forKeys:pKeys];
        //} // NBodySimulationPropertiesCreateDictionary
        
        static func updatePreferences(properties: Properties,
            _ pPreferences: NBodyPreferences)
        {
            pPreferences.GPUOnly     = properties.mbIsGPUOnly
            pPreferences.demos         = properties.mnDemos
            pPreferences.demoType      = properties.mnDemoType
            pPreferences.particles        = properties.mnParticles
            pPreferences.config        = properties.mnConfig
            pPreferences.timeStep      = properties.mnTimeStep
            pPreferences.clusterScale  = properties.mnClusterScale
            pPreferences.velocityScale = properties.mnVelocityScale
            pPreferences.softening     = properties.mnSoftening
            pPreferences.damping       = properties.mnDamping
            pPreferences.pointSize     = properties.mnPointSize
            pPreferences.viewDistance  = properties.mnViewDistance
            pPreferences.rotate        = NSMakePoint(properties.mnRotateX, properties.mnRotateY)
        }
        
        //MARK: -
        //MARK: Public - Interfaces
        
        private func construct(type: Int) {
            NBody.Simulation.Properties.setDefaults(type, self)
            
            mnDemos = NBody.Simulation.Properties.setData(mnDemoType, self)
        }
        
        private func construct(pDictionary: [String: AnyObject]) {
            NBody.Simulation.Properties.setDefaults(self)
            NBody.Simulation.Properties.setData(pDictionary, self)
        }
        
        private func construct(pPreferences: NBodyPreferences) {
            NBody.Simulation.Properties.setDefaults(self)
            NBody.Simulation.Properties.setData(pPreferences.preferences, self)
        }
        
        private func destruct() {
            mbIsGPUOnly     = false
            mnDemos         = 0
            mnDemoType      = 0
            mnParticles        = 0
            mnConfig        = .Random
            mnTimeStep      = 0.0
            mnClusterScale  = 0.0
            mnVelocityScale = 0.0
            mnSoftening     = 0.0
            mnDamping       = 0.0
            mnPointSize     = 0.0
            mnViewDistance  = 0.0
            mnRotateX       = 0.0
            mnRotateY       = 0.0
        }
        
        private func construct(rProperties: Properties) {
            NBody.Simulation.Properties.copyData(rProperties, to: self)
        }
        
        //Properties& Properties::operator=(const Properties& rProperties)
        //{
        //    if(this != &rProperties)
        //    {
        //        NBodySimulationPropertiesCopyData(rProperties, *this);
        //    } // if
        //
        //    return *this;
        //} // Operator =
        //
        //Properties& Properties::operator=(NSDictionary* pDictionary)
        //{
        //    NBodySimulationPropertiesSetData(pDictionary, *this);
        //
        //    return *this;
        //} // Operator =
        //
        //Properties& Properties::operator=(NBodyPreferences* pPreferences)
        //{
        //    if(pPreferences)
        //    {
        //        NBodySimulationPropertiesSetData(pPreferences.preferences, *this);
        //    } // Constructor
        //
        //    return *this;
        //} // Operator =
        //
        //NSDictionary* Properties::dictionary()
        //{
        //    return NBodySimulationPropertiesCreateDictionary(*this);
        //} // dictionary
        
        func update(pPreferences: NBodyPreferences) {
            NBody.Simulation.Properties.updatePreferences(self, pPreferences)
        }
        
        //Properties* Properties::create(const size_t& nCount)
        //{
        //    return NBodySimulationPropertiesCreate(nCount);
        //} // Static constructor
        //
        //Properties* Properties::create(NSString* pFilename)
        //{
        //    return NBodySimulationPropertiesCreate(CFStringRef(pFilename));
        //} // create
        
        static func create() -> [Properties] {
            return Properties.create("NBodySimulationProperties")
        }
    }
}

infix operator <<- {associativity right precedence 90}
func <<- (inout lhs: NBody.Simulation.Properties, pPreferences: NBodyPreferences?) {
    if let pPreferences = pPreferences {
        lhs = NBody.Simulation.Properties()
        NBody.Simulation.Properties.setData(pPreferences.preferences, lhs)
    }
}
func <<- (inout lhs: NBody.Simulation.Properties?, pPreferences: NBodyPreferences?) {
    if let pPreferences = pPreferences {
        lhs = NBody.Simulation.Properties()
        NBody.Simulation.Properties.setData(pPreferences.preferences, lhs!)
    }
}