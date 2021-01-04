page 6151197 "NPR NpCs Workflows"
{
    Caption = 'Collect Workflows';
    CardPageID = "NPR NpCs Workflow Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR NpCs Workflow";
    UsageCategory = Administration;

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
}

