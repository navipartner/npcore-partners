page 6014444 "Quantity Discount Line"
{
    Caption = 'Multiple Unit Price';
    PageType = CardPart;
    SourceTable = "Quantity Discount Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Quantity;Quantity)
                {
                }
                field("Unit Price";"Unit Price")
                {
                }
                field(Total;Total)
                {
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

