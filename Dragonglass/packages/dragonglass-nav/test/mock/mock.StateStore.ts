import { StateStore } from "dragonglass-redux";

export const mockStateStore = (descriptor: any = {}) => ({
    getState: jest.fn(),
    dispatch: jest.fn(),
    subscribe: jest.fn(),
    replaceReducer: jest.fn(),
    injectReducer: jest.fn(),
    subscribeSelector: jest.fn(),
    getDataStates: jest.fn(),
    appendDataStatesToTarget: jest.fn(),

    ...descriptor
}) as StateStore;
