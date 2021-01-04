page 6014538 "NPR Insurance Companies"
{
    Caption = 'Insurance - Companies';
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR Insurance Companies";

    layout
    {
        area(content)
        {
            repeater(Control6150614)
            {
                ShowCaption = false;
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
            }
        }
    }

    actions
    {
    }
}

