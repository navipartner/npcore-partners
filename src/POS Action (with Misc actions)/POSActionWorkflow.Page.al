page 6150706 "NPR POS Action Workflow"
{
    AutoSplitKey = true;
    Caption = 'POS Action Workflow';
    PageType = List;
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
                }
                field("Action Code"; "Action Code")
                {
                    ApplicationArea = All;
                }
                field("Condition Type"; "Condition Type")
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

