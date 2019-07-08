table 6059769 "NaviDocs Entry Comment"
{
    // NPR5.26/THRO/20160808 CASE 248662 Removed field 3 Type

    Caption = 'Document Handling Comment';

    fields
    {
        field(1;"Entry No.";BigInteger)
        {
            Caption = 'Entry No.';
        }
        field(5;"Table No.";Integer)
        {
            Caption = 'Table No.';
            TableRelation = AllObj."Object ID" WHERE ("Object Type"=CONST(Table));
        }
        field(10;"Document Type";Integer)
        {
            Caption = 'Document Type';
        }
        field(15;"Document No.";Code[20])
        {
            Caption = 'No.';
        }
        field(20;"Line No.";Integer)
        {
            Caption = 'Line No.';
        }
        field(50;Description;Text[250])
        {
            Caption = 'Description';
        }
        field(60;"Insert Date";Date)
        {
            Caption = 'Date';
            Editable = false;
        }
        field(70;"Insert Time";Time)
        {
            Caption = 'Time';
            Editable = false;
        }
        field(120;"User ID";Text[50])
        {
            Caption = 'User ID';
            Editable = false;
        }
        field(210;Warning;Boolean)
        {
            Caption = 'Warning';
        }
    }

    keys
    {
        key(Key1;"Entry No.","Line No.")
        {
        }
        key(Key2;"Table No.","Document Type","Document No.","Line No.")
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

