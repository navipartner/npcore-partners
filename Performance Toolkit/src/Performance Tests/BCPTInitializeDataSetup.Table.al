table 88000 "NPR BCPT Initialize Data Setup"
{
    Caption = 'BCPT Initialize Data Setup';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(20; "Last Initialized POS Unit No."; Code[10])
        {
            Caption = 'Last Initialized POS Unit No.';
            DataClassification = CustomerContent;
            InitValue = '1000';
        }
        field(30; "Create Sales Until Date Time"; DateTime)
        {
            Caption = 'Create Sales Until Date Time';
            DataClassification = CustomerContent;
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
        GetSetup();
        FindNextPOSUnitAndSetItAsLastInitialized(POSUnit);
        Modify();
    end;

    procedure FindNextPOSUnitAndSetCreateSalesUntilDateTime(var POSUnit: Record "NPR POS Unit"; var CreateSalesUntilDateTime: DateTime; CreateSalesForNoOfMinutes: Integer)
    begin
        GetSetup();
        FindNextPOSUnitAndSetItAsLastInitialized(POSUnit);
        SetCreateSalesUntilDateTime(CreateSalesUntilDateTime, CreateSalesForNoOfMinutes);
        Modify();
    end;

    local procedure GetSetup()
    begin
        LockTable(true);
        if not Get() then begin
            Init();
            Insert();
        end;
    end;

    local procedure FindNextPOSUnitAndSetItAsLastInitialized(var POSUnit: Record "NPR POS Unit")
    begin
        POSUnit.SetFilter("No.", '>%1', "Last Initialized POS Unit No.");
        if POSUnit.Next() = 0 then begin
            "Last Initialized POS Unit No." := '1000';
            POSUnit.SetFilter("No.", '>%1', "Last Initialized POS Unit No.");
            POSUnit.Next();
        end;

        "Last Initialized POS Unit No." := POSUnit."No.";
    end;

    local procedure SetCreateSalesUntilDateTime(var CreateSalesUntilDateTime: DateTime; CreateSalesForNoOfMinutes: Integer)
    begin
        CreateSalesUntilDateTime := CurrentDateTime() + (CreateSalesForNoOfMinutes * 1000 * 60);
        if "Create Sales Until Date Time" <> 0DT then begin
            if CreateSalesUntilDateTime - "Create Sales Until Date Time" > 60000 then
                "Create Sales Until Date Time" := CreateSalesUntilDateTime
            else
                CreateSalesUntilDateTime := "Create Sales Until Date Time";
        end else
            "Create Sales Until Date Time" := CreateSalesUntilDateTime;
    end;
}
