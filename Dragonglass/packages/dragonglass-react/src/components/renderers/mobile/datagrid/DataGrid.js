import React, { useState } from "react";
import { useSelector } from "react-redux";
import { ConfigProvider } from "./ConfigProvider";
import { DataGridItem } from "./DataGridItem";
import Alert from "../Alert/Alert";
import ALERT_MESSAGE_TYPES from "../Alert/AlertMessageTypes";
import EmptyCart from "./EmptyCart";
import { AnimateSharedLayout, AnimatePresence, motion } from "framer-motion";

export const DataGrid = ({ layout, clickHandler }) => {
  const [currentlySwipedItemIndex, setCurrentlySwipedItemIndex] = useState(
    null
  );

  if (!layout || !layout.dataSource) {
    return (
      <Alert
        messageType={ALERT_MESSAGE_TYPES.DANGER}
        originFile="DataGrid.js"
        originProperties={["layout", "layout.dataSource"]}
      />
    );
  }

  const provider = ConfigProvider.getLayout(layout);

  if (!provider) {
    return (
      <Alert
        messageType={ALERT_MESSAGE_TYPES.DANGER}
        originFile="DataGrid.js"
        originProperties={["provider"]}
      />
    );
  }

  let data = useSelector((state) => {
    const set = state.data.sets[layout.dataSource];
    const source = state.data.sources[layout.dataSource];
    return set && source ? { set, source } : null;
  });

  // TODO: Vjeko and Aca to figure out how to set this up without the Alert always flashing before getting the data from useSelector.
  if (data === null) {
    return null;
    // <Alert
    //   messageType={ALERT_MESSAGE_TYPES.DANGER}
    //   originFile="DataGrid.js"
    //   originProperties={["data source"]}
    //   additionalMessage="Unknown dataSource was specified."
    // />
  }

  return (
    <AnimateSharedLayout>
      <motion.div className="data-grid" layout>
        <AnimatePresence>
          {data.set.rows.map((item) => (
            <DataGridItem
              key={item.position}
              provider={provider}
              item={item}
              itemIndex={item.position}
              dataSource={layout.dataSource}
              setCurrentlySwipedItemIndex={(itemIndex) =>
                setCurrentlySwipedItemIndex(itemIndex)
              }
              currentlySwipedItemIndex={currentlySwipedItemIndex}
              clickHandler={clickHandler}
            />
          ))}

          {data.set.rows.length === 0 && <EmptyCart />}
        </AnimatePresence>
      </motion.div>
    </AnimateSharedLayout>
  );
};
