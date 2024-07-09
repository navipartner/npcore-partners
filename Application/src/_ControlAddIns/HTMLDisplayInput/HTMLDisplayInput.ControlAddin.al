controladdin "NPR HTML Display Input"
{
    Scripts = 'src/_ControlAddIns/HTMLDisplayInput/Scripts/HTMLDisplayInput.js';

    VerticalStretch = true;
    HorizontalStretch = true;

#if not BC17
    [Obsolete('Use SendInputDataAndLabelV2(Input: JsonObject; ShowControl: Boolean; ApproveLabel: Text; RedoLabel: Text; PhoneNo: Text) instead.', '2023-06-28')]
#endif
    procedure SendInputData(Input: JsonObject; ShowControl: Boolean);
#if not BC17
    [Obsolete('Use SendInputDataAndLabelV2(Input: JsonObject; ShowControl: Boolean; ApproveLabel: Text; RedoLabel: Text; PhoneNo: Text; NoInputLbl: Text) instead.', '2024-04-28')]
#endif
    procedure SendInputDataAndLabel(Input: JsonObject; ShowControl: Boolean; ApproveLabel: Text; RedoLabel: Text; PhoneNoLbl: Text);
#if not BC17
    [Obsolete('Use SendInputDataAndLabelV2(Input: JsonObject; ShowControl: Boolean; ApproveLabel: Text; RedoLabel: Text; PhoneNo: Text; NoInputLbl: Text) instead.', '2024-04-28')]
#endif
    procedure SendInputDataAndLabel(Input: JsonObject; ShowControl: Boolean; ApproveLabel: Text; RedoLabel: Text; PhoneNoLbl: Text; NoInputLbl: Text);
    procedure SendInputDataAndLabelV2(Input: JsonObject; ShowControl: Boolean; ApproveLabel: Text; RedoLabel: Text; PhoneNoLbl: Text; NoInputLbl: Text);
    event Ready();
    event OkInput();
    event RedoInput();
}
