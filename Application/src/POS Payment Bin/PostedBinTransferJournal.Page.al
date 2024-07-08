page 6151243 "NPR PostedBinTransferJournal"
{
    Caption = 'Posted POS Payment Bin Transfer Journal';
    PageType = List;
    ApplicationArea = NPRRetail;
    UsageCategory = History;
    SourceTable = "NPR PostedBinTransferEntry";
    Extensible = false;
    Editable = false;
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
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Description field.';
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
                }
                field(TransferFromBinCode; Rec.TransferFromBinCode)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Transfer From Bin Code field.';
                    ShowMandatory = true;
                }
                field(ReceiveAtPosUnitCode; Rec.ReceiveAtPosUnitCode)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Receive From Pos Unit Code field.';
                }
                field(TransferToBinCode; Rec.TransferToBinCode)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Transfer To Bin Code field.';
                    ShowMandatory = true;
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
                field(CreatedBy; Rec.CreatedBy)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Created By field.';
                }

                field(TransferredBy; Rec.TransferredBy)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Transferred By field.';
                }
                field(TransferDate; Rec.TransferredAt)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Transfer Datetime field.';
                }
                field(EntryNo; Rec.EntryNo)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Entry No. field.';
                }

            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(GLEntries)
            {
                Caption = 'General Ledger Entries';
                ApplicationArea = NPRRetail;
                ToolTip = 'Navigate to associated general ledger entries.';
                Image = GeneralLedger;
                Scope = Repeater;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = Category4;
                RunObject = page "General Ledger Entries";
                RunPageLink = "Document No." = field(DocumentNo);
            }

            action(BinEntries)
            {
                Caption = 'Payment Bin Entries';
                ApplicationArea = NPRRetail;
                ToolTip = 'Navigate to associated bin payment entries.';
                Image = BinLedger;
                Scope = Repeater;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = Category4;
                RunObject = page "NPR POS Bin Entries";
                RunPageView = sorting("Entry No.") order(descending);
            }
            action(Denomination)
            {
                Caption = 'Show Denomination';
                ApplicationArea = NPRRetail;
                ToolTip = 'Show the denominations transferred.';
                Image = CashFlow;
                Scope = Repeater;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                RunObject = page "NPR BinTransferDenomination";
                RunPageLink = EntryNo = field(EntryNo);
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
                    PostedBinTransfer: Record "NPR PostedBinTransferEntry";
                begin
                    CurrPage.SetSelectionFilter(PostedBinTransfer);
                    PostedBinTransfer.FindSet(true);
                    repeat
                        BinTransferAnPost.ReceivePrint(Rec.EntryNo);
                    until (PostedBinTransfer.Next() = 0);
                end;
            }
        }
    }

    var
        _EditAmount: Boolean;

    trigger OnAfterGetCurrRecord()
    begin
        //Rec.CalcFields(HasDenomination);
        _EditAmount := not Rec.HasDenomination;
    end;

}
