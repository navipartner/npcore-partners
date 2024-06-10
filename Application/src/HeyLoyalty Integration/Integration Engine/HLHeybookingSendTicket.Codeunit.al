codeunit 6151489 "NPR HL Heybooking Send Ticket"
{
    Access = Internal;
    TableNo = "NPR Nc Task";

    trigger OnRun()
    begin
        Error(NotReprocessibleErr);
    end;

    var
        TempTouchedTicketNotifEntry: Record "NPR TM Ticket Notif. Entry" temporary;
        NotReprocessibleErr: Label 'The task %1 cannot be (re)processed manually. It is generated and processed automatically by the ticket notification handler.', Comment = '%1 - Task ID (Entry No.)';

    procedure Touch(TicketNotificationEntryIn: Record "NPR TM Ticket Notif. Entry")
    begin
        TempTouchedTicketNotifEntry := TicketNotificationEntryIn;
        TempTouchedTicketNotifEntry."Notification Send Status" := TempTouchedTicketNotifEntry."Notification Send Status"::PENDING;
        TempTouchedTicketNotifEntry.Insert();
    end;

    procedure SendTouched()
    var
        NcTask: Record "NPR Nc Task";
        TicketNotifEntry: Record "NPR TM Ticket Notif. Entry";
        HLScheduleSend: Codeunit "NPR HL Schedule Send Tasks";
        LastErrorText: Text;
        Success: Boolean;
    begin
        if TempTouchedTicketNotifEntry.IsEmpty() then
            exit;

        NcTask.Init();
        NcTask."Entry No." := 0;
        NcTask."Table No." := Database::"NPR TM Ticket Notif. Entry";
        NcTask."Company Name" := CopyStr(CompanyName(), 1, MaxStrLen(NcTask."Company Name"));
        NcTask."Log Date" := CurrentDateTime();
        NcTask."Task Processor Code" := HLScheduleSend.GetHeyLoyaltyTaskProcessorCode(true);
        NcTask."Last Processing Started at" := CurrentDateTime();

        ClearLastError();
        Success := TrySendTouched(NcTask);
        if not Success then
            LastErrorText := GetLastErrorText();

        NcTask.Insert();
        Codeunit.Run(Codeunit::"NPR Nc Task Mgt.", NcTask);
        if not NcTask.Processed then begin
            NcTask.Processed := true;  //the task is not reprocessible, even after an error
            NcTask.Modify();
        end;

        TempTouchedTicketNotifEntry.FindSet();
        repeat
            if TicketNotifEntry.Get(TempTouchedTicketNotifEntry."Entry No.") then begin
                if TempTouchedTicketNotifEntry."Notification Send Status" = TempTouchedTicketNotifEntry."Notification Send Status"::FAILED then begin
                    TicketNotifEntry."Notification Send Status" := TempTouchedTicketNotifEntry."Notification Send Status";
                    TicketNotifEntry."Failed With Message" := TempTouchedTicketNotifEntry."Failed With Message";
                end else
                    if Success then begin
                        TicketNotifEntry."Notification Send Status" := TicketNotifEntry."Notification Send Status"::SENT;
                        TicketNotifEntry."Failed With Message" := '';
                    end else begin
                        TicketNotifEntry."Notification Send Status" := TicketNotifEntry."Notification Send Status"::FAILED;
                        TicketNotifEntry."Failed With Message" := CopyStr(LastErrorText, 1, MaxStrLen(TicketNotifEntry."Failed With Message"));
                    end;
                TicketNotifEntry.Modify();
            end;
        until TempTouchedTicketNotifEntry.Next() = 0;

        Commit();
    end;

    [TryFunction]
    local procedure TrySendTouched(var NcTask: Record "NPR Nc Task")
    var
        HLIntegrationMgt: Codeunit "NPR HL Integration Mgt.";
        TempBlob: Codeunit "Temp Blob";
        CSVFieldList: List of [Text];
        CSVFieldSeparator: Text[1];
        NothingToSendErr: Label 'There is nothing to send.';
    begin
        CSVFieldSeparator := ',';
        if not GenerateCSVPayloadFile(TempBlob, CSVFieldList, CSVFieldSeparator) then
            Error(NothingToSendErr);
        ClearLastError();
        GenerateRequestContent(TempBlob, CSVFieldList, CSVFieldSeparator, NcTask);
        HLIntegrationMgt.InvokeHeybookingDBUpdateRequest(NcTask);
    end;

    local procedure GenerateCSVPayloadFile(var TempBlob: Codeunit "Temp Blob"; var CSVFieldList: List of [Text]; CSVFieldSeparator: Text[1]): Boolean
    var
        TempCSVBuffer: Record "CSV Buffer" temporary;
        LineNo: Integer;
    begin
        if not TempTouchedTicketNotifEntry.FindSet() then
            exit(false);
        LineNo := 0;
        repeat
            LineNo += 1;
            ClearLastError();
            if not GenerateTicketNotifEntryCSVPayload(TempTouchedTicketNotifEntry, LineNo, TempCSVBuffer, CSVFieldList) then begin
                TempTouchedTicketNotifEntry."Notification Send Status" := TempTouchedTicketNotifEntry."Notification Send Status"::FAILED;
                TempTouchedTicketNotifEntry."Failed With Message" := CopyStr(GetLastErrorText(), 1, MaxStrLen(TempTouchedTicketNotifEntry."Failed With Message"));
                TempTouchedTicketNotifEntry.Modify();
            end;
        until TempTouchedTicketNotifEntry.Next() = 0;

        if TempCSVBuffer.IsEmpty() then
            exit(false);
        TempCSVBuffer.SaveDataToBlob(TempBlob, CSVFieldSeparator);
        exit(true);
    end;

    [TryFunction]
    local procedure GenerateTicketNotifEntryCSVPayload(TicketNotifEntry: Record "NPR TM Ticket Notif. Entry"; LineNo: Integer; var CSVBuffer: Record "CSV Buffer"; var CSVFieldList: List of [Text])
    var
        Item: Record Item;
        Ticket: Record "NPR TM Ticket";
        TempTicketReservationRequest: Record "NPR TM Ticket Reservation Req." temporary;
        TicketType: Record "NPR TM Ticket Type";
        HLIntegrationEvents: Codeunit "NPR HL Integration Events";
        FieldNameValueList: Dictionary of [Text, Text];
        FieldName: Text;
        INVALID: Label 'Invalid %1';
        NOT_IMPLEMENTED: Label 'Case %1 %2 is not implemented.';
    begin
        TicketNotifEntry.TestField("Notification Engine", TicketNotifEntry."Notification Engine"::NPR_HEYLOYALTY);
        if TicketNotifEntry."Notification Method" in [TempTouchedTicketNotifEntry."Notification Method"::NA, TempTouchedTicketNotifEntry."Notification Method"::SMS] then
            Error(NOT_IMPLEMENTED, TicketNotifEntry.FieldCaption("Notification Method"), TicketNotifEntry."Notification Method");
        if TicketNotifEntry."Notification Address" = '' then
            Error(INVALID, TicketNotifEntry.FieldCaption("Notification Address"));

        Ticket.Get(TempTouchedTicketNotifEntry."Ticket No.");
        if not TicketType.Get(TempTouchedTicketNotifEntry."Ticket Type Code") then
            Clear(TicketType);

        if TempTouchedTicketNotifEntry."Ticket Item No." = '' then begin
            FindTicketRequests(Ticket."Ticket Reservation Entry No.", TempTicketReservationRequest);
            TempTicketReservationRequest.SetRange("Admission Code", TicketNotifEntry."Admission Code");
            if TempTicketReservationRequest.IsEmpty() then
                TempTicketReservationRequest.SetRange("Admission Code");
            if TempTicketReservationRequest.FindFirst() then
                TempTouchedTicketNotifEntry."Ticket Item No." := TempTicketReservationRequest."Item No.";
        end;
        if not Item.Get(TempTouchedTicketNotifEntry."Ticket Item No.") then
            Clear(Item);

        Clear(FieldNameValueList);
        FieldNameValueList.Add('email', TempTouchedTicketNotifEntry."Ticket Holder E-Mail");
        FieldNameValueList.Add('booking_id', StrSubstNo('%1_%2', TempTouchedTicketNotifEntry."External Ticket No.", TempTouchedTicketNotifEntry."Admission Code"));
        FieldNameValueList.Add('product_id', TempTouchedTicketNotifEntry."Ticket Item No.");
        FieldNameValueList.Add('category_id', TempTouchedTicketNotifEntry."Ticket Type Code");
        FieldNameValueList.Add('category_name', TicketType.Description);
        FieldNameValueList.Add('booking_date', Format(Ticket."Document Date", 0, 9));
        FieldNameValueList.Add('price', Format(Item."Unit Price", 0, 9));
        HLIntegrationEvents.OnAddFieldsToHeybookingDBPayload(TempTouchedTicketNotifEntry, FieldNameValueList);

        foreach FieldName in FieldNameValueList.Keys() do
            if FieldName <> '' then
                AddFieldToCSVBuffer(CSVBuffer, LineNo, FieldName, FieldNameValueList.Get(FieldName), CSVFieldList);
    end;

    local procedure FindTicketRequests(RequestEntryNo: Integer; var TicketReservationRequestOut: Record "NPR TM Ticket Reservation Req.")
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        HLIntegrationMgt: Codeunit "NPR HL Integration Mgt.";
    begin
        if not TicketReservationRequestOut.IsTemporary() then
            HLIntegrationMgt.NonTempParameterError();

        TicketReservationRequest.SetAutoCalcFields("Is Superseeded");
        TicketReservationRequest.Get(RequestEntryNo);
        AddRequestToTmp(TicketReservationRequest."Session Token ID", TicketReservationRequestOut);
        while TicketReservationRequest."Is Superseeded" do begin
            TicketReservationRequest.SetRange("Superseeds Entry No.", TicketReservationRequest."Entry No.");
            TicketReservationRequest.FindFirst();
            AddRequestToTmp(TicketReservationRequest."Session Token ID", TicketReservationRequestOut);
        end;
    end;

    local procedure AddRequestToTmp(Token: Text[100]; var TicketReservationRequestOut: Record "NPR TM Ticket Reservation Req.")
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
    begin
        TicketReservationRequest.SetRange("Session Token ID", Token);
        if TicketReservationRequest.FindSet() then
            repeat
                TicketReservationRequestOut := TicketReservationRequest;
                if TicketReservationRequestOut.Insert() then;
            until (TicketReservationRequest.Next() = 0);
    end;

    local procedure AddFieldToCSVBuffer(var CSVBuffer: Record "CSV Buffer"; LineNo: Integer; FieldName: Text; FieldValue: Text; var CSVFieldList: List of [Text])
    begin
        If not CSVFieldList.Contains(FieldName) then
            CSVFieldList.Add(FieldName);
        CSVBuffer.InsertEntry(LineNo, CSVFieldList.IndexOf(FieldName), CopyStr(FieldValue, 1, MaxStrLen(CSVBuffer.Value)));
    end;

    local procedure GenerateRequestContent(TempBlob: Codeunit "Temp Blob"; CSVFieldList: List of [Text]; CSVFieldSeparator: Text[1]; var NcTask: Record "NPR Nc Task")
    var
        HLIntegrationMgt: Codeunit "NPR HL Integration Mgt.";
        ContentString: TextBuilder;
        CSVFileStream: InStream;
        OutStr: OutStream;
        FieldName: Text;
        FileLine: Text;
        ContentDispositionLbl: Label 'Content-Disposition: form-data; name="%1"', Locked = true;
        FileNameLbl: Label '; filename="TicketData_%1.csv"', Locked = true;
    begin
        Clear(NcTask."Data Output");
        NcTask."Record Value" := CopyStr(DelChr(CreateGuid(), '=', '{}-'), 1, MaxStrLen(NcTask."Record Value"));

        //file
        ContentString.AppendLine('--' + NcTask."Record Value");
        ContentString.AppendLine(StrSubstNo(ContentDispositionLbl, 'file') + StrSubstNo(FileNameLbl, Format(CurrentDateTime, 0, '<Year4><Month,2><Day,2><Hours24,2><Minutes,2><Seconds,2>')));
        ContentString.AppendLine('Content-Type: text/csv');
        ContentString.AppendLine();
        TempBlob.CreateInStream(CSVFileStream);
        while not CSVFileStream.EOS() do begin
            CSVFileStream.ReadText(FileLine);
            if FileLine <> '' then
                ContentString.AppendLine(FileLine);
        end;

        //delimiter
        ContentString.AppendLine('--' + NcTask."Record Value");
        ContentString.AppendLine(StrSubstNo(ContentDispositionLbl, 'delimiter'));
        ContentString.AppendLine();
        ContentString.AppendLine(CSVFieldSeparator);

        //skip_header_line
        ContentString.AppendLine('--' + NcTask."Record Value");
        ContentString.AppendLine(StrSubstNo(ContentDispositionLbl, 'skip_header_line'));
        ContentString.AppendLine();
        ContentString.AppendLine('false');

        //date_format
        ContentString.AppendLine('--' + NcTask."Record Value");
        ContentString.AppendLine(StrSubstNo(ContentDispositionLbl, 'date_format'));
        ContentString.AppendLine();
        ContentString.AppendLine('iso8601');

        //sendErrorsTo
        ContentString.AppendLine('--' + NcTask."Record Value");
        ContentString.AppendLine(StrSubstNo(ContentDispositionLbl, 'sendErrorsTo'));
        ContentString.AppendLine();
        ContentString.AppendLine(HLIntegrationMgt.SendHeybookingErrToEmail());

        //duplicate_field
        ContentString.AppendLine('--' + NcTask."Record Value");
        ContentString.AppendLine(StrSubstNo(ContentDispositionLbl, 'duplicate_field'));
        ContentString.AppendLine();
        ContentString.AppendLine('booking_id');

        //handle_existing
        ContentString.AppendLine('--' + NcTask."Record Value");
        ContentString.AppendLine(StrSubstNo(ContentDispositionLbl, 'handle_existing'));
        ContentString.AppendLine();
        ContentString.AppendLine('update');

        //fields
        foreach FieldName in CSVFieldList do begin
            ContentString.AppendLine('--' + NcTask."Record Value");
            ContentString.AppendLine(StrSubstNo(ContentDispositionLbl, 'fields_selected[]'));
            ContentString.AppendLine();
            ContentString.AppendLine(FieldName);
        end;
        ContentString.AppendLine('--' + NcTask."Record Value" + '--');

        NcTask."Data Output".CreateOutStream(OutStr);
        OutStr.WriteText(ContentString.ToText());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Nc Sync. Mgt.", 'OnBeforeProcessTask', '', true, false)]
    local procedure CreateTaskSetup(var Task: Record "NPR Nc Task")
    var
        HLScheduleSend: Codeunit "NPR HL Schedule Send Tasks";
    begin
        if Task."Table No." <> Database::"NPR TM Ticket Notif. Entry" then
            exit;
        if (Task."Task Processor Code" = '') or (Task."Task Processor Code" <> HLScheduleSend.GetHeyLoyaltyTaskProcessorCode(false)) then
            exit;

        Error(NotReprocessibleErr);
    end;
}