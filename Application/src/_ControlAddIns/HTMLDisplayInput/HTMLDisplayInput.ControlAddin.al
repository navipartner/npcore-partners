controladdin "NPR HTML Display Input"
{
    Scripts = 'src/_ControlAddIns/HTMLDisplayInput/Scripts/HTMLDisplayInput.js';

    VerticalStretch = true;
    HorizontalStretch = true;

#if not BC17
    [Obsolete('Use SendInputDataAndLabel(Input: JsonObject; ShowControl: Boolean; ApproveLabel: Text; RedoLabel: Text; PhoneNo: Text) instead.', 'NPR23.0')]
#endif
    procedure SendInputData(Input: JsonObject; ShowControl: Boolean);
    procedure SendInputDataAndLabel(Input: JsonObject; ShowControl: Boolean; ApproveLabel: Text; RedoLabel: Text; PhoneNo: Text);
    event Ready();
    event OkInput();
    event RedoInput();
}
