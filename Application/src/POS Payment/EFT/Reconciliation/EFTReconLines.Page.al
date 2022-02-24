page 6059819 "NPR EFT Recon. Lines"
{
    Extensible = False;
    Caption = 'Reconciliation Lines';
    InsertAllowed = false;
    PageType = ListPart;
    SourceTable = "NPR EFT Recon. Line";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(TransactionDate; Rec."Transaction Date")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Transaction Date field';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Amount field';
                }
                field(FeeAmount; Rec."Fee Amount")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Fee field';
                }
                field(ApplicationAccountID; Rec."Application Account ID")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Application Account ID field';
                }
                field(CardNumber; Rec."Card Number")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Card Number field';
                }
                field(ReferenceNumber; Rec."Reference Number")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Reference Number field';
                }
                field(HardwareID; Rec."Hardware ID")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Hardware ID field';
                }
                field(ShortcutDimension1Code; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = NPRRetail;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Shortcut Dimension 1 Code field';
                }
                field(ShortcutDimension2Code; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = NPRRetail;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Shortcut Dimension 2 Code field';
                }
                field(AppliedEntryNo; Rec."Applied Entry No.")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Applied Entry No. field';
                }
                field(AppliedAmount; Rec."Applied Amount")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Applied Amount field';
                }
                field(AppliedFeeAmount; Rec."Applied Fee Amount")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Applied Fee Amount field';
                }
            }
        }
    }

    actions
    {
    }
}

