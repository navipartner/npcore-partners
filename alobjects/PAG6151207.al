page 6151207 "NpCs Collect Store Order Lines"
{
    // NPR5.50/MHA /20190531  CASE 345261 Object created - Collect in Store
    // NPR5.53/MHA /20191106  CASE 376104 Replaced "No." with Text function GetNo() to increase column width a bit

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
                field("GetNo()";GetNo())
                {
                    Caption = 'No.';
                }
                field(Description;Description)
                {
                }
                field("Variant Code";"Variant Code")
                {
                    Visible = false;
                }
                field("Description 2";"Description 2")
                {
                }
                field("Unit of Measure";"Unit of Measure")
                {
                    Visible = false;
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

    local procedure GetNo(): Text
    begin
        //-NPR5.53 [376104]
        exit("No.");
        //+NPR5.53 [376104]
    end;
}

