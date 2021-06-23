export interface NAVEventsState {
    queue: any[];
    active: { [key: number]: any };
    errors: { [key: number]: any };
};
