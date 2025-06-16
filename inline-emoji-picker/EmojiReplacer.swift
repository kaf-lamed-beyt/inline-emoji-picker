import Foundation
import AppKit

class EmojiReplacer {
    private var timer: Timer?
    private var eventTap: CFMachPort?
    
    func start() {
        let eventMask = (1 << CGEventType.keyDown.rawValue)
        eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: {
                proxy, type, event, refcon in
                guard let key = event.typedCharacter,
                      key.count == 1 else { return Unmanaged.passUnretained(event)}
                
                EmojiReplacer.shared.appendToBufferAndReplace(key)
                return Unmanaged.passUnretained(event)
            },
            userInfo: nil
        )
        
        if let eventTap = eventTap {
            let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
            CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
            CGEvent.tapEnable(tap: eventTap, enable: true)
            print("Event tap started")
        } else {
            print("Failed to create event tap. Do you have accessiblity permissions enabled?")
        }
    }
    
    func stop() {
        if let eventTap = eventTap {
            CGEvent.tapEnable(tap: eventTap, enable: false)
            print("Event tap stopped")
        }
    }
    
    private var typedBuffer = ""
    
    private func appendToBufferAndReplace(_ character: String) {
        typedBuffer.append(character)
        
        for (key, emoji) in emojiMap {
            if typedBuffer.hasSuffix(key) {
                replaceLastTyped(key, with: emoji)
                typedBuffer = ""
                break
            }
        }
        
        if typedBuffer.count > 15 {
            typedBuffer.removeFirst()
        }
    }
    
    var emojiPopover: EmojiPopover?
    
    private func replaceLastTyped(_ text: String, with emoji: String) {
        for _ in 0..<text.count {
            sendKeyPress(keyCode: 51) // this is so we remove the trailing space
        }
        for char in emoji {
            sendText(String(char))
        }
        
        // this would only work, supposedly in a macOS input field. maybe i should just remove it
        DispatchQueue.main.async {
            if let mainWindow = NSApplication.shared.mainWindow,
               let contentView = mainWindow.contentView {
                if self.emojiPopover == nil {
                    self.emojiPopover = EmojiPopover()
                }
                self.emojiPopover?.show(emoji: emoji, relativeTo: contentView)
            }
        }
    }
    
    private func sendText(_ string: String) {
        let source = CGEventSource(stateID: .combinedSessionState)
        // when i first tried scalar.value. the first emoji replacement worked. on the second attempt
        // it crashed because scalar.value is too big to fit into UInt16 which UniChar uses 😅
        // i learned that most emojis, especially the newer ones have code points beyond 0xFFFF
        // best thing is to convert it to utf-16
        var utf16Chars = Array(string.utf16)

        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: true)
        keyDown?.keyboardSetUnicodeString(stringLength: utf16Chars.count, unicodeString: &utf16Chars)
        keyDown?.post(tap: .cghidEventTap)

        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: false)
        keyUp?.keyboardSetUnicodeString(stringLength: utf16Chars.count, unicodeString: &utf16Chars)
        keyUp?.post(tap: .cghidEventTap)

        print("Typed emoji: \(string) | utf16: \(utf16Chars)")
    }

    
    private func sendKeyPress(keyCode: CGKeyCode) {
            let source = CGEventSource(stateID: .hidSystemState)
            let keyDown = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: true)
            let keyUp = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: false)
            keyDown?.post(tap: .cghidEventTap)
            keyUp?.post(tap: .cghidEventTap)
        }
    
    static let shared = EmojiReplacer()
    
    private func checkClipboard() {
        let pasteboard = NSPasteboard.general
        guard let contents = pasteboard.string(forType: .string) else { return }
        
        for (key, emoji) in emojiMap {
            if contents.contains(key) {
                let replaced = contents.replacingOccurrences(of: key, with: emoji)
                if replaced != contents {
                    pasteboard.clearContents()
                    pasteboard.setString(replaced, forType: .string)
                    print("Replaced text with emoji: \(replaced)")
                }
            }
        }
    }
    
    func replaceEmojis(in text: String) -> String {
        var result = text
        for (code, emoji) in emojiMap {
            result = result.replacingOccurrences(of: code, with: emoji)
        }
        return result
    }
}

extension CGEvent {
    var typedCharacter: String? {
        var length: Int = 0
        var buffer = [UniChar](repeating: 0, count: 10)

        self.keyboardGetUnicodeString(maxStringLength: buffer.count, actualStringLength: &length, unicodeString: &buffer)
        return String(utf16CodeUnits: buffer, count: length)
    }
}

