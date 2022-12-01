codeunit 6059932 "NPR POS Pmt. Method Item Mgt."
{
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale Line", 'OnBeforeDeletePOSSaleLine', '', true, true)]
    local procedure CheckOnBeforeDeletePOSSaleLine(SaleLinePOS: Record "NPR POS Sale Line")
    begin
        if SaleLinePOS.IsTemporary() then
            exit;

        if SaleLinePOS."Line Type" = SaleLinePOS."Line Type"::Item then
            CheckIsDeletingPOSSaleLineAllowed(SaleLinePOS);
    end;

    local procedure CheckIsDeletingPOSSaleLineAllowed(POSSaleLine: Record "NPR POS Sale Line")
    var
        PaymentPOSSaleLine: Record "NPR POS Sale Line";
        CannotDeleteErr: Label '%1 for item %2 %3 cannot be deleted since it is restricted to payment type %4 that has already been used.', Comment = '%1 - POS Sale Line table caption, %2 - Item No. value, %3 - POS Sale Line Description value, %4 - POS Payment Method Code value';
    begin
        PaymentPOSSaleLine.SetRange("Register No.", POSSaleLine."Register No.");
        PaymentPOSSaleLine.SetRange("Sales Ticket No.", POSSaleLine."Sales Ticket No.");
        PaymentPOSSaleLine.SetRange("Line Type", PaymentPOSSaleLine."Line Type"::"POS Payment");
        if PaymentPOSSaleLine.IsEmpty() then
            exit;

        PaymentPOSSaleLine.FindSet();
        repeat
            if IsThisPOSPaymentMethodItem(PaymentPOSSaleLine."No.", POSSaleLine) then
                Error(CannotDeleteErr, POSSaleLine.TableCaption, POSSaleLine."No.", POSSaleLine.Description, PaymentPOSSaleLine."No.");
        until PaymentPOSSaleLine.Next() = 0;
    end;

    internal procedure IsThisPOSPaymentMethodItem(POSPaymentMethodCode: Code[20]; POSSaleLine: Record "NPR POS Sale Line"): Boolean
    var
        POSPaymentMethodItem: Record "NPR POS Payment Method Item";
    begin
        POSPaymentMethodItem.SetCurrentKey("POS Payment Method Code", Type, "No.");
        POSPaymentMethodItem.SetRange("POS Payment Method Code", POSPaymentMethodCode);
        if POSPaymentMethodItem.IsEmpty() then
            exit(false);

        POSPaymentMethodItem.SetRange(Type, POSPaymentMethodItem.Type::"Item Categories");
        POSPaymentMethodItem.SetRange("No.", POSSaleLine."Item Category Code");
        if not POSPaymentMethodItem.IsEmpty() then
            exit(true);

        POSPaymentMethodItem.SetRange(Type, POSPaymentMethodItem.Type::Item);
        POSPaymentMethodItem.SetRange("No.", POSSaleLine."No.");
        if not POSPaymentMethodItem.IsEmpty() then
            exit(true);

        exit(false);
    end;
}