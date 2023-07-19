codeunit 6060083 "NPR POS Html Disp. Req"
{
    Access = Internal;

    procedure AppendMediaObject(var Context: JsonObject; POSUnit: Record "NPR POS Unit")
    var
        UnitDisplay: Record "NPR POS Unit Display";
        DisplayContent: Record "NPR Display Content";
        HtmlDisplay: Record "NPR POS HTML Disp. Prof.";
        DisplayContentLines: Record "NPR Display Content Lines";

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
        if (not UnitDisplay.Get(POSUnit."No.")) then begin
            UnitDisplay.Init();
            UnitDisplay."Screen No." := 0;
            UnitDisplay.POSUnit := POSUnit."No.";
            UnitDisplay.Insert();
        end;
        HtmlDisplay.Get(POSUnit."POS HTML Display Profile");
        DisplayContent.Get(HtmlDisplay."Display Content Code");

        Context.Add('WindowScreenNo', UnitDisplay."Screen No.");
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
        Context.Add('LocalMediaInfo', LocalMediaInfo);
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

    procedure GetReceiptContent(POSUnitCode: Code[10]; SalesTicket: Code[20]; Date: Date): JsonObject
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        GLSetup: Record "General Ledger Setup";
        POSunit: Record "NPR POS Unit";
        HtmlProfile: Record "NPR POS HTML Disp. Prof.";

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
        GLSetup.Get();
        SaleLinePOS.Reset();
        SaleLinePOS.SetRange("Register No.", POSUnitCode);
        SaleLinePOS.SetRange("Sales Ticket No.", SalesTicket);
        SaleLinePOS.SetRange(Date, Date);
        POSunit.Get(POSUnitCode);
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