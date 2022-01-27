page 6014539 "NPR Insurance Category"
{
    Extensible = False;
    Caption = 'Insurance Category';
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR Insurance Category";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Control6150614)
            {
                ShowCaption = false;
                field(Kategori; Rec.Kategori)
                {

                    ToolTip = 'Specifies the value of the Category field';
                    ApplicationArea = NPRRetail;
                }
                field("Calculation Type"; Rec."Calculation Type")
                {

                    ToolTip = 'Specifies the value of the Calculation Type field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

