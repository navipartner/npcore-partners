page 6151522 "NPR Nc Endpoint FTP List"
{
    Extensible = False;
    Caption = 'Nc Endpoint FTP List';
    CardPageID = "NPR Nc Endpoint FTP Card";
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    UsageCategory = None;
    SourceTable = "NPR Nc Endpoint FTP";
    ObsoleteState = Pending;
    ObsoleteTag = '2023-06-28';
    ObsoleteReason = 'Going ot switch to use Ftp Connection and Sftp Connection.';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
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
                field(Server; Rec.Server)
                {
                    ToolTip = 'Specifies the value of the FTP Server field';
                    ApplicationArea = NPRNaviConnect;
                }
            }
        }
    }
}

