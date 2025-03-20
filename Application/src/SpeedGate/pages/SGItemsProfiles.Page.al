page 6185031 "NPR SG ItemsProfiles"
{
    Extensible = false;
    PageType = List;
    UsageCategory = None;
    Editable = false;
    SourceTable = "NPR SG ItemsProfile";
    CardPageId = "NPR SG ItemsProfile";
    Caption = 'Speedgate Items Profiles';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Code"; Rec."Code")
                {
                    ToolTip = 'Specifies the value of the Code field.';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}