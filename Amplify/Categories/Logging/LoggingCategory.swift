//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

/// AWS Amplify writes console logs through Logger. You can use Logger in your apps for the same purpose.
final public class LoggingCategory: Category {
    public let categoryType = CategoryType.logging

    var plugins = [PluginKey: LoggingCategoryPlugin]()

    /// Returns the plugin added to the category, if only one plugin is added. Accessing
    /// this property if no plugins are added, or if more than one plugin is added without a pluginSelectorFactory,
    /// will cause a preconditionFailure.
    var plugin: LoggingCategoryPlugin {
        guard isConfigured else {
            preconditionFailure(
                """
                \(categoryType.displayName) category is not configured. Call Amplify.configure() before using \
                any methods on the category.
                """
            )
        }

        guard !plugins.isEmpty else {
            preconditionFailure("No plugins added to \(categoryType.displayName) category.")
        }

        guard plugins.count == 1 else {
            preconditionFailure(
                """
                More than 1 plugin added to \(categoryType.displayName) category. \
                You must invoke operations on this category by getting the plugin you want, as in:
                #"Amplify.\(categoryType.displayName).getPlugin(for: "ThePluginKey").foo()
                """
            )
        }

        return plugins.first!.value
    }

    var isConfigured = false

    // MARK: - Plugin handling

    /// Adds `plugin` to the list of Plugins that implement functionality for this category. If a plugin has
    /// already added to this category, callers must add a `PluginSelector` before adding a second plugin.
    ///
    /// - Parameter plugin: The Plugin to add
    /// - Throws:
    ///   - PluginError.emptyKey if the plugin's `key` property is empty
    ///   - PluginError.noSelector if the call to `add` would cause there to be more than one plugin added to this
    ///     category.
    public func add(plugin: LoggingCategoryPlugin) throws {
        let key = plugin.key
        guard !key.isEmpty else {
            let pluginDescription = String(describing: plugin)
            let error = PluginError.emptyKey("Plugin \(pluginDescription) has an empty `key`.",
                "Set the `key` property for \(String(describing: plugin))")
            throw error
        }

        plugins[plugin.key] = plugin
    }

    /// Returns the added plugin with the specified `key` property.
    ///
    /// - Parameter key: The PluginKey (String) of the plugin to retrieve
    /// - Returns: The wrapped plugin
    /// - Throws: PluginError.noSuchPlugin if no plugin exists for `key`
    public func getPlugin(for key: PluginKey) throws -> LoggingCategoryPlugin {
        guard let plugin = plugins[key] else {
            let keys = plugins.keys.joined(separator: ", ")
            let error = PluginError.noSuchPlugin("No plugin has been added for '\(key)'.",
                "Either add a plugin for '\(key)', or use one of the known keys: \(keys)")
            throw error
        }
        return plugin
    }

    /// Removes the plugin registered for `key` from the list of Plugins that implement functionality for this category.
    /// If no plugin has been added for `key`, no action is taken, making this method safe to call multiple times.
    ///
    /// - Parameter key: The key used to `add` the plugin
    public func removePlugin(for key: PluginKey) {
        plugins.removeValue(forKey: key)
    }

}
