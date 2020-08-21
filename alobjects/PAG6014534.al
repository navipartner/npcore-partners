page 6014534 "Touch Screen - Return Reasons"
{
    // NPR4.15/TS/20151001 CASE 222137 Added Fields

    Caption = 'Return reasons';
    SourceTable = "Return Reason";

    layout
    {
        area(content)
        {
            repeater(Control6150616)
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

