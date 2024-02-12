codeunit 6184686 "NPR POS Action: BG SIS EJ ExpB"
{
    Access = Internal;

    internal procedure PrepareHTTPRequest(Type: Option D2D,T2T,EOD2EOD; POSUnitNo: Code[10]) Request: JsonObject;
    var
        BGSISPOSUnitMapping: Record "NPR BG SIS POS Unit Mapping";
        BGSISCommunicationMgt: Codeunit "NPR BG SIS Communication Mgt.";
        InputDialog: Page "NPR Input Dialog";
        FromDate, ToDate : Date;
        FromDateTime, ToDateTime : DateTime;
        FromGrandReceiptNo, ToGrandReceiptNo : Integer;
        FromZ, ToZ : Integer;
        AllDateAndTimesMustBeEnteredErr: Label 'All date and times must be entered.';
        AllGrandReceiptNumbersMustBeEnteredAndPositiveErr: Label 'All Grand Receipt numbers must be entered and positive numbers.';
        AllZReportsMustBeEnteredAndPositiveErr: Label 'All Z Reports must be entered and positive numbers.';
        FromDateLbl: Label 'From Date';
        FromGrandReceiptNoLbl: Label 'From Grand Receipt Number';
        FromTimeLbl: Label 'From Time';
        FromZReportLbl: Label 'From Z Report';
        ToDateLbl: Label 'To Date';
        ToDateTimeCannotBeBeforeFromDateTimeErr: Label 'To DateTime cannot be before From DateTime.';
        ToGrandReceiptNoLbl: Label 'To Grand Receipt Number';
        ToGrandReceiptNumberCannotBeSmallerFromGrandReceiptNumberErr: Label 'To Grand Receipt number cannot be smaller from From Grand Receipt number.';
        ToTimeLbl: Label 'To Time';
        ToZCannotBeSmallerFromZErr: Label 'To Z Report number cannot be smaller from From Z Report number.';
        ToZReportLbl: Label 'To Z Report';
        Param1, Param2 : Text;
        FromTime, ToTime : Time;
    begin
        BGSISPOSUnitMapping.Get(POSUnitNo);
        BGSISPOSUnitMapping.TestField("Fiscal Printer IP Address");

        Request.Add('url', 'http://' + BGSISPOSUnitMapping."Fiscal Printer IP Address");

        case Type of
            Type::D2D:
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
            Type::T2T:
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

                    Param1 := Format(FromGrandReceiptNo).PadLeft(10, '0');
                    Param2 := Format(ToGrandReceiptNo).PadLeft(10, '0');
                end;
            Type::EOD2EOD:
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

                    Param1 := Format(FromZ).PadLeft(5, '0');
                    Param2 := Format(ToZ).PadLeft(5, '0');
                end;
        end;

        Request.Add('requestBody', BGSISCommunicationMgt.CreateJSONBodyForExportDataFromElectronicJournal(Type, Param1, Param2));
    end;

    internal procedure HandleResponse(ResponseText: Text)
    var
        BGSISCommunicationMgt: Codeunit "NPR BG SIS Communication Mgt.";
    begin
        BGSISCommunicationMgt.ProcessExportDataFromElectronicJournalResponse(ResponseText);
    end;
}
