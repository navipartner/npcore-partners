page 6150732 "NPR POS Scenarios Sets"
{

    Caption = 'POS Scenarios Sets';
    CardPageID = "NPR POS Scenarios Set Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR POS Sales Workflow Set";
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
            }
        }
    }

    actions
    {
    }
}

