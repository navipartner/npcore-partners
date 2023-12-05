table 6059868 "NPR FTP Connection"
{
    Caption = 'FTP Connection';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR FTP Connection List";
    LookupPageID = "NPR FTP Connection List";
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
            InitValue = 21;
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
        field(7; "Force Behavior"; Boolean)
        {
            Caption = 'Force';
            DataClassification = CustomerContent;
        }
        field(8; "FTP Enc. Mode"; Enum "NPR Nc FTP Encryption mode")
        {
            Caption = 'FTP Encryption Mode';
            DataClassification = CustomerContent;
            InitValue = "None";
        }
        field(9; "FTP Passive Transfer Mode"; Boolean)
        {
            Caption = 'FTP Passive Transfer Mode';
            DataClassification = CustomerContent;
            InitValue = True;
        }
    }
}