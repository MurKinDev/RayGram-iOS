import Foundation
import UIKit
import CoreText

public struct RayGramFontItem: Codable, Equatable {
    public let postscriptName: String
    public let displayName: String
    public let fileName: String?
    public let isImported: Bool
    
    public init(postscriptName: String, displayName: String, fileName: String? = nil, isImported: Bool = false) {
        self.postscriptName = postscriptName
        self.displayName = displayName
        self.fileName = fileName
        self.isImported = isImported
    }
}

public final class RayGramFontManager {
    public static let shared = RayGramFontManager()
    
    public static let didChangeFontNotification = Notification.Name("RayGramDidChangeFontNotification")
    
    private let defaults = UserDefaults.standard
    private let customFontKey = "RayGram_customFont"
    private let importedFontsKey = "RayGram_importedFonts"
    
    public let presetFonts: [RayGramFontItem] = [
        RayGramFontItem(postscriptName: "", displayName: "По умолчанию (Системный)", isImported: false),
        RayGramFontItem(postscriptName: "AvenirNext-Regular", displayName: "Avenir Next", isImported: false),
        RayGramFontItem(postscriptName: "ArialRoundedMTBold", displayName: "Arial Rounded", isImported: false),
        RayGramFontItem(postscriptName: "Georgia", displayName: "Georgia", isImported: false),
        RayGramFontItem(postscriptName: "ChalkboardSE-Regular", displayName: "Chalkboard SE", isImported: false),
        RayGramFontItem(postscriptName: "TimesNewRomanPSMT", displayName: "Times New Roman", isImported: false),
        RayGramFontItem(postscriptName: "Menlo-Regular", displayName: "Menlo", isImported: false),
        RayGramFontItem(postscriptName: "TrebuchetMS", displayName: "Trebuchet MS", isImported: false),
        RayGramFontItem(postscriptName: "Noteworthy-Light", displayName: "Noteworthy", isImported: false),
        RayGramFontItem(postscriptName: "CourierNewPSMT", displayName: "Courier New", isImported: false),
        RayGramFontItem(postscriptName: "Verdana", displayName: "Verdana", isImported: false),
        RayGramFontItem(postscriptName: "SnellRoundhand", displayName: "Snell Roundhand", isImported: false)
    ]
    
    private var registeredUrls = Set<URL>()
    private let lock = NSLock()
    
    private var fontsDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let dir = paths[0].appendingPathComponent("RayGramFonts", isDirectory: true)
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true, attributes: nil)
        }
        return dir
    }
    
    private var cachedCurrentPostscriptName: String?
    
    private init() {
        let val = self.defaults.string(forKey: self.customFontKey)
        if let val = val, !val.isEmpty, val != "system" {
            self.cachedCurrentPostscriptName = val
        }
        self.registerAllImportedFonts()
    }
    
    public var currentFontPostscriptName: String? {
        get {
            return self.cachedCurrentPostscriptName
        }
        set {
            if let val = newValue, !val.isEmpty, val != "system" {
                self.cachedCurrentPostscriptName = val
                self.defaults.set(val, forKey: self.customFontKey)
                self.defaults.set(val, forKey: "aorusgram_font_choice")
            } else {
                self.cachedCurrentPostscriptName = nil
                self.defaults.removeObject(forKey: self.customFontKey)
                self.defaults.removeObject(forKey: "aorusgram_font_choice")
            }
            Font.clearCache()
            NotificationCenter.default.post(name: RayGramFontManager.didChangeFontNotification, object: nil)
            NotificationCenter.default.post(name: NSNotification.Name("RayGram_settingsChanged"), object: nil)
        }
    }
    
    public var currentFontDisplayName: String {
        guard let current = self.currentFontPostscriptName else {
            return "По умолчанию"
        }
        for font in self.allFonts {
            if font.postscriptName == current {
                return font.displayName
            }
        }
        return current
    }
    
    public var importedFonts: [RayGramFontItem] {
        get {
            guard let data = self.defaults.data(forKey: self.importedFontsKey),
                  let items = try? JSONDecoder().decode([RayGramFontItem].self, from: data) else {
                return []
            }
            return items
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                self.defaults.set(data, forKey: self.importedFontsKey)
            }
        }
    }
    
    public var allFonts: [RayGramFontItem] {
        return self.presetFonts + self.importedFonts
    }
    
    public func registerAllImportedFonts() {
        self.lock.lock()
        defer { self.lock.unlock() }
        
        let dir = self.fontsDirectory
        let items = self.importedFonts
        for item in items {
            guard let fileName = item.fileName else { continue }
            let fileUrl = dir.appendingPathComponent(fileName)
            self.registerFontFile(at: fileUrl)
        }
    }
    
    @discardableResult
    private func registerFontFile(at url: URL) -> Bool {
        guard FileManager.default.fileExists(atPath: url.path) else {
            return false
        }
        if self.registeredUrls.contains(url) {
            return true
        }
        var error: Unmanaged<CFError>?
        let success = CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error)
        if success {
            self.registeredUrls.insert(url)
            return true
        } else {
            if let err = error?.takeRetainedValue() as Error? as NSError?, err.code == 105 {
                self.registeredUrls.insert(url)
                return true
            }
            return false
        }
    }
    
    public func importFont(from sourceUrl: URL) -> RayGramFontItem? {
        self.lock.lock()
        defer { self.lock.unlock() }
        
        let isSecured = sourceUrl.startAccessingSecurityScopedResource()
        defer {
            if isSecured {
                sourceUrl.stopAccessingSecurityScopedResource()
            }
        }
        
        guard let fontData = try? Data(contentsOf: sourceUrl) else {
            return nil
        }
        
        guard let dataProvider = CGDataProvider(data: fontData as CFData),
              let cgFont = CGFont(dataProvider) else {
            return nil
        }
        
        let postscriptName = (cgFont.postScriptName as String?) ?? sourceUrl.deletingPathExtension().lastPathComponent
        let fullName = (cgFont.fullName as String?) ?? postscriptName
        
        let ext = sourceUrl.pathExtension.isEmpty ? "ttf" : sourceUrl.pathExtension
        let safeName = "\(postscriptName.replacingOccurrences(of: " ", with: "_")).\(ext)"
        let targetUrl = self.fontsDirectory.appendingPathComponent(safeName)
        
        do {
            if FileManager.default.fileExists(atPath: targetUrl.path) {
                try FileManager.default.removeItem(at: targetUrl)
            }
            try fontData.write(to: targetUrl, options: .atomic)
        } catch {
            return nil
        }
        
        self.registerFontFile(at: targetUrl)
        
        let newItem = RayGramFontItem(
            postscriptName: postscriptName,
            displayName: fullName,
            fileName: safeName,
            isImported: true
        )
        
        var currentImported = self.importedFonts
        currentImported.removeAll(where: { $0.postscriptName == postscriptName })
        currentImported.append(newItem)
        self.importedFonts = currentImported
        
        return newItem
    }
    
    public func deleteImportedFont(_ item: RayGramFontItem) {
        self.lock.lock()
        defer { self.lock.unlock() }
        
        guard item.isImported, let fileName = item.fileName else { return }
        let targetUrl = self.fontsDirectory.appendingPathComponent(fileName)
        
        var error: Unmanaged<CFError>?
        CTFontManagerUnregisterFontsForURL(targetUrl as CFURL, .process, &error)
        self.registeredUrls.remove(targetUrl)
        
        try? FileManager.default.removeItem(at: targetUrl)
        
        var currentImported = self.importedFonts
        currentImported.removeAll(where: { $0.postscriptName == item.postscriptName })
        self.importedFonts = currentImported
        
        if self.currentFontPostscriptName == item.postscriptName {
            self.currentFontPostscriptName = nil
        }
    }
    
    public func previewFont(for postscriptName: String, size: CGFloat) -> UIFont {
        if postscriptName.isEmpty || postscriptName == "system" {
            return UIFont.systemFont(ofSize: size)
        }
        if let font = UIFont(name: postscriptName, size: size) {
            return font
        }
        return UIFont.systemFont(ofSize: size)
    }
    
    public func resolveFont(size: CGFloat, weight: Font.Weight = .regular, traits: Font.Traits = []) -> UIFont? {
        guard let baseName = self.cachedCurrentPostscriptName, !baseName.isEmpty else {
            return nil
        }
        
        var targetName = baseName
        let isBold = weight.isBold
        let isItalic = traits.contains(.italic)
        
        if baseName.hasPrefix("AvenirNext") {
            if isBold && isItalic { targetName = "AvenirNext-BoldItalic" }
            else if isBold { targetName = "AvenirNext-Bold" }
            else if isItalic { targetName = "AvenirNext-Italic" }
            else if weight == .medium { targetName = "AvenirNext-Medium" }
            else { targetName = "AvenirNext-Regular" }
        } else if baseName.hasPrefix("Georgia") {
            if isBold && isItalic { targetName = "Georgia-BoldItalic" }
            else if isBold { targetName = "Georgia-Bold" }
            else if isItalic { targetName = "Georgia-Italic" }
            else { targetName = "Georgia" }
        } else if baseName.hasPrefix("Menlo") {
            if isBold && isItalic { targetName = "Menlo-BoldItalic" }
            else if isBold { targetName = "Menlo-Bold" }
            else if isItalic { targetName = "Menlo-Italic" }
            else { targetName = "Menlo-Regular" }
        } else if baseName.hasPrefix("TimesNewRoman") {
            if isBold && isItalic { targetName = "TimesNewRomanPS-BoldItalicMT" }
            else if isBold { targetName = "TimesNewRomanPS-BoldMT" }
            else if isItalic { targetName = "TimesNewRomanPS-ItalicMT" }
            else { targetName = "TimesNewRomanPSMT" }
        } else if baseName.hasPrefix("Trebuchet") {
            if isBold && isItalic { targetName = "Trebuchet-BoldItalic" }
            else if isBold { targetName = "TrebuchetMS-Bold" }
            else if isItalic { targetName = "TrebuchetMS-Italic" }
            else { targetName = "TrebuchetMS" }
        } else if baseName.hasPrefix("CourierNew") {
            if isBold && isItalic { targetName = "CourierNewPS-BoldItalicMT" }
            else if isBold { targetName = "CourierNewPS-BoldMT" }
            else if isItalic { targetName = "CourierNewPS-ItalicMT" }
            else { targetName = "CourierNewPSMT" }
        } else if baseName.hasPrefix("Verdana") {
            if isBold && isItalic { targetName = "Verdana-BoldItalic" }
            else if isBold { targetName = "Verdana-Bold" }
            else if isItalic { targetName = "Verdana-Italic" }
            else { targetName = "Verdana" }
        }
        
        if let font = UIFont(name: targetName, size: size) {
            return font
        }
        
        if let baseFont = UIFont(name: baseName, size: size) {
            var symbolicTraits: UIFontDescriptor.SymbolicTraits = []
            if isBold { symbolicTraits.insert(.traitBold) }
            if isItalic { symbolicTraits.insert(.traitItalic) }
            
            if !symbolicTraits.isEmpty, let descriptor = baseFont.fontDescriptor.withSymbolicTraits(symbolicTraits) {
                return UIFont(descriptor: descriptor, size: size)
            }
            return baseFont
        }
        
        return nil
    }
}
