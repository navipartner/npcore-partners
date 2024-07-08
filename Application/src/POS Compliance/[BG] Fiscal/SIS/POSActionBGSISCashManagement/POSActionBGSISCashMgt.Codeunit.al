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
        POSSale: Record "NPR POS Sale";
        POSActionBGSISCashMgtB: Codeunit "NPR POS Action: BGSISCashMgt B";
        Direction: Option In,Out;
    begin
        Sale.GetCurrentSale(POSSale);
        Direction := Context.GetIntegerParameter('Direction');
        Response := POSActionBGSISCashMgtB.PrepareHTTPRequest(Direction, POSSale."Register No.", POSSale."Salesperson Code")
    end;

    local procedure HandleResponse(Context: Codeunit "NPR POS JSON Helper")
    var
        POSActionBGSISCashMgtB: Codeunit "NPR POS Action: BGSISCashMgt B";
        Response: JsonObject;
        ResponseText: Text;
    begin
        Response := Context.GetJsonObject('result');
        Response.WriteTo(ResponseText);
        POSActionBGSISCashMgtB.HandleResponse(ResponseText);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionBGSISPrFM.js###
'let main=async({workflow:e,context:n})=>{let t=await e.respond("PrepareRequest");const s=await(await fetch(t.url,{method:"POST",headers:{"Content-Type":"application/json"},body:t.requestBody})).json();await e.respond("HandleResponse",{result:s})};'
        );
    end;
}
