## Inline Emoji Picker

Spawn emojis from your keyboard with markdown syntax without losing flow as you type.

## Why?

Whenever I chat with my friend on iMessage &mdash; "Messages" for me, since I do not use an iPhone.

When it's time to pick an emoji, I have to stop typing into the input field, move my hand (in agony) over to the trackpad, click on the emoji icon and start looking for what I want &mdash; it is irritating, slow and I, most of time, lose or forget what I want to type next after searching for those;

GitHub, Discord, Slack, even WhatsApp allows me the affordances of spawning emojis just by typing. Say, I want to use this emoji (👈🏽), all I need to do is type this `:point_left:`. I don't even need to type it out completely, and I'll get emojis close to my input.

Why isn't it possible here?

When I got tired of complaining, pretty sure my friend, too, was tired of my complaints. I asked ChatGPT (**Yesterday, Sun, Jun 16, 2025**) why this isn't possible. One reason it provided was around them not wanting to build a markdown rendering engine.

Okay, fair. But that one no concern me. I need my emoji superpower, you can't just strip me of that.

And reverse-engineering the app was a no-go area for me, _where I wan even start from?_ I've not written a computer program in Swift before.

To do this, I took inspiration from how the Grammarly app works &mdash; **Accessibility**

Since Grammarly somehow (I'm not exactly 100% sure) uses Keyboard events (`keyUp` | `keyDown`) to provide corrections when we type words on our devices, I and ChatGPT had to work with this same info, by using the low-level hardware event [`CGEvent`](https://developer.apple.com/documentation/coregraphics/cgevent) in Swift to listen for tap/keyboard events.

18hrs+ later, and here we are. I even discovered it works across the entire computer, since we're listening to hardware event now.

What initially started as an "emoji picker" patch for Messages, lol.

One thing that was quite insufferable to get working in this process was getting the disk-image you can install on your machine to work correctly.

## Usage

To use this, download the installer [here](https://meje.dev/inline-emoji-picker-for-macos) or clone this repo to build a version you'd like for yourself or just download the dmg file at the root of the repo here.

Once you've done that, open it and drag it into **"Applications"** and try to launch it. You'd be prompted to grant accessibility permissions to the app.

You can do this by opening Settings, head to **Privacy & Security**, scroll down, you'll find **Accessibility**, click on it and add "Inline Emoji Picker" from Applications by clickin on the small plus (+) button below.

If it doesn't work for the first time, you may need to enable it. Look at your menu bar, top-right of your screen, you should see this emoji (😎), toggle it to either enable or disable inline emoji selection/completion.

If you run into the error below and you'd still love to use this tool

> Apple could not verify “inline-emoji-picker” is free of malware that may harm your Mac or compromise your privacy.

Open Settings, click **"Privacy & Security"**, scroll to the bottom. Beside **"inline-emoji-picker" was blocked to protect your Mac." you'll see "Open Anyway", click it.

This happened because, I did not pay the $99/yr fee Apple requests for their Developer Program.

## To Do

- [ ] ensure the app icon actually shows. for now, it doesn't, and I've tried all i could to get that working. I'll keep digging though.
- [ ] show a popover with matching emoji key/pairs as you type

## Contributing

Found a bug? Got an improvement? PRs and issues welcome.

**PS: All emojis were obtained from [gemoji](https://github.com/github/gemoji)**, so if you find any emoji that is not included here, feel free to open a PR.

## License

[MIT](LICENSE)
