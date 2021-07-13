page 6060144 "NPR MM Member Notific. Entry"
{

    Caption = 'Member Notification Entry';
    InsertAllowed = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR MM Member Notific. Entry";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Notification Trigger"; Rec."Notification Trigger")
                {

                    ToolTip = 'Specifies the value of the Notification Trigger field';
                    ApplicationArea = NPRRetail;
                }
                field("Notification Method"; Rec."Notification Method")
                {

                    ToolTip = 'Specifies the value of the Notification Method field';
                    ApplicationArea = NPRRetail;
                }
                field("Date To Notify"; Rec."Date To Notify")
                {

                    ToolTip = 'Specifies the value of the Date To Notify field';
                    ApplicationArea = NPRRetail;
                }
                field("Notification Sent By User"; Rec."Notification Sent By User")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Notification Sent By User field';
                    ApplicationArea = NPRRetail;
                }
                field("Notification Sent At"; Rec."Notification Sent At")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Notification Sent At field';
                    ApplicationArea = NPRRetail;
                }
                field("Notification Send Status"; Rec."Notification Send Status")
                {

                    ToolTip = 'Specifies the value of the Notification Send Status field';
                    ApplicationArea = NPRRetail;
                }
                field(Blocked; Rec.Blocked)
                {

                    ToolTip = 'Specifies the value of the Blocked field';
                    ApplicationArea = NPRRetail;
                }
                field("External Member No."; Rec."External Member No.")
                {

                    ToolTip = 'Specifies the value of the External Member No. field';
                    ApplicationArea = NPRRetail;
                }
                field("External Membership No."; Rec."External Membership No.")
                {

                    ToolTip = 'Specifies the value of the External Membership No. field';
                    ApplicationArea = NPRRetail;
                }
                field("E-Mail Address"; Rec."E-Mail Address")
                {

                    ToolTip = 'Specifies the value of the E-Mail Address field';
                    ApplicationArea = NPRRetail;
                }
                field("Phone No."; Rec."Phone No.")
                {

                    ToolTip = 'Specifies the value of the Phone No. field';
                    ApplicationArea = NPRRetail;
                }
                field("First Name"; Rec."First Name")
                {

                    ToolTip = 'Specifies the value of the First Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Middle Name"; Rec."Middle Name")
                {

                    ToolTip = 'Specifies the value of the Middle Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Last Name"; Rec."Last Name")
                {

                    ToolTip = 'Specifies the value of the Last Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Display Name"; Rec."Display Name")
                {

                    ToolTip = 'Specifies the value of the Display Name field';
                    ApplicationArea = NPRRetail;
                }
                field(Address; Rec.Address)
                {

                    ToolTip = 'Specifies the value of the Address field';
                    ApplicationArea = NPRRetail;
                }
                field("Post Code Code"; Rec."Post Code Code")
                {

                    ToolTip = 'Specifies the value of the ZIP Code field';
                    ApplicationArea = NPRRetail;
                }
                field(City; Rec.City)
                {

                    ToolTip = 'Specifies the value of the City field';
                    ApplicationArea = NPRRetail;
                }
                field("Country Code"; Rec."Country Code")
                {

                    ToolTip = 'Specifies the value of the Country Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Country; Rec.Country)
                {

                    ToolTip = 'Specifies the value of the Country field';
                    ApplicationArea = NPRRetail;
                }
                field(Birthday; Rec.Birthday)
                {

                    ToolTip = 'Specifies the value of the Birthday field';
                    ApplicationArea = NPRRetail;
                }
                field("Community Code"; Rec."Community Code")
                {

                    ToolTip = 'Specifies the value of the Community Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Membership Code"; Rec."Membership Code")
                {

                    ToolTip = 'Specifies the value of the Membership Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Membership Valid From"; Rec."Membership Valid From")
                {

                    ToolTip = 'Specifies the value of the Membership Valid From field';
                    ApplicationArea = NPRRetail;
                }
                field("Membership Valid Until"; Rec."Membership Valid Until")
                {

                    ToolTip = 'Specifies the value of the Membership Valid Until field';
                    ApplicationArea = NPRRetail;
                }

                field("Membership Consecutive From"; Rec."Membership Consecutive From")
                {

                    ToolTip = 'Specifies the value of the Membership Consecutive From field';
                    ApplicationArea = NPRRetail;
                }

                field("Membership Consecutive Until"; Rec."Membership Consecutive Until")
                {

                    ToolTip = 'Specifies the value of the Membership Consecutive Until field';
                    ApplicationArea = NPRRetail;
                }
                field("Target Member Role"; Rec."Target Member Role")
                {

                    ToolTip = 'Specifies the value of the Target Member Role field';
                    ApplicationArea = NPRRetail;
                }
                field("Template Filter Value"; Rec."Template Filter Value")
                {

                    Enabled = false;
                    ToolTip = 'Specifies the value of the Template Filter Value field';
                    ApplicationArea = NPRRetail;
                }
                field("Include NP Pass"; Rec."Include NP Pass")
                {

                    ToolTip = 'Specifies the value of the Include NP Pass field';
                    ApplicationArea = NPRRetail;
                }
                field("Wallet Pass Id"; Rec."Wallet Pass Id")
                {

                    ToolTip = 'Specifies the value of the Wallet Pass Id field';
                    ApplicationArea = NPRRetail;
                }
                field("Wallet Pass Default URL"; Rec."Wallet Pass Default URL")
                {

                    ToolTip = 'Specifies the value of the Wallet Pass Default URL field';
                    ApplicationArea = NPRRetail;
                }
                field("Wallet Pass Andriod URL"; Rec."Wallet Pass Andriod URL")
                {

                    ToolTip = 'Specifies the value of the Wallet Pass Andriod URL field';
                    ApplicationArea = NPRRetail;
                }
                field("Blocked By User"; Rec."Blocked By User")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Blocked By User field';
                    ApplicationArea = NPRRetail;
                }
                field("Blocked At"; Rec."Blocked At")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Blocked At field';
                    ApplicationArea = NPRRetail;
                }
                field("Notification Code"; Rec."Notification Code")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Notification Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Membership Entry No."; Rec."Membership Entry No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Membership Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Member Entry No."; Rec."Member Entry No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Member Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Notification Entry No."; Rec."Notification Entry No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Notification Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Failed With Message"; Rec."Failed With Message")
                {

                    ToolTip = 'Specifies the value of the Failed With Message field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

