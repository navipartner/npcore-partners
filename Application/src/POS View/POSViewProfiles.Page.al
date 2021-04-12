page 6150635 "NPR POS View Profiles"
{
    Caption = 'POS View Profiles';
    CardPageID = "NPR POS View Profile Card";
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    Editable = false;
    SourceTable = "NPR POS View Profile";

    layout
    {
        area(content)
        {
            repeater(Group)
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
                field("Client Formatting Culture ID"; Rec."Client Formatting Culture ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Client Formatting Culture ID field';
                }
                field("Client Decimal Separator"; Rec."Client Decimal Separator")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Client Decimal Separator field';
                }
                field("Client Thousands Separator"; Rec."Client Thousands Separator")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Client Thousands Separator field';
                }
                field("Client Date Separator"; Rec."Client Date Separator")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Client Date Separator field';
                }
                field("POS Theme Code"; Rec."POS Theme Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Theme Code field';
                }
                field("Line Order on Screen"; Rec."Line Order on Screen")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Line Order on Screen field';
                }
                field("Initial Sales View"; Rec."Initial Sales View")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Initial Sales View field';
                }
                field("After End-of-Sale View"; Rec."After End-of-Sale View")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the After End-of-Sale View field';
                }
                field("POS - Show discount fields"; Rec."POS - Show discount fields")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Show Discount field';
                }
            }
        }
    }
}