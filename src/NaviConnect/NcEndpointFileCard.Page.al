page 6151527 "NPR Nc Endpoint File Card"
{
    // NC2.01/BR  /20160826  CASE 247479 NaviConnect
    // NC2.01/BR  /20161220  CASE 261431 Added field "File Encoding"
    // NC2.12/MHA /20180502  CASE 313362 Added field 105 "Client Path"

    Caption = 'Nc Endpoint File Card';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    UsageCategory = Administration;
    SourceTable = "NPR Nc Endpoint File";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field(Enabled; Enabled)
                {
                    ApplicationArea = All;
                }
            }
            group("File")
            {
                field(Path; Path)
                {
                    ApplicationArea = All;
                }
                field("Client Path"; "Client Path")
                {
                    ApplicationArea = All;
                    ToolTip = 'Client Path can only be used with Manual Export';
                }
                field(Filename; Filename)
                {
                    ApplicationArea = All;
                }
                field("Handle Exiting File"; "Handle Exiting File")
                {
                    ApplicationArea = All;
                }
                field("File Encoding"; "File Encoding")
                {
                    ApplicationArea = All;
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
                ApplicationArea = All;

                trigger OnAction()
                begin
                    ShowEndpointTriggerLinks;
                end;
            }
        }
    }
}

