table 6059867 "NPR SFTP Connection"
{
    Caption = 'SFTP Connection';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR SFTP Connection List";
    LookupPageID = "NPR SFTP Connection List";
    Extensible = False;
    Access = public;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(2; "Description"; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(3; "Server Host"; Text[250])
        {
            Caption = 'Server Hostname/Ip address';
            DataClassification = CustomerContent;
            NotBlank = True;
        }
        field(4; "Server Port"; Integer)
        {
            Caption = 'Server Port';
            DataClassification = CustomerContent;
            InitValue = 22;
        }
        field(5; "Username"; Text[200])
        {
            Caption = 'Server Username';
            DataClassification = CustomerContent;
        }
        field(6; "Password"; Text[200])
        {
            ExtendedDatatype = Masked;
            Caption = 'Server Password';
            DataClassification = CustomerContent;
        }
        field(7; "Server SSH Key"; Blob)
        {
            Caption = 'Server SSH Key';
            DataClassification = CustomerContent;
        }
        field(8; "Force Behavior"; Boolean)
        {
            Caption = 'Force';
            DataClassification = CustomerContent;
        }
    }
}