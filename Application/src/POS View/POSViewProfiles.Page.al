page 6150635 "NPR POS View Profiles"
{
    // NPR5.49/TJ  /20190201 CASE 335739 New object
    // NPR5.55/TSA /20200527 CASE 406862 Added "Initial Sales View", "After End-of-Sale View"

    Caption = 'POS View Profiles';
    CardPageID = "NPR POS View Profile Card";
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR POS View Profile";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field("Client Formatting Culture ID"; "Client Formatting Culture ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Client Formatting Culture ID field';
                }
                field("Client Decimal Separator"; "Client Decimal Separator")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Client Decimal Separator field';
                }
                field("Client Thousands Separator"; "Client Thousands Separator")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Client Thousands Separator field';
                }
                field("Client Date Separator"; "Client Date Separator")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Client Date Separator field';
                }
                field("POS Theme Code"; "POS Theme Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Theme Code field';
                }
                field("Line Order on Screen"; "Line Order on Screen")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Line Order on Screen field';
                }
                field("Initial Sales View"; "Initial Sales View")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Initial Sales View field';
                }
                field("After End-of-Sale View"; "After End-of-Sale View")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the After End-of-Sale View field';
                }
            }
        }
    }

    actions
    {
    }
}

