codeunit 6059878 "NPR POS Action: Rev.Dir.Sale B"
{
    Access = Internal;

    var
        POSEntryMgt: Codeunit "NPR POS Entry Management";

    procedure HendleReverse(SalesTicketNo: Code[20]; ObfucationMethod: Option "None",MI; CopyHeaderDim: Boolean; ReturnReasonCode: Code[20]; IncludePaymentLines: Boolean; CopyLineDimensions: Boolean)
    var
        POSSession: Codeunit "NPR POS Session";
    begin
        VerifyReceiptForReversal(SalesTicketNo, ObfucationMethod);
        CopySalesReceiptForReversal(SalesTicketNo, ObfucationMethod, CopyHeaderDim, ReturnReasonCode, IncludePaymentLines, CopyLineDimensions);
        POSSession.ChangeViewSale();
    end;

    local procedure VerifyReceiptForReversal(SalesTicketNo: Code[20]; ObfucationMethod: Option "None",MI)
    var
        POSEntry: Record "NPR POS Entry";
        NotFoundErr: Label 'Return receipt reference number %1 not found.';
        NothingToReturnErr: Label 'All items sold on ticket %1  has already been returned.';
    begin
        POSEntryMgt.DeObfuscateTicketNo(ObfucationMethod, SalesTicketNo);

        POSEntry.SetRange("Entry Type", POSEntry."Entry Type"::"Direct Sale");
        POSEntry.SetRange("Document No.", SalesTicketNo);
        if POSEntry.IsEmpty() then
            Error(NotFoundErr, SalesTicketNo);

        if (IsCompleteReversal(SalesTicketNo)) then
            Error(NothingToReturnErr, SalesTicketNo);

        OnBeforeReverseSalesTicket(SalesTicketNo);
    end;

    local procedure CopySalesReceiptForReversal(SalesTicketNo: Code[20]; ObfucationMethod: Option "None",MI; CopyHeaderDim: Boolean; ReturnReasonCode: Code[20]; IncludePaymentLines: Boolean; CopyLineDimensions: Boolean)
    var
        POSSession: Codeunit "NPR POS Session";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        QTY_ADJUSTED: Label 'Quantity was adjusted due to previous return sales.';
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSSession.GetSaleLine(POSSaleLine);

        POSEntryMgt.DeObfuscateTicketNo(ObfucationMethod, SalesTicketNo);

        SetCustomerOnReverseSale(SalePOS, SalesTicketNo);

        ReverseSalesTicket(SalePOS, SalesTicketNo, ReturnReasonCode, CopyLineDimensions);

        if IncludePaymentLines then
            ReversePaymentLines(SalePOS, SalesTicketNo, CopyLineDimensions);

        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");

        if not SaleLinePOS.IsEmpty then
            POSSaleLine.SetLast();

        if (ApplyMaxReturnQty(SalePOS, SalesTicketNo)) then
            Message(QTY_ADJUSTED);

        if CopyHeaderDim then
            if CopyDimensions(SalePOS, SalesTicketNo) then
                POSSale.Refresh(SalePOS);

        POSSaleLine.ResendAllOnAfterInsertPOSSaleLine();

        POSSale.RefreshCurrent();
    end;

    procedure ReverseSalesTicket(var SalePOS: Record "NPR POS Sale"; SalesTicketNo: Code[20]; ReturnReasonCode: Code[20]; CopyLineDimensions: Boolean)
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSalesLine: Record "NPR POS Entry Sales Line";
        SaleLinePOS2: Record "NPR POS Sale Line";
        TicketManagement: Codeunit "NPR TM Ticket Retail Mgt.";
        SaleLinePOSLineNo: Integer;
    begin
        POSSalesLine.SetRange("Document No.", SalesTicketNo);
        POSSalesLine.SetRange(Type, POSSalesLine.Type::Item);

        SaleLinePOS2.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS2.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        if not SaleLinePOS2.FindLast() then
            SaleLinePOS2."Line No." := 0;
        SaleLinePOSLineNo := SaleLinePOS2."Line No." + 10000;

        if POSSalesLine.FindSet(false) then
            repeat
                SaleLinePOS.Init();
                SaleLinePOS."Register No." := SalePOS."Register No.";
                SaleLinePOS."Sales Ticket No." := SalePOS."Sales Ticket No.";
                SaleLinePOS.Date := SalePOS.Date;
                SaleLinePOS."Line Type" := SaleLinePOS."Line Type"::Item;
                SaleLinePOS."Line No." := SaleLinePOSLineNo;
                SaleLinePOS."Manual Item Sales Price" := true;
                SaleLinePOS.Insert(true);
                SaleLinePOSLineNo := SaleLinePOSLineNo + 10000;

                ReverseAuditInfoToSalesLine(SaleLinePOS, POSSalesLine, CopyLineDimensions);

                if ReturnReasonCode <> '' then
                    SaleLinePOS.Validate("Return Reason Code", ReturnReasonCode);
                SaleLinePOS.UpdateAmounts(SaleLinePOS);
                SaleLinePOS."Return Sale Sales Ticket No." := SalesTicketNo;
                CallOnReverseSalesTicketOnBeforeModifySalesLinePOS(SaleLinePOS, SalePOS);
                SaleLinePOS.Modify(true);

                TicketManagement.UpdateTicketOnSaleLineInsert(SaleLinePOS);
            until POSSalesLine.Next() = 0;
    end;

    procedure ReverseAuditInfoToSalesLine(var SaleLinePOS: Record "NPR POS Sale Line"; POSSalesLine: Record "NPR POS Entry Sales Line"; CopyLineDimensions: Boolean)
    var
        POSEntry: Record "NPR POS Entry";
    begin
        POSEntry.Get(POSSalesLine."POS Entry No.");

        SaleLinePOS.SetSkipUpdateDependantQuantity(true);
        SaleLinePOS.Validate("No.", POSSalesLine."No.");
        SaleLinePOS.Description := POSSalesLine.Description;

        if not (SaleLinePOS."Line Type" in [SaleLinePOS."Line Type"::"POS Payment", SaleLinePOS."Line Type"::"GL Payment", SaleLinePOS."Line Type"::Comment]) then
            SaleLinePOS.Validate(Quantity, -POSSalesLine.Quantity);

        SaleLinePOS.Validate("Unit of Measure Code", POSSalesLine."Unit of Measure Code");
        SaleLinePOS."VAT %" := POSSalesLine."VAT %";
        SaleLinePOS."Discount %" := Abs(POSSalesLine."Line Discount %");
        SaleLinePOS."Discount Amount" := -POSSalesLine."Line Discount Amount Excl. VAT";
        SaleLinePOS.Amount := -POSSalesLine."Amount Excl. VAT";
        SaleLinePOS."Currency Amount" := -POSSalesLine."Amount Excl. VAT";
        SaleLinePOS."Amount Including VAT" := -POSSalesLine."Amount Incl. VAT";
        SaleLinePOS."Serial No." := POSSalesLine."Serial No.";
        SaleLinePOS."Lot No." := POSSalesLine."Lot No.";
        SaleLinePOS."Discount Type" := POSSalesLine."Discount Type";
        SaleLinePOS."Discount Code" := CopyStr(POSSalesLine."Discount Code", 1, MaxStrLen(SaleLinePOS."Discount Code"));
        SaleLinePOS."Gen. Bus. Posting Group" := POSSalesLine."Gen. Bus. Posting Group";
        SaleLinePOS."Gen. Prod. Posting Group" := POSSalesLine."Gen. Prod. Posting Group";
        SaleLinePOS."VAT Bus. Posting Group" := POSSalesLine."VAT Bus. Posting Group";
        SaleLinePOS."VAT Prod. Posting Group" := POSSalesLine."VAT Prod. Posting Group";
        SaleLinePOS."Unit Cost (LCY)" := POSSalesLine."Unit Cost (LCY)";
        SaleLinePOS.Cost := -(POSSalesLine."Unit Cost" * POSSalesLine.Quantity);
        SaleLinePOS."Unit Cost" := POSSalesLine."Unit Cost";
        SaleLinePOS."Unit Price" := POSSalesLine."Unit Price";
        SaleLinePOS."VAT Base Amount" := -POSSalesLine."VAT Base Amount";
        SaleLinePOS."Variant Code" := POSSalesLine."Variant Code";
        if CopyLineDimensions then begin
            SaleLinePOS."Shortcut Dimension 1 Code" := POSSalesLine."Shortcut Dimension 1 Code";
            SaleLinePOS."Shortcut Dimension 2 Code" := POSSalesLine."Shortcut Dimension 2 Code";
            SaleLinePOS."Dimension Set ID" := POSSalesLine."Dimension Set ID";
        end;
        SaleLinePOS."Orig.POS Entry S.Line SystemId" := POSSalesLine.SystemId;
        SaleLinePOS."Serial No. not Created" := POSSalesLine."Retail Serial No.";
    end;

    local procedure SetCustomerOnReverseSale(var SalePOS: Record "NPR POS Sale"; SalesTicketNo: Code[20])
    var
        CustomerNo: Code[20];
        POSSale: Codeunit "NPR POS Sale";
        Customer: Record Customer;
        POSEntry: Record "NPR POS Entry";
    begin
        POSEntry.SetRange("Entry Type", POSEntry."Entry Type"::"Direct Sale");
        POSEntry.SetRange("Document No.", SalesTicketNo);
        if POSEntry.IsEmpty then exit;

        POSEntry.SetFilter("Customer No.", '<>%1', '');
        if POSEntry.FindFirst() then
            CustomerNo := POSEntry."Customer No."
        else
            exit;

        if Customer.Get(CustomerNo) then
            SalePOS.Validate("Customer No.", Customer."No.");

        SalePOS.Modify(true);
        POSSale.Refresh(SalePOS);
        POSSale.Modify(true, false);
    end;

    local procedure IsCompleteReversal(SalesTicketNo: Code[20]): Boolean
    var
        TmpPosRmaLine: Record "NPR POS RMA Line";
        PosRmaLine: Record "NPR POS RMA Line";
        POSSalesLine: Record "NPR POS Entry Sales Line";
        ItemQty: Decimal;
    begin
        PosRmaLine.SetRange("Sales Ticket No.", SalesTicketNo);
        if (PosRmaLine.IsEmpty()) then
            exit(false); // No return sales for this register yet

        POSSalesLine.SetCurrentKey(Type, "No.", "Document No.");
        POSSalesLine.SetLoadFields("No.");
        POSSalesLine.SetRange("Document No.", SalesTicketNo);
        POSSalesLine.SetRange(Type, POSSalesLine.Type::Item);

        if (POSSalesLine.FindSet()) then begin
            repeat
                TmpPosRmaLine."Sales Ticket No." := SalesTicketNo;
                TmpPosRmaLine."Returned Item No." := POSSalesLine."No.";
                TmpPosRmaLine.CalcFields("FF Total Qty Sold", "FF Total Qty Returned");
                ItemQty += TmpPosRmaLine."FF Total Qty Sold" + TmpPosRmaLine."FF Total Qty Returned";
            until (POSSalesLine.Next() = 0);
        end;

        // When returned quantity is equal to (or exceeds) sold quantity, all items have been returned
        exit(ItemQty <= 0);
    end;

    local procedure ApplyMaxReturnQty(CurrentSalePOS: Record "NPR POS Sale"; OriginalSalesTicketNo: Code[20]): Boolean
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        AdjustedQty: Decimal;
        QtyIsAdjusted: Boolean;
    begin
        SaleLinePOS.SetRange("Register No.", CurrentSalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", CurrentSalePOS."Sales Ticket No.");
        SaleLinePOS.SetLoadFields("Line Type", "Orig.POS Entry S.Line SystemId", Quantity);
        if SaleLinePOS.FindSet(true) then begin
            repeat
                if ((SaleLinePOS.Quantity < 0) and (SaleLinePOS."Line Type" = SaleLinePOS."Line Type"::Item)) then begin
                    AdjustedQty := GetRemainingQtyToReturn(OriginalSalesTicketNo, Abs(SaleLinePOS.Quantity), SaleLinePOS."Line No.", SaleLinePOS."Orig.POS Entry S.Line SystemId") * -1;
                    if (AdjustedQty <> SaleLinePOS.Quantity) then begin
                        SaleLinePOS.Validate(Quantity, AdjustedQty);
                        SaleLinePOS.Modify();
                        QtyIsAdjusted := true;
                    end;
                end;
            until (SaleLinePOS.Next() = 0);
        end;

        exit(QtyIsAdjusted);
    end;

    local procedure GetRemainingQtyToReturn(SalesTicketNo: Code[20]; OriginalQty: Decimal; LineNo: Integer; OriginalSystemId: Guid) MaxQuantity: Decimal
    var
        POSSalesLine: Record "NPR POS Entry Sales Line";
        PosRmaLine: Record "NPR POS RMA Line";
    begin
        if not POSSalesLine.GetBySystemId(OriginalSystemId) then
            exit(OriginalQty);

        MaxQuantity := POSSalesLine.Quantity;

        // Check previous returns
        PosRmaLine.SetRange("Sales Ticket No.", SalesTicketNo);
        PosRmaLine.SetRange("Returned Item No.", POSSalesLine."No.");
        PosRmaLine.SetRange("Line No. Filter", LineNo);

        if (PosRmaLine.FindFirst()) then begin
            PosRmaLine.CalcFields("FF Total Qty Sold", "FF Total Qty Returned");
            if (PosRmaLine."FF Total Qty Sold" + PosRmaLine."FF Total Qty Returned" < MaxQuantity) then
                MaxQuantity := PosRmaLine."FF Total Qty Sold" + PosRmaLine."FF Total Qty Returned";
        end;

        // Either sales ticket is a return order or we have over returned already.
        if (MaxQuantity < 0) then
            MaxQuantity := 0;
    end;

    local procedure CopyDimensions(var CurrentSalePOS: Record "NPR POS Sale"; OriginalSalesTicketNo: Code[20]): Boolean
    var
        POSEntry: Record "NPR POS Entry";
        OldDimSetID: Integer;
    begin

        POSEntry.SetCurrentKey("Document No.");
        POSEntry.SetRange("Document No.", OriginalSalesTicketNo);
        if POSEntry.FindLast() then
            if CurrentSalePOS."Dimension Set ID" <> POSEntry."Dimension Set ID" then begin
                OldDimSetID := CurrentSalePOS."Dimension Set ID";

                CurrentSalePOS."Dimension Set ID" := POSEntry."Dimension Set ID";
                CurrentSalePOS."Shortcut Dimension 1 Code" := POSEntry."Shortcut Dimension 1 Code";
                CurrentSalePOS."Shortcut Dimension 2 Code" := POSEntry."Shortcut Dimension 2 Code";
                CurrentSalePOS.Modify();

                if CurrentSalePOS.SalesLinesExist() then
                    CurrentSalePOS.UpdateAllLineDim(CurrentSalePOS."Dimension Set ID", OldDimSetID);

                exit(true);
            end;

        exit(false);
    end;

    local procedure ReversePaymentLines(SalePOS: Record "NPR POS Sale"; SalesTicketNo: Code[20]; CopyLineDimensions: Boolean)
    var
        POSEntryPaymentLines: Record "NPR POS Entry Payment Line";
    begin
        POSEntryPaymentLines.SetRange("Document No.", SalesTicketNo);
        POSEntryPaymentLines.SetFilter(Amount, '>%1', 0);
        if POSEntryPaymentLines.FindSet() then
            repeat
                InsertPaymentLine(SalePOS, CopyLineDimensions, POSEntryPaymentLines);
            until POSEntryPaymentLines.Next() = 0;
    end;

    local procedure GetPaymentLineNo(SalePOS: Record "NPR POS Sale"): Integer
    var
        PaymentLine: Record "NPR POS Sale Line";
    begin
        PaymentLine.SetRange("Register No.", SalePOS."Register No.");
        PaymentLine.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        if PaymentLine.FindLast() then
            exit(PaymentLine."Line No." + 10000)
        else
            exit(10000);
    end;

    local procedure CallOnReverseSalesTicketOnBeforeModifySalesLinePOS(var SaleLinePOS: Record "NPR POS Sale Line"; var SalePOS: Record "NPR POS Sale")
    var
        ReverseSalePublicAccess: Codeunit "NPR Reverse Sale Public Access";
    begin
        ReverseSalePublicAccess.CallOnReverseSalesTicketOnBeforeModifySalesLinePOS(SaleLinePOS, SalePOS);
    end;

    local procedure InsertPaymentLine(var SalePOS: Record "NPR POS Sale"; CopyLineDimensions: Boolean; var POSEntryPaymentLines: Record "NPR POS Entry Payment Line")
    var
        PaymentLine: Record "NPR POS Sale Line";
        POSPaymentMethod: Record "NPR POS Payment Method";
    begin
        POSPaymentMethod.Get(POSEntryPaymentLines."POS Payment Method Code");
        If POSPaymentMethod."Processing Type" <> POSPaymentMethod."Processing Type"::CASH then
            exit;

        PaymentLine.Init();
        PaymentLine."Register No." := SalePOS."Register No.";
        PaymentLine."Sale Type" := PaymentLine."Sale Type"::Sale;
        PaymentLine."Line Type" := PaymentLine."Line Type"::"POS Payment";
        PaymentLine."Sales Ticket No." := SalePOS."Sales Ticket No.";
        PaymentLine."Line No." := GetPaymentLineNo(SalePOS);
        PaymentLine."No." := POSEntryPaymentLines."POS Payment Method Code";
        PaymentLine."Currency Code" := POSPaymentMethod."Currency Code";
        if POSEntryPaymentLines."Currency Code" <> '' then
            PaymentLine."Amount Including VAT" := -POSEntryPaymentLines."Amount (LCY)" - GetChangeAmt(POSEntryPaymentLines, POSPaymentMethod)
        else
            PaymentLine."Amount Including VAT" := -POSEntryPaymentLines.Amount - GetChangeAmt(POSEntryPaymentLines, POSPaymentMethod);
        PaymentLine."Currency Amount" := PaymentLine."Amount Including VAT";
        PaymentLine."EFT Approved" := POSEntryPaymentLines.EFT;
        if CopyLineDimensions then begin
            PaymentLine."Shortcut Dimension 1 Code" := POSEntryPaymentLines."Shortcut Dimension 1 Code";
            PaymentLine."Shortcut Dimension 2 Code" := POSEntryPaymentLines."Shortcut Dimension 2 Code";
            PaymentLine."Dimension Set ID" := POSEntryPaymentLines."Dimension Set ID";
        end;
        if POSEntryPaymentLines."VAT Base Amount (LCY)" <> 0 then
            PaymentLine."VAT Base Amount" := -POSEntryPaymentLines."VAT Base Amount (LCY)";
        PaymentLine."Location Code" := SalePOS."Location Code";
        PaymentLine."Responsibility Center" := POSEntryPaymentLines."Responsibility Center";
        PaymentLine."VAT Bus. Posting Group" := POSEntryPaymentLines."VAT Bus. Posting Group";
        PaymentLine."VAT Prod. Posting Group" := POSEntryPaymentLines."VAT Prod. Posting Group";
        PaymentLine.Description := POSEntryPaymentLines.Description;
        PaymentLine.Date := SalePOS.Date;
        PaymentLine.Insert(false, true);
    end;

    local procedure GetChangeAmt(POSEntryPaymentLines: Record "NPR POS Entry Payment Line"; POSPaymentMethod: Record "NPR POS Payment Method") ChangeAmount: Decimal
    var
        POSEntryChangePaymentLine: Record "NPR POS Entry Payment Line";
    begin
        POSEntryChangePaymentLine.SetRange("Document No.", POSEntryPaymentLines."Document No.");
        POSEntryChangePaymentLine.SetRange("POS Payment Method Code", POSPaymentMethod."Return Payment Method Code");
        POSEntryChangePaymentLine.SetFilter(Amount, '<%1', 0);
        if POSEntryChangePaymentLine.FindSet() then begin
            POSEntryChangePaymentLine.CalcSums(Amount);
            ChangeAmount := POSEntryChangePaymentLine.Amount;
        end;

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale Line", 'OnBeforeSetQuantity', '', true, true)]
    local procedure OnBeforeSetQuantityOnReverseSales(var Sender: Codeunit "NPR POS Sale Line"; var SaleLinePOS: Record "NPR POS Sale Line"; var NewQuantity: Decimal)
    var
        PosRmaLine: Record "NPR POS RMA Line";
        SaleLinePOSCopy: Record "NPR POS Sale Line";
        MAX_TO_RETURN: Label 'Maximum number of items to return is %1.';
        COPIED_RECEIPT: Label 'This sales is copied from %1 and new return items can''t be added to the return sales.';
    begin
        // Publisher in Codeunit POS Sale Line
        // This subscriber is intended to prevent returning more items them originally sold
        if (NewQuantity >= 0) then
            exit;

        if (SaleLinePOS."Line Type" <> SaleLinePOS."Line Type"::Item) then
            exit;

        // if this line is missing the sales ticket reference, all the other lines must also not have a reference
        if (SaleLinePOS."Return Sale Sales Ticket No." = '') then begin
            SaleLinePOSCopy.SetRange("Register No.", SaleLinePOS."Register No.");
            SaleLinePOSCopy.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
            SaleLinePOSCopy.SetRange("Line Type", SaleLinePOSCopy."Line Type"::Item);
            SaleLinePOSCopy.SetFilter(Quantity, '<%1', 0);
            SaleLinePOSCopy.SetFilter("Return Sale Sales Ticket No.", '<>%1', '');
            if (not SaleLinePOSCopy.IsEmpty()) then
                Error(COPIED_RECEIPT, SaleLinePOS."Sales Ticket No.");
            exit;
        end;

        PosRmaLine.SetFilter("Sales Ticket No.", '=%1', SaleLinePOS."Return Sale Sales Ticket No.");
        PosRmaLine.SetFilter("Returned Item No.", '=%1', SaleLinePOS."No.");

        if (PosRmaLine.FindFirst()) then begin
            PosRmaLine.CalcFields("FF Total Qty Sold", "FF Total Qty Returned");

            if ((NewQuantity + PosRmaLine."FF Total Qty Sold" + PosRmaLine."FF Total Qty Returned") < 0) then
                Error(MAX_TO_RETURN, PosRmaLine."FF Total Qty Sold" + PosRmaLine."FF Total Qty Returned")
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeReverseSalesTicket(SalesTicketNo: Code[20])
    begin
    end;
}