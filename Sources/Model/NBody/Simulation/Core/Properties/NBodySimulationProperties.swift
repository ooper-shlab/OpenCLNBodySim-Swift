//
//  NBodySimulationProperties.swift
//  OpenCL_NBody_Simulation
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/12/29.
//
//
///*
// <codex>
// <abstract>
// N-Body simulation Properties.
// </abstract>
// </codex>
// */
//
//#ifndef _NBODY_SIMULATION_PROPERTIES_H_
//#define _NBODY_SIMULATION_PROPERTIES_H_
//
//#import <Cocoa/Cocoa.h>
import Cocoa
//#import <OpenGL/OpenGL.h>
import OpenGL.GL
//
//#import "NBodyPreferences.h"
//
//#ifdef __cplusplus
//
//namespace NBody
//{
extension NBody.Simulation {
//    namespace Simulation
//    {
//        class Properties
    public class Properties {
//        {
//        public:
//            Properties(const uint32_t& demoType = 1);
        init(_ demoType: Int = 1) {construct(demoType)}
//            Properties(NSDictionary* pDictionary);
        init(_ pDictionary: [String: AnyObject]) {construct(pDictionary)}
//            Properties(NBodyPreferences* pPreferences);
        init(_ pPreferences: NBodyPreferences) {construct(pPreferences)}
//
//            Properties(const Properties& rProperties);
        init(_ rProperties: Properties) {construct(rProperties)}
//
//            virtual ~Properties();
        deinit {destruct()}
//
//            Properties& operator=(const Properties& rProperties);
//            Properties& operator=(NSDictionary* pDictionary);
//            Properties& operator=(NBodyPreferences* pPreferences);
//
//            NSDictionary*   dictionary();
//
//            void update(NBodyPreferences* pPreferences);
//
//            static Properties* create(const size_t& nCount);
//
//            static Properties* create();
//            static Properties* create(NSString* pFilename);
//
//        public:
//            bool      mbIsGPUOnly;
        var mbIsGPUOnly: Bool = false
//            int64_t   mnDemos;
        var mnDemos: Int = 0
//            uint32_t  mnDemoType;
        var mnDemoType: Int = 0
//            uint32_t  mnParticles;
        var mnParticles: Int = 0
//            uint32_t  mnConfig;
        var mnConfig: NBody.Config = .Random
//            float     mnTimeStep;
        var mnTimeStep: Float = 0.0
//            float     mnClusterScale;
        var mnClusterScale: Float = 0.0
//            float     mnVelocityScale;
        var mnVelocityScale: Float = 0.0
//            float     mnSoftening;
        var mnSoftening: Float = 0.0
//            float     mnDamping;
        var mnDamping: Float = 0.0
//            float     mnPointSize;
        var mnPointSize: Float = 0.0
//            float     mnViewDistance;
        var mnViewDistance: Float = 0.0
//            double    mnRotateX;
        var mnRotateX: CGFloat = 0.0
//            double    mnRotateY;
        var mnRotateY: CGFloat = 0.0
//        }; // Properties
//    } // Simulation
//} // NBody
//
//#endif
//
//#endif
///*
// <codex>
// <import>NBodySimulationProperties.h</import>
// </codex>
// */
//
//#pragma mark -
//#pragma mark Headers
//
//#import <memory>
//
//#import "CFFile.h"
//
//#import "NBodyConstants.h"
//#import "NBodyPreferences.h"
//#import "NBodySimulationProperties.h"
//
//#pragma mark -
//#pragma mark Private - Namespace
//
//using namespace NBody::Simulation;
//
//#pragma mark -
//#pragma mark Private - Type Definitions
//
//typedef NSArray* NSArrayRef;
//
//#pragma mark -
//#pragma mark Private - Type Definitions
//
//static const uint32_t kNBodySimulationPropertiesDefaultDemoType = 1;
        static let DefaultDemoType = 1
//
//#pragma mark -
//#pragma mark Private - Utilities
//
//static void NBodySimulationPropertiesSetValue(NSNumber* pNumber,
        static func setValue(pNumber: AnyObject?, inout _ value: Int) {
//                                              int64_t& value)
//{
//    if(pNumber)
//    {
            if let integerValue = pNumber as? Int {
//        value = pNumber.longLongValue;
                value = integerValue
//    } // if
            }
//} // NBodySimulationPropertiesSetValue
        }
        
        static func setValue(pNumber: AnyObject?, inout _ value: NBody.Config) {
            if let
                integerValue = pNumber as? Int,
                configValue = NBody.Config(rawValue: integerValue)
            {
                value = configValue
            }
        }
//
//static void NBodySimulationPropertiesSetValue(NSNumber* pNumber,
        static func setValue(pNumber: AnyObject?, inout _ value: UInt32) {
//                                              uint32_t& value)
//{
//    if(pNumber)
//    {
            if let pNumber = pNumber as? NSNumber {
//        value = pNumber.unsignedIntValue;
                value = pNumber.unsignedIntValue
//    } // if
            }
//} // NBodySimulationPropertiesSetValue
        }
//
//static void NBodySimulationPropertiesSetValue(NSNumber* pNumber,
        static func setValue(pNumber: AnyObject?, inout _ value: CGFloat) {
            if let cgFloatValue = pNumber as? CGFloat {
                value = cgFloatValue
            }
        }
        static func setValue(pNumber: AnyObject?, inout _ value: Double) {
//                                              double& value)
//{
//    if(pNumber)
//    {
            if let doubleValue = pNumber as? Double {
//        value = pNumber.doubleValue;
                value = doubleValue
//    } // if
            }
//} // NBodySimulationPropertiesSetValue
        }
//
//static void NBodySimulationPropertiesSetValue(NSNumber* pNumber,
        static func setValue(pNumber: AnyObject?, inout _ value: Float) {
//                                              float& value)
//{
//    if(pNumber)
//    {
            if let floatValue = pNumber as? Float {
//        value = pNumber.floatValue;
                value = floatValue
//    } // if
            }
//} // NBodySimulationPropertiesSetValue
        }
//
//static void NBodySimulationPropertiesSetValue(NSNumber* pNumber,
        static func setValue(pNumber: AnyObject?, inout _ value: Bool) {
//                                              bool& value)
//{
//    if(pNumber)
//    {
            if let boolValue = pNumber as? Bool {
//        value = pNumber.floatValue;
                value = boolValue   //###
//    } // if
            }
//} // NBodySimulationPropertiesSetValue
        }
//
//// Note: We're using NSNumber here as the equivalent CFNumberRef does not
////       have representations of unsigned numbers.
//static void NBodySimulationPropertiesSetData(NSDictionary* pDictionary,
        static func setData(pDictionary: [String: AnyObject], _ properties: Properties) {
//                                             Properties& properties)
//{
//    if(pDictionary)
//    {
//        NBodySimulationPropertiesSetValue(pDictionary[kNBodyPrefIsGPUOnly],     properties.mbIsGPUOnly);
            setValue(pDictionary[kNBodyPrefIsGPUOnly],     &properties.mbIsGPUOnly)
//        NBodySimulationPropertiesSetValue(pDictionary[kNBodyPrefDemos],         properties.mnDemos);
            setValue(pDictionary[kNBodyPrefDemos],         &properties.mnDemos)
//        NBodySimulationPropertiesSetValue(pDictionary[kNBodyPrefDemoType],      properties.mnDemoType);
            setValue(pDictionary[kNBodyPrefDemoType],      &properties.mnDemoType)
//        NBodySimulationPropertiesSetValue(pDictionary[kNBodyPrefParticles],        properties.mnParticles);
            setValue(pDictionary[kNBodyPrefParticles],        &properties.mnParticles)
//        NBodySimulationPropertiesSetValue(pDictionary[kNBodyPrefConfig],        properties.mnConfig);
            setValue(pDictionary[kNBodyPrefConfig],        &properties.mnConfig)
//        NBodySimulationPropertiesSetValue(pDictionary[kNBodyPrefTimeStep],      properties.mnTimeStep);
            setValue(pDictionary[kNBodyPrefTimeStep],      &properties.mnTimeStep)
//        NBodySimulationPropertiesSetValue(pDictionary[kNBodyPrefClusterScale],  properties.mnClusterScale);
            setValue(pDictionary[kNBodyPrefClusterScale],  &properties.mnClusterScale)
//        NBodySimulationPropertiesSetValue(pDictionary[kNBodyPrefVelocityScale], properties.mnVelocityScale);
            setValue(pDictionary[kNBodyPrefVelocityScale], &properties.mnVelocityScale)
//        NBodySimulationPropertiesSetValue(pDictionary[kNBodyPrefSoftening],     properties.mnSoftening);
            setValue(pDictionary[kNBodyPrefSoftening],     &properties.mnSoftening)
//        NBodySimulationPropertiesSetValue(pDictionary[kNBodyPrefDamping],       properties.mnDamping);
            setValue(pDictionary[kNBodyPrefDamping],       &properties.mnDamping)
//        NBodySimulationPropertiesSetValue(pDictionary[kNBodyPrefPointSize],     properties.mnPointSize);
            setValue(pDictionary[kNBodyPrefPointSize],     &properties.mnPointSize)
//        NBodySimulationPropertiesSetValue(pDictionary[kNBodyPrefViewDistance],  properties.mnViewDistance);
            setValue(pDictionary[kNBodyPrefViewDistance],  &properties.mnViewDistance)
//        NBodySimulationPropertiesSetValue(pDictionary[kNBodyPrefRotateX],       properties.mnRotateX);
            setValue(pDictionary[kNBodyPrefRotateX],       &properties.mnRotateX)
//        NBodySimulationPropertiesSetValue(pDictionary[kNBodyPrefRotateY],       properties.mnRotateY);
            setValue(pDictionary[kNBodyPrefRotateY],       &properties.mnRotateY)
//    } // if
//} // NBodySimulationPropertiesSetData
        }
//
//static void NBodySimulationPropertiesSetDefaults(const uint32_t& nDemoType,
        static func setDefaults(nDemoType: Int, _ properties: Properties) {
//                                                 Properties& properties)
//{
//    properties.mbIsGPUOnly     = NO;
            properties.mbIsGPUOnly     = false
//    properties.mnDemos         = 7;
            properties.mnDemos         = 7
//    properties.mnDemoType      = nDemoType;
            properties.mnDemoType      = nDemoType
//    properties.mnParticles        = NBody::Particles::kCount;
            properties.mnParticles        = NBody.Particles.kCount
//    properties.mnConfig        = NBody::Config::eConfigShell;
            properties.mnConfig        = NBody.Config.Shell
//    properties.mnTimeStep      = NBody::Scale::kTime * 0.016f;
            properties.mnTimeStep      = NBody.Scale.kTime.f * 0.016
//    properties.mnClusterScale  = 1.54f;
            properties.mnClusterScale  = 1.54
//    properties.mnVelocityScale = 8.0f;
            properties.mnVelocityScale = 8.0
//    properties.mnSoftening     = NBody::Scale::kSoftening * 0.1f;
            properties.mnSoftening     = NBody.Scale.kSoftening.f * 0.1
//    properties.mnDamping       = 1.0f;
            properties.mnDamping       = 1.0
//    properties.mnPointSize     = 1.0f;
            properties.mnPointSize     = 1.0
//    properties.mnViewDistance  = 30.0f;
            properties.mnViewDistance  = 30.0
//    properties.mnRotateX       = 0.0f;
            properties.mnRotateX       = 0.0
//    properties.mnRotateY       = 0.0f;
            properties.mnRotateY       = 0.0
//} // NBodySimulationPropertiesSetData
        }
//
//static void NBodySimulationPropertiesSetDefaults(Properties& properties)
//{
        static func setDefaults(properties: Properties) {
//    NBodySimulationPropertiesSetDefaults(kNBodySimulationPropertiesDefaultDemoType, properties);
            setDefaults(DefaultDemoType, properties)
//} // NBodySimulationPropertiesSetDefaults
        }
//
//static void NBodySimulationPropertiesCopyData(const Properties& propertiesSrc,
        static func copyData(propertiesSrc: Properties,
//                                              Properties& propertiesDst)
            to propertiesDst: Properties)
//{
        {
//    propertiesDst.mbIsGPUOnly     = propertiesSrc.mbIsGPUOnly;
            propertiesDst.mbIsGPUOnly     = propertiesSrc.mbIsGPUOnly
//    propertiesDst.mnDemos         = propertiesSrc.mnDemos;
            propertiesDst.mnDemos         = propertiesSrc.mnDemos
//    propertiesDst.mnParticles        = propertiesSrc.mnParticles;
            propertiesDst.mnParticles        = propertiesSrc.mnParticles
//    propertiesDst.mnConfig        = propertiesSrc.mnConfig;
            propertiesDst.mnConfig        = propertiesSrc.mnConfig
//    propertiesDst.mnTimeStep      = propertiesSrc.mnTimeStep;
            propertiesDst.mnTimeStep      = propertiesSrc.mnTimeStep
//    propertiesDst.mnClusterScale  = propertiesSrc.mnClusterScale;
            propertiesDst.mnClusterScale  = propertiesSrc.mnClusterScale
//    propertiesDst.mnVelocityScale = propertiesSrc.mnVelocityScale;
            propertiesDst.mnVelocityScale = propertiesSrc.mnVelocityScale
//    propertiesDst.mnSoftening     = propertiesSrc.mnSoftening;
            propertiesDst.mnSoftening     = propertiesSrc.mnSoftening
//    propertiesDst.mnDamping       = propertiesSrc.mnDamping;
            propertiesDst.mnDamping       = propertiesSrc.mnDamping
//    propertiesDst.mnPointSize     = propertiesSrc.mnPointSize;
            propertiesDst.mnPointSize     = propertiesSrc.mnPointSize
//    propertiesDst.mnViewDistance  = propertiesSrc.mnViewDistance;
            propertiesDst.mnViewDistance  = propertiesSrc.mnViewDistance
//    propertiesDst.mnRotateX       = propertiesSrc.mnRotateX;
            propertiesDst.mnRotateX       = propertiesSrc.mnRotateX
//    propertiesDst.mnRotateY       = propertiesSrc.mnRotateY;
            propertiesDst.mnRotateY       = propertiesSrc.mnRotateY
//} // NBodySimulationPropertiesCopyData
        }
//
//static int64_t NBodySimulationPropertiesSetData(const uint32_t& demoType,
        static func setData(demoType: Int,
//                                                Properties& properties)
            _ properties: Properties) -> Int
//{
        {
//    int64_t  nDemos = 0;
            var nDemos = 0
//
//    CF::File file(CFSTR("NBodySimulationProperties"), CFSTR("plist"));
            let file = CF.File("NBodySimulationProperties", "plist")
//
//    NSArray* pArray = NSArrayRef(file.plist());
            if let pArray = file.plist as? NSArray {
//
//    if(pArray)
//    {
//        nDemos = [pArray count];
                nDemos = pArray.count
//
//        bool isValid  = demoType < nDemos;
                var isValid  = demoType < nDemos
//
//        if(isValid)
//        {
                if isValid {
//            NSDictionary* pDictionary = pArray[demoType];
                    if let pDictionary = pArray[demoType] as? [String: NSNumber] {
//
//            isValid = pDictionary != nil;
//
//            if(isValid)
//            {
//                NBodySimulationPropertiesSetDefaults(properties);
                        NBody.Simulation.Properties.setDefaults(properties)
//                NBodySimulationPropertiesSetData(pDictionary, properties);
                        NBody.Simulation.Properties.setData(pDictionary, properties)
//            } // if
                    } else {
                        isValid = false
                    }
//        } // if
                }
//
//        if(!isValid)
//        {
                if !isValid {
//            nDemos = -1;
                    nDemos = -1
//        } // if
                }
//    } // if
            }
//
//    return nDemos;
            return nDemos
//} // NBodySimulationPropertiesSetData
        }
//
//static Properties* NBodySimulationPropertiesCreate(const size_t& nCount)
//{
        static func create(nCount: Int) -> [Properties] {
//    Properties* pProperties = nullptr;
            var pProperties: [Properties] = []
//
//    CF::File file(CFSTR("NBodySimulationProperties"), CFSTR("plist"));
            let file = CF.File("NBodySimulationProperties", "plist")
//
//    NSArray* pArray = NSArrayRef(file.plist());
            if let pArray = file.plist as? NSArray {
//
//    if(pArray)
//    {
//        size_t nMax = [pArray count];
                let nMax = pArray.count
//        size_t iMax = (nCount <= nMax) ? nCount : nMax;
                let iMax = (nCount <= nMax) ? nCount : nMax
//
//        pProperties = new (std::nothrow) Properties[iMax];
                pProperties.reserveCapacity(iMax)
//
//        if(pProperties != nullptr)
//        {
//            size_t i = 0;
//
//            for(i = 0; i < iMax; ++i)
//            {
                for i in 0..<iMax {
                    let prop = Properties()
//                NBodySimulationPropertiesSetDefaults(pProperties[i]);
                    setDefaults(prop)
//                NBodySimulationPropertiesSetData(pArray[i], pProperties[i]);
                    setData(pArray[i] as! [String: AnyObject], prop)
                    pProperties.append(prop)
//            } // for
                }
//        } // if
//    } // if
            }
//
//    return pProperties;
            return pProperties
//} // NBodySimulationPropertiesCreate
        }
//
//static Properties* NBodySimulationPropertiesCreate(CFStringRef pFilename)
//{
        static func create(pFilename: String) -> [Properties] {
//    Properties* pProperties = nullptr;
            var pProperties: [Properties] = []
//
//    CF::File file(pFilename, CFSTR("plist"));
            let file = CF.File(pFilename, "plist")
//
//    NSArray* pArray = NSArrayRef(file.plist());
            if let pArray = file.plist {
//
//    if(pArray)
//    {
//        size_t iMax = [pArray count];
                let iMax = pArray.count
//
//        pProperties = new (std::nothrow) Properties[iMax];
                pProperties = (0..<iMax).map{i in
                    Properties()
                }
//
//        if(pProperties != nullptr)
//        {
                if !pProperties.isEmpty {
//            size_t i = 0;
                    var i = 0
//
//            NSDictionary* pDictionary = nil;
//
//            for(pDictionary in pArray)
//            {
                    for pDictionary in pArray as! [[String: AnyObject]] {
//                NBodySimulationPropertiesSetDefaults(pProperties[i]);
                        setDefaults(pProperties[i])
//                NBodySimulationPropertiesSetData(pDictionary, pProperties[i]);
                        setData(pDictionary, pProperties[i])
//
//                i++;
                        i++
//            } // for
                    }
//        } // if
                }
//    } // if
            }
//
//    return pProperties;
            return pProperties
//} // NBodySimulationPropertiesCreate
        }
//
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
//
//static void NBodySimulationPropertiesUpdatePreferences(const Properties& properties,
        static func updatePreferences(properties: Properties,
//                                                       NBodyPreferences* pPreferences)
            _ pPreferences: NBodyPreferences)
//{
        {
//    if(pPreferences)
//    {
//        pPreferences.isGPUOnly     = properties.mbIsGPUOnly;
            pPreferences.GPUOnly     = properties.mbIsGPUOnly
//        pPreferences.demos         = properties.mnDemos;
            pPreferences.demos         = properties.mnDemos
//        pPreferences.demoType      = properties.mnDemoType;
            pPreferences.demoType      = properties.mnDemoType
//        pPreferences.particles        = properties.mnParticles;
            pPreferences.particles        = properties.mnParticles
//        pPreferences.config        = properties.mnConfig;
            pPreferences.config        = properties.mnConfig
//        pPreferences.timeStep      = properties.mnTimeStep;
            pPreferences.timeStep      = properties.mnTimeStep
//        pPreferences.clusterScale  = properties.mnClusterScale;
            pPreferences.clusterScale  = properties.mnClusterScale
//        pPreferences.velocityScale = properties.mnVelocityScale;
            pPreferences.velocityScale = properties.mnVelocityScale
//        pPreferences.softening     = properties.mnSoftening;
            pPreferences.softening     = properties.mnSoftening
//        pPreferences.damping       = properties.mnDamping;
            pPreferences.damping       = properties.mnDamping
//        pPreferences.pointSize     = properties.mnPointSize;
            pPreferences.pointSize     = properties.mnPointSize
//        pPreferences.viewDistance  = properties.mnViewDistance;
            pPreferences.viewDistance  = properties.mnViewDistance
//        pPreferences.rotate        = NSMakePoint(properties.mnRotateX, properties.mnRotateY);
            pPreferences.rotate        = NSMakePoint(properties.mnRotateX, properties.mnRotateY)
//    } // if
//} // NBodySimulationPropertiesUpdatePreferences
        }
//
//#pragma mark -
//#pragma mark Public - Interfaces
//
//Properties::Properties(const uint32_t& type)
//{
        private func construct(type: Int) {
//    NBodySimulationPropertiesSetDefaults(type, *this);
            NBody.Simulation.Properties.setDefaults(type, self)
//
//    mnDemos = NBodySimulationPropertiesSetData(mnDemoType, *this);
            mnDemos = NBody.Simulation.Properties.setData(mnDemoType, self)
//} // Constructor
        }
//
//Properties::Properties(NSDictionary* pDictionary)
//{
        private func construct(pDictionary: [String: AnyObject]) {
//    if(pDictionary)
//    {
//        NBodySimulationPropertiesSetDefaults(*this);
            NBody.Simulation.Properties.setDefaults(self)
//        NBodySimulationPropertiesSetData(pDictionary, *this);
            NBody.Simulation.Properties.setData(pDictionary, self)
//    } // if
//} // Constructor
        }
//
//Properties::Properties(NBodyPreferences* pPreferences)
//{
        private func construct(pPreferences: NBodyPreferences) {
//    if(pPreferences)
//    {
//        NBodySimulationPropertiesSetDefaults(*this);
                NBody.Simulation.Properties.setDefaults(self)
//        NBodySimulationPropertiesSetData(pPreferences.preferences, *this);
                NBody.Simulation.Properties.setData(pPreferences.preferences, self)
//    } // Constructor
//} // Constructor
        }
//
//Properties::~Properties()
//{
        private func destruct() {
//    mbIsGPUOnly     = NO;
            mbIsGPUOnly     = false
//    mnDemos         = 0;
            mnDemos         = 0
//    mnDemoType      = 0;
            mnDemoType      = 0
//    mnParticles        = 0;
            mnParticles        = 0
//    mnConfig        = 0;
            mnConfig        = .Random
//    mnTimeStep      = 0.0;
            mnTimeStep      = 0.0
//    mnClusterScale  = 0.0;
            mnClusterScale  = 0.0
//    mnVelocityScale = 0.0;
            mnVelocityScale = 0.0
//    mnSoftening     = 0.0;
            mnSoftening     = 0.0
//    mnDamping       = 0.0;
            mnDamping       = 0.0
//    mnPointSize     = 0.0;
            mnPointSize     = 0.0
//    mnViewDistance  = 0.0;
            mnViewDistance  = 0.0
//    mnRotateX       = 0.0;
            mnRotateX       = 0.0
//    mnRotateY       = 0.0;
            mnRotateY       = 0.0
//} // Destructor
        }
//
//Properties::Properties(const Properties& rProperties)
//{
        private func construct(rProperties: Properties) {
//    NBodySimulationPropertiesCopyData(rProperties, *this);
            NBody.Simulation.Properties.copyData(rProperties, to: self)
//} // Copy Constructor
        }
//
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
//
//void Properties::update(NBodyPreferences* pPreferences)
//{
        func update(pPreferences: NBodyPreferences) {
//    NBodySimulationPropertiesUpdatePreferences(*this, pPreferences);
            NBody.Simulation.Properties.updatePreferences(self, pPreferences)
//} // update
        }
//
//Properties* Properties::create(const size_t& nCount)
//{
//    return NBodySimulationPropertiesCreate(nCount);
//} // Static constructor
//
//Properties* Properties::create(NSString* pFilename)
//{
//    return NBodySimulationPropertiesCreate(CFStringRef(pFilename));
//} // create
//
//Properties* Properties::create()
//{
        static func create() -> [Properties] {
            return Properties.create("NBodySimulationProperties")
//    return NBodySimulationPropertiesCreate(CFSTR("NBodySimulationProperties"));
        }
//} // Static constructor
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