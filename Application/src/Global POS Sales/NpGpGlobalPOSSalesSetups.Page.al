page 6151171 "NPR NpGp Global POSSalesSetups"
{
    Extensible = False;
    Caption = 'Global POS Sales Setups';
    ContextSensitiveHelpPage = 'docs/retail/pos_profiles/how-to/global_profile/global_profile/';
    CardPageID = "NPR NpGp POS Sales Setup Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR NpGp POS Sales Setup";
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
                    ToolTip = 'Specifies the code for the global POS sales setup';
                    ApplicationArea = NPRRetail;
                }
                field("Company Name"; Rec."Company Name")
                {
                    ToolTip = 'Specifies the company name for the global POS sales setup';
                    ApplicationArea = NPRRetail;
                }
                field("Service Url"; Rec."Service Url")
                {
                    ToolTip = 'Specifies the service URL for the global POS sales setup';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

