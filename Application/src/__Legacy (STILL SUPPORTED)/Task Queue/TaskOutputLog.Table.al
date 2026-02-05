table 6059905 "NPR Task Output Log"
{
    Access = Internal;
    Caption = 'Task Output Log';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteTag = '2023-06-28';
    ObsoleteReason = 'Task Queue module removed from NP Retail. We are now using Job Queue instead.';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(5; "Task Log Entry No."; Integer)
        {
            Caption = 'Task Log Entry No.';
            DataClassification = CustomerContent;
        }
        field(10; "Journal Template Name"; Code[10])
        {
            Caption = 'Journal Template Name';
            DataClassification = CustomerContent;
        }
        field(11; "Journal Batch Name"; Code[10])
        {
            Caption = 'Journal Batch Name';
            DataClassification = CustomerContent;
        }
        field(12; "Journal Line No."; Integer)
        {
            Caption = 'Journal Line No.';
            DataClassification = CustomerContent;
        }
        field(20; "File"; BLOB)
        {
            Caption = 'File';
            DataClassification = CustomerContent;
        }
        field(21; "File Name"; Text[250])
        {
            Caption = 'File Name';
            DataClassification = CustomerContent;
        }
        field(30; "Import DateTime"; DateTime)
        {
            Caption = 'Import DateTime';
            DataClassification = CustomerContent;
        }
        field(40; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Task Log Entry No.")
        {
        }
        key(Key3; "Journal Template Name", "Journal Batch Name", "Journal Line No.")
        {
        }
    }
}

