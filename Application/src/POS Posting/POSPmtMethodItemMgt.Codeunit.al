codeunit 6059932 "NPR POS Pmt. Method Item Mgt."
{
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale Line", 'OnBeforeDeletePOSSaleLine', '', true, true)]
    local procedure CheckOnBeforeDeletePOSSaleLine(SaleLinePOS: Record "NPR POS Sale Line"; Synchronization: Boolean)
    begin
        if SaleLinePOS.IsTemporary() then
            exit;

        if (SaleLinePOS."Line Type" = SaleLinePOS."Line Type"::Item) and not Synchronization then
            CheckIsDeletingPOSSaleLineAllowed(SaleLinePOS);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Payment Line", 'OnBeforeDeleteLine', '', true, true)]
    local procedure CheckOnBeforeDeletePOSPaymentLine(SaleLinePOS: Record "NPR POS Sale Line")
    begin
        if SaleLinePOS.IsTemporary() then
            exit;

        CheckIsDeletingPOSPaymentLineVoucherAllowed(SaleLinePOS);
    end;
#IF NOT (BC17 or BC18)
    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnDeleteSalesLinesOnBeforeDeleteLine', '', false, false)]
    local procedure SalesHeaderOnDeleteSalesLinesOnBeforeDeleteLine(var SalesLine: Record "Sales Line")
    begin
        SalesLine.SetSkipPOSPaymentMethodItemCheck(true);
    end;
#ENDIF
    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnBeforeDeleteEvent', '', true, true)]
    local procedure SalesLineOnBeforeDelete(var Rec: Record "Sales Line")
    var
        MagentoPaymentLine: Record "NPR Magento Payment Line";
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        SkipPOSPaymentMethodItemCheck: Boolean;
        PaymentMethodCode: Code[10];
        CannotDeleteErr: Label '%1 for item %2 %3 cannot be deleted since it is restricted to payment type No: %4, that has already been used.', Comment = '%1 - Sale Line table caption, %2 - Item No. value, %3 - POS Sale Line Description value, %4 - Payment Line No. value';
    begin
        if Rec.IsTemporary() then
            exit;
        if Rec.Type <> Rec.Type::Item then
            exit;
#IF NOT (BC17 or BC18)
        SkipPOSPaymentMethodItemCheck := Rec.GetSkipPOSPaymentMethodItemCheck();
#ELSE
        SkipPOSPaymentMethodItemCheck := Rec.GetSuspendedStatusCheck();
#ENDIF
        if not SkipPOSPaymentMethodItemCheck then begin
            MagentoPaymentLine.SetLoadFields("No.");
            MagentoPaymentLine.SetRange("Document Table No.", Database::"Sales Header");
            MagentoPaymentLine.SetRange("Document Type", MagentoPaymentLine."Document Type"::Order);
            MagentoPaymentLine.SetRange("Document No.", Rec."Document No.");
            MagentoPaymentLine.SetRange("Payment Type", MagentoPaymentLine."Payment Type"::Voucher);
            MagentoPaymentLine.SetFilter(Amount, '>%1', 0);
            if MagentoPaymentLine.FindSet() then
                repeat
                    PaymentMethodCode := NpRvVoucherMgt.GetVoucherPaymentMethod(MagentoPaymentLine."No.");
                    if IsThisPOSPaymentMethodItem(PaymentMethodCode, Rec) then
                        Error(CannotDeleteErr, Rec.TableCaption, Rec."No.", Rec.Description, MagentoPaymentLine."No.");
                until MagentoPaymentLine.Next() = 0;
        end;
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

    local procedure CheckIsDeletingPOSPaymentLineVoucherAllowed(POSSaleLine: Record "NPR POS Sale Line")
    var
        OriginalPOSPaymentMethodItem: Record "NPR POS Payment Method Item";
        OriginalVoucherType: Record "NPR NpRv Voucher Type";
        OriginalVoucherSalesLine: Record "NPR NpRv Sales Line";
        ReturnVoucherSalesLine: Record "NPR NpRv Sales Line";
        POSPaymentMethod: Record "NPR POS Payment Method";
        Dummyguid: Guid;
        CannotDeleteErr: Label '%1 for voucher type %2 reference no. %3 cannot be deleted since it has been issued from voucher type %4 reference no. %5 which has an item filter. Please delete voucher type %6 reference no. %7 from the POS Sale and try again.', Comment = '%1 - POS Sale Line table caption, %2 - voucher value, %3 - POS Sale Line Description value, %4 - POS Payment Method Code value';
    begin
        if POSSaleLine."Line Type" <> POSSaleLine."Line Type"::"POS Payment" then
            exit;

        POSPaymentMethod.SetLoadFields(Code, "Processing Type");
        if not POSPaymentMethod.Get(POSSaleLine."No.") then
            exit;

        if POSPaymentMethod."Processing Type" <> POSPaymentMethod."Processing Type"::VOUCHER then
            exit;

        ReturnVoucherSalesLine.Reset();
        ReturnVoucherSalesLine.SetCurrentKey("Retail ID", "Document Source", Type);
        ReturnVoucherSalesLine.SetRange("Retail ID", POSSaleLine.SystemId);
        ReturnVoucherSalesLine.SetLoadFields(SystemId, "Voucher Type", "Reference No.", "Parent Id");
        if not ReturnVoucherSalesLine.FindFirst() then
            exit;

        if ReturnVoucherSalesLine."Parent Id" = Dummyguid then
            exit;

        OriginalVoucherSalesLine.SetLoadFields("Voucher Type", "Voucher No.", "Reference No.");
        if not OriginalVoucherSalesLine.Get(ReturnVoucherSalesLine."Parent Id") then
            exit;

        OriginalVoucherType.SetLoadFields(Code, "Payment Type");
        if not OriginalVoucherType.Get(OriginalVoucherSalesLine."Voucher Type") then
            exit;

        if OriginalVoucherType."Payment Type" = '' then
            exit;

        OriginalPOSPaymentMethodItem.Reset();
        OriginalPOSPaymentMethodItem.SetRange("POS Payment Method Code", OriginalVoucherType."Payment Type");
        if OriginalPOSPaymentMethodItem.IsEmpty then
            exit;


        Error(CannotDeleteErr,
              POSSaleLine.TableCaption,
              ReturnVoucherSalesLine."Voucher Type",
              ReturnVoucherSalesLine."Reference No.",
              OriginalVoucherSalesLine."Voucher Type",
              OriginalVoucherSalesLine."Reference No.",
              OriginalVoucherSalesLine."Voucher Type",
              OriginalVoucherSalesLine."Reference No.");
    end;

    internal procedure IsThisPOSPaymentMethodItem(POSPaymentMethodCode: Code[20]; POSSaleLine: Record "NPR POS Sale Line"): Boolean
    begin
        exit(IsThisPOSPaymentMethodItem(POSPaymentMethodCode, POSSaleLine."Item Category Code", POSSaleLine."No."))
    end;

    internal procedure IsThisPOSPaymentMethodItem(POSPaymentMethodCode: Code[20]; SalesLine: Record "Sales Line"): Boolean
    begin
        exit(IsThisPOSPaymentMethodItem(POSPaymentMethodCode, SalesLine."Item Category Code", SalesLine."No."))
    end;

    internal procedure IsThisPOSPaymentMethodItem(POSPaymentMethodCode: Code[20]; ItemCategoryCode: Code[20]; ItemNo: Code[20]): Boolean
    var
        POSPaymentMethodItem: Record "NPR POS Payment Method Item";
    begin
        POSPaymentMethodItem.SetCurrentKey("POS Payment Method Code", Type, "No.");
        POSPaymentMethodItem.SetRange("POS Payment Method Code", POSPaymentMethodCode);
        if POSPaymentMethodItem.IsEmpty() then
            exit(false);

        POSPaymentMethodItem.SetRange(Type, POSPaymentMethodItem.Type::"Item Categories");
        POSPaymentMethodItem.SetRange("No.", ItemCategoryCode);
        if not POSPaymentMethodItem.IsEmpty() then
            exit(true);

        POSPaymentMethodItem.SetRange(Type, POSPaymentMethodItem.Type::Item);
        POSPaymentMethodItem.SetRange("No.", ItemNo);
        if not POSPaymentMethodItem.IsEmpty() then
            exit(true);

        exit(false);
    end;

    internal procedure HasPOSPaymentMethodItemFilter(POSPaymentMethodCode: Code[10]) HasItemFilter: Boolean
    var
        POSPaymentMethodItem: Record "NPR POS Payment Method Item";
    begin
        POSPaymentMethodItem.Reset();
        POSPaymentMethodItem.SetRange("POS Payment Method Code", POSPaymentMethodCode);
        POSPaymentMethodItem.SetCurrentKey("POS Payment Method Code", Type, "No.");
        HasItemFilter := not POSPaymentMethodItem.IsEmpty;
    end;
}