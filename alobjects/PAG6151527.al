page 6151527 "Nc Endpoint File Card"
{
    // NC2.01/BR  /20160826  CASE 247479 NaviConnect
    // NC2.01/BR  /20161220  CASE 261431 Added field "File Encoding"
    // NC2.12/MHA /20180502  CASE 313362 Added field 105 "Client Path"

    Caption = 'Nc Endpoint File Card';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "Nc Endpoint File";

    layout
    {
        area(content)
        {
            group(General)
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
            }
            group(File)
            {
                field(Path;Path)
                {
                }
                field("Client Path";"Client Path")
                {
                    ToolTip = 'Client Path can only be used with Manual Export';
                }
                field(Filename;Filename)
                {
                }
                field("Handle Exiting File";"Handle Exiting File")
                {
                }
                field("File Encoding";"File Encoding")
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

