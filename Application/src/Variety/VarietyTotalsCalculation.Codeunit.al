codeunit 6059781 "NPR Variety Totals Calculation"
{
    Access = Internal;

    EventSubscriberInstance = Manual;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Document Totals", 'OnAfterSalesCheckIfDocumentChanged', '', false, false)]
    local procedure SalesCheckifDocChanged(SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line"; var TotalsUpToDate: Boolean)
    begin
        TotalsUpToDate := false;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Document Totals", 'OnAfterPurchaseCheckIfDocumentChanged', '', false, false)]
    local procedure PurchaseCheckifDocChanged(PurchaseLine: Record "Purchase Line"; xPurchaseLine: Record "Purchase Line"; var TotalsUpToDate: Boolean)
    begin
        TotalsUpToDate := false;
    end;
}