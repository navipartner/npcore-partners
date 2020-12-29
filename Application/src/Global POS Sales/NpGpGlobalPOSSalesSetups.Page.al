page 6151171 "NPR NpGp Global POSSalesSetups"
{
    Caption = 'Global POS Sales Setups';
    CardPageID = "NPR NpGp POS Sales Setup Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR NpGp POS Sales Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field("Company Name"; "Company Name")
                {
                    ApplicationArea = All;
                }
                field("Service Url"; "Service Url")
                {
                    ApplicationArea = All;
                }
                field("Sync POS Sales Immediately"; "Sync POS Sales Immediately")
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

