codeunit 6014648 "NPR BTF Nc Import Type" implements "NPR Nc Import List IUpdate"
{
    Permissions = TableData "Job Queue Entry" = rm;

    var
        ImportTypeDescriptionLbl: Label 'BTwentyFour integration. Run all enabled services';
        ServiceSetupNotFoundLbl: Label '%1 not found for %2: %3 or it''s not enabled. Check out by running an action "Show Setup Page"', Comment = '%1=ServiceSetup.TableCaption();%2=ImportType.TableCaption();%3=ImportType.Code';
        ServiceEndPointsNotFoundLbl: Label '%1 not found for %2: %3 or endpoints exist but they are not enabled. Try to navigate to service endpoints through the setup by running an action "Show Setup Page"', Comment = '%1=ServiceEndPoint.TableCaption();%2=ServiceSetup.TableCaption();%3=ServiceSetup.Code';
        APIIntegrationLbl: Label 'BTwentyFour API Integration';
        ImportTypeParameterLbl: Label 'import_type', locked = true;
        ProcessImportListLbl: Label 'process_import_list', Locked = true;

    procedure Update(TaskLine: Record "NPR Task Line"; ImportType: Record "NPR Nc Import Type")
    begin
        SendWebRequests(ImportType, TaskLine.RecordID(), '');
    end;

    procedure Update(JobQueueEntry: Record "Job Queue Entry"; ImportType: Record "NPR Nc Import Type")
    var
        DummyServiceEndPoint: Record "NPR BTF Service EndPoint";
        ImportListProcessing: Codeunit "NPR Nc Import List Processing";
        EndPointIDFilter: Text;
    begin
        if not ImportListProcessing.HasParameter(JobQueueEntry, ImportTypeParameterLbl) then
            exit;
        if ImportType.Code <> ImportListProcessing.GetParameterValue(JobQueueEntry, ImportTypeParameterLbl) then
            exit;
        if ImportListProcessing.HasParameter(JobQueueEntry, DummyServiceEndPoint.TableName()) then
            EndPointIDFilter := ImportListProcessing.GetParameterValue(JobQueueEntry, DummyServiceEndPoint.TableName());

        SendWebRequests(ImportType, JobQueueEntry.RecordId(), EndPointIDFilter);
    end;

    procedure ShowSetup(ImportType: Record "NPR Nc Import Type")
    var
        ServiceSetup: Record "NPR BTF Service Setup";
    begin
        ServiceSetup.Setrange(Code, ImportType.Code);
        Page.Run(0, ServiceSetup);
    end;

    procedure ShowErrorLog(ImportType: Record "NPR Nc Import Type")
    var
        ServiceAPI: Codeunit "NPR BTF Service API";
    begin
        ServiceAPI.ShowErrorLogEntries(ImportType.Code);
    end;

    local procedure SendWebRequests(ImportType: Record "NPR Nc Import Type"; InitiateFromRecID: RecordId; EndPointIDFilter: Text)
    var
        ServiceSetup: Record "NPR BTF Service Setup";
        ImportEntry: Record "NPR Nc Import Entry";
        ServiceEndPoint: Record "NPR BTF Service EndPoint";
        Response: Codeunit "Temp Blob";
        ServiceAPI: Codeunit "NPR BTF Service API";
        FormatResponse: Interface "NPR BTF IFormatResponse";
    begin
        ServiceSetup.Code := ImportType.Code;
        if (not ServiceSetup.Find()) or (not ServiceSetup.Enabled) then begin
            LogEndPointError(ServiceSetup, ServiceEndPoint, Response, '', StrSubstNo(ServiceSetupNotFoundLbl, ServiceSetup.TableCaption(), ImportType.TableCaption(), ImportType.Code), InitiateFromRecID);
            exit;
        end;

        ServiceEndPoint.Setcurrentkey("Service Code", "Sequence Order", Enabled);
        ServiceEndPoint.SetRange("Service Code", ServiceSetup.Code);
        ServiceEndPoint.SetRange(Enabled, true);
        if EndPointIDFilter <> '' then
            ServiceEndPoint.SetFilter("EndPoint ID", EndPointIDFilter);
        if ServiceEndPoint.IsEmpty() then begin
            LogEndPointError(ServiceSetup, ServiceEndPoint, Response, '', StrSubstNo(ServiceEndPointsNotFoundLbl, ServiceEndPoint.TableCaption(), ServiceSetup.TableCaption(), ServiceSetup.Code), InitiateFromRecID);
            exit;
        end;
        ServiceEndPoint.FindSet();
        repeat
            if ServiceEndPoint."EndPoint ID" <> ServiceSetup."Authroization EndPoint ID" then begin
                ServiceAPI.SendWebRequest(ServiceSetup, ServiceEndPoint, Response);
                FormatResponse := ServiceEndPoint.Accept;

                if FormatResponse.FoundErrorInResponse(Response) then begin
                    LogEndPointError(ServiceSetup, ServiceEndPoint, Response, '', FormatResponse.GetErrorDescription(Response), InitiateFromRecID);
                end else begin
                    InsertImportEntry(ImportEntry, ImportType.Code, Response, ServiceEndPoint);
                end;
            end;
        until ServiceEndPoint.Next() = 0;
    end;

    local procedure LogEndPointError(ServiceSetup: Record "NPR BTF Service Setup"; ServiceEndPoint: Record "NPR BTF Service EndPoint"; Response: Codeunit "Temp Blob"; CurrUserId: Code[50]; ErrorNote: Text; InitiateFromRecID: RecordId)
    var
        ServiceAPI: Codeunit "NPR BTF Service API";
    begin
        ServiceAPI.LogEndPointError(ServiceSetup, ServiceEndPoint, Response, CurrUserId, ErrorNote, InitiateFromRecID);
    end;

    local procedure InsertImportEntry(var ImportEntry: Record "NPR Nc Import Entry"; ImportTypeCode: Code[20]; Response: Codeunit "Temp Blob"; ServiceEndPoint: Record "NPR BTF Service EndPoint")
    var
        EndPoint: Interface "NPR BTF IEndPoint";
        FormatResponse: Interface "NPR BTF IFormatResponse";
        DataTypeManagement: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        clear(ImportEntry);
        ImportEntry."Entry No." := 0;
        ImportEntry."Import Type" := ImportTypeCode;
        if Response.HasValue() then begin
            EndPoint := ServiceEndPoint."EndPoint Method";
            FormatResponse := ServiceEndPoint.Accept;
            ImportEntry."Document Name" := EndPoint.GetDefaultFileName(ServiceEndPoint) + '.' + FormatResponse.GetFileExtension();
            ImportEntry."Document ID" := Format(ServiceEndPoint.RecordId());
            DataTypeManagement.GetRecordRef(ImportEntry, RecRef);
            Response.ToRecordRef(RecRef, ImportEntry.FieldNo("Document Source"));
            RecRef.SetTable(ImportEntry);
        end;
        ImportEntry.Insert(true);
    end;

    local procedure RegisterNcImportType(ImportTypeCode: Code[20])
    var
        ImportType: Record "NPR Nc Import Type";
    begin
        if ImportTypeCode = '' then
            exit;
        ImportType.Code := ImportTypeCode;
        if ImportType.Find() then
            exit;
        ImportType.Init();
        ImportType.Description := Copystr(ImportTypeDescriptionLbl, 1, MaxStrLen(ImportType.Description));
        ImportType."Import List Update Handler" := ImportType."Import List Update Handler"::B24API;
        ImportType."Import Codeunit ID" := Codeunit::"NPR BTF Nc Import Entry";
        ImportType.Insert(true);
    end;

    local procedure ScheduleJobQueueEntry(ServiceSetupCode: Code[20])
    var
        JobQueueEntry: Record "Job Queue Entry";
        ServiceEndPoint: Record "NPR BTF Service EndPoint";
        ServiceSetup: Record "NPR BTF Service Setup";
        ServiceAPI: Codeunit "NPR BTF Service API";
        DummyRecId: RecordID;
    begin
        if JobQueueEntry.FindJobQueueEntry(JobQueueEntry."Object Type to Run"::Codeunit, CODEUNIT::"NPR Nc Import List Processing") then
            exit;

        JobQueueEntry.ScheduleRecurrentJobQueueEntry(
            JobQueueEntry."Object Type to Run"::Codeunit, CODEUNIT::"NPR Nc Import List Processing", DummyRecId);
        JobQueueEntry.Description := CopyStr(APIIntegrationLbl, 1, MaxStrLen(JobQueueEntry.Description));
        JobQueueEntry."Starting Time" := 070000T;
        JobQueueEntry."Ending Time" := 230000T;
        JobQueueEntry."No. of Minutes between Runs" := 10;

        ServiceSetup.get(ServiceSetupCode);
        ServiceEndPoint.SetRange("Service Code", ServiceSetupCode);
        ServiceEndPoint.setfilter("Endpoint ID", '<>%1', ServiceSetup."Authroization EndPoint ID");
        ServiceEndPoint.SetRange(Enabled, true);

        JobQueueEntry."Parameter String" :=
                            StrSubstNo('%1=%2,%3=%4,%5',
                                        ImportTypeParameterLbl, ServiceSetup.Code,
                                        ServiceEndPoint.TableName(), ServiceAPI.GetSelectionFilterForServiceEndPoints(ServiceEndPoint),
                                        ProcessImportListLbl);

        JobQueueEntry.Modify();
    end;

    local procedure DeleteNcImportType(ImportTypeCode: Code[20])
    var
        ImportType: Record "NPR Nc Import Type";
    begin
        ImportType.SetRange(Code, ImportTypeCode);
        if not ImportType.IsEmpty() then
            ImportType.DeleteAll();
    end;

    local procedure ShowJobQueueEntries()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.Setrange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", CODEUNIT::"NPR Nc Import List Processing");
        Page.Run(0, JobQueueEntry);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR BTF Register Service", 'OnAfterRegisterService', '', true, true)]
    local procedure OnRegisterService(sender: Record "NPR BTF Service Setup")
    begin
        RegisterNcImportType(sender.Code);
        ScheduleJobQueueEntry(sender.Code);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR BTF Service Setup", 'OnAfterDeleteEvent', '', true, true)]
    local procedure OnDeleteServiceSetup(var Rec: Record "NPR BTF Service Setup")
    begin
        DeleteNcImportType(Rec.Code);
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR BTF Service Setup", 'OnAfterActionEvent', 'JobQueueEntries', true, true)]
    local procedure OnSetupActionShowJobQueueEntries()
    begin
        ShowJobQueueEntries();
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR BTF Service Setup Card", 'OnAfterActionEvent', 'JobQueueEntries', true, true)]
    local procedure OnSetupCardActionShowJobQueueEntries()
    begin
        ShowJobQueueEntries();
    end;
}