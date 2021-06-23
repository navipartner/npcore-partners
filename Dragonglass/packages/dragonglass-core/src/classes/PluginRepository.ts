import { PropertyBag } from "../interfaces/PropertyBag";

export class PluginRepository<T> {
    private moniker: string;
    private repository: PropertyBag<T> = {};

    constructor(moniker: string) {
        this.moniker = moniker;
    }

    /**
     * Registers a plugin in the repository.
     * @param name Name of the plugin to register
     * @param plugin Plugin to register
     */
    registerPlugin(name: string, plugin: T): void {
        if (this.repository[name] && this.repository[name] !== plugin) {
            console.warn(`Attempting to register a ${this.moniker} with a name that has already been registered: [${name}]`);
            return;
        }

        this.repository[name] = plugin;
    }

    /**
     * Retrieves a registered workflow plugin.
     * @param name Name of the registered plugin to retrieve.
     * @returns Retrieved plugin or null if none
     */
    get(name: string): T | null {
        return this.repository[name] || null;
    }
}
