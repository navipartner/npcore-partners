page 6150706 "NPR POS Action Workflow"
{
    AutoSplitKey = true;
    Caption = 'POS Action Workflow';
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR POS Action Workflow";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("Action Code"; "Action Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Action Code field';
                }
                field("Condition Type"; "Condition Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Condition Type field';
                }
            }
        }
    }

    actions
    {
    }
}

