codeunit 6184641 "NPR POS Action: BG SIS Cashier" implements "NPR IPOS Workflow"
{
    // NOTE: this codeunit is created as separated implementation of POS Workflow, since it is not possible to run the same Workflow twice with different parameters the same time
    // otherwise it would be combined with codeunit "NPR POS Action: BG SIS FP Mgt."
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config");
    var
        ActionDescriptionLbl: Label 'This is a built-in action to manage fiscal printer cashier methods.';
        ParamMethodCaptionLbl: Label 'Method';
        ParamMethodDescrLbl: Label 'Specifies the Method used.';
        ParamMethodOptionsCaptionLbl: Label 'Get Cashier Data,Is Cashier Set,Set Cashier,Delete Cashier,Try Set Cashier';
        ParamMethodOptionsLbl: Label 'getCashierData,isCashierSet,setCashier,deleteCashier,trySetCashier', Locked = true;
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescriptionLbl);
        WorkflowConfig.AddOptionParameter('Method', ParamMethodOptionsLbl, '', ParamMethodCaptionLbl, ParamMethodDescrLbl, ParamMethodOptionsCaptionLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup");
    begin
        case Step of
            'PrepareRequest':
                FrontEnd.WorkflowResponse(PrepareHTTPRequest(Context, Sale));
            'HandleResponse':
                HandleResponse(Context, Sale);
        end;
    end;

    local procedure PrepareHTTPRequest(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale") Response: JsonObject;
    var
        POSSale: Record "NPR POS Sale";
        POSActionBGSISCashierB: Codeunit "NPR POS Action: BG SISCashierB";
        Method: Option getCashierData,isCashierSet,setCashier,deleteCashier,trySetCashier;
    begin
        Sale.GetCurrentSale(POSSale);
        Method := Context.GetIntegerParameter('Method');
        Response := POSActionBGSISCashierB.PrepareHTTPRequest(Method, POSSale."Register No.", POSSale."Salesperson Code")
    end;

    local procedure HandleResponse(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale")
    var
        POSSale: Record "NPR POS Sale";
        POSActionBGSISCashierB: Codeunit "NPR POS Action: BG SISCashierB";
        Response: JsonObject;
        Method: Option getCashierData,isCashierSet,setCashier,deleteCashier,trySetCashier;
        ResponseText: Text;
    begin
        Sale.GetCurrentSale(POSSale);
        Response := Context.GetJsonObject('result');
        Response.WriteTo(ResponseText);
        Method := Context.GetIntegerParameter('Method');
        POSActionBGSISCashierB.HandleResponse(ResponseText, Method, POSSale."Salesperson Code");
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionBGSISCashier.js###
'let main=async({workflow:t,context:n})=>{let e=await t.respond("PrepareRequest");if(e.requestBody){const s=await(await fetch(e.url,{method:"POST",headers:{"Content-Type":"application/json"},body:e.requestBody})).json();await t.respond("HandleResponse",{result:s})}};'
        );
    end;
}
