import React from "react";
import { useState } from "react";
import VisibilitySensor from "react-visibility-sensor";
import { useLookup } from "../redux/lookup/useLookup";
import useUniqueId from "./useUniqueId";

const WrapWithVisibility = ({ children, wrap, loadMore, index }) => {
  return wrap ? (
    <VisibilitySensor
      onChange={(visible) => {
        console.info(`Index: ${index}, visible: ${visible}`);
        visible && loadMore();
      }}
    >
      {children}
    </VisibilitySensor>
  ) : (
    children
  );
};

const Dropdown = ({ showCount, id, type, batchSize, updateInputValue, filter }) => {
  filter = (filter || "").toLowerCase();
  const dataRaw = useLookup(showCount, id, type, batchSize);
  const data = filter
    ? dataRaw.filter(
        (item) => item.id.toLowerCase().includes(filter) || item.description.toLowerCase().includes(filter)
      )
    : dataRaw;

  return (
    <div className="input-with-lookup__dropdown">
      <div className="input-with-lookup__dropdown-content">
        {data.map((row, index) => {
          const wrap = typeof data.loadMore === "function" && !data.completed && index === data.length - 1;
          const caption = `${row.id}: ${row.description}`;

          return (
            <WrapWithVisibility key={index} loadMore={data.loadMore} wrap={wrap} index={index}>
              <div className="input-with-lookup__row" onMouseDown={() => updateInputValue(row.id)}>
                {caption}
              </div>
            </WrapWithVisibility>
          );
        })}
      </div>
    </div>
  );
};

export const InputWithLookup = ({
  type,
  batchSize,
  className,
  onFocus,
  onBlur,
  onChange,
  onRowClick,
  currentValue,
}) => {
  const id = useUniqueId("input-with-lookup");
  const [state, updateState] = useState({ shown: false, showCount: 1 });
  const { shown, showCount } = state;
  const [filter, setFilter] = useState();

  const updateStateOnFocus = (event) => {
    onFocus(event);
    updateState({ shown: !shown, showCount: showCount + 1 });
    setFilter(null);
  };

  const updateStateOnBlur = () => {
    onBlur();
    updateState({ shown: !shown, showCount });
  };

  const searchByTyping = (event) => {
    setFilter(event.target.value);
    onChange(event);
  };

  return (
    <div className="input-with-lookup">
      <input
        type="text"
        onFocus={updateStateOnFocus}
        onBlur={updateStateOnBlur}
        className={className}
        value={currentValue || ""}
        onChange={searchByTyping}
      />
      {shown ? (
        <Dropdown
          showCount={showCount}
          id={id}
          type={type}
          batchSize={batchSize}
          updateInputValue={onRowClick}
          filter={filter}
        />
      ) : null}
    </div>
  );
};
