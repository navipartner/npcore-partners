page 6151171 "NpGp Global POS Sales Setups"
{
    // NPR5.50/MHA /20190422  CASE 337539 Object created - [NpGp] NaviPartner Global POS Sales

    Caption = 'Global POS Sales Setups';
    CardPageID = "NpGp POS Sales Setup Card";
    Editable = false;
    PageType = List;
    SourceTable = "NpGp POS Sales Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code";Code)
                {
                }
                field("Company Name";"Company Name")
                {
                }
                field("Service Url";"Service Url")
                {
                }
                field("Sync POS Sales Immediately";"Sync POS Sales Immediately")
                {
                }
            }
        }
    }

    actions
    {
    }
}

