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
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}

