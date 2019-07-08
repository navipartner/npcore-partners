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
                field("Device ID";"Device ID")
                {
                    Editable = false;
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
            }
            group(User)
            {
                field("User ID";"User ID")
                {
                    Editable = false;
                }
            }
            group("POS Unit")
            {
                field("Default POS Unit No.";"Default POS Unit No.")
                {
                }
            }
            group(Device)
            {
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

