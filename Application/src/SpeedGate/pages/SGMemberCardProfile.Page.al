page 6184916 "NPR SG MemberCardProfile"
{
    Extensible = false;

    PageType = Card;
    UsageCategory = None;
    SourceTable = "NPR SG MemberCardProfile";
    Caption = 'Speedgate Member Card Profile';

    layout
    {
        area(Content)
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
            part(MemberCardProfileLines; "NPR SG MemberCardProfileLine")
            {
                Caption = 'Member Card Profile Lines';
                ApplicationArea = NPRRetail;
                SubPageLink = Code = field("Code");
                SubPageView = sorting(Code, LineNo);
            }
        }
    }
}