#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248381 "NPR ApiSpeedgateReports"
{
    Access = Internal;
    internal procedure LookupReferenceNumber(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        EntryLog: Record "NPR SGEntryLog";
    begin
        if (not Request.QueryParams().ContainsKey('referenceNumber')) then
            exit(Response.RespondBadRequest('Missing required query parameter: referenceNumber'));

        EntryLog.SetCurrentKey(ReferenceNo);
        EntryLog.SetFilter(ReferenceNo, '=%1', Request.QueryParams().Get('referenceNumber'));

        exit(Response.RespondOK(CreateLookupResponse(EntryLog).BuildAsArray()));

    end;

    local procedure CreateLookupResponse(var EntryLogFilter: Record "NPR SGEntryLog") ResultJson: Codeunit "NPR Json Builder"
    var
        EntryLog: Record "NPR SGEntryLog";
        SpeedgateAdmit: Codeunit "NPR ApiSpeedgateAdmit";
    begin

        EntryLog.CopyFilters(EntryLogFilter);
        ResultJson := ResultJson.StartArray();

        if EntryLog.FindSet() then begin
            repeat
                ResultJson.StartObject()
                    .AddProperty('referenceNumber', EntryLog.ReferenceNo)
                    .AddProperty('referenceNumberType', SpeedgateAdmit.ReferenceNumberTypeAsText(EntryLog.ReferenceNumberType))
                    .AddObject(AsNull(ResultJson, 'referenceId', EntryLog.EntityId))

                    .AddProperty('scannerId', EntryLog.ScannerId)
                    .AddProperty('scannerDescription', EntryLog.ScannerDescription)
                    .AddProperty('admissionCode', EntryLog.AdmissionCode)

                    .AddObject(AsNull(ResultJson, 'admitToken', EntryLog.Token))
                    .AddProperty('entryStatus', SpeedgateAdmit.EntryStatusAsText(EntryLog.EntryStatus))
                    .AddProperty('attemptedAt', EntryLog.SystemCreatedAt)

                    .AddProperty('admittedReferenceNumber', EntryLog.AdmittedReferenceNo)
                    .AddObject(AsNull(ResultJson, 'admittedReferenceId', EntryLog.AdmittedReferenceId))
                    .AddObject(AsNull(ResultJson, 'admittedAt', EntryLog.AdmittedAt))

                    .AddObject(ErrorDescription(ResultJson, EntryLog))
                    .AddObject(ExtraEntityDescription(ResultJson, EntryLog))

                    .AddProperty('entryNumber', EntryLog.EntryNo)
                    .EndObject();

            until (EntryLog.Next() = 0);
        end;
        ResultJson.EndArray();

    end;

    local procedure AsNull(ResultJson: Codeunit "NPR Json Builder"; PropertyName: Text; PropertyValue: Guid): Codeunit "NPR Json Builder"
    begin
        if (IsNullGuid(PropertyValue)) then
            ResultJson.AddProperty(PropertyName)
        else
            ResultJson.AddProperty(PropertyName, format(PropertyValue, 0, 4).ToLower());

        exit(ResultJson);
    end;

    local procedure AsNull(ResultJson: Codeunit "NPR Json Builder"; PropertyName: Text; PropertyValue: DateTime): Codeunit "NPR Json Builder"
    begin
        if (CreateDateTime(0D, 0T) = PropertyValue) then
            ResultJson.AddProperty(PropertyName)
        else
            ResultJson.AddProperty(PropertyName, PropertyValue);

        exit(ResultJson);
    end;

    local procedure ErrorDescription(ResultJson: Codeunit "NPR Json Builder"; EntryLog: Record "NPR SGEntryLog"): Codeunit "NPR Json Builder"
    var
        ErrorText: Text;
    begin

        if (EntryLog.ApiErrorNumber <> 0) then begin
            ErrorText := EntryLog.ApiErrorMessage;
            if (ErrorText = '') then
                ErrorText := Format(Enum::"NPR API Error Code".FromInteger(EntryLog.ApiErrorNumber), 0, 1);
        end;

        ResultJson
            .AddProperty('errorNumber', EntryLog.ApiErrorNumber)
            .AddProperty('errorMessage', ErrorText);

    end;

    local procedure ExtraEntityDescription(ResultJson: Codeunit "NPR Json Builder"; EntryLog: Record "NPR SGEntryLog"): Codeunit "NPR Json Builder"
    var
        MemberGuest: Record "NPR MM Members. Admis. Setup";
        MemberCard: Record "NPR MM Member Card";
        Ticket: Record "NPR TM Ticket";
    begin

        // 6060135 Guest
        // 6060131 Member Card
        // 6059785 Ticket
        case EntryLog.ExtraEntityTableId of
            6060135:
                if (MemberGuest.GetBySystemId(EntryLog.ExtraEntityId)) then
                    ResultJson
                        .AddProperty('type', 'memberGuest')
                        .AddObject(AsNull(ResultJson, 'typeId', EntryLog.ExtraEntityId))
                        .AddProperty('typeDescription', MemberGuest.Description);

            6060131:
                if (MemberCard.GetBySystemId(EntryLog.ExtraEntityId)) then
                    ResultJson
                        .AddProperty('type', 'memberCard')
                        .AddObject(AsNull(ResultJson, 'typeId', EntryLog.ExtraEntityId))
                        .AddProperty('typeDescription', MemberCard."External Card No.");

            6059785:
                if (Ticket.GetBySystemId(EntryLog.ExtraEntityId)) then
                    ResultJson
                        .AddProperty('type', 'ticket')
                        .AddObject(AsNull(ResultJson, 'typeId', EntryLog.ExtraEntityId))
                        .AddProperty('typeDescription', Ticket."External Ticket No.");

        end;

        exit(ResultJson);
    end;
}
#endif