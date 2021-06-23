import React, { Component } from "react";
import { bindComponentToDataSetState } from "../../redux/reducers/dataReducer";
import DataBoundCaption from "../DataBoundCaption";
import Caption from "../Caption";

class GridTotals extends Component {
    render() {
        const { dataSourceName, totals } = this.props;
        return (
            <div className="subtotal">
                {
                    totals.map((total, index) =>
                        <div key={index} className="subtotal__container">
                            <span className="left"><Caption caption={total.caption} /></span>
                            <span className="right"><DataBoundCaption fallbackValue={0} dataSourceName={dataSourceName} total={total.total} /></span>
                        </div>)
                }
            </div>
        )
    }
}

export default bindComponentToDataSetState(GridTotals);
