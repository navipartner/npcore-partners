page 6151171 "NPR NpGp Global POSSalesSetups"
{
    // NPR5.50/MHA /20190422  CASE 337539 Object created - [NpGp] NaviPartner Global POS Sales

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

