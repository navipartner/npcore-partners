page 6151238 "NPR BinTransferJournalPos"
{
    Caption = 'POS Payment Bin Transfer Journal (POS)';
    PageType = List;
    UsageCategory = None;
    SourceTable = "NPR BinTransferJournal";
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
                field(TransferFromBinCode; Rec.TransferFromBinCode)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Transfer From Bin Code field.';
                }
                field(TransferToBinCode; Rec.TransferToBinCode)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Transfer To Bin Code field.';
                }
                field(PaymentMethod; Rec.PaymentMethod)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Payment Method field.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Amount field.';
                }
                field(ExternalDocumentNo; Rec.ExternalDocumentNo)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value if the External Document No field.';
                    Editable = true;
                }
                field(HasDenomination; Rec.HasDenomination)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Has Denomination field.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Receive)
            {
                Caption = 'Receive';
                ApplicationArea = NPRRetail;
                ToolTip = 'This action receives the transfer into the payment bin.';
                Image = Approve;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Scope = Repeater;
                trigger OnAction();
                var
                    BinTransferAnPost: Codeunit "NPR BinTransferPost";
                begin
                    BinTransferAnPost.ReceiveToPaymentBin(Rec.EntryNo);
                    CurrPage.Update(false);
                end;
            }
            action(Print)
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
                begin
                    BinTransferAnPost.ReleasePrint(Rec.EntryNo);
                end;
            }
        }
        area(Navigation)
        {
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
            action(PostedTransfers)
            {
                Caption = 'Posted POS Payment Bin Entries';
                ApplicationArea = NPRRetail;
                ToolTip = 'Navigate to Posted POS Payment Transfer Entries.';
                Image = GeneralLedger;
                Scope = Repeater;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                RunObject = page "NPR PostedBinTransferJournal";
            }

        }
    }

    trigger OnOpenPage()
    begin
        Rec.SetFilter(Status, '=%1', Rec.Status::RELEASED);
    end;
}