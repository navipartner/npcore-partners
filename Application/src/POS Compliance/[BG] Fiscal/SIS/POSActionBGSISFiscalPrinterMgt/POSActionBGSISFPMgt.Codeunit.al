codeunit 6184606 "NPR POS Action: BG SIS FP Mgt." implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config");
    var
        ActionDescriptionLbl: Label 'This is a built-in action to manage fiscal printer methods.';
        ParamMethodCaptionLbl: Label 'Method';
        ParamMethodDescrLbl: Label 'Specifies the Method used.';
        // TO-DO this will be finished in one of the future tasks
        // ParamMethodOptionsCaptionLbl: Label 'Get Mfc Info,Print Receipt,Print X Report,Print Z Report,Print Duplicate,Cash Handling,Print Last Not Fiscalized,Print Selected Not Fiscalized,Get Cash Balance,Get Receipt';
        // ParamMethodOptionsLbl: Label 'getMfcInfo,printReceipt,printXReport,printZReport,printDuplicate,cashHandling,printLastNotFiscalized,printSelectedNotFiscalized,getCashBalance,getReceipt', Locked = true;
        ParamMethodOptionsCaptionLbl: Label 'Get Mfc Info,Print Receipt,Print X Report,Print Z Report,Print Duplicate,Cash Handling,Print Last Not Fiscalized,Print Selected Not Fiscalized,Get Cash Balance';
        ParamMethodOptionsLbl: Label 'getMfcInfo,printReceipt,printXReport,printZReport,printDuplicate,cashHandling,printLastNotFiscalized,printSelectedNotFiscalized,getCashBalance', Locked = true;
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
        POSActionBGSISFPMgtB: Codeunit "NPR POS Action: BG SIS FP MgtB";
        SalesTicketNo: Code[20];
        CheckpointEntryNo: Integer;
        Method: Option getMfcInfo,printReceipt,printXReport,printZReport,printDuplicate,cashHandling,printLastNotFiscalized,printSelectedNotFiscalized,getCashBalance;
    begin
        Sale.GetCurrentSale(POSSale);
        Method := Context.GetIntegerParameter('Method');

        case Method of
            Method::printReceipt:
                SalesTicketNo := GetSalesTicketNo(Context);
            Method::cashHandling:
                CheckpointEntryNo := GetCheckpointEntryNo(Context);
        end;

        Response := POSActionBGSISFPMgtB.PrepareHTTPRequest(Method, POSSale."Register No.", SalesTicketNo, CheckpointEntryNo)
    end;

    local procedure HandleResponse(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale")
    var
        POSSale: Record "NPR POS Sale";
        POSActionBGSISFPMgtB: Codeunit "NPR POS Action: BG SIS FP MgtB";
        SalesTicketNo: Code[20];
        CheckpointEntryNo: Integer;
        Response: JsonObject;
        Method: Option getMfcInfo,printReceipt,printXReport,printZReport,printDuplicate,cashHandling,printLastNotFiscalized,printSelectedNotFiscalized,getCashBalance;
        ResponseText: Text;
    begin
        Sale.GetCurrentSale(POSSale);
        Response := Context.GetJsonObject('result');
        Method := Context.GetIntegerParameter('Method');

        case Method of
            Method::printReceipt:
                SalesTicketNo := GetSalesTicketNo(Context);
            Method::cashHandling:
                CheckpointEntryNo := GetCheckpointEntryNo(Context);
        end;

        Response.WriteTo(ResponseText);
        POSActionBGSISFPMgtB.HandleResponse(ResponseText, Method, POSSale."Register No.", SalesTicketNo, CheckpointEntryNo);
    end;

    local procedure GetSalesTicketNo(var Context: Codeunit "NPR POS JSON Helper") SalesTicketNo: Code[20];
    var
        CustomParameters: JsonObject;
        JsonToken: JsonToken;
    begin
        CustomParameters := Context.GetJsonObject('customParameters');
        CustomParameters.Get('salesTicketNo', JsonToken);
        SalesTicketNo := CopyStr(JsonToken.AsValue().AsCode(), 1, MaxStrLen(SalesTicketNo));
    end;

    local procedure GetCheckpointEntryNo(var Context: Codeunit "NPR POS JSON Helper") CheckpointEntryNo: Integer
    var
        TransferResult: JsonObject;
        JsonToken: JsonToken;
    begin
        TransferResult := Context.GetJsonObject('transferResult');
        TransferResult.Get('checkpointEntryNo', JsonToken);
        CheckpointEntryNo := JsonToken.AsValue().AsInteger();
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionBGSISFPMgt.js###
'let main=async({workflow:t,context:n})=>{let e=await t.respond("PrepareRequest");if(e.requestBody){const s=await(await fetch(e.url,{method:"POST",headers:{"Content-Type":"application/json"},body:e.requestBody})).json();await t.respond("HandleResponse",{result:s})}};'
        );
    end;
}
