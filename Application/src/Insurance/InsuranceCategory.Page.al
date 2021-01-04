page 6014539 "NPR Insurance Category"
{
    Caption = 'Insurance Category';
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR Insurance Category";

    layout
    {
        area(content)
        {
            repeater(Control6150614)
            {
                ShowCaption = false;
                field(Kategori; Kategori)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Category field';
                }
                field("Calculation Type"; "Calculation Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Calculation Type field';
                }
            }
        }
    }

    actions
    {
    }
}

