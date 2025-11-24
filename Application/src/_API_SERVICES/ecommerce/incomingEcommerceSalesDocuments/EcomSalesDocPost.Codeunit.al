#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248657 "NPR Ecom Sales Doc Post"
{
    Access = Internal;
    TableNo = "NPR Ecom Sales Header";
    trigger OnRun()
    begin
        PostSalesOrder(Rec);
    end;

    local procedure SalesOrderPrepareVirtualItemsForPosting(EcomSalesHeader: Record "NPR Ecom Sales Header"; SalesHeader: Record "Sales Header")
    var
        EcomSalesLine: Record "NPR Ecom Sales Line";
        SalesLine: Record "Sales Line";
    begin
        if SalesHeader."Document Type" <> SalesHeader."Document Type"::Order then
            exit;


        EcomSalesLine.Reset();
        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        EcomSalesLine.SetFilter(Type, '%1', EcomSalesLine.Type::Voucher);
        if not EcomSalesLine.FindSet() then
            exit;

        repeat
            SalesLine.Reset();
            SalesLine.SetRange("Document Type", SalesHeader."Document Type");
            SalesLine.SetRange("Document No.", SalesHeader."No.");
            SalesLine.SetRange("NPR Inc Ecom Sales Line Id", EcomSalesLine.SystemId);
            if SalesLine.FindFirst() then begin
                SalesLine.Validate("Qty. to Ship", SalesLine."Outstanding Quantity");
                SalesLine.Modify(true);
            end
        until EcomSalesLine.Next() = 0;
    end;

    local procedure ResetPostingQuantityOnSalesOrders(SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.Reset();
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetFilter(Quantity, '<>%1', 0);
        if SalesLine.FindSet() then
            repeat
                SalesLine.Validate("Qty. to Ship", 0);
                SalesLine.Validate("Qty. to Invoice", 0);
                SalesLine.Modify(true);
            until SalesLine.Next() = 0;
    end;

    local procedure PostSalesOrder(var SalesHeader: Record "Sales Header") Success: Boolean
    var
        SalesPost: Codeunit "Sales-Post";
    begin
        if SalesHeader."Document Type" <> SalesHeader."Document Type"::Order then
            exit;

        SalesHeader.Ship := true;
        SalesHeader.Invoice := true;
        Commit();
        Clear(SalesPost);
        Success := SalesPost.Run(SalesHeader);
    end;

    local procedure PostSalesOrder(var EcomSalesHeader: Record "NPR Ecom Sales Header") Success: Boolean
    var
        SalesHeader: Record "Sales Header";
    begin
        EcomSalesHeader.ReadIsolation := EcomSalesHeader.ReadIsolation::UpdLock;
        EcomSalesHeader.Get(EcomSalesHeader.RecordId);

        if not EcomSalesHeader."Virtual Items Exist" then
            exit;

        if EcomSalesHeader."Document Type" <> EcomSalesHeader."Document Type"::Order then
            exit;

        SalesHeader.Reset();
        SalesHeader.SetRange("NPR Inc Ecom Sale Id", EcomSalesHeader.SystemId);
        SalesHeader.ReadIsolation := SalesHeader.ReadIsolation::UpdLock;
        if not SalesHeader.FindFirst() then
            exit;

        ResetPostingQuantityOnSalesOrders(SalesHeader);
        SalesOrderPrepareVirtualItemsForPosting(EcomSalesHeader, SalesHeader);
        PostSalesOrder(SalesHeader);

        Success := true;
    end;


}
#endif