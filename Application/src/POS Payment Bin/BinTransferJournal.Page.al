page 6151240 "NPR BinTransferJournal"
{
    Caption = 'POS Payment Bin Transfer Journal';
    PageType = Worksheet;
    ApplicationArea = NPRRetail;
    UsageCategory = Administration;
    SourceTable = "NPR BinTransferJournal";
    Extensible = false;
    DelayedInsert = true;
    PromotedActionCategories = 'New,Process,Report,Navigate,Print';
    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                Caption = 'GroupName';

                field(DocumentNo; Rec.DocumentNo)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Document No. field.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Status field.';
                    Editable = false;
                }
                field(StoreCode; Rec.StoreCode)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Store Code field.';
                    ShowMandatory = true;
                }
                field(ReceiveFromPosUnitCode; Rec.ReceiveFromPosUnitCode)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Receive From Pos Unit Code field.';

                    trigger OnValidate()
                    var
                        PosUnit: Record "NPR POS Unit";
                    begin
                        if (not (PosUnit.Get(Rec.ReceiveFromPosUnitCode))) then
                            exit;
                        Rec.TransferFromBinCode := PosUnit."Default POS Payment Bin";
                    end;
                }
                field(TransferFromBinCode; Rec.TransferFromBinCode)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Transfer From Bin Code field.';
                    ShowMandatory = true;

                    trigger OnValidate()
                    var
                        Bin: Record "NPR POS Payment Bin";
                    begin
                        Bin.Get(Rec.TransferFromBinCode);
                        if (Bin."Bin Type" = Bin."Bin Type"::CASH_DRAWER) then
                            Rec.TestField(ReceiveFromPosUnitCode);

                        if (Bin."Bin Type" <> Bin."Bin Type"::CASH_DRAWER) then
                            Clear(Rec.ReceiveFromPosUnitCode);
                    end;
                }
                field(ReceiveAtPosUnitCode; Rec.ReceiveAtPosUnitCode)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Receive From Pos Unit Code field.';

                    trigger OnValidate()
                    var
                        PosUnit: Record "NPR POS Unit";
                    begin
                        if (not (PosUnit.Get(Rec.ReceiveFromPosUnitCode))) then
                            exit;
                        Rec.ReceiveAtPosUnitCode := PosUnit."Default POS Payment Bin";
                    end;
                }
                field(TransferToBinCode; Rec.TransferToBinCode)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Transfer To Bin Code field.';
                    ShowMandatory = true;

                    trigger OnValidate()
                    var
                        Bin: Record "NPR POS Payment Bin";
                    begin
                        Bin.Get(Rec.TransferToBinCode);
                        if (Bin."Bin Type" = Bin."Bin Type"::CASH_DRAWER) then
                            Rec.TestField(ReceiveAtPosUnitCode);

                        if (Bin."Bin Type" <> Bin."Bin Type"::CASH_DRAWER) then
                            Clear(Rec.ReceiveAtPosUnitCode);
                    end;
                }
                field(PaymentMethod; Rec.PaymentMethod)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Payment Method field.';
                    ShowMandatory = true;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Amount field.';
                    Editable = _EditAmount;
                }
                field(ExternalDocumentNo; Rec.ExternalDocumentNo)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value if the External Document No field.';
                }
                field(HasDenomination; Rec.HasDenomination)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Has Denomination field.';
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Denomination)
            {
                Caption = 'Specify Denomination';
                ApplicationArea = NPRRetail;
                ToolTip = 'Specify the denominations to transfer.';
                Image = CashFlow;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Scope = Repeater;

                trigger OnAction()
                var
                    BinTransferAnPost: Codeunit "NPR BinTransferPost";
                    TransferDenomination: Record "NPR BinTransferDenomination";
                    TransferDenominationPage: Page "NPR BinTransferDenomination";
                    PageAction: Action;
                begin
                    Rec.TestField(PaymentMethod);

                    if (Rec.Status = Rec.Status::OPEN) then begin
                        BinTransferAnPost.InitPaymentMethodDenomination(Rec.PaymentMethod, Rec.EntryNo);
                        TransferDenominationPage.SetEditable();
                        Commit();
                    end;

                    TransferDenomination.FilterGroup(4);
                    TransferDenomination.SetFilter(EntryNo, '=%1', Rec.EntryNo);
                    TransferDenomination.FilterGroup(0);

                    TransferDenominationPage.SetTableView(TransferDenomination);
                    PageAction := TransferDenominationPage.RunModal();

                    Rec.CalcFields(DenominationSum);
                    Rec.Amount := Rec.DenominationSum;
                    CurrPage.Update(true);
                end;
            }
            action(Open)
            {
                Caption = 'Open';
                ApplicationArea = NPRRetail;
                ToolTip = 'This actions opens the bin transfer for editing.';
                Image = Edit;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Scope = Repeater;

                trigger OnAction();
                var
                    BinTransferAnPost: Codeunit "NPR BinTransferPost";
                    BinTransferJournal: Record "NPR BinTransferJournal";
                begin
                    CurrPage.SetSelectionFilter(BinTransferJournal);
                    BinTransferJournal.FindSet(true);
                    repeat
                        BinTransferAnPost.SetReleased(BinTransferJournal.EntryNo, false);
                    until (BinTransferJournal.Next() = 0);

                    CurrPage.Update(false);
                end;
            }
            action(Release)
            {
                Caption = 'Release';
                ApplicationArea = NPRRetail;
                ToolTip = 'This action releases the bin transfer and makes it available for the POS to process.';
                Image = Approve;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Scope = Repeater;

                trigger OnAction();
                var
                    BinTransferAnPost: Codeunit "NPR BinTransferPost";
                    BinTransferJournal: Record "NPR BinTransferJournal";
                begin
                    CurrPage.SetSelectionFilter(BinTransferJournal);
                    BinTransferJournal.FindSet(true);
                    repeat
                        BinTransferAnPost.SetReleased(BinTransferJournal.EntryNo, true);
                    until (BinTransferJournal.Next() = 0);

                    CurrPage.Update(false);
                end;
            }
            action(Receive)
            {
                Caption = 'Receive';
                ApplicationArea = NPRRetail;
                ToolTip = 'This actions transfer payment from source to target bin .';
                Image = Edit;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Scope = Repeater;
                Enabled = not NewBinTransfer or (Rec.ReceiveAtPosUnitCode = '');

                trigger OnAction();
                var
                    BinTransferAnPost: Codeunit "NPR BinTransferPost";
                    BinTransferJournal: Record "NPR BinTransferJournal";
                begin
                    CheckNewBintTransferNotEnabled();
                    CurrPage.SetSelectionFilter(BinTransferJournal);
                    BinTransferJournal.FindSet(true);
                    repeat
                        BinTransferAnPost.ReceiveToPaymentBin(BinTransferJournal.EntryNo);
                    until (BinTransferJournal.Next() = 0);

                    CurrPage.Update(false);
                end;
            }

            action(PostTransfer)
            {
                Caption = 'Transfer and Post to G/L';
                ApplicationArea = NPRRetail;
                ToolTip = 'This action transfers the amount to bin and posts the required entries to general ledger.';
                Image = TransferToGeneralJournal;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Scope = Repeater;
                Enabled = not NewBinTransfer or (Rec.ReceiveAtPosUnitCode = '');

                trigger OnAction();
                var
                    BinTransferAnPost: Codeunit "NPR BinTransferPost";
                    BinTransferJournal: Record "NPR BinTransferJournal";
                begin
                    CheckNewBintTransferNotEnabled();
                    CurrPage.SetSelectionFilter(BinTransferJournal);
                    BinTransferJournal.FindSet(true);
                    repeat
                        BinTransferAnPost.ReceiveToPaymentBinAndPost(BinTransferJournal.EntryNo);
                    until (BinTransferJournal.Next() = 0);

                    CurrPage.Update(false);
                end;
            }

            action(ReleasePrint)
            {
                Caption = 'Print Release Document';
                ApplicationArea = NPRRetail;
                ToolTip = 'This action prints transfer release document.';
                Image = PrintAcknowledgement;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category5;
                PromotedIsBig = true;
                Scope = Repeater;
                trigger OnAction();
                var
                    BinTransferAnPost: Codeunit "NPR BinTransferPost";
                    BinTransferJournal: Record "NPR BinTransferJournal";
                begin
                    CurrPage.SetSelectionFilter(BinTransferJournal);
                    BinTransferJournal.FindSet(true);
                    repeat
                        if (Rec.Status = Rec.Status::RELEASED) then
                            BinTransferAnPost.ReleasePrint(Rec.EntryNo);
                    until (BinTransferJournal.Next() = 0);
                end;
            }
            action(ReceivePrint)
            {
                Caption = 'Print Receive Document';
                ApplicationArea = NPRRetail;
                ToolTip = 'This action prints transfer receive document.';
                Image = PrintAcknowledgement;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category5;
                PromotedIsBig = true;
                Scope = Repeater;
                trigger OnAction();
                var
                    BinTransferAnPost: Codeunit "NPR BinTransferPost";
                    BinTransferJournal: Record "NPR BinTransferJournal";
                begin
                    CurrPage.SetSelectionFilter(BinTransferJournal);
                    BinTransferJournal.FindSet(true);
                    repeat
                        if (Rec.Status = Rec.Status::RECEIVED) then
                            BinTransferAnPost.ReceivePrint(Rec.EntryNo);
                    until (BinTransferJournal.Next() = 0);
                end;
            }
        }
        area(Navigation)
        {
            action(PostedTransfers)
            {
                Caption = 'Posted POS Payment Bin Entries';
                ApplicationArea = NPRRetail;
                ToolTip = 'Navigate to Posted POS Payment Transfer Entries.';
                Image = GeneralLedger;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                RunObject = page "NPR PostedBinTransferJournal";
            }
        }
    }

    var
        _EditAmount: Boolean;

    trigger OnAfterGetCurrRecord()
    begin
        Rec.CalcFields(DenominationSum);
        _EditAmount := (Rec.DenominationSum = 0);
    end;

    trigger OnOpenPage()
    var
        FeatureFlagsManagement: Codeunit "NPR Feature Flags Management";
        POSActionBinTransferB: Codeunit "NPR POS Action: Bin Transfer B";
    begin
        NewBinTransfer := FeatureFlagsManagement.IsEnabled(POSActionBinTransferB.NewBinTransferFeatureFlag());
    end;

    local procedure CheckNewBintTransferNotEnabled()
    var
        MustBePostedThroughPOSErr: Label 'This Bin Transfer IN transaction must be finished through POS.';
    begin
        if NewBinTransfer and (Rec.ReceiveAtPosUnitCode <> '') then
            Error(MustBePostedThroughPOSErr);
    end;

    var
        NewBinTransfer: Boolean;
}