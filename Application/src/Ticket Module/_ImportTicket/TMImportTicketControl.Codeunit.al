codeunit 6184689 "NPR TM ImportTicketControl"
{
    Access = Internal;

    var
        MandatoryKeyMissing: Label 'Expected and mandatory key "%1" missing in object.';

    internal procedure ImportAndCreate(TicketJson: JsonObject) JobId: Code[40]
    var
        TempTicketImport: Record "NPR TM ImportTicketHeader" temporary;
        TempTicketImportLine: Record "NPR TM ImportTicketLine" temporary;
        ImportTicket: Codeunit "NPR TM ImportTicketWorker";
        StartTime: Time;
        ImportDuration: Duration;
    begin
        JobId := CopyStr(UpperCase(DelChr(Format(CreateGuid()), '=', '{}-')), 1, MaxStrLen(JobId));
        MapTicketJsonToTempTable(TicketJson, JobId, TempTicketImport, TempTicketImportLine);

        ImportTicket.SetImportBuffer(TempTicketImport, TempTicketImportLine);
        StartTime := Time;
        ImportTicket.Import();
        ImportDuration := Time() - StartTime;
        LogImport(JobId, '', ImportDuration, TempTicketImportLine.Count(), true, '');
    end;

    internal procedure ImportTicketsFromFile(Preview: Boolean) JobId: Code[40]
    var
        TempBlob: Codeunit "Temp Blob";
        FileMgt: Codeunit "File Management";
        FileName: Text;
        IStream: InStream;
        IMPORT_FILE: label 'External Ticket Import';
        ImportSuccess: Label 'File %1 successfully import as job id: %2';
        TicketJsonText: Text;
        TicketJson: JsonObject;
        ResponseMessage: Text;
    begin
        FileName := FileMgt.BLOBImportWithFilter(TempBlob, IMPORT_FILE, '', 'External Ticket File (*.json)|*.json', 'json');
        if (FileName = '') then
            exit;

        TempBlob.CreateInStream(IStream);
        IStream.Read(TicketJsonText);
        TicketJson.ReadFrom(TicketJsonText);
        Clear(TempBlob);

        if (not DoImportPreviewAndTicketCreate(TicketJson, FileName, Preview, ResponseMessage, JobId)) then
            Error(ResponseMessage);

        if (Preview) then
            Message(ImportSuccess, FileName, JobId);
    end;

    internal procedure ImportTicketFromJson(
        TicketJson: JsonObject;
        Preview: Boolean;
        var ResponseMessage: Text;
        var JobId: Code[40]) Imported: Boolean
    begin
        exit(DoImportPreviewAndTicketCreate(TicketJson, '', Preview, ResponseMessage, JobId));
    end;

    local procedure DoImportPreviewAndTicketCreate(
        TicketJson: JsonObject;
        FileName: Text;
        Preview: Boolean;
        var ResponseMessage: Text;
        var JobId: Code[40]) Imported: Boolean
    var
        TempTicketImport: Record "NPR TM ImportTicketHeader" temporary;
        TempTicketImportLine: Record "NPR TM ImportTicketLine" temporary;
        CallStack: Text;
        ImportPreview: Page "NPR TM ImportTicketsPreview";
        ImportTicket: Codeunit "NPR TM ImportTicketWorker";
        StartTime: Time;
        ImportDuration: Duration;
    begin
        JobId := CopyStr(UpperCase(DelChr(Format(CreateGuid()), '=', '{}-')), 1, MaxStrLen(JobId));
        MapTicketJsonToTempTable(TicketJson, JobId, TempTicketImport, TempTicketImportLine);

        if (Preview) then begin
            ImportPreview.LoadData(TempTicketImport, TempTicketImportLine);
            ImportPreview.LookupMode(true);
            if (Action::LookupOk <> ImportPreview.RunModal()) then
                Error('');
        end;

        ClearLastError();
        ImportTicket.SetImportBuffer(TempTicketImport, TempTicketImportLine);

        StartTime := Time;
        Imported := ImportTicket.Run();
        ImportDuration := Time() - StartTime;

        if (not Imported) then begin
            ResponseMessage := GetLastErrorText();
            CallStack := GetLastErrorCallStack();
            ImportTicket.CleanUpFailedImport(JobId);
        end;

        LogImport(JobId, FileName, ImportDuration, TempTicketImportLine.Count(), Imported, ResponseMessage);
        Commit();

        if (Imported) then
            exit;

        if (Preview) then
            Error('%1\\%2', ResponseMessage, CallStack);
    end;

    local procedure LogImport(JobId: Code[40]; FileName: Text; ImportDuration: Duration; TicketCount: Integer; Imported: Boolean; ResponseMessage: Text)
    var
        Log: Record "NPR TM ImportTicketLog";
    begin
        Log.JobId := JobId;
        Log.FileName := CopyStr(FileName, 1, MaxStrLen(Log.FileName));
        Log.ImportDuration := ImportDuration;
        Log.NumberOfTickets := TicketCount;
        Log.Success := Imported;
        Log.ResponseMessage := CopyStr(ResponseMessage, 1, MaxStrLen(Log.ResponseMessage));
        Log.ImportedBy := CopyStr(UserId(), 1, MaxStrLen(log.ImportedBy));
        Log.Insert();
    end;

#pragma warning disable AA0139
    local procedure MapTicketJsonToTempTable(
        TicketJson: JsonObject;
        JobId: Code[40];
        var TempTicketImport: Record "NPR TM ImportTicketHeader" temporary;
        var TempTicketImportLine: Record "NPR TM ImportTicketLine" temporary)
    var
        JToken: JsonToken;
        TicketOrder, Ticket, TicketHolder : JsonObject;
        TicketOrderToken, TicketToken : JsonToken;
        TicketOrders, Tickets : JsonArray;
        TMTicketSetup: Record "NPR TM Ticket Setup";
        TMTicketManagement: Codeunit "NPR TM Ticket Management";
        TMTicket: Record "NPR TM Ticket";
        GenerateNumberCount: Integer;
        ErrUnableToGenerateUniqueNumber: Label 'Unable to generate an unique number after 10 attempts.';
        ErrEmptyExtTicketPattern: Label 'cannot be empty when PreAssignedTicketNumber is blank upon Ticket Import.';
    begin
        TMTicketSetup.Get();
        Clear(TempTicketImport);
        Clear(TempTicketImportLine);
        TicketJson.Get('ticketBatch', JToken);
        TicketOrders := JToken.AsArray();

        foreach TicketOrderToken in TicketOrders do begin
            TicketOrder := TicketOrderToken.AsObject();
            TempTicketImport.Init();
            TempTicketImport.OrderId := Format(GetAsText(TicketOrder, 'orderNumber', MaxStrLen(TempTicketImport.OrderId), true));
            TempTicketImport.JobId := JobId;
            TempTicketImport.TotalAmount := GetAsDecimal(TicketOrder, 'totalAmount', true);
            TempTicketImport.TotalAmountInclVat := GetAsDecimal(TicketOrder, 'totalAmountInclVat', true);
            TempTicketImport.TotalAmountLcyInclVat := GetAsDecimal(TicketOrder, 'totalAmountLcyInclVat', true);
            TempTicketImport.TotalDiscountAmountInclVat := GetAsDecimal(TicketOrder, 'totalDiscountAmountInclVat', true);
            TempTicketImport.CurrencyCode := Format(GetAsText(TicketOrder, 'currencyCode', MaxStrLen(TempTicketImport.CurrencyCode), true));
            TempTicketImport.SalesDate := GetAsDate(TicketOrder, 'salesDate', true);
            TempTicketImport.PaymentReference := Format(GetAsText(TicketOrder, 'paymentReference', MaxStrLen(TempTicketImport.PaymentReference), false));
            TempTicketImport.TicketHolderEMail := LowerCase(GetAsText(TicketOrder, 'eMail', MaxStrLen(TempTicketImport.TicketHolderEMail), false));
            TempTicketImport.TicketHolderName := GetAsText(TicketOrder, 'name', MaxStrLen(TempTicketImport.TicketHolderName), false);
            TempTicketImport.TicketHolderPreferredLang := GetAsText(TicketOrder, 'languageCode', MaxStrLen(TempTicketImport.TicketHolderPreferredLang), false);

            TicketOrder.Get('tickets', JToken);
            Tickets := JToken.AsArray();
            foreach TicketToken in Tickets do begin
                Ticket := TicketToken.AsObject();
                TempTicketImportLine.Init();
                TempTicketImportLine.OrderId := TempTicketImport.OrderId;
                TempTicketImportLine.JobId := JobId;
                TempTicketImportLine.TicketRequestTokenLine := GetAsInteger(Ticket, 'orderLineNumber', false);
                TempTicketImportLine.PreAssignedTicketNumber := Format(GetAsText(Ticket, 'preAssignedTicketNumber', MaxStrLen(TempTicketImportLine.PreAssignedTicketNumber), false));

                if (TempTicketImportLine.PreAssignedTicketNumber = '') then begin
                    if (TMTicketSetup."Imp. Def. Ext. Ticket Pattern" = '') then
                        TMTicketSetup.FieldError("Imp. Def. Ext. Ticket Pattern", ErrEmptyExtTicketPattern);

                    TempTicketImportLine.PreAssignedTicketNumber := TMTicketManagement.GenerateNumberPattern(TMTicketSetup."Imp. Def. Ext. Ticket Pattern", '');
                    if (not TMTicket.CheckIsUnique(TempTicketImportLine.PreAssignedTicketNumber)) then begin
                        repeat
                            TempTicketImportLine.PreAssignedTicketNumber := TMTicketManagement.GenerateNumberPattern(TMTicketSetup."Imp. Def. Ext. Ticket Pattern", '');
                            GenerateNumberCount += 1;
                        until ((TMTicket.CheckIsUnique(TempTicketImportLine.PreAssignedTicketNumber)) or (GenerateNumberCount >= 10));

                        if (GenerateNumberCount > 10) then
                            Error(ErrUnableToGenerateUniqueNumber);
                    end;
                end;

                TempTicketImportLine.ItemReferenceNumber := Format(GetAsText(Ticket, 'itemReferenceNumber', MaxStrLen(TempTicketImportLine.ItemReferenceNumber), true));
                TempTicketImportLine.Description := Format(GetAsText(Ticket, 'description', MaxStrLen(TempTicketImportLine.Description), false));
                TempTicketImportLine.ExpectedVisitDate := GetAsDate(Ticket, 'expectedVisitDate', true);
                TempTicketImportLine.ExpectedVisitTime := GetAsTime(Ticket, 'expectedVisitTime', true);

                TempTicketImportLine.Amount := GetAsDecimal(Ticket, 'amount', true);
                TempTicketImportLine.AmountInclVat := GetAsDecimal(Ticket, 'amountInclVat', true);
                TempTicketImportLine.DiscountAmountInclVat := GetAsDecimal(Ticket, 'discountAmountInclVat', true);
                TempTicketImportLine.AmountLcyInclVat := GetAsDecimal(Ticket, 'amountLcyInclVat', true);
                TempTicketImportLine.CurrencyCode := TempTicketImport.CurrencyCode;

                if (Ticket.Get('ticketHolder', JToken)) then begin
                    TicketHolder := JToken.AsObject();
                    TempTicketImportLine.TicketHolderEMail := LowerCase(GetAsText(TicketHolder, 'eMail', MaxStrLen(TempTicketImportLine.TicketHolderEMail), false));
                    TempTicketImportLine.TicketHolderName := GetAsText(TicketHolder, 'name', MaxStrLen(TempTicketImportLine.TicketHolderName), false);
                    TempTicketImportLine.TicketHolderPreferredLang := GetAsText(TicketHolder, 'languageCode', MaxStrLen(TempTicketImportLine.TicketHolderPreferredLang), false);
                    TempTicketImportLine.MembershipNumber := Format(GetAsText(TicketHolder, 'membershipNumber', MaxStrLen(TempTicketImportLine.MembershipNumber), false));
                    TempTicketImportLine.MemberNumber := Format(GetAsText(TicketHolder, 'memberNumber', MaxStrLen(TempTicketImportLine.MemberNumber), false));
                end;

                if (TempTicketImport.TicketHolderEMail = '') then begin
                    TempTicketImport.TicketHolderEMail := TempTicketImportLine.TicketHolderEMail;
                    TempTicketImport.TicketHolderName := TempTicketImportLine.TicketHolderName;
                    TempTicketImport.TicketHolderPreferredLang := TempTicketImportLine.TicketHolderPreferredLang;
                end;

                TempTicketImportLine.Insert();
            end;
            TempTicketImport.Insert();
        end;
    end;
#pragma warning restore AA0139

    local procedure GetAsText(JObject: JsonObject; KeyName: Text; MaxLength: Integer; Mandatory: Boolean) KeyValue: Text
    var
        MandatoryKeyBlank: Label 'Mandatory key "%1" has a blank value.';
        ValueExceedsLength: Label 'Value "%1" specified for key "%2", exceeds max length (%3).';
        JToken: JsonToken;
    begin
        KeyValue := '';

        if (not JObject.Get(KeyName, JToken)) then begin
            if (Mandatory) then
                Error(MandatoryKeyMissing, KeyName);
            exit;
        end;

        if (Mandatory) then
            if (JToken.AsValue().AsText() = '') then
                Error(MandatoryKeyBlank, KeyName);

        KeyValue := JToken.AsValue().AsText();
        if (StrLen(KeyValue) > MaxLength) then
            Error(ValueExceedsLength, KeyValue, KeyName, MaxLength);
    end;

    local procedure GetAsInteger(JObject: JsonObject; KeyName: Text; Mandatory: Boolean) KeyValue: Integer
    var
        JToken: JsonToken;
    begin
        KeyValue := 0;

        if (not JObject.Get(KeyName, JToken)) then begin
            if (Mandatory) then
                Error(MandatoryKeyMissing, KeyName);
            exit;
        end;

        KeyValue := JToken.AsValue().AsInteger();
    end;


    local procedure GetAsDecimal(JObject: JsonObject; KeyName: Text; Mandatory: Boolean) KeyValue: Decimal
    var
        JToken: JsonToken;
    begin
        KeyValue := 0.0;

        if (not JObject.Get(KeyName, JToken)) then begin
            if (Mandatory) then
                Error(MandatoryKeyMissing, KeyName);
            exit;
        end;

        KeyValue := JToken.AsValue().AsDecimal();
    end;

    local procedure GetAsDate(JObject: JsonObject; KeyName: Text; Mandatory: Boolean) KeyValue: Date
    var
        JToken: JsonToken;
    begin
        KeyValue := 0D;

        if (not JObject.Get(KeyName, JToken)) then begin
            if (Mandatory) then
                Error(MandatoryKeyMissing, KeyName);
            exit;
        end;

        KeyValue := JToken.AsValue().AsDate();

    end;

    local procedure GetAsTime(JObject: JsonObject; KeyName: Text; Mandatory: Boolean) KeyValue: Time
    var
        JToken: JsonToken;
    begin
        KeyValue := 0T;

        if (not JObject.Get(KeyName, JToken)) then begin
            if (Mandatory) then
                Error(MandatoryKeyMissing, KeyName);
            exit;
        end;

        KeyValue := JToken.AsValue().AsTime();
    end;
}