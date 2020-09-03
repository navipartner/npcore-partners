codeunit 6014675 "NPR Endpoint Management"
{
    // NPR5.23\BR\20160518  CASE 237658 Object created
    // NPR5.25\BR\20160802  CASE 234602 Added function CreateQuery


    trigger OnRun()
    var
        RecItem: Record Item;
    begin
        RecItem.SetFilter("No.", '1..11000');
        RecItem.SetRange("Net Weight", 0, 99);
        CreateOutboundEndpointQuery('Item', RecItem, true);
    end;

    procedure GetEndpointRequestBatchNo(EndpointCode: Code[20]): BigInteger
    var
        EndpointRequestBatch: Record "NPR Endpoint Request Batch";
        Endpoint: Record "NPR Endpoint";
    begin
        with EndpointRequestBatch do begin
            Reset;
            SetCurrentKey("Endpoint Code", Status);
            SetRange("Endpoint Code", EndpointCode);
            SetRange(Status, Status::Collecting);
            if FindLast then begin
                Endpoint.Get(EndpointCode);
                if Endpoint."Max. Requests per Batch" = 0 then
                    exit("No.");
                CalcFields("No. of Requests");
                if "No. of Requests" < Endpoint."Max. Requests per Batch" then
                    exit("No.");
                if Endpoint."Send when Max. Requests" then begin
                    Validate(Status, Status::"Ready to Send");
                    Modify(true);
                end;
            end;
            Init;
            "No." := 0;
            Validate("Endpoint Code", EndpointCode);
            Validate(Status, Status::Collecting);
            Endpoint.Get(EndpointCode);
            "Table No." := Endpoint."Table No.";
            "Creation Date" := CurrentDateTime;
            Insert(true);
            exit("No.");
        end;
    end;

    procedure PopulatePKFields(var EndpointRequest: Record "NPR Endpoint Request"; RecRef: RecordRef)
    var
        RecIDChange: RecordID;
        RecRefchange: RecordRef;
        FieldRefPKField: FieldRef;
        ToRecRef: RecordRef;
        ToFieldRef: FieldRef;
        PKKeyRef: KeyRef;
        I: Integer;
    begin
        //RecIDChange := EndpointRequest."Record ID";
        //RecRefchange := RecIDChange.GETRECORD;

        case EndpointRequest."Table No." of
            127:
                begin
                    FieldRefPKField := RecRef.Field(1);
                    EndpointRequest."PK Code 1" := Format(FieldRefPKField.Value);
                end;
            else begin
                    PKKeyRef := RecRef.KeyIndex(1);
                    ToRecRef.GetTable(EndpointRequest);
                    for I := 1 to PKKeyRef.FieldCount do begin
                        FieldRefPKField := PKKeyRef.FieldIndex(I);
                        ToFieldRef := ToRecRef.Field(EndpointRequest.FieldNo("PK Code 1"));
                        if FieldRefPKField.Type = ToFieldRef.Type then begin
                            if EndpointRequest."PK Code 1" = '' then
                                EndpointRequest."PK Code 1" := FieldRefPKField.Value
                            else
                                if EndpointRequest."PK Code 2" = '' then
                                    EndpointRequest."PK Code 2" := FieldRefPKField.Value;
                        end else begin
                            ToFieldRef := ToRecRef.Field(EndpointRequest.FieldNo("PK Line 1"));
                            if FieldRefPKField.Type = ToFieldRef.Type then begin
                                if EndpointRequest."PK Line 1" = 0 then
                                    EndpointRequest."PK Line 1" := FieldRefPKField.Value
                                else
                                    EndpointRequest."PK Line 2" := FieldRefPKField.Value;
                            end else begin
                                ToFieldRef := ToRecRef.Field(EndpointRequest.FieldNo("PK Option 1"));
                                if FieldRefPKField.Type = ToFieldRef.Type then begin
                                    if EndpointRequest."PK Option 1" = 20 then
                                        EndpointRequest."PK Option 1" := FieldRefPKField.Value;
                                end;
                            end;
                        end;
                    end;
                end;
        end;
    end;

    procedure CreateModifyRequests(Endpoint: Record "NPR Endpoint")
    var
        RecRef: RecordRef;
        EndpointFilter: Record "NPR Endpoint Filter";
        FieldRefTemp: FieldRef;
        FieldRefChange: FieldRef;
        RecReftemp: RecordRef;
        SkipRecord: Boolean;
    begin
        RecRef.Open(Endpoint."Table No.");
        RecReftemp.Open(Endpoint."Table No.", true);
        if RecRef.FindFirst then
            repeat
                SkipRecord := false;
                EndpointFilter.Reset;
                EndpointFilter.SetRange("Endpoint Code", Endpoint.Code);
                EndpointFilter.SetRange("Table No.", Endpoint."Table No.");
                if EndpointFilter.FindSet then
                    repeat
                        FieldRefTemp := RecReftemp.Field(EndpointFilter."Field No.");
                        FieldRefChange := RecRef.Field(EndpointFilter."Field No.");
                        FieldRefTemp.Value := FieldRefChange.Value;
                        RecReftemp.Insert;
                        FieldRefTemp.SetFilter(EndpointFilter."Filter Text");
                        if RecReftemp.IsEmpty then
                            SkipRecord := true;
                        RecReftemp.Delete;
                    until (EndpointFilter.Next = 0) or SkipRecord;
                if not SkipRecord then
                    InsertModifyRequest(RecReftemp, Endpoint.Code);
            until RecRef.Next = 0;
    end;

    local procedure InsertModifyRequest(RecRef: RecordRef; EndPointCode: Code[20])
    var
        EndpointRequest: Record "NPR Endpoint Request";
    begin
        with EndpointRequest do begin
            Init;
            "No." := 0;
            "Endpoint Code" := EndPointCode;
            "Request Batch No." := GetEndpointRequestBatchNo(EndPointCode);
            "Type of Change" := "Type of Change"::Modify;
            //"Record ID" := DataLogRecord."Record ID";
            "Record Position" := RecRef.GetPosition(false);
            "Table No." := RecRef.Number;
            "Data log Record No." := 0;
            PopulatePKFields(EndpointRequest, RecRef);
            Insert(true);
        end;

        MarkPreviousRequestsAsObsolete(EndpointRequest);
    end;

    procedure MarkPreviousRequestsAsObsolete(EndpointRequest: Record "NPR Endpoint Request")
    var
        OldEndpointRequests: Record "NPR Endpoint Request";
        EndPoint: Record "NPR Endpoint";
    begin
        EndPoint.Get(EndpointRequest."Endpoint Code");
        with OldEndpointRequests do begin
            Reset;
            SetFilter("Request Batch No.", '=%1', EndpointRequest."Request Batch No.");
            SetFilter("No.", '<%1', EndpointRequest."No.");
            SetFilter("Table No.", '=%1', EndpointRequest."Table No.");
            SetFilter("Type of Change", '=%1', EndpointRequest."Type of Change");
            SetFilter("PK Code 1", '=%1', EndpointRequest."PK Code 1");
            SetFilter("PK Code 2", '=%1', EndpointRequest."PK Code 2");
            SetFilter("PK Line 1", '=%1', EndpointRequest."PK Line 1");
            SetFilter("PK Option 1", '=%1', EndpointRequest."PK Option 1");
            if EndPoint."Delete Obsolete Requests" then begin
                DeleteAll(true);
            end else begin
                if FindSet then
                    repeat
                        Validate(Obsolete, true);
                        Modify(true);
                    until Next = 0;
            end;
        end;
    end;

    procedure SetBatchStatus(EndpointRequestBatch: Record "NPR Endpoint Request Batch"; NewStatus: Option Collecting,"Ready to Send",Sent)
    var
        TxtStatusAllready: Label '%1 %2 is already %3.';
        TxtBatchWillNotbeSent: Label '%1 %2 be marked as sent without being sent.';
        TxtBatchWillBeResentSent: Label '%1 %2 be marked unsent and %3 requests will be resent.';
    begin
        if NewStatus = EndpointRequestBatch.Status then
            exit;
        case EndpointRequestBatch.Status of
            EndpointRequestBatch.Status::Collecting:
                begin
                    case NewStatus of
                        NewStatus::"Ready to Send":
                            begin
                                EndpointRequestBatch.CalcFields("No. of Requests");
                                EndpointRequestBatch.TestField("No. of Requests");
                                EndpointRequestBatch.Validate(Status, NewStatus);
                                EndpointRequestBatch.Modify(true);
                            end;
                        NewStatus::Sent:
                            begin
                                if Confirm(StrSubstNo(TxtBatchWillNotbeSent, EndpointRequestBatch.TableCaption, EndpointRequestBatch."No.")) then begin
                                    EndpointRequestBatch.Validate(Status, NewStatus);
                                    EndpointRequestBatch.Modify(true);
                                end;
                            end;
                    end;
                end;
            EndpointRequestBatch.Status::"Ready to Send":
                begin
                    case NewStatus of
                        NewStatus::Collecting:
                            begin
                                EndpointRequestBatch.Validate(Status, NewStatus);
                                EndpointRequestBatch.Modify(true);
                            end;
                        NewStatus::Sent:
                            begin
                                if Confirm(StrSubstNo(TxtBatchWillNotbeSent, EndpointRequestBatch.TableCaption, EndpointRequestBatch."No.")) then begin
                                    EndpointRequestBatch.Validate(Status, NewStatus);
                                    EndpointRequestBatch."Sent Date" := 0DT;
                                    EndpointRequestBatch.Modify(true);
                                end;
                            end;
                    end;
                end;
            EndpointRequestBatch.Status::Sent:
                begin
                    EndpointRequestBatch.CalcFields("No. of Requests");
                    if EndpointRequestBatch."No. of Requests" = 0 then begin
                        EndpointRequestBatch.Validate(Status, NewStatus);
                        EndpointRequestBatch.Modify(true);
                    end else begin
                        if Confirm(StrSubstNo(TxtBatchWillBeResentSent, EndpointRequestBatch.TableCaption, EndpointRequestBatch."No.", EndpointRequestBatch."No. of Requests")) then begin
                            EndpointRequestBatch.Validate(Status, NewStatus);
                            if NewStatus = NewStatus::Collecting then
                                EndpointRequestBatch."Ready to Send Date" := 0DT;
                            EndpointRequestBatch."Sent Date" := 0DT;
                            EndpointRequestBatch.Modify(true);
                        end;
                    end;
                end;
        end;
    end;

    procedure CreateOutboundEndpointQuery(QueryName: Text[30]; RecordToQuery: Variant; OnlyNewAndModified: Boolean)
    var
        TextOnlyRecords: Label 'You can only create Endpoint Queries for Records.';
        FieldRec: Record "Field";
        RecRef: RecordRef;
        FldRef: FieldRef;
        FilterText: Text[250];
        EndpointQuery: Record "NPR Endpoint Query";
        EndpointQueryFilter: Record "NPR Endpoint Query Filter";
        ActiveSession: Record "Active Session";
    begin
        //-NPR5.25
        if not RecordToQuery.IsRecord then
            Error(TextOnlyRecords);

        EndpointQuery.Init;
        EndpointQuery.Validate(Direction, EndpointQuery.Direction::Outgoing);
        EndpointQuery.Validate(Name, QueryName);
        EndpointQuery.Validate("Only New and Modified Records", OnlyNewAndModified);
        EndpointQuery.Insert(true);

        RecRef.GetTable(RecordToQuery);
        InsertFilterRecords(EndpointQuery, RecRef);
        //+NPR5.25
    end;

    procedure InsertFilterRecords(EndpointQuery: Record "NPR Endpoint Query"; RecRef: RecordRef)
    var
        EndpointQueryFilter: Record "NPR Endpoint Query Filter";
        FieldRec: Record "Field";
        FldRef: FieldRef;
        FilterText: Text;
    begin
        //-NPR5.25
        EndpointQuery.TestField("No.");
        EndpointQueryFilter.Reset;
        EndpointQueryFilter.SetRange("Endpoint Query No.", EndpointQuery."No.");
        EndpointQueryFilter.DeleteAll(true);
        if RecRef.HasFilter then begin
            FieldRec.Reset;
            FieldRec.SetRange(TableNo, RecRef.Number);
            FieldRec.SetRange(Class, FieldRec.Class::Normal);
            if FieldRec.FindSet then
                repeat
                    FldRef := RecRef.Field(FieldRec."No.");
                    FilterText := CopyStr(Format(FldRef.GetFilter, 0, 9), 1, MaxStrLen(EndpointQueryFilter."Filter Text"));
                    if FilterText <> '' then begin
                        EndpointQueryFilter.Init;
                        EndpointQueryFilter.Validate("Endpoint Query No.", EndpointQuery."No.");
                        EndpointQueryFilter.Validate("Table No.", RecRef.Number);
                        EndpointQueryFilter.Validate("Field No.", FldRef.Number);
                        EndpointQueryFilter.Validate("Filter Text", FilterText);
                        EndpointQueryFilter.Insert(true);
                    end;
                until FieldRec.Next = 0;
        end;
        //+NPR5.25
    end;
}

