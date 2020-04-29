page 6150635 "POS View Profiles"
{
    // NPR5.49/TJ  /20190201 CASE 335739 New object

    Caption = 'POS View Profiles';
    CardPageID = "POS View Profile Card";
    PageType = List;
    SourceTable = "POS View Profile";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code";Code)
                {
                }
                field("Client Formatting Culture ID";"Client Formatting Culture ID")
                {
                }
                field("Client Decimal Separator";"Client Decimal Separator")
                {
                }
                field("Client Thousands Separator";"Client Thousands Separator")
                {
                }
                field("Client Date Separator";"Client Date Separator")
                {
                }
                field("POS Theme Code";"POS Theme Code")
                {
                }
                field("Line Order on Screen";"Line Order on Screen")
                {
                }
            }
        }
    }

    actions
    {
    }
}

