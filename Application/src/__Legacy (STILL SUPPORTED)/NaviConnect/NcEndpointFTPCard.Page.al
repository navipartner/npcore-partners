page 6151523 "NPR Nc Endpoint FTP Card"
{
    Extensible = False;
    Caption = 'Nc Endpoint FTP Card';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    UsageCategory = None;
    SourceTable = "NPR Nc Endpoint FTP";
    ObsoleteState = Pending;
    ObsoleteTag = '2023-06-28';
    ObsoleteReason = 'Going ot switch to use Ftp Connection and Sftp Connection.';

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
                    ObsoleteState = Pending;
                    ObsoleteTag = '2023-06-28';
                    ObsoleteReason = 'Option type to be removed. Use new enum field "Protocol Type" instead.';
                    Visible = false;
                    ToolTip = 'Specifies the value of the Type field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Protocol Type"; Rec."Protocol Type")
                {
                    ToolTip = 'Specifies if File sending will be done using regular or secure FTP';
                    ApplicationArea = NPRNaviConnect;

                    trigger OnValidate()
                    begin
                        EncryptionModeEnabled := Rec."Protocol Type" = Rec."Protocol Type"::FTP;
                    end;
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
                    Editable = EncryptionModeEnabled;
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
                field("FTP Files temporrary extension"; Rec."File Temporary Extension")
                {
                    ApplicationArea = NPRRetail;
                    Importance = Additional;
                    ToolTip = 'Specifies temporary file extension. If it is entered, file will be uploaded with this extension and then renamed to real (target) one.';
                }
                field("File Encoding"; Rec."File Encoding")
                {

                    ToolTip = 'Specifies the value of the File Encoding field';
                    ApplicationArea = NPRNaviConnect;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        EncryptionModeEnabled := Rec."Protocol Type" = Rec."Protocol Type"::FTP;
    end;

    var
        EncryptionModeEnabled: Boolean;
}

