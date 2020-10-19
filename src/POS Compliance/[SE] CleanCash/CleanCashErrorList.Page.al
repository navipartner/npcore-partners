page 6184501 "NPR CleanCash Error List"
{
    Caption = 'CleanCash Error List';
    PageType = List;
    SourceTable = "NPR CleanCash Error List";
    UsageCategory = None;

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

