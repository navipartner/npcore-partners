codeunit 6184682 "NPR POS Action: BG SIS Pr FM B"
{
    Access = Internal;

    internal procedure PrepareHTTPRequest(Type: Option FD2D,SD2D,FZ2Z,SZ2Z; POSUnitNo: Code[10]) Request: JsonObject;
    var
        BGSISPOSUnitMapping: Record "NPR BG SIS POS Unit Mapping";
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
        FromAsText, ToAsText : Text;
    begin
        BGSISPOSUnitMapping.Get(POSUnitNo);
        BGSISPOSUnitMapping.TestField("Fiscal Printer IP Address");

        Request.Add('url', 'http://' + BGSISPOSUnitMapping."Fiscal Printer IP Address");

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

        Request.Add('requestBody', BGSISCommunicationMgt.CreateJSONBodyForPrintFromFiscalMemory(Type, FromAsText, ToAsText));
    end;

    internal procedure HandleResponse(ResponseText: Text)
    var
        BGSISCommunicationMgt: Codeunit "NPR BG SIS Communication Mgt.";
    begin
        BGSISCommunicationMgt.ProcessPrintReportFromFiscalMemoryResponse(ResponseText);
    end;
}
