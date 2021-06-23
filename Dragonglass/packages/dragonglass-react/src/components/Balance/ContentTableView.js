import React from "react";
import CountingTable from "./CountingTable";
import ClosingAndTransferTable from "./ClosingAndTransferTable";
import { motion } from "framer-motion";
import { localize } from "../LocalizationManager";

export default function ContentTableView({ state, layout, displayCoinTypes }) {
  return (
    <div className="counting__content">
      <motion.h1
        initial={{ position: "relative", top: -40, opacity: 0 }}
        animate={{ top: 0, opacity: 1, transition: { ease: [0.34, 1.56, 0.64, 1] } }}
      >
        {localize("Balancing_CashCountCounting")}
      </motion.h1>
      <CountingTable layout={layout.counting} data={state.counting} displayCoinTypes={displayCoinTypes} />
      <ClosingAndTransferTable layout={layout.closingAndTransfer} data={state.closingAndTransfer} />
    </div>
  );
}
