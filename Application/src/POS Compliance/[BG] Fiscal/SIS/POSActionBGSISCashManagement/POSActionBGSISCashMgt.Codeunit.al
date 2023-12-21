codeunit 6184700 "NPR POS Action: BGSISCashMgt" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config");
    var
        ActionDescriptionLbl: Label 'This is a built-in action to manage cash in fiscal printer.';
        ParamDirectionCaptionLbl: Label 'Direction';
        ParamDirectionDescrLbl: Label 'Specifies the Direction used.';
        ParamDirectionOptionsCaptionLbl: Label 'In,Out';
        ParamDirectionOptionsLbl: Label 'In,Out', Locked = true;
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescriptionLbl);
        WorkflowConfig.AddOptionParameter('Direction', ParamDirectionOptionsLbl, '', ParamDirectionCaptionLbl, ParamDirectionDescrLbl, ParamDirectionOptionsCaptionLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup");
    begin
        case Step of
            'PrepareRequest':
                FrontEnd.WorkflowResponse(PrepareHTTPRequest(Context, Sale));
            'HandleResponse':
                HandleResponse(Context);
        end;
    end;

    local procedure PrepareHTTPRequest(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale") Response: JsonObject;
    var
        BGSISPOSUnitMapping: Record "NPR BG SIS POS Unit Mapping";
        POSSale: Record "NPR POS Sale";
        BGSISCommunicationMgt: Codeunit "NPR BG SIS Communication Mgt.";
        InputDialog: Page "NPR Input Dialog";
        AmountToHandle: Decimal;
        AmountToHandleLbl: Label 'Amount to Handle';
        AmountToHandleErr: Label 'Amount to Handle must be positive.';
        Direction: Option In,Out;
    begin
        Sale.GetCurrentSale(POSSale);
        BGSISPOSUnitMapping.Get(POSSale."Register No.");
        BGSISPOSUnitMapping.TestField("Fiscal Printer IP Address");

        Response.Add('url', 'http://' + BGSISPOSUnitMapping."Fiscal Printer IP Address");

        Direction := Context.GetIntegerParameter('Direction');

        InputDialog.SetInput(1, AmountToHandle, AmountToHandleLbl);
        InputDialog.RunModal();
        InputDialog.InputDecimal(1, AmountToHandle);

        if AmountToHandle <= 0 then
            Error(AmountToHandleErr);

        if Direction = Direction::Out then
            AmountToHandle := -AmountToHandle;

        Response.Add('requestBody', BGSISCommunicationMgt.CreateJSONBodyForCashHandling(POSSale."Register No.", POSSale."Salesperson Code", AmountToHandle));
    end;

    local procedure HandleResponse(Context: Codeunit "NPR POS JSON Helper")
    var
        BGSISCommunicationMgt: Codeunit "NPR BG SIS Communication Mgt.";
        Response: JsonObject;
        ResponseText: Text;
    begin
        Response := Context.GetJsonObject('result');
        Response.WriteTo(ResponseText);
        BGSISCommunicationMgt.ProcessCashHandlingResponse(ResponseText);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionBGSISPrFM.js###
'let main=async({workflow:e,context:n})=>{let t=await e.respond("PrepareRequest");const s=await(await fetch(t.url,{method:"POST",headers:{"Content-Type":"application/json"},body:t.requestBody})).json();await e.respond("HandleResponse",{result:s})};'
        );
    end;
}
