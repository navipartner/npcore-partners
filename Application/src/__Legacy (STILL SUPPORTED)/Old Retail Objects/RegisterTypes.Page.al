page 6014575 "NPR Register Types"
{
    // NPR5.30/TJ  /20170215 CASE 265504 Changed page ENU caption

    Caption = 'Cash Register Types';
    SourceTable = "NPR Register Types";

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
            }
        }
    }

    actions
    {
    }
}

