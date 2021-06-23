import React, { Component } from "react";

export class Chair extends Component {
  render() {
    const noChairs = this.props.chairs || 0;

    return (
      <div className="table__chairs">
        {Array.from(Array(noChairs)).map((_, index) => (
          <span key={index} />
        ))}
      </div>
    );
  }
}
