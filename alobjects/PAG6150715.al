page 6150715 "POS Unit Identity List"
{
    // #Transcendence/TSA/20170221 CASE Trancendence Login

    Caption = 'POS Unit Identity List';
    CardPageID = "POS Unit Identity Card";
    PageType = ListPlus;
    SourceTable = "POS Unit Identity";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Device ID"; "Device ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("User ID"; "User ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Default POS Unit No."; "Default POS Unit No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Host Name"; "Host Name")
                {
                    ApplicationArea = All;
                }
                field("Session Type"; "Session Type")
                {
                    ApplicationArea = All;
                }
                field("Select POS Using"; "Select POS Using")
                {
                    ApplicationArea = All;
                }
                field("Created At"; "Created At")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Last Session At"; "Last Session At")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }

    actions
    {
    }
}

