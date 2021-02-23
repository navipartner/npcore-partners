table 6184511 "NPR EFT BIN Group"
{
    Caption = 'EFT Mapping Group';
    DataClassification = CustomerContent;
    LookupPageID = "NPR EFT BIN Group List";

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(4; Priority; Integer)
        {
            Caption = 'Priority';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                EFTBINRange: Record "NPR EFT BIN Range";
            begin
                EFTBINRange.SetRange("BIN Group Code", Code);
                EFTBINRange.ModifyAll("BIN Group Priority", Priority);
            end;
        }
        field(5; "Card Issuer ID"; Text[30])
        {
            DataClassification = CustomerContent;
            Caption = 'Card Issuer ID';
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    trigger OnDelete()
    var
        EFTBINRange: Record "NPR EFT BIN Range";
    begin
        EFTBINRange.SetRange("BIN Group Code", Code);
        EFTBINRange.DeleteAll;
    end;

    trigger OnInsert()
    begin
        TestField(Code);
    end;
}

