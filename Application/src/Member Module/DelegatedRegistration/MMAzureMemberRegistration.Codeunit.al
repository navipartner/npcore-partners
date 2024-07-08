codeunit 6151383 "NPR MM AzureMemberRegistration"
{
    Access = Internal;

    var
        _AzureKeyVaultNamePrefix: Label 'MM-SignUp-SAS-%1', Locked = true, Comment = '%1 is storage account name';
        _AzureKeyVaultBlobNamePrefix: Label 'MM-SignUpImage-SAS-%1', Locked = true, Comment = '%1 is storage account name';

    trigger OnRun()
    var
        AzureRegistrationSetup: Record "NPR MM AzureMemberRegSetup";
        ProcessCount: Integer;
        FailedCount: Integer;
    begin
        AzureRegistrationSetup.SetFilter(Enabled, '=%1', true);
        AzureRegistrationSetup.SetFilter(EnableDequeuing, '=%1', true);
        if (AzureRegistrationSetup.FindSet()) then begin
            repeat
                repeat
                    ProcessMemberUpdateQueue(AzureRegistrationSetup.AzureRegistrationSetupCode, ProcessCount, FailedCount);
                until ((ProcessCount = 0) or (not AzureRegistrationSetup.DequeueUntilEmpty));
            until (AzureRegistrationSetup.Next() = 0);
        end;
    end;

    internal procedure ProcessMemberUpdateQueue(AzureRegistrationSetupCode: Code[10]; var ProcessCount: Integer; var FailCount: Integer)
    var
        AzureRegistrationSetup: Record "NPR MM AzureMemberRegSetup";
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
        QueueMessageListText: Text;
        XmlDoc: XmlDocument;
        MessageList: XmlElement;
        Messages: XmlNodeList;
        Message: XmlNode;
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        MessageId: Text[64];
        PopReceipt: Text[64];
        DataSubjectId: Text[64];
        MemberJson: JsonObject;
        ImageB64: Text;
        VisibilityTimeout: Integer;
        HaveImage: Boolean;
    begin
        if (not AzureRegistrationSetup.Get(AzureRegistrationSetupCode)) then
            exit;

        if (not AzureRegistrationSetup.Enabled) then
            exit;

        AzureRegistrationSetup.TestField(EnableDequeuing);
        VisibilityTimeout := AzureRegistrationSetup.DequeueBatchSize * 5; // Seconds until elements will be visible in queue again, when not completely processed. Only an issue when long update times and multiple jobs pulling from queue

        DequeueMemberRegistrations(AzureRegistrationSetup.AzureStorageAccountName, AzureRegistrationSetup.QueueName, AzureRegistrationSetup.DequeueBatchSize, VisibilityTimeout, QueueMessageListText);
        XmlDocument.ReadFrom(QueueMessageListText, XmlDoc);
        XmlDoc.GetRoot(MessageList);

        if (not NpXmlDomMgt.FindNodes(MessageList.AsXmlNode(), 'QueueMessagesList/QueueMessage', Messages)) then
            exit;

        foreach Message in Messages do begin
            if (DecodeMessage(Message.AsXmlElement(), MessageId, PopReceipt, DataSubjectId, MemberJson)) then begin
                HaveImage := GetMemberImage(AzureRegistrationSetup.AzureStorageAccountName, DataSubjectId, ImageB64);
                if (MembershipManagement.UpdateMember(DataSubjectId, MemberJson, ImageB64)) then begin
                    if (HaveImage) then
                        if (DeleteMemberImage(AzureRegistrationSetup.AzureStorageAccountName, DataSubjectId)) then; // not fatal to not delete the image
                    DeleteQueuedMessage(AzureRegistrationSetup.AzureStorageAccountName, AzureRegistrationSetup.QueueName, MessageId, PopReceipt);
                end;
                UpdateReceiveAzureLog(DataSubjectId, MemberJson);
                Commit();
                ProcessCount += 1;
            end else begin
                FailCount += 1;
            end;
        end;
    end;

    local procedure UpdateReceiveAzureLog(DataSubjectId: Text[64]; MemberJson: JsonObject)
    var
        JToken: JsonToken;
        SignUpJson: JsonObject;
        AzureLog: Record "NPR MM AzureMemberUpdateLog";
    begin
        AzureLog.SetCurrentKey(DataSubjectId);
        AzureLog.SetFilter(DataSubjectId, '=%1', DataSubjectId);
        if (not AzureLog.FindLast()) then
            exit;

        if (MemberJson.Get('m', JToken)) then
            MemberJson := JToken.AsObject();

        if (not MemberJson.Get('su', JToken)) then begin
            AzureLog.RegistrationMethod := AzureLog.RegistrationMethod::UNKNOWN;
        end else begin
            if (not SignUpJson.Get('pv', JToken)) then begin
                AzureLog.RegistrationMethod := AzureLog.RegistrationMethod::UNKNOWN;
            end else begin
                if (SignUpJson.Get('tn', JToken)) then
                    AzureLog.Token := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(AzureLog.Token));

                case (LowerCase(JToken.AsValue().AsText())) of
                    'email':
                        begin
                            AzureLog.RegistrationMethod := AzureLog.RegistrationMethod::EMAIL;
                            if (MemberJson.Get('em', JToken)) then
                                AzureLog.Token := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(AzureLog.Token));
                        end;
                    'facebook':
                        AzureLog.RegistrationMethod := AzureLog.RegistrationMethod::FACEBOOK;
                    'apple':
                        AzureLog.RegistrationMethod := AzureLog.RegistrationMethod::APPLE;
                    'google':
                        AzureLog.RegistrationMethod := AzureLog.RegistrationMethod::GOOGLE;
                    else
                        AzureLog.RegistrationMethod := AzureLog.RegistrationMethod::UNKNOWN;
                end;
            end;
        end;

        AzureLog.ResponseReceived := CurrentDateTime();
        AzureLog.Modify();
    end;

#pragma warning disable AA0139
    [TryFunction]
    internal procedure DecodeMessage(QueueMessage: XmlElement; var MessageId: Text[64]; var PopReceipt: Text[64]; var DataSubjectId: Text[64]; var MemberJson: JsonObject)
    var
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        Base64: Codeunit "Base64 Convert";
        Message: JsonObject;
        JToken: JsonToken;
        PartitionKey: Text[64];
    begin
        // Queue Message
        MessageId := NpXmlDomMgt.GetXmlText(QueueMessage, 'MessageId', 64, true);
        PopReceipt := NpXmlDomMgt.GetXmlText(QueueMessage, 'PopReceipt', 64, true);
        Message.ReadFrom(Base64.FromBase64(NpXmlDomMgt.GetXmlText(QueueMessage, 'MessageText', 0, true)));

        // Message Payload
        Message.Get('PartitionKey', JToken);
        PartitionKey := JToken.AsValue().AsText();

        Message.Get('RowKey', JToken);
        DataSubjectId := JToken.AsValue().AsText();

        Message.Get('Data', JToken);
        MemberJson.ReadFrom(Base64.FromBase64(JToken.AsValue().AsText()));

    end;
#pragma warning restore AA0139

    internal procedure TestBlobFunctions(StorageAccountName: Text[24])
    var
        DataSubjectId: Text[64];
        BlobData: Text;
    begin
        BlobData := 'Foo Bar Baz';
        DataSubjectId := CopyStr(UpperCase(DelChr(Format(CreateGuid()), '=', '{}')), 1, MaxStrLen(DataSubjectId));
        PutMemberImage(StorageAccountName, DataSubjectId, BlobData);
        GetMemberImage(StorageAccountName, DataSubjectId, BlobData);
        DeleteMemberImage(StorageAccountName, DataSubjectId);
    end;

    [TryFunction]
    local procedure GetMemberImage(StorageAccountName: Text[24]; DataSubjectId: Text[64]; var ImageB64: Text)
    var
        Client: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        GetBlobUrl: Label 'https://%1.blob.core.windows.net/images/%2?%3', locked = true;
        SharedAccessSignature: Text;
    begin
        ImageB64 := '';
        SharedAccessSignature := GetSecret(_AzureKeyVaultBlobNamePrefix, StorageAccountName);

        Request.Method('GET');
        Request.SetRequestUri(StrSubstNo(GetBlobUrl, StorageAccountName, DataSubjectId, SharedAccessSignature));
        if (not Client.Send(Request, Response)) then
            Error(GetLastErrorText());

        if (not Response.IsSuccessStatusCode()) then
            Error(GetLastErrorText());

        Response.Content().ReadAs(ImageB64);
    end;

    [TryFunction]
    local procedure DeleteMemberImage(StorageAccountName: Text[24]; DataSubjectId: Text[64])
    var
        Client: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        GetBlobUrl: Label 'https://%1.blob.core.windows.net/images/%2?%3', locked = true;
        SharedAccessSignature: Text;
    begin
        SharedAccessSignature := GetSecret(_AzureKeyVaultBlobNamePrefix, StorageAccountName);

        Request.Method('DELETE');
        Request.SetRequestUri(StrSubstNo(GetBlobUrl, StorageAccountName, DataSubjectId, SharedAccessSignature));
        if (not Client.Send(Request, Response)) then
            Error(GetLastErrorText());

        if (not Response.IsSuccessStatusCode()) then
            Error(GetLastErrorText());
    end;

    [TryFunction]
    local procedure PutMemberImage(StorageAccountName: Text[24]; DataSubjectId: Text[64]; BlobData: Text)
    var
        Client: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        Header: HttpHeaders;
        Content: HttpContent;
        GetBlobUrl: Label 'https://%1.blob.core.windows.net/images/%2?%3', locked = true;
        SharedAccessSignature: Text;
    begin
        SharedAccessSignature := GetSecret(_AzureKeyVaultBlobNamePrefix, StorageAccountName);
        Content.WriteFrom(BlobData);

        Request.GetHeaders(Header);
        Header.Add('x-ms-blob-type', 'BlockBlob');

        Request.Method('PUT');
        Request.SetRequestUri(StrSubstNo(GetBlobUrl, StorageAccountName, DataSubjectId, SharedAccessSignature));
        if (not Client.Send(Request, Response)) then
            Error(GetLastErrorText());

        if (not Response.IsSuccessStatusCode()) then
            Error(GetLastErrorText());
    end;

    [TryFunction]
    internal procedure CheckIfStorageAccountQueueExist(StorageAccountName: Text[24]; QueueName: Text[64])
    var
        Client: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        Headers: HttpHeaders;
        GetQueueMetaDataUrl: Label 'https://%1.queue.core.windows.net/%2?%3&comp=metadata', Locked = true;
        SharedAccessSignature: Text;
        UnexpectedResponseCodeErr: Label 'Azure service did not return with a HTTP 200 return code (return code was: %1 - %2).';
        HeaderValues: array[10] of Text;
        MsErrorCode: Text;
    begin
        SharedAccessSignature := GetSecret(_AzureKeyVaultNamePrefix, StorageAccountName);

        Request.Method('HEAD');
        Request.SetRequestUri(StrSubstNo(GetQueueMetaDataUrl, StorageAccountName, QueueName, SharedAccessSignature));
        if (not Client.Send(Request, Response)) then
            Error(GetLastErrorText());

        if (Response.HttpStatusCode() = 200) then
            exit;

        Headers := Response.Headers();
        if (Headers.Contains('x-ms-error-code')) then
            if (Headers.GetValues('x-ms-error-code', HeaderValues)) then
                MsErrorCode := HeaderValues[1];

        Error(UnexpectedResponseCodeErr, Response.HttpStatusCode(), MsErrorCode);
    end;

    [TryFunction]
    internal procedure CreateStorageAccountQueue(StorageAccountName: Text[24]; QueueName: Text[64])
    var
        Client: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        Headers: HttpHeaders;
        CreateQueueUrl: Label 'https://%1.queue.core.windows.net/%2?%3', Locked = true;
        SharedAccessSignature: Text;
        UnexpectedResponseCodeErr: Label 'Azure service did not return with a HTTP 201, 204 return code (return code was: %1 - %2).';
        HeaderValues: array[10] of Text;
        MsErrorCode: Text;
    begin
        SharedAccessSignature := GetSecret(_AzureKeyVaultNamePrefix, StorageAccountName);

        Request.Method('PUT');
        Request.SetRequestUri(StrSubstNo(CreateQueueUrl, StorageAccountName, QueueName, SharedAccessSignature));
        if (not Client.Send(Request, Response)) then
            Error(GetLastErrorText());

        if (Response.HttpStatusCode() in [201, 204]) then // Created, Already Exists
            exit;

        Headers := Response.Headers();
        if (Headers.Contains('x-ms-error-code')) then
            if (Headers.GetValues('x-ms-error-code', HeaderValues)) then
                MsErrorCode := HeaderValues[1];

        Error(UnexpectedResponseCodeErr, Response.HttpStatusCode(), MsErrorCode);
    end;

    internal procedure CreateMemberSignUpReference(AzureRegistrationSetupCode: Code[10]; DataSubjectId: Text[64]): Boolean
    var
        AzureRegistrationSetup: Record "NPR MM AzureMemberRegSetup";
    begin
        AzureRegistrationSetup.Get(AzureRegistrationSetupCode);
        if (not AzureRegistrationSetup.Enabled) then
            exit(false);

        if (not GuiAllowed()) then
            exit(CreateMemberSignUpReference(AzureRegistrationSetup.AzureStorageAccountName, AzureRegistrationSetup.QueueName, DataSubjectId));

        CreateMemberSignUpReference(AzureRegistrationSetup.AzureStorageAccountName, AzureRegistrationSetup.QueueName, DataSubjectId);
        exit(true);
    end;

    [TryFunction]
    local procedure CreateMemberSignUpReference(StorageAccountName: Text[24]; QueueName: Text[64]; DataSubjectId: Text[64])
    var
        Client: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        Headers: HttpHeaders;
        ContentHeader: HttpHeaders;
        Content: HttpContent;
        InsertIntoTableUrl: Label 'https://%1.table.core.windows.net/SignupRequest?%2', Locked = true;
        SharedAccessSignature: Text;
        UnexpectedResponseCodeErr: Label 'Azure service did not return with a HTTP 201 return code (return code was: %1 - %2).';
        HeaderValues: array[10] of Text;
        MsErrorCode: Text;
        PayloadText: Text;
        MessageBody: JsonObject;
    begin
        SharedAccessSignature := GetSecret(_AzureKeyVaultNamePrefix, StorageAccountName);

        MessageBody.Add('PartitionKey', QueueName);
        MessageBody.Add('RowKey', DataSubjectId);
        MessageBody.Add('TenantId', TenantId());
        MessageBody.Add('CompanyName', CompanyName());

        MessageBody.WriteTo(PayloadText);
        Content.WriteFrom(PayloadText);
        Content.GetHeaders(ContentHeader);

        ContentHeader.Clear();
        ContentHeader.Remove('Content-Type');
        ContentHeader.Add('Content-Type', 'application/json; charset=utf-8');

        Request.GetHeaders(Headers);
        Headers.Add('Accept', '*/*');

        Request.Method('POST');
        Request.SetRequestUri(StrSubstNo(InsertIntoTableUrl, StorageAccountName, SharedAccessSignature));
        Request.Content(Content);

        Client.Timeout(5000);
        if (not Client.Send(Request, Response)) then
            Error(GetLastErrorText());

        if (Response.HttpStatusCode() in [201, 409]) then // Created, Conflict (duplicate)
            exit;

        Headers := Response.Headers();
        if (Headers.Contains('x-ms-error-code')) then
            if (Headers.GetValues('x-ms-error-code', HeaderValues)) then
                MsErrorCode := HeaderValues[1];

        Error(UnexpectedResponseCodeErr, Response.HttpStatusCode(), MsErrorCode);
    end;

    [TryFunction]
    local procedure DequeueMemberRegistrations(StorageAccountName: Text[24]; QueueName: Text[64]; BatchSize: Integer; VisibilityTimeout: Integer; var QueueMessageListXml: Text)
    var
        Client: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        DequeueFromUrl: Label 'https://%1.queue.core.windows.net/%2/messages?numofmessages=%3&visibilitytimeout=%4&%5', Locked = true;
        SharedAccessSignature: Text;
    begin
        QueueMessageListXml := '';
        SharedAccessSignature := GetSecret(_AzureKeyVaultNamePrefix, StorageAccountName);

        Request.Method('GET');
        Request.SetRequestUri(StrSubstNo(DequeueFromUrl, StorageAccountName, QueueName, BatchSize, VisibilityTimeout, SharedAccessSignature));
        Client.Timeout(5000);
        if (not Client.Send(Request, Response)) then
            Error(GetLastErrorText());

        if (not Response.IsSuccessStatusCode) then
            Error(GetLastErrorText());

        Response.Content().ReadAs(QueueMessageListXml);
    end;

    [TryFunction]
    local procedure DeleteQueuedMessage(StorageAccountName: Text[24]; QueueName: Text[64]; MessageId: Text[64]; PopReceipt: Text[64])
    var
        Client: HttpClient;
        Request: HttpRequestMessage;
        Headers: HttpHeaders;
        Response: HttpResponseMessage;
        DeleteFromQueueUrl: Label 'https://%1.queue.core.windows.net/%2/messages/%3?popreceipt=%4&%5', Locked = true;
        SharedAccessSignature: Text;
    begin
        SharedAccessSignature := GetSecret(_AzureKeyVaultNamePrefix, StorageAccountName);

        Request.Method('DELETE');
        Request.SetRequestUri(StrSubstNo(DeleteFromQueueUrl, StorageAccountName, QueueName, MessageId, PopReceipt, SharedAccessSignature));
        Request.GetHeaders(Headers);
        Headers.Add('If-Match', '*');

        Client.Timeout(5000);
        if (not Client.Send(Request, Response)) then
            Error(GetLastErrorText());

        if (not Response.IsSuccessStatusCode) then
            Error(GetLastErrorText());
    end;

    procedure CreateAzureMemberUpdateJob(var JobQueueEntry: Record "Job Queue Entry"; Silent: Boolean): Boolean
    var
        ConfirmJobCreationQst: Label 'This function will add a new periodic job (Job Queue Entry), responsible for fetching member updates from Azure (if a similar job already exists, system will not add anything).\Are you sure you want to continue?';
    begin
        if (not Silent) then
            if not Confirm(ConfirmJobCreationQst, true) then
                exit(false);
        exit(InitAzureMemberUpdateJob(JobQueueEntry));
    end;

    local procedure InitAzureMemberUpdateJob(var JobQueueEntry: Record "Job Queue Entry"): Boolean
    var
        JobQueueMgt: Codeunit "NPR Job Queue Management";
        NextRunDateFormula: DateFormula;
        JobQueueCategoryTok: Label 'MMAZUREUPD', Locked = true, MaxLength = 10;
        JobQueueDescLbl: Label 'Dequeue and update member information from Azure user input', Locked = true;
    begin
        JobQueueMgt.SetJobTimeout(4, 0);  //4 hours

        if (JobQueueMgt.InitRecurringJobQueueEntry(
            JobQueueEntry."Object Type to Run"::Codeunit,
            Codeunit::"NPR MM AzureMemberRegistration",
            '',
            JobQueueDescLbl,
            JobQueueMgt.NowWithDelayInSeconds(60),
            000000T,
            000000T,
            NextRunDateFormula,
            JobQueueCategoryTok,
            JobQueueEntry))
        then begin
            JobQueueEntry."No. of Minutes between Runs" := 1;
            JobQueueEntry."Recurring Job" := true;
            JobQueueEntry.Validate("Starting Time", 070001T);
            JobQueueEntry."Ending Time" := 220000T;
            JobQueueEntry.Modify();
            JobQueueMgt.StartJobQueueEntry(JobQueueEntry);
            exit(true);
        end;
    end;

    local procedure GetSecret(LabelPrefix: Text; StorageAccountName: Text[24]): Text
    var
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
    begin
        exit(AzureKeyVaultMgt.GetAzureKeyVaultSecret(StrSubstNo(LabelPrefix, StorageAccountName)));
    end;
}
