codeunit 6184643 "NPR POS Action: BG SIS Pr FM" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config");
    var
        ActionDescriptionLbl: Label 'This is a built-in action to manage printing report from fiscal memory.';
        ParamTypeCaptionLbl: Label 'Type';
        ParamTypeDescrLbl: Label 'Specifies the Type used.';
        ParamTypeOptionsCaptionLbl: Label 'FD2D,SD2D,FZ2Z,SZ2Z';
        ParamTypeOptionsLbl: Label 'FD2D,SD2D,FZ2Z,SZ2Z', Locked = true;
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
        BGSISPOSUnitMapping: Record "NPR BG SIS POS Unit Mapping";
        POSSale: Record "NPR POS Sale";
        BGSISCommunicationMgt: Codeunit "NPR BG SIS Communication Mgt.";
        InputDialog: Page "NPR Input Dialog";
        FromDate, ToDate : Date;
        FromZ, ToZ : Integer;
        AllDatesMustBeEnteredErr: Label 'All dates must be entered.';
        AllZReportsMustBeEnteredAndPositiveErr: Label 'All Z Reports must be entered and positive numbers.';
        FromDateLbl: Label 'From Date';
        FromZReportLbl: Label 'From Z Report';
        ToDateCannotBeBeforeFromDateErr: Label 'To Date cannot be before From Date.';
        ToDateLbl: Label 'To Date';
        ToZCannotBeSmallerFromZErr: Label 'To Z Report number cannot be smaller from From Z Report number.';
        ToZReportLbl: Label 'To Z Report';
        Type: Option FD2D,SD2D,FZ2Z,SZ2Z;
        FromAsText, ToAsText : Text;
    begin
        Sale.GetCurrentSale(POSSale);
        BGSISPOSUnitMapping.Get(POSSale."Register No.");
        BGSISPOSUnitMapping.TestField("Fiscal Printer IP Address");

        Response.Add('url', 'http://' + BGSISPOSUnitMapping."Fiscal Printer IP Address");

        Type := Context.GetIntegerParameter('Type');

        case Type of
            Type::FD2D, Type::SD2D:
                begin
                    InputDialog.SetInput(1, FromDate, FromDateLbl);
                    InputDialog.SetInput(2, ToDate, ToDateLbl);
                    InputDialog.RunModal();
                    InputDialog.InputDate(1, FromDate);
                    InputDialog.InputDate(2, ToDate);

                    if (FromDate = 0D) or (ToDate = 0D) then
                        Error(AllDatesMustBeEnteredErr);

                    if ToDate < FromDate then
                        Error(ToDateCannotBeBeforeFromDateErr);

                    FromAsText := Format(FromDate, 0, '<Day,2>/<Month,2>/<Year,2>');
                    ToAsText := Format(ToDate, 0, '<Day,2>/<Month,2>/<Year,2>');
                end;
            Type::FZ2Z, Type::SZ2Z:
                begin
                    InputDialog.SetInput(1, FromZ, FromZReportLbl);
                    InputDialog.SetInput(2, ToZ, ToZReportLbl);
                    InputDialog.RunModal();
                    InputDialog.InputInteger(1, FromZ);
                    InputDialog.InputInteger(2, ToZ);

                    if (FromZ < 1) or (ToZ < 1) then
                        Error(AllZReportsMustBeEnteredAndPositiveErr);

                    if ToZ < FromZ then
                        Error(ToZCannotBeSmallerFromZErr);

                    FromAsText := Format(FromZ);
                    ToAsText := Format(ToZ);
                end;
        end;

        Response.Add('requestBody', BGSISCommunicationMgt.CreateJSONBodyForPrintFromFiscalMemory(Type, FromAsText, ToAsText));
    end;

    local procedure HandleResponse(Context: Codeunit "NPR POS JSON Helper")
    var
        BGSISCommunicationMgt: Codeunit "NPR BG SIS Communication Mgt.";
        Response: JsonObject;
        ResponseText: Text;
    begin
        Response := Context.GetJsonObject('result');
        Response.WriteTo(ResponseText);
        BGSISCommunicationMgt.ProcessPrintReportFromFiscalMemoryResponse(ResponseText);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionBGSISPrFM.js###
'let main=async({workflow:e,context:n})=>{let t=await e.respond("PrepareRequest");const s=await(await fetch(t.url,{method:"POST",headers:{"Content-Type":"application/json"},body:t.requestBody})).json();await e.respond("HandleResponse",{result:s})};'
        );
    end;
}
