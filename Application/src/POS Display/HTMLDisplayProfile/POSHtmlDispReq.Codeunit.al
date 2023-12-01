codeunit 6060083 "NPR POS Html Disp. Req"
{
    Access = Internal;

    local procedure GetPOSNo(): Code[10]
    var
        Session: Codeunit "NPR POS Session";
        Setup: Codeunit "NPR POS Setup";
    begin
        Session.GetSetup(Setup);
        exit(Setup.GetPOSUnitNo());
    end;

    procedure HtmlDisplayVersion(): Integer
    begin
        exit(1);
    end;

    local procedure GetScreenNo(): Integer
    var
        UnitDisplay: Record "NPR POS Unit Display";
    begin
        if (not UnitDisplay.Get(GetPOSNo())) then begin
            UnitDisplay.Init();
            UnitDisplay."Screen No." := 0;
            UnitDisplay.POSUnit := GetPOSNo();
            UnitDisplay.Insert();
        end;
        exit(UnitDisplay."Screen No.");
    end;

    procedure OpenRequest(var Request: JsonObject; DownloadMedia: Boolean)
    var
        PosUnit: Record "NPR POS Unit";
    begin
        Request.Add('DisplayAction', 'Open');
        Request.Add('Version', HtmlDisplayVersion());
        if (DownloadMedia) then begin
            PosUnit.Get(GetPOSNo());
            Request.Add('LocalMediaInfo', LocalMediaObject());
        end;
        Request.Add('WindowScreenNo', GetScreenNo());
    end;

    procedure CloseRequest(var Request: JsonObject)
    begin
        Request.Add('DisplayAction', 'Close');
        Request.Add('Version', HtmlDisplayVersion());
    end;

    procedure InputRequest(var Request: JsonObject; HtmlProf: Record "NPR POS HTML Disp. Prof.")
    var
        JsParam: JsonObject;
        JsParamTxt: Text;
    begin
        if (HtmlProf."CIO: Money Back"::None = HtmlProf."CIO: Money Back") then
            Error('Programming error: Cannot Get input with option ''None''');
        Request.Add('DisplayAction', 'SendJs');
        Request.Add('Version', HtmlDisplayVersion());
        JsParam.Add('JSAction', 'GetInput');
        JsParam.Add('InputType', Format(HtmlProf."CIO: Money Back"));
        JsParam.WriteTo(JsParamTxt);
        Request.Add('JsParameter', JsParamTxt);
    end;

    procedure UpdateReceiptRequest(var Request: JsonObject)
    var
        JsParam: JsonObject;
        PosUnit: Record "NPR POS Unit";
        HtmlProfile: Record "NPR POS HTML Disp. Prof.";
        JsParamTxt: Text;
    begin
        PosUnit.Get(GetPOSNo());
        HtmlProfile.Get(PosUnit."POS HTML Display Profile");
        Request.Add('DisplayAction', 'SendJs');
        Request.Add('Version', HtmlDisplayVersion());
        JsParam.Add('JSAction', 'UpdateReceipt');
        JsParam.Add('ReceiptContent', GetReceiptContent());
        JsParam.Add('Labels', GetLabels());
        JsParam.Add('ExVAT', HtmlProfile."Ex. VAT");
        JsParam.WriteTo(JsParamTxt);
        Request.Add('JsParameter', JsParamTxt);

    end;

    /// <summary>
    /// The use case for the current version of the HTML File is only Mobilepay, hence the naming conventions.
    /// In the future the following changes will be made:
    /// Provider --> Title
    /// Amount --> Message
    /// QrContent (Will remain the same)
    /// Command will be removed.JSAction should dictate the action made.
    /// </summary>

    procedure ToggleQRRequest(var Request: JsonObject; Open: Boolean; QrTitle: Text; QrMessage: Text; QrContent: Text)
    var
        JsParam: JsonObject;
        Command: Text;
        JsParamTxt: Text;
    begin
        Request.Add('DisplayAction', 'SendJs');
        Request.Add('Version', HtmlDisplayVersion());
        JsParam.Add('Provider', QrTitle);
        JsParam.Add('PaymentAmount', QrMessage);
        JsParam.Add('QrContent', QrContent);
        if (Open) then
            Command := 'Open'
        else
            Command := 'Close';
        JsParam.Add('Command', Command);
        JsParam.Add('JSAction', 'QRPaymentScan');
        JsParam.WriteTo(JsParamTxt);
        Request.Add('JsParameter', JsParamTxt);
    end;

    procedure LoadWebsiteRequest(var Request: JsonObject; Website: Text; JsExe: Text)
    begin
        Request.Add('DisplayAction', 'LoadWebsite');
        Request.Add('Version', HtmlDisplayVersion());
        Request.Add('Website', Website);
        Request.Add('JsScript', JsExe);
    end;

    procedure LoadProfileRequest(var Request: JsonObject)
    begin
        Request.Add('DisplayAction', 'LoadWebsite');
        Request.Add('Version', HtmlDisplayVersion());
        Request.Add('Website', '');
    end;

    procedure LocalMediaObject(): JsonObject
    var
        DisplayContent: Record "NPR Display Content";
        HtmlDisplay: Record "NPR POS HTML Disp. Prof.";
        DisplayContentLines: Record "NPR Display Content Lines";
        PosUnit: Record "NPR POS Unit";

        LocalMediaInfo: JsonObject;
        Images: JsonArray;
        Videos: JsonArray;
        Image: JsonObject;
        ImageExt: Text;
        ImageBase64Content: Text;
        Video: JsonObject;
        Base64Html: Text;
        Counter: Integer;
        InS: InStream;
        base64Convert: Codeunit "Base64 Convert";

    begin
        PosUnit.Get(GetPOSNo());
        HtmlDisplay.Get(POSUnit."POS HTML Display Profile");
        DisplayContent.Get(HtmlDisplay."Display Content Code");

        if (HtmlDisplay."Display Content Code" <> '') then begin
            DisplayContentLines.SetRange("Content Code", HtmlDisplay."Display Content Code");
            case DisplayContent.Type of
                DisplayContent.Type::Html:
                    begin
                        if DisplayContentLines.FindFirst() then
                            LocalMediaInfo.Add('WebsiteUrl', DisplayContentLines.Url);
                    end;
                DisplayContent.Type::Image:
                    begin
                        if (DisplayContentLines.FindSet()) then begin
                            Counter := 1;
                            repeat
                                GetImageContentAndExtension(DisplayContentLines, ImageBase64Content, ImageExt);
                                Image.Add('Name', Format(Counter) + '.' + ImageExt);
                                Image.Add('Base64Content', ImageBase64Content);
                                Images.Add(Image.Clone().AsObject());
                                Image.Remove('Name');
                                Image.Remove('Base64Content');
                                Counter += 1;
                            until DisplayContentLines.Next() = 0;
                            LocalMediaInfo.Add('Images', Images);
                        end;
                    end;
                DisplayContent.Type::Video:
                    begin
                        if (DisplayContentLines.FindSet()) then begin
                            Counter := 1;
                            repeat
                                Video.Add('Name', Format(Counter));
                                Video.Add('Url', DisplayContentLines.Url);
                                Videos.Add(Video.Clone().AsObject());
                                Video.Remove('Name');
                                Video.Remove('Url');
                                Counter += 1;
                            until DisplayContentLines.Next() = 0;
                            LocalMediaInfo.Add('Videos', Videos);
                        end;
                    end;
            end;
        end;

        if (HtmlDisplay."HTML Blob".HasValue() and HtmlDisplay.CalcFields("HTML Blob")) then begin
            HtmlDisplay."HTML Blob".CreateInStream(Ins, TextEncoding::UTF8);
            Base64Html := base64Convert.ToBase64(InS);
        end;
        LocalMediaInfo.Add('Base64Html', Base64Html);
        exit(LocalMediaInfo);
    end;

    procedure GetLabels(): JsonObject;
    var
        Lbls: JsonObject;

        lbl_Total: Label 'Total';
        lbl_PayTotal: Label 'Payment Total';
        lbl_TotalRemaining: Label 'Total Remaining';
        lbl_TotalExVat: Label 'Sub Total';
        lbl_TotalVat: Label 'Tax Total';
        lbl_TotalPayback: Label 'Total Change';

        lbl_Submit: Label 'Submit';
        lbl_Clear: Label 'Clear';
        lbl_PhoneNo: Label 'Phone Number';
    begin
        Lbls.Add('Total', lbl_Total);
        Lbls.Add('PaymentTotal', lbl_PayTotal);
        Lbls.Add('TotalRemaining', lbl_TotalRemaining);
        Lbls.Add('TotalExVat', lbl_TotalExVat);
        Lbls.Add('TotalVat', lbl_TotalVat);
        Lbls.Add('TotalPayback', lbl_TotalPayback);
        Lbls.Add('Submit', lbl_Submit);
        Lbls.Add('Clear', lbl_Clear);
        Lbls.Add('PhoneNo', lbl_PhoneNo);
        exit(Lbls);
    end;

    procedure GetReceiptContent(): JsonObject
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        GLSetup: Record "General Ledger Setup";
        POSunit: Record "NPR POS Unit";
        HtmlProfile: Record "NPR POS HTML Disp. Prof.";

        POSSession: Codeunit "NPR POS Session";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleRec: Record "NPR POS Sale";

        ReceiptContent: JsonObject;
        SaleLines: JsonArray;
        SaleLine: JsonObject;
        PayLines: JsonArray;
        PayLine: JsonObject;
        LineType: Enum "NPR POS Sale Line Type";

        TotalTAX: Decimal;
        TotalAmountExTax: Decimal;
        TotalAmountIncTax: Decimal;
        PaymentTotal: Decimal;
        PaybackIncTax: Decimal;
        PaybackExTax: Decimal;
        RemainingTotalIncTax: Decimal;
        RemainingTotalExTax: Decimal;
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(POSSaleRec);
        GLSetup.Get();
        SaleLinePOS.Reset();
        SaleLinePOS.SetRange("Register No.", GetPOSNo());
        SaleLinePOS.SetRange("Sales Ticket No.", POSSaleRec."Sales Ticket No.");
        SaleLinePOS.SetRange(Date, POSSaleRec.Date);
        POSunit.Get(GetPOSNo());
        HtmlProfile.Get(POSunit."POS HTML Display Profile");
        if (SaleLinePOS.FindSet()) then begin
            repeat
                if SaleLinePOS."No." <> '' then
                    case SaleLinePOS."Line Type" of
                        LineType::"POS Payment":
                            begin
                                PaymentTotal := PaymentTotal + SaleLinePOS."Amount Including VAT";
                                PayLine.Add('Description', SaleLinePOS.Description);
                                PayLine.Add('Amount', SaleLinePOS."Amount Including VAT");
                                PayLines.Add(PayLine.Clone().AsObject());
                                PayLine.Remove('Description');
                                PayLine.Remove('Amount');
                            end;
                        LineType::"BOM List",
                        LineType::"Customer Deposit",
                        LineType::"Issue Voucher",
                        LineType::Item:
                            begin
                                SaleLine.Add('Description', SaleLinePOS.Description);
                                if (HtmlProfile."Receipt Item Description" = HtmlProfile."Receipt Item Description"::"Item Description 2") then
                                    SaleLine.Replace('Description', SaleLinePOS."Description 2");
                                SaleLine.Add('AmountIncTax', SaleLinePOS."Amount Including VAT");
                                SaleLine.Add('AmountExTax', SaleLinePOS.Amount);
                                SaleLine.Add('Quantity', SaleLinePOS.Quantity);
                                SaleLine.Add('DiscountPercent', SaleLinePOS."Discount %");
                                SaleLines.Add(SaleLine.Clone().AsObject());
                                SaleLine.Remove('Description');
                                SaleLine.Remove('AmountIncTax');
                                SaleLine.Remove('AmountExTax');
                                SaleLine.Remove('Quantity');
                                SaleLine.Remove('DiscountPercent');
                                TotalTAX := TotalTAX + (SaleLinePOS."Amount Including VAT" - SaleLinePOS.Amount);
                                TotalAmountExTax := TotalAmountExTax + SaleLinePOS.Amount;
                                TotalAmountIncTax := TotalAmountExTax + TotalTAX;
                            end;
                    end;
            until (SaleLinePOS.Next() = 0)
        end;
        if (PaymentTotal > TotalAmountExTax) then begin
            PaybackExTax := Round((PaymentTotal - TotalAmountExTax) * -1, 0.01, '=');
        end else begin
            RemainingTotalExTax := TotalAmountExTax - PaymentTotal;
        end;
        if (PaymentTotal > TotalAmountIncTax) then begin
            PaybackIncTax := Round((PaymentTotal - TotalAmountIncTax) * -1, 0.01, '=');
        end else begin
            RemainingTotalIncTax := TotalAmountIncTax - PaymentTotal;
        end;
        ReceiptContent.Add('SaleLines', SaleLines);
        ReceiptContent.Add('PayLines', PayLines);
        ReceiptContent.Add('Currency', GLSetup.GetCurrencyCode(''));

        ReceiptContent.Add('TotalAmountExTax', TotalAmountExTax);
        ReceiptContent.Add('TotalTax', TotalTAX);
        ReceiptContent.Add('TotalAmountIncTax', TotalAmountIncTax);

        ReceiptContent.Add('PaymentTotal', PaymentTotal);
        ReceiptContent.Add('RemainingTotalIncTax', RemainingTotalIncTax);
        ReceiptContent.Add('RemainingTotalExTax', RemainingTotalExTax);
        ReceiptContent.Add('PaybackExTax', PaybackExTax);
        ReceiptContent.Add('PaybackIncTax', PaybackIncTax);
        exit(ReceiptContent);
    end;

    local procedure GetImageContentAndExtension(DisplayContentLines: Record "NPR Display Content Lines"; var Base64: Text; var Extension: Text)
    var
        InS: InStream;
        OutS: OutStream;
        base64Convert: Codeunit "Base64 Convert";
        TempBlob: Codeunit "Temp Blob";
        filenameindex: Integer;
        TenantMedia: Record "Tenant Media";
    begin
        if DisplayContentLines.Picture.HasValue() then begin
            TempBlob.CreateOutStream(OutS);
            DisplayContentLines.Picture.ExportStream(OutS);
            TempBlob.CreateInStream(InS);
            Base64 := base64Convert.ToBase64(InS);
            if (TenantMedia.Get(DisplayContentLines.Picture.MediaId())) then begin
                filenameindex := TenantMedia.Description.LastIndexOf('.') + 1;
                Extension := TenantMedia.Description.Substring(filenameindex);
            end;
        end;
    end;
}