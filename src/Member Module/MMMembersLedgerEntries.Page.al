page 6060129 "NPR MM Members. Ledger Entries"
{
    // MM1.00/TSA/20151217  CASE 229684 NaviPartner Member Management Module
    // MM1.10/TSA/20160405  CASE 237393 Transport MM1.10 - 22 March 2016
    // MM1.17/TSA/20161208  CASE 259671 Added field "Activate On First Use"
    // MM1.23/NPKNAV/20171025  CASE 257011 Transport MM1.23 - 25 October 2017
    // MM1.30/TSA /20180615 CASE 319477 Added "Membership Code", "Item No."
    // MM1.34/TSA/20180927  CASE 327605 Transport MM1.34 - 27 September 2018

    Caption = 'Membership Ledger Entries';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = ListPart;
    SourceTable = "NPR MM Membership Entry";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                Editable = false;
                field("Activate On First Use"; "Activate On First Use")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Valid From Date"; "Valid From Date")
                {
                    ApplicationArea = All;
                }
                field("Valid Until Date"; "Valid Until Date")
                {
                    ApplicationArea = All;
                }
                field("Created At"; "Created At")
                {
                    ApplicationArea = All;
                }
                field(Context; Context)
                {
                    ApplicationArea = All;
                }
                field("Receipt No."; "Receipt No.")
                {
                    ApplicationArea = All;
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = All;
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = All;
                }
                field("Membership Code"; "Membership Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Auto-Renew Entry No."; "Auto-Renew Entry No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(RemainingAmountLCY; RemainingAmountLCY)
                {
                    ApplicationArea = All;
                    Caption = 'Remaining Amount (LCY)';
                    Editable = false;
                    Style = Unfavorable;
                    StyleExpr = AccentuateAmount;
                }
                field(Blocked; Blocked)
                {
                    ApplicationArea = All;
                }
                field("Blocked At"; "Blocked At")
                {
                    ApplicationArea = All;
                }
                field("Blocked By"; "Blocked By")
                {
                    ApplicationArea = All;
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

