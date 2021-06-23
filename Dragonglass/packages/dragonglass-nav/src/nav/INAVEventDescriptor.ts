export interface INAVEventDescriptor {
    name: string;
    skipIfBusy?: boolean;
    rejectDuplicate?: boolean;
    appendDataStates?: boolean;
    forceAsync?: boolean;
}