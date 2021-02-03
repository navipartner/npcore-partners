table 6014431 "NPR Record Field Setup"
{
    Caption = 'Record Field Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Table ID"; Integer)
        {
            Caption = 'Table ID';
            NotBlank = true;
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(Table));
            DataClassification = CustomerContent;
        }
        field(2; "Custom Field No. 1"; Code[20])
        {
            Caption = 'Custom Field No. 1';
            TableRelation = "NPR Record Field Type".Code;
            DataClassification = CustomerContent;
        }
        field(3; "Custom Field No. 2"; Code[20])
        {
            Caption = 'Custom Field No. 2';
            TableRelation = "NPR Record Field Type".Code;
            DataClassification = CustomerContent;
        }
        field(4; "Custom Field No. 3"; Code[20])
        {
            Caption = 'Custom Field No. 3';
            TableRelation = "NPR Record Field Type".Code;
            DataClassification = CustomerContent;
        }
        field(5; "Custom Field No. 4"; Code[20])
        {
            Caption = 'Custom Field No. 4';
            TableRelation = "NPR Record Field Type".Code;
            DataClassification = CustomerContent;
        }
        field(6; "Custom Field No. 5"; Code[20])
        {
            Caption = 'Custom Field No. 5';
            TableRelation = "NPR Record Field Type".Code;
            DataClassification = CustomerContent;
        }
        field(7; "Custom Field No. 6"; Code[20])
        {
            Caption = 'Custom Field No. 6';
            TableRelation = "NPR Record Field Type".Code;
            DataClassification = CustomerContent;
        }
        field(8; "Custom Field No. 7"; Code[20])
        {
            Caption = 'Custom Field No. 7';
            TableRelation = "NPR Record Field Type".Code;
            DataClassification = CustomerContent;
        }
        field(9; "Custom Field No. 8"; Code[20])
        {
            Caption = 'Custom Field No. 8';
            TableRelation = "NPR Record Field Type".Code;
            DataClassification = CustomerContent;
        }
        field(10; "Custom Field No. 9"; Code[20])
        {
            Caption = 'Custom Field No. 9';
            TableRelation = "NPR Record Field Type".Code;
            DataClassification = CustomerContent;
        }
        field(11; "Custom Field No. 10"; Code[20])
        {
            Caption = 'Custom Field No. 10';
            TableRelation = "NPR Record Field Type".Code;
            DataClassification = CustomerContent;
        }
        field(20; "Text Field 1 Caption"; Text[30])
        {
            Caption = 'Text Field 1 Caption';
            DataClassification = CustomerContent;
        }
        field(21; "Text Field 2 Caption"; Text[30])
        {
            Caption = 'Text Field 2 Caption';
            DataClassification = CustomerContent;
        }
        field(30; "Decimal Field 1 Caption"; Text[30])
        {
            Caption = 'Decimal Field 1 Caption';
            DataClassification = CustomerContent;
        }
        field(31; "Decimal Field 2 Caption"; Text[30])
        {
            Caption = 'Decimal Field 2 Caption';
            DataClassification = CustomerContent;
        }
        field(40; "Code Field 1 Caption"; Text[30])
        {
            Caption = 'Code Field 1 Caption';
            DataClassification = CustomerContent;
        }
        field(41; "Code Field 2 Caption"; Text[30])
        {
            Caption = 'Code Field 2 Caption';
            DataClassification = CustomerContent;
        }
        field(200; "Code Field 1 Table No."; Integer)
        {
            Caption = 'Code Field 1 Table No.';
            DataClassification = CustomerContent;
        }
        field(201; "Code Field 2 Table No."; Integer)
        {
            Caption = 'Code Field 2 Table No.';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Table ID")
        {
        }
    }
}

