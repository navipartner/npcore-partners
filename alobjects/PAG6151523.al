page 6151523 "Nc Endpoint FTP Card"
{
    // NC2.01/BR   /20160818  CASE 248630 NaviConnect
    // NC2.01/BR  /20161220  CASE 261431 Added field "File Encoding"

    Caption = 'Nc Endpoint FTP Card';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "Nc Endpoint FTP";

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
            group(FTP)
            {
                field(Type;Type)
                {
                }
                field(Server;Server)
                {
                }
                field(Username;Username)
                {
                }
                field(Password;Password)
                {
                }
                field(Port;Port)
                {
                }
                field(Passive;Passive)
                {
                }
                field(Directory;Directory)
                {
                }
                field(Filename;Filename)
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

