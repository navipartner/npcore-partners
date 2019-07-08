page 6060088 "MM Member Arrival Log"
{
    // MM1.21/TSA /20170721 CASE 284653 First Version

    Caption = 'Member Arrival Log';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "MM Member Arrival Log Entry";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No.";"Entry No.")
                {
                    Visible = false;
                }
                field("Event Type";"Event Type")
                {
                }
                field("Created At";"Created At")
                {
                }
                field("Local Date";"Local Date")
                {
                    Visible = false;
                }
                field("Local Time";"Local Time")
                {
                }
                field("External Membership No.";"External Membership No.")
                {
                }
                field("External Member No.";"External Member No.")
                {
                }
                field("External Card No.";"External Card No.")
                {
                }
                field("Scanner Station Id";"Scanner Station Id")
                {
                    Visible = false;
                }
                field("Admission Code";"Admission Code")
                {
                }
                field("Response Type";"Response Type")
                {
                }
                field("Response Code";"Response Code")
                {
                }
                field("Response Rule Entry No.";"Response Rule Entry No.")
                {
                }
                field("Response Message";"Response Message")
                {
                }
            }
        }
    }

    actions
    {
    }
}

