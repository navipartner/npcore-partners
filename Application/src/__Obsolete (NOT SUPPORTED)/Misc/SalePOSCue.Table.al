table 6059986 "NPR Sale POS Cue"
{
    Access = Internal;
    Caption = 'Sale POS Cue';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteReason = 'Not used';

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(20; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
        field(25; "Register Filter"; Code[10])
        {
            Caption = 'POS Unit Filter';
            FieldClass = FlowFilter;
        }
        field(26; "Salesperson Filter"; Code[20])
        {
            Caption = 'Salesperson Filter';
            FieldClass = FlowFilter;
        }
    }
    keys
    {
        key(Key1; "Primary Key")
        {
        }
    }
}

