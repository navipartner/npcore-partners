table 6059924 "NPR SE CC Journal Event"
{
    Access = Internal;
    Caption = 'SE CleanCash Journal Event';
    DataClassification = CustomerContent;
    Extensible = false;
    TableType = Temporary;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
        }
        field(2; "Registration Time"; DateTime)
        {
            Caption = 'Registration Time';
            DataClassification = CustomerContent;
        }
        field(3; "Event Type"; Enum "NPR SE CC Journal Event Type")
        {
            Caption = 'Event Type';
            DataClassification = CustomerContent;
        }
        field(4; "Source Entry No."; BigInteger)
        {
            Caption = 'Source Entry No.';
            DataClassification = SystemMetadata;
        }
        field(5; "Source Line No."; Integer)
        {
            Caption = 'Source Line No.';
            DataClassification = SystemMetadata;
        }
        field(6; "User Code"; Code[50])
        {
            Caption = 'User Code';
            DataClassification = EndUserPseudonymousIdentifiers;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Chronological; "Registration Time", "Entry No.")
        {
        }
    }
}
