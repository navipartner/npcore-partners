page 6184501 "CleanCash Error List"
{
    // NPR5.26/JHL/20160714 CASE 242776 Page created to show Error from Black Box
    // NPR5.48/JDH /20181109 CASE 334163 Added Caption to Object

    Caption = 'CleanCash Error List';
    PageType = List;
    SourceTable = "CleanCash Error List";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No.";"Entry No.")
                {
                    Editable = false;
                    Enabled = false;
                }
                field(Date;Date)
                {
                    Editable = false;
                    Enabled = false;
                }
                field(Time;Time)
                {
                    Editable = false;
                    Enabled = false;
                }
                field("Object Type";"Object Type")
                {
                    Editable = false;
                    Enabled = false;
                }
                field("Object No.";"Object No.")
                {
                    Editable = false;
                    Enabled = false;
                }
                field("Object Name";"Object Name")
                {
                    Editable = false;
                    Enabled = false;
                }
                field(EventResponse;EventResponse)
                {
                    Editable = false;
                    Enabled = false;
                }
                field("Enum Type";"Enum Type")
                {
                    Editable = false;
                    Enabled = false;
                }
                field("Error Text";"Error Text")
                {
                    Editable = false;
                    Enabled = false;
                }
            }
        }
    }

    actions
    {
    }
}

