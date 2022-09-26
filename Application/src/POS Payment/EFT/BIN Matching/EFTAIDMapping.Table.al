table 6059783 "NPR EFT AID Mapping"
{
    Access = Internal;
    Caption = 'EFT Application ID Mapping';
    DataClassification = CustomerContent;
    LookupPageID = "NPR EFT AID Mapping List";

    fields
    {
        field(1; "ApplicationID"; Code[50])
        {
            Caption = 'ApplicationID';
            DataClassification = CustomerContent;
        }
        field(2; "Description"; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(3; "Bin Group Code"; Code[10])
        {
            Caption = 'Bin Group Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR EFT BIN Group";
        }
    }

    keys
    {
        key(Key1; "ApplicationID")
        {

        }
    }

    procedure RID(): Text
    var
        txt: Text;
    begin
        txt := Rec.ApplicationID;
        exit(txt.Substring(1, 10));
    end;

    procedure PIX(): Text
    var
        txt: Text;
    begin
        txt := Rec.ApplicationID;
        exit(txt.Substring(11));
    end;
}