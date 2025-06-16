import Cocoa

class EmojiPopoverViewController: NSViewController {
    private let emojiLabel = NSTextField(labelWithString: "")
    
    var emoji: String = "" {
        didSet {
            emojiLabel.stringValue = emoji
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    override func loadView() {
        let view = NSView(frame: .zero)
        view.setFrameSize(NSSize(width: 100, height: 100))
        self.view = view
        
        emojiLabel.font = NSFont.systemFont(ofSize: 48)
        emojiLabel.alignment = .center
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        emojiLabel.textColor = .labelColor
        
        view.addSubview(emojiLabel)
        
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

class EmojiPopover {
    private let popover = NSPopover()
    private let viewController = EmojiPopoverViewController()
    
    init() {
        popover.behavior = .transient
        popover.contentViewController = viewController
    }
    
    func show(emoji: String, relativeTo view: NSView) {
        viewController.emoji = emoji
        popover.show(relativeTo: view.bounds, of: view, preferredEdge: .maxY)
    }
    
    func close() {
        popover.close()
    }
}
