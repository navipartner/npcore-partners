page 6059839 "NPR EFT Recon. Trans. List"
{
    Caption = 'EFT Recon. Trans. List';
    Editable = false;
    PageType = ListPart;
    SaveValues = false;
    SourceTable = "NPR EFT Transaction Request";
    SourceTableTemporary = true;
    SourceTableView = sorting("DCC Amount")
                      order(descending);

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Score; Rec."DCC Amount")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Score';
                    ToolTip = 'Specifies the value of the Score field';
                }
                field(POSPaymentTypeCode; Rec."POS Payment Type Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the POS Payment Type Code field';
                }
                field(AcquirerID; Rec."Acquirer ID")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Acquirer ID field';
                }
                field(ReconciliationID; Rec."Reconciliation ID")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Reconciliation ID field';
                }
                field(CardNumber; Rec."Card Number")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Card Number field';
                }
                field(ReferenceNumberOutput; Rec."Reference Number Output")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Reference Number Output field';
                }
                field(HardwareID; Rec."Hardware ID")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Hardware ID field';
                }
                field(TransactionDate; Rec."Transaction Date")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Transaction Date field';
                }
                field(ResultAmount; Rec."Result Amount")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Result Amount field';
                }
                field(EntryNo; Rec."Entry No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
            }
        }
    }

    actions
    {
    }


    procedure SetPageData(var TempEFTTransactionRequest: Record "NPR EFT Transaction Request" temporary)
    begin
        if not Rec.IsTemporary then
            Error('Table not temporary');
        Rec.DeleteAll();
        if TempEFTTransactionRequest.FindSet() then
            repeat
                Rec := TempEFTTransactionRequest;
                Rec.Insert();
            until TempEFTTransactionRequest.Next() = 0;
        CurrPage.Update(false);
    end;
}

