import React, { useState } from "react";
import CountingNumpad from "./CountingNumpad";
import InlineProperty from "./InlineProperty";
import { contentItems } from "./ContentDefaultViewItems.js";
import { balancingActions } from "../../redux/balancing/balancing-actions";
import { motion } from "framer-motion";
import { CountingConfirmButton } from "./CountingConfirmButton";
import { localize } from "../LocalizationManager";
import { Popup } from "../../dragonglass-popup/PopupHost";

export default function ContentDefaultView({ state, layout, activePaymentTypeIndex, displayCoinTypes }) {
  const countedByType = state.counting[activePaymentTypeIndex]._countedByType;
  // TODO: Aca, if countedByType is true then the coin icons should be shown in green (just like confirmed icon when confirmed)
  const countingData = state.counting[activePaymentTypeIndex];
  const closingAndTransferData = state.closingAndTransfer[activePaymentTypeIndex];

  const [focusedInlineProperty, setFocusedInlineProperty] = useState("");
  const [propertyValueSelected, setPropertyValueSelected] = useState("");

  const confirmIfNecessary = async () => {
    if (focusedInlineProperty === "countedAmount" && state.counting[activePaymentTypeIndex]._countedByType) {
      return Popup.confirm(localize("Balancing_CountByTypeCompletedLbl"));
    }
    return true;
  };

  const setValues = (values) => {
    const payload = {
      property: focusedInlineProperty,
      paymentTypeNo: countingData.paymentTypeNo,
      counting: {
        calculatedAmount: values.calculatedAmount,
        countedAmount: values.countedAmount,
        difference: values.difference,
      },
      closingAndTransfer: {
        floatAmount: values.floatAmount,
        transferredAmount: values.transferredAmount,
        calculatedAmount: values.calculatedAmount,
        newFloatAmount: values.newFloatAmount,
        bankDepositAmount: values.bankDepositAmount,
        bankDepositBinCode: values.bankDepositBinCode,
        bankDepositReference: values.bankDepositReference,
        moveToBinAmount: values.moveToBinAmount,
        moveToBinNo: values.moveToBinNo,
        moveToBinTransId: values.moveToBinTransId,
      },
    };
    balancingActions.updateValues(payload);
  };

  const convertToFloat = (value) => {
    const floatValue = parseFloat(value);

    if (isNaN(floatValue)) {
      return value;
    }

    return floatValue.toFixed(2);
  };

  const values = {
    calculatedAmount: convertToFloat(countingData.calculatedAmount),
    countedAmount: convertToFloat(countingData.countedAmount),
    difference: convertToFloat(countingData.difference),
    floatAmount: convertToFloat(closingAndTransferData.floatAmount),
    transferredAmount: convertToFloat(closingAndTransferData.transferredAmount),
    calculatedAmount: convertToFloat(closingAndTransferData.calculatedAmount),
    newFloatAmount: convertToFloat(closingAndTransferData.newFloatAmount),
    bankDepositAmount: convertToFloat(closingAndTransferData.bankDepositAmount),
    bankDepositBinCode: closingAndTransferData.bankDepositBinCode,
    bankDepositReference: closingAndTransferData.bankDepositReference,
    moveToBinAmount: convertToFloat(closingAndTransferData.moveToBinAmount),
    moveToBinNo: closingAndTransferData.moveToBinNo,
    moveToBinTransId: closingAndTransferData.moveToBinTransId,
  };

  const updateTextValue = async (value) => {
    if (!(await confirmIfNecessary())) {
      return;
    }

    let newValues = { ...values };
    newValues[focusedInlineProperty] = value;

    setValues(newValues);
  };

  const deleteLastCharacter = async () => {
    if (!(await confirmIfNecessary())) {
      return;
    }

    const currentValue = values[focusedInlineProperty];

    if (currentValue !== "0.00") {
      let newValues = { ...values };

      let slicedValue = currentValue.replace(/\D/g, "").slice(0, -1);

      const decimalSeparator = (0.1).toLocaleString().replace(/\d/g, "");

      let firstPart = slicedValue.slice(0, slicedValue.length - 2);

      if (firstPart === "") {
        firstPart = "0";
      }

      slicedValue = firstPart + decimalSeparator + slicedValue.slice(-2);

      newValues[focusedInlineProperty] = slicedValue;

      setValues(newValues);
      setPropertyValueSelected("");
    }
  };

  const updateNumberValue = async (value) => {
    if (!(await confirmIfNecessary())) {
      return;
    }

    let newValues = { ...values };

    if (value.length > 1) {
      value = value.slice(-1);
    }

    const currentValue = values[focusedInlineProperty];
    const currentValueWithoutDecimalSeparator = currentValue.replace(/\D/g, "");

    if (value === ".") {
      const slicedValue = currentValueWithoutDecimalSeparator.slice(0, currentValueWithoutDecimalSeparator.length - 2);
      const currentIntValue = parseInt(slicedValue);

      if (currentIntValue < 1) {
        let newValue = "";

        if (currentValueWithoutDecimalSeparator.slice(0, 2) === "00") {
          newValue = currentValueWithoutDecimalSeparator.slice(-1);
        } else if (currentValueWithoutDecimalSeparator.slice(0, 1) === "0") {
          newValue = currentValueWithoutDecimalSeparator.slice(-2);
        }

        newValues[focusedInlineProperty] = newValue + ".00";
      }
    } else {
      let digitOnlyValue = propertyValueSelected ? value : currentValueWithoutDecimalSeparator + value;

      if (digitOnlyValue.toString().length === 1) {
        digitOnlyValue = "00" + digitOnlyValue;
      } else if (
        digitOnlyValue.slice(0, 1) === "0" ||
        (digitOnlyValue.slice(0, 1) === "0" && digitOnlyValue.slice(1, 2) === "0")
      ) {
        digitOnlyValue = digitOnlyValue.slice(-3);
      }

      const decimalSeparator = (0.1).toLocaleString().replace(/\d/g, "");
      const fullValue =
        digitOnlyValue.slice(0, digitOnlyValue.length - 2) + decimalSeparator + digitOnlyValue.slice(-2);

      newValues[focusedInlineProperty] = fullValue;
    }

    setValues(newValues);
    setPropertyValueSelected("");
  };

  const setAsFocused = (property) => {
    setFocusedInlineProperty(property);
  };

  const setSelected = (property) => {
    setPropertyValueSelected(property);
  };

  const disableNumpadFor = ["bankDepositBinCode", "bankDepositReference", "moveToBinNo", "moveToBinTransId"];

  const isNumpadDisabled = !focusedInlineProperty || disableNumpadFor.includes(focusedInlineProperty);

  const animationDelay = 0.05;
  const bezierCurve = [0.34, 1.56, 0.64, 1];

  const variants = {
    hidden: {
      position: "relative",
      top: -40,
      opacity: 0,
    },
    visible: (custom) => {
      return {
        top: 0,
        opacity: 1,
        transition: {
          ease: bezierCurve,
          delay: animationDelay * custom,
        },
      };
    },
  };

  return (
    <div className="counting__content counting__content--default">
      <div className="counting__data-container">
        <motion.h1 variants={variants} initial="hidden" animate="visible" custom={0}>
          {localize("Balancing_CashCountCounting")}
        </motion.h1>
        <motion.div
          className="counting__primary-data"
          variants={variants}
          initial="hidden"
          animate="visible"
          custom={0}
        >
          {contentItems.primaryDataItems.map((item, index) => {
            const inputIcon =
              item.property === "countedAmount" ? (
                <div className="input-icon" onClick={() => displayCoinTypes()}>
                  <i className="fa-light fa-coins"></i>
                </div>
              ) : item.property === "difference" ? (
                <CountingConfirmButton paymentType={state.counting[activePaymentTypeIndex]} />
              ) : null;

            return (
              <InlineProperty
                key={index}
                layout={layout.counting}
                property={item.property}
                isEditable={item.isEditable}
                type={item.type}
                currentValue={values[item.property]}
                setAsFocused={setAsFocused}
                focusedInlineProperty={focusedInlineProperty}
                updateNumberValue={updateNumberValue}
                updateTextValue={updateTextValue}
                setSelected={setSelected}
                deleteLastCharacter={deleteLastCharacter}
                inputIcon={inputIcon}
              />
            );
          })}
        </motion.div>
        <div className="counting__inline-container">
          <motion.div
            className="counting__inline-section counting__inline-section--wide"
            variants={variants}
            initial="hidden"
            animate="visible"
            custom={1}
          >
            <h1>{localize("Balancing_CashCountClosingAndTransfer")}</h1>
            <div className="inline-properties inline-properties--grid">
              {contentItems.closingAndTransferItems.map((item, index) => {
                return (
                  <InlineProperty
                    key={index}
                    layout={layout.closingAndTransfer}
                    property={item.property}
                    isEditable={item.isEditable}
                    type={item.type}
                    currentValue={values[item.property]}
                    setAsFocused={setAsFocused}
                    focusedInlineProperty={focusedInlineProperty}
                    updateNumberValue={updateNumberValue}
                    updateTextValue={updateTextValue}
                    setSelected={setSelected}
                    deleteLastCharacter={deleteLastCharacter}
                  />
                );
              })}
            </div>
          </motion.div>
          <motion.div
            className="counting__inline-section"
            variants={variants}
            initial="hidden"
            animate="visible"
            custom={2}
          >
            <h1>{localize("Balancing_CashCountBankDeposit")}</h1>
            <div className="inline-properties inline-properties--column">
              {contentItems.bankDepositItems.map((item, index) => {
                return (
                  <InlineProperty
                    key={index}
                    layout={layout.closingAndTransfer}
                    property={item.property}
                    isEditable={item.isEditable}
                    type={item.type}
                    currentValue={values[item.property]}
                    setAsFocused={setAsFocused}
                    focusedInlineProperty={focusedInlineProperty}
                    updateNumberValue={updateNumberValue}
                    updateTextValue={updateTextValue}
                    setSelected={setSelected}
                    deleteLastCharacter={deleteLastCharacter}
                  />
                );
              })}
            </div>
          </motion.div>
          <motion.div
            className="counting__inline-section"
            variants={variants}
            initial="hidden"
            animate="visible"
            custom={3}
          >
            <h1>{localize("Balancing_CashCountMoveToBin")}</h1>
            <div className="inline-properties inline-properties--column">
              {contentItems.moveToBinItems.map((item, index) => {
                return (
                  <InlineProperty
                    key={index}
                    layout={layout.closingAndTransfer}
                    property={item.property}
                    isEditable={item.isEditable}
                    type={item.type}
                    currentValue={values[item.property]}
                    setAsFocused={setAsFocused}
                    focusedInlineProperty={focusedInlineProperty}
                    updateNumberValue={updateNumberValue}
                    updateTextValue={updateTextValue}
                    setSelected={setSelected}
                    deleteLastCharacter={deleteLastCharacter}
                  />
                );
              })}
            </div>
          </motion.div>
        </div>
      </div>
      <CountingNumpad
        updateInput={updateNumberValue}
        deleteInput={deleteLastCharacter}
        isNumpadDisabled={isNumpadDisabled}
        hasDecimalPoint={true}
        hasDelete={true}
        isDecimalPointDisabled={parseInt(values[focusedInlineProperty]) >= 1}
        animationDelay={0.25}
      />
    </div>
  );
}
