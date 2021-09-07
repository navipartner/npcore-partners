codeunit 6014688 "NPR APIV1 - POS Sale Mgmt."
{

    var

        IDShouldBeSpecifiedErr: Label 'You must specify an Id to get the POS Sale.';
        POSSaleNotFoundErr: Label 'POS Sale record with System Id ''%1'' not exist.';
        POSSalesIDNotSpecifiedErr: Label 'You must specify a POS Sale Id to get the lines.';
        POSSalesLineItemVariantIsRequired: Label 'You must specify a variantCode for Item No. ''%1''';
        PaymentTypeNotFound: Label '%1 %2 for POS unit %3 was not found.';

        TransactionNotBalancedErr: Label 'Transaction is not balanced. Difference: %1.';

    procedure UpdatePOSSale(var TempPOSSaleBuff: Record "NPR POS Sales API Buffer"; POSSale: Codeunit "NPR POS Sale")
    var
        POSSaleRec: Record "NPR POS Sale";
    begin
        POSSale.GetCurrentSale(POSSaleRec);

        POSSaleRec.Validate(Reference, TempPOSSaleBuff.Reference);

        IF TempPOSSaleBuff."Customer No." <> '' then begin
            POSSaleRec."Customer Type" := TempPOSSaleBuff."Customer Type";
            POSSaleRec.Validate("Customer No.", TempPOSSaleBuff."Customer No.");
        end;

        POSSaleRec.Modify(true);
        POSSale.RefreshCurrent();

        TempPOSSaleBuff.TransferFields(POSSaleRec); //copy data back for the api response
        TempPOSSaleBuff."POS Sale System Id" := POSSaleRec.SystemId;

    end;

    procedure InsertPOSSaleLine(var TempPOSSaleLineBuff: Record "NPR POS Sales Line API Buffer"; POSSaleLine: Codeunit "NPR POS Sale Line"; SaleBuffer: Record "NPR POS Sales API Buffer"; PresetLineNo: Boolean)
    var
        POSSaleLineRec: Record "NPR POS Sale Line";
    begin
        // create Real Sales Lines from Temporary
        POSSaleLineRec.TransferFields(TempPOSSaleLineBuff);

        CheckPOSSalesLineRecItemBeforeInsert(POSSaleLineRec);

        POSSaleLine.SetUsePresetLineNo(PresetLineNo);

        IF (TempPOSSaleLineBuff."Discount %" > 0) OR (TempPOSSaleLineBuff."Discount Amount" > 0) then begin
            POSSaleLineRec."Allow Line Discount" := true;
            POSSaleLineRec.SetSkipCalcDiscount(true);
            POSSaleLine.InsertLine(POSSaleLineRec, true);
        end Else
            POSSaleLine.InsertLine(POSSaleLineRec, false);

        TempPOSSaleLineBuff.TransferFields(POSSaleLineRec); //copy data back for the api response
        TempPOSSaleLineBuff."POS Sale Line System Id" := POSSaleLineRec.SystemId;
        TempPOSSaleLineBuff."POS Sale System Id" := SaleBuffer."POS Sale System Id";
    end;

    procedure InsertPOSPaymentLine(var TempPOSSaleLineBuff: Record "NPR POS Sales Line API Buffer"; POSPaymentLine: Codeunit "NPR POS Payment Line"; SaleBuffer: Record "NPR POS Sales API Buffer"; PresetLineNo: Boolean)
    var
        POSPaymentLineRec: Record "NPR POS Sale Line";
        POSPaymentMethod: Record "NPR POS Payment Method";
        PaymentMethodCode: Code[20];
    begin
        // create Real Payment Line from Temporary
        POSPaymentLineRec.TransferFields(TempPOSSaleLineBuff);
        POSPaymentLineRec.Date := SaleBuffer.Date;

        CheckPOSSalesLineRecPaymentBeforeInsert(POSPaymentLineRec);

        POSPaymentLineRec."Register No." := SaleBuffer."Register No.";
        POSPaymentLineRec."Sales Ticket No." := SaleBuffer."Sales Ticket No.";

        PaymentMethodCode := POSPaymentLineRec."No.";
        IF NOT POSPaymentMethod.Get(PaymentMethodCode) then
            Error(PaymentTypeNotFound, POSPaymentMethod.TableCaption, PaymentMethodCode, SaleBuffer."Register No.");

        POSPaymentLine.SetUsePresetLineNo(PresetLineNo);
        CaptureAPIPayment(POSPaymentLineRec.Amount, POSPaymentLine, POSPaymentLineRec, POSPaymentMethod);

        TempPOSSaleLineBuff.TransferFields(POSPaymentLineRec); //copy data back for the api response
        TempPOSSaleLineBuff."POS Sale Line System Id" := POSPaymentLineRec.SystemId;
        TempPOSSaleLineBuff."POS Sale System Id" := SaleBuffer."POS Sale System Id";
    end;

    local procedure CaptureAPIPayment(AmountToCaptureLCY: Decimal; POSPaymentLine: Codeunit "NPR POS Payment Line"; var POSLine: Record "NPR POS Sale Line"; POSPaymentMethod: Record "NPR POS Payment Method"): Boolean
    var
        AmountToCapture: Decimal;
    begin
        AmountToCapture := AmountToCaptureLCY;

        if AmountToCaptureLCY = 0 then
            exit(true);

        POSPaymentLine.ValidateAmountBeforePayment(POSPaymentMethod, AmountToCaptureLCY);

        if (POSPaymentMethod."Fixed Rate" <> 0) then begin
            POSLine."Amount Including VAT" := 0;
            POSPaymentLine.InsertPaymentLine(POSLine, AmountToCapture);
        end else begin
            POSLine."Amount Including VAT" := AmountToCaptureLCY;
            POSPaymentLine.InsertPaymentLine(POSLine, 0);
        end;
        POSPaymentLine.GetCurrentPaymentLine(POSLine);

        exit(true);
    end;

    procedure LoadPOSSale(var TempPOSSaleBuff: Record "NPR POS Sales API Buffer"; IdFilter: Text)
    var
        POSSaleRec: Record "NPR POS Sale";
        SysId: Guid;
    begin
        if (IdFilter = '') then
            Error(IDShouldBeSpecifiedErr);

        Evaluate(SysId, IdFilter);
        IF POSSaleRec.GetBySystemId(SysId) then begin
            TempPOSSaleBuff.TransferFields(POSSaleRec);
            TempPOSSaleBuff."POS Sale System Id" := SysId;
            TempPOSSaleBuff.Insert();
        end else
            Error(POSSaleNotFoundErr, SysId);
    end;

    procedure GetPOSSalesIdFilterFromPOSSalesLineSystemId(POSSalesLineSysId: Guid): Text
    var
        POSSalesLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
    begin
        if not POSSalesLine.GetBySystemId(POSSalesLineSysId) then
            exit(' ');

        POSSale.Get(POSSalesLine."Register No.", POSSalesLine."Sales Ticket No.");
        exit(Format(POSSale.SystemId));
    end;

    procedure LoadPOSSaleLines(var TempPOSSaleLineBuff: Record "NPR POS Sales Line API Buffer"; POSSaleIdFilter: Text)
    var
        POSSaleRec: Record "NPR POS Sale";
        POSSaleLineRec: Record "NPR POS Sale Line";
    begin
        if POSSaleIdFilter = '' then
            Error(POSSalesIDNotSpecifiedErr);

        POSSaleRec.SetFilter(SystemId, POSSaleIdFilter);
        if not POSSaleRec.FindFirst() then
            exit;

        POSSaleLineRec.SetRange("Register No.", POSSaleRec."Register No.");
        POSSaleLineRec.SetRange("Sales Ticket No.", POSSaleRec."Sales Ticket No.");
        POSSaleLineRec.SetRange(Date, POSSaleRec.Date);
        IF POSSaleLineRec.FindSet() then
            repeat
                TempPOSSaleLineBuff.TransferFields(POSSaleLineRec);
                TempPOSSaleLineBuff."POS Sale System Id" := POSSaleRec.SystemId;
                TempPOSSaleLineBuff."POS Sale Line System Id" := POSSaleLineRec.SystemId;
                TempPOSSaleLineBuff.Insert();
            Until POSSaleLineRec.Next() = 0;
    end;

    local procedure ItemVariantIsRequired(ItemNo: Code[20]): Boolean
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
    begin
        if ItemNo = '' then
            exit;

        if not Item.Get(ItemNo) then
            exit;

        ItemVariant.SetRange(ItemVariant."Item No.", Item."No.");
        ItemVariant.SetRange(ItemVariant."NPR Blocked", false);

        Exit(not ItemVariant.IsEmpty());
    end;

    local procedure CheckPOSSalesLineRecItemBeforeInsert(POSSaleLineRec: Record "NPR POS Sale Line")
    var
    begin
        IF (POSSaleLineRec."Sale Type" = POSSaleLineRec."Sale Type"::Sale) AND (POSSaleLineRec."No." <> '') AND (POSSaleLineRec."Variant Code" = '') then
            IF ItemVariantIsRequired(POSSaleLineRec."No.") then
                Error(POSSalesLineItemVariantIsRequired, POSSaleLineRec."No.");
    end;

    local procedure CheckPOSSalesLineRecPaymentBeforeInsert(POSPaymentLineRec: Record "NPR POS Sale Line")
    var
    begin
        POSPaymentLineRec.TestField("No.");
        POSPaymentLineRec.TestField(Amount);
    end;

    procedure ValidateBalance(POSSaleRec: Record "NPR POS Sale")
    var
        SaleAmount: Decimal;
        PaidAmount: Decimal;
        ReturnAmount: Decimal;
        Subtotal: Decimal;
    begin
        CalculateBalance(POSSaleRec, SaleAmount, PaidAmount, ReturnAmount, Subtotal);
        IF ReturnAmount <> 0 then
            Error(TransactionNotBalancedErr, ReturnAmount);
    end;

    procedure CalculateBalance(POSSaleRec: Record "NPR POS Sale"; var SaleAmount: Decimal; var PaidAmount: Decimal; var ReturnAmount: Decimal; var Subtotal: Decimal)
    var
        RoundingAmount: Decimal;
        SaleLinePOS: Record "NPR POS Sale Line";
        PostingProfile: Record "NPR POS Posting Profile";
        POSStoreRec: Record "NPR POS Store";
    begin

        SaleAmount := 0;
        PaidAmount := 0;
        ReturnAmount := 0;
        Subtotal := 0;

        POSStoreRec.Get(POSSaleRec."POS Store Code");
        POSStoreRec.GetProfile(PostingProfile);

        SaleLinePOS.SetRange(SaleLinePOS."Register No.", POSSaleRec."Register No.");
        SaleLinePOS.SetRange(SaleLinePOS."Sales Ticket No.", POSSaleRec."Sales Ticket No.");
        SaleLinePOS.SetFilter(SaleLinePOS.Type, '<>%1', SaleLinePOS.Type::Comment);
        if SaleLinePOS.FindSet() then
            repeat
                case true of
                    (SaleLinePOS."Sale Type" in [SaleLinePOS."Sale Type"::Sale, SaleLinePOS."Sale Type"::Deposit]):
                        SaleAmount += SaleLinePOS."Amount Including VAT";
                    (SaleLinePOS."Sale Type" = SaleLinePOS."Sale Type"::"Out payment") and (SaleLinePOS."Discount Type" <> SaleLinePOS."Discount Type"::Rounding):
                        SaleAmount -= SaleLinePOS."Amount Including VAT";
                    (SaleLinePOS."Sale Type" = SaleLinePOS."Sale Type"::"Out payment") and (SaleLinePOS."Discount Type" = SaleLinePOS."Discount Type"::Rounding):
                        RoundingAmount += SaleLinePOS."Amount Including VAT";
                    (SaleLinePOS."Sale Type" = SaleLinePOS."Sale Type"::Payment):
                        PaidAmount += SaleLinePOS."Amount Including VAT";
                end;
            until SaleLinePOS.Next() = 0;


        Subtotal := SaleAmount - PaidAmount - RoundingAmount;
        ReturnAmount := SaleAmount - PaidAmount - RoundingAmount;

        if (ReturnAmount < 0) and (PostingProfile."POS Sales Rounding Account" <> '') and (PostingProfile."POS Sales Amt. Rndng Precision" > 0) then
            ReturnAmount := Round(ReturnAmount, PostingProfile."POS Sales Amt. Rndng Precision", PostingProfile.RoundingDirection());
    end;

    procedure EndSaleTransaction(POSSaleRec: Record "NPR POS Sale"; var POSEntry: Record "NPR POS Entry")
    var
        POSCreateEntry: Codeunit "NPR POS Create Entry";
        POSSaleRec2: Record "NPR POS Sale";
    begin
        POSSaleRec2 := POSSaleRec;
        POSCreateEntry.Run(POSSaleRec2);

        IF not FindPostedSaleEntry(POSSaleRec, POSEntry) then
            Error('POS Entry not created');

        POSSaleRec.Delete(true);
    end;

    local procedure FindPostedSaleEntry(POSSaleRec: Record "NPR POS Sale"; var POSEntry: Record "NPR POS Entry"): Boolean
    var
    begin
        POSEntry.Reset();
        POSEntry.SetRange("POS Unit No.", POSSaleRec."Register No.");
        POSEntry.SetRange("Document No.", POSSaleRec."Sales Ticket No.");
        POSEntry.SetRange("POS Store Code", POSSaleRec."POS Store Code");
        POSEntry.SetRange("Entry Date", POSSaleRec.Date);
        exit(POSEntry.FindLast());
    end;

    /* procedure PropagateModifyPOSSaleLine(var POSSaleLineBuff: Record "NPR POS Sales Line API Buffer"; var TempFieldBuffer: Record "Field Buffer")
    var
        POSSaleLineRec: Record "NPR POS Sale Line";
    begin
        if not POSSaleLineRec.GetBySystemId(POSSaleLineBuff."POS Sale Line System Id") then
            Error(CannotModifyALineThatDoesntExistErr);

        If TempFieldBuffer.Isempty() then
            Error(NoFieldsToModifyErr);

        TransferSaleLineBuffToPOSSaleLine(POSSaleLineBuff, TempFieldBuffer, POSSaleLineRec);

        POSSaleLineRec.Modify(true);

        POSSaleLineBuff.TransferFields(POSSaleLineRec);
    end;

    local procedure TransferSaleLineBuffToPOSSaleLine(var POSSaleLineBuff: Record "NPR POS Sales Line API Buffer"; var TempFieldBuffer: Record "Field Buffer"; var POSSaleLineRec: Record "NPR POS Sale Line")
    var
        TypeHelper: Codeunit "Type Helper";
        POSSaleLineRecordRef: RecordRef;
    begin
        POSSaleLineRecordRef.GetTable(POSSaleLineRec);

        TypeHelper.TransferFieldsWithValidate(TempFieldBuffer, POSSaleLineBuff, POSSaleLineRecordRef);

        POSSaleLineRecordRef.SetTable(POSSaleLineRec);
    end; */
}
