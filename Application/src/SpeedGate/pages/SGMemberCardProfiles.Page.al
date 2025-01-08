page 6184915 "NPR SG MemberCardProfiles"
{
    Extensible = false;
    PageType = List;
    UsageCategory = None;
    Editable = false;
    SourceTable = "NPR SG MemberCardProfile";
    CardPageId = "NPR SG MemberCardProfile";
    Caption = 'Speedgate Member Card Profiles';


    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Code"; Rec."Code")
                {
                    ToolTip = 'Specifies the value of the Code field.', Comment = '%';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field.', Comment = '%';
                    ApplicationArea = NPRRetail;
                }
                field(ValidationMode; Rec.ValidationMode)
                {
                    ToolTip = 'Specifies the value of the Validate Mode field.', Comment = '%';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}