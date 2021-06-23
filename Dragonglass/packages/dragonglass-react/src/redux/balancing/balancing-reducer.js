import { createReducer } from "dragonglass-redux";
import {
  DRAGONGLASS_BALANCING_CONFIRM_PAYMENT_TYPE,
  DRAGONGLASS_BALANCING_UPDATE_COIN_TYPES,
  DRAGONGLASS_BALANCING_UPDATE_STATE,
  DRAGONGLASS_BALANCING_UPDATE_VALUES,
} from "./balancing-actions";
import initialState from "./balancing-initial";

const compare = (existing, incoming, diffs = [], level = "") => {
  if (
    typeof existing !== "object" ||
    typeof incoming !== "object" ||
    Array.isArray(existing) ||
    Array.isArray(incoming)
  ) {
    return;
  }

  const keysExisting = Object.keys(existing);
  const keysIncoming = Object.keys(incoming);

  for (let key of keysIncoming) {
    if (!keysExisting.includes(key)) {
      diffs.push(`Unknown property in incoming state: ${level ? `${level}.` : ""}${key}`);
    }
  }

  for (let key of keysExisting) {
    compare(existing[key], incoming[key], diffs, `${level ? `${level}.${key}` : key}`);
  }

  return diffs;
};

const updateCountingCalculations = (entry, property) => {
  const newEntry = {
    ...entry,
    closingAndTransfer: { ...entry.closingAndTransfer },
    counting: { ...entry.counting },
  };

  const calculateNewFloatAmount = () => {
    newEntry.closingAndTransfer.newFloatAmount = Math.max(
      newEntry.counting.countedAmount -
        newEntry.closingAndTransfer.bankDepositAmount -
        newEntry.closingAndTransfer.moveToBinAmount,
      0
    );
  };

  const calculateDifference = () => {
    newEntry.counting.difference = newEntry.counting.calculatedAmount - newEntry.counting.countedAmount;
  };

  switch (property) {
    case "countedAmount":
      calculateDifference();
      calculateNewFloatAmount();
      break;
    case "difference":
      newEntry.counting.countedAmount = newEntry.counting.calculatedAmount - newEntry.counting.difference;
      calculateDifference();
      calculateNewFloatAmount();
      break;
    case "newFloatAmount":
      newEntry.closingAndTransfer.bankDepositAmount =
        newEntry.counting.countedAmount -
        newEntry.closingAndTransfer.moveToBinAmount -
        newEntry.closingAndTransfer.newFloatAmount;
      // TODO: error if bank deposit amount is less than 0!
      break;
    case "bankDepositAmount":
      calculateNewFloatAmount();
      break;
    case "moveToBinAmount":
      calculateNewFloatAmount();
      break;
  }

  return newEntry;
};

export const balancing = createReducer(initialState, {
  [DRAGONGLASS_BALANCING_UPDATE_STATE]: (state, payload) => {
    const diffs = compare(state, payload);
    for (let diff of diffs) {
      console.warn(`[Balancing reducer issue] ${diff}`);
    }
    const result = { ...state, ...payload };
    const paymentTypes = result.cashCount.closingAndTransfer.map((entry) => entry.paymentTypeNo);
    result.cashCount.confirmed = {};
    for (let type of paymentTypes) {
      result.cashCount.confirmed[type] = false;
    }
    return result;
  },

  [DRAGONGLASS_BALANCING_UPDATE_VALUES]: (state, payload) => {
    const result = { ...state };
    const counting = [];
    const closingAndTransfer = [];
    payload = updateCountingCalculations(payload, payload.property);
    for (let entry of state.cashCount.counting) {
      if (entry.paymentTypeNo === payload.paymentTypeNo) {
        const newEntry = { ...entry, ...payload.counting };
        if (payload.property === "countedAmount") {
          delete newEntry._countedByType;
          for (let coinType of newEntry.coinTypes) {
            delete coinType.quantity;
          }
        }
        counting.push(newEntry);
      } else {
        counting.push(entry);
      }
    }
    for (let entry of state.cashCount.closingAndTransfer) {
      if (entry.paymentTypeNo === payload.paymentTypeNo) {
        const newEntry = { ...entry, ...payload.closingAndTransfer };
        closingAndTransfer.push(newEntry);
      } else {
        closingAndTransfer.push(entry);
      }
    }
    result.cashCount = { ...state.cashCount, counting, closingAndTransfer };
    return result;
  },

  [DRAGONGLASS_BALANCING_CONFIRM_PAYMENT_TYPE]: (state, payload) => {
    const result = { ...state, cashCount: { ...state.cashCount, confirmed: { ...state.cashCount.confirmed } } };
    result.cashCount.confirmed[payload] = true;
    return result;
  },

  [DRAGONGLASS_BALANCING_UPDATE_COIN_TYPES]: (state, payload) => {
    const { paymentTypeNo, coinTypes } = payload;
    const result = { ...state, cashCount: { ...state.cashCount } };
    const total = coinTypes.reduce((total, current) => total + current.value * (current.quantity || 0), 0);
    const counting = [];
    const closingAndTransfer = [];
    for (let i = 0; i < result.cashCount.counting.length; i++) {
      const block = {
        counting: { ...result.cashCount.counting[i] },
        closingAndTransfer: { ...result.cashCount.closingAndTransfer[i] },
      };
      if (block.counting.paymentTypeNo === paymentTypeNo) {
        block.counting.countedAmount = total;
        block = updateCountingCalculations(block, "countedAmount");
        const newCoinTypes = [];
        for (let coinType of block.counting.coinTypes) {
          const newCoinType = { ...coinType };
          const updated = coinTypes.find((t) => t.type === coinType.type && t.value === coinType.value);
          if (updated) {
            newCoinType.quantity = updated.quantity;
          }
          newCoinTypes.push(newCoinType);
        }
        block.counting.coinTypes = newCoinTypes;
        block.counting._countedByType = true;
      }
      counting.push(block.counting);
      closingAndTransfer.push(block.closingAndTransfer);
    }
    result.cashCount.counting = counting;
    result.cashCount.closingAndTransfer = closingAndTransfer;
    return result;
  },
});
