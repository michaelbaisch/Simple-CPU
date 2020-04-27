
import Foundation

public class Regex {
    let internalExpression: NSRegularExpression
    let pattern: String
    
    public init(_ pattern: String) {
        self.pattern = pattern
        
        do {
            try self.internalExpression = NSRegularExpression(pattern: pattern, options: [.caseInsensitive, .anchorsMatchLines])
        } catch {
            self.internalExpression = NSRegularExpression()
        }
    }
    
    public func test(input: String) -> Bool {
        let matches = self.internalExpression.matches(in: input, options: NSRegularExpression.MatchingOptions(), range:NSMakeRange(0, input.utf16.count))
        return matches.count > 0
    }
    
    public func firstMatch(input: String) -> NSTextCheckingResult? {
        if let matches =  self.internalExpression.firstMatch(in: input, options: NSRegularExpression.MatchingOptions(), range: NSMakeRange(0, input.utf16.count)) {
            if (matches.range.location != NSNotFound) {
                return matches
            }
        }
        
        return nil
    }
    
}
