page 6184917 "NPR SG MemberCardProfileLine"
{
    Extensible = false;

    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "NPR SG MemberCardProfileLine";
    DelayedInsert = true;
    Caption = 'Speedgate Member Card Profile';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {

                field("Code"; Rec."Code")
                {
                    ToolTip = 'Specifies the value of the Code field.', Comment = '%';
                    Visible = false;
                    ApplicationArea = NPRRetail;
                    NotBlank = true;
                }
                field(LineNo; Rec.LineNo)
                {
                    ToolTip = 'Specifies the value of the Line No. field.', Comment = '%';
                    Visible = false;
                    ApplicationArea = NPRRetail;

                }
                field(RuleType; Rec.RuleType)
                {
                    ToolTip = 'Specifies the value of the Rule Type field.', Comment = '%';
                    ApplicationArea = NPRRetail;
                    Editable = false;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field.', Comment = '%';
                    ApplicationArea = NPRRetail;
                }
                field(MembershipCode; Rec.MembershipCode)
                {
                    ToolTip = 'Specifies the value of the Membership Code field.', Comment = '%';
                    ApplicationArea = NPRRetail;
                }
                field(AllowGuests; Rec.AllowGuests)
                {
                    ToolTip = 'Specifies the value of the Allow Guests field.', Comment = '%';
                    ApplicationArea = NPRRetail;
                }
                field(IncludeMemberDetails; Rec.IncludeMemberDetails)
                {
                    ToolTip = 'Specifies the value of the Include Member Details field.', Comment = '%';
                    ApplicationArea = NPRRetail;
                }
                field(IncludeMemberPhoto; Rec.IncludeMemberPhoto)
                {
                    ToolTip = 'Specifies the value of the Include Member Photo field.', Comment = '%';
                    ApplicationArea = NPRRetail;
                }
                field(ItemNo; Rec.ItemNo)
                {
                    ToolTip = 'Specifies the value of the Item No. field.', Comment = '%';
                    ApplicationArea = NPRRetail;
                }
                field(AdmissionCode; Rec.AdmissionCode)
                {
                    ToolTip = 'Specifies the value of the Admission Code field.', Comment = '%';
                    ApplicationArea = NPRRetail;
                }
                field(CalendarCode; Rec.CalendarCode)
                {
                    ToolTip = 'Specifies the value of the Calendar Code field.', Comment = '%';
                    ApplicationArea = NPRRetail;
                }
                field(PermitFromTime; Rec.PermitFromTime)
                {
                    ToolTip = 'Specifies the value of the Permit From Time field.', Comment = '%';
                    ApplicationArea = NPRRetail;
                }
                field(PermitUntilTime; Rec.PermitUntilTime)
                {
                    ToolTip = 'Specifies the value of the Permit Until Time field.', Comment = '%';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

}