table 6014523 "NPR BTF Service EndPoint"
{
    DataClassification = CustomerContent;
    Caption = 'BTwentyFour Service EndPoint';
    LookupPageId = "NPR BTF Service EndPoints";

    fields
    {
        field(1; "Service Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Service Code';
            TableRelation = "NPR BTF Service Setup";
        }
        field(2; "EndPoint ID"; Text[250])
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
            var
                ServiceAPI: codeunit "NPR BTF Service API";
            begin
                ServiceAPI.RemoveLastSlashFromPath(Path, 1);
            end;
        }
        field(5; "Service Method Name"; Enum "NPR BTF Service Method")
        {
            DataClassification = CustomerContent;
            Caption = 'Service Method Name';
        }

        field(6; Enabled; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Enabled';
        }
        field(7; "Sequence Order"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Sequence Order';
        }
        field(8; "EndPoint Method"; Enum "NPR BTF EndPoint Method")
        {
            DataClassification = CustomerContent;
            Caption = 'EndPoint Method';
        }
        field(9; "Content-Type"; Enum "NPR BTF Content Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Content-Type';
        }
        field(10; Accept; Enum "NPR BTF Content Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Accept';
        }
        field(11; "EndPoint-Key"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Endpoint Key';
        }
    }

    keys
    {
        key(PK; "Service Code", "EndPoint ID")
        {
            Clustered = true;
        }
    }

    var
        RenameNotAllowedErr: Label 'Rename not allowed. Instead, delete and recreate record.';

    trigger OnRename()
    begin
        Error(RenameNotAllowedErr);
    end;

    procedure RegisterServiceEndPoint(NewServiceCode: Code[10]; NewEndPointID: Text; NewPath: Text; NewServiceMethodName: Enum "NPR BTF Service Method"; NewDescription: Text; NewEnabled: Boolean; NewSeqOrder: Integer; NewEndPointMethod: Enum "NPR BTF EndPoint Method"; NewContentType: Enum "NPR BTF Content Type"; NewAccept: Enum "NPR BTF Content Type"; NewEndPointKey: Text)
    begin
        "Service Code" := NewServiceCode;
        "EndPoint ID" := NewEndPointID;
        if Find() then
            exit;

        Init();
        Path := NewPath;
        Description := NewDescription;
        "Service Method Name" := NewServiceMethodName;
        Enabled := NewEnabled;
        "Sequence Order" := NewSeqOrder;
        "EndPoint Method" := NewEndPointMethod;
        "Content-Type" := NewContentType;
        Accept := NewAccept;
        "EndPoint-Key" := NewEndPointKey;

        OnAfterInit();

        Insert();
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterInit()
    begin
    end;

    [IntegrationEvent(true, false)]
    procedure OnRegisterServiceEndPoint()
    begin
    end;
}
