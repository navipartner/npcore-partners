page 6060144 "NPR MM Member Notific. Entry"
{
    // MM1.14/TSA/20160523  CASE 240871 Reminder Service
    // MM1.29/TSA /20180506 CASE 314131 Added field for wallet services

    Caption = 'Member Notification Entry';
    InsertAllowed = false;
    PageType = List;
    SourceTable = "NPR MM Member Notific. Entry";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Notification Trigger"; "Notification Trigger")
                {
                    ApplicationArea = All;
                }
                field("Notification Method"; "Notification Method")
                {
                    ApplicationArea = All;
                }
                field("Date To Notify"; "Date To Notify")
                {
                    ApplicationArea = All;
                }
                field("Notification Sent By User"; "Notification Sent By User")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Notification Sent At"; "Notification Sent At")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Notification Send Status"; "Notification Send Status")
                {
                    ApplicationArea = All;
                }
                field(Blocked; Blocked)
                {
                    ApplicationArea = All;
                }
                field("External Member No."; "External Member No.")
                {
                    ApplicationArea = All;
                }
                field("External Membership No."; "External Membership No.")
                {
                    ApplicationArea = All;
                }
                field("E-Mail Address"; "E-Mail Address")
                {
                    ApplicationArea = All;
                }
                field("Phone No."; "Phone No.")
                {
                    ApplicationArea = All;
                }
                field("First Name"; "First Name")
                {
                    ApplicationArea = All;
                }
                field("Middle Name"; "Middle Name")
                {
                    ApplicationArea = All;
                }
                field("Last Name"; "Last Name")
                {
                    ApplicationArea = All;
                }
                field("Display Name"; "Display Name")
                {
                    ApplicationArea = All;
                }
                field(Address; Address)
                {
                    ApplicationArea = All;
                }
                field("Post Code Code"; "Post Code Code")
                {
                    ApplicationArea = All;
                }
                field(City; City)
                {
                    ApplicationArea = All;
                }
                field("Country Code"; "Country Code")
                {
                    ApplicationArea = All;
                }
                field(Country; Country)
                {
                    ApplicationArea = All;
                }
                field(Birthday; Birthday)
                {
                    ApplicationArea = All;
                }
                field("Community Code"; "Community Code")
                {
                    ApplicationArea = All;
                }
                field("Membership Code"; "Membership Code")
                {
                    ApplicationArea = All;
                }
                field("Membership Valid From"; "Membership Valid From")
                {
                    ApplicationArea = All;
                }
                field("Membership Valid Until"; "Membership Valid Until")
                {
                    ApplicationArea = All;
                }
                field("Target Member Role"; "Target Member Role")
                {
                    ApplicationArea = All;
                }
                field("Template Filter Value"; "Template Filter Value")
                {
                    ApplicationArea = All;
                    Enabled = false;
                }
                field("Include NP Pass"; "Include NP Pass")
                {
                    ApplicationArea = All;
                }
                field("Wallet Pass Id"; "Wallet Pass Id")
                {
                    ApplicationArea = All;
                }
                field("Wallet Pass Default URL"; "Wallet Pass Default URL")
                {
                    ApplicationArea = All;
                }
                field("Wallet Pass Andriod URL"; "Wallet Pass Andriod URL")
                {
                    ApplicationArea = All;
                }
                field("Blocked By User"; "Blocked By User")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Blocked At"; "Blocked At")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Notification Code"; "Notification Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Membership Entry No."; "Membership Entry No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Member Entry No."; "Member Entry No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Notification Entry No."; "Notification Entry No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Failed With Message"; "Failed With Message")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

