page 6060129 "NPR MM Members. Ledger Entries"
{
    Extensible = False;

    Caption = 'Membership Ledger Entries';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = ListPart;
    UsageCategory = Administration;

    SourceTable = "NPR MM Membership Entry";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                Editable = false;
                field("Activate On First Use"; Rec."Activate On First Use")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Activate On First Use field';
                    ApplicationArea = NPRRetail;
                }
                field("Valid From Date"; Rec."Valid From Date")
                {

                    ToolTip = 'Specifies the value of the Valid From Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Valid Until Date"; Rec."Valid Until Date")
                {

                    ToolTip = 'Specifies the value of the Valid Until Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Created At"; Rec."Created At")
                {

                    ToolTip = 'Specifies the value of the Created At field';
                    ApplicationArea = NPRRetail;
                }
                field(Context; Rec.Context)
                {

                    ToolTip = 'Specifies the value of the Context field';
                    ApplicationArea = NPRRetail;
                }
                field("Receipt No."; Rec."Receipt No.")
                {

                    ToolTip = 'Specifies the value of the Receipt No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Document No."; Rec."Document No.")
                {

                    ToolTip = 'Specifies the value of the Document No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Item No."; Rec."Item No.")
                {

                    ToolTip = 'Specifies the value of the Item No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Membership Code"; Rec."Membership Code")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Membership Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Auto-Renew Entry No."; Rec."Auto-Renew Entry No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Auto-Renew Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field(RemainingAmountLCY; RemainingAmountLCY)
                {

                    Caption = 'Remaining Amount (LCY)';
                    Editable = false;
                    Style = Unfavorable;
                    StyleExpr = AccentuateAmount;
                    ToolTip = 'Specifies the value of the Remaining Amount (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field(Blocked; Rec.Blocked)
                {

                    ToolTip = 'Specifies the value of the Blocked field';
                    ApplicationArea = NPRRetail;
                }
                field("Blocked At"; Rec."Blocked At")
                {

                    ToolTip = 'Specifies the value of the Blocked At field';
                    ApplicationArea = NPRRetail;
                }
                field("Blocked By"; Rec."Blocked By")
                {

                    ToolTip = 'Specifies the value of the Blocked By field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Entries)
            {
                Caption = 'Membership Ledger Entries';
                ToolTip = 'Opens a list for the entries.';
                ApplicationArea = NPRRetail;
                Image = EditLines;
                RunObject = Page "NPR MM Edit Membership Entries";
                RunPageMode = Edit;
                RunPageLink = "Membership Entry No." = field("Membership Entry No.");
                RunPageView = sorting("Membership Entry No.") order(ascending);
            }
        }
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

