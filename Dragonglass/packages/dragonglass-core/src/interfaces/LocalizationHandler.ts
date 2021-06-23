export interface LocalizationHandler {
    localize(caption: string): string;
    localizeAction(action: string): {};
}
