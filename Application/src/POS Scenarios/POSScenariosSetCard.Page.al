page 6150733 "NPR POS Scenarios Set Card"
{

    Caption = 'POS Scenarios Set Card';
    PageType = Card;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR POS Sales Workflow Set";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
            }
            part(Control6014404; "NPR POS Scenarios Set Entries")
            {
                SubPageLink = "Set Code" = FIELD(Code);
                ApplicationArea = All;
            }
        }
    }

    actions
    {
    }
}

