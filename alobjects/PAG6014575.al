page 6014575 "Register Types"
{
    // NPR5.30/TJ  /20170215 CASE 265504 Changed page ENU caption

    Caption = 'Cash Register Types';
    SourceTable = "Register Types";

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
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

