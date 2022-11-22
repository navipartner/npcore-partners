table 6059783 "NPR EFT AID Mapping"
{
    Access = Internal;
    Caption = 'EFT Application ID Mapping';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteReason = 'Wrong Format this table did not have code fields big enough';

    fields
    {
        field(1; "ApplicationID"; Code[50])
        {
            Caption = 'ApplicationID';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Wrong Format this table did not have code fields big enough';
        }
        field(2; "Description"; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Wrong Format this table did not have code fields big enough';
        }
        field(3; "Bin Group Code"; Code[10])
        {
            Caption = 'Bin Group Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR EFT BIN Group";
            ObsoleteState = Removed;
            ObsoleteReason = 'Wrong Format this table did not have code fields big enough';
        }
        field(4; "RID"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Registered application provider ID';
            ObsoleteState = Removed;
            ObsoleteReason = 'Wrong Format this table did not have code fields big enough';
        }
    }

    keys
    {
        key(Key1; "ApplicationID")
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'Wrong Format this table did not have code fields big enough';
        }
        key(Key2; RID)
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'Wrong Format this table did not have code fields big enough';
        }
    }
}