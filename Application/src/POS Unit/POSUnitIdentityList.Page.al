page 6150715 "NPR POS Unit Identity List"
{
    // #Transcendence/TSA/20170221 CASE Trancendence Login

    Caption = 'POS Unit Identity List';
    CardPageID = "NPR POS Unit Identity Card";
    PageType = ListPlus;
    SourceTable = "NPR POS Unit Identity";
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
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
                field("Device ID"; "Device ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Device ID field';
                }
                field("User ID"; "User ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the User ID field';
                }
                field("Default POS Unit No."; "Default POS Unit No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Default POS Unit No. field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Host Name"; "Host Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Host Name field';
                }
                field("Session Type"; "Session Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Session Type field';
                }
                field("Select POS Using"; "Select POS Using")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Select POS Using field';
                }
                field("Created At"; "Created At")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Created At field';
                }
                field("Last Session At"; "Last Session At")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Last Session At field';
                }
            }
        }
    }

    actions
    {
    }
}

