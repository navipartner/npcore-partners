#if not BC17
codeunit 6184823 "NPR Spfy Order Lookup" implements "NPR Nc Import List ILookup"
{
    Access = Internal;

    var
        OrderMgt: Codeunit "NPR Spfy Order Mgt.";

    procedure RunLookupImportEntry(ImportEntry: Record "NPR Nc Import Entry")
    var
        SalesHeader: Record "Sales Header";
        TempSpfyRelatedDocument: Record "NPR Spfy Related Document" temporary;
        TempSalesInvHeader: Record "Sales Invoice Header" temporary;
        Order: JsonToken;
        NoRelatedDocsFoundErr: Label 'No related documents found for the line.';
    begin
        OrderMgt.LoadOrder(ImportEntry, Order);
        if OrderMgt.FindSalesOrder(ImportEntry."Store Code", Order, SalesHeader) then
            TempSpfyRelatedDocument.AddSalesHeader(SalesHeader);

        if OrderMgt.FindSalesInvoices(ImportEntry."Store Code", Order, TempSalesInvHeader) then
            if TempSalesInvHeader.FindSet() then
                repeat
                    TempSpfyRelatedDocument."Document Type" := TempSpfyRelatedDocument."Document Type"::"Posted Sales Invoice";
                    TempSpfyRelatedDocument."Document No." := TempSalesInvHeader."No.";
                    if not TempSpfyRelatedDocument.Find() then
                        TempSpfyRelatedDocument.Insert();
                until TempSalesInvHeader.Next() = 0;

        if TempSpfyRelatedDocument.IsEmpty() then
            Error(NoRelatedDocsFoundErr);
        Page.RunModal(0, TempSpfyRelatedDocument);
    end;
}
#endif