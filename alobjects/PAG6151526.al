page 6151526 "Nc Endpoint File List"
{
    // NC2.01/BR  /20160826  CASE 247479 NaviConnect
    // NC2.12/MHA /20180502  CASE 313362 Added field 105 "Client Path"

    Caption = 'Nc Endpoint File List';
    CardPageID = "Nc Endpoint File Card";
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Nc Endpoint File";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code";Code)
                {
                }
                field(Description;Description)
                {
                }
                field(Enabled;Enabled)
                {
                }
                field(Path;Path)
                {
                }
                field("Client Path";"Client Path")
                {
                }
                field(Filename;Filename)
                {
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("Trigger Links")
            {
                Caption = 'Trigger Links';
                Image = Link;

                trigger OnAction()
                begin
                    ShowEndpointTriggerLinks;
                end;
            }
        }
    }
}

