page 6151197 "NPR NpCs Workflows"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
    Extensible = False;
    Caption = 'Collect Workflows';
    ContextSensitiveHelpPage = 'docs/retail/click_and_collect/how-to/workflow/';
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

