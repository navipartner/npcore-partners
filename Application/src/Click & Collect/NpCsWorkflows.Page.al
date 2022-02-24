page 6151197 "NPR NpCs Workflows"
{
    Extensible = False;
    Caption = 'Collect Workflows';
    CardPageID = "NPR NpCs Workflow Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR NpCs Workflow";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the Code for the Collect Workflow.';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the Description of the Collect Workflow.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}

