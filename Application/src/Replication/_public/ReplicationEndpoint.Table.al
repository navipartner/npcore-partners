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
                Path := Path.TrimEnd('/');
            end;
        }

        field(6; Enabled; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Enabled';
            trigger OnValidate()
            begin
                IF Rec.Enabled then
                    Rec.TestField(Path);
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

        field(15; "odata.maxpagesize"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Odata Max Page Size';
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

    trigger OnRename()
    begin
        Error(RenameNotAllowedErr);
    end;

    trigger OnDelete()
    begin
        Rec.TestField(Enabled, false);
    end;

    procedure RegisterServiceEndPoint(pServiceCode: Code[20]; pEndPointID: Text; pPath: Text; pDescription: Text; pEnabled: Boolean; pSeqOrder: Integer; pEndPointMethod: Enum "NPR Replication EndPoint Meth"; pReplicationCounter: BigInteger; pOdataMaxPageSize: Integer)
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

        OnRegisterServiceEndPointOnBeforeInsert();

        Rec.Insert();
    end;

    [IntegrationEvent(true, false)]
    local procedure OnRegisterServiceEndPointOnBeforeInsert()
    begin
    end;
}

