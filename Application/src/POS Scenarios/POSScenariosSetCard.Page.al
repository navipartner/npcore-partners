page 6150733 "NPR POS Scenarios Set Card"
{
    Extensible = False;

    Caption = 'POS Scenarios Set Card';
    PageType = Card;
    UsageCategory = None;
    SourceTable = "NPR POS Sales Workflow Set";
    ObsoleteState = Pending;
    ObsoleteTag = '2023-06-28';
    ObsoleteReason = 'Scenarios have been moved to hardcoded codeunit calls for internal steps, and event subscribers for PTE steps';


    layout
    {
        area(content)
        {
            group(General)
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
            part(Control6014404; "NPR POS Scenarios Set Entries")
            {
                SubPageLink = "Set Code" = FIELD(Code);
                ApplicationArea = NPRRetail;

            }
        }
    }

    actions
    {
    }
}

