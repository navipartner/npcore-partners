table 6059880 "NPR Return Info Device Setting"
{
    Access = Internal;
    Caption = 'Return Info Device Setting';
    DataClassification = CustomerContent;
    LookupPageId = "NPR ReturnInfo Device Settings";

    fields
    {
        field(1; "POS Unit No."; Code[10])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Unit";
        }
        field(10; "Terminal ID"; Text[250])
        {
            Caption = 'Terminal ID';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "POS Unit No.")
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