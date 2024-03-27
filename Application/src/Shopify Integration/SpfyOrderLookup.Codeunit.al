#if not BC17
codeunit 6184823 "NPR Spfy Order Lookup" implements "NPR Nc Import List ILookup"
{
    Access = Internal;

    var
        OrderMgt: Codeunit "NPR Spfy Order Mgt.";

    procedure RunLookupImportEntry(ImportEntry: Record "NPR Nc Import Entry")
    var
        SalesHeader: Record "Sales Header";
        TempSalesInvHeader: Record "Sales Invoice Header" temporary;
        Order: JsonToken;
        FirstInv: Text;
    begin
        OrderMgt.LoadOrder(ImportEntry, Order);
        if OrderMgt.FindSalesOrder(ImportEntry."Store Code", Order, SalesHeader) then begin
            Page.Run(Page::"Sales Order", SalesHeader);
            exit;
        end;

        if OrderMgt.FindSalesInvoices(ImportEntry."Store Code", Order, TempSalesInvHeader) then begin
            FirstInv := Format(TempSalesInvHeader);
            TempSalesInvHeader.FindLast();
            if FirstInv = Format(TempSalesInvHeader) then
                Page.Run(Page::"Posted Sales Invoice", TempSalesInvHeader)
            else
                Page.Run(Page::"Posted Sales Invoices", TempSalesInvHeader);

            exit;
        end;

        Error('');
    end;
}
#endif