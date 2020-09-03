page 6151523 "NPR Nc Endpoint FTP Card"
{
    // NC2.01/BR   /20160818  CASE 248630 NaviConnect
    // NC2.01/BR  /20161220  CASE 261431 Added field "File Encoding"

    Caption = 'Nc Endpoint FTP Card';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "NPR Nc Endpoint FTP";

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
            group(FTP)
            {
                field(Type; Type)
                {
                    ApplicationArea = All;
                }
                field(Server; Server)
                {
                    ApplicationArea = All;
                }
                field(Username; Username)
                {
                    ApplicationArea = All;
                }
                field(Password; Password)
                {
                    ApplicationArea = All;
                }
                field(Port; Port)
                {
                    ApplicationArea = All;
                }
                field(Passive; Passive)
                {
                    ApplicationArea = All;
                }
                field(Directory; Directory)
                {
                    ApplicationArea = All;
                }
                field(Filename; Filename)
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

                trigger OnAction()
                begin
                    ShowEndpointTriggerLinks;
                end;
            }
        }
    }
}

