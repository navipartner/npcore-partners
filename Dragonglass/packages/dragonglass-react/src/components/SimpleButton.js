import React, { PureComponent } from "react";

export default class SimpleButton extends PureComponent {
    render() {
        const { width = 80, height = 40, caption, onClick, className = "", active } = this.props;

        // TODO Vladimir: "active" indicates if this is the currently selected location, the button should show different style to indicate it's active (the same as :active selector in Button.scss)

        return (
            <div className={`button button--simple ${className}`} style={{ height, width }} onClick={e => typeof onClick === "function" && onClick(e)}>
                <div className="ripple-effect">
                    <span className="button__caption">
                        <span className="caption">
                            {caption}
                        </span>
                    </span>
                </div>
            </div>
        );
    }
}
