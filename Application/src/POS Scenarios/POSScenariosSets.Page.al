page 6150732 "NPR POS Scenarios Sets"
{
    Extensible = False;

    Caption = 'POS Scenarios Sets';
    CardPageID = "NPR POS Scenarios Set Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR POS Sales Workflow Set";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;
    ObsoleteState = Pending;
    ObsoleteTag = '2023-06-28';
    ObsoleteReason = 'Scenarios have been moved to hardcoded codeunit calls for internal steps, and event subscribers for PTE steps';


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

