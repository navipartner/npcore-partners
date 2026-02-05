table 6151527 "NPR Nc Collection"
{
    Access = Internal;
    Caption = 'Nc Collection';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteTag = '2023-06-28';
    ObsoleteReason = 'NC Collector module removed from NpCore. We switched to Job Queue instead of using Task Queue.';

    fields
    {
        field(1; "No."; BigInteger)
        {
            AutoIncrement = true;
            Caption = 'No.';
            DataClassification = CustomerContent;
        }
        field(10; "Collector Code"; Code[20])
        {
            Caption = 'Collector Code';
            DataClassification = CustomerContent;
        }
        field(30; Status; Option)
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            OptionCaption = 'Collecting,Ready to Send,Sent';
            OptionMembers = Collecting,"Ready to Send",Sent;
        }
        field(40; "Creation Date"; DateTime)
        {
            Caption = 'Creation Date';
            DataClassification = CustomerContent;
        }
        field(50; "Ready to Send Date"; DateTime)
        {
            Caption = 'Ready to Send Date';
            DataClassification = CustomerContent;
        }
        field(60; "Sent Date"; DateTime)
        {
            Caption = 'Sent Date';
            DataClassification = CustomerContent;
        }
        field(100; "Table No."; Integer)
        {
            Caption = 'Table No.';
            DataClassification = CustomerContent;
        }
        field(200; "No. of Lines"; Integer)
        {
            CalcFormula = Count("NPR Nc Collection Line" WHERE("Collector Code" = FIELD("Collector Code"),
                                                            "Collection No." = FIELD("No.")));
            Caption = 'No. of Lines';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
        }
        key(Key2; "Collector Code", Status)
        {
        }
        key(Key3; "Collector Code", "No.")
        {
        }
    }

}

