table 6059769 "NPR NaviDocs Entry Comment"
{
    // NPR5.26/THRO/20160808 CASE 248662 Removed field 3 Type

    Caption = 'Document Handling Comment';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(5; "Table No."; Integer)
        {
            Caption = 'Table No.';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
            DataClassification = CustomerContent;
        }
        field(10; "Document Type"; Integer)
        {
            Caption = 'Document Type';
            DataClassification = CustomerContent;
        }
        field(15; "Document No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
        }
        field(20; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(50; Description; Text[250])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(60; "Insert Date"; Date)
        {
            Caption = 'Date';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(70; "Insert Time"; Time)
        {
            Caption = 'Time';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(120; "User ID"; Text[50])
        {
            Caption = 'User ID';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(210; Warning; Boolean)
        {
            Caption = 'Warning';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.", "Line No.")
        {
        }
        key(Key2; "Table No.", "Document Type", "Document No.", "Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        "Insert Date" := Today;
        "Insert Time" := Time;

        "User ID" := UserId;
    end;

    var
        Resource: Record Resource;
}

