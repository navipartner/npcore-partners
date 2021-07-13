page 6150671 "NPR POS Entry Factbox"
{
    Caption = 'POS Entry Factbox';
    PageType = CardPart;
    UsageCategory = Administration;

    SourceTable = "NPR POS Entry";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            field("Currency Code"; Rec."Currency Code")
            {

                ToolTip = 'Specifies the value of the Currency Code field';
                ApplicationArea = NPRRetail;
            }
            field("Item Sales (LCY)"; Rec."Item Sales (LCY)")
            {

                ToolTip = 'Specifies the value of the Item Sales (LCY) field';
                ApplicationArea = NPRRetail;

                trigger OnDrillDown()
                begin
                    SaleDetail(1);
                end;
            }
            field("Customer Sales (LCY)"; Rec."Customer Sales (LCY)")
            {

                ToolTip = 'Specifies the value of the Customer Sales (LCY) field';
                ApplicationArea = NPRRetail;
            }
            field("G/L Sales (LCY)"; Rec."G/L Sales (LCY)")
            {

                ToolTip = 'Specifies the value of the G/L Sales (LCY) field';
                ApplicationArea = NPRRetail;
            }
            field("Discount Amount"; Rec."Discount Amount")
            {

                Caption = 'Disc. Amt Excl. VAT';
                ToolTip = 'Specifies the value of the Disc. Amt Excl. VAT field';
                ApplicationArea = NPRRetail;
            }
            field("Amount Incl. Tax"; Rec."Amount Incl. Tax")
            {

                ToolTip = 'Specifies the value of the Amount Incl. Tax field';
                ApplicationArea = NPRRetail;
            }
            field("Amount Excl. Tax"; Rec."Amount Excl. Tax")
            {

                ToolTip = 'Specifies the value of the Amount Excl. Tax field';
                ApplicationArea = NPRRetail;
            }
            field("Tax Amount"; Rec."Tax Amount")
            {

                ToolTip = 'Specifies the value of the Tax Amount field';
                ApplicationArea = NPRRetail;

                trigger OnDrillDown()
                begin
                    TaxDetail();
                end;
            }
            field("Rounding Amount (LCY)"; Rec."Rounding Amount (LCY)")
            {

                ToolTip = 'Specifies the value of the Rounding Amount (LCY) field';
                ApplicationArea = NPRRetail;
            }
            field("Payment Amount"; Rec."Payment Amount")
            {

                ToolTip = 'Specifies the value of the Payment Amount field';
                ApplicationArea = NPRRetail;
            }
            field("Sales Quantity"; Rec."Sales Quantity")
            {

                DecimalPlaces = 0 : 2;
                ToolTip = 'Specifies the value of the Sales Quantity field';
                ApplicationArea = NPRRetail;
            }
            field("Return Sales Quantity"; Rec."Return Sales Quantity")
            {

                DecimalPlaces = 0 : 2;
                ToolTip = 'Specifies the value of the Return Sales Quantity field';
                ApplicationArea = NPRRetail;
            }
            field("Sale Lines"; Rec."Sale Lines")
            {

                ToolTip = 'Specifies the value of the Sale Lines field';
                ApplicationArea = NPRRetail;
            }
            field("Payment Lines"; Rec."Payment Lines")
            {

                ToolTip = 'Specifies the value of the Payment Lines field';
                ApplicationArea = NPRRetail;
            }
            field("EFT Transaction Requests"; Rec."EFT Transaction Requests")
            {
                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies the value of the EFT Transaction field';

            }
            field("Tax Lines"; Rec."Tax Lines")
            {

                ToolTip = 'Specifies the value of the Tax Lines field';
                ApplicationArea = NPRRetail;
            }
            field("No. of Print Output Entries"; Rec."No. of Print Output Entries")
            {

                ToolTip = 'Specifies the value of the No. of Print Output Entries field';
                ApplicationArea = NPRRetail;
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        if Rec."Discount Amount" = 0 then
            UpdateDiscountAmt();
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

