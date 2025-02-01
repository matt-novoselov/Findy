//
// yolov8n.swift
//
// This file was automatically generated and should not be edited.
//

import CoreML


/// Model Prediction Input Type
@available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, visionOS 1.0, *)
class yolov8nInput : MLFeatureProvider {
    
    /// image as color (kCVPixelFormatType_32BGRA) image buffer, 640 pixels wide by 640 pixels high
    var image: CVPixelBuffer
    
    /// iouThreshold as double value
    var iouThreshold: Double
    
    /// confidenceThreshold as double value
    var confidenceThreshold: Double
    
    var featureNames: Set<String> { ["image", "iouThreshold", "confidenceThreshold"] }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        if featureName == "image" {
            return MLFeatureValue(pixelBuffer: image)
        }
        if featureName == "iouThreshold" {
            return MLFeatureValue(double: iouThreshold)
        }
        if featureName == "confidenceThreshold" {
            return MLFeatureValue(double: confidenceThreshold)
        }
        return nil
    }
    
    init(image: CVPixelBuffer, iouThreshold: Double, confidenceThreshold: Double) {
        self.image = image
        self.iouThreshold = iouThreshold
        self.confidenceThreshold = confidenceThreshold
    }
    
    convenience init(imageWith image: CGImage, iouThreshold: Double, confidenceThreshold: Double) throws {
        self.init(image: try MLFeatureValue(cgImage: image, pixelsWide: 640, pixelsHigh: 640, pixelFormatType: kCVPixelFormatType_32ARGB, options: nil).imageBufferValue!, iouThreshold: iouThreshold, confidenceThreshold: confidenceThreshold)
    }
    
    convenience init(imageAt image: URL, iouThreshold: Double, confidenceThreshold: Double) throws {
        self.init(image: try MLFeatureValue(imageAt: image, pixelsWide: 640, pixelsHigh: 640, pixelFormatType: kCVPixelFormatType_32ARGB, options: nil).imageBufferValue!, iouThreshold: iouThreshold, confidenceThreshold: confidenceThreshold)
    }
    
    func setImage(with image: CGImage) throws  {
        self.image = try MLFeatureValue(cgImage: image, pixelsWide: 640, pixelsHigh: 640, pixelFormatType: kCVPixelFormatType_32ARGB, options: nil).imageBufferValue!
    }
    
    func setImage(with image: URL) throws  {
        self.image = try MLFeatureValue(imageAt: image, pixelsWide: 640, pixelsHigh: 640, pixelFormatType: kCVPixelFormatType_32ARGB, options: nil).imageBufferValue!
    }
    
}


/// Model Prediction Output Type
@available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, visionOS 1.0, *)
class yolov8nOutput : MLFeatureProvider {
    
    /// Source provided by CoreML
    private let provider : MLFeatureProvider
    
    /// confidence as multidimensional array of floats
    var confidence: MLMultiArray {
        provider.featureValue(for: "confidence")!.multiArrayValue!
    }
    
    /// confidence as multidimensional array of floats
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
    var confidenceShapedArray: MLShapedArray<Float> {
        MLShapedArray<Float>(confidence)
    }
    
    /// coordinates as multidimensional array of floats
    var coordinates: MLMultiArray {
        provider.featureValue(for: "coordinates")!.multiArrayValue!
    }
    
    /// coordinates as multidimensional array of floats
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
    var coordinatesShapedArray: MLShapedArray<Float> {
        MLShapedArray<Float>(coordinates)
    }
    
    var featureNames: Set<String> {
        provider.featureNames
    }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        provider.featureValue(for: featureName)
    }
    
    init(confidence: MLMultiArray, coordinates: MLMultiArray) {
        self.provider = try! MLDictionaryFeatureProvider(dictionary: ["confidence" : MLFeatureValue(multiArray: confidence), "coordinates" : MLFeatureValue(multiArray: coordinates)])
    }
    
    init(features: MLFeatureProvider) {
        self.provider = features
    }
}


/// Class for model loading and prediction
@available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, visionOS 1.0, *)
class yolov8n {
    let model: MLModel
    
    /// URL of model assuming it was installed in the same bundle as this class
    class var urlOfModelInThisBundle : URL {
        let resPath = Bundle(for: self).url(forResource: "YOLO8", withExtension: "zip")!
        return try! MLModel.compileModel(at: resPath)
    }
    
    /**
     Construct yolov8n instance with an existing MLModel object.
     
     Usually the application does not use this initializer unless it makes a subclass of yolov8n.
     Such application may want to use `MLModel(contentsOfURL:configuration:)` and `yolov8n.urlOfModelInThisBundle` to create a MLModel object to pass-in.
     
     - parameters:
     - model: MLModel object
     */
    init(model: MLModel) {
        self.model = model
    }
    
    /**
     Construct a model with configuration
     
     - parameters:
     - configuration: the desired model configuration
     
     - throws: an NSError object that describes the problem
     */
    convenience init(configuration: MLModelConfiguration = MLModelConfiguration()) throws {
        try self.init(contentsOf: type(of:self).urlOfModelInThisBundle, configuration: configuration)
    }
    
    /**
     Construct yolov8n instance with explicit path to mlmodelc file
     - parameters:
     - modelURL: the file url of the model
     
     - throws: an NSError object that describes the problem
     */
    convenience init(contentsOf modelURL: URL) throws {
        try self.init(model: MLModel(contentsOf: modelURL))
    }
    
    /**
     Construct a model with URL of the .mlmodelc directory and configuration
     
     - parameters:
     - modelURL: the file url of the model
     - configuration: the desired model configuration
     
     - throws: an NSError object that describes the problem
     */
    convenience init(contentsOf modelURL: URL, configuration: MLModelConfiguration) throws {
        try self.init(model: MLModel(contentsOf: modelURL, configuration: configuration))
    }
    
    /**
     Construct yolov8n instance asynchronously with optional configuration.
     
     Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.
     
     - parameters:
     - configuration: the desired model configuration
     - handler: the completion handler to be called when the model loading completes successfully or unsuccessfully
     */
    class func load(configuration: MLModelConfiguration = MLModelConfiguration(), completionHandler handler: @escaping (Swift.Result<yolov8n, Error>) -> Void) {
        load(contentsOf: self.urlOfModelInThisBundle, configuration: configuration, completionHandler: handler)
    }
    
    /**
     Construct yolov8n instance asynchronously with optional configuration.
     
     Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.
     
     - parameters:
     - configuration: the desired model configuration
     */
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
    class func load(configuration: MLModelConfiguration = MLModelConfiguration()) async throws -> yolov8n {
        try await load(contentsOf: self.urlOfModelInThisBundle, configuration: configuration)
    }
    
    /**
     Construct yolov8n instance asynchronously with URL of the .mlmodelc directory with optional configuration.
     
     Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.
     
     - parameters:
     - modelURL: the URL to the model
     - configuration: the desired model configuration
     - handler: the completion handler to be called when the model loading completes successfully or unsuccessfully
     */
    class func load(contentsOf modelURL: URL, configuration: MLModelConfiguration = MLModelConfiguration(), completionHandler handler: @escaping (Swift.Result<yolov8n, Error>) -> Void) {
        MLModel.load(contentsOf: modelURL, configuration: configuration) { result in
            switch result {
            case .failure(let error):
                handler(.failure(error))
            case .success(let model):
                handler(.success(yolov8n(model: model)))
            }
        }
    }
    
    /**
     Construct yolov8n instance asynchronously with URL of the .mlmodelc directory with optional configuration.
     
     Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.
     
     - parameters:
     - modelURL: the URL to the model
     - configuration: the desired model configuration
     */
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
    class func load(contentsOf modelURL: URL, configuration: MLModelConfiguration = MLModelConfiguration()) async throws -> yolov8n {
        let model = try await MLModel.load(contentsOf: modelURL, configuration: configuration)
        return yolov8n(model: model)
    }
    
    /**
     Make a prediction using the structured interface
     
     It uses the default function if the model has multiple functions.
     
     - parameters:
     - input: the input to the prediction as yolov8nInput
     
     - throws: an NSError object that describes the problem
     
     - returns: the result of the prediction as yolov8nOutput
     */
    func prediction(input: yolov8nInput) throws -> yolov8nOutput {
        try prediction(input: input, options: MLPredictionOptions())
    }
    
    /**
     Make a prediction using the structured interface
     
     It uses the default function if the model has multiple functions.
     
     - parameters:
     - input: the input to the prediction as yolov8nInput
     - options: prediction options
     
     - throws: an NSError object that describes the problem
     
     - returns: the result of the prediction as yolov8nOutput
     */
    func prediction(input: yolov8nInput, options: MLPredictionOptions) throws -> yolov8nOutput {
        let outFeatures = try model.prediction(from: input, options: options)
        return yolov8nOutput(features: outFeatures)
    }
    
    /**
     Make an asynchronous prediction using the structured interface
     
     It uses the default function if the model has multiple functions.
     
     - parameters:
     - input: the input to the prediction as yolov8nInput
     - options: prediction options
     
     - throws: an NSError object that describes the problem
     
     - returns: the result of the prediction as yolov8nOutput
     */
    @available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
    func prediction(input: yolov8nInput, options: MLPredictionOptions = MLPredictionOptions()) async throws -> yolov8nOutput {
        let outFeatures = try await model.prediction(from: input, options: options)
        return yolov8nOutput(features: outFeatures)
    }
    
    /**
     Make a prediction using the convenience interface
     
     It uses the default function if the model has multiple functions.
     
     - parameters:
     - image: color (kCVPixelFormatType_32BGRA) image buffer, 640 pixels wide by 640 pixels high
     - iouThreshold: double value
     - confidenceThreshold: double value
     
     - throws: an NSError object that describes the problem
     
     - returns: the result of the prediction as yolov8nOutput
     */
    func prediction(image: CVPixelBuffer, iouThreshold: Double, confidenceThreshold: Double) throws -> yolov8nOutput {
        let input_ = yolov8nInput(image: image, iouThreshold: iouThreshold, confidenceThreshold: confidenceThreshold)
        return try prediction(input: input_)
    }
    
    /**
     Make a batch prediction using the structured interface
     
     It uses the default function if the model has multiple functions.
     
     - parameters:
     - inputs: the inputs to the prediction as [yolov8nInput]
     - options: prediction options
     
     - throws: an NSError object that describes the problem
     
     - returns: the result of the prediction as [yolov8nOutput]
     */
    func predictions(inputs: [yolov8nInput], options: MLPredictionOptions = MLPredictionOptions()) throws -> [yolov8nOutput] {
        let batchIn = MLArrayBatchProvider(array: inputs)
        let batchOut = try model.predictions(from: batchIn, options: options)
        var results : [yolov8nOutput] = []
        results.reserveCapacity(inputs.count)
        for i in 0..<batchOut.count {
            let outProvider = batchOut.features(at: i)
            let result =  yolov8nOutput(features: outProvider)
            results.append(result)
        }
        return results
    }
}
