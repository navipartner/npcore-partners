controladdin "NPR POS Customer Input Display"
{
    Scripts = 'src/_ControlAddIns/POSCustomerInputDisplay/Scripts/POSCustomerInputDisplay.js';

    VerticalStretch = true;
    HorizontalStretch = true;
    RequestedWidth = 300;
    RequestedHeight = 1000;

    procedure SendInputDataAndLabel(Input: JsonObject; ShowControl: Boolean; ApproveLabel: Text; RedoLabel: Text; PhoneNoLbl: Text; NoInputLbl: Text);
    procedure SendInputDataAndLabelV2(Input: JsonObject; ShowControl: Boolean; ApproveLabel: Text; RedoLabel: Text; PhoneNoLbl: Text; NoInputLbl: Text);
    event Ready();
    event OkInput();
    event RedoInput();
}
