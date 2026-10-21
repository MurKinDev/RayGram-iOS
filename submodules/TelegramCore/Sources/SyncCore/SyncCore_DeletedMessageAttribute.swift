import Foundation
import Postbox

public class DeletedMessageAttribute: MessageAttribute {
    public let timestamp: Int32
    
    public init(timestamp: Int32 = Int32(Date().timeIntervalSince1970)) {
        self.timestamp = timestamp
    }
    
    required public init(decoder: PostboxDecoder) {
        self.timestamp = decoder.decodeInt32ForKey("t", orElse: 0)
    }
    
    public func encode(_ encoder: PostboxEncoder) {
        encoder.encodeInt32(self.timestamp, forKey: "t")
    }
}

public extension Message {
    var isDeleted: Bool {
        for attribute in self.attributes {
            if attribute is DeletedMessageAttribute {
                return true
            }
        }
        return false
    }
}
