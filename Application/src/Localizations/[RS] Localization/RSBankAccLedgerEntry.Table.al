table 6060023 "NPR RS Bank Acc. Ledger Entry"
{
    Caption = 'RS Bank Account Ledger Entry';
    Access = Internal;
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Table SystemId"; Guid)
        {
            Caption = 'Table SystemId';
            DataClassification = CustomerContent;
        }
        field(5; "Document Type"; Enum "Gen. Journal Document Type")
        {
            Caption = 'Document Type';
            DataClassification = CustomerContent;
        }
        field(51; "Bal. Account Type"; Enum "Gen. Journal Account Type")
        {
            Caption = 'Bal. Account Type';
            DataClassification = CustomerContent;
        }
        field(52; "Bal. Account No."; Code[20])
        {
            Caption = 'Bal. Account No.';
            DataClassification = CustomerContent;
            TableRelation = IF ("Bal. Account Type" = CONST("G/L Account")) "G/L Account"
            ELSE
            IF ("Bal. Account Type" = CONST(Customer)) Customer
            ELSE
            IF ("Bal. Account Type" = CONST(Vendor)) Vendor
            ELSE
            IF ("Bal. Account Type" = CONST("Bank Account")) "Bank Account"
            ELSE
            IF ("Bal. Account Type" = CONST("Fixed Asset")) "Fixed Asset"
            ELSE
            IF ("Bal. Account Type" = CONST(Employee)) Employee;
        }
        field(6014400; Prepayment; Boolean)
        {
            Caption = 'Prepayment';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Table SystemId")
        {
            Clustered = true;
        }
    }

    internal procedure Save()
    begin
        if not Insert() then
            Modify();
    end;

    internal procedure Read(IncSystemId: Guid)
    var
        RSLocalisationMgt: Codeunit "NPR RS Localisation Mgt.";
    begin
        if not RSLocalisationMgt.GetLocalisationSetupEnabled() then
            exit;
        if not Rec.Get(IncSystemId) then begin
            Rec.Init();
            Rec."Table SystemId" := IncSystemId;
        end;
    end;
}