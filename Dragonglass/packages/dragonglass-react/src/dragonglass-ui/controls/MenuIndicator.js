import React, { Component } from "react";

export class MenuIndicator extends Component {
    constructor(props) {
        super(props);
        this.state = {};
        this._rendered = false;
        this._settingStyle = false;
    }

    componentDidMount() {
        this._updateUI();
        this._updateListener = () => this._scheduleUpdate();
        window.addEventListener("resize", this._updateListener);
    }

    componentWillUnmount() {
        window.removeEventListener("resize", this._updateListener);
    }

    _scheduleUpdate() {
        this._updateUI();
    }

    _updateUI() {
        const parent = document.querySelector(`.${this.props.uniqueClass}`);
        this._settingStyle = true;
        this.setState({
            style: {
                left: parent.offsetLeft,
                width: parent.clientWidth
            }
        });
        this._settingStyle = false;
    }

    render() {
        const style = { ... this.state.style };
        if (this._rendered && !this._settingStyle)
            setTimeout(() => { this._updateUI() });
        this._rendered = true;
        return <div style={style} className="c-navigation__indicator"></div>
    }
}