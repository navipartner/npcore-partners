page 6150635 "POS View Profiles"
{
    // NPR5.49/TJ  /20190201 CASE 335739 New object
    // NPR5.55/TSA /20200527 CASE 406862 Added "Initial Sales View", "After End-of-Sale View"

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
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field("Client Formatting Culture ID"; "Client Formatting Culture ID")
                {
                    ApplicationArea = All;
                }
                field("Client Decimal Separator"; "Client Decimal Separator")
                {
                    ApplicationArea = All;
                }
                field("Client Thousands Separator"; "Client Thousands Separator")
                {
                    ApplicationArea = All;
                }
                field("Client Date Separator"; "Client Date Separator")
                {
                    ApplicationArea = All;
                }
                field("POS Theme Code"; "POS Theme Code")
                {
                    ApplicationArea = All;
                }
                field("Line Order on Screen"; "Line Order on Screen")
                {
                    ApplicationArea = All;
                }
                field("Initial Sales View"; "Initial Sales View")
                {
                    ApplicationArea = All;
                }
                field("After End-of-Sale View"; "After End-of-Sale View")
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

