table 6184511 "EFT BIN Group"
{
    // NPR5.40/NPKNAV/20180330  CASE 290734 Transport NPR5.40 - 30 March 2018
    // NPR5.42/MMV /20180507 CASE 306689 Moved "Payment Type POS" to a link table for location code support.
    // NPR5.53/MMV /20191204 CASE 349520 Added insert validation

    Caption = 'EFT BIN Group';
    DataClassification = CustomerContent;
    LookupPageID = "EFT BIN Group List";

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
                EFTBINRange: Record "EFT BIN Range";
            begin
                EFTBINRange.SetRange("BIN Group Code", Code);
                EFTBINRange.ModifyAll("BIN Group Priority", Priority);
            end;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        EFTBINRange: Record "EFT BIN Range";
    begin
        EFTBINRange.SetRange("BIN Group Code", Code);
        EFTBINRange.DeleteAll;
    end;

    trigger OnInsert()
    begin
        //-NPR5.53 [349520]
        TestField(Code);
        //+NPR5.53 [349520]
    end;
}

