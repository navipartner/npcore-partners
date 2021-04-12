page 6060144 "NPR MM Member Notific. Entry"
{

    Caption = 'Member Notification Entry';
    InsertAllowed = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR MM Member Notific. Entry";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Notification Trigger"; Rec."Notification Trigger")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Notification Trigger field';
                }
                field("Notification Method"; Rec."Notification Method")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Notification Method field';
                }
                field("Date To Notify"; Rec."Date To Notify")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Date To Notify field';
                }
                field("Notification Sent By User"; Rec."Notification Sent By User")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Notification Sent By User field';
                }
                field("Notification Sent At"; Rec."Notification Sent At")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Notification Sent At field';
                }
                field("Notification Send Status"; Rec."Notification Send Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Notification Send Status field';
                }
                field(Blocked; Rec.Blocked)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Blocked field';
                }
                field("External Member No."; Rec."External Member No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External Member No. field';
                }
                field("External Membership No."; Rec."External Membership No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External Membership No. field';
                }
                field("E-Mail Address"; Rec."E-Mail Address")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the E-Mail Address field';
                }
                field("Phone No."; Rec."Phone No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Phone No. field';
                }
                field("First Name"; Rec."First Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the First Name field';
                }
                field("Middle Name"; Rec."Middle Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Middle Name field';
                }
                field("Last Name"; Rec."Last Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Last Name field';
                }
                field("Display Name"; Rec."Display Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Display Name field';
                }
                field(Address; Rec.Address)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Address field';
                }
                field("Post Code Code"; Rec."Post Code Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the ZIP Code field';
                }
                field(City; Rec.City)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the City field';
                }
                field("Country Code"; Rec."Country Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Country Code field';
                }
                field(Country; Rec.Country)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Country field';
                }
                field(Birthday; Rec.Birthday)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Birthday field';
                }
                field("Community Code"; Rec."Community Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Community Code field';
                }
                field("Membership Code"; Rec."Membership Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Membership Code field';
                }
                field("Membership Valid From"; Rec."Membership Valid From")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Membership Valid From field';
                }
                field("Membership Valid Until"; Rec."Membership Valid Until")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Membership Valid Until field';
                }

                field("Membership Consecutive From"; Rec."Membership Consecutive From")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Membership Consecutive From field';
                }

                field("Membership Consecutive Until"; Rec."Membership Consecutive Until")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Membership Consecutive Until field';
                }
                field("Target Member Role"; Rec."Target Member Role")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Target Member Role field';
                }
                field("Template Filter Value"; Rec."Template Filter Value")
                {
                    ApplicationArea = All;
                    Enabled = false;
                    ToolTip = 'Specifies the value of the Template Filter Value field';
                }
                field("Include NP Pass"; Rec."Include NP Pass")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Include NP Pass field';
                }
                field("Wallet Pass Id"; Rec."Wallet Pass Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Wallet Pass Id field';
                }
                field("Wallet Pass Default URL"; Rec."Wallet Pass Default URL")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Wallet Pass Default URL field';
                }
                field("Wallet Pass Andriod URL"; Rec."Wallet Pass Andriod URL")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Wallet Pass Andriod URL field';
                }
                field("Blocked By User"; Rec."Blocked By User")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Blocked By User field';
                }
                field("Blocked At"; Rec."Blocked At")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Blocked At field';
                }
                field("Notification Code"; Rec."Notification Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Notification Code field';
                }
                field("Membership Entry No."; Rec."Membership Entry No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Membership Entry No. field';
                }
                field("Member Entry No."; Rec."Member Entry No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Member Entry No. field';
                }
                field("Notification Entry No."; Rec."Notification Entry No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Notification Entry No. field';
                }
                field("Failed With Message"; Rec."Failed With Message")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Failed With Message field';
                }
            }
        }
    }

    actions
    {
    }
}

