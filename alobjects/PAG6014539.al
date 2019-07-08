page 6014539 "Insurance Category"
{
    Caption = 'Insurance Category';
    PageType = List;
    SourceTable = "Insurance Category";

    layout
    {
        area(content)
        {
            repeater(Control6150614)
            {
                ShowCaption = false;
                field(Kategori;Kategori)
                {
                }
                field("Calculation Type";"Calculation Type")
                {
                }
            }
        }
    }

    actions
    {
    }
}

