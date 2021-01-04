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
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
                field("Date"; Date)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Enabled = false;
                    ToolTip = 'Specifies the value of the Date field';
                }
                field("Time"; Time)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Enabled = false;
                    ToolTip = 'Specifies the value of the Time field';
                }
                field("Object Type"; "Object Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Enabled = false;
                    ToolTip = 'Specifies the value of the Object Type field';
                }
                field("Object No."; "Object No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Enabled = false;
                    ToolTip = 'Specifies the value of the Object No. field';
                }
                field("Object Name"; "Object Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Enabled = false;
                    ToolTip = 'Specifies the value of the Object Name field';
                }
                field(EventResponse; EventResponse)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Enabled = false;
                    ToolTip = 'Specifies the value of the Event Response field';
                }
                field("Enum Type"; "Enum Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Enabled = false;
                    ToolTip = 'Specifies the value of the Enum Type field';
                }
                field("Error Text"; "Error Text")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Enabled = false;
                    ToolTip = 'Specifies the value of the Error Text field';
                }
            }
        }
    }

    actions
    {
    }
}

