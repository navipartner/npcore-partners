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
            ObsoleteState = Pending;
            ObsoleteTag = '2026-04-20';
            ObsoleteReason = 'Replaced by the "Last Order Import Sync At".';
        }
        field(9; "Last Order Import Sync At"; DateTime)
        {
            Caption = 'Last Orders Imported At';
            FieldClass = FlowField;
            CalcFormula = lookup("NPR Entria Store Sync State"."Last Orders Imported At" where("Store Code" = field(Code)));
            Editable = false;
        }

        field(10; "Process Order On Import"; Boolean)
        {
            Caption = 'Process Order On Import';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteTag = '2026-04-20';
            ObsoleteReason = 'The field is no longer used as orders are now processed by job queues.';
        }
        field(11; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1));
            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, "Global Dimension 1 Code");
            end;
        }
        field(12; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2));
            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2, "Global Dimension 2 Code");
            end;
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

    trigger OnInsert()
    begin
        DimMgt.UpdateDefaultDim(Database::"NPR Entria Store", Code, "Global Dimension 1 Code", "Global Dimension 2 Code");
    end;

    trigger OnDelete()
    begin
        DeleteAPIKey();
        DimMgt.DeleteDefaultDim(Database::"NPR Entria Store", Code);
        EntriaIntegrationMgt.DeleteRelatedRecords(Rec.Code);
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

    internal procedure SetLastOrdersImportedAt(StoreCode: Code[20]; NewDateTime: DateTime)
    var
        EntriaStoreSyncState: Record "NPR Entria Store Sync State";
    begin
        FindSyncState(StoreCode, EntriaStoreSyncState);
        EntriaStoreSyncState."Last Orders Imported At" := NewDateTime;
        EntriaStoreSyncState.Modify();
    end;

    local procedure FindSyncState(StoreCode: Code[20]; var EntriaStoreSyncState: Record "NPR Entria Store Sync State")
    begin
        EntriaStoreSyncState.ReadIsolation := ReadIsolation::UpdLock;
        if EntriaStoreSyncState.Get(StoreCode) then
            exit;

        EntriaStoreSyncState.Init();
        EntriaStoreSyncState."Store Code" := StoreCode;
        if not EntriaStoreSyncState.Insert() then
            EntriaStoreSyncState.Get(StoreCode);
    end;

    local procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        DimMgt.ValidateDimValueCode(FieldNumber, ShortcutDimCode);
        if not IsTemporary() then begin
            DimMgt.SaveDefaultDim(Database::"NPR Entria Store", Code, FieldNumber, ShortcutDimCode);
            Modify();
        end;
    end;

    var
        DimMgt: Codeunit DimensionManagement;
        EntriaIntegrationMgt: Codeunit "NPR Entria Integration Mgt.";
}
#endif
