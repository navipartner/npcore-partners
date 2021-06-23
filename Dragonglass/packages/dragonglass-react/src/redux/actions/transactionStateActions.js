export const DRAGONGLASS_TRANSACTIONSTATE_UPDATE = "DRAGONGLASS_TRANSACTIONSTATE_UPDATE";

export const updateTransactionState = state => {
    return {
        type: DRAGONGLASS_TRANSACTIONSTATE_UPDATE,
        payload: state
    };
};