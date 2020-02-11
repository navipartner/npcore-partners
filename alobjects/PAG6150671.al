page 6150671 "POS Entry Factbox"
{
    // NPR5.39/BR  /20180129  CASE 302696 Object Created
    // NPR5.53/SARA/20191024  CASE 373672 Change request to POS List
    // NPR5.53/SARA/20200127  CASE 387442 Added field "No. of Print Output Entries"

    Caption = 'POS Entry Factbox';
    PageType = CardPart;
    SourceTable = "POS Entry";

    layout
    {
        area(content)
        {
            field("Currency Code";"Currency Code")
            {
            }
            field("Item Sales (LCY)";"Item Sales (LCY)")
            {

                trigger OnDrillDown()
                begin
                    //-NPR5.53 [373672]
                    SaleDetail(1);
                    //+NPR5.53 [373672]
                end;
            }
            field("Customer Sales (LCY)";"Customer Sales (LCY)")
            {
            }
            field("G/L Sales (LCY)";"G/L Sales (LCY)")
            {
            }
            field("Discount Amount";"Discount Amount")
            {
            }
            field("Amount Incl. Tax";"Amount Incl. Tax")
            {
            }
            field("Amount Excl. Tax";"Amount Excl. Tax")
            {
            }
            field("Tax Amount";"Tax Amount")
            {

                trigger OnDrillDown()
                begin
                    //-NPR5.53 [373672]
                    TaxDetail;
                    //+NPR5.53 [373672]
                end;
            }
            field("Rounding Amount (LCY)";"Rounding Amount (LCY)")
            {
            }
            field("Payment Amount";"Payment Amount")
            {
            }
            field("Sales Quantity";"Sales Quantity")
            {
                DecimalPlaces = 0:2;
            }
            field("Return Sales Quantity";"Return Sales Quantity")
            {
                DecimalPlaces = 0:2;
            }
            field("Sale Lines";"Sale Lines")
            {
            }
            field("Payment Lines";"Payment Lines")
            {
            }
            field("Tax Lines";"Tax Lines")
            {
            }
            field("No. of Print Output Entries";"No. of Print Output Entries")
            {
            }
        }
    }

    actions
    {
    }

    local procedure TaxDetail()
    var
        TaxAmountLine: Record "POS Tax Amount Line";
    begin
        TaxAmountLine.Reset;
        TaxAmountLine.SetRange("POS Entry No.","Entry No.");
        PAGE.Run(0,TaxAmountLine);
    end;

    local procedure SaleDetail(Type: Integer)
    var
        SalesLine: Record "POS Sales Line";
    begin
        SalesLine.Reset;
        SalesLine.SetRange("POS Entry No.","Entry No.");
        case Type of
          1: SalesLine.SetRange(Type,SalesLine.Type::Item);
        end;
        PAGE.Run(0,SalesLine);
    end;
}

