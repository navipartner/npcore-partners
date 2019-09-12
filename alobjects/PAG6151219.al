page 6151219 "NpCs Collect Store Inv. Lines"
{
    // NPR5.51/MHA /20190821  CASE 364557 Object created - Collect in Store

    Caption = 'Lines';
    Editable = false;
    PageType = ListPart;
    SourceTable = "Sales Invoice Line";

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

