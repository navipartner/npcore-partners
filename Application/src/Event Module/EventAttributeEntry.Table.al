table 6060159 "NPR Event Attribute Entry"
{
    Access = Internal;
    Caption = 'Event Attribute Entry';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(10; "Template Name"; Code[20])
        {
            Caption = 'Template Name';
            DataClassification = CustomerContent;
            TableRelation = "NPR Event Attribute Template";
        }
        field(20; "Job No."; Code[20])
        {
            Caption = 'Job No.';
            DataClassification = CustomerContent;
        }
        field(30; "Row Line No."; Integer)
        {
            Caption = 'Row Line No.';
            DataClassification = CustomerContent;
        }
        field(40; "Column Line No."; Integer)
        {
            Caption = 'Column Line No.';
            DataClassification = CustomerContent;
        }
        field(50; "Value Text"; Text[250])
        {
            Caption = 'Value Text';
            DataClassification = CustomerContent;
        }
        field(60; "Value Decimal"; Decimal)
        {
            Caption = 'Value Decimal';
            DataClassification = CustomerContent;
        }
        field(70; "Filter"; Boolean)
        {
            Caption = 'Filter';
            DataClassification = CustomerContent;
            Description = 'NPR5.33';
        }
        field(80; "Filter Name"; Code[20])
        {
            Caption = 'Filter Name';
            DataClassification = CustomerContent;
            Description = 'NPR5.33';
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
    }
}

