#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
table 6059910 "NPR Entria Store"
{
    Caption = 'Entria Store';
    Access = Internal;
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR Entria Stores";
    LookupPageId = "NPR Entria Stores";
    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(2; Enabled; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                if Enabled then
                    TestField("Entria Url");
                if (CurrFieldNo = FieldNo(Enabled)) and (Enabled <> xRec.Enabled) then
                    Modify();
                EntriaIntegrationMgt.SetupJobQueues();
            end;
        }
        field(3; "Entria Url"; Text[250])
        {
            Caption = 'Entria Base Url';
            DataClassification = CustomerContent;
            ExtendedDatatype = URL;
            trigger OnValidate()
            begin
                EntriaIntegrationMgt.ValidateEntriaUrl(Rec);
            end;
        }
        field(4; Description; Text[250])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(5; "Entria API Key Token"; Guid)
        {
            Caption = 'Entria API Key';
            DataClassification = CustomerContent;
            ExtendedDatatype = Masked;
        }
        field(6; "Sales Order Integration"; Boolean)
        {
            Caption = 'Sales Order Integration';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                if (CurrFieldNo = FieldNo("Sales Order Integration")) and ("Sales Order Integration" <> xRec."Sales Order Integration") then begin
                    Modify();
                    EntriaIntegrationMgt.SetupJobQueues();
                end;
            end;
        }
        field(7; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
            TableRelation = Location.Code;
        }
        field(8; "Last Orders Imported At"; DateTime)
        {
            Caption = 'Last Orders Imported At';
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
                JQRunningErr: Label 'The "Last Orders Imported At" value cannot be modified while the order import job is running. Stop the job queue and try again.';
            begin
                if EntriaIntegrationMgt.HasRunningEntriaJob() then
                    Error(JQRunningErr);
            end;
        }
        field(10; "Process Order On Import"; Boolean)
        {
            Caption = 'Process Order On Import';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
        key(SK1; Enabled, "Sales Order Integration")
        {
        }
    }

    trigger OnDelete()
    begin
        DeleteAPIKey();
    end;

    [NonDebuggable]
    internal procedure GetAPIKey() ApiKeyValue: Text
    begin
        IsolatedStorage.Get("Entria API Key Token", DataScope::Company, ApiKeyValue);
    end;

    [NonDebuggable]
    internal procedure SetAPIKey(NewApiKeyValue: Text)
    begin
        if IsNullGuid(Rec."Entria API Key Token") then
            Rec."Entria API Key Token" := CreateGuid();

        if EncryptionEnabled() then
            IsolatedStorage.SetEncrypted(Rec."Entria API Key Token", NewApiKeyValue, DataScope::Company)
        else
            IsolatedStorage.Set(Rec."Entria API Key Token", NewApiKeyValue, DataScope::Company);
    end;

    internal procedure DeleteAPIKey()
    begin
        if IsNullGuid(Rec."Entria API Key Token") then
            exit;

        IsolatedStorage.Delete(Rec."Entria API Key Token", DataScope::Company);
    end;

    internal procedure HasAPIKey(): Boolean
    begin
        if IsNullGuid(Rec."Entria API Key Token") then
            exit(false);

        exit(IsolatedStorage.Contains(Rec."Entria API Key Token", DataScope::Company));
    end;

    internal procedure SetLastOrdersImportedAt(NewLastOrdersImportedAt: DateTime)
    begin
        Rec."Last Orders Imported At" := NewLastOrdersImportedAt;
        Rec.Modify(true);
    end;

    var
        EntriaIntegrationMgt: Codeunit "NPR Entria Integration Mgt.";
}
#endif
