import React, { Component as PureComponent } from "react";
import { bindComponentToWatermarkState } from "../redux/reducers/imagesReducer";

class WatermarkUnbound extends PureComponent {
    render() {
        const { watermark } = this.props;
        if (!watermark)
            return null;

        return (
            <div className="np-watermark">
                <div className="content">
                    {
                        typeof watermark === "object"
                            ? watermark.text
                            : <img src={watermark} />
                    }
                </div>
            </div>
        );
    }
}

export const Watermark = bindComponentToWatermarkState(WatermarkUnbound);
