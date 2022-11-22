table 6059792 "NPR EFT Aid Rid Mapping"
{
    Access = Internal;
    Caption = 'EFT Application ID Mapping';
    DataClassification = CustomerContent;
    LookupPageID = "NPR EFT AID Mapping List";

    fields
    {
        field(1; "AID"; Code[64])
        {
            Caption = 'ApplicationID';
            DataClassification = CustomerContent;
        }
        field(2; "RID"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Registered application provider ID';
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
        key(Key1; "AID")
        {

        }
        key(Key2; RID)
        {

        }
    }
}