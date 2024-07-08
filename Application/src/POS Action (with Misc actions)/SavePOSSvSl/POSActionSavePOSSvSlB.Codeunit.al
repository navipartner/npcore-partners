codeunit 6059851 "NPR POS Action: SavePOSSvSl B"
{
    Access = Internal;
    procedure SaveSaleAndStartNewSale(var POSSavedSaleEntry: Record "NPR POS Saved Sale Entry")
    var
        POSSale: Codeunit "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
    begin
        POSSession.GetSale(POSSale);

        SaveSale(POSSavedSaleEntry);

        POSSale.SelectViewForEndOfSale();
    end;

    procedure SaveSale(var POSSavedSaleEntry: Record "NPR POS Saved Sale Entry")
    var
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSCreateEntry: Codeunit "NPR POS Create Entry";
        POSSession: Codeunit "NPR POS Session";
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        CreateSavedSaleEntry(SalePOS, POSSavedSaleEntry);
        POSCreateEntry.InsertParkSaleEntry(SalePOS."Register No.", SalePOS."Salesperson Code");

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.DeleteAll();
        SalePOS.Delete();
        Commit();
    end;


    procedure CreateSavedSaleEntry(SalePOS: Record "NPR POS Sale"; var POSQuoteEntry: Record "NPR POS Saved Sale Entry")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        LineNo: Integer;
    begin
        OnBeforeSaveAsQuote(SalePOS);

        InsertPOSQuoteEntry(SalePOS, POSQuoteEntry);

        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        if SaleLinePOS.FindSet() then
            repeat
                InsertPOSQuoteLine(SaleLinePOS, POSQuoteEntry, LineNo);
                if SaleLinePOS."EFT Approved" or SaleLinePOS."From Selection" then begin
                    SaleLinePOS."EFT Approved" := false;
                    SaleLinePOS."From Selection" := false;
                    SaleLinePOS.Modify();
                end;
                UpdateNpRvSaleLine(SaleLinePOS);
                SaleLinePOS.Delete(true);
            until SaleLinePOS.Next() = 0;
    end;

    local procedure InsertPOSQuoteEntry(SalePOS: Record "NPR POS Sale"; var POSQuoteEntry: Record "NPR POS Saved Sale Entry")
    var
        POSQuoteMgt: Codeunit "NPR POS Saved Sale Mgt.";
        XmlDoc: XmlDocument;
        OutStr: OutStream;
    begin
        POSQuoteEntry.Init();
        POSQuoteEntry."Entry No." := 0;
        POSQuoteEntry."Created at" := CurrentDateTime;
        POSQuoteEntry."Register No." := SalePOS."Register No.";
        POSQuoteEntry."Sales Ticket No." := SalePOS."Sales Ticket No.";
        POSQuoteEntry."Salesperson Code" := SalePOS."Salesperson Code";
        POSQuoteEntry."Customer No." := SalePOS."Customer No.";
        POSQuoteEntry."Customer Price Group" := SalePOS."Customer Price Group";
        POSQuoteEntry."Customer Disc. Group" := SalePOS."Customer Disc. Group";
        POSQuoteEntry.Attention := SalePOS."Contact No.";
        POSQuoteEntry.Reference := SalePOS.Reference;
        POSQuoteEntry.SystemId := SalePOS.SystemId;
        POSQuoteMgt.POSSale2Xml(SalePOS, XmlDoc);
        POSQuoteEntry."POS Sales Data".CreateOutStream(OutStr, TEXTENCODING::UTF8);
        XmlDoc.WriteTo(OutStr);
        POSQuoteEntry.Insert(true, true);
    end;

    local procedure InsertPOSQuoteLine(SaleLinePOS: Record "NPR POS Sale Line"; POSQuoteEntry: Record "NPR POS Saved Sale Entry"; var LineNo: Integer)
    var
        POSQuoteLine: Record "NPR POS Saved Sale Line";
    begin
        LineNo += 10000;

        POSQuoteLine.Init();
        POSQuoteLine."Quote Entry No." := POSQuoteEntry."Entry No.";
        POSQuoteLine."Line No." := LineNo;
        POSQuoteLine."Sale Line No." := SaleLinePOS."Line No.";
        POSQuoteLine."Sale Date" := SaleLinePOS.Date;
        POSQuoteLine."Line Type" := SaleLinePOS."Line Type";
        POSQuoteLine."No." := SaleLinePOS."No.";
        POSQuoteLine."Variant Code" := SaleLinePOS."Variant Code";
        POSQuoteLine.Description := SaleLinePOS.Description;
        POSQuoteLine."Unit of Measure Code" := SaleLinePOS."Unit of Measure Code";
        POSQuoteLine.Quantity := SaleLinePOS.Quantity;
        POSQuoteLine."Price Includes VAT" := SaleLinePOS."Price Includes VAT";
        POSQuoteLine."Currency Code" := SaleLinePOS."Currency Code";
        POSQuoteLine."Unit Price" := SaleLinePOS."Unit Price";
        POSQuoteLine.Amount := SaleLinePOS.Amount;
        POSQuoteLine."Amount Including VAT" := SaleLinePOS."Amount Including VAT";
        POSQuoteLine."Customer Price Group" := SaleLinePOS."Customer Price Group";
        POSQuoteLine."Discount Type" := SaleLinePOS."Discount Type";
        POSQuoteLine."Discount %" := SaleLinePOS."Discount %";
        POSQuoteLine."Discount Amount" := SaleLinePOS."Discount Amount";
        POSQuoteLine."Discount Code" := SaleLinePOS."Discount Code";
#pragma warning disable AA0139
        POSQuoteLine."Discount Authorised by" := SaleLinePOS."Discount Authorised by";
#pragma warning restore AA0139
        POSQuoteLine."EFT Approved" := SaleLinePOS."EFT Approved";
        POSQuoteLine.SystemId := SaleLinePOS.SystemId;
        POSQuoteLine.Insert(true, true);
    end;

    local procedure UpdateNpRvSaleLine(SaleLinePOS: Record "NPR POS Sale Line")
    var
        NpRvSalesLine: Record "NPR NpRv Sales Line";
    begin
        NpRvSalesLine.SetCurrentKey("Retail ID", "Document Source", Type);
        NpRvSalesLine.SetRange("Retail ID", SaleLinePOS.SystemId);
        NpRvSalesLine.SetRange("Document Source", NpRvSalesLine."Document Source"::POS);

        if NpRvSalesLine.IsEmpty() then
            exit;

        NpRvSalesLine.FindFirst();
        NpRvSalesLine."Document Source" := NpRvSalesLine."Document Source"::"POS Quote";
        NpRvSalesLine.Modify();
    end;

    procedure PrintAfterSave(PrintTemplateCode: Code[20]; POSQuoteEntry: Record "NPR POS Saved Sale Entry")
    var
        RPTemplateHeader: Record "NPR RP Template Header";
        RPTemplateMgt: Codeunit "NPR RP Template Mgt.";
    begin
        if not RPTemplateHeader.Get(PrintTemplateCode) then
            exit;
        RPTemplateHeader.CalcFields("Table ID");
        if RPTemplateHeader."Table ID" <> DATABASE::"NPR POS Saved Sale Entry" then
            exit;

        POSQuoteEntry.SetRecFilter();
        RPTemplateMgt.PrintTemplate(RPTemplateHeader.Code, POSQuoteEntry, 0);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSaveAsQuote(var SalePOS: Record "NPR POS Sale")
    begin
    end;

}