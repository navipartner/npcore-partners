codeunit 6184729 "NPR POS Action: IT EJ Report B"
{
    Access = Internal;

    var
        ITPrinterMgt: Codeunit "NPR IT Printer Mgt.";

    internal procedure CreateHTTPRequestBody(Method: Option reportByDate,reportByNumber; Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale"; var Request: JsonObject)
    var
        ITPOSUnitMapping: Record "NPR IT POS Unit Mapping";
    begin
        ITPOSUnitMapping.Get(GetPOSUnitNo(Sale));
        ITPOSUnitMapping.TestField("Fiscal Printer IP Address");

        case Method of
            Method::reportByNumber:
                AddParametersToRequest(Request, ITPOSUnitMapping, ITPrinterMgt.CreatePrinterCommandRequestMessage(ITPrinterMgt.CreateDirectIOCommand('3098', ReportByRecNumberFormatData(Context))));
            Method::reportByDate:
                AddParametersToRequest(Request, ITPOSUnitMapping, ITPrinterMgt.CreatePrinterCommandRequestMessage(ITPrinterMgt.CreateDirectIOCommand('3099', ReportByDateFormatData(Context))));
        end;
    end;

    internal procedure HandleResponse(Context: Codeunit "NPR POS JSON Helper")
    var
        ResponseToken: JsonToken;
    begin
        ResponseToken := Context.GetJToken('result');

        ITPrinterMgt.ProcessFPrinterEJReportPrintResponse(ResponseToken);
    end;

    local procedure GetPOSUnitNo(Sale: Codeunit "NPR POS Sale"): Code[10]
    var
        POSSale: Record "NPR POS Sale";
    begin
        Sale.GetCurrentSale(POSSale);
        exit(POSSale."Register No.");
    end;

    local procedure AddParametersToRequest(var Request: JsonObject; ITPOSUnitMapping: Record "NPR IT POS Unit Mapping"; RequestMessage: Text)
    begin
        Request.Remove('requestBody');
        Request.Add('url', ITPrinterMgt.FormatHTTPRequestUrl(ITPOSUnitMapping."Fiscal Printer IP Address"));
        Request.Add('requestBody', RequestMessage);
    end;

    local procedure ReportByRecNumberFormatData(Context: Codeunit "NPR POS JSON Helper") DataValue: Text
    var
        ZReportDateInputToken: JsonToken;
        ReceiptNumberInput: Text;
        ReceiptNumberFromTo: List of [Text];
        FormatDataLbl: Label '01%1%2 %3 1', Locked = true, Comment = '%1 = Z Report Date, %2 = Receipt No. Start, %3 = Receipt No. End';
    begin
        ZReportDateInputToken := Context.GetJToken('zreportdate');
        ReceiptNumberInput := Context.GetString('receiptnumber');
        ReceiptNumberFromTo := ReceiptNumberInput.Split('-');
        DataValue := StrSubstNo(FormatDataLbl, Format(DT2Date(ZReportDateInputToken.AsValue().AsDateTime()), 6, '<Day,2><Month,2><Year,2>'), ReceiptNumberFromTo.Get(1).PadLeft(4, '0'), ReceiptNumberFromTo.Get(2).PadLeft(4, '0'));
        DataValue := DelChr(DataValue, '=', ' ');
    end;

    local procedure ReportByDateFormatData(Context: Codeunit "NPR POS JSON Helper"): Text
    var
        FormatDataLbl: Label '01%1%2', Locked = true, Comment = '%1 = Start Date, %2 = End Date';
        StartDateToken: JsonToken;
        EndDateToken: JsonToken;
    begin
        StartDateToken := Context.GetJToken('startdate');
        EndDateToken := Context.GetJToken('enddate');
        exit(StrSubstNo(FormatDataLbl, Format(DT2Date(StartDateToken.AsValue().AsDateTime()), 6, '<Day,2><Month,2><Year,2>'), Format(DT2Date(EndDateToken.AsValue().AsDateTime()), 6, '<Day,2><Month,2><Year,2>')));
    end;
}