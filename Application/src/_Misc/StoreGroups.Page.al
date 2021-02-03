page 6014582 "NPR Store Groups"
{
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
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Blank Location"; Rec."Blank Location")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Blank Location field';
                }
            }
        }
    }
}

