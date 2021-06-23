import { Component } from "react";
import { Timer } from "../classes/Timer";

class TimerCaption extends Component {
    constructor(props) {
        super(props);
        Timer.subscribe(this, props.layout.refresh || 60);
        this.state = {
            time: new Date()
        }
    }

    componentWillUnmount() {
        Timer.unsubscribe(this);
    }

    timerUpdate(date) {
        this.setState({ time: date });
    }

    render() {
        return this.state.time.toString();
    }
}

export default TimerCaption;