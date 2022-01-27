page 6151523 "NPR Nc Endpoint FTP Card"
{
    Extensible = False;
    Caption = 'Nc Endpoint FTP Card';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    UsageCategory = Administration;
    SourceTable = "NPR Nc Endpoint FTP";
    ApplicationArea = NPRNaviConnect;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRNaviConnect;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRNaviConnect;
                }
                field(Enabled; Rec.Enabled)
                {

                    ToolTip = 'Specifies the value of the Enabled field';
                    ApplicationArea = NPRNaviConnect;
                }
            }
            group(FTP)
            {
                Caption = 'FTP';
                field(Type; Rec.Type)
                {

                    ToolTip = 'Specifies the value of the Type field';
                    ApplicationArea = NPRNaviConnect;
                }
                field(Server; Rec.Server)
                {

                    ToolTip = 'Specifies the value of the FTP Server field';
                    ApplicationArea = NPRNaviConnect;
                }
                field(Username; Rec.Username)
                {

                    ToolTip = 'Specifies the value of the FTP Username field';
                    ApplicationArea = NPRNaviConnect;
                }
                field(Password; Rec.Password)
                {

                    ToolTip = 'Specifies the value of the FTP Password field';
                    ApplicationArea = NPRNaviConnect;
                }
                field(Port; Rec.Port)
                {

                    ToolTip = 'Specifies the value of the FTP Port field';
                    ApplicationArea = NPRNaviConnect;
                }
                field(Passive; Rec.Passive)
                {

                    ToolTip = 'Specifies the value of the FTP Passive field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Encryption mode"; Rec.EncMode)
                {
                    ToolTip = 'Specifies which mode of encryption is used between client and server';
                    ApplicationArea = NPRRetail;
                }
                field(Directory; Rec.Directory)
                {

                    ToolTip = 'Specifies the value of the FTP Directory field';
                    ApplicationArea = NPRNaviConnect;
                }
                field(Filename; Rec.Filename)
                {

                    ToolTip = 'Specifies the value of the Filename field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("File Encoding"; Rec."File Encoding")
                {

                    ToolTip = 'Specifies the value of the File Encoding field';
                    ApplicationArea = NPRNaviConnect;
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
                ToolTip = 'Executes the Trigger Links action';
                ApplicationArea = NPRNaviConnect;

                trigger OnAction()
                begin
                    Rec.ShowEndpointTriggerLinks();
                end;
            }
        }
    }
}

