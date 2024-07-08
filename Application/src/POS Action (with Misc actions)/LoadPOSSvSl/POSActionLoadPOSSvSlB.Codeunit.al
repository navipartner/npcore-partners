codeunit 6059852 "NPR POS Action: LoadPOSSvSl B"
{
    Access = Internal;
    local procedure DeletePOSSalesLines(SalePOS: Record "NPR POS Sale")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        if SaleLinePOS.FindFirst() then
            SaleLinePOS.DeleteAll(true);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeLoadFromPOSQuote(var SalePOS: Record "NPR POS Sale"; var POSQuoteEntry: Record "NPR POS Saved Sale Entry";
        var XmlDoc: XmlDocument)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterLoadFromQuote(POSQuoteEntry: Record "NPR POS Saved Sale Entry"; var SalePOS: Record "NPR POS Sale")
    begin
    end;

    procedure LoadFromQuote(var POSQuoteEntry: Record "NPR POS Saved Sale Entry"; var SalePOS: Record "NPR POS Sale"): Boolean
    var
        POSQuoteMgt: Codeunit "NPR POS Saved Sale Mgt.";
        XmlDoc: XmlDocument;
    begin
        POSQuoteEntry.SkipLineDeleteTrigger(true);

        if not POSQuoteMgt.LoadPOSSaleData(POSQuoteEntry, XmlDoc) then
            exit(false);

        OnBeforeLoadFromPOSQuote(SalePOS, POSQuoteEntry, XmlDoc);
        DeletePOSSalesLines(SalePOS);

        POSQuoteMgt.Xml2POSSale(XmlDoc, SalePOS);
        OnAfterLoadFromQuote(POSQuoteEntry, SalePOS);
        POSQuoteEntry.Delete(true);

        exit(true);
    end;

    procedure InsertParkedSale(var POSQuoteEntry: Record "NPR POS Saved Sale Entry"; var SalePOS: Record "NPR POS Sale")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        SalePOS2: Record "NPR POS Sale";
        POSStore: Record "NPR POS Store";
        POSCreateEntry: Codeunit "NPR POS Create Entry";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSession: Codeunit "NPR POS Session";
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS2);
        POSStore.Get(SalePOS2."POS Store Code");
        SalePOS."Location Code" := POSStore."Location Code";
        SalePOS.Validate("POS Store Code", SalePOS2."POS Store Code");
        SalePOS.Modify();

        POSSale.Refresh(SalePOS);

        POSSession.GetSaleLine(POSSaleLine);
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetFilter("Line Type", '<>%1', SaleLinePOS."Line Type"::"POS Payment");
        if not SaleLinePOS.IsEmpty then
            POSSaleLine.SetLast();

        POSCreateEntry.InsertParkedSaleRetrievalEntry(
          SalePOS."Register No.", SalePOS."Salesperson Code", POSQuoteEntry."Sales Ticket No.", SalePOS."Sales Ticket No.");

    end;
}