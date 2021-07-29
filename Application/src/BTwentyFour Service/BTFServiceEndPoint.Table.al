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

            trigger OnValidate()
            begin
                "EndPoint ID" := UpperCase("EndPoint ID");
            end;
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

            trigger OnValidate()
            var
                ServiceAPI: Codeunit "NPR BTF Service API";
                ImportType: Record "NPR Nc Import Type";
            begin
                if Rec.Enabled then begin
                    ServiceAPI.RegisterNcImportType(CopyStr(Rec."EndPoint ID", 1, MaxStrlen(ImportType.Code)), Rec.Description, GetImportListUpdateHandler());
                    ServiceAPI.ScheduleJobQueueEntry(Rec);
                end else begin
                    ServiceAPI.DeleteNcImportType(CopyStr(Rec."EndPoint ID", 1, MaxStrlen(ImportType.Code)));
                    ServiceAPI.CancelJob(Rec);
                end;
            end;
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

        field(30; "Next EndPoint ID"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Next EndPoint ID';
            TableRelation = "NPR BTF Service EndPoint"."EndPoint ID" where("Service Code" = field("Service Code"));
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

    trigger OnDelete()
    var
        ImportType: Record "NPR Nc Import Type";
        ServiceAPI: Codeunit "NPR BTF Service API";
    begin
        ServiceAPI.DeleteNcImportType(CopyStr(Rec."EndPoint ID", 1, MaxStrlen(ImportType.Code)));
        ServiceAPI.CancelJob(Rec);
    end;

    trigger OnRename()
    begin
        Error(RenameNotAllowedErr);
    end;

    procedure GetImportListUpdateHandler(): Enum "NPR Nc IL Update Handler"
    var
        EndPoint: Interface "NPR BTF IEndPoint";
    begin
        EndPoint := Rec."EndPoint Method";
        exit(EndPoint.GetImportListUpdateHandler());
    end;

    procedure RegisterServiceEndPoint(NewServiceCode: Code[20]; NewEndPointID: Text; NewPath: Text; NewServiceMethodName: Enum "NPR BTF Service Method"; NewDescription: Text;
                                                                                                                              NewEnabled: Boolean;
                                                                                                                              NewSeqOrder: Integer;
                                                                                                                              NewEndPointMethod: Enum "NPR BTF EndPoint Method";
                                                                                                                              NewContentType: Enum "NPR BTF Content Type";
                                                                                                                              NewAccept: Enum "NPR BTF Content Type";
                                                                                                                              NewEndPointKey: Text;
                                                                                                                              NewNextEndPointKey: Text)
    begin
        "Service Code" := NewServiceCode;
        validate("EndPoint ID", CopyStr(NewEndPointID, 1, MaxStrlen("EndPoint ID")));
        if Find() then
            exit;

        Init();
        InitServiceEndPoint(NewServiceCode, NewEndPointID, NewPath, NewServiceMethodName, NewDescription, NewEnabled, NewSeqOrder, NewEndPointMethod, NewContentType, NewAccept, NewEndPointKey, NewNextEndPointKey);
        OnAfterInit();
        Insert();
    end;

    procedure InitServiceEndPoint(NewServiceCode: Code[20]; NewEndPointID: Text; NewPath: Text; NewServiceMethodName: Enum "NPR BTF Service Method"; NewDescription: Text;
                                                                                                                          NewEnabled: Boolean;
                                                                                                                          NewSeqOrder: Integer;
                                                                                                                          NewEndPointMethod: Enum "NPR BTF EndPoint Method";
                                                                                                                          NewContentType: Enum "NPR BTF Content Type";
                                                                                                                          NewAccept: Enum "NPR BTF Content Type";
                                                                                                                          NewEndPointKey: Text;
                                                                                                                          NewNextEndPointKey: Text)
    begin
        Path := CopyStr(NewPath, 1, MaxStrlen(Path));
        Description := CopyStr(NewDescription, 1, MaxStrlen(Description));
        "Service Method Name" := NewServiceMethodName;
        Enabled := NewEnabled;
        "Sequence Order" := NewSeqOrder;
        "EndPoint Method" := NewEndPointMethod;
        "Content-Type" := NewContentType;
        Accept := NewAccept;
        "EndPoint-Key" := CopyStr(NewEndPointKey, 1, MaxStrlen("EndPoint-Key"));
        "Next EndPoint ID" := CopyStr(NewNextEndPointKey, 1, MaxStrlen("Next EndPoint ID"));
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
