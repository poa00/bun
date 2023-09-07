// Generated by `bun src/js/builtins/codegen`
// Do not edit by hand.
type RemoveThis<F> = F extends (this: infer T, ...args: infer A) => infer R ? (...args: A) => R : F;

// ReadableByteStreamInternals.ts
declare const $privateInitializeReadableByteStreamController: RemoveThis<typeof import("../builtins/ReadableByteStreamInternals")["privateInitializeReadableByteStreamController"]>;
declare const $readableStreamByteStreamControllerStart: RemoveThis<typeof import("../builtins/ReadableByteStreamInternals")["readableStreamByteStreamControllerStart"]>;
declare const $privateInitializeReadableStreamBYOBRequest: RemoveThis<typeof import("../builtins/ReadableByteStreamInternals")["privateInitializeReadableStreamBYOBRequest"]>;
declare const $isReadableByteStreamController: RemoveThis<typeof import("../builtins/ReadableByteStreamInternals")["isReadableByteStreamController"]>;
declare const $isReadableStreamBYOBRequest: RemoveThis<typeof import("../builtins/ReadableByteStreamInternals")["isReadableStreamBYOBRequest"]>;
declare const $isReadableStreamBYOBReader: RemoveThis<typeof import("../builtins/ReadableByteStreamInternals")["isReadableStreamBYOBReader"]>;
declare const $readableByteStreamControllerCancel: RemoveThis<typeof import("../builtins/ReadableByteStreamInternals")["readableByteStreamControllerCancel"]>;
declare const $readableByteStreamControllerError: RemoveThis<typeof import("../builtins/ReadableByteStreamInternals")["readableByteStreamControllerError"]>;
declare const $readableByteStreamControllerClose: RemoveThis<typeof import("../builtins/ReadableByteStreamInternals")["readableByteStreamControllerClose"]>;
declare const $readableByteStreamControllerClearPendingPullIntos: RemoveThis<typeof import("../builtins/ReadableByteStreamInternals")["readableByteStreamControllerClearPendingPullIntos"]>;
declare const $readableByteStreamControllerGetDesiredSize: RemoveThis<typeof import("../builtins/ReadableByteStreamInternals")["readableByteStreamControllerGetDesiredSize"]>;
declare const $readableStreamHasBYOBReader: RemoveThis<typeof import("../builtins/ReadableByteStreamInternals")["readableStreamHasBYOBReader"]>;
declare const $readableStreamHasDefaultReader: RemoveThis<typeof import("../builtins/ReadableByteStreamInternals")["readableStreamHasDefaultReader"]>;
declare const $readableByteStreamControllerHandleQueueDrain: RemoveThis<typeof import("../builtins/ReadableByteStreamInternals")["readableByteStreamControllerHandleQueueDrain"]>;
declare const $readableByteStreamControllerPull: RemoveThis<typeof import("../builtins/ReadableByteStreamInternals")["readableByteStreamControllerPull"]>;
declare const $readableByteStreamControllerShouldCallPull: RemoveThis<typeof import("../builtins/ReadableByteStreamInternals")["readableByteStreamControllerShouldCallPull"]>;
declare const $readableByteStreamControllerCallPullIfNeeded: RemoveThis<typeof import("../builtins/ReadableByteStreamInternals")["readableByteStreamControllerCallPullIfNeeded"]>;
declare const $transferBufferToCurrentRealm: RemoveThis<typeof import("../builtins/ReadableByteStreamInternals")["transferBufferToCurrentRealm"]>;
declare const $readableStreamReaderKind: RemoveThis<typeof import("../builtins/ReadableByteStreamInternals")["readableStreamReaderKind"]>;
declare const $readableByteStreamControllerEnqueue: RemoveThis<typeof import("../builtins/ReadableByteStreamInternals")["readableByteStreamControllerEnqueue"]>;
declare const $readableByteStreamControllerEnqueueChunk: RemoveThis<typeof import("../builtins/ReadableByteStreamInternals")["readableByteStreamControllerEnqueueChunk"]>;
declare const $readableByteStreamControllerRespondWithNewView: RemoveThis<typeof import("../builtins/ReadableByteStreamInternals")["readableByteStreamControllerRespondWithNewView"]>;
declare const $readableByteStreamControllerRespond: RemoveThis<typeof import("../builtins/ReadableByteStreamInternals")["readableByteStreamControllerRespond"]>;
declare const $readableByteStreamControllerRespondInternal: RemoveThis<typeof import("../builtins/ReadableByteStreamInternals")["readableByteStreamControllerRespondInternal"]>;
declare const $readableByteStreamControllerRespondInReadableState: RemoveThis<typeof import("../builtins/ReadableByteStreamInternals")["readableByteStreamControllerRespondInReadableState"]>;
declare const $readableByteStreamControllerRespondInClosedState: RemoveThis<typeof import("../builtins/ReadableByteStreamInternals")["readableByteStreamControllerRespondInClosedState"]>;
declare const $readableByteStreamControllerProcessPullDescriptors: RemoveThis<typeof import("../builtins/ReadableByteStreamInternals")["readableByteStreamControllerProcessPullDescriptors"]>;
declare const $readableByteStreamControllerFillDescriptorFromQueue: RemoveThis<typeof import("../builtins/ReadableByteStreamInternals")["readableByteStreamControllerFillDescriptorFromQueue"]>;
declare const $readableByteStreamControllerShiftPendingDescriptor: RemoveThis<typeof import("../builtins/ReadableByteStreamInternals")["readableByteStreamControllerShiftPendingDescriptor"]>;
declare const $readableByteStreamControllerInvalidateBYOBRequest: RemoveThis<typeof import("../builtins/ReadableByteStreamInternals")["readableByteStreamControllerInvalidateBYOBRequest"]>;
declare const $readableByteStreamControllerCommitDescriptor: RemoveThis<typeof import("../builtins/ReadableByteStreamInternals")["readableByteStreamControllerCommitDescriptor"]>;
declare const $readableByteStreamControllerConvertDescriptor: RemoveThis<typeof import("../builtins/ReadableByteStreamInternals")["readableByteStreamControllerConvertDescriptor"]>;
declare const $readableStreamFulfillReadIntoRequest: RemoveThis<typeof import("../builtins/ReadableByteStreamInternals")["readableStreamFulfillReadIntoRequest"]>;
declare const $readableStreamBYOBReaderRead: RemoveThis<typeof import("../builtins/ReadableByteStreamInternals")["readableStreamBYOBReaderRead"]>;
declare const $readableByteStreamControllerPullInto: RemoveThis<typeof import("../builtins/ReadableByteStreamInternals")["readableByteStreamControllerPullInto"]>;
declare const $readableStreamAddReadIntoRequest: RemoveThis<typeof import("../builtins/ReadableByteStreamInternals")["readableStreamAddReadIntoRequest"]>;

// StreamInternals.ts
declare const $markPromiseAsHandled: RemoveThis<typeof import("../builtins/StreamInternals")["markPromiseAsHandled"]>;
declare const $shieldingPromiseResolve: RemoveThis<typeof import("../builtins/StreamInternals")["shieldingPromiseResolve"]>;
declare const $promiseInvokeOrNoopMethodNoCatch: RemoveThis<typeof import("../builtins/StreamInternals")["promiseInvokeOrNoopMethodNoCatch"]>;
declare const $promiseInvokeOrNoopNoCatch: RemoveThis<typeof import("../builtins/StreamInternals")["promiseInvokeOrNoopNoCatch"]>;
declare const $promiseInvokeOrNoopMethod: RemoveThis<typeof import("../builtins/StreamInternals")["promiseInvokeOrNoopMethod"]>;
declare const $promiseInvokeOrNoop: RemoveThis<typeof import("../builtins/StreamInternals")["promiseInvokeOrNoop"]>;
declare const $promiseInvokeOrFallbackOrNoop: RemoveThis<typeof import("../builtins/StreamInternals")["promiseInvokeOrFallbackOrNoop"]>;
declare const $validateAndNormalizeQueuingStrategy: RemoveThis<typeof import("../builtins/StreamInternals")["validateAndNormalizeQueuingStrategy"]>;
declare const $createFIFO: RemoveThis<typeof import("../builtins/StreamInternals")["createFIFO"]>;
declare const $newQueue: RemoveThis<typeof import("../builtins/StreamInternals")["newQueue"]>;
declare const $dequeueValue: RemoveThis<typeof import("../builtins/StreamInternals")["dequeueValue"]>;
declare const $enqueueValueWithSize: RemoveThis<typeof import("../builtins/StreamInternals")["enqueueValueWithSize"]>;
declare const $peekQueueValue: RemoveThis<typeof import("../builtins/StreamInternals")["peekQueueValue"]>;
declare const $resetQueue: RemoveThis<typeof import("../builtins/StreamInternals")["resetQueue"]>;
declare const $extractSizeAlgorithm: RemoveThis<typeof import("../builtins/StreamInternals")["extractSizeAlgorithm"]>;
declare const $extractHighWaterMark: RemoveThis<typeof import("../builtins/StreamInternals")["extractHighWaterMark"]>;
declare const $extractHighWaterMarkFromQueuingStrategyInit: RemoveThis<typeof import("../builtins/StreamInternals")["extractHighWaterMarkFromQueuingStrategyInit"]>;
declare const $createFulfilledPromise: RemoveThis<typeof import("../builtins/StreamInternals")["createFulfilledPromise"]>;
declare const $toDictionary: RemoveThis<typeof import("../builtins/StreamInternals")["toDictionary"]>;

// ReadableStreamInternals.ts
declare const $readableStreamReaderGenericInitialize: RemoveThis<typeof import("../builtins/ReadableStreamInternals")["readableStreamReaderGenericInitialize"]>;
declare const $privateInitializeReadableStreamDefaultController: RemoveThis<typeof import("../builtins/ReadableStreamInternals")["privateInitializeReadableStreamDefaultController"]>;
declare const $readableStreamDefaultControllerError: RemoveThis<typeof import("../builtins/ReadableStreamInternals")["readableStreamDefaultControllerError"]>;
declare const $readableStreamPipeTo: RemoveThis<typeof import("../builtins/ReadableStreamInternals")["readableStreamPipeTo"]>;
declare const $acquireReadableStreamDefaultReader: RemoveThis<typeof import("../builtins/ReadableStreamInternals")["acquireReadableStreamDefaultReader"]>;
declare const $setupReadableStreamDefaultController: RemoveThis<typeof import("../builtins/ReadableStreamInternals")["setupReadableStreamDefaultController"]>;
declare const $createReadableStreamController: RemoveThis<typeof import("../builtins/ReadableStreamInternals")["createReadableStreamController"]>;
declare const $readableStreamDefaultControllerStart: RemoveThis<typeof import("../builtins/ReadableStreamInternals")["readableStreamDefaultControllerStart"]>;
declare const $readableStreamPipeToWritableStream: RemoveThis<typeof import("../builtins/ReadableStreamInternals")["readableStreamPipeToWritableStream"]>;
declare const $pipeToLoop: RemoveThis<typeof import("../builtins/ReadableStreamInternals")["pipeToLoop"]>;
declare const $pipeToDoReadWrite: RemoveThis<typeof import("../builtins/ReadableStreamInternals")["pipeToDoReadWrite"]>;
declare const $pipeToErrorsMustBePropagatedForward: RemoveThis<typeof import("../builtins/ReadableStreamInternals")["pipeToErrorsMustBePropagatedForward"]>;
declare const $pipeToErrorsMustBePropagatedBackward: RemoveThis<typeof import("../builtins/ReadableStreamInternals")["pipeToErrorsMustBePropagatedBackward"]>;
declare const $pipeToClosingMustBePropagatedForward: RemoveThis<typeof import("../builtins/ReadableStreamInternals")["pipeToClosingMustBePropagatedForward"]>;
declare const $pipeToClosingMustBePropagatedBackward: RemoveThis<typeof import("../builtins/ReadableStreamInternals")["pipeToClosingMustBePropagatedBackward"]>;
declare const $pipeToShutdownWithAction: RemoveThis<typeof import("../builtins/ReadableStreamInternals")["pipeToShutdownWithAction"]>;
declare const $pipeToShutdown: RemoveThis<typeof import("../builtins/ReadableStreamInternals")["pipeToShutdown"]>;
declare const $pipeToFinalize: RemoveThis<typeof import("../builtins/ReadableStreamInternals")["pipeToFinalize"]>;
declare const $readableStreamTee: RemoveThis<typeof import("../builtins/ReadableStreamInternals")["readableStreamTee"]>;
declare const $readableStreamTeePullFunction: RemoveThis<typeof import("../builtins/ReadableStreamInternals")["readableStreamTeePullFunction"]>;
declare const $readableStreamTeeBranch1CancelFunction: RemoveThis<typeof import("../builtins/ReadableStreamInternals")["readableStreamTeeBranch1CancelFunction"]>;
declare const $readableStreamTeeBranch2CancelFunction: RemoveThis<typeof import("../builtins/ReadableStreamInternals")["readableStreamTeeBranch2CancelFunction"]>;
declare const $isReadableStream: RemoveThis<typeof import("../builtins/ReadableStreamInternals")["isReadableStream"]>;
declare const $isReadableStreamDefaultReader: RemoveThis<typeof import("../builtins/ReadableStreamInternals")["isReadableStreamDefaultReader"]>;
declare const $isReadableStreamDefaultController: RemoveThis<typeof import("../builtins/ReadableStreamInternals")["isReadableStreamDefaultController"]>;
declare const $readDirectStream: RemoveThis<typeof import("../builtins/ReadableStreamInternals")["readDirectStream"]>;
declare const $assignToStream: RemoveThis<typeof import("../builtins/ReadableStreamInternals")["assignToStream"]>;
declare const $readStreamIntoSink: RemoveThis<typeof import("../builtins/ReadableStreamInternals")["readStreamIntoSink"]>;
declare const $handleDirectStreamError: RemoveThis<typeof import("../builtins/ReadableStreamInternals")["handleDirectStreamError"]>;
declare const $handleDirectStreamErrorReject: RemoveThis<typeof import("../builtins/ReadableStreamInternals")["handleDirectStreamErrorReject"]>;
declare const $onPullDirectStream: RemoveThis<typeof import("../builtins/ReadableStreamInternals")["onPullDirectStream"]>;
declare const $noopDoneFunction: RemoveThis<typeof import("../builtins/ReadableStreamInternals")["noopDoneFunction"]>;
declare const $onReadableStreamDirectControllerClosed: RemoveThis<typeof import("../builtins/ReadableStreamInternals")["onReadableStreamDirectControllerClosed"]>;
declare const $onCloseDirectStream: RemoveThis<typeof import("../builtins/ReadableStreamInternals")["onCloseDirectStream"]>;
declare const $onFlushDirectStream: RemoveThis<typeof import("../builtins/ReadableStreamInternals")["onFlushDirectStream"]>;
declare const $createTextStream: RemoveThis<typeof import("../builtins/ReadableStreamInternals")["createTextStream"]>;
declare const $initializeTextStream: RemoveThis<typeof import("../builtins/ReadableStreamInternals")["initializeTextStream"]>;
declare const $initializeArrayStream: RemoveThis<typeof import("../builtins/ReadableStreamInternals")["initializeArrayStream"]>;
declare const $initializeArrayBufferStream: RemoveThis<typeof import("../builtins/ReadableStreamInternals")["initializeArrayBufferStream"]>;
declare const $readableStreamError: RemoveThis<typeof import("../builtins/ReadableStreamInternals")["readableStreamError"]>;
declare const $readableStreamDefaultControllerShouldCallPull: RemoveThis<typeof import("../builtins/ReadableStreamInternals")["readableStreamDefaultControllerShouldCallPull"]>;
declare const $readableStreamDefaultControllerCallPullIfNeeded: RemoveThis<typeof import("../builtins/ReadableStreamInternals")["readableStreamDefaultControllerCallPullIfNeeded"]>;
declare const $isReadableStreamLocked: RemoveThis<typeof import("../builtins/ReadableStreamInternals")["isReadableStreamLocked"]>;
declare const $readableStreamDefaultControllerGetDesiredSize: RemoveThis<typeof import("../builtins/ReadableStreamInternals")["readableStreamDefaultControllerGetDesiredSize"]>;
declare const $readableStreamReaderGenericCancel: RemoveThis<typeof import("../builtins/ReadableStreamInternals")["readableStreamReaderGenericCancel"]>;
declare const $readableStreamCancel: RemoveThis<typeof import("../builtins/ReadableStreamInternals")["readableStreamCancel"]>;
declare const $readableStreamDefaultControllerCancel: RemoveThis<typeof import("../builtins/ReadableStreamInternals")["readableStreamDefaultControllerCancel"]>;
declare const $readableStreamDefaultControllerPull: RemoveThis<typeof import("../builtins/ReadableStreamInternals")["readableStreamDefaultControllerPull"]>;
declare const $readableStreamDefaultControllerClose: RemoveThis<typeof import("../builtins/ReadableStreamInternals")["readableStreamDefaultControllerClose"]>;
declare const $readableStreamClose: RemoveThis<typeof import("../builtins/ReadableStreamInternals")["readableStreamClose"]>;
declare const $readableStreamFulfillReadRequest: RemoveThis<typeof import("../builtins/ReadableStreamInternals")["readableStreamFulfillReadRequest"]>;
declare const $readableStreamDefaultControllerEnqueue: RemoveThis<typeof import("../builtins/ReadableStreamInternals")["readableStreamDefaultControllerEnqueue"]>;
declare const $readableStreamDefaultReaderRead: RemoveThis<typeof import("../builtins/ReadableStreamInternals")["readableStreamDefaultReaderRead"]>;
declare const $readableStreamAddReadRequest: RemoveThis<typeof import("../builtins/ReadableStreamInternals")["readableStreamAddReadRequest"]>;
declare const $isReadableStreamDisturbed: RemoveThis<typeof import("../builtins/ReadableStreamInternals")["isReadableStreamDisturbed"]>;
declare const $readableStreamReaderGenericRelease: RemoveThis<typeof import("../builtins/ReadableStreamInternals")["readableStreamReaderGenericRelease"]>;
declare const $readableStreamDefaultControllerCanCloseOrEnqueue: RemoveThis<typeof import("../builtins/ReadableStreamInternals")["readableStreamDefaultControllerCanCloseOrEnqueue"]>;
declare const $lazyLoadStream: RemoveThis<typeof import("../builtins/ReadableStreamInternals")["lazyLoadStream"]>;
declare const $readableStreamIntoArray: RemoveThis<typeof import("../builtins/ReadableStreamInternals")["readableStreamIntoArray"]>;
declare const $readableStreamIntoText: RemoveThis<typeof import("../builtins/ReadableStreamInternals")["readableStreamIntoText"]>;
declare const $readableStreamToArrayBufferDirect: RemoveThis<typeof import("../builtins/ReadableStreamInternals")["readableStreamToArrayBufferDirect"]>;
declare const $readableStreamToTextDirect: RemoveThis<typeof import("../builtins/ReadableStreamInternals")["readableStreamToTextDirect"]>;
declare const $readableStreamToArrayDirect: RemoveThis<typeof import("../builtins/ReadableStreamInternals")["readableStreamToArrayDirect"]>;
declare const $readableStreamDefineLazyIterators: RemoveThis<typeof import("../builtins/ReadableStreamInternals")["readableStreamDefineLazyIterators"]>;

// WritableStreamInternals.ts
declare const $isWritableStream: RemoveThis<typeof import("../builtins/WritableStreamInternals")["isWritableStream"]>;
declare const $isWritableStreamDefaultWriter: RemoveThis<typeof import("../builtins/WritableStreamInternals")["isWritableStreamDefaultWriter"]>;
declare const $acquireWritableStreamDefaultWriter: RemoveThis<typeof import("../builtins/WritableStreamInternals")["acquireWritableStreamDefaultWriter"]>;
declare const $createWritableStream: RemoveThis<typeof import("../builtins/WritableStreamInternals")["createWritableStream"]>;
declare const $createInternalWritableStreamFromUnderlyingSink: RemoveThis<typeof import("../builtins/WritableStreamInternals")["createInternalWritableStreamFromUnderlyingSink"]>;
declare const $initializeWritableStreamSlots: RemoveThis<typeof import("../builtins/WritableStreamInternals")["initializeWritableStreamSlots"]>;
declare const $writableStreamCloseForBindings: RemoveThis<typeof import("../builtins/WritableStreamInternals")["writableStreamCloseForBindings"]>;
declare const $writableStreamAbortForBindings: RemoveThis<typeof import("../builtins/WritableStreamInternals")["writableStreamAbortForBindings"]>;
declare const $isWritableStreamLocked: RemoveThis<typeof import("../builtins/WritableStreamInternals")["isWritableStreamLocked"]>;
declare const $setUpWritableStreamDefaultWriter: RemoveThis<typeof import("../builtins/WritableStreamInternals")["setUpWritableStreamDefaultWriter"]>;
declare const $writableStreamAbort: RemoveThis<typeof import("../builtins/WritableStreamInternals")["writableStreamAbort"]>;
declare const $writableStreamClose: RemoveThis<typeof import("../builtins/WritableStreamInternals")["writableStreamClose"]>;
declare const $writableStreamAddWriteRequest: RemoveThis<typeof import("../builtins/WritableStreamInternals")["writableStreamAddWriteRequest"]>;
declare const $writableStreamCloseQueuedOrInFlight: RemoveThis<typeof import("../builtins/WritableStreamInternals")["writableStreamCloseQueuedOrInFlight"]>;
declare const $writableStreamDealWithRejection: RemoveThis<typeof import("../builtins/WritableStreamInternals")["writableStreamDealWithRejection"]>;
declare const $writableStreamFinishErroring: RemoveThis<typeof import("../builtins/WritableStreamInternals")["writableStreamFinishErroring"]>;
declare const $writableStreamFinishInFlightClose: RemoveThis<typeof import("../builtins/WritableStreamInternals")["writableStreamFinishInFlightClose"]>;
declare const $writableStreamFinishInFlightCloseWithError: RemoveThis<typeof import("../builtins/WritableStreamInternals")["writableStreamFinishInFlightCloseWithError"]>;
declare const $writableStreamFinishInFlightWrite: RemoveThis<typeof import("../builtins/WritableStreamInternals")["writableStreamFinishInFlightWrite"]>;
declare const $writableStreamFinishInFlightWriteWithError: RemoveThis<typeof import("../builtins/WritableStreamInternals")["writableStreamFinishInFlightWriteWithError"]>;
declare const $writableStreamHasOperationMarkedInFlight: RemoveThis<typeof import("../builtins/WritableStreamInternals")["writableStreamHasOperationMarkedInFlight"]>;
declare const $writableStreamMarkCloseRequestInFlight: RemoveThis<typeof import("../builtins/WritableStreamInternals")["writableStreamMarkCloseRequestInFlight"]>;
declare const $writableStreamMarkFirstWriteRequestInFlight: RemoveThis<typeof import("../builtins/WritableStreamInternals")["writableStreamMarkFirstWriteRequestInFlight"]>;
declare const $writableStreamRejectCloseAndClosedPromiseIfNeeded: RemoveThis<typeof import("../builtins/WritableStreamInternals")["writableStreamRejectCloseAndClosedPromiseIfNeeded"]>;
declare const $writableStreamStartErroring: RemoveThis<typeof import("../builtins/WritableStreamInternals")["writableStreamStartErroring"]>;
declare const $writableStreamUpdateBackpressure: RemoveThis<typeof import("../builtins/WritableStreamInternals")["writableStreamUpdateBackpressure"]>;
declare const $writableStreamDefaultWriterAbort: RemoveThis<typeof import("../builtins/WritableStreamInternals")["writableStreamDefaultWriterAbort"]>;
declare const $writableStreamDefaultWriterClose: RemoveThis<typeof import("../builtins/WritableStreamInternals")["writableStreamDefaultWriterClose"]>;
declare const $writableStreamDefaultWriterCloseWithErrorPropagation: RemoveThis<typeof import("../builtins/WritableStreamInternals")["writableStreamDefaultWriterCloseWithErrorPropagation"]>;
declare const $writableStreamDefaultWriterEnsureClosedPromiseRejected: RemoveThis<typeof import("../builtins/WritableStreamInternals")["writableStreamDefaultWriterEnsureClosedPromiseRejected"]>;
declare const $writableStreamDefaultWriterEnsureReadyPromiseRejected: RemoveThis<typeof import("../builtins/WritableStreamInternals")["writableStreamDefaultWriterEnsureReadyPromiseRejected"]>;
declare const $writableStreamDefaultWriterGetDesiredSize: RemoveThis<typeof import("../builtins/WritableStreamInternals")["writableStreamDefaultWriterGetDesiredSize"]>;
declare const $writableStreamDefaultWriterRelease: RemoveThis<typeof import("../builtins/WritableStreamInternals")["writableStreamDefaultWriterRelease"]>;
declare const $writableStreamDefaultWriterWrite: RemoveThis<typeof import("../builtins/WritableStreamInternals")["writableStreamDefaultWriterWrite"]>;
declare const $setUpWritableStreamDefaultController: RemoveThis<typeof import("../builtins/WritableStreamInternals")["setUpWritableStreamDefaultController"]>;
declare const $writableStreamDefaultControllerStart: RemoveThis<typeof import("../builtins/WritableStreamInternals")["writableStreamDefaultControllerStart"]>;
declare const $setUpWritableStreamDefaultControllerFromUnderlyingSink: RemoveThis<typeof import("../builtins/WritableStreamInternals")["setUpWritableStreamDefaultControllerFromUnderlyingSink"]>;
declare const $writableStreamDefaultControllerAdvanceQueueIfNeeded: RemoveThis<typeof import("../builtins/WritableStreamInternals")["writableStreamDefaultControllerAdvanceQueueIfNeeded"]>;
declare const $isCloseSentinel: RemoveThis<typeof import("../builtins/WritableStreamInternals")["isCloseSentinel"]>;
declare const $writableStreamDefaultControllerClearAlgorithms: RemoveThis<typeof import("../builtins/WritableStreamInternals")["writableStreamDefaultControllerClearAlgorithms"]>;
declare const $writableStreamDefaultControllerClose: RemoveThis<typeof import("../builtins/WritableStreamInternals")["writableStreamDefaultControllerClose"]>;
declare const $writableStreamDefaultControllerError: RemoveThis<typeof import("../builtins/WritableStreamInternals")["writableStreamDefaultControllerError"]>;
declare const $writableStreamDefaultControllerErrorIfNeeded: RemoveThis<typeof import("../builtins/WritableStreamInternals")["writableStreamDefaultControllerErrorIfNeeded"]>;
declare const $writableStreamDefaultControllerGetBackpressure: RemoveThis<typeof import("../builtins/WritableStreamInternals")["writableStreamDefaultControllerGetBackpressure"]>;
declare const $writableStreamDefaultControllerGetChunkSize: RemoveThis<typeof import("../builtins/WritableStreamInternals")["writableStreamDefaultControllerGetChunkSize"]>;
declare const $writableStreamDefaultControllerGetDesiredSize: RemoveThis<typeof import("../builtins/WritableStreamInternals")["writableStreamDefaultControllerGetDesiredSize"]>;
declare const $writableStreamDefaultControllerProcessClose: RemoveThis<typeof import("../builtins/WritableStreamInternals")["writableStreamDefaultControllerProcessClose"]>;
declare const $writableStreamDefaultControllerProcessWrite: RemoveThis<typeof import("../builtins/WritableStreamInternals")["writableStreamDefaultControllerProcessWrite"]>;
declare const $writableStreamDefaultControllerWrite: RemoveThis<typeof import("../builtins/WritableStreamInternals")["writableStreamDefaultControllerWrite"]>;

// TransformStreamInternals.ts
declare const $isTransformStream: RemoveThis<typeof import("../builtins/TransformStreamInternals")["isTransformStream"]>;
declare const $isTransformStreamDefaultController: RemoveThis<typeof import("../builtins/TransformStreamInternals")["isTransformStreamDefaultController"]>;
declare const $createTransformStream: RemoveThis<typeof import("../builtins/TransformStreamInternals")["createTransformStream"]>;
declare const $initializeTransformStream: RemoveThis<typeof import("../builtins/TransformStreamInternals")["initializeTransformStream"]>;
declare const $transformStreamError: RemoveThis<typeof import("../builtins/TransformStreamInternals")["transformStreamError"]>;
declare const $transformStreamErrorWritableAndUnblockWrite: RemoveThis<typeof import("../builtins/TransformStreamInternals")["transformStreamErrorWritableAndUnblockWrite"]>;
declare const $transformStreamSetBackpressure: RemoveThis<typeof import("../builtins/TransformStreamInternals")["transformStreamSetBackpressure"]>;
declare const $setUpTransformStreamDefaultController: RemoveThis<typeof import("../builtins/TransformStreamInternals")["setUpTransformStreamDefaultController"]>;
declare const $setUpTransformStreamDefaultControllerFromTransformer: RemoveThis<typeof import("../builtins/TransformStreamInternals")["setUpTransformStreamDefaultControllerFromTransformer"]>;
declare const $transformStreamDefaultControllerClearAlgorithms: RemoveThis<typeof import("../builtins/TransformStreamInternals")["transformStreamDefaultControllerClearAlgorithms"]>;
declare const $transformStreamDefaultControllerEnqueue: RemoveThis<typeof import("../builtins/TransformStreamInternals")["transformStreamDefaultControllerEnqueue"]>;
declare const $transformStreamDefaultControllerError: RemoveThis<typeof import("../builtins/TransformStreamInternals")["transformStreamDefaultControllerError"]>;
declare const $transformStreamDefaultControllerPerformTransform: RemoveThis<typeof import("../builtins/TransformStreamInternals")["transformStreamDefaultControllerPerformTransform"]>;
declare const $transformStreamDefaultControllerTerminate: RemoveThis<typeof import("../builtins/TransformStreamInternals")["transformStreamDefaultControllerTerminate"]>;
declare const $transformStreamDefaultSinkWriteAlgorithm: RemoveThis<typeof import("../builtins/TransformStreamInternals")["transformStreamDefaultSinkWriteAlgorithm"]>;
declare const $transformStreamDefaultSinkAbortAlgorithm: RemoveThis<typeof import("../builtins/TransformStreamInternals")["transformStreamDefaultSinkAbortAlgorithm"]>;
declare const $transformStreamDefaultSinkCloseAlgorithm: RemoveThis<typeof import("../builtins/TransformStreamInternals")["transformStreamDefaultSinkCloseAlgorithm"]>;
declare const $transformStreamDefaultSourcePullAlgorithm: RemoveThis<typeof import("../builtins/TransformStreamInternals")["transformStreamDefaultSourcePullAlgorithm"]>;
