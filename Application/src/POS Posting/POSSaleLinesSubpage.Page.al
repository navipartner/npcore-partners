page 6150748 "NPR POS Sale Lines Subpage"
{
    Caption = 'POS Sale Lines';
    Editable = false;
    PageType = ListPart;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR POS Sale Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Sale Type"; Rec."Sale Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sale Type field';
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Line No. field';
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Quantity field';
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Unit Price field';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount field';
                }
                field("Amount Including VAT"; Rec."Amount Including VAT")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount Including VAT field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(ShowDocument)
            {
                Caption = 'Show Document';
                Image = ViewDetails;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Show Document action';

                trigger OnAction()
                var
                    SalePOS: Record "NPR POS Sale";
                begin
                    SalePOS.Get(Rec."Register No.", Rec."Sales Ticket No.");
                    PAGE.Run(PAGE::"NPR Unfinished POS Sale Trx", SalePOS);
                end;
            }
            action(ShowTaxCalculation)
            {
                Caption = 'Show Sales Tax Calculation';
                Image = TaxDetail;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Show sales tax calculation for active sale line.';

                trigger OnAction()
                var
                    POSSaleTaxCalc: codeunit "NPR POS Sale Tax Calc.";
                begin
                    POSSaleTaxCalc.Show(Rec.SystemId);
                end;
            }
        }
    }
}
