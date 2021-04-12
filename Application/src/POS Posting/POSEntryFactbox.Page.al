page 6150671 "NPR POS Entry Factbox"
{
    Caption = 'POS Entry Factbox';
    PageType = CardPart;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR POS Entry";

    layout
    {
        area(content)
        {
            field("Currency Code"; Rec."Currency Code")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Currency Code field';
            }
            field("Item Sales (LCY)"; Rec."Item Sales (LCY)")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Item Sales (LCY) field';

                trigger OnDrillDown()
                begin
                    SaleDetail(1);
                end;
            }
            field("Customer Sales (LCY)"; Rec."Customer Sales (LCY)")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Customer Sales (LCY) field';
            }
            field("G/L Sales (LCY)"; Rec."G/L Sales (LCY)")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the G/L Sales (LCY) field';
            }
            field("Discount Amount"; Rec."Discount Amount")
            {
                ApplicationArea = All;
                Caption = 'Disc. Amt Excl. VAT';
                ToolTip = 'Specifies the value of the Disc. Amt Excl. VAT field';
            }
            field("Amount Incl. Tax"; Rec."Amount Incl. Tax")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Amount Incl. Tax field';
            }
            field("Amount Excl. Tax"; Rec."Amount Excl. Tax")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Amount Excl. Tax field';
            }
            field("Tax Amount"; Rec."Tax Amount")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Tax Amount field';

                trigger OnDrillDown()
                begin
                    TaxDetail;
                end;
            }
            field("Rounding Amount (LCY)"; Rec."Rounding Amount (LCY)")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Rounding Amount (LCY) field';
            }
            field("Payment Amount"; Rec."Payment Amount")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Payment Amount field';
            }
            field("Sales Quantity"; Rec."Sales Quantity")
            {
                ApplicationArea = All;
                DecimalPlaces = 0 : 2;
                ToolTip = 'Specifies the value of the Sales Quantity field';
            }
            field("Return Sales Quantity"; Rec."Return Sales Quantity")
            {
                ApplicationArea = All;
                DecimalPlaces = 0 : 2;
                ToolTip = 'Specifies the value of the Return Sales Quantity field';
            }
            field("Sale Lines"; Rec."Sale Lines")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Sale Lines field';
            }
            field("Payment Lines"; Rec."Payment Lines")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Payment Lines field';
            }
            field("Tax Lines"; Rec."Tax Lines")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Tax Lines field';
            }
            field("No. of Print Output Entries"; Rec."No. of Print Output Entries")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the No. of Print Output Entries field';
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        if Rec."Discount Amount" = 0 then
            UpdateDiscountAmt;
    end;

    local procedure TaxDetail()
    var
        TaxAmountLine: Record "NPR POS Entry Tax Line";
    begin
        TaxAmountLine.Reset();
        TaxAmountLine.SetRange("POS Entry No.", Rec."Entry No.");
        PAGE.Run(0, TaxAmountLine);
    end;

    local procedure SaleDetail(Type: Integer)
    var
        SalesLine: Record "NPR POS Entry Sales Line";
    begin
        SalesLine.Reset();
        SalesLine.SetRange("POS Entry No.", Rec."Entry No.");
        case Type of
            1:
                SalesLine.SetRange(Type, SalesLine.Type::Item);
        end;
        PAGE.Run(0, SalesLine);
    end;

    local procedure UpdateDiscountAmt()
    var
        POSSalesLine: Record "NPR POS Entry Sales Line";
    begin
        POSSalesLine.Reset();
        POSSalesLine.SetRange("POS Entry No.", Rec."Entry No.");
        if POSSalesLine.FindSet() then begin
            repeat
                Rec."Discount Amount" += POSSalesLine."Line Discount Amount Excl. VAT";
            until POSSalesLine.Next() = 0;
        end;
    end;
}

