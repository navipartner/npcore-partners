page 6184875 "NPR AttractionWalletAssignment"
{
    Extensible = False;
    PageType = List;
    UsageCategory = None;
    SourceTable = "NPR AttractionWalletSaleLine";
    Caption = 'Attraction Wallet Assignment';
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            field(_SelectWalletReference; _SelectWalletReference)
            {
                Caption = 'Select Wallet';
                ToolTip = 'Specifies the value of the Select Wallet field.';
                ApplicationArea = NPRRetail;
                Editable = true;

                trigger OnLookup(var Text: Text): Boolean
                var
                    WalletList: page "NPR AttractionWalletSaleList";
                    IntermediaryWallet: Record "NPR AttractionWalletSaleHdr";
                    WalletManager: Codeunit "NPR AttractionWalletCreate";
                    PageAction: Action;
                begin
                    IntermediaryWallet.SetFilter(SaleHeaderSystemId, '=%1', Rec.SaleHeaderSystemId);
                    WalletList.SetTableView(IntermediaryWallet);
                    WalletList.Editable := false;
                    WalletList.LookupMode := true;
                    PageAction := WalletList.RunModal();
                    if (PageAction = Action::LookupCancel) then
                        error(''); // Cancel the lookup

                    WalletList.GetRecord(IntermediaryWallet);
                    ValidateNumberOfWallets();
                    WalletManager.AddIntermediateWalletLine(IntermediaryWallet, Rec.SaleLineId, Rec.LineNumber);
                end;

                trigger OnValidate()
                var
                    IntermediaryWallet: Record "NPR AttractionWalletSaleHdr";
                    WalletManager: Codeunit "NPR AttractionWalletCreate";
                    ExistingWallet: Record "NPR AttractionWallet";
                    WalletNumber: Integer;
                begin
                    ValidateNumberOfWallets();

                    // Relative Wallet Number
                    if (Evaluate(WalletNumber, _SelectWalletReference)) then
                        if (IntermediaryWallet.Get(Rec.SaleHeaderSystemId, WalletNumber)) then begin
                            WalletManager.AddIntermediateWalletLine(IntermediaryWallet, Rec.SaleLineId, Rec.LineNumber);
                            exit;
                        end;

                    // Existing Wallet, already added to intermediate wallet list
                    IntermediaryWallet.Reset();
                    IntermediaryWallet.SetCurrentKey(SaleHeaderSystemId, ReferenceNumber);
                    IntermediaryWallet.SetFilter(SaleHeaderSystemId, '=%1', Rec.SaleHeaderSystemId);
                    IntermediaryWallet.SetFilter(ReferenceNumber, '=%1', _SelectWalletReference);
                    if (IntermediaryWallet.FindFirst()) then begin
                        WalletManager.AddIntermediateWalletLine(IntermediaryWallet, Rec.SaleLineId, Rec.LineNumber);
                        exit;
                    end;

                    // Existing Wallet, not yet added to intermediate wallet list
                    ExistingWallet.SetCurrentKey(ReferenceNumber);
                    ExistingWallet.SetFilter(ReferenceNumber, '=%1', _SelectWalletReference);
                    if (not ExistingWallet.FindFirst()) then
                        error('Invalid reference number');

                    WalletManager.CreateIntermediateWalletForExistingWallet(
                        Rec.SaleHeaderSystemId, Rec.SaleLineId, Rec.LineNumber,
                        ExistingWallet.Description, ExistingWallet.ReferenceNumber, ExistingWallet.EntryNo);

                    _SelectWalletReference := '';
                    CurrPage.Update(false);

                end;

            }
            repeater(GroupName)
            {
                field(WalletNumber; Rec.WalletNumber)
                {
                    ToolTip = 'Specifies the value of the Wallet Number field.';
                    Editable = false;
                    ApplicationArea = NPRRetail;
                }

                field(_Name; _Name)
                {
                    Caption = 'Name';
                    ToolTip = 'Specifies the value of the Name field.';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    var
                        IntermediaryWallet: Record "NPR AttractionWalletSaleHdr";
                        Wallet: Record "NPR AttractionWallet";
                    begin
                        IntermediaryWallet.Get(Rec.SaleHeaderSystemId, Rec.WalletNumber);
                        IntermediaryWallet.Name := _Name;
                        IntermediaryWallet.Modify();
                        if (IntermediaryWallet.WalletEntryNo > 0) then begin
                            if (Wallet.Get(IntermediaryWallet.WalletEntryNo)) then begin
                                Wallet.Description := _Name;
                                Wallet.Modify();
                            end;
                        end;
                    end;
                }

                field(_ReferenceNumber; _ReferenceNumber)
                {
                    Caption = 'Reference Number';
                    ToolTip = 'Specifies the value of the Reference Number field.';
                    ApplicationArea = NPRRetail;
                    trigger OnValidate()
                    var
                        IntermediaryWallet: Record "NPR AttractionWalletSaleHdr";
                        ExistingWallet: Record "NPR AttractionWallet";
                    begin
                        ExistingWallet.SetCurrentKey(ReferenceNumber);
                        ExistingWallet.SetFilter(ReferenceNumber, '=%1', _ReferenceNumber);
                        if (not ExistingWallet.FindFirst()) then
                            error('Invalid reference number');

                        IntermediaryWallet.SetFilter(SaleHeaderSystemId, '=%1', Rec.SaleHeaderSystemId);
                        IntermediaryWallet.SetFilter(ReferenceNumber, '=%1', _ReferenceNumber);
                        if (IntermediaryWallet.FindFirst()) then
                            error('Reference number %1 is already in use on intermediate wallet %2', _ReferenceNumber, IntermediaryWallet.WalletNumber);

                        // Update intermediate wallet with info from existing wallet
                        IntermediaryWallet.Get(Rec.SaleHeaderSystemId, Rec.WalletNumber);
                        IntermediaryWallet.ReferenceNumber := _ReferenceNumber;
                        if (ExistingWallet.Description <> '') then
                            IntermediaryWallet.Name := ExistingWallet.Description;
                        IntermediaryWallet.WalletEntryNo := ExistingWallet.EntryNo;
                        IntermediaryWallet.Modify();
                        CurrPage.Update(false);
                    end;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CreateWallets)
            {
                Caption = 'Add Wallet';
                ToolTip = 'This action creates a wallet and assigns the item as its asset.';
                ApplicationArea = NPRRetail;
                Image = Create;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                    WalletHandler: Codeunit "NPR AttractionWalletCreate";
                begin
                    WalletHandler.CreateIntermediateWallet(_SaleHeaderSystemId, _SaleLineId, _LineNumber, 1, _MaxQuantity);
                    CurrPage.Update(false);
                end;
            }
            action(RemoveWallet)
            {
                Caption = 'Remove Wallet';
                ToolTip = 'This action removes the selected wallet from the sales line.';
                ApplicationArea = NPRRetail;
                Image = Delete;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Scope = Repeater;

                trigger OnAction()
                var
                    WalletHandler: Codeunit "NPR AttractionWalletCreate";
                begin
                    WalletHandler.DeleteIntermediateWalletLine(Rec);
                    CurrPage.Update(false);
                end;
            }

            action(AssignAll)
            {
                Caption = 'Assign All';
                ToolTip = 'This action assigns all wallets to the sales line.';
                ApplicationArea = NPRRetail;
                Image = AssemblyBOM;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                    WalletHandler: Codeunit "NPR AttractionWalletCreate";
                begin
                    WalletHandler.TopUpIntermediateWalletsForLine(Rec.SaleHeaderSystemId, Rec.SaleLineId, Rec.LineNumber, _MaxQuantity);
                    CurrPage.Update(false);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        IntermediaryWallet: Record "NPR AttractionWalletSaleHdr";
    begin
        if (not IntermediaryWallet.Get(Rec.SaleHeaderSystemId, Rec.WalletNumber)) then begin
            IntermediaryWallet.Init();
            IntermediaryWallet.SaleHeaderSystemId := Rec.SaleHeaderSystemId;
            IntermediaryWallet.WalletNumber := Rec.WalletNumber;
            IntermediaryWallet.Name := StrSubstNo('Wallet %1', Rec.WalletNumber);
            IntermediaryWallet.ReferenceNumber := '';
            IntermediaryWallet.Insert();
        end;

        _Name := IntermediaryWallet.Name;
        _ReferenceNumber := IntermediaryWallet.ReferenceNumber;
    end;

    local procedure ValidateNumberOfWallets()
    var
        IntermediaryWalletLine: Record "NPR AttractionWalletSaleLine";
        MaxWalletsExceeded: Label 'Maximum number of wallets assigned to this line has been reached';
        WalletCount: Integer;
    begin
        IntermediaryWalletLine.SetCurrentKey(SaleHeaderSystemId, LineNumber);
        IntermediaryWalletLine.SetFilter(SaleHeaderSystemId, '=%1', Rec.SaleHeaderSystemId);
        IntermediaryWalletLine.SetFilter(LineNumber, '=%1', Rec.LineNumber);
        WalletCount := IntermediaryWalletLine.Count();
        if (WalletCount >= _MaxQuantity) then
            error(MaxWalletsExceeded);
    end;

    internal procedure SetSalesContext(SaleHeaderSystemId: Guid; SaleLineId: Guid; LineNumber: Integer; MaxQuantity: Integer)
    begin
        _SaleHeaderSystemId := SaleHeaderSystemId;
        _SaleLineId := SaleLineId;
        _LineNumber := LineNumber;
        _MaxQuantity := MaxQuantity;
    end;

    var
        _Name: Text[100];
        _ReferenceNumber: Code[50];
        _SaleHeaderSystemId: Guid;
        _SaleLineId: Guid;
        _LineNumber: Integer;
        _MaxQuantity: Integer;
        _SelectWalletReference: Code[50];
}