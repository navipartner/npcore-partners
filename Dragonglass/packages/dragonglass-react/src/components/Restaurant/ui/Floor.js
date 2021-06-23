import React, { PureComponent } from "react";
import { Bar } from "./Bar";
import { Door } from "./Door";
import { Room } from "./Room";
import Table from "./Table";
import { Wall } from "./Wall";
import { StateStore } from "../../../redux/StateStore";
import { restaurantSelectTableAction } from "../../../redux/actions/restaurantActions";

const renderers = {
  bar: (component, props) => (
    <Bar
      component={component}
      locationId={props.locationId}
      restaurantId={props.restaurantId}
    />
  ),
  door: (component, props) => (
    <Door
      component={component}
      locationId={props.locationId}
      restaurantId={props.restaurantId}
    />
  ),
  room: (component, props) => (
    <Room
      component={component}
      locationId={props.locationId}
      restaurantId={props.restaurantId}
    />
  ),
  table: (component, props) => (
    <Table
      component={component}
      tableId={component.id}
      locationId={props.locationId}
      showWaiterPads={props.showTableWaiterPads}
      restaurantId={props.restaurantId}
    />
  ),
  wall: (component, props) => (
    <Wall
      component={component}
      locationId={props.locationId}
      restaurantId={props.restaurantId}
    />
  ),
};

const render = (component, key, props) => {
  const { type, x = 0, y = 0 } = component;

  return (
    <div key={key} id={component.id} style={{ top: `${y}px`, left: `${x}px` }}>
      {renderers[type](component, props)}
    </div>
  );
};

export class Floor extends PureComponent {
  constructor(props) {
    super(props);

    this._ref = React.createRef();
  }

  clickEmptySpace(e) {
    if (e.target === this._ref.current)
      StateStore.dispatch(restaurantSelectTableAction(null));
  }

  render() {
    const { components, ...props } = this.props;
    return (
      <div
        ref={this._ref}
        className="restaurant__floor"
        onClick={(e) => this.clickEmptySpace(e)}
      >
        {components.map((component, key) => render(component, key, props))}
      </div>
    );
  }
}
