table 88000 "NPR BCPT Initialize Data Setup"
{
    Caption = 'BCPT Initialize Data Setup';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = ToBeClassified;
        }
        field(20; "Last Initialized POS Unit No."; Code[10])
        {
            Caption = 'Last Initialized POS Unit No.';
            DataClassification = ToBeClassified;
            InitValue = '1000';
        }
    }
    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    procedure FindNextPOSUnit(var POSUnit: Record "NPR POS Unit")
    begin
        LockTable(true);
        if not Get() then begin
            Init();
            Insert();
        end;

        POSUnit.SetFilter("No.", '>%1', "Last Initialized POS Unit No.");
        if POSUnit.Next() = 0 then begin
            "Last Initialized POS Unit No." := '1000';
            POSUnit.SetFilter("No.", '>%1', "Last Initialized POS Unit No.");
            POSUnit.Next();
        end;

        "Last Initialized POS Unit No." := POSUnit."No.";
        Modify();
    end;
}
