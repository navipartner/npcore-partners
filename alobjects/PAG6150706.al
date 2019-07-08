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
                field(Type;Type)
                {
                }
                field("Action Code";"Action Code")
                {
                }
                field("Condition Type";"Condition Type")
                {
                }
            }
        }
    }

    actions
    {
    }
}

