page 6151523 "NPR Nc Endpoint FTP Card"
{
    // NC2.01/BR   /20160818  CASE 248630 NaviConnect
    // NC2.01/BR  /20161220  CASE 261431 Added field "File Encoding"

    Caption = 'Nc Endpoint FTP Card';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    UsageCategory = Administration;
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
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Enabled; Enabled)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Enabled field';
                }
            }
            group(FTP)
            {
                field(Type; Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field(Server; Server)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the FTP Server field';
                }
                field(Username; Username)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the FTP Username field';
                }
                field(Password; Password)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the FTP Password field';
                }
                field(Port; Port)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the FTP Port field';
                }
                field(Passive; Passive)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the FTP Passive field';
                }
                field(Directory; Directory)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the FTP Directory field';
                }
                field(Filename; Filename)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Filename field';
                }
                field("File Encoding"; "File Encoding")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the File Encoding field';
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
                ToolTip = 'Executes the Trigger Links action';

                trigger OnAction()
                begin
                    ShowEndpointTriggerLinks;
                end;
            }
        }
    }
}

