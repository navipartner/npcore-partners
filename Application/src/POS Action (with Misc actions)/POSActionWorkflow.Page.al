page 6150706 "NPR POS Action Workflow"
{
    Extensible = False;
    AutoSplitKey = true;
    Caption = 'POS Action Workflow';
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR POS Action Workflow";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Rec.Type)
                {

                    ToolTip = 'Specifies the value of the Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Action Code"; Rec."Action Code")
                {

                    ToolTip = 'Specifies the value of the Action Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Condition Type"; Rec."Condition Type")
                {

                    ToolTip = 'Specifies the value of the Condition Type field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}

