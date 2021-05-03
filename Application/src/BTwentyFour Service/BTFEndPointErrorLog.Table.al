table 6014524 "NPR BTF EndPoint Error Log"
{
    DataClassification = CustomerContent;
    Caption = 'BTwentyFour Error Log';
    LookupPageId = "NPR BTF EndPoints Error Log";

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            DataClassification = CustomerContent;
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(2; "Service Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Service Code';
        }
        field(3; "EndPoint ID"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'EndPoint ID';
        }
        field(4; Path; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Path';
        }
        field(5; "Service Method Name"; Enum "NPR BTF Service Method")
        {
            DataClassification = CustomerContent;
            Caption = 'Service Method Name';
        }
        field(6; "Content-Type"; Enum "NPR BTF Content Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Content-Type';
        }
        field(7; Accept; Enum "NPR BTF Content Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Accept';
        }
        field(8; "EndPoint-Key"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Endpoint Key';
        }
        field(9; "Sent on Date"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Sent on Date';
        }
        field(10; "Sent by User ID"; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Sent by User ID';
        }
        field(11; "Subscription-Key"; Text[50])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Subscription Key';
        }
        field(12; Environment; Enum "NPR BTF Environment")
        {
            DataClassification = CustomerContent;
            Caption = 'Environment';
        }
        field(13; "API Username"; Text[100])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'API User Name';
        }
        field(14; Portal; Text[100])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Portal';
        }
        field(15; "EndPoint Enabled"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'EndPoint Enabled';
        }
        field(16; "API Password"; Text[50])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'API Password';
        }
        field(17; Response; Media)
        {
            DataClassification = CustomerContent;
            Caption = 'Response';
        }
        field(18; "Response Note"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Response Note';
        }
        field(19; "Authroization EndPoint ID"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Authorization EndPoint ID';
        }
        field(20; "Response File Name"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Response File Name';
        }
        field(21; "Service URL"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Service URL';
        }
        field(22; "Initiatied From Rec. ID"; RecordID)
        {
            DataClassification = CustomerContent;
            Caption = 'Initiatied From Rec. ID';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }

    procedure InitRec(CurrUserId: Code[50]; InitiatiedFromRecID: RecordID)
    begin
        Rec.Init();
        Rec."Sent on Date" := CurrentDateTime();
        Rec."Sent by User ID" := CurrUserId;
        Rec."Initiatied From Rec. ID" := InitiatiedFromRecID;

        OnAfterInitRec(Rec);
    end;

    procedure InitTempRec(EntryNo: Integer; CurrUserId: Code[50]; InitiatiedFromRecID: RecordID)
    begin
        if not Rec.Istemporary() then
            exit;

        Rec."Entry No." := EntryNo;
        Rec.Init();
        Rec."Sent on Date" := CurrentDateTime();
        Rec."Sent by User ID" := CurrUserId;
        Rec."Initiatied From Rec. ID" := InitiatiedFromRecID;

        OnAfterInitRec(Rec);
    end;

    procedure CopyFromServiceSetup(ServiceSetup: Record "NPR BTF Service Setup")
    begin
        Rec."Service Code" := ServiceSetup.Code;
        Rec."Subscription-Key" := ServiceSetup."Subscription-Key";
        Rec.Environment := ServiceSetup.Environment;
        Rec."API Username" := ServiceSetup.Username;
        Rec."API Password" := ServiceSetup.Password;
        Rec.Portal := ServiceSetup.Portal;
        Rec."Authroization EndPoint ID" := ServiceSetup."Authroization EndPoint ID";
        Rec."Service URL" := ServiceSetup."Service URL";

        OnAfterCopyFromServiceSetup(Rec, ServiceSetup);
    end;

    procedure CopyFromServiceEndPoint(ServiceEndPoint: Record "NPR BTF Service EndPoint")
    begin
        Rec."EndPoint ID" := ServiceEndPoint."EndPoint ID";
        Rec.Path := ServiceEndPoint.Path;
        Rec."Service Method Name" := ServiceEndPoint."Service Method Name";
        Rec."Content-Type" := ServiceEndPoint."Content-Type";
        Rec.Accept := ServiceEndPoint.Accept;
        Rec."EndPoint-Key" := ServiceEndPoint."EndPoint-Key";
        Rec."EndPoint Enabled" := ServiceEndPoint.Enabled;

        OnAfterCopyFromServiceEndPoint(Rec, ServiceEndPoint);
    end;

    procedure SetResponse(ResponseBlob: Codeunit "Temp Blob"; ServiceEndPoint: Record "NPR BTF Service EndPoint"; ErrorNote: Text)
    var
        EndPoint: Interface "NPR BTF IEndPoint";
        FormatResponse: Interface "NPR BTF IFormatResponse";
        InStr: InStream;
    begin
        Rec."Response Note" := CopyStr(ErrorNote, 1, MaxStrLen(Rec."Response Note"));
        if ResponseBlob.HasValue() then begin
            EndPoint := ServiceEndPoint."EndPoint Method";
            FormatResponse := ServiceEndPoint.Accept;

            Rec."Response File Name" := EndPoint.GetDefaultFileName(ServiceEndPoint) + '.' + FormatResponse.GetFileExtension();

            ResponseBlob.CreateInStream(InStr);
            Rec.Response.ImportStream(InStr, EndPoint.GetDefaultFileName(ServiceEndPoint));
        end;
        OnAfterSetResponse(Rec, ResponseBlob, ServiceEndPoint);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitRec(var Sender: Record "NPR BTF EndPoint Error Log")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyFromServiceSetup(var Sender: Record "NPR BTF EndPoint Error Log"; ServiceSetup: Record "NPR BTF Service Setup")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyFromServiceEndPoint(var Sender: Record "NPR BTF EndPoint Error Log"; ServiceEndPoint: Record "NPR BTF Service EndPoint")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetResponse(var Sender: Record "NPR BTF EndPoint Error Log"; ResponseBlob: Codeunit "Temp Blob"; ServiceEndPoint: Record "NPR BTF Service EndPoint")
    begin
    end;
}
