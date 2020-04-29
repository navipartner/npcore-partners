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
                field("Entry No.";"Entry No.")
                {
                    Visible = false;
                }
                field("Device ID";"Device ID")
                {
                    Editable = false;
                }
                field("User ID";"User ID")
                {
                    Editable = false;
                }
                field("Default POS Unit No.";"Default POS Unit No.")
                {
                }
                field(Description;Description)
                {
                }
                field("Host Name";"Host Name")
                {
                }
                field("Session Type";"Session Type")
                {
                }
                field("Select POS Using";"Select POS Using")
                {
                }
                field("Created At";"Created At")
                {
                    Editable = false;
                }
                field("Last Session At";"Last Session At")
                {
                    Editable = false;
                }
            }
        }
    }

    actions
    {
    }
}

