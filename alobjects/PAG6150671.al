page 6150671 "POS Entry Factbox"
{
    // NPR5.39/BR  /20180129  CASE 302696 Object Created
    // NPR5.53/SARA/20191024  CASE 373672 Change request to POS List
    // NPR5.53/SARA/20200127  CASE 387442 Added field "No. of Print Output Entries"
    // NPR5.54/SARA/20200324  CASE 393490 Calculate Discount Amount

    Caption = 'POS Entry Factbox';
    PageType = CardPart;
    SourceTable = "POS Entry";

    layout
    {
        area(content)
        {
            field("Currency Code"; "Currency Code")
            {
                ApplicationArea = All;
            }
            field("Item Sales (LCY)"; "Item Sales (LCY)")
            {
                ApplicationArea = All;

                trigger OnDrillDown()
                begin
                    //-NPR5.53 [373672]
                    SaleDetail(1);
                    //+NPR5.53 [373672]
                end;
            }
            field("Customer Sales (LCY)"; "Customer Sales (LCY)")
            {
                ApplicationArea = All;
            }
            field("G/L Sales (LCY)"; "G/L Sales (LCY)")
            {
                ApplicationArea = All;
            }
            field("Discount Amount"; "Discount Amount")
            {
                ApplicationArea = All;
                Caption = 'Disc. Amt Excl. VAT';
            }
            field("Amount Incl. Tax"; "Amount Incl. Tax")
            {
                ApplicationArea = All;
            }
            field("Amount Excl. Tax"; "Amount Excl. Tax")
            {
                ApplicationArea = All;
            }
            field("Tax Amount"; "Tax Amount")
            {
                ApplicationArea = All;

                trigger OnDrillDown()
                begin
                    //-NPR5.53 [373672]
                    TaxDetail;
                    //+NPR5.53 [373672]
                end;
            }
            field("Rounding Amount (LCY)"; "Rounding Amount (LCY)")
            {
                ApplicationArea = All;
            }
            field("Payment Amount"; "Payment Amount")
            {
                ApplicationArea = All;
            }
            field("Sales Quantity"; "Sales Quantity")
            {
                ApplicationArea = All;
                DecimalPlaces = 0 : 2;
            }
            field("Return Sales Quantity"; "Return Sales Quantity")
            {
                ApplicationArea = All;
                DecimalPlaces = 0 : 2;
            }
            field("Sale Lines"; "Sale Lines")
            {
                ApplicationArea = All;
            }
            field("Payment Lines"; "Payment Lines")
            {
                ApplicationArea = All;
            }
            field("Tax Lines"; "Tax Lines")
            {
                ApplicationArea = All;
            }
            field("No. of Print Output Entries"; "No. of Print Output Entries")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        //-NPR5.54 [393490]
        if "Discount Amount" = 0 then
            UpdateDiscountAmt;
        //+NPR5.54 [393490]
    end;

    local procedure TaxDetail()
    var
        TaxAmountLine: Record "POS Tax Amount Line";
    begin
        TaxAmountLine.Reset;
        TaxAmountLine.SetRange("POS Entry No.", "Entry No.");
        PAGE.Run(0, TaxAmountLine);
    end;

    local procedure SaleDetail(Type: Integer)
    var
        SalesLine: Record "POS Sales Line";
    begin
        SalesLine.Reset;
        SalesLine.SetRange("POS Entry No.", "Entry No.");
        case Type of
            1:
                SalesLine.SetRange(Type, SalesLine.Type::Item);
        end;
        PAGE.Run(0, SalesLine);
    end;

    local procedure UpdateDiscountAmt()
    var
        POSSalesLine: Record "POS Sales Line";
    begin
        //-NPR5.54 [393490]
        POSSalesLine.Reset;
        POSSalesLine.SetRange("POS Entry No.", "Entry No.");
        if POSSalesLine.FindSet then begin
            repeat
                "Discount Amount" += POSSalesLine."Line Discount Amount Excl. VAT";
            until POSSalesLine.Next = 0;
        end;
        //+NPR5.54 [393490]
    end;
}

