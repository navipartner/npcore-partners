codeunit 6248250 "NPR KSA Audit Mgt."
{
    Access = Internal;

    #region KSA Audit Mgt. - Audit Handler

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Audit Log Mgt.", 'OnLookupAuditHandler', '', true, true)]
    local procedure OnLookupAuditHandler(var tmpRetailList: Record "NPR Retail List")
    begin
        AddKSAAuditHandler(tmpRetailList);
    end;

    local procedure AddKSAAuditHandler(var tmpRetailList: Record "NPR Retail List")
    begin
        tmpRetailList.Number += 1;
        tmpRetailList.Choice := CopyStr(HandlerCode(), 1, MaxStrLen(tmpRetailList.Choice));
        tmpRetailList.Insert();
    end;

    local procedure IsKSAAuditEnabled(POSAuditProfileCode: Code[20]): Boolean
    var
        POSAuditProfile: Record "NPR POS Audit Profile";
    begin
        if not POSAuditProfile.Get(POSAuditProfileCode) then
            exit(false);
        if POSAuditProfile."Audit Handler" = HandlerCode() then
            exit(true);
    end;

    internal procedure HandlerCode(): Text
    var
        HandlerCodeTxt: Label 'K_SAUDI_ARABIA', Locked = true, MaxLength = 20;
    begin
        exit(HandlerCodeTxt);
    end;

    #endregion KSA Audit Mgt. - Audit Handler

    #region KSA Audit Mgt. - Sale and Return in Same Transaction

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale", 'OnBeforeEndSale', '', false, false)]
    local procedure HandleOnBeforeEndSale(var Sender: Codeunit "NPR POS Sale"; SaleHeader: Record "NPR POS Sale");
    var
        POSUnit: Record "NPR POS Unit";
    begin
        if not POSUnit.Get(SaleHeader."Register No.") then
            exit;

        if not IsKSAAuditEnabled(POSUnit."POS Audit Profile") then
            exit;

        CheckSalesAndReturnsInSameTransaction(SaleHeader, POSUnit."POS Audit Profile");
    end;

    local procedure CheckSalesAndReturnsInSameTransaction(SaleHeader: Record "NPR POS Sale"; POSAuditProfileCode: Code[20])
    var
        POSAuditProfile: Record "NPR POS Audit Profile";
        POSSaleLine: Record "NPR POS Sale Line";
        SalesAndReturnsNotAllowedInSameTransactionErr: Label 'It is not allowed to sell and return item(s) in same transaction.';
    begin
        POSAuditProfile.Get(POSAuditProfileCode);
        if POSAuditProfile.AllowSalesAndReturnInSameTrans then
            exit;

        POSSaleLine.SetCurrentKey("Register No.", "Sales Ticket No.", "Line Type");
        POSSaleLine.SetRange("Register No.", SaleHeader."Register No.");
        POSSaleLine.SetRange("Sales Ticket No.", SaleHeader."Sales Ticket No.");
        POSSaleLine.SetRange("Line Type", POSSaleLine."Line Type"::Item);
        POSSaleLine.SetFilter(Quantity, '>0');
        if POSSaleLine.IsEmpty() then
            exit;

        POSSaleLine.SetFilter(Quantity, '<0');
        if POSSaleLine.IsEmpty() then
            exit;

        Error(SalesAndReturnsNotAllowedInSameTransactionErr);
    end;

    #endregion KSA Audit Mgt. - Sale and Return in Same Transaction
}