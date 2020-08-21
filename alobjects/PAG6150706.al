page 6150706 "POS Action Workflow"
{
    AutoSplitKey = true;
    Caption = 'POS Action Workflow';
    PageType = List;
    SourceTable = "POS Action Workflow";

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

