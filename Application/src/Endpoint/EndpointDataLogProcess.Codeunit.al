﻿codeunit 6014674 "NPR Endpoint Data Log Process."
{
    Access = Internal;
    // NPR5.23\BR\20160518  CASE 237658 Object created, to be set up in table Data Log Subscriber

    TableNo = "NPR Data Log Record";

    trigger OnRun()
    begin
        CheckEndpoints(Rec);
    end;

    local procedure CheckEndpoints(Datalogrecord: Record "NPR Data Log Record")
    var
        Endpoint: Record "NPR Endpoint";
    begin
        Endpoint.Reset();
        Endpoint.SetRange("Table No.", Datalogrecord."Table ID");
        Endpoint.SetRange(Active, true);
        if Endpoint.FindSet() then
            repeat
                if ((Datalogrecord."Type of Change" = Datalogrecord."Type of Change"::Insert) and Endpoint."Trigger on Insert") or
                   ((Datalogrecord."Type of Change" = Datalogrecord."Type of Change"::Delete) and Endpoint."Trigger on Delete") or
                   ((Datalogrecord."Type of Change" = Datalogrecord."Type of Change"::Rename) and Endpoint."Trigger on Rename") or
                   ((Datalogrecord."Type of Change" = Datalogrecord."Type of Change"::Modify) and Endpoint."Trigger on Modify") then
                    ProcessChange(Datalogrecord, Endpoint.Code);
            until Endpoint.Next() = 0;
    end;

    local procedure ProcessChange(DataLogRecord: Record "NPR Data Log Record"; EndpointCode: Code[20])
    var
        EndpointRequest: Record "NPR Endpoint Request";
        EndpointManagement: Codeunit "NPR Endpoint Management";
        RecRef: RecordRef;
    begin
        if DataLogRecord."Type of Change" <> DataLogRecord."Type of Change"::Delete then
            if not CheckFilter(DataLogRecord, EndpointCode) then
                exit;

        EndpointRequest.Init();
        EndpointRequest."No." := 0;
        EndpointRequest."Endpoint Code" := EndpointCode;
        EndpointRequest."Request Batch No." := EndpointManagement.GetEndpointRequestBatchNo(EndpointCode);
        EndpointRequest."Type of Change" := DataLogRecord."Type of Change";
        //"Record ID" := DataLogRecord."Record ID";
        RecRef.Get(DataLogRecord."Record ID");
        EndpointRequest."Record Position" := CopyStr(RecRef.GetPosition(false), 1, MaxStrLen(EndpointRequest."Record Position"));
        EndpointRequest."Table No." := DataLogRecord."Table ID";
        EndpointRequest."Data log Record No." := DataLogRecord."Entry No.";
        EndpointManagement.PopulatePKFields(EndpointRequest, RecRef);
        EndpointRequest.Insert(true);

        if EndpointRequest."Type of Change" in [EndpointRequest."Type of Change"::Modify, EndpointRequest."Type of Change"::Delete] then
            EndpointManagement.MarkPreviousRequestsAsObsolete(EndpointRequest);
    end;

    local procedure CheckFilter(DataLogRecord: Record "NPR Data Log Record"; EndpointCode: Code[20]): Boolean
    var
        EndpointFilter: Record "NPR Endpoint Filter";
        RecRefchange: RecordRef;
        RecReftemp: RecordRef;
        FieldRefTemp: FieldRef;
        FieldRefChange: FieldRef;
    begin
        if not RecRefchange.Get(DataLogRecord."Record ID") then
            exit(false);
        RecReftemp.Open(RecRefchange.Number, true);
        EndpointFilter.Reset();
        EndpointFilter.SetRange("Endpoint Code", EndpointCode);
        EndpointFilter.SetRange("Table No.", DataLogRecord."Table ID");
        if EndpointFilter.FindSet() then
            repeat
                FieldRefTemp := RecReftemp.Field(EndpointFilter."Field No.");
                FieldRefChange := RecRefchange.Field(EndpointFilter."Field No.");
                FieldRefTemp.Value := FieldRefChange.Value;
                RecReftemp.Insert();
                FieldRefTemp.SetFilter(EndpointFilter."Filter Text");
                if RecReftemp.IsEmpty then
                    exit(false);
                RecReftemp.Delete();
            until EndpointFilter.Next() = 0;

        exit(true);
    end;
}

