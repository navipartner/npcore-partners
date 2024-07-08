codeunit 6184604 "NPR POS Action: BG SIS EJ Exp" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config");
    var
        ActionDescriptionLbl: Label 'This is a built-in action to manage exporting data from electronic journal.';
        ParamTypeCaptionLbl: Label 'Type';
        ParamTypeDescrLbl: Label 'Specifies the Type used.';
        ParamTypeOptionsCaptionLbl: Label 'D2D,T2T,EOD2EOD';
        ParamTypeOptionsLbl: Label 'D2D,T2T,EOD2EOD', Locked = true;
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescriptionLbl);
        WorkflowConfig.AddOptionParameter('Type', ParamTypeOptionsLbl, '', ParamTypeCaptionLbl, ParamTypeDescrLbl, ParamTypeOptionsCaptionLbl);
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
        POSActionBGSISEJExpB: Codeunit "NPR POS Action: BG SIS EJ ExpB";
        Type: Option D2D,T2T,EOD2EOD;
    begin
        Sale.GetCurrentSale(POSSale);
        Type := Context.GetIntegerParameter('Type');
        Response := POSActionBGSISEJExpB.PrepareHTTPRequest(Type, POSSale."Register No.");
    end;

    local procedure HandleResponse(Context: Codeunit "NPR POS JSON Helper")
    var
        POSActionBGSISEJExpB: Codeunit "NPR POS Action: BG SIS EJ ExpB";
        Response: JsonObject;
        ResponseText: Text;
    begin
        Response := Context.GetJsonObject('result');
        Response.WriteTo(ResponseText);
        POSActionBGSISEJExpB.HandleResponse(ResponseText);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionBGSISEJExp.js###
'let main=async({workflow:e,context:n})=>{let t=await e.respond("PrepareRequest");const s=await(await fetch(t.url,{method:"POST",headers:{"Content-Type":"application/json"},body:t.requestBody})).json();await e.respond("HandleResponse",{result:s})};'
        );
    end;
}
