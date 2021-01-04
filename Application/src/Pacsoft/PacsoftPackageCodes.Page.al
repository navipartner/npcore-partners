page 6014415 "NPR Pacsoft Package Codes"
{
    // PS1.00/LS/20141021  CASE  188056 : PacSoft Module Integration Created Page

    Caption = 'Pacsoft Package Codes';
    PageType = Worksheet;
    SourceTable = "NPR Pacsoft Package Code";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
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

