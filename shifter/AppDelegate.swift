import UIKit
import CoreData
import Compression

// MARK: - Data Compression / Decompression Extension
extension Data {
    func compressed() -> Data? {
        let bufferSize = Constants.bufferSize
        var sourceBuffer = [UInt8](self)
        let destinationBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        defer { destinationBuffer.deallocate() }
        let compressedSize = compression_encode_buffer(destinationBuffer,
                                                       bufferSize,
                                                       &sourceBuffer,
                                                       self.count,
                                                       nil,
                                                       COMPRESSION_ZLIB)
        guard compressedSize != 0 else { return nil }
        return Data(bytes: destinationBuffer, count: compressedSize)
    }
    
    func decompressed(using algorithm: compression_algorithm) -> Data? {
        let bufferSize = Constants.bufferSize
        let destinationBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        defer { destinationBuffer.deallocate() }
        let decompressedSize = self.withUnsafeBytes { (sourceBuffer: UnsafeRawBufferPointer) -> Int in
            guard let baseAddress = sourceBuffer.baseAddress?.assumingMemoryBound(to: UInt8.self) else { return 0 }
            return compression_decode_buffer(destinationBuffer,
                                             bufferSize,
                                             baseAddress,
                                             self.count,
                                             nil,
                                             algorithm)
        }
        guard decompressedSize != 0 else { return nil }
        return Data(bytes: destinationBuffer, count: decompressedSize)
    }
}

// MARK: - AppDelegate
@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    // MARK: - Core Data Stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "UserDataModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load persistent store: \(error)")
            }
        }
        return container
    }()

    // MARK: - Core Data Saving Support
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
