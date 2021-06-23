import { Enabled } from "../enums/Enabled";
import { ActionType } from "../enums/ActionType";
import { localize } from "../components/LocalizationManager";

const cache = {};

function shouldShow(button, state) {
    if (!button.Content)
        return true;

    if (button.Content.filterSalesPerson)
        return state && button.Content.filterSalesPerson.split("|").includes(state.salesPerson);
    if (button.Content.filterRegister)
        return state && button.Content.filterRegister.split("|").includes(state.register);

    return true;
}

/**
 * From menu redux state and layout definition, builds a menu array for rendering through the
 * ButtonGrid component. If possible, returns a cached version, and when possible, caches a built
 * version.
 *
 * @param {Object} menu An object typically from redux state, that represents raw menu definition (typically coming from NAV)
 * @param {Number|Array<Number>} rows Number of rows for the button grid menu. It can either be a number or an array of numbers, where each number in array represents "weight" of the row.
 * @param {Number|Array<Number>} Columns Number of columns for the button grid menu. It can either be a number or an array of numbers, where each number in array represents "weight" of the column.
 * @param {Object} state Transaction state from redux.
 * @param {Object} parent When constructing a submenu, this is the parent menu button. Otherwise, null or undefined.
 * @returns Array representing button grid.
 */
function getMenu(menu, rows, columns, state, parent) {
    let cacheId;
    if (menu.Id && menu.generation) {
        cacheId = `${menu.Id}_${rows}_${columns}`;
        if (cache[cacheId] && cache[cacheId].generation === menu.generation)
            return cache[cacheId];
    }

    const resultingArray = [];
    const free = [];
    const rowsIsArray = Array.isArray(rows);
    const columnsIsArray = Array.isArray(columns);
    const r = rowsIsArray ? rows.length : rows;
    const c = columnsIsArray ? columns.length : columns;
    let freeCount = r * c;
    for (let i = 0; i < r; i++) {
        let row = [];
        let freeRow = [];
        for (let j = 0; j < c; j++) {
            row.push(null);
            freeRow.push(null);
        }
        resultingArray.push(row);
        rowsIsArray && (row.heightFactor = rows[i]);
        free.push(freeRow);
    }

    function fitOrContinue(b, x, y) {
        if (!resultingArray[y][x]) {
            let btn = resultingArray[y][x] = new MenuButtonInfo(b, parent, x, y);
            btn.menuId || (menu.Id && (btn.menuId = menu.Id));
            btn.widthFactor = columnsIsArray ? columns[x] : 1;
            if (b.Row) btn.row = b.Row;
            if (b.Column) btn.column = b.Column;

            btn.action &&
                btn.action.Type &&
                btn.action.Type === ActionType.SubMenu &&
                (btn.submenu = getMenu({ Id: menu.Id, MenuButtons: b.MenuButtons }, rows, columns, state, btn));
            free[y][x] = 1;
            freeCount--;
            return true;
        }
        return false;
    }

    function placeButton(b, startX, startY, favorColumn) {
        startX >= c && (startX = c - 1);
        startY >= r && (startY = r - 1);
        let x = startX, y = startY;
        while (freeCount > 0) {
            if (fitOrContinue(b, x, y)) return;
            favorColumn
                ? (
                    y++ ,
                    y >= r && (y = 0, x++),
                    x >= c && (x = 0)
                )
                : (
                    x++ ,
                    x >= c && (x = 0, y++),
                    y >= r && (y = 0)
                );
            if (x === startX && y === startY) return;
        }
    }

    let buttons = menu.MenuButtons.filter(button => shouldShow(button, state));
    while (buttons.length < c * r) buttons.push({ Enabled: false });
    for (let iter = 0; iter < 4; iter++) {
        let todo = [];
        for (let k = 0; k < buttons.length; k++) {
            let b = buttons[k];
            let skip = true;
            let placeX = 0, placeY = 0, favorColumn = false;
            iter === 0 &&
                (b.Row && b.Column) &&
                (skip = false, placeX = b.Column - 1, placeY = b.Row - 1);
            iter === 1 && (b.Column) && (skip = false, placeX = b.Column - 1, favorColumn = true);
            iter === 2 && (b.Row) && (skip = false, placeY = b.Row - 1);
            iter === 3 && (skip = false);
            skip ? todo.push(b) : placeButton(b, placeX, placeY, favorColumn);
        }
        buttons = todo;
    }

    if (parent) {
        resultingArray[r - 1][c - 1] = {
            caption: localize("Global_Back"),
            enabled: true,
            backgroundColor: "red",
            iconClass: "fad fa-backward",
            widthFactor: 1,
            action: { Type: ActionType.Back }
        };
    }

    if (cacheId && menu.generation) {
        cache[cacheId] = resultingArray;
        cache[cacheId].generation = menu.generation;
    }

    return resultingArray;
}

/**
 * Represents an individual button in a button grid menu
 *
 * @class MenuButtonInfo
 */
export class MenuButtonInfo {
    constructor(button, parent, x, y) {
        this.caption = button.Caption;
        this.action = button.Action || (button.MenuButtons && { Type: ActionType.SubMenu });
        if (button.Action && button.Action.Type === "Menu" && button.Action.OpenAsPopup)
            this.action.Type = ActionType.PopupMenu;        
        this.enabled = !button.hasOwnProperty("Enabled") || Enabled.parse.fromInt(button.Enabled) === Enabled.Yes;
        this.autoEnable = Enabled.parse.fromInt(button.Enabled) === Enabled.Auto;
        this.backgroundColor = button.BackgroundColor;
        this.bold = button.Bold;
        this.class = button.Class;
        this.color = button.Color,
            this.fontSize = button.FontSize;

            this.iconClass = button.IconClass;
        // Backward-compatibility support for Transcendence setup and Font Awesome icons
        if ((this.iconClass || "").startsWith("fa-"))
            this.iconClass = `fad ${this.iconClass}`;

        this.tooltip = button.Tooltip;
        this.content = button.Content;
        this.positionReference = { x: x, y: y };
        button.Row && (this.row = button.Row);
        button.Column && (this.column = button.Column);

        if (parent) {
            if (parent.menuId)
                this.menuId = parent.menuId;
            if (parent.content.keyId)
                this.parentKeyId = parent.content.keyId;
        }
    }
}

export const getButtonGridMenu = getMenu;