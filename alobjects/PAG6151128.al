page 6151128 "NpIa Item AddOn Line Options"
{
    // NPR5.48/JAVA/20190205  CASE 334922 Transport NPR5.48 - 5 February 2019

    AutoSplitKey = true;
    Caption = 'Item AddOn Line Options';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "NpIa Item AddOn Line Option";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Item No.";"Item No.")
                {
                }
                field("Variant Code";"Variant Code")
                {
                }
                field(Description;Description)
                {
                }
                field("Description 2";"Description 2")
                {
                }
                field(Quantity;Quantity)
                {
                }
            }
        }
    }

    actions
    {
    }
}

