page 6150888 "NPR FTP Connection List"
{
    PageType = List;
    ApplicationArea = NPRRetail;
    UsageCategory = Administration;
    SourceTable = "NPR FTP Connection";
    Extensible = False;
    CardPageId = "NPR FTP Connection";
    Editable = False;
    Caption = 'FTP Connections';

    layout
    {
        area(Content)
        {
            repeater("File Server Info")
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the unique code identifer for the fileserver connection.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies a description used to help distingush FTP Connections';
                }
                field("File Server Connection"; (Rec."Username" + '@' + Rec."Server Host" + ':' + Format(Rec."Server Port")))
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Connection String';
                    ToolTip = 'Specifies the connection string to the server.';
                }
            }

        }
    }
}