page 6151207 "NpCs Collect Store Order Lines"
{
    // NPR5.50/MHA /20190531  CASE 345261 Object created - Collect in Store

    Caption = 'Lines';
    Editable = false;
    PageType = ListPart;
    SourceTable = "Sales Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type;Type)
                {
                }
                field("No.";"No.")
                {
                }
                field(Description;Description)
                {
                }
                field("Variant Code";"Variant Code")
                {
                }
                field("Description 2";"Description 2")
                {
                }
                field("Unit of Measure";"Unit of Measure")
                {
                }
                field(Quantity;Quantity)
                {
                }
                field("Unit Price";"Unit Price")
                {
                }
                field("Line Amount";"Line Amount")
                {
                }
            }
        }
    }

    actions
    {
    }
}

