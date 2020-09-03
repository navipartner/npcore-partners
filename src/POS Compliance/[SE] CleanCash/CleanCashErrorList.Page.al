page 6184501 "NPR CleanCash Error List"
{
    // NPR5.26/JHL/20160714 CASE 242776 Page created to show Error from Black Box
    // NPR5.48/JDH /20181109 CASE 334163 Added Caption to Object

    Caption = 'CleanCash Error List';
    PageType = List;
    SourceTable = "NPR CleanCash Error List";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Enabled = false;
                }
                field("Date"; Date)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Enabled = false;
                }
                field("Time"; Time)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Enabled = false;
                }
                field("Object Type"; "Object Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Enabled = false;
                }
                field("Object No."; "Object No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Enabled = false;
                }
                field("Object Name"; "Object Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Enabled = false;
                }
                field(EventResponse; EventResponse)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Enabled = false;
                }
                field("Enum Type"; "Enum Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Enabled = false;
                }
                field("Error Text"; "Error Text")
                {
                    ApplicationArea = All;
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

