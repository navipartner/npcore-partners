codeunit 6150996 "NPR POS Action MScanFind Item" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'This built in function opens the Scandit Barcode Reader on the MPOS and searches for an item.';
        LblNoBarcodeFound: Label 'No barcode was found associated with the Sale Line.';
        Err_ScanditFailed: Label 'Error running the Scandit Barcode Reader';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddLabel('Err_ScanditFailed', Err_ScanditFailed);
        WorkflowConfig.AddLabel('LblNoBarcodeFound', LblNoBarcodeFound);
    end;

    procedure RunWorkflow(
        Step: Text;
        Context: codeunit "NPR POS JSON Helper";
        FrontEnd: codeunit "NPR POS Front End Management";
        Sale: codeunit "NPR POS Sale";
        SaleLine: codeunit "NPR POS Sale Line";
        PaymentLine: codeunit "NPR POS Payment Line";
        Setup: codeunit "NPR POS Setup");
    begin
        case Step of
            'GetScanditRequest':
                FrontEnd.WorkflowResponse(GetScanditRequest(SaleLine));
        end;
    end;

    #region GetScanditRequest
    local procedure GetScanditRequest(POSSaleLine: codeunit "NPR POS Sale Line"): JsonObject
    var
        ScanFindItemB: Codeunit "NPR POS Action MScanFind ItemB";
        BarcodeText: Text[50];
        Request: JsonObject;
    begin
        if ScanFindItemB.FindItemBarcodeFromSalesLine(POSSaleLine, BarcodeText) then begin
            Request.Add('foundbarcode', true);
            Request.Add('barcode', BarcodeText);
        end else begin
            Request.Add('foundbarcode', false);
        end;
        exit(Request);
    end;
    #endregion GetScanditRequest

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionMScanFindItem.js###
'let main=async({captions:e,workflow:t,popup:r})=>{let n=await t.respond("GetScanditRequest");if(n.foundbarcode){let a={RequestMethod:"SCANDITFINDITEM",BaseAddress:"",Endpoint:"",PrintJob:n.barcode,RequestType:"",ErrorCaption:e.Err_ScanditFailed};await t.run("MPOS_API",{context:{InvokeType:"ACTION",FunctionName:"SCANDITFINDITEM",FunctionArgument:a}})}else r.error(e.LblNoBarcodeFound)};'
        )
    end;
}
