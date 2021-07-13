page 6014696 "NPR POS EOD Prof. Select"
{
    Caption = 'POS End of Day Profile';
    PageType = List;
    SourceTable = "NPR POS End of Day Profile";
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
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("End of Day Type"; Rec."End of Day Type")
                {

                    ToolTip = 'Specifies the value of the End of Day Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Master POS Unit No."; Rec."Master POS Unit No.")
                {

                    ToolTip = 'Specifies the value of the Master POS Unit No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Z-Report UI"; Rec."Z-Report UI")
                {

                    ToolTip = 'Specifies the value of the Z-Report UI field';
                    ApplicationArea = NPRRetail;
                }
                field("X-Report UI"; Rec."X-Report UI")
                {

                    ToolTip = 'Specifies the value of the X-Report UI field';
                    ApplicationArea = NPRRetail;
                }
                field("Close Workshift UI"; Rec."Close Workshift UI")
                {

                    ToolTip = 'Specifies the value of the Close Workshift UI field';
                    ApplicationArea = NPRRetail;
                }
                field("Force Blind Counting"; Rec."Force Blind Counting")
                {

                    ToolTip = 'Specifies the value of the Force Blind Counting field';
                    ApplicationArea = NPRRetail;
                }
                field("SMS Profile"; Rec."SMS Profile")
                {

                    ToolTip = 'Specifies the value of the SMS Profile field';
                    ApplicationArea = NPRRetail;
                }
                field("Z-Report Number Series"; Rec."Z-Report Number Series")
                {

                    ToolTip = 'Specifies the value of the Z-Report Number Series field';
                    ApplicationArea = NPRRetail;
                }
                field("X-Report Number Series"; Rec."X-Report Number Series")
                {

                    ToolTip = 'Specifies the value of the X-Report Number Series field';
                    ApplicationArea = NPRRetail;
                }
                field("Show Zero Amount Lines"; Rec."Show Zero Amount Lines")
                {

                    ToolTip = 'Specifies the value of the Show Zero Amount Lines field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    procedure SetRec(var TempPOSEndOfDayProfile: Record "NPR POS End of Day Profile")
    begin
        if TempPOSEndOfDayProfile.FindSet() then
            repeat
                Rec.Copy(TempPOSEndOfDayProfile);
                Rec.Insert();
            until TempPOSEndOfDayProfile.Next() = 0;

        if Rec.FindSet() then;
    end;
}