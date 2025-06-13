# Telegram Bot Swift Template 🤖

[![Build Status](https://img.shields.io/badge/Build-Passing-brightgreen)](https://github.com/Maxim-Lanskoy/GPTGram/actions) 
[![Swift](https://img.shields.io/badge/Swift-6.1-orange)](https://github.com/swiftlang/swift/releases/tag/swift-6.1-RELEASE) 
[![Vapor](https://img.shields.io/badge/Vapor-4.115.0-mediumslateblue)](https://github.com/vapor/vapor/releases/tag/4.115.0) 

A Telegram Bot template built with Swift, using a router-controller architecture, multiple languages, and database persistence.

<p align="center">[ <a href="https://docs.vapor.codes">Vapor Documentation</a> ]  
  [ <a href="https://docs.vapor.codes/fluent/overview/#fluent">Fluent ORM / SQLite</a> ]  
  [ <a href="https://core.telegram.org/bots/api">Telegram Bot API</a> ]  
  [ <a href="https://github.com/nerzh/swift-telegram-sdk">Swift Telegram SDK</a> ]  
  [ <a href="https://openai.com/index/gpt-4-1/">OpenAI GPT-4.1</a> ]
</p>

## 🎯 Purpose

This template provides a robust foundation for building Telegram bots in Swift with:
- **State-based navigation** using a router-controller pattern
- **Multi-language support** with dynamic locale switching
- **User session management** with SQLite database persistence
- **Modern Swift concurrency** with actors and async/await

Perfect for creating bots that need to manage complex user interactions, multiple conversation states, and persistent data.

## 🏗️ Architecture

### Core Components

```
┌─────────────────────────────────────────────────────────────┐
│                        TGBotActor                           │
│  (Manages bot instance and ensures thread-safe operations)  │
└─────────────────────────────────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                      Router System                          │
│  (Maps updates to appropriate controllers based on state)   │
└─────────────────────────────────────────────────────────────┘
                               │
                    ┌──────────┴──────────┐
                    ▼                     ▼
        ┌─────────────────────┐   ┌───────────────────┐
        │    Controllers      │   │   User Sessions   │
        │ (Handle "UI" logic) │   │ (Persistent state)│
        └─────────────────────┘   └───────────────────┘
```

### Router-Controller Pattern

The template implements a sophisticated state machine where each controller represents a different "screen" or interaction mode:

1. **Router**: Processes incoming Telegram updates and routes them to the appropriate controller based on:
   - User's current state (stored in database)
   - Command matching
   - Content type (text, callback query, etc.)

2. **Controllers**: Each controller encapsulates logic for a specific interaction flow:
   - `RegistrationController`: Handles first-time user setup and language selection
   - `MainController`: The main menu and home screen
   - `SettingsController`: User preferences and configuration
   - Custom controllers can be easily added for new features

3. **Context**: Provides controllers with everything needed to handle requests:
   - Bot instance for sending messages
   - Database connection
   - Localization (Lingo)
   - User session data
   - Parsed arguments from commands

## 📁 Project Structure

```
TGBotSwiftTemplate/
├── Swift/
│   ├── Controllers/              # Bot controllers (screens/states)
│   │   ├── AllControllers.swift  # Controller registry
│   │   ├── MainController.swift  # Main menu controller
│   │   ├── RegistrationController.swift
│   │   ├── SettingsController.swift
│   │   └── XEverywhereController.swift  # Global command handlers
│   │
│   ├── Models/                   # Database models (Fluent ORM)
│   │   ├── User.swift           # User session and preferences
│   │   └── DataEntry.swift      # Example data model
│   │
│   ├── Migrations/              # Database schema migrations
│   │   ├── CreateUser.swift
│   │   └── CreateDataEntry.swift
│   │
│   ├── Telegram/
│   │   ├── Router/              # Routing system
│   │   │   ├── Router.swift     # Main router logic
│   │   │   ├── Context.swift    # Request context
│   │   │   ├── Commands.swift   # Command definitions
│   │   │   ├── ContentType.swift # Message content types
│   │   │   ├── Arguments.swift  # Command argument parsing
│   │   │   └── Router+Helpers.swift
│   │   │
│   │   └── TGBot/               # Bot infrastructure
│   │       ├── TGBotActor.swift # Thread-safe bot wrapper
│   │       ├── TGDispatcher.swift
│   │       └── VaporTGClient.swift # Vapor HTTP client adapter
│   │
│   ├── Helpers/
│   │   ├── TGBot+Extensions.swift # Convenience extensions
│   │   └── DotEnv+Env.swift      # Environment helpers
│   │
│   ├── entrypoint.swift         # Application entry point
│   ├── configure.swift          # Vapor configuration
│   └── routes.swift             # HTTP routes (if needed)
│
├── Localizations/               # Multi-language support
│   ├── en.json                 # English translations
│   └── ru-UA.json              # Ukrainian translations
│
├── SQLite/                      # Database files (gitignored)
│   └── .gitkeep
│
├── Public/                      # Static files for web routes
│   └── favicon.ico
│
├── Package.swift                # Swift Package Manager manifest
├── Package.resolved             # Dependency lock file
├── .env.example                 # Environment template
└── .gitignore
```

## 🚀 Getting Started

### Prerequisites

- **Swift 6.1+** toolchain
- **Xcode 15+** (optional, for IDE support)
- **Telegram Bot Token** from [@BotFather](https://t.me/botfather)

### Installation

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd TGBotSwiftTemplate
   ```

2. **Configure environment**:
   ```bash
   cp .env.example .env
   ```
   Edit `.env` and add your bot token:
   ```
   TELEGRAM_BOT_TOKEN=YOUR_BOT_TOKEN_HERE
   ```

3. **Update configuration**:
   
   Edit `Swift/configure.swift` and replace the following:
   - `projectPath`: Update to your actual project path
   - `owner` and `helper`: Replace with your Telegram user IDs
   - `@TGUserName`: Replace with your Telegram username in localizations

4. **Build and run**:
   ```bash
   swift build
   swift run
   ```

   Or using Vapor CLI:
   ```bash
   vapor build
   vapor run
   ```

### Finding Your Telegram User ID

To get your Telegram user ID:
1. Start a chat with [@ForwardInfoBot](https://t.me/ForwardInfoBot)
2. The bot will reply with your user ID
3. Add this ID to the `allowedUsers` array in `configure.swift`

## 💡 How It Works

### User Flow

1. **First Contact**: When a user messages the bot for the first time:
   - `User.session()` creates a new user record
   - User is routed to `RegistrationController`
   - Language selection is presented

2. **State Management**: Each user has a `routerName` field that tracks their current controller:
   - `"registration"` → Registration flow
   - `"main"` → Main menu
   - `"settings"` → Settings menu
   - Custom states for your features

3. **Message Processing**:
   ```swift
   Update arrives → RouterStore finds current controller → 
   Controller processes → Updates user state → Sends response
   ```

### Adding a New Feature

1. **Create a new controller**:
   ```swift
   final class MyFeatureController: TGControllerBase {
       override func attachHandlers(to bot: TGBot, lingo: Lingo) async {
           let router = Router(bot: bot) { router in
               router["/mycommand"] = onMyCommand
               router.unmatched = unmatched
           }
           await processRouterForEachName(router)
       }
       
       func onMyCommand(context: Context) async throws -> Bool {
           try await context.respond("Hello from my feature!")
           return true
       }
   }
   ```

2. **Register the controller** in `AllControllers.swift`:
   ```swift
   static let myFeature = MyFeatureController(routerName: "myfeature")
   static let all: [TGControllerBase] = [
       registration, mainController, settingsController, myFeature
   ]
   ```

3. **Add navigation** from another controller:
   ```swift
   context.session.routerName = "myfeature"
   try await context.session.save(on: context.db)
   ```

### Working with Keyboards

The template provides sophisticated keyboard management:

```swift
// Reply keyboard (persistent buttons)
let markup = TGReplyKeyboardMarkup(keyboard: [
    [TGKeyboardButton(text: "Button 1"), TGKeyboardButton(text: "Button 2")]
], resizeKeyboard: true)

// Inline keyboard (buttons under messages)
let inline = TGInlineKeyboardMarkup(inlineKeyboard: [
    [TGInlineKeyboardButton(text: "Click me", callbackData: "action:123")]
])
```

### Database Operations

Using Fluent ORM for database operations:

```swift
// Create
let entry = DataEntry(userId: user.id!, department: "Sales")
try await entry.save(on: db)

// Read
let entries = try await DataEntry.query(on: db)
    .filter(\.$userId == user.id!)
    .all()

// Update
entry.quantity = "100"
try await entry.save(on: db)

// Delete
try await entry.delete(on: db)
```

## 🌐 Localization

The template includes built-in multi-language support:

1. **Add translations** to `Localizations/*.json`
2. **Use in code**:
   ```swift
   let welcomeText = lingo.localize("welcome", locale: user.locale)
   let greeting = lingo.localize("greeting.message", locale: user.locale, 
                                  interpolations: ["full-name": user.name])
   ```

3. **Add new language**:
   - Create new JSON file in `Localizations/`
   - Add locale code to `allSupportedLocales` in `configure.swift`
   - Update language selection UI in registration/settings

## 🔧 Configuration Options

### Environment Variables

- `TELEGRAM_BOT_TOKEN` - Your bot token from BotFather (required)
- `DATABASE_URL` - Custom database URL (optional, defaults to SQLite)

### Bot Settings

In `configure.swift`:
- `owner`, `helper` - Admin user IDs
- `allowedUsers` - Array of authorized user IDs (remove for public access)
- `allSupportedLocales` - Available languages

### Database Options

```swift
// SQLite file (default)
app.databases.use(.sqlite(.file("path/to/db.sqlite")), as: .sqlite)

// In-memory (for testing)
app.databases.use(.sqlite(.memory), as: .sqlite)

// PostgreSQL (change driver dependency)
app.databases.use(.postgres(configuration: ...), as: .psql)
```

## 📚 Dependencies

- **[Vapor](https://vapor.codes)** - Web framework and server
- **[Fluent](https://docs.vapor.codes/fluent/overview/)** - ORM for database operations
- **[SwiftTelegramSdk](https://github.com/nerzh/swift-telegram-sdk)** - Telegram Bot API client
- **[swift-dotenv](https://github.com/thebarndog/swift-dotenv)** - Environment file support
- **[Lingo-Vapor](https://github.com/vapor-community/Lingo-Vapor)** - Localization support

## 🛠️ Advanced Features

### Custom Routers

Create specialized routers for complex command handling:

```swift
router.add(.photo) { context in
    // Handle photo messages
}

router.add(.callback_query(data: "specific_action")) { context in
    // Handle specific callback
}
```

### Middleware-like Processing

Use `XEverywhereController` for global command handling that works across all states:
- `/help` - Always available
- `/settings` - Accessible from anywhere
- `/buttons` - Restore keyboard from any state

### Actor-based Concurrency

The bot uses Swift actors for thread-safe operations:
```swift
actor TGBotActor {
    private var _bot: TGBot!
    
    var bot: TGBot { self._bot }
    
    func setBot(_ bot: TGBot) {
        self._bot = bot
    }
}
```

## 🙏 Acknowledgments

- [Vapor](https://vapor.codes) team for the excellent web framework
- [swift-telegram-sdk](https://github.com/nerzh/swift-telegram-sdk) for Telegram integration
- Swift community for the amazing language and tooling
