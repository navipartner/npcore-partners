codeunit 6151491 "NPR Raptor Management"
{
    trigger OnRun()
    begin
    end;

    var
        RaptorSetup: Record "NPR Raptor Setup";
        ActionDescrLbl_GetUserIDHistory: Label 'Browsing History Entries';
        ActionCommentLbl_GetUserIDHistory: Label 'Compiles a chronological list of viewed products for a user in realtime while the user is browsing the website.';
        ActionDescrLbl_GetUserRecomm: Label 'Recommendations';
        ActionCommentLbl_GetUserRecomm: Label 'Generates personalized recommendations based on a user''s current behavior on the website.';
        ActionNotSupported: Label 'An unknown or unsupported %1 ''%2'' has been invoked. You must register the corresponding action handler before you can call it. This indicates a programming bug, not a user error. Please contact system vendor if you need assistance.';
        ConfirmOverwrite: Label '%1 ''%2'' already exists in the database. Are you sure you want to overwrite it with default values?';
        DailyUpdateQst: Label 'A job queue entry for exporting of Raptor tracking data has been created.\\Do you want to open the Job Queue Entry Setup window?';
        NothingToShowErr: Label 'There are no Raptor %1 available for the customer %2.';
        SendDataToRaptrorLbl: Label 'Export of tracking data to Raptor.';
        TrackServDescr_rsa: Label 'Raptor service for tracking in a no-javascript environment';
        UnknownValue: Label 'The %1 = %2 is not defined in the system.';
        IncorrectFunctionCallErr: Label 'Function call on a non-temporary variable. This is a critical programming error. Please contact system vendor.';

    procedure SendRaptorGetDataRequst(RaptorAction: Record "NPR Raptor Action"; UserIdentifier: Text; var ErrorMsg: Text): Text
    var
        RaptorAPI: Codeunit "NPR Raptor API";
        Baseurl: Text;
        Path: Text;
        PathLbl: Label '/v1/%1/%2/%3/%4?%5=%6&json=True', Locked = true;
    begin
        if UserIdentifier = '' then
            exit;

        if not IsEnabled(0) then
            exit;

        RaptorAction.TestField("Raptor Module Code");
        if RaptorAction."Number of Entries to Return" <= 0 then
            RaptorAction."Number of Entries to Return" := 10;
        if RaptorAction."User Identifier Param. Name" = '' then
            RaptorAction."User Identifier Param. Name" := 'UserIdentifier';

        Baseurl := RaptorSetup."Base Url";
        Path :=
            StrSubstNo(PathLbl,
                RaptorSetup."Customer ID",
                RaptorAction.RaptorActionAPIReqString(),
                RaptorAction."Number of Entries to Return",
                RaptorSetup."API Key",
                RaptorAction."User Identifier Param. Name",
                UserIdentifier);

        exit(RaptorAPI.SendRaptorRequest(Baseurl, Path, ErrorMsg));
    end;

    procedure SendRaptorTrackingRequest(var Parameters: Record "Name/Value Buffer")
    var
        RaptorAPI: Codeunit "NPR Raptor API";
        ErrorMsg: Text;
        Result: Text;
        ResultLbl: Label '/%1.%2', Locked = true;
    begin
        if not IsEnabled(1) then
            exit;

        Result :=
            RaptorAPI.SendRaptorRequest(
                RaptorSetup."Tracking Service Url",
                StrSubstNo(ResultLbl, RaptorSetup."Customer ID", RaptorSetup."Tracking Service Type") + GenerateUrlQueryString(Parameters),
                ErrorMsg);

        if ErrorMsg <> '' then
            Error(ErrorMsg);
    end;

    procedure GetRaptorData(RaptorAction: Record "NPR Raptor Action"; UserIdentifier: Text; var RaptorDataBuffer: Record "NPR Raptor Data Buffer")
    var
        JArray: JsonArray;
        JObject: JsonObject;
        JToken: JsonToken;
        ErrorMsg: Text;
        Result: Text;
        Handled: Boolean;
        InvalidRespErr: Label 'Invalid response, expected a JSON array as root object.\Actual response: %1';
    begin
        RaptorDataBuffer.Reset();
        RaptorDataBuffer.DeleteAll();

        Result := SendRaptorGetDataRequst(RaptorAction, UserIdentifier, ErrorMsg);
        if ErrorMsg <> '' then
            Error(ErrorMsg);
        if not JArray.ReadFrom(Result) then
            Error(InvalidRespErr, Result);
        foreach JToken in JArray do begin
            OnProcessRaptorDataLine(RaptorAction, UserIdentifier, JToken.AsValue().AsText(), RaptorDataBuffer, Handled);

            if not Handled then begin
                JObject := JToken.AsObject();
                case RaptorAction."Raptor Module Code" of
                    RaptorModule_GetUserIdHistory():
                        begin
                            RaptorDataBuffer.Init();
                            RaptorDataBuffer."Entry No." += 1;
                            RaptorDataBuffer."Date-Time Created" := GetJsonToken(JObject, 'CreateDate').AsValue().AsDateTime();
                            RaptorDataBuffer.Priority := GetJsonToken(JObject, 'Priority').AsValue().AsInteger();
                            ParseItemNo(GetJsonToken(JObject, 'RecommendedId').AsValue().AsText(), RaptorDataBuffer);
                            RaptorDataBuffer.Insert();
                        end;

                    RaptorModule_GetUserRecommendations():
                        begin
                            RaptorDataBuffer.Init();
                            RaptorDataBuffer."Entry No." += 1;
                            RaptorDataBuffer.Priority := GetJsonToken(JObject, 'Priority').AsValue().AsInteger();
                            ParseItemNo(GetJsonToken(JObject, 'RecommendedId').AsValue().AsText(), RaptorDataBuffer);
                            RaptorDataBuffer.Insert();
                        end;

                    else
                        Error(ActionNotSupported, RaptorAction.TableCaption, RaptorAction.Code);
                end;
            end;
        end;
    end;

    procedure ShowRaptorData(RaptorAction: Record "NPR Raptor Action"; UserIdentifier: Text)
    var
        RaptorDataBuffer: Record "NPR Raptor Data Buffer" temporary;
        RaptorDataBufferEntries: Page "NPR Raptor Data Buffer Entries";
        Handled: Boolean;
    begin
        GetRaptorData(RaptorAction, UserIdentifier, RaptorDataBuffer);
        if RaptorDataBuffer.IsEmpty then
            Error(NothingToShowErr, RaptorAction."Data Type Description", UserIdentifier);

        OnBeforeShowRaptorBuffer(RaptorAction, RaptorDataBuffer, Handled);
        if not Handled then
            case RaptorAction."Raptor Module Code" of
                RaptorModule_GetUserIdHistory():
                    begin
                        RaptorDataBuffer.SetCurrentKey(Priority, "Date-Time Created");
                        RaptorDataBuffer.FindFirst();
                    end;
                RaptorModule_GetUserRecommendations():
                    begin
                        RaptorDataBuffer.SetCurrentKey(Priority);
                        RaptorDataBuffer.FindFirst();
                    end;
            end;

        Clear(RaptorDataBufferEntries);
        RaptorDataBufferEntries.SetTableView(RaptorDataBuffer);
        RaptorDataBufferEntries.SetRaptorAction(RaptorAction);
        RaptorDataBufferEntries.SetRecordSet(RaptorDataBuffer);
        RaptorDataBufferEntries.Run();
    end;

    procedure SelectRaptorAction(RaptorModuleCode: Text[50]; UseFirst: Boolean; var RaptorAction: Record "NPR Raptor Action"): Boolean
    var
        RaptorAction2: Record "NPR Raptor Action";
    begin
        RaptorAction.Reset();
        if RaptorModuleCode <> '' then
            RaptorAction2.SetRange("Raptor Module Code", RaptorModuleCode);
        if UseFirst then begin
            RaptorAction2.FindFirst();
            RaptorAction := RaptorAction2;
            exit(true);
        end else
            if PAGE.RunModal(0, RaptorAction2) = ACTION::LookupOK then begin
                RaptorAction := RaptorAction2;
                exit(true);
            end;
        exit(false);
    end;

    procedure ParseItemNo(RaptorItemNo: Text; var RaptorDataBuffer: Record "NPR Raptor Data Buffer")
    var
        Item: Record Item;
        Position: Integer;
    begin
        Position := StrPos(RaptorItemNo, '_');
        if Position > 0 then begin
            RaptorDataBuffer."Item No." := CopyStr(CopyStr(RaptorItemNo, 1, Position - 1), 1, MaxStrLen(RaptorDataBuffer."Item No."));
            RaptorDataBuffer."Variant Code" := CopyStr(RaptorItemNo, Position + 1, MaxStrLen(RaptorDataBuffer."Variant Code"));
        end else begin
            RaptorDataBuffer."Item No." := CopyStr(RaptorItemNo, 1, MaxStrLen(RaptorDataBuffer."Item No."));
            RaptorDataBuffer."Variant Code" := '';
        end;
        if not Item.Get(RaptorDataBuffer."Item No.") then
            Item.Init();
        RaptorDataBuffer."Item Description" := Item.Description;
    end;

    local procedure GenerateUrlQueryString(var Parameters: Record "Name/Value Buffer") QueryString: Text
    var
        TypeHelper: Codeunit "Type Helper";
        QueryStringLbl: Label '%1=%2', Locked = true;
    begin
        Parameters.SetFilter(Name, '<>%1', '_*');
        Parameters.SetFilter(Value, '<>%1', '');
        if Parameters.FindSet() then
            repeat
                if QueryString <> '' then
                    QueryString := QueryString + '&'
                else
                    QueryString := '?';
                QueryString := QueryString +
                    StrSubstNo(QueryStringLbl, TypeHelper.UrlEncode(Parameters.Name), TypeHelper.UrlEncode(Parameters.Value));
            until Parameters.Next() = 0;
    end;

    local procedure IsEnabled(DataFlowType: Option GetData,SendData): Boolean
    begin
        if not (RaptorSetup.Get() and RaptorSetup."Enable Raptor Functions") then
            exit(false);

        case DataFlowType of
            DataFlowType::GetData:
                begin
                    RaptorSetup.TestField("API Key");
                    RaptorSetup.TestField("Base Url");
                end;
            DataFlowType::SendData:
                begin
                    if not RaptorSetup."Send Data to Raptor" then
                        exit(false);
                    RaptorSetup.TestField("Tracking Service Url");
                    RaptorSetup.TestField("Tracking Service Type");
                end;
        end;
        RaptorSetup.TestField("Customer ID");

        exit(true);
    end;

    procedure InitializeDefaultActions(Force: Boolean; Silent: Boolean)
    var
        RaptorAction: Record "NPR Raptor Action";
    begin
        if not (Force or RaptorAction.IsEmpty) then
            exit;

        RaptorAction.Init();
        RaptorAction.Code := 'USER_BROWS_HIST';
        RaptorAction."Raptor Module Code" := RaptorModule_GetUserIdHistory();
        RaptorAction."Data Type Description" := ActionDescrLbl_GetUserIDHistory;
        RaptorAction.Comment := ActionCommentLbl_GetUserIDHistory;
        RaptorAction."Number of Entries to Return" := 10;
        RaptorAction."Show Date-Time Created" := true;
        RaptorAction."Show Priority" := true;
        AddAction(RaptorAction, Silent);

        RaptorAction.Init();
        RaptorAction.Code := 'USER_RECOMM';
        RaptorAction."Raptor Module Code" := RaptorModule_GetUserRecommendations();
        RaptorAction."Data Type Description" := ActionDescrLbl_GetUserRecomm;
        RaptorAction.Comment := ActionCommentLbl_GetUserRecomm;
        RaptorAction."Number of Entries to Return" := 10;
        RaptorAction."Show Priority" := true;
        AddAction(RaptorAction, Silent);

        OnInitializeDefaultActions(Silent);
    end;

    procedure AddAction(RaptorAction: Record "NPR Raptor Action"; Silent: Boolean)
    var
        RaptorAction2: Record "NPR Raptor Action";
    begin
        RaptorAction2 := RaptorAction;
        if RaptorAction2.Find() then begin
            if not Silent then
                if not Confirm(ConfirmOverwrite, false, RaptorAction2.TableCaption, RaptorAction2.Code) then
                    exit;
            RaptorAction2.Delete();
            RaptorAction2 := RaptorAction;
        end;
        RaptorAction2.Insert();
        Commit();
    end;

    procedure SetupJobQueue(Enabled: Boolean)
    var
        JobQueueEntry: Record "Job Queue Entry";
        DummyRecId: RecordID;
    begin
        if Enabled then begin
            AddDataLogSubscribers();

            JobQueueEntry.ScheduleRecurrentJobQueueEntry(
                JobQueueEntry."Object Type to Run"::Codeunit, CODEUNIT::"NPR Raptor Send Data", DummyRecId);
            JobQueueEntry.Description := CopyStr(SendDataToRaptrorLbl, 1, MaxStrLen(JobQueueEntry.Description));
            JobQueueEntry."Starting Time" := 070000T;
            JobQueueEntry."Ending Time" := 230000T;
            JobQueueEntry."No. of Minutes between Runs" := 10;
            JobQueueEntry.Modify();
            Commit();

            if Confirm(DailyUpdateQst) then
                PAGE.Run(PAGE::"Job Queue Entry Card", JobQueueEntry);
        end else
            if JobQueueEntry.FindJobQueueEntry(JobQueueEntry."Object Type to Run"::Codeunit, CODEUNIT::"NPR Raptor Send Data") then
                JobQueueEntry.Cancel();
    end;

    procedure ShowJobQueueEntry()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", CODEUNIT::"NPR Raptor Send Data");
        if JobQueueEntry.FindFirst() then
            PAGE.Run(PAGE::"Job Queue Entry Card", JobQueueEntry);
    end;

    procedure AddDataLogSubscribers()
    var
        DataLogSetup: Record "NPR Data Log Setup (Table)";
        DataLogSubscriber: Record "NPR Data Log Subscriber";
        Updated: Boolean;
    begin
        DataLogSetup.InsertNewTable(DATABASE::"Item Ledger Entry", 1, 0, 0);
        DataLogSetup.Get(DATABASE::"Item Ledger Entry");
        if DataLogSetup."Log Insertion" = DataLogSetup."Log Insertion"::" " then begin
            DataLogSetup."Log Insertion" := DataLogSetup."Log Insertion"::Simple;
            Updated := true;
        end;
        if DataLogSetup."Keep Log for" < DaysToDuration(2) then begin
            DataLogSetup."Keep Log for" := DaysToDuration(2);
            Updated := true;
        end;
        if Updated then
            DataLogSetup.Modify(true);

        DataLogSubscriber.AddAsSubscriber(RaptorDataLogSubscriber(), DATABASE::"Item Ledger Entry");
    end;

    local procedure DaysToDuration(NoOfDays: Integer): BigInteger
    begin
        exit(NoOfDays * 86400000);
    end;

    procedure SelectTrackingServiceType(var TrackingServiceType: Text): Boolean
    var
        ListOfTrackingServiceTypes: Record "Name/Value Buffer" temporary;
    begin
        GetListOfTrackingServiceTypes(ListOfTrackingServiceTypes);
        if TrackingServiceType <> '' then begin
            ListOfTrackingServiceTypes.SetRange(Value, TrackingServiceType);
            if ListOfTrackingServiceTypes.Find('=><') then;
            ListOfTrackingServiceTypes.SetRange(Value);
        end;
        if PAGE.RunModal(PAGE::"Name/Value Lookup", ListOfTrackingServiceTypes) = ACTION::LookupOK then begin
            TrackingServiceType := CopyStr(ListOfTrackingServiceTypes.Value, 1, MaxStrLen(RaptorSetup."Tracking Service Type"));
            exit(true);
        end else
            exit(false);
    end;

    procedure ValidateTrackingServiceType(TrackingServiceType: Text)
    var
        ListOfTrackingServiceTypes: Record "Name/Value Buffer" temporary;
    begin
        if TrackingServiceType = '' then
            exit;
        GetListOfTrackingServiceTypes(ListOfTrackingServiceTypes);
        ListOfTrackingServiceTypes.SetRange(Value, TrackingServiceType);
        if ListOfTrackingServiceTypes.IsEmpty then
            Error(UnknownValue, RaptorSetup.FieldCaption("Tracking Service Type"), TrackingServiceType);
    end;

    procedure GetDefaultTrackingServiceType(var TrackingServiceType: Text): Text
    var
        Handled: Boolean;
    begin
        OnGetDefaultTrackingServiceType(TrackingServiceType, Handled);
        if not Handled then
            TrackingServiceType := RaptorTrackService_rsa();
    end;

    local procedure GetListOfTrackingServiceTypes(var ListOfTrackingServiceTypes: Record "Name/Value Buffer")
    begin
        if not ListOfTrackingServiceTypes.IsTemporary then
            Error(IncorrectFunctionCallErr);

        ListOfTrackingServiceTypes.Reset();
        ListOfTrackingServiceTypes.DeleteAll();

        ListOfTrackingServiceTypes.Init();
        ListOfTrackingServiceTypes.ID += 1;
        ListOfTrackingServiceTypes.Name := CopyStr(TrackServDescr_rsa, 1, MaxStrLen(ListOfTrackingServiceTypes.Name));
        ListOfTrackingServiceTypes.Value := RaptorTrackService_rsa();
        ListOfTrackingServiceTypes.Insert();

        OnGetListOfTrackingServiceTypes(ListOfTrackingServiceTypes);
    end;

    procedure RaptorModule_GetUserIdHistory(): Text
    begin
        exit('GetUserIdHistory');
    end;

    procedure RaptorModule_GetUserRecommendations(): Text
    begin
        exit('GetUserRecommendations');
    end;

    local procedure RaptorTrackService_rsa(): Text[30]
    begin
        exit('rsa');
    end;

    procedure RaptorDataLogSubscriber(): Code[30]
    begin
        exit('RAPTOR');
    end;

    procedure SelectWebShopSalespersons(var SalespersonFilter: Text)
    var
        SalespersonTmp: Record "Salesperson/Purchaser" temporary;
        RaptorSendData: Codeunit "NPR Raptor Send Data";
        SalespersonList: Page "NPR Salesperson List";
        InQuotes: Label '''%1''';
    begin
        RaptorSendData.CreateTmpSalespersonList(SalespersonTmp);

        if SalespersonFilter <> '' then begin
            SalespersonTmp.SetFilter(Code, SalespersonFilter);
            if SalespersonTmp.FindSet() then
                repeat
                    SalespersonTmp.Mark := true;
                until SalespersonTmp.Next() = 0;
            SalespersonTmp.SetRange(Code);
        end;

        Clear(SalespersonList);
        SalespersonList.SetDataset(SalespersonTmp);
        SalespersonList.SetMultiSelectionMode(true);
        SalespersonList.LookupMode(true);
        if SalespersonList.RunModal() <> ACTION::LookupOK then
            exit;
        SalespersonList.GetDataset(SalespersonTmp);
        SalespersonTmp.MarkedOnly(true);

        SalespersonFilter := '';
        if SalespersonTmp.FindSet() then
            repeat
                if SalespersonFilter <> '' then
                    SalespersonFilter := SalespersonFilter + '|';
                SalespersonFilter := SalespersonFilter + StrSubstNo(InQuotes, SalespersonTmp.Code);
            until SalespersonTmp.Next() = 0;
    end;

    procedure GetJsonToken(JObject: JsonObject; TokenKey: Text) JToken: JsonToken
    var
        TokenNotFoundErr: Label 'Could not find a JSON token with key %1';
    begin
        if not JObject.Get(TokenKey, JToken) then
            Error(TokenNotFoundErr, TokenKey);
    end;

    [IntegrationEvent(TRUE, false)]
    procedure OnProcessRaptorDataLine(RaptorAction: Record "NPR Raptor Action"; UserIdentifier: Text; JObjectAsText: Text; var RaptorDataBuffer: Record "NPR Raptor Data Buffer"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    procedure OnBeforeShowRaptorBuffer(RaptorAction: Record "NPR Raptor Action"; var RaptorDataBuffer: Record "NPR Raptor Data Buffer"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    procedure OnInitializeDefaultActions(Silent: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnGetListOfTrackingServiceTypes(var ListOfTrackingServiceTypes: Record "Name/Value Buffer")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnGetDefaultTrackingServiceType(var TrackingServiceType: Text; var Handled: Boolean)
    begin
    end;
}