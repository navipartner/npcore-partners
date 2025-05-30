page 6060144 "NPR MM Member Notific. Entry"
{
    Extensible = False;

    Caption = 'Member Notification Entry';
    InsertAllowed = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR MM Member Notific. Entry";
    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Notification Trigger"; Rec."Notification Trigger")
                {
                    ToolTip = 'Specifies the value of the Notification Trigger field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Notification Method"; Rec."Notification Method")
                {
                    ToolTip = 'Specifies the value of the Notification Method field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Date To Notify"; Rec."Date To Notify")
                {
                    ToolTip = 'Specifies the value of the Date To Notify field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Notification Sent By User"; Rec."Notification Sent By User")
                {
                    ToolTip = 'Specifies the value of the Notification Sent By User field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Notification Sent At"; Rec."Notification Sent At")
                {

                    ToolTip = 'Specifies the value of the Notification Sent At field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Notification Send Status"; Rec."Notification Send Status")
                {
                    ToolTip = 'Specifies the value of the Notification Send Status field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Blocked; Rec.Blocked)
                {
                    ToolTip = 'Specifies the value of the Blocked field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("External Member No."; Rec."External Member No.")
                {
                    ToolTip = 'Specifies the value of the External Member No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("External Membership No."; Rec."External Membership No.")
                {
                    ToolTip = 'Specifies the value of the External Membership No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("E-Mail Address"; Rec."E-Mail Address")
                {
                    ToolTip = 'Specifies the value of the E-Mail Address field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Phone No."; Rec."Phone No.")
                {
                    ToolTip = 'Specifies the value of the Phone No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("First Name"; Rec."First Name")
                {
                    ToolTip = 'Specifies the value of the First Name field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Middle Name"; Rec."Middle Name")
                {
                    ToolTip = 'Specifies the value of the Middle Name field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Last Name"; Rec."Last Name")
                {
                    ToolTip = 'Specifies the value of the Last Name field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Display Name"; Rec."Display Name")
                {
                    ToolTip = 'Specifies the value of the Display Name field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Address; Rec.Address)
                {
                    ToolTip = 'Specifies the value of the Address field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Post Code Code"; Rec."Post Code Code")
                {
                    ToolTip = 'Specifies the value of the ZIP Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(City; Rec.City)
                {
                    ToolTip = 'Specifies the value of the City field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Country Code"; Rec."Country Code")
                {
                    ToolTip = 'Specifies the value of the Country Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Country; Rec.Country)
                {
                    ToolTip = 'Specifies the value of the Country field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(PreferredLanguage; Rec.PreferredLanguageCode)
                {
                    ToolTip = 'Specifies the value of the Preferred Language field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Birthday; Rec.Birthday)
                {
                    ToolTip = 'Specifies the value of the Birthday field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Community Code"; Rec."Community Code")
                {
                    ToolTip = 'Specifies the value of the Community Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Membership Code"; Rec."Membership Code")
                {
                    ToolTip = 'Specifies the value of the Membership Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Membership Valid From"; Rec."Membership Valid From")
                {
                    ToolTip = 'Specifies the value of the Membership Valid From field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Membership Valid Until"; Rec."Membership Valid Until")
                {
                    ToolTip = 'Specifies the value of the Membership Valid Until field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Membership Consecutive From"; Rec."Membership Consecutive From")
                {
                    ToolTip = 'Specifies the value of the Membership Consecutive From field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Membership Consecutive Until"; Rec."Membership Consecutive Until")
                {
                    ToolTip = 'Specifies the value of the Membership Consecutive Until field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Coupon Reference No."; Rec."Coupon Reference No.")
                {
                    ToolTip = 'Specifies the value of the Coupon Reference No. field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Coupon Description"; Rec."Coupon Description")
                {
                    ToolTip = 'Specifies the value of the Coupon Description field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Coupon Discount %"; Rec."Coupon Discount %")
                {
                    ToolTip = 'Specifies the value of the Coupon Discount % field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Coupon Discount Amount"; Rec."Coupon Discount Amount")
                {
                    ToolTip = 'Specifies the value of the Coupon Discount Amount field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Coupon Discount Type"; Rec."Coupon Discount Type")
                {
                    ToolTip = 'Specifies the value of the Coupon Discount Type field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Coupon Ending Date"; Rec."Coupon Ending Date")
                {
                    ToolTip = 'Specifies the value of the Coupon Ending Date field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Coupon Starting Date"; Rec."Coupon Starting Date")
                {
                    ToolTip = 'Specifies the value of the Coupon Starting Date field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Contact No."; Rec."Contact No.")
                {
                    ToolTip = 'Specifies the value of the Contact No. field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ToolTip = 'Specifies the value of the Customer No. field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Auto-Renew"; Rec."Auto-Renew")
                {
                    ToolTip = 'Specifies the value of the Auto-Renew field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Auto-Renew External Data"; Rec."Auto-Renew External Data")
                {
                    ToolTip = 'Specifies the value of the Auto-Renew External Data field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Auto-Renew Payment Method Code"; Rec."Auto-Renew Payment Method Code")
                {
                    ToolTip = 'Specifies the value of the Auto-Renew Payment Method Code field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(NextActivationDate; Rec.NextActivationDate)
                {
                    ToolTip = 'Specifies the value of the Next Activation Date field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(NextMembershipCode; Rec.NextMembershipCode)
                {
                    ToolTip = 'Specifies the value of the Next Membership Code field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(NextMembershipDescription; Rec.NextMembershipDescription)
                {
                    ToolTip = 'Specifies the value of the Next Membership Description field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }

                field("External Member Card No."; Rec."External Member Card No.")
                {
                    ToolTip = 'Specifies the value of the External Member Card No. field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Card Valid Until"; Rec."Card Valid Until")
                {
                    ToolTip = 'Specifies the value of the Card Valid Until field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Target Member Role"; Rec."Target Member Role")
                {
                    ToolTip = 'Specifies the value of the Target Member Role field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Template Filter Value"; Rec."Template Filter Value")
                {
                    Enabled = false;
                    ToolTip = 'Specifies the value of the Template Filter Value field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Include NP Pass"; Rec."Include NP Pass")
                {
                    ToolTip = 'Specifies the value of the Include NP Pass field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Wallet Pass Id"; Rec."Wallet Pass Id")
                {
                    ToolTip = 'Specifies the value of the Wallet Pass Id field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Wallet Pass Default URL"; Rec."Wallet Pass Default URL")
                {
                    ToolTip = 'Specifies the value of the Wallet Pass Default URL field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Wallet Pass Andriod URL"; Rec."Wallet Pass Andriod URL")
                {
                    ToolTip = 'Specifies the value of the Wallet Pass Andriod URL field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Blocked By User"; Rec."Blocked By User")
                {
                    ToolTip = 'Specifies the value of the Blocked By User field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Blocked At"; Rec."Blocked At")
                {
                    ToolTip = 'Specifies the value of the Blocked At field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Notification Code"; Rec."Notification Code")
                {
                    ToolTip = 'Specifies the value of the Notification Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Membership Entry No."; Rec."Membership Entry No.")
                {
                    ToolTip = 'Specifies the value of the Membership Entry No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Member Entry No."; Rec."Member Entry No.")
                {
                    ToolTip = 'Specifies the value of the Member Entry No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Notification Entry No."; Rec."Notification Entry No.")
                {
                    ToolTip = 'Specifies the value of the Notification Entry No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Failed With Message"; Rec."Failed With Message")
                {
                    ToolTip = 'Specifies the value of the Failed With Message field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(AzureRegistrationSetupCode; Rec.AzureRegistrationSetupCode)
                {
                    ToolTip = 'Specifies the value of the Member Registration Profile Code. field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(ClientSignUpUrl; Rec.ClientSignUpUrl)
                {
                    ToolTip = 'Specifies the value of the Client URL to SignUp Form field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Community Description"; Rec."Community Description")
                {
                    ToolTip = 'Specifies the value of the Community Description field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(DataSubjectId; Rec.DataSubjectId)
                {
                    ToolTip = 'Specifies the value of the Member Identifier field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Specifies the value of the Item No. field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Magento Get Password URL"; Rec."Magento Get Password URL")
                {
                    ToolTip = 'Specifies the value of the Magento Get Password URL field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Membership Description"; Rec."Membership Description")
                {
                    ToolTip = 'Specifies the value of the Membership Description field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Notification Engine"; Rec."Notification Engine")
                {
                    ToolTip = 'Specifies the value of the Notification Engine field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Notification Token"; Rec."Notification Token")
                {
                    ToolTip = 'Specifies the value of the Notification Token field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Pay by Link URL"; Rec."Pay by Link URL")
                {
                    ToolTip = 'Specifies the value of the Pay by Link URL field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Pin Code"; Rec."Pin Code")
                {
                    ToolTip = 'Specifies the value of the Pin Code field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Rejected Reason Code"; Rec."Rejected Reason Code")
                {
                    ToolTip = 'Specifies the value of the Rejected Reason Code field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Rejected Reason Description"; Rec."Rejected Reason Description")
                {
                    ToolTip = 'Specifies the value of the Rejected Reason Description field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Remaining Points"; Rec."Remaining Points")
                {
                    ToolTip = 'Specifies the value of the Remaining Points field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Wallet Pass Landing URL"; Rec."Wallet Pass Landing URL")
                {
                    ToolTip = 'Specifies the value of the Wallet Pass Combine URL field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
            }
        }
    }

    actions
    {
    }
}

