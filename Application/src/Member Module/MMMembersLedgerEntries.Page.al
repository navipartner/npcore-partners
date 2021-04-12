page 6060129 "NPR MM Members. Ledger Entries"
{

    Caption = 'Membership Ledger Entries';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = ListPart;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR MM Membership Entry";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                Editable = false;
                field("Activate On First Use"; Rec."Activate On First Use")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Activate On First Use field';
                }
                field("Valid From Date"; Rec."Valid From Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Valid From Date field';
                }
                field("Valid Until Date"; Rec."Valid Until Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Valid Until Date field';
                }
                field("Created At"; Rec."Created At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Created At field';
                }
                field(Context; Rec.Context)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Context field';
                }
                field("Receipt No."; Rec."Receipt No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Receipt No. field';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document No. field';
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item No. field';
                }
                field("Membership Code"; Rec."Membership Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Membership Code field';
                }
                field("Auto-Renew Entry No."; Rec."Auto-Renew Entry No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Auto-Renew Entry No. field';
                }
                field(RemainingAmountLCY; RemainingAmountLCY)
                {
                    ApplicationArea = All;
                    Caption = 'Remaining Amount (LCY)';
                    Editable = false;
                    Style = Unfavorable;
                    StyleExpr = AccentuateAmount;
                    ToolTip = 'Specifies the value of the Remaining Amount (LCY) field';
                }
                field(Blocked; Rec.Blocked)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Blocked field';
                }
                field("Blocked At"; Rec."Blocked At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Blocked At field';
                }
                field("Blocked By"; Rec."Blocked By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Blocked By field';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin

        AccentuateAmount := false;
        if (Rec.CalculateRemainingAmount(OriginalAmountLCY, RemainingAmountLCY, DueDate)) then
            AccentuateAmount := ((RemainingAmountLCY > 0) and (DueDate < Today));
    end;

    var
        RemainingAmountLCY: Decimal;
        OriginalAmountLCY: Decimal;
        DueDate: Date;
        AccentuateAmount: Boolean;
}

