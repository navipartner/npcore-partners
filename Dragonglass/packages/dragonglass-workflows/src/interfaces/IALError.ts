export interface IALError {
    handled: boolean;
    originalMessage: string | null;
    popupShown: boolean;
    silent: boolean;
}