page 6060144 "MM Member Notification Entry"
{
    // MM1.14/TSA/20160523  CASE 240871 Reminder Service
    // MM1.29/TSA /20180506 CASE 314131 Added field for wallet services

    Caption = 'Member Notification Entry';
    InsertAllowed = false;
    PageType = List;
    SourceTable = "MM Member Notification Entry";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Notification Trigger";"Notification Trigger")
                {
                }
                field("Notification Method";"Notification Method")
                {
                }
                field("Date To Notify";"Date To Notify")
                {
                }
                field("Notification Sent By User";"Notification Sent By User")
                {
                    Visible = false;
                }
                field("Notification Sent At";"Notification Sent At")
                {
                    Visible = false;
                }
                field("Notification Send Status";"Notification Send Status")
                {
                }
                field(Blocked;Blocked)
                {
                }
                field("External Member No.";"External Member No.")
                {
                }
                field("External Membership No.";"External Membership No.")
                {
                }
                field("E-Mail Address";"E-Mail Address")
                {
                }
                field("Phone No.";"Phone No.")
                {
                }
                field("First Name";"First Name")
                {
                }
                field("Middle Name";"Middle Name")
                {
                }
                field("Last Name";"Last Name")
                {
                }
                field("Display Name";"Display Name")
                {
                }
                field(Address;Address)
                {
                }
                field("Post Code Code";"Post Code Code")
                {
                }
                field(City;City)
                {
                }
                field("Country Code";"Country Code")
                {
                }
                field(Country;Country)
                {
                }
                field(Birthday;Birthday)
                {
                }
                field("Community Code";"Community Code")
                {
                }
                field("Membership Code";"Membership Code")
                {
                }
                field("Membership Valid From";"Membership Valid From")
                {
                }
                field("Membership Valid Until";"Membership Valid Until")
                {
                }
                field("Target Member Role";"Target Member Role")
                {
                }
                field("Template Filter Value";"Template Filter Value")
                {
                    Enabled = false;
                }
                field("Include NP Pass";"Include NP Pass")
                {
                }
                field("Wallet Pass Id";"Wallet Pass Id")
                {
                }
                field("Wallet Pass Default URL";"Wallet Pass Default URL")
                {
                }
                field("Wallet Pass Andriod URL";"Wallet Pass Andriod URL")
                {
                }
                field("Blocked By User";"Blocked By User")
                {
                    Visible = false;
                }
                field("Blocked At";"Blocked At")
                {
                    Visible = false;
                }
                field("Notification Code";"Notification Code")
                {
                    Visible = false;
                }
                field("Membership Entry No.";"Membership Entry No.")
                {
                    Visible = false;
                }
                field("Member Entry No.";"Member Entry No.")
                {
                    Visible = false;
                }
                field("Notification Entry No.";"Notification Entry No.")
                {
                    Visible = false;
                }
                field("Failed With Message";"Failed With Message")
                {
                }
            }
        }
    }

    actions
    {
    }
}

