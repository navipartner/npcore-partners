table 6014602 "NPR Rep. Special Field Mapping"
{
    Caption = 'Replication Special Field Mapping';
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

        field(10; "Table ID"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Table ID';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
        }

        field(20; "Field ID"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Field ID';
            TableRelation = Field."No." where(TableNo = Field("Table ID"));
        }

        field(21; "Field Name"; Text[30])
        {
            Caption = 'Field Name';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup(Field.FieldName WHERE(TableNo = Field("Table ID"), "No." = field("Field ID")));
        }

        field(25; "API Field Name"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'API Field Name';
        }

        field(27; "With Validation"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'With Validation';
        }

        field(28; "Skip"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Skip';
        }

        field(30; Priority; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Priority';
        }

    }
    keys
    {
        key(PK; "Service Code", "EndPoint ID", "Table ID", "Field ID", Priority)
        {
            Clustered = true;
        }
    }

    procedure RegisterSpecialFieldMapping(pServiceCode: Code[20]; pEndPointID: Text[50]; pTableID: integer; pFieldId: integer; pAPIFieldName: Text[100]; pPriority: Integer; pValidate: Boolean; pSkip: Boolean)
    begin
        Rec."Service Code" := pServiceCode;
        Rec."EndPoint ID" := pEndPointID;
        Rec."Table ID" := pTableID;
        Rec."Field ID" := pFieldId;
        Rec.Priority := pPriority;
        if rec.Find() then
            exit;

        Rec.Init();
        Rec."API Field Name" := pAPIFieldName;
        Rec."With Validation" := pValidate;
        Rec.Skip := pSkip;

        OnRegisterServiceEndPointOnBeforeInsert();

        Rec.Insert();
    end;

    procedure CopyFromEndpointToEndpoint(FromEndpoint: Record "NPR Replication Endpoint"; ToEndpoint: Record "NPR Replication Endpoint")
    var
        SpecialFieldMapping: Record "NPR Rep. Special Field Mapping";
    begin
        IF (ToEndpoint."Table ID" = 0) or (FromEndpoint."Table ID" = 0) then
            exit;

        SpecialFieldMapping.SetRange("Service Code", FromEndpoint."Service Code");
        SpecialFieldMapping.SetRange("EndPoint ID", FromEndpoint."EndPoint ID");
        SpecialFieldMapping.SetRange("Table ID", FromEndpoint."Table ID");
        IF SpecialFieldMapping.FindSet() then
            repeat
                Rec := SpecialFieldMapping;
                Rec."Service Code" := ToEndpoint."Service Code";
                Rec."EndPoint ID" := ToEndpoint."EndPoint ID";
                Rec.Insert(true);
            until SpecialFieldMapping.Next() = 0;
    end;

    [IntegrationEvent(true, false)]
    local procedure OnRegisterServiceEndPointOnBeforeInsert()
    begin
    end;
}

