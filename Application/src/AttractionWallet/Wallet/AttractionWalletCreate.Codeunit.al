codeunit 6185076 "NPR AttractionWalletCreate"
{
    TableNo = "NPR POS Sale";
    Access = Internal;

    trigger OnRun()
    var
        Wallet: Codeunit "NPR AttractionWallet";
    begin
        if (not Wallet.IsWalletEnabled()) then
            exit;

        ManageWalletAssets(Rec);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale", 'OnBeforeEndSale', '', true, true)]
    local procedure OnBeforeEndSale(var Sender: Codeunit "NPR POS Sale"; SaleHeader: Record "NPR POS Sale")
    var
        Wallet: Codeunit "NPR AttractionWallet";
    begin
        if (not Wallet.IsWalletEnabled()) then
            exit;

        ManageWalletAssets(SaleHeader);
    end;

    local procedure ManageWalletAssets(POSSale: Record "NPR POS Sale")
    var
        WalletAssetMgt: Codeunit "NPR AttractionWallet";
        POSSaleLine: Record "NPR POS Sale Line";
    begin

        POSSaleLine.SetCurrentKey("Register No.", "Sales Ticket No.");
        POSSaleLine.SetFilter("Register No.", '=%1', POSSale."Register No.");
        POSSaleLine.SetFilter("Sales Ticket No.", '=%1', POSSale."Sales Ticket No.");
        if (POSSaleLine.FindSet()) then begin
            repeat
                if (POSSaleLine.Quantity > 0) then
                    WalletAssetMgt.CreateAssetsFromPosSaleLine(POSSale, POSSaleLine);

                if (POSSaleLine.Quantity < 0) then
                    WalletAssetMgt.RevokeAssetsFromPosSaleLine(POSSale, POSSaleLine."Line No.");

            until (POSSaleLine.Next() = 0);
        end;
    end;


    // ********************************************************************************************************************
    internal procedure CreateIntermediateWallet(SaleLinePOS: Record "NPR POS Sale Line")
    var
        POSSale: Record "NPR POS Sale";
        Item: Record Item;
        TargetQuantity: Integer;
        TopUp: Boolean;
        SaleLinePOSAddOn: Record "NPR NpIa SaleLinePOS AddOn";
    begin
        if (not POSSale.Get(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.")) then
            exit;

        if (not Item.Get(SaleLinePOS."No.")) then
            exit;

        TargetQuantity := Round(SaleLinePOS.Quantity, 1);

        SaleLinePOSAddOn.Init();
        if (SaleLinePOS.Indentation > 0) then begin
            SaleLinePOSAddOn.SetCurrentKey("Register No.", "Sales Ticket No.", "Sale Type", "Sale Date", "Sale Line No.", "Line No.");
            SaleLinePOSAddOn.SetFilter("Register No.", '=%1', SaleLinePOS."Register No.");
            SaleLinePOSAddOn.SetFilter("Sales Ticket No.", '=%1', SaleLinePOS."Sales Ticket No.");
            SaleLinePOSAddOn.SetFilter("Sale Type", '=%1', SaleLinePOSAddOn."Sale Type"::Sale);
            SaleLinePOSAddOn.SetFilter("Sale Date", '=%1', SaleLinePOS.Date);
            SaleLinePOSAddOn.SetFilter("Sale Line No.", '=%1', SaleLinePOS."Line No.");
            SaleLinePOSAddOn.SetFilter(AddToWallet, '=%1', true);
            if (not SaleLinePOSAddOn.FindFirst()) then
                SaleLinePOSAddOn.Init();
        end;

        TopUp := (Item."NPR CreateAttractionWallet" or SaleLinePOSAddOn.AddToWallet);
        if (TopUp) then
            TopUpIntermediateWalletsForLine(POSSale.SystemId, SaleLinePOS.SystemId, SaleLinePOS."Line No.", TargetQuantity);

    end;

    internal procedure OnAfterSetQuantityPOSSaleLine(SaleLinePOS: Record "NPR POS Sale Line"; var NewQuantity: Decimal)
    begin
        OnBeforeSetQuantityPOSSaleLine(SaleLinePOS, NewQuantity);
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale Line", 'OnBeforeSetQuantity', '', true, true)]
    local procedure OnBeforeSetQuantityPOSSaleLine(SaleLinePOS: Record "NPR POS Sale Line"; var NewQuantity: Decimal)
    begin
        SetQuantityPOSSaleLineWorker(SaleLinePOS, NewQuantity);
    end;

    internal procedure SetQuantityPOSSaleLineWorker(SaleLinePOS: Record "NPR POS Sale Line"; NewQuantity: Decimal)
    var
        POSSale: Record "NPR POS Sale";
        IntermediaryWalletLine: Record "NPR AttractionWalletSaleLine";
        OrgQuantity: Integer;
        TargetQuantity: Integer;
        InvalidQuantity: Label 'Sale quantity must be an positive integer when assigning wallets.';
    begin
        if (not POSSale.Get(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.")) then
            exit;

        // Only adjust wallet quantities when there exist wallets for this line 
        IntermediaryWalletLine.SetCurrentKey(SaleHeaderSystemId, LineNumber);
        IntermediaryWalletLine.SetFilter(SaleHeaderSystemId, '=%1', POSSale.SystemId);
        IntermediaryWalletLine.SetFilter(LineNumber, '=%1', SaleLinePOS."Line No.");
        IntermediaryWalletLine.SetFilter(ActionType, '=%1', IntermediaryWalletLine.ActionType::CREATE);
        if (IntermediaryWalletLine.IsEmpty()) then
            exit;

        OrgQuantity := IntermediaryWalletLine.Count();
        TargetQuantity := Round(NewQuantity, 1);
        if (TargetQuantity <> NewQuantity) then
            Error(InvalidQuantity);

        AdjustIntermediateWalletQuantityForLine(POSSale.SystemId, SaleLinePOS.SystemId, SaleLinePOS."Line No.", OrgQuantity, TargetQuantity);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Sale Line", 'OnBeforeDeleteEvent', '', true, false)]
    local procedure OnBeforeDeleteRecordPOSSaleLine(var Rec: Record "NPR POS Sale Line"; RunTrigger: Boolean)
    var
        POSSale: Record "NPR POS Sale";
        IntermediaryWalletLine: Record "NPR AttractionWalletSaleLine";
    begin
        if (Rec.IsTemporary()) then
            exit;

        if (not POSSale.Get(Rec."Register No.", Rec."Sales Ticket No.")) then
            exit;

        IntermediaryWalletLine.SetCurrentKey(SaleHeaderSystemId, LineNumber);
        IntermediaryWalletLine.SetFilter(SaleHeaderSystemId, '=%1', POSSale.SystemId);
        IntermediaryWalletLine.SetFilter(LineNumber, '=%1', Rec."Line No.");
        if (IntermediaryWalletLine.FindSet()) then
            repeat
                DeleteIntermediateWalletLine(IntermediaryWalletLine);
            until (IntermediaryWalletLine.Next() = 0);
    end;

    internal procedure CreateIntermediateWallet(SaleId: Guid; SaleLineId: Guid; SaleLineNumber: Integer; QtyToCreate: Integer; MaxQuantity: Integer)
    var
        IntermediaryWallet: Record "NPR AttractionWalletSaleHdr";
        IntermediaryWalletLine: Record "NPR AttractionWalletSaleLine";
        i: Integer;
        LastWalletNumber: Integer;
        WalletCount: Integer;
    begin
        IntermediaryWalletLine.SetCurrentKey(SaleHeaderSystemId, LineNumber);
        IntermediaryWalletLine.SetFilter(SaleHeaderSystemId, '=%1', SaleId);
        IntermediaryWalletLine.SetFilter(LineNumber, '=%1', SaleLineNumber);
        IntermediaryWalletLine.SetFilter(ActionType, '=%1', IntermediaryWalletLine.ActionType::CREATE);
        WalletCount := IntermediaryWalletLine.Count();
        if (WalletCount >= MaxQuantity) then
            exit;

        if (WalletCount + QtyToCreate > MaxQuantity) then
            QtyToCreate := MaxQuantity - WalletCount;

        if (QtyToCreate < 1) then
            exit;

        LastWalletNumber := 0;
        IntermediaryWallet.SetCurrentKey(SaleHeaderSystemId, WalletNumber);
        IntermediaryWallet.SetFilter(SaleHeaderSystemId, '=%1', SaleId);
        if (IntermediaryWallet.FindLast()) then
            LastWalletNumber := IntermediaryWallet.WalletNumber;

        for i := 1 to QtyToCreate do begin
            CreateIntermediateWallet(SaleId, SaleLineId, SaleLineNumber, LastWalletNumber + i, '', '', 0);
        end;
    end;

    internal procedure CreateIntermediateWalletForExistingWallet(SaleId: Guid; SaleLineId: Guid; SaleLineNumber: Integer; Name: Text[100]; ReferenceNumber: Code[50]; ExistingWalletEntryNo: Integer)
    var
        IntermediaryWallet: Record "NPR AttractionWalletSaleHdr";
        WalletNumber: Integer;
        Wallet: Record "NPR AttractionWallet";
    begin
        Wallet.Get(ExistingWalletEntryNo);

        IntermediaryWallet.Reset();
        IntermediaryWallet.SetCurrentKey(SaleHeaderSystemId, WalletNumber);
        IntermediaryWallet.SetFilter(SaleHeaderSystemId, '=%1', SaleId);

        WalletNumber := 1;
        if (IntermediaryWallet.FindLast()) then
            WalletNumber := IntermediaryWallet.WalletNumber + 1;

        CreateIntermediateWallet(SaleId, SaleLineId, SaleLineNumber, WalletNumber, Name, ReferenceNumber, ExistingWalletEntryNo);
    end;

    internal procedure CreateIntermediateWallet(SaleId: Guid; SaleLineId: Guid; SaleLineNumber: Integer; WalletNumber: Integer; Name: Text[100]; ReferenceNumber: Code[50]; ExistingWalletEntryNo: Integer)
    var
        IntermediaryWallet: Record "NPR AttractionWalletSaleHdr";
    begin
        IntermediaryWallet.Init();
        IntermediaryWallet.SaleHeaderSystemId := SaleId;
        IntermediaryWallet.WalletNumber := WalletNumber; // Intermediary wallet number
        IntermediaryWallet.Name := Name;
        if (IntermediaryWallet.Name = '') then
            IntermediaryWallet.Name := StrSubstNo('Wallet %1', IntermediaryWallet.WalletNumber);

        IntermediaryWallet.ReferenceNumber := ReferenceNumber;
        IntermediaryWallet.WalletEntryNo := ExistingWalletEntryNo; // Actual wallet number when teller selects existing wallet

        if (not IntermediaryWallet.Insert()) then
            ; // Ignore existing records

        AddIntermediateWalletLine(IntermediaryWallet, SaleLineId, SaleLineNumber);
    end;

    internal procedure AddIntermediateWalletLine(IntermediaryWallet: Record "NPR AttractionWalletSaleHdr"; SaleLineId: Guid; LineNumber: Integer): Boolean
    var
        IntermediaryWalletLine: Record "NPR AttractionWalletSaleLine";
    begin
        IntermediaryWalletLine.SaleHeaderSystemId := IntermediaryWallet.SaleHeaderSystemId;
        IntermediaryWalletLine.LineNumber := LineNumber;
        IntermediaryWalletLine.SaleLineId := SaleLineId;
        IntermediaryWalletLine.WalletNumber := IntermediaryWallet.WalletNumber;
        IntermediaryWalletLine.ActionType := IntermediaryWalletLine.ActionType::CREATE;

        exit(IntermediaryWalletLine.Insert());
    end;

    internal procedure AdjustIntermediateWalletQuantityForLine(SaleId: Guid; SaleLineId: Guid; SaleLineNumber: Integer; OrgQuantity: Integer; NewQuantity: Integer)
    begin
        if (OrgQuantity < NewQuantity) then
            TopUpIntermediateWalletsForLine(SaleId, SaleLineId, SaleLineNumber, NewQuantity);

        if (OrgQuantity > NewQuantity) then
            RemoveIntermediateWalletsForLine(SaleId, SaleLineNumber, NewQuantity);
    end;

    internal procedure TopUpIntermediateWalletsForLine(SaleId: Guid; SaleLineId: Guid; SaleLineNumber: Integer; TargetQuantity: Integer)
    var
        IntermediaryWallet: Record "NPR AttractionWalletSaleHdr";
        IntermediaryWalletLine: Record "NPR AttractionWalletSaleLine";
        SaleLinePOS: Record "NPR POS Sale Line";
        CurrentCount, ExistingCount : Integer;
        ReuseExistingWallets: Boolean;
    begin
        ReuseExistingWallets := false;
        if (SaleLinePOS.GetBySystemId(SaleLineId)) then
            ReuseExistingWallets := (SaleLinePOS.Indentation > 0);

        // Get current assigned count
        IntermediaryWalletLine.SetCurrentKey(SaleHeaderSystemId, LineNumber);
        IntermediaryWalletLine.SetFilter(SaleHeaderSystemId, '=%1', SaleId);
        IntermediaryWalletLine.SetFilter(LineNumber, '=%1', SaleLineNumber);
        IntermediaryWalletLine.SetFilter(ActionType, '=%1', IntermediaryWalletLine.ActionType::CREATE);
        CurrentCount := IntermediaryWalletLine.Count();
        if (CurrentCount >= TargetQuantity) then
            exit;

        // Add existing wallets not yet assigned to this line. (brute force)
        if (ReuseExistingWallets) then begin
            IntermediaryWallet.SetCurrentKey(SaleHeaderSystemId, WalletNumber);
            IntermediaryWallet.SetFilter(SaleHeaderSystemId, '=%1', SaleId);
            ExistingCount := IntermediaryWallet.Count();

            if (ExistingCount > CurrentCount) then begin
                IntermediaryWallet.FindSet();
                repeat
                    if (WalletNumberIsLegalToAssign(IntermediaryWallet.WalletNumber, SaleId, SaleLineId)) then
                        if (AddIntermediateWalletLine(IntermediaryWallet, SaleLineId, SaleLineNumber)) then
                            CurrentCount += 1;
                until (IntermediaryWallet.Next() = 0) or (CurrentCount >= TargetQuantity);
            end;
        end;

        if (CurrentCount < TargetQuantity) then
            CreateIntermediateWallet(SaleId, SaleLineId, SaleLineNumber, TargetQuantity - CurrentCount, TargetQuantity);

    end;

    local procedure WalletNumberIsLegalToAssign(WalletNumber: Integer; SaleId: Guid; SaleLineId: Guid): Boolean
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        SaleLinePOSAddOn: Record "NPR NpIa SaleLinePOS AddOn";
        IntermediaryWalletLine: Record "NPR AttractionWalletSaleLine";
    begin

        if (not SaleLinePOS.GetBySystemId(SaleLineId)) then
            exit(false);

        SaleLinePOSAddOn.SetCurrentKey("Register No.", "Sales Ticket No.", "Sale Type", "Sale Date", "Sale Line No.", "Line No.");
        SaleLinePOSAddOn.SetFilter("Register No.", '=%1', SaleLinePOS."Register No.");
        SaleLinePOSAddOn.SetFilter("Sales Ticket No.", '=%1', SaleLinePOS."Sales Ticket No.");
        SaleLinePOSAddOn.SetFilter("Sale Type", '=%1', SaleLinePOSAddOn."Sale Type"::Sale);
        SaleLinePOSAddOn.SetFilter("Sale Date", '=%1', SaleLinePOS.Date);
        SaleLinePOSAddOn.SetFilter("Sale Line No.", '=%1', SaleLinePOS."Line No.");
        if (not SaleLinePOSAddOn.FindFirst()) then
            exit(false);

        IntermediaryWalletLine.SetCurrentKey(SaleHeaderSystemId, LineNumber);
        IntermediaryWalletLine.SetFilter(SaleHeaderSystemId, '=%1', SaleId);
        IntermediaryWalletLine.SetFilter(LineNumber, '=%1', SaleLinePOSAddOn."Applies-to Line No.");
        IntermediaryWalletLine.SetFilter(WalletNumber, '=%1', WalletNumber);
        IntermediaryWalletLine.SetFilter(ActionType, '=%1', IntermediaryWalletLine.ActionType::CREATE);
        exit(not IntermediaryWalletLine.IsEmpty());
    end;

    internal procedure RemoveIntermediateWalletsForLine(SaleId: Guid; SaleLineNumber: Integer; TargetQuantity: Integer)
    var
        IntermediaryWallet: Record "NPR AttractionWalletSaleHdr";
        IntermediaryWalletLine: Record "NPR AttractionWalletSaleLine";
        CurrentCount: Integer;
    begin
        IntermediaryWalletLine.SetCurrentKey(SaleHeaderSystemId, LineNumber, WalletNumber);
        IntermediaryWalletLine.SetFilter(SaleHeaderSystemId, '=%1', SaleId);
        IntermediaryWalletLine.SetFilter(LineNumber, '=%1', SaleLineNumber);
        IntermediaryWalletLine.SetFilter(ActionType, '=%1', IntermediaryWalletLine.ActionType::CREATE);
        CurrentCount := IntermediaryWalletLine.Count();
        if (CurrentCount <= TargetQuantity) then
            exit;

        TargetQuantity := CurrentCount - TargetQuantity;

        // Delete wallets without reference number first (backwards)
        if (IntermediaryWalletLine.Find('+')) then
            repeat
                IntermediaryWallet.Get(IntermediaryWalletLine.SaleHeaderSystemId, IntermediaryWalletLine.WalletNumber);
                if (IntermediaryWallet.ReferenceNumber = '') then begin
                    DeleteIntermediateWalletLine(IntermediaryWalletLine);
                    TargetQuantity -= 1;
                end
            until (IntermediaryWalletLine.Next(-1) = 0) or (TargetQuantity = 0);

        if (TargetQuantity <= 0) then
            exit;

        // Delete wallets with reference number (backwards)
        if (IntermediaryWalletLine.Find('+')) then begin
            repeat
                DeleteIntermediateWalletLine(IntermediaryWalletLine);
                TargetQuantity -= 1;
            until (IntermediaryWalletLine.Next(-1) = 0) or (TargetQuantity = 0);
        end;

    end;

    internal procedure DeleteIntermediateWalletLine(IntermediaryWalletLine: Record "NPR AttractionWalletSaleLine")
    var
        IntermediaryWallet: Record "NPR AttractionWalletSaleHdr";
        IntermediaryWalletLine2: Record "NPR AttractionWalletSaleLine";
    begin
        if (not IntermediaryWalletLine.Delete()) then
            exit;

        IntermediaryWalletLine2.SetCurrentKey(SaleHeaderSystemId, WalletNumber);
        IntermediaryWalletLine2.SetFilter(SaleHeaderSystemId, '=%1', IntermediaryWalletLine.SaleHeaderSystemId);
        IntermediaryWalletLine2.SetFilter(WalletNumber, '=%1', IntermediaryWalletLine.WalletNumber);
        if (IntermediaryWalletLine2.IsEmpty()) then
            if (IntermediaryWallet.Get(IntermediaryWalletLine.SaleHeaderSystemId, IntermediaryWalletLine.WalletNumber)) then
                IntermediaryWallet.Delete();
    end;
}