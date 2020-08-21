page 6150716 "POS Unit Identity Card"
{
    // #Transcendence/TSA/20170221 CASE Trancendence Login

    Caption = 'POS Unit Identity Card';
    PageType = Card;
    SourceTable = "POS Unit Identity";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Device ID"; "Device ID")
                {
                    ApplicationArea = All;
                    Editable = false;
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
            }
            group(User)
            {
                field("User ID"; "User ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
            group("POS Unit")
            {
                field("Default POS Unit No."; "Default POS Unit No.")
                {
                    ApplicationArea = All;
                }
            }
            group(Device)
            {
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

