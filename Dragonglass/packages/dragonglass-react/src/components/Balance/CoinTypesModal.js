import React, { useState } from "react";
import CountingNumpad from "./CountingNumpad";
import CoinTypesRow from "./CoinTypesRow";
import { motion } from "framer-motion";
import { localize } from "../LocalizationManager";
import { balancingActions } from "../../redux/balancing/balancing-actions";

export default function CoinTypesModal({ coinTypes, paymentTypeNo, onClose }) {
  const totalQuantity = coinTypes.reduce((total, current) => total + (current.quantity || 0), 0);
  const totalAmount = coinTypes.reduce((total, current) => total + current.value * (current.quantity || 0), 0);
  const [activeRowIndex, setActiveRowIndex] = useState();

  const updateQuantities = (quantity) => {
    const newCoinTypes = coinTypes.map((type) => ({ ...type }));
    newCoinTypes[activeRowIndex].quantity = quantity;
    balancingActions.updateCoinTypes(paymentTypeNo, newCoinTypes);
  };

  const updateQuantityInput = (quantity) => {
    const currentQuantity = coinTypes[activeRowIndex].quantity || "";
    const newQuantity = Number.parseInt(`${currentQuantity}${quantity}`);
    updateQuantities(newQuantity);
  };

  const deleteQuantityInput = () => {
    updateQuantities(0);
  };

  const descriptionPresent = coinTypes.find((type) => type.description);

  return (
    <div className="modal-backdrop">
      <div className="modal">
        <h1>{localize("Balancing_CashCountCoinTypes")}</h1>
        <div className="modal__container">
          <motion.div
            className="coin-types"
            initial={{ position: "relative", top: -40, opacity: 0 }}
            animate={{ top: 0, opacity: 1, transition: { ease: [0.34, 1.56, 0.64, 1] } }}
          >
            <div className="row row--heading">
              <div className="cell">{localize("Balancing_CashCountType")}</div>
              {descriptionPresent ? <div className="cell">{localize("Balancing_CashCountDescription")}</div> : null}
              <div className="cell">{localize("Balancing_CashCountQuantity")}</div>
              <div className="cell">{localize("Balancing_CashCountAmount")}</div>
            </div>
            {coinTypes.map((item, index) => {
              const isOddRow = index % 2 === 0;
              const isActive = index === activeRowIndex;

              return (
                <CoinTypesRow
                  isOddRow={isOddRow}
                  coinType={item}
                  key={index}
                  onQuantityChange={updateQuantities}
                  isActive={isActive}
                  markAsActiveOnClick={() => setActiveRowIndex(index)}
                  quantity={item.quantity || 0}
                  descriptionPresent={descriptionPresent}
                  index={index}
                />
              );
            })}
            <div className="row row--total">
              <div className="cell">{localize("Balancing_CashCountTotal")}</div>
              {descriptionPresent && <div className="cell"></div>}
              <div className="cell total-quantity">{totalQuantity}</div>
              <div className="cell">{totalAmount.toFixed(2)}</div>
            </div>
          </motion.div>
          <CountingNumpad
            updateInput={updateQuantityInput}
            deleteInput={deleteQuantityInput}
            hasDecimalPoint={false}
            hasDelete={true}
            animationDelay={0.15}
          />
        </div>
        <div className="button" onClick={() => onClose(totalAmount)}>
          {localize("Global_Close")}
        </div>
      </div>
    </div>
  );
}
