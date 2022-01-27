page 6014695 "NPR POS View Prof. Select"
{
    Extensible = False;
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
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Client Decimal Separator"; Rec."Client Decimal Separator")
                {

                    ToolTip = 'Specifies the value of the Client Decimal Separator field';
                    ApplicationArea = NPRRetail;
                }
                field("Client Thousands Separator"; Rec."Client Thousands Separator")
                {

                    ToolTip = 'Specifies the value of the Client Thousands Separator field';
                    ApplicationArea = NPRRetail;
                }
                field("Client Date Separator"; Rec."Client Date Separator")
                {

                    ToolTip = 'Specifies the value of the Client Date Separator field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Theme Code"; Rec."POS Theme Code")
                {

                    ToolTip = 'Specifies the value of the POS Theme Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Line Order on Screen"; Rec."Line Order on Screen")
                {

                    ToolTip = 'Specifies the value of the Line Order on Screen field';
                    ApplicationArea = NPRRetail;
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
