// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  /// Search API
  internal static let searchApi = L10n.tr("Localizable", "search_api", fallback: "Search API")
  internal enum Action {
    /// Localizable.strings
    ///   Magneto
    /// 
    ///   Created by Stanislas Chevallier on 22/08/2019.
    ///   Copyright © 2019 Syan. All rights reserved.
    internal static let cancel = L10n.tr("Localizable", "action.cancel", fallback: "Cancel")
    /// Close
    internal static let close = L10n.tr("Localizable", "action.close", fallback: "Close")
    /// Delete
    internal static let delete = L10n.tr("Localizable", "action.delete", fallback: "Delete")
    /// Edit
    internal static let edit = L10n.tr("Localizable", "action.edit", fallback: "Edit")
    /// Login
    internal static let login = L10n.tr("Localizable", "action.login", fallback: "Login")
    /// Open
    internal static let `open` = L10n.tr("Localizable", "action.open", fallback: "Open")
    /// Remove finished
    internal static let removefinished = L10n.tr("Localizable", "action.removefinished", fallback: "Remove finished")
    /// Save
    internal static let save = L10n.tr("Localizable", "action.save", fallback: "Save")
    /// Share page link
    internal static let sharelink = L10n.tr("Localizable", "action.sharelink", fallback: "Share page link")
    /// Update
    internal static let update = L10n.tr("Localizable", "action.update", fallback: "Update")
  }
  internal enum Alert {
    internal enum Auth {
      /// %@ requires a user and a password
      internal static func message(_ p1: Any) -> String {
        return L10n.tr("Localizable", "alert.auth.message %@", String(describing: p1), fallback: "%@ requires a user and a password")
      }
      /// Authentication needed
      internal static let title = L10n.tr("Localizable", "alert.auth.title", fallback: "Authentication needed")
    }
    internal enum Client {
      internal enum Delete {
        /// Are you sure you want to delete %@?
        internal static func message(_ p1: Any) -> String {
          return L10n.tr("Localizable", "alert.client.delete.message %@", String(describing: p1), fallback: "Are you sure you want to delete %@?")
        }
        /// Confirmation required
        internal static let title = L10n.tr("Localizable", "alert.client.delete.title", fallback: "Confirmation required")
      }
    }
    internal enum Help {
      /// To add a torrent you need to open this app with a magnet. Go to Safari, open a page with a magnet link in it, click the magnet to open this app, and then select a client to start downloading the torrent.
      internal static let message = L10n.tr("Localizable", "alert.help.message", fallback: "To add a torrent you need to open this app with a magnet. Go to Safari, open a page with a magnet link in it, click the magnet to open this app, and then select a client to start downloading the torrent.")
      /// Help
      internal static let title = L10n.tr("Localizable", "alert.help.title", fallback: "Help")
    }
    internal enum Update {
      /// A new version of Magneto is available, you definitely should install it ;)
      internal static let message = L10n.tr("Localizable", "alert.update.message", fallback: "A new version of Magneto is available, you definitely should install it ;)")
      /// Update available
      internal static let title = L10n.tr("Localizable", "alert.update.title", fallback: "Update available")
    }
  }
  internal enum Client {
    /// Host
    internal static let host = L10n.tr("Localizable", "client.host", fallback: "Host")
    /// Torrent label
    internal static let label = L10n.tr("Localizable", "client.label", fallback: "Torrent label")
    /// Name
    internal static let name = L10n.tr("Localizable", "client.name", fallback: "Name")
    /// Password
    internal static let password = L10n.tr("Localizable", "client.password", fallback: "Password")
    /// Port
    internal static let port = L10n.tr("Localizable", "client.port", fallback: "Port")
    /// Username
    internal static let username = L10n.tr("Localizable", "client.username", fallback: "Username")
    internal enum Host {
      /// 192.168.13.12
      internal static let placeholder = L10n.tr("Localizable", "client.host.placeholder", fallback: "192.168.13.12")
    }
    internal enum Label {
      /// magneto
      internal static let placeholder = L10n.tr("Localizable", "client.label.placeholder", fallback: "magneto")
    }
    internal enum Name {
      /// My server
      internal static let placeholder = L10n.tr("Localizable", "client.name.placeholder", fallback: "My server")
    }
    internal enum Password {
      /// password
      internal static let placeholder = L10n.tr("Localizable", "client.password.placeholder", fallback: "password")
    }
    internal enum Port {
      /// 9091
      internal static let placeholder = L10n.tr("Localizable", "client.port.placeholder", fallback: "9091")
    }
    internal enum Title {
      /// Edit client
      internal static let edit = L10n.tr("Localizable", "client.title.edit", fallback: "Edit client")
      /// New client
      internal static let new = L10n.tr("Localizable", "client.title.new", fallback: "New client")
    }
    internal enum Username {
      /// user
      internal static let placeholder = L10n.tr("Localizable", "client.username.placeholder", fallback: "user")
    }
  }
  internal enum Clients {
    internal enum Addcustom {
      /// Add a custom client
      internal static let line1 = L10n.tr("Localizable", "clients.addcustom.line1", fallback: "Add a custom client")
      /// in case yours wasn't detected
      internal static let line2 = L10n.tr("Localizable", "clients.addcustom.line2", fallback: "in case yours wasn't detected")
    }
    internal enum Count {
      /// Add a client
      internal static let add = L10n.tr("Localizable", "clients.count.add", fallback: "Add a client")
    }
    internal enum Openurl {
      /// Open magnet
      internal static let line1 = L10n.tr("Localizable", "clients.openurl.line1", fallback: "Open magnet")
      /// Will launch your default torrent app
      internal static let line2 = L10n.tr("Localizable", "clients.openurl.line2", fallback: "Will launch your default torrent app")
    }
    internal enum Section {
      /// Clients
      internal static let clients = L10n.tr("Localizable", "clients.section.clients", fallback: "Clients")
      /// No results
      internal static let noresults = L10n.tr("Localizable", "clients.section.noresults", fallback: "No results")
      /// Results
      internal static let results = L10n.tr("Localizable", "clients.section.results", fallback: "Results")
    }
  }
  internal enum Discovery {
    /// Add a client
    internal static let title = L10n.tr("Localizable", "discovery.title", fallback: "Add a client")
    internal enum Section {
      /// Available clients
      internal static let found = L10n.tr("Localizable", "discovery.section.found", fallback: "Available clients")
    }
  }
  internal enum Error {
    /// Operation cancelled
    internal static let cancelled = L10n.tr("Localizable", "error.cancelled", fallback: "Operation cancelled")
    /// Client unavailable
    internal static let clientOffline = L10n.tr("Localizable", "error.clientOffline", fallback: "Client unavailable")
    /// Couldn't decode content of type %@: %@
    internal static func decoding(_ p1: Any, _ p2: Any) -> String {
      return L10n.tr("Localizable", "error.decoding", String(describing: p1), String(describing: p2), fallback: "Couldn't decode content of type %@: %@")
    }
    /// Please check your informations
    internal static let form = L10n.tr("Localizable", "error.form", fallback: "Please check your informations")
    /// No available API could respond to the request
    internal static let noAvailableAPI = L10n.tr("Localizable", "error.noAvailableAPI", fallback: "No available API could respond to the request")
    /// No client saved in your settings, please add one before trying to download this item
    internal static let noClientsSaved = L10n.tr("Localizable", "error.noClientsSaved", fallback: "No client saved in your settings, please add one before trying to download this item")
    /// You seem to be offline, retry when you have access to the internet
    internal static let offline = L10n.tr("Localizable", "error.offline", fallback: "You seem to be offline, retry when you have access to the internet")
    /// The request couldn't finish
    internal static let request = L10n.tr("Localizable", "error.request", fallback: "The request couldn't finish")
    /// Unknown error
    internal static let unknown = L10n.tr("Localizable", "error.unknown", fallback: "Unknown error")
    internal enum Form {
      /// %@ is not valid
      internal static func invalid(_ p1: Any) -> String {
        return L10n.tr("Localizable", "error.form.invalid %@", String(describing: p1), fallback: "%@ is not valid")
      }
      /// %@ should be filled
      internal static func missing(_ p1: Any) -> String {
        return L10n.tr("Localizable", "error.form.missing %@", String(describing: p1), fallback: "%@ should be filled")
      }
      /// %@ should be filled when using a %@
      internal static func missingIfHas(_ p1: Any, _ p2: Any) -> String {
        return L10n.tr("Localizable", "error.form.missingIfHas %@ %@", String(describing: p1), String(describing: p2), fallback: "%@ should be filled when using a %@")
      }
    }
    internal enum Title {
      /// Cannot add torrent
      internal static let cannotAddTorrent = L10n.tr("Localizable", "error.title.cannotAddTorrent", fallback: "Cannot add torrent")
      /// Cannot load results
      internal static let cannotLoadResults = L10n.tr("Localizable", "error.title.cannotLoadResults", fallback: "Cannot load results")
    }
  }
  internal enum Placeholder {
    /// Search
    internal static let search = L10n.tr("Localizable", "placeholder.search", fallback: "Search")
  }
  internal enum Torrent {
    /// Loading…
    internal static let loading = L10n.tr("Localizable", "torrent.loading", fallback: "Loading…")
    /// Success!
    internal static let success = L10n.tr("Localizable", "torrent.success", fallback: "Success!")
    internal enum Removed {
      /// Removed one finished item
      internal static let one = L10n.tr("Localizable", "torrent.removed.one", fallback: "Removed one finished item")
      /// Removed %d finished item(s)
      internal static func other(_ p1: Int) -> String {
        return L10n.tr("Localizable", "torrent.removed.other", p1, fallback: "Removed %d finished item(s)")
      }
      /// No finished item to remove
      internal static let zero = L10n.tr("Localizable", "torrent.removed.zero", fallback: "No finished item to remove")
    }
    internal enum Success {
      /// Message from %@: 
      internal static func messagefrom(_ p1: Any) -> String {
        return L10n.tr("Localizable", "torrent.success.messagefrom %@", String(describing: p1), fallback: "Message from %@: ")
      }
    }
  }
  internal enum Webkit {
    /// Cancel
    internal static let cancel = L10n.tr("Localizable", "webkit.cancel", fallback: "Cancel")
    /// Complete
    internal static let finish = L10n.tr("Localizable", "webkit.finish", fallback: "Complete")
    /// Authentication required
    internal static let title = L10n.tr("Localizable", "webkit.title", fallback: "Authentication required")
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
