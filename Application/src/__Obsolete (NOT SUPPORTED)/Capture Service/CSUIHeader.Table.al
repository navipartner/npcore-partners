table 6151373 "NPR CS UI Header"
{
    Access = Internal;

    Caption = 'CS UI Header';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteReason = 'Object moved to NP Warehouse App.';


    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(11; Description; Text[30])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(12; "No. of Records in List"; Integer)
        {
            Caption = 'No. of Records in List';
            DataClassification = CustomerContent;
        }
        field(13; "Form Type"; Option)
        {
            Caption = 'Form Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Card,Selection List,Data List,Data List Input', Locked = true;
            OptionMembers = Card,"Selection List","Data List","Data List Input";
        }
        field(14; "Expand Summary Items"; Boolean)
        {
            Caption = 'Expand Summary Items';
            DataClassification = CustomerContent;
        }
        field(15; "Start UI"; Boolean)
        {
            Caption = 'Start UI';
            DataClassification = CustomerContent;


        }
        field(16; "Hid Fulfilled Lines"; Boolean)
        {
            Caption = 'Hid Fulfilled Lines';
            DataClassification = CustomerContent;
        }
        field(17; "Add Posting Options"; Boolean)
        {
            Caption = 'Add Posting Options';
            DataClassification = CustomerContent;
            Description = 'NPR5.52 - Discontinued';
        }
        field(18; "Update Posting Date"; Boolean)
        {
            Caption = 'Update Posting Date';
            DataClassification = CustomerContent;
        }
        field(19; "Warehouse Type"; Option)
        {
            Caption = 'Warehouse Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Basic,Advanced,Advanced (Bins)';
            OptionMembers = Basic,Advanced,"Advanced (Bins)";
        }
        field(20; "Handling Codeunit"; Integer)
        {
            Caption = 'Handling Codeunit';
            DataClassification = CustomerContent;
        }
        field(21; "Next UI"; Code[20])
        {
            Caption = 'Next UI';
            DataClassification = CustomerContent;
        }
        field(22; "Set defaults from last record"; Boolean)
        {
            Caption = 'Set defaults from last record';
            DataClassification = CustomerContent;
        }
        field(23; "Posting Type"; Option)
        {
            Caption = 'Posting Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Handle,Handle & Invoice,Prompt User';
            OptionMembers = Handle,"Handle & Invoice","Prompt User";
        }
        field(25; XMLin; BLOB)
        {
            Caption = 'XMLin';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    fieldgroups
    {
    }






}

