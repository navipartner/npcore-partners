table 6060114 "NPR TM Ticket Access Fact"
{
    Caption = 'Ticket Access Fact';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR TM Ticket Access Facts";
    LookupPageID = "NPR TM Ticket Access Facts";

    fields
    {
        field(1; "Fact Name"; Option)
        {
            Caption = 'Fact Name';
            DataClassification = CustomerContent;
            OptionCaption = 'Item,Ticket Type,Admission Date,Admission Hour,Admission Code,Variant Code';
            OptionMembers = ITEM,TICKET_TYPE,ADMISSION_DATE,ADMISSION_HOUR,ADMISSION_CODE,VARIANT_CODE;
        }
        field(2; "Fact Code"; Code[20])
        {
            Caption = 'Fact Code';
            DataClassification = CustomerContent;
        }
        field(10; Description; Text[30])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(11; Block; Boolean)
        {
            Caption = 'Block';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Fact Name", "Fact Code")
        {
        }
    }

    fieldgroups
    {
    }
}

