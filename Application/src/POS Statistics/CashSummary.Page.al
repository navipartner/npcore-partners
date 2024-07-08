page 6150781 "NPR Cash Summary"
{
    Caption = 'Cash Summary';
    DeleteAllowed = false;
    Extensible = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "NPR Cash Summary Buffer";
    SourceTableTemporary = true;
    SourceTableView = sorting("Payment Bin No.", "Payment Method Code");
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("POS Unit No"; Rec."POS Unit No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the unique identifier for the POS unit.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the current status of the POS unit.';
                }
                field("Payment Bin No"; Rec."Payment Bin No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the unique identifier for the payment bin where cash is stored.';
                }
                field("Payment Method Code"; Rec."Payment Method Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the code representing the payment method used for cash stored in payment bins.';
                }
                field("Transaction Amount"; Rec."Transaction Amount")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the total amount of cash stored in the payment bins in the default currency.';
                }
                field("Transaction Amount (LCY)"; Rec."Transaction Amount (LCY)")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the total amount of cash stored in the payment bins in the local currency.';
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        POSStatisticsMgt: Codeunit "NPR POS Statistics Mgt.";
    begin
        POSStatisticsMgt.FillCashSummary(Rec);
        Rec.Reset();
    end;
}