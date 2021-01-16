page 6014582 "NPR Store Groups"
{
    // NPR4.16/TJ/20151115 CASE 222281 Page Created

    Caption = 'Store Groups';
    PageType = List;
    SourceTable = "NPR Store Group";
    UsageCategory = Administration;
    ApplicationArea = All;

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
                field("Blank Location"; "Blank Location")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Blank Location field';
                }
            }
        }
    }

    actions
    {
    }
}

