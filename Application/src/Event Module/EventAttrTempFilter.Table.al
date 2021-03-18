table 6060163 "NPR Event Attr. Temp. Filter"
{
    Caption = 'Event Attribute Temp. Filter';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Template Name"; Code[20])
        {
            Caption = 'Template Name';
            DataClassification = CustomerContent;
        }
        field(2; "Filter Name"; Code[20])
        {
            Caption = 'Filter Name';
            DataClassification = CustomerContent;
        }
        field(10; Description; Text[30])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Template Name", "Filter Name")
        {
        }
    }

    fieldgroups
    {
    }
}

