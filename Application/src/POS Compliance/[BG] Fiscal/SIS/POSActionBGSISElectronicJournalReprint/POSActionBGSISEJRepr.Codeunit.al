codeunit 6184609 "NPR POS Action: BG SIS EJ Repr" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config");
    var
        ActionDescriptionLbl: Label 'This is a built-in action to manage reprinting from electronic journal.';
        ParamTypeCaptionLbl: Label 'Type';
        ParamTypeDescrLbl: Label 'Specifies the Type used.';
        ParamTypeOptionsCaptionLbl: Label 'EOD,T2TEOD,T2TDATE';
        ParamTypeOptionsLbl: Label 'EOD,T2TEOD,T2TDATE', Locked = true;
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
        FromDateTime, ToDateTime : DateTime;
        FromGrandReceiptNo, ToGrandReceiptNo : Integer;
        FromZ: Integer;
        AllDateAndTimesMustBeEnteredErr: Label 'All date and times must be entered.';
        AllGrandReceiptNumbersMustBeEnteredAndPositiveErr: Label 'All Grand Receipt numbers must be entered and positive numbers.';
        FromDateLbl: Label 'From Date';
        FromGrandReceiptNoLbl: Label 'From Grand Receipt Number';
        FromTimeLbl: Label 'From Time';
        FromZReportLbl: Label 'From Z Report';
        ToDateLbl: Label 'To Date';
        ToDateTimeCannotBeBeforeFromDateTimeErr: Label 'To DateTime cannot be before From DateTime.';
        ToGrandReceiptNoLbl: Label 'To Grand Receipt Number';
        ToGrandReceiptNumberCannotBeSmallerFromGrandReceiptNumberErr: Label 'To Grand Receipt number cannot be smaller from From Grand Receipt number.';
        ToTimeLbl: Label 'To Time';
        ZMustBeEnteredAndPositiveErr: Label 'Z Report must be entered and positive number.';
        Type: Option EOD,T2TEOD,T2TDATE;
        Param1, Param2, Param3, Param4 : Text;
        FromTime, ToTime : Time;
    begin
        Sale.GetCurrentSale(POSSale);
        BGSISPOSUnitMapping.Get(POSSale."Register No.");
        BGSISPOSUnitMapping.TestField("Fiscal Printer IP Address");

        Response.Add('url', 'http://' + BGSISPOSUnitMapping."Fiscal Printer IP Address");

        Type := Context.GetIntegerParameter('Type');

        case Type of
            Type::EOD:
                begin
                    InputDialog.SetInput(1, FromZ, FromZReportLbl);
                    InputDialog.RunModal();
                    InputDialog.InputInteger(1, FromZ);

                    if FromZ < 1 then
                        Error(ZMustBeEnteredAndPositiveErr);

                    Param1 := Format(FromZ).PadLeft(5, '0');
                end;
            Type::T2TEOD:
                begin
                    InputDialog.SetInput(1, FromGrandReceiptNo, FromGrandReceiptNoLbl);
                    InputDialog.SetInput(2, ToGrandReceiptNo, ToGrandReceiptNoLbl);
                    InputDialog.RunModal();
                    InputDialog.InputInteger(1, FromGrandReceiptNo);
                    InputDialog.InputInteger(2, ToGrandReceiptNo);

                    if (FromGrandReceiptNo < 1) or (ToGrandReceiptNo < 1) then
                        Error(AllGrandReceiptNumbersMustBeEnteredAndPositiveErr);

                    if ToGrandReceiptNo < FromGrandReceiptNo then
                        Error(ToGrandReceiptNumberCannotBeSmallerFromGrandReceiptNumberErr);

                    Param1 := Format(-1); // directive from SIS is to always use -1
                    Param2 := Format(FromGrandReceiptNo).PadLeft(10, '0');
                    Param3 := Param1;
                    Param4 := Format(ToGrandReceiptNo).PadLeft(10, '0');
                end;
            Type::T2TDATE:
                begin
                    InputDialog.SetInput(1, FromDate, FromDateLbl);
                    InputDialog.SetInput(2, FromTime, FromTimeLbl);
                    InputDialog.SetInput(3, ToDate, ToDateLbl);
                    InputDialog.SetInput(4, ToTime, ToTimeLbl);
                    InputDialog.RunModal();
                    InputDialog.InputDate(1, FromDate);
                    InputDialog.InputTime(2, FromTime);
                    InputDialog.InputDate(3, ToDate);
                    InputDialog.InputTime(4, ToTime);

                    if (FromDate = 0D) or (FromTime = 0T) or (ToDate = 0D) or (ToTime = 0T) then
                        Error(AllDateAndTimesMustBeEnteredErr);

                    FromDateTime := CreateDateTime(FromDate, FromTime);
                    ToDateTime := CreateDateTime(ToDate, ToTime);

                    if ToDateTime < FromDateTime then
                        Error(ToDateTimeCannotBeBeforeFromDateTimeErr);

                    Param1 := Format(FromDateTime, 0, '<Day,2>/<Month,2>/<Year,2>;<Hours24,2>:<Minutes,2>:<Seconds,2>');
                    Param2 := Format(ToDateTime, 0, '<Day,2>/<Month,2>/<Year,2>;<Hours24,2>:<Minutes,2>:<Seconds,2>');
                end;
        end;

        Response.Add('requestBody', BGSISCommunicationMgt.CreateJSONBodyForReprintFromElectronicJournal(Type, Param1, Param2, Param3, Param4));
    end;

    local procedure HandleResponse(Context: Codeunit "NPR POS JSON Helper")
    var
        BGSISCommunicationMgt: Codeunit "NPR BG SIS Communication Mgt.";
        Response: JsonObject;
        ResponseText: Text;
    begin
        Response := Context.GetJsonObject('result');
        Response.WriteTo(ResponseText);
        BGSISCommunicationMgt.ProcessReprintFromElectronicJournalResponse(ResponseText);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionBGSISEJRepr.js###
'let main=async({workflow:e,context:n})=>{let t=await e.respond("PrepareRequest");const s=await(await fetch(t.url,{method:"POST",headers:{"Content-Type":"application/json"},body:t.requestBody})).json();await e.respond("HandleResponse",{result:s})};'
        );
    end;
}
