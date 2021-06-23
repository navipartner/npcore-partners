import { StateStore } from "../redux/StateStore";
import { updateDataAction, deleteLineAction } from "../redux/actions/dataActions";

var pos = 0;

const pending = {};
const lineNoRegEx = /Line No\.=CONST\((?<lineNo>\d+)\)/i;

const lineNoFromPosition = position => {
    const match = position.match(lineNoRegEx);
    return (!match || !match.groups || !match.groups.lineNo)
        ? 0
        : Number.parseInt(match.groups.lineNo);
};

export class DataManager {
    static insertItemWithPending(no, caption, dataSource) {
        try {
            const newPos = `fake_${pos++}`;
            const payload = {
                "rows": [
                    {
                        "position": newPos,
                        "pending": true,
                        "fields": {
                            "6": no,
                            "10": caption,
                            "12": 1
                        }

                    }
                ],
                "pending": true,
                "currentPosition": newPos,
                "dataSource": dataSource,
                "totals": {}
            };

            if (!pending[dataSource])
                pending[dataSource] = [];

            const dataBefore = StateStore.getState().data;
            const set = dataBefore.sets[dataSource];
            const maxLineNo = set.rows.reduce((prev, current) => {
                const currentLineNo = lineNoFromPosition(current.position);
                return currentLineNo > prev ? currentLineNo : prev;
            }, 0);
            let result;
            pending[dataSource].push(result = {
                ...payload,
                fieldMatch: row => row.fields["6"] === no && lineNoFromPosition(row.position) > maxLineNo,
                _previousPosition: dataBefore.sets[dataSource].currentPosition
            });

            StateStore.dispatch(updateDataAction({ [dataSource]: payload }));
            return result;
        } catch {
            return null;
        }
    }

    static cancelPendingLineIfNecessary(newLine) {
        if (!newLine || !newLine.currentPosition)
            return;

        const data = StateStore.getState().data;
        const set = data.sets[newLine.dataSource];
        if (pending[newLine.dataSource].length) {
            pending[newLine.dataSource] = pending[newLine.dataSource].filter(row => row.currentPosition !== newLine.currentPosition)
        }

        const line = set.rows.find(row => row.position === newLine.currentPosition);
        if (line && line.pending)
            StateStore.dispatch(deleteLineAction(newLine));
    }

    static updateData(dataSets) {
        Object.keys(dataSets).forEach(key => {
            if (!pending[key] || !pending[key].length)
                return;

            let dataSet = dataSets[key];
            dataSet.rows.forEach(row => {
                let pendingPayload = pending[key].find(p => p.fieldMatch(row));
                if (!pendingPayload)
                    return;

                row._pendingPosition = pendingPayload.currentPosition;
                pending[key] = pending[key].filter(row => row !== pendingPayload);
                if (pending[key].length)
                    dataSet._stillPending = true;
            });
        });
        StateStore.dispatch(updateDataAction(dataSets));
    }
}
