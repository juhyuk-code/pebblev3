import Foundation
import CoreNFC
import Combine

/// Protocol for NFC scanning operations
protocol NFCServiceProtocol {
    /// Start an NFC scanning session
    func startScanning() async -> NFCScanResult

    /// Whether NFC is available on this device
    var isAvailable: Bool { get }
}

/// CoreNFC-based implementation of NFC scanning
final class NFCService: NSObject, NFCServiceProtocol {

    // MARK: - Properties

    private var session: NFCNDEFReaderSession?
    private var scanContinuation: CheckedContinuation<NFCScanResult, Never>?

    var isAvailable: Bool {
        NFCNDEFReaderSession.readingAvailable
    }

    // MARK: - Public Methods

    func startScanning() async -> NFCScanResult {
        guard isAvailable else {
            return .error(NFCError.notAvailable)
        }

        return await withCheckedContinuation { continuation in
            self.scanContinuation = continuation

            session = NFCNDEFReaderSession(
                delegate: self,
                queue: .main,
                invalidateAfterFirstRead: true
            )
            session?.alertMessage = Constants.nfcScanningMessage
            session?.begin()
        }
    }

    // MARK: - Private Methods

    private func validatePayload(_ payload: String) -> NFCScanResult {
        if PebbleTag.validate(payload: payload) {
            return .valid
        } else {
            return .invalid(reason: "Not an official Pebble tag")
        }
    }

    private func extractTextPayload(from message: NFCNDEFMessage) -> String? {
        for record in message.records {
            if record.typeNameFormat == .nfcWellKnown,
               let type = String(data: record.type, encoding: .utf8),
               type == "T" {
                // Text record format: [language code length][language code][text]
                let payload = record.payload
                guard payload.count > 0 else { continue }

                let languageCodeLength = Int(payload[0] & 0x3F)
                guard payload.count > languageCodeLength + 1 else { continue }

                let textData = payload.dropFirst(languageCodeLength + 1)
                return String(data: Data(textData), encoding: .utf8)
            }
        }
        return nil
    }
}

// MARK: - NFCNDEFReaderSessionDelegate

extension NFCService: NFCNDEFReaderSessionDelegate {

    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        guard let message = messages.first,
              let payload = extractTextPayload(from: message) else {
            let result = NFCScanResult.invalid(reason: "Could not read tag data")
            scanContinuation?.resume(returning: result)
            scanContinuation = nil
            return
        }

        let result = validatePayload(payload)

        if case .valid = result {
            session.alertMessage = "Pebble detected!"
        }

        scanContinuation?.resume(returning: result)
        scanContinuation = nil
    }

    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        let nsError = error as NSError

        let result: NFCScanResult
        if nsError.domain == NFCReaderError.errorDomain {
            switch nsError.code {
            case NFCReaderError.readerSessionInvalidationErrorUserCanceled.rawValue:
                result = .cancelled
            case NFCReaderError.readerSessionInvalidationErrorFirstNDEFTagRead.rawValue:
                // Normal completion after first read - already handled in didDetectNDEFs
                return
            default:
                result = .error(error)
            }
        } else {
            result = .error(error)
        }

        scanContinuation?.resume(returning: result)
        scanContinuation = nil
    }

    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {
        // Session is active and ready to scan
    }
}

// MARK: - Errors

enum NFCError: LocalizedError {
    case notAvailable
    case invalidPayload

    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "NFC is not available on this device"
        case .invalidPayload:
            return "Could not read tag payload"
        }
    }
}
