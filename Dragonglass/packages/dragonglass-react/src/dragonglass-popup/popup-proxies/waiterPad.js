import { FormatAs } from "../../enums/DataType";
import { localize, GlobalCaption } from "../../components/LocalizationManager";

const DEFAULT_SIZE = {
    width: "500px",
    height: "300px"
};

const DEFAULT_BODY_STYLE = {
    display: "flex",
    flexDirection: "column",
    justifyContent: "center",
    alignItems: "center"
};

const DEFAULT_TITLE_STYLE = {
    marginBottom: "0.5em"
};

const DEFAULT_AMOUNT_STYLE = {
    fontWeight: "1200",
    fontSize: "1.5em",
    marginBottom: "1em"
};

const DEFAULT_SPINNER_STYLE = {
    height: 50,
    width: 50,
    margin: "1em"
};

const DEFAULT_STATUS_STYLE = {
    marginTop: "1em"
}

const DEFAULT_TITLE = "Payment"; // TODO: Localize
const DEFAULT_AMOUNT = FormatAs.decimal(0);
const DEFAULT_SPINNER = Microsoft.Dynamics.NAV.GetImageResource("spinner-100-R.png");
const DEFAULT_INITIAL_STATUS = "Initializing..."; // TODO: Localize

const getDefaultUI = param => {
    const ui = [
        {
            id: "title",
            type: "label",
            caption: param.title,
            style: param.titleStyle || DEFAULT_TITLE_STYLE
        },
        {
            id: "amount",
            type: "label",
            caption: param.amount,
            style: param.amountStyle || DEFAULT_AMOUNT_STYLE
        },
        {
            id: "spinner",
            type: "image",
            src: param.spinnerImg,
            class: "image--spin colorize-r--white",
            style: param.spinnerStyle || DEFAULT_SPINNER_STYLE
        }
    ];

    if (param.showStatus) {
        ui.push({
            id: "status",
            type: "label",
            caption: param.initialStatus || DEFAULT_INITIAL_STATUS,
            style: param.statusStyle || DEFAULT_STATUS_STYLE
        });
    }
    return ui;
};

const populateContentWithDefaults = content => {
    const param = { ...content };

    if (!param.size)
        param.size = { ...DEFAULT_SIZE };

    if (!param.bodyStyle)
        param.bodyStyle = { ...DEFAULT_BODY_STYLE };

    if (!param.title)
        param.title = DEFAULT_TITLE;

    if (!param.amount)
        param.amount = DEFAULT_AMOUNT;

    if (!param.spinnerImg)
        param.spinnerImg = DEFAULT_SPINNER;

    param.ui = getDefaultUI(param);

    return param;
};

export const waiterPad = (popup, content = {}) => {
    const param = populateContentWithDefaults(content);

    const dialogRef = popup.open({
        size: param.size,
        bodyStyle: param.bodyStyle,
        noScroll: true,
        ui: param.ui,
        buttons: [
            {
                id: "btn_abort",
                caption: localize(GlobalCaption.FromBackEnd.Global_Abort),
                enabled: false,
                click: () => {
                    dialogRef.close(null);
                }
            }
        ]
    });

    dialogRef.updateAmount = amount => dialogRef.update("amount", "caption", FormatAs.decimal(amount));
    dialogRef.updateStatus = status => dialogRef.update("status", "caption", status);

    return dialogRef;
};
