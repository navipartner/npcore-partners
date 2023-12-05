page 6150871 "NPR SFTP Connection"
{
    PageType = Card;
    UsageCategory = None;
    Caption = 'SFTP Connection';
    SourceTable = "NPR SFTP Connection";
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
                    ToolTip = 'Specifies a description used to help distingush SFTP Connections';
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
                field("File Server Key"; Rec."Server SSH Key".HasValue())
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the SSH key used to log on to the file server via SFTP if needed on the server.';
                    Caption = 'SSH Key uploaded.';
                }
                field("Force Behvaior"; Rec."Force Behavior")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies if the file transfer operations should be forced. Allows files to be overwritten and directories to be deleted even if they have content.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Upload SSH Key")
            {
                ToolTip = 'Upload the private SSH key.';
                Image = Import;
                ApplicationArea = NPRRetail;
                trigger OnAction()
                var
                    fromFile: Text;
                    InS: InStream;
                    Out: OutStream;
                    SelFileLbl: Label 'Select File';
                    FileNotUploaded: Label 'Error: The file was not uploaded.';
                begin
                    if (File.UploadIntoStream(SelFileLbl, '', '', fromFile, InS)) then begin
                        Clear(Rec."Server SSH Key");
                        Rec."Server SSH Key".CreateOutStream(Out);
                        if (not CopyStream(Out, InS)) then Error(FileNotUploaded);
                        Rec.Modify();
                    end;
                end;
            }
            action("Remove SSH key")
            {
                ToolTip = 'Removes the private SSH key.';
                Image = Delete;
                ApplicationArea = NPRRetail;
                trigger OnAction()
                begin
                    Clear(Rec."Server SSH Key");
                end;
            }
        }
    }
}