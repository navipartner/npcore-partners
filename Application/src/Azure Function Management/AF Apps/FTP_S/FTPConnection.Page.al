page 6150887 "NPR FTP Connection"
{
    PageType = Card;
    UsageCategory = None;
    Caption = 'FTP Connection';
    SourceTable = "NPR FTP Connection";
    Extensible = False;
    Editable = true;

    layout
    {
        area(Content)
        {
            group("File Server Info")
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies a unique code identifier for the fileserver connection.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies a description used to help distingush FTP Connections';
                }
                field("File Server Host"; Rec."Server Host")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the hostname/ip-address of the remote file server.';
                }
                field("File Server Port"; Rec."Server Port")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the port on the remote server. Default port for FTP and FTPS is 21, and default port for SFTP is 22.';
                }
                field("File Server Username"; Rec."Username")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the username used to log on to the file server.';
                }
                field("File Server Password"; Rec."Password")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the password used to log on to the file server.';
                }
                field("FTP Transfer Mode"; Rec."FTP Passive Transfer Mode")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies if FTP(S) should use Passive mode. Passive mode is the most frequently used.';
                }
                field("FTP Enc. Mode"; Rec."FTP Enc. Mode")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the encryption mode of the FTPS protocol. Explicit is the most common for FTPS. If using FTP use None.';
                }
                field("Force Behvaior"; Rec."Force Behavior")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies if the file transfer operations should be forced. Allows files to be overwritten and directories to be deleted even if they have content.';
                }
            }
        }
    }
}