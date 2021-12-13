table 6014589 "NPR Replication Endpoint"
{
    Caption = 'Replication Endpoint';
    DataClassification = CustomerContent;
    Extensible = true;

    fields
    {
        field(1; "Service Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Service Code';
            TableRelation = "NPR Replication Service Setup";
        }
        field(2; "EndPoint ID"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'EndPoint ID';
        }
        field(3; Description; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }
        field(4; Path; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Path';
            trigger OnValidate()
            begin
                Rec.TestField(Enabled, false);
                Path := CopyStr(Path.TrimEnd('/'), 1, MaxStrLen(Path));
            end;
        }

        field(6; Enabled; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Enabled';
            trigger OnValidate()
            begin
                if Rec.Enabled then begin
                    Rec.TestField(Path);
                    if Rec."Endpoint Method" = Rec."Endpoint Method"::"Get BC Generic Data" then
                        Rec.TestField("Table ID");
                end;
            end;
        }
        field(7; "Sequence Order"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Sequence Order';
            trigger OnValidate()
            begin
                Rec.TestField(Enabled, false);
            end;
        }
        field(8; "Endpoint Method"; Enum "NPR Replication EndPoint Meth")
        {
            DataClassification = CustomerContent;
            Caption = 'Endpoint Method';
            trigger OnValidate()
            begin
                Rec.TestField(Enabled, false);
            end;
        }
        field(10; "Table ID"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Table ID';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
            trigger OnValidate()
            var
                Mapping: Record "NPR Rep. Special Field Mapping";
            begin
                Rec.TestField(Enabled, false);
                if CheckMappingExistForEndpoint(Mapping) then
                    Error(SpecialFieldMappingExistErr);
            end;
        }

        field(12; "Run OnInsert Trigger"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Run OnInsert Trigger';
            trigger OnValidate()
            begin
                Rec.TestField(Enabled, false);
            end;
        }

        field(13; "Run OnModify Trigger"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Run OnModify Trigger';
            trigger OnValidate()
            begin
                Rec.TestField(Enabled, false);
            end;
        }

        field(15; "odata.maxpagesize"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Odata Max Page Size';
        }

        field(17; "Skip Import Entry No Data Resp"; Boolean)
        {
            Caption = 'Skip Import Entry No Data Response';
            DataClassification = CustomerContent;
            InitValue = true;
            trigger OnValidate()
            begin
                Rec.TestField(Enabled, false);
            end;
        }

        field(18; "Fixed Filter"; Text[100])
        {
            Caption = 'Fixed Filter';
            DataClassification = CustomerContent;
        }

        field(20; "Replication Counter"; BigInteger)
        {
            DataClassification = CustomerContent;
            Caption = 'Replication Counter';
        }
    }
    keys
    {
        key(PK; "Service Code", "EndPoint ID")
        {
            Clustered = true;
        }
        key(SEC1; "Service Code", Enabled, "Sequence Order")
        {
            Description = 'Order of requests execution is based on Sequence Order.';
        }
    }

    var
        RenameNotAllowedErr: Label 'Rename not allowed. Instead, delete and recreate record.';
        SpecialFieldMappingExistErr: Label 'One or more special Field Mappings exist for this endpoint.';

    trigger OnRename()
    begin
        Error(RenameNotAllowedErr);
    end;

    trigger OnDelete()
    var
        Mapping: Record "NPR Rep. Special Field Mapping";
    begin
        if CheckMappingExistForEndpoint(Mapping) then
            Mapping.DeleteAll(true);
    end;

    procedure RegisterServiceEndPoint(pServiceCode: Code[20]; pEndPointID: Text[50]; pPath: Text[250]; pDescription: Text[100]; pEnabled: Boolean; pSeqOrder: Integer; pEndPointMethod: Enum "NPR Replication EndPoint Meth"; pReplicationCounter: BigInteger; pOdataMaxPageSize: Integer; pTableId: Integer; pRunInsert: Boolean; pRunModify: Boolean)
    begin
        Rec."Service Code" := pServiceCode;
        Rec."EndPoint ID" := pEndPointID;
        if rec.Find() then
            exit;

        Rec.Init();
        Rec.Path := pPath;
        Rec.Description := pDescription;
        Rec.Enabled := pEnabled;
        Rec."Sequence Order" := pSeqOrder;
        Rec."Endpoint Method" := pEndPointMethod;
        Rec."odata.maxpagesize" := pOdataMaxPageSize;
        Rec."Replication Counter" := pReplicationCounter;
        Rec."Skip Import Entry No Data Resp" := true;
        Rec."Table ID" := pTableId;
        Rec."Run OnInsert Trigger" := pRunInsert;
        Rec."Run OnModify Trigger" := pRunModify;

        OnRegisterServiceEndPointOnBeforeInsert();

        Rec.Insert();

        OnRegisterServiceEndPointOnAfterInsert();
    end;

    procedure CheckMappingExistForEndpoint(var Mapping: Record "NPR Rep. Special Field Mapping"): Boolean
    begin
        Mapping.SetRange("Service Code", Rec."Service Code");
        Mapping.SetRange("EndPoint ID", Rec."EndPoint ID");
        Mapping.SetRange("Table ID", Rec."Table ID");
        exit(NOT Mapping.IsEmpty());
    end;

    procedure OpenSpecialFieldMappings()
    var
        SpecFieldMappingsPage: Page "NPR Rep. Spec. Field Mappings";
        SpecFieldMappingsRec: Record "NPR Rep. Special Field Mapping";
    begin
        Rec.TestField("Table ID");
        SpecFieldMappingsRec.FilterGroup(2);
        SpecFieldMappingsRec.SetRange("Service Code", Rec."Service Code");
        SpecFieldMappingsRec.SetRange("EndPoint ID", Rec."EndPoint ID");
        SpecFieldMappingsRec.SetRange("Table ID", Rec."Table ID");
        SpecFieldMappingsRec.FilterGroup(0);
        SpecFieldMappingsPage.SetTableView(SpecFieldMappingsRec);
        SpecFieldMappingsPage.SetFieldsNonEditable();
        SpecFieldMappingsPage.SetReplicationEndpoint(Rec);
        SpecFieldMappingsPage.RunModal();
    end;

    [IntegrationEvent(true, false)]
    local procedure OnRegisterServiceEndPointOnBeforeInsert()
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnRegisterServiceEndPointOnAfterInsert()
    begin
    end;
}

