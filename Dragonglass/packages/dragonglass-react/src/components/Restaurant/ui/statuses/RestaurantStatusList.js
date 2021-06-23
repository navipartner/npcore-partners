import React, { PureComponent } from "react";
import { getStatusColorAndIcon } from "../../status";

const getStyle = (status, active) => {
  const style = {};
  if (status && status.color) {
    style.backgroundColor = status.color;
    if (!active) style.backgroundColor += "11";
  }

  return style;
};

const Status = (props) => {
  const { status, active, bound, onClick } = props;
  const statusStyle = getStatusColorAndIcon(props.status, active);

  return (
    <div
      style={getStyle(statusStyle, active)}
      className={`npre-status ${active ? "npre-status--is-active" : ""} ${
        bound ? "" : "npre-status--unbound"
      }`}
      onClick={(e) => onClick(e, status.id)}
    >
      {statusStyle.icon ? (
        <span className={`npre-status__icon ${statusStyle.icon}`}></span>
      ) : null}
      {status.caption}
    </div>
  );
};

export class RestaurantStatusList extends PureComponent {
  /* virtual */ click() {}

  render() {
    const { statuses, active } = this.props;
    statuses.sort((left, right) => (left.ordinal || 0) - (right.ordinal || 0));

    return (
      <div className="npre-status-container">
        {statuses.map((status, id) => (
          <Status
            bound={this.props.bound}
            status={status}
            key={id}
            active={active === status.id}
            onClick={(e, id) => this.click(e, id)}
          />
        ))}
      </div>
    );
  }
}
