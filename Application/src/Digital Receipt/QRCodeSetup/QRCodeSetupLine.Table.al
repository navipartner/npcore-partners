table 6059927 "NPR QR Code Setup Line"
{
    Access = Internal;
    Caption = 'QR Code Setup Line';
    DataClassification = CustomerContent;
    LookupPageId = "NPR QR Code Setup Lines";

    fields
    {
        field(1; "QR Code Setup Header Code"; Code[20])
        {
            Caption = 'QR Code Setup Header Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR QR Code Setup Header".Code;
        }
        field(10; "POS Unit No."; Code[10])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Unit";
        }
        field(20; "Terminal ID"; Text[200])
        {
            Caption = 'Terminal ID';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "QR Code Setup Header Code", "POS Unit No.")
        {
            Clustered = true;
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; "POS Unit No.", "Terminal ID")
        {
        }
    }

    trigger OnInsert()
    begin
        TestField("POS Unit No.");
    end;

    trigger OnModify()
    begin
        TestField("POS Unit No.");
    end;

    trigger OnRename()
    begin
        TestField("POS Unit No.");
    end;
}
