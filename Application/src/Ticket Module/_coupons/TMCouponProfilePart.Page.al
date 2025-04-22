page 6184594 "NPR TM CouponProfilePart"
{
    Extensible = false;
    PageType = ListPart;
    UsageCategory = None;
    Caption = 'Ticket Coupon Profiles';
    ContextSensitiveHelpPage = 'docs/entertainment/ticket/how-to/create_coupon_profile/';
    CardPageId = "NPR TM CouponProfile";
    SourceTable = "NPR TM CouponProfile";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {

                field(ProfileCode; Rec.ProfileCode)
                {
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Profile Code field.';
                }
                field(AliasCode; Rec.AliasCode)
                {
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Coupon Alias field.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Description field.';
                }
                field(CouponType; Rec.CouponType)
                {
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Coupon Type field.';
                }
                field(Default; Rec.Default)
                {
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Default field.';
                }
                field(AdmissionIsRequired; Rec.AdmissionIsRequired)
                {
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Admission Is Required field.';
                }
                field(Enabled; Rec.Enabled)
                {
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Enabled field.';
                }
                field(ForceAmount; Rec.ForceAmount)
                {
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Force Amount field.';
                }
                field(RequiredAdmissionCode; Rec.RequiredAdmissionCode)
                {
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Required Admission Code field.';
                }
                field(ValidForDateFormula; Rec.ValidForDateFormula)
                {
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Valid For Date Formula field.';
                }
                field(ValidFromDate; Rec.ValidFromDate)
                {
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Valid From Date field.';
                }
            }

        }

    }
}
