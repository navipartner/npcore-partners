table 6059778 "NPR Sync Profile Setup"
{
    Caption = 'Sync Profile Setup';
    DataPerCompany = false;
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteReason = 'Not used';

    fields
    {
        field(1; "Synchronisation Profile"; Code[20])
        {
            Caption = 'Synchronisation Profile';
            DataClassification = CustomerContent;
        }
        field(2; "Table No."; Integer)
        {
            Caption = 'Table No.';
            DataClassification = CustomerContent;
        }
        field(3; "Record Synchronisation Type"; Option)
        {
            Caption = 'Record Synchronisation Type';
            OptionCaption = 'All,Create,Modify,Delete';
            OptionMembers = All,Create,Modify,Delete;
            DataClassification = CustomerContent;
        }
        field(4; "Field Synchronisation Type"; Option)
        {
            Caption = 'Field Synchronisation Type';
            OptionCaption = 'Full,Partial';
            OptionMembers = Full,Partial;
            DataClassification = CustomerContent;
        }
        field(5; "Synchronisation Type"; Option)
        {
            Caption = 'Synchronisation Type';
            OptionCaption = 'Navision';
            OptionMembers = Navision;
            DataClassification = CustomerContent;
        }
        field(6; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(7; Enabled; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Synchronisation Profile", "Table No.")
        {
        }
    }
}

