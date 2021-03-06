#if !defined(GPB_GRPC_PROTOCOL_ONLY) || !GPB_GRPC_PROTOCOL_ONLY
#import "google/cloud/translate/v3beta1/TranslationService.pbrpc.h"
#import "google/cloud/translate/v3beta1/TranslationService.pbobjc.h"
#import <ProtoRPC/ProtoRPCLegacy.h>
#import <RxLibrary/GRXWriter+Immediate.h>

#import "google/api/Annotations.pbobjc.h"
#import "google/longrunning/Operations.pbobjc.h"
#if defined(GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS) && GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS
#import <protobuf/Timestamp.pbobjc.h>
#else
#import "google/protobuf/Timestamp.pbobjc.h"
#endif

@implementation TranslationService

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"

// Designated initializer
- (instancetype)initWithHost:(NSString *)host callOptions:(GRPCCallOptions *_Nullable)callOptions {
  return [super initWithHost:host
                 packageName:@"google.cloud.translation.v3beta1"
                 serviceName:@"TranslationService"
                 callOptions:callOptions];
}

- (instancetype)initWithHost:(NSString *)host {
  return [super initWithHost:host
                 packageName:@"google.cloud.translation.v3beta1"
                 serviceName:@"TranslationService"];
}

#pragma clang diagnostic pop

// Override superclass initializer to disallow different package and service names.
- (instancetype)initWithHost:(NSString *)host
                 packageName:(NSString *)packageName
                 serviceName:(NSString *)serviceName {
  return [self initWithHost:host];
}

- (instancetype)initWithHost:(NSString *)host
                 packageName:(NSString *)packageName
                 serviceName:(NSString *)serviceName
                 callOptions:(GRPCCallOptions *)callOptions {
  return [self initWithHost:host callOptions:callOptions];
}

#pragma mark - Class Methods

+ (instancetype)serviceWithHost:(NSString *)host {
  return [[self alloc] initWithHost:host];
}

+ (instancetype)serviceWithHost:(NSString *)host callOptions:(GRPCCallOptions *_Nullable)callOptions {
  return [[self alloc] initWithHost:host callOptions:callOptions];
}

#pragma mark - Method Implementations

#pragma mark TranslateText(TranslateTextRequest) returns (TranslateTextResponse)

/**
 * Translates input text and returns translated text.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (void)translateTextWithRequest:(TranslateTextRequest *)request handler:(void(^)(TranslateTextResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToTranslateTextWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * Translates input text and returns translated text.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (GRPCProtoCall *)RPCToTranslateTextWithRequest:(TranslateTextRequest *)request handler:(void(^)(TranslateTextResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"TranslateText"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[TranslateTextResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
/**
 * Translates input text and returns translated text.
 */
- (GRPCUnaryProtoCall *)translateTextWithMessage:(TranslateTextRequest *)message responseHandler:(id<GRPCProtoResponseHandler>)handler callOptions:(GRPCCallOptions *_Nullable)callOptions {
  return [self RPCToMethod:@"TranslateText"
                   message:message
           responseHandler:handler
               callOptions:callOptions
             responseClass:[TranslateTextResponse class]];
}

#pragma mark DetectLanguage(DetectLanguageRequest) returns (DetectLanguageResponse)

/**
 * Detects the language of text within a request.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (void)detectLanguageWithRequest:(DetectLanguageRequest *)request handler:(void(^)(DetectLanguageResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToDetectLanguageWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * Detects the language of text within a request.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (GRPCProtoCall *)RPCToDetectLanguageWithRequest:(DetectLanguageRequest *)request handler:(void(^)(DetectLanguageResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"DetectLanguage"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[DetectLanguageResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
/**
 * Detects the language of text within a request.
 */
- (GRPCUnaryProtoCall *)detectLanguageWithMessage:(DetectLanguageRequest *)message responseHandler:(id<GRPCProtoResponseHandler>)handler callOptions:(GRPCCallOptions *_Nullable)callOptions {
  return [self RPCToMethod:@"DetectLanguage"
                   message:message
           responseHandler:handler
               callOptions:callOptions
             responseClass:[DetectLanguageResponse class]];
}

#pragma mark GetSupportedLanguages(GetSupportedLanguagesRequest) returns (SupportedLanguages)

/**
 * Returns a list of supported languages for translation.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (void)getSupportedLanguagesWithRequest:(GetSupportedLanguagesRequest *)request handler:(void(^)(SupportedLanguages *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToGetSupportedLanguagesWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * Returns a list of supported languages for translation.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (GRPCProtoCall *)RPCToGetSupportedLanguagesWithRequest:(GetSupportedLanguagesRequest *)request handler:(void(^)(SupportedLanguages *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"GetSupportedLanguages"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[SupportedLanguages class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
/**
 * Returns a list of supported languages for translation.
 */
- (GRPCUnaryProtoCall *)getSupportedLanguagesWithMessage:(GetSupportedLanguagesRequest *)message responseHandler:(id<GRPCProtoResponseHandler>)handler callOptions:(GRPCCallOptions *_Nullable)callOptions {
  return [self RPCToMethod:@"GetSupportedLanguages"
                   message:message
           responseHandler:handler
               callOptions:callOptions
             responseClass:[SupportedLanguages class]];
}

#pragma mark BatchTranslateText(BatchTranslateTextRequest) returns (Operation)

/**
 * Translates a large volume of text in asynchronous batch mode.
 * This function provides real-time output as the inputs are being processed.
 * If caller cancels a request, the partial results (for an input file, it's
 * all or nothing) may still be available on the specified output location.
 * 
 * This call returns immediately and you can
 * use google.longrunning.Operation.name to poll the status of the call.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (void)batchTranslateTextWithRequest:(BatchTranslateTextRequest *)request handler:(void(^)(Operation *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToBatchTranslateTextWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * Translates a large volume of text in asynchronous batch mode.
 * This function provides real-time output as the inputs are being processed.
 * If caller cancels a request, the partial results (for an input file, it's
 * all or nothing) may still be available on the specified output location.
 * 
 * This call returns immediately and you can
 * use google.longrunning.Operation.name to poll the status of the call.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (GRPCProtoCall *)RPCToBatchTranslateTextWithRequest:(BatchTranslateTextRequest *)request handler:(void(^)(Operation *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"BatchTranslateText"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[Operation class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
/**
 * Translates a large volume of text in asynchronous batch mode.
 * This function provides real-time output as the inputs are being processed.
 * If caller cancels a request, the partial results (for an input file, it's
 * all or nothing) may still be available on the specified output location.
 * 
 * This call returns immediately and you can
 * use google.longrunning.Operation.name to poll the status of the call.
 */
- (GRPCUnaryProtoCall *)batchTranslateTextWithMessage:(BatchTranslateTextRequest *)message responseHandler:(id<GRPCProtoResponseHandler>)handler callOptions:(GRPCCallOptions *_Nullable)callOptions {
  return [self RPCToMethod:@"BatchTranslateText"
                   message:message
           responseHandler:handler
               callOptions:callOptions
             responseClass:[Operation class]];
}

#pragma mark CreateGlossary(CreateGlossaryRequest) returns (Operation)

/**
 * Creates a glossary and returns the long-running operation. Returns
 * NOT_FOUND, if the project doesn't exist.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (void)createGlossaryWithRequest:(CreateGlossaryRequest *)request handler:(void(^)(Operation *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToCreateGlossaryWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * Creates a glossary and returns the long-running operation. Returns
 * NOT_FOUND, if the project doesn't exist.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (GRPCProtoCall *)RPCToCreateGlossaryWithRequest:(CreateGlossaryRequest *)request handler:(void(^)(Operation *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"CreateGlossary"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[Operation class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
/**
 * Creates a glossary and returns the long-running operation. Returns
 * NOT_FOUND, if the project doesn't exist.
 */
- (GRPCUnaryProtoCall *)createGlossaryWithMessage:(CreateGlossaryRequest *)message responseHandler:(id<GRPCProtoResponseHandler>)handler callOptions:(GRPCCallOptions *_Nullable)callOptions {
  return [self RPCToMethod:@"CreateGlossary"
                   message:message
           responseHandler:handler
               callOptions:callOptions
             responseClass:[Operation class]];
}

#pragma mark ListGlossaries(ListGlossariesRequest) returns (ListGlossariesResponse)

/**
 * Lists glossaries in a project. Returns NOT_FOUND, if the project doesn't
 * exist.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (void)listGlossariesWithRequest:(ListGlossariesRequest *)request handler:(void(^)(ListGlossariesResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToListGlossariesWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * Lists glossaries in a project. Returns NOT_FOUND, if the project doesn't
 * exist.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (GRPCProtoCall *)RPCToListGlossariesWithRequest:(ListGlossariesRequest *)request handler:(void(^)(ListGlossariesResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"ListGlossaries"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[ListGlossariesResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
/**
 * Lists glossaries in a project. Returns NOT_FOUND, if the project doesn't
 * exist.
 */
- (GRPCUnaryProtoCall *)listGlossariesWithMessage:(ListGlossariesRequest *)message responseHandler:(id<GRPCProtoResponseHandler>)handler callOptions:(GRPCCallOptions *_Nullable)callOptions {
  return [self RPCToMethod:@"ListGlossaries"
                   message:message
           responseHandler:handler
               callOptions:callOptions
             responseClass:[ListGlossariesResponse class]];
}

#pragma mark GetGlossary(GetGlossaryRequest) returns (Glossary)

/**
 * Gets a glossary. Returns NOT_FOUND, if the glossary doesn't
 * exist.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (void)getGlossaryWithRequest:(GetGlossaryRequest *)request handler:(void(^)(Glossary *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToGetGlossaryWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * Gets a glossary. Returns NOT_FOUND, if the glossary doesn't
 * exist.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (GRPCProtoCall *)RPCToGetGlossaryWithRequest:(GetGlossaryRequest *)request handler:(void(^)(Glossary *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"GetGlossary"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[Glossary class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
/**
 * Gets a glossary. Returns NOT_FOUND, if the glossary doesn't
 * exist.
 */
- (GRPCUnaryProtoCall *)getGlossaryWithMessage:(GetGlossaryRequest *)message responseHandler:(id<GRPCProtoResponseHandler>)handler callOptions:(GRPCCallOptions *_Nullable)callOptions {
  return [self RPCToMethod:@"GetGlossary"
                   message:message
           responseHandler:handler
               callOptions:callOptions
             responseClass:[Glossary class]];
}

#pragma mark DeleteGlossary(DeleteGlossaryRequest) returns (Operation)

/**
 * Deletes a glossary, or cancels glossary construction
 * if the glossary isn't created yet.
 * Returns NOT_FOUND, if the glossary doesn't exist.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (void)deleteGlossaryWithRequest:(DeleteGlossaryRequest *)request handler:(void(^)(Operation *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToDeleteGlossaryWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * Deletes a glossary, or cancels glossary construction
 * if the glossary isn't created yet.
 * Returns NOT_FOUND, if the glossary doesn't exist.
 *
 * This method belongs to a set of APIs that have been deprecated. Using the v2 API is recommended.
 */
- (GRPCProtoCall *)RPCToDeleteGlossaryWithRequest:(DeleteGlossaryRequest *)request handler:(void(^)(Operation *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"DeleteGlossary"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[Operation class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
/**
 * Deletes a glossary, or cancels glossary construction
 * if the glossary isn't created yet.
 * Returns NOT_FOUND, if the glossary doesn't exist.
 */
- (GRPCUnaryProtoCall *)deleteGlossaryWithMessage:(DeleteGlossaryRequest *)message responseHandler:(id<GRPCProtoResponseHandler>)handler callOptions:(GRPCCallOptions *_Nullable)callOptions {
  return [self RPCToMethod:@"DeleteGlossary"
                   message:message
           responseHandler:handler
               callOptions:callOptions
             responseClass:[Operation class]];
}

@end
#endif
