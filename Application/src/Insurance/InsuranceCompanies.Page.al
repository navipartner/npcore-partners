page 6014538 "NPR Insurance Companies"
{
    Caption = 'Insurance - Companies';
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR Insurance Companies";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Control6150614)
            {
                ShowCaption = false;
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

