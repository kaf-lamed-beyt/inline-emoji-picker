import Cocoa
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var emojiReplacer: EmojiReplacer!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("✅ App did launch")
        setupMenuBarIcon()
        requestAccessibilityAccess()
        emojiReplacer = EmojiReplacer()
        emojiReplacer?.start()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        emojiReplacer?.stop()
    }
    
    var shouldreplaceEmojis = true
    let toggleItem = NSMenuItem(title: "Disable Emoji Replacer", action: #selector(toggleEmojiReplacement), keyEquivalent: "t")
    
    private func setupMenuBarIcon() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        let menu = NSMenu()
        menu.addItem(toggleItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit Emoji Replacer", action: #selector(quit), keyEquivalent: "q"))
        statusItem.menu = menu

        if let button = statusItem.button {
            button.title = "😎"
        }
    }
    
    @objc private func toggleEmojiReplacement() {
        shouldreplaceEmojis.toggle()
        toggleItem.title = shouldreplaceEmojis ? "Disable Emoji Replacer" : "Enable Emoji Replacer"
        if shouldreplaceEmojis {
            emojiReplacer?.start()
        } else {
            emojiReplacer?.stop()
        }
        
        print("Emoji replacement is now \(shouldreplaceEmojis ? "enabled" : "disabled")")
    }
    
    @objc private func quit() {
        NSApp.terminate(nil)
    }
    
    private func requestAccessibilityAccess() {
        let checkOptPrompt = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as NSString
        let options = [checkOptPrompt: true] as CFDictionary
        AXIsProcessTrustedWithOptions(options)
        
        if AXIsProcessTrusted() {
            print("✅ Accessibility access granted")
        } else {
            print("❌ Accessibility access denied")
        }
    }
}

