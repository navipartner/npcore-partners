codeunit 6059879 "NPR POS Action: Quantity B"
{
    procedure ChangeQuantity(ReturnReasonCode: Code[20]; Quantity: Decimal; UnitPrice: Decimal; ConstraintOption: Option "No Constraint","Positive Quantity Only","Negative Quantity Only"; NegativeInput: Boolean; SkipItemAvailabilityCheck: Boolean; SaleLine: Codeunit "NPR POS Sale Line")
    var
        PosInventoryProfile: Record "NPR POS Inventory Profile";
        POSSalesLine: Record "NPR POS Entry Sales Line";
        SaleLinePOS: Record "NPR POS Sale Line";
        PosItemCheckAvail: Codeunit "NPR POS Item-Check Avail.";
        POSSession: Codeunit "NPR POS Session";
        SaleMustBePositiveErr: Label 'Quantity must be positive on the sales line.';
        SaleMustBeNegativeErr: Label 'Quantity must be negative on the sales line.';
        WrongQuantityErr: Label 'The minimum number of units to sell must be greater than zero.';
        WrongReturnQuantityErr: Label 'The maximum number of units to return for %1 is %2.', Comment = '%1 = item description, %2 = maximal allowed quantity for return';
        EFTApprovedErr: Label 'The quantity cannot be changed because the line has been approved by the EFT device.';
    begin

        if NegativeInput and (Quantity > 0) then
            Quantity := -Quantity;

        SaleLine.GetCurrentSaleLine(SaleLinePOS);

        if SaleLinePOS."EFT Approved" then
            Error(EftApprovedErr);

        if (SaleLinePOS."Return Sale Sales Ticket No." <> '') then begin
            POSSalesLine.SetRange("Document No.", SaleLinePOS."Return Sale Sales Ticket No.");
            POSSalesLine.SetRange("Line No.", SaleLinePOS."Line No.");
            if POSSalesLine.FindFirst() then
                if Abs(Quantity) > Abs(POSSalesLine.Quantity) then
                    Error(WrongReturnQuantityErr, POSSalesLine.Description, Abs(POSSalesLine.Quantity));
        end;

        case ConstraintOption of
            ConstraintOption::"Positive Quantity Only":
                begin
                    if (Quantity = 0) then
                        Error(WrongQuantityErr);
                    if (Quantity < 0) then
                        Error(SaleMustBePositiveErr);
                end;
            ConstraintOption::"Negative Quantity Only":
                begin
                    if (Quantity = 0) then
                        Error(WrongQuantityErr);
                    if (Quantity > 0) then
                        Error(SaleMustBeNegativeErr);
                end;
        end;

        Clear(PosItemCheckAvail);
        if not SkipItemAvailabilityCheck then begin
            PosItemCheckAvail.GetPosInvtProfile(POSSession, PosInventoryProfile);
            if PosInventoryProfile."Stockout Warning" then
                PosItemCheckAvail.SetxDataset(POSSession);
        end;

        SaleLine.SetQuantity(Quantity);

        // Manual Unit Price when returning goods
        if (UnitPrice <> 0) and (Quantity < 0) then
            SaleLine.SetUnitPrice(Abs(UnitPrice));

        if ReturnReasonCode <> '' then begin
            SaleLine.GetCurrentSaleLine(SaleLinePOS);
            SaleLinePOS.Validate("Return Reason Code", ReturnReasonCode);
            SaleLinePOS.Modify();
            SaleLine.RefreshCurrent();
        END;

        if not SkipItemAvailabilityCheck and PosInventoryProfile."Stockout Warning" then
            PosItemCheckAvail.DefineScopeAndCheckAvailability(POSSession, false);

    end;

    procedure RemoveStarFromQuantity(var Quantity: Text)
    var
        Position: Integer;
    begin
        Position := StrPos(Quantity, '*');
        if Position <> StrLen(Quantity) then
            exit;

        Quantity := DelStr(Quantity, Position);
    end;
}