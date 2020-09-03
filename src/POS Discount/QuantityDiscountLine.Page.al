page 6014444 "NPR Quantity Discount Line"
{
    Caption = 'Multiple Unit Price';
    PageType = CardPart;
    SourceTable = "NPR Quantity Discount Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                }
                field("Unit Price"; "Unit Price")
                {
                    ApplicationArea = All;
                }
                field(Total; Total)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetCurrRecord()
    begin
        CalcFields("Price Includes VAT");
    end;

    trigger OnAfterGetRecord()
    begin
        CalcFields("Price Includes VAT");
    end;

    var
        Text10600000: Label 'You must enter an amount in the unit price!';
        Text10600001: Label 'You must enter the unit cost to Item %1 on the item card!';
}

