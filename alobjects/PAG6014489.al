page 6014489 "Report Usage Log Entries"
{
    // NPR5.48/TJ  /20181108 CASE 324444 New object

    Caption = 'Report Usage Log Entries';
    Editable = false;
    PageType = List;
    SourceTable = "Report Usage Log Entry";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No.";"Entry No.")
                {
                }
                field("Database Name";"Database Name")
                {
                }
                field("Tenant Id";"Tenant Id")
                {
                }
                field("Company Name";"Company Name")
                {
                }
                field("Report Id";"Report Id")
                {
                }
                field(Description;Description)
                {
                }
                field("User Id";"User Id")
                {
                }
                field("Used on";"Used on")
                {
                }
            }
        }
    }

    actions
    {
    }
}

