page 6014695 "NPR POS View Prof. Select"
{
    Caption = 'POS View Profiles';
    PageType = List;
    SourceTable = "NPR POS View Profile";
    SourceTableTemporary = true;
    DelayedInsert = true;
    UsageCategory = None;

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
            }
        }
    }
    procedure SetRec(var TempPOSViewProfile: Record "NPR POS View Profile")
    begin
        if TempPOSViewProfile.FindSet() then
            repeat
                Rec.Copy(TempPOSViewProfile);
                Rec.Insert();
            until TempPOSViewProfile.Next() = 0;

        if Rec.FindSet() then;
    end;
}