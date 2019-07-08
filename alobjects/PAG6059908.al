page 6059908 "Session Log"
{
    // TQ1.29/JDH /20161101 CASE 242044 Shows Session logins, and the master thread logout as well
    // TQ1.31/BR /20171109 CASE 295987 Added field Error Message

    Caption = 'Session Log';
    Editable = false;
    PageType = List;
    SourceTable = "Session Log";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No.";"Entry No.")
                {
                }
                field("Log Type";"Log Type")
                {
                }
                field("Log Time";"Log Time")
                {
                }
                field("User ID";"User ID")
                {
                }
                field("Task Worker Group";"Task Worker Group")
                {
                }
                field("Server Instance ID";"Server Instance ID")
                {
                }
                field("Company Name";"Company Name")
                {
                }
                field("Error Message";"Error Message")
                {
                }
            }
        }
    }

    actions
    {
    }
}

