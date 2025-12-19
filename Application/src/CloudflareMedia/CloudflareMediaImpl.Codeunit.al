codeunit 6248557 "NPR CloudflareMediaImpl" implements "NPR CloudflareMigrationInterface"
{
    Access = Internal;

    var
        _JobNotFoundError: Label 'Job not found.';
        _ErrorRetrievingMediaKey: Label 'Error retrieving media key from Cloudflare response.';
        _MediaKeyLengthError: Label 'Media Key length exceeds maximum allowed length of %1 characters.';
        _LicenseExpired: Label 'The license has expired on %1.';
        _NoLicenseForSelector: Label 'No license found for bc cloudflare media.';
        _OverwriteExistingLicense: Label 'A license already exists for this media selector. Do you want to overwrite it?';
        _ConfirmDeleteLicense: Label 'Are you sure you want to delete the license? This action cannot be undone.';
        _InvalidLicense: Label 'The license is not valid.';
        _StorageKey: Label 'NPR_CF_MEDIA_LICENSE';

    // ***************************************
    #region internal facade methods
#pragma warning disable AA0150
    internal procedure PublicIdLookup(PublicId: Text[100]; var TableNumber: Integer; var SystemId: Guid): Boolean;
    begin
        exit(false); // Not implemented for MediaSelector NOOP
    end;
#pragma warning restore AA0150

    internal procedure Upload(MediaSelector: Enum "NPR CloudflareMediaSelector"; PublicId: Text[100]; ContentType: Text[100]; ImageBase64: Text; TimeToLive: integer; var MediaResponse: JsonObject): Boolean
    begin
        exit(UploadImageWorker(MediaSelector, PublicId, ContentType, ImageBase64, TimeToLive, MediaResponse));
    end;

    internal procedure StoreMediaLink(TableNumber: Integer; TableSystemId: Guid; PublicId: Text[100]; MediaSelector: Enum "NPR CloudflareMediaSelector"; MediaUploadResponse: JsonObject): Boolean
    var
        JsonToken: JsonToken;
    begin
        if (not MediaUploadResponse.Get('key', JsonToken)) then
            Error(_ErrorRetrievingMediaKey);

        exit(StoreMediaLinkWorker(TableNumber, TableSystemId, PublicId, MediaSelector, JsonToken.AsValue().AsText()));
    end;

    internal procedure GetMediaUrl(MediaKey: Text; Variant: Enum "NPR CloudflareMediaVariants"; TimeToLive: integer; var MediaResponse: JsonObject): Boolean
    begin
        exit(SignMediaUrlWorker(MediaKey, Variant, TimeToLive, 'bytes', MediaResponse));
    end;

    internal procedure GetMediaB64(MediaKey: Text; Variant: Enum "NPR CloudflareMediaVariants"; var MediaResponse: JsonObject): Boolean
    var
        GetMediaFailed: Label 'Get media failed: %1';
        JToken: JsonToken;
        ImageUrl: Text;
    begin
        if (not GetMediaB64Url(MediaKey, Variant, 60, MediaResponse)) then
            exit(false);

        if (not MediaResponse.Get('url', JToken)) then
            exit(false);

        ImageUrl := JToken.AsValue().AsText();

        Clear(MediaResponse);
        if (not (GetMedia(ImageUrl, MediaResponse))) then
            Error(GetMediaFailed, GetLastErrorText());

        exit(true);
    end;

    internal procedure GetMediaB64Url(MediaKey: Text; Variant: Enum "NPR CloudflareMediaVariants"; TimeToLive: integer; var MediaResponse: JsonObject): Boolean
    begin
        exit(SignMediaUrlWorker(MediaKey, Variant, TimeToLive, 'base64', MediaResponse));
    end;

    internal procedure Delete(MediaKey: Text): Boolean
    begin
        // TODO: Actual R2 deletion not implement at this time
        exit(true);
    end;
    # endregion



    // ***************************************
    #region implementation methods and workers

    [NonDebuggable]
    [TryFunction]
    local procedure UploadImageWorker(MediaSelector: Enum "NPR CloudflareMediaSelector"; PublicId: Text[100]; ContentType: Text[100]; ImageBase64: Text; TimeToLive: integer; var MediaResponse: JsonObject)
    var
        Client: HttpClient;
        Headers, ContentHeader : HttpHeaders;
        Content: HttpContent;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        ResponseBody: Text;
        RequestJson: JsonObject;
        RequestContentText: Text;
    begin

        RequestJson.Add('publicId', PublicId);
        RequestJson.Add('prefix', GetStrictPrefix(MediaSelector));
        RequestJson.Add('contentType', ContentType);
        RequestJson.Add('imageB64', ImageBase64);
        RequestJson.Add('ttl', TimeToLive);
        RequestJson.Add('wantUrl', true);
        RequestJson.WriteTo(RequestContentText);
        Content.WriteFrom(RequestContentText);

        Content.GetHeaders(ContentHeader);
        ContentHeader.Remove('Content-Type');
        ContentHeader.Add('Content-Type', 'application/json');

        Request.GetHeaders(Headers);
        Headers.Add('Accept', '*/*');

        Request.Method := 'POST';
        Request.SetRequestUri(StrSubstNo('%1/upload', GetCFWorkerBaseUrl()));
        Request.Content := Content;
        AddXApiKeyHeader(Request);

        Client.Send(Request, Response);
        if (not Response.IsSuccessStatusCode()) then
            if (Response.Content().ReadAs(ResponseBody)) then
                Error('Error uploading image to Cloudflare: %1 - %2 - %3', Response.HttpStatusCode, Response.ReasonPhrase, ResponseBody)
            else
                Error('Error uploading image to Cloudflare: %1 - %2', Response.HttpStatusCode, Response.ReasonPhrase);

        Response.Content().ReadAs(ResponseBody);
        MediaResponse.ReadFrom(ResponseBody);
    end;

#pragma warning disable AA0139
    local procedure StoreMediaLinkWorker(TableNumber: Integer; TableSystemId: Guid; PublicId: Text[100]; MediaSelector: Enum "NPR CloudflareMediaSelector"; MediaKey: Text) Ok: Boolean
    var
        MediaLink: Record "NPR CloudflareMediaLink";

    begin
        if (StrLen(MediaKey) > MaxStrLen(MediaLink.MediaKey)) then
            Error(_MediaKeyLengthError, MaxStrLen(MediaLink.MediaKey));

        if (MediaLink.Get(TableNumber, TableSystemId, MediaSelector)) then begin
            MediaLink.MediaKey := MediaKey;
            MediaLink.PublicId := PublicId;
            Ok := MediaLink.Modify();
            exit;
        end;

        MediaLink.Init();
        MediaLink.TableNumber := TableNumber;
        MediaLink.RecordId := TableSystemId;
        MediaLink.MediaSelector := MediaSelector;
        MediaLink.MediaKey := MediaKey;
        MediaLink.PublicId := PublicId;
        Ok := MediaLink.Insert();
    end;
#pragma warning restore AA0139

    [NonDebuggable]
    [TryFunction]
    local procedure SignMediaUrlWorker(MediaKey: Text; Variant: Enum "NPR CloudflareMediaVariants"; TimeToLive: integer; responseType: Text; var MediaResponse: JsonObject)
    var
        Client: HttpClient;
        Headers: HttpHeaders;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        ResponseBody: Text;
        TypeHelper: Codeunit "Type Helper";
        VariantAsText: Text;
    begin
        VariantAsText := Variant.Names.Get(Variant.Ordinals.IndexOf(Variant.AsInteger())).ToLower();

        // if bytes and license, self-sign the URL here and skip the call to the worker
        if (responseType = 'bytes') then
            if (GetSelfSignImgUrl(MediaKey, Variant, TimeToLive, MediaResponse)) then
                exit;

        Request.GetHeaders(Headers);
        Headers.Add('Accept', '*/*');

        Request.Method := 'GET';
        Request.SetRequestUri(StrSubstNo('%1/sign?key=%2&variant=%3&ttl=%4&response=%5', GetCFWorkerBaseUrl(), TypeHelper.UrlEncode(MediaKey), VariantAsText, Format(TimeToLive), responseType.ToLower()));
        AddXApiKeyHeader(Request);

        Client.Send(Request, Response);
        if (not Response.IsSuccessStatusCode()) then
            if (Response.Content().ReadAs(ResponseBody)) then
                Error('Error signing image url from Cloudflare: %1 - %2 - %3', Response.HttpStatusCode, Response.ReasonPhrase, ResponseBody)
            else
                Error('Error signing image url from Cloudflare: %1 - %2', Response.HttpStatusCode, Response.ReasonPhrase);

        Response.Content().ReadAs(ResponseBody);
        MediaResponse.ReadFrom(ResponseBody);
    end;

    [NonDebuggable]
    local procedure UrlEncode(Input: Text): Text
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        exit(TypeHelper.UrlEncode(Input));
    end;

    [NonDebuggable]
    local procedure GetSelfSignImgUrl(MediaKey: Text; Variant: Enum "NPR CloudflareMediaVariants"; TimeToLive: integer; var MediaResponse: JsonObject): Boolean
    var
        ExpirationDate: DateTime;
        ToSign, ImgUrl, Signature, SignedUrl : Text;
        Exp, Kid, Secret : Text;
        Cryptography: Codeunit "Cryptography Management";
        HashAlgorithmType: Option MD5,SHA1,SHA256,SHA384,SHA512;
    begin
        if (not GetSecret(ExpirationDate, Kid, Secret)) then
            exit(false); // no license, fall back to worker signing

        if (CurrentDateTime() > ExpirationDate) then
            exit(false); // fall back to worker signing

        Exp := Format(Round((GetUTCDateTime() - CreateDateTime(DMY2Date(1, 1, 1970), 0T)) / 1000 + TimeToLive, 1), 0, 9);  // Unix epoch time in seconds (UTC)
        ImgUrl := StrSubstNo('/img/%1?variant=%2&response=bytes&kid=%3&exp=%4', UrlEncode(MediaKey), Variant.Names.Get(Variant.Ordinals.IndexOf(Variant.AsInteger())).ToLower(), Kid, Exp);
        ToSign := StrSubstNo('GET|%1|%2|%3|%4', MediaKey, Variant.Names.Get(Variant.Ordinals.IndexOf(Variant.AsInteger())).ToLower(), Kid, Exp);
        Signature := Cryptography.GenerateHashAsBase64String(ToSign, Secret, HashAlgorithmType::SHA256).Replace('+', '-').Replace('/', '_').Replace('=', '');
        SignedUrl := StrSubstNo('%1%2&sig=%3', GetCFWorkerBaseUrl(), ImgUrl, Signature);

        MediaResponse.Add('url', SignedUrl);
        exit(true);
    end;

#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
    local procedure GetUTCDateTime(): DateTime
    var
        TypeHelper: Codeunit "Type Helper";
        DateString: Text;
        UtcDate: Date;
        UtcTime: Time;
    begin
        // yyyy-MM-ddTHH:mm:ssZ
        DateString := TypeHelper.GetCurrUTCDateTimeISO8601();
        Evaluate(UtcDate, (CopyStr(DateString, 1, 10)), 9);
        Evaluate(UtcTime, (CopyStr(DateString, 12, 8)), 9);
        exit(CreateDateTime(UtcDate, UtcTime));
    end;
#else
    local procedure GetUTCDateTime(): DateTime
    begin
        exit(CurrentDateTime() + 12 * 3600 * 1000); // BC17-22 does not have GetCurrUTCDateTime, so we add 12 hours to approximate worst case UTC time offset
    end;
#endif

    [NonDebuggable]
    [TryFunction]
    local procedure GetMedia(ImageUrl: Text; var MediaResponse: JsonObject)
    var
        Client: HttpClient;
        Headers: HttpHeaders;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        ResponseBody: Text;
    begin

        // Depending on the URL type requested (base64 or bytes) we may need to add different headers
        // For now, we just accept JSON, not the actual image bytes
        Request.GetHeaders(Headers);
        Headers.Add('Accept', 'application/json');

        // No authentication headers needed as this endpoint is public and the URL is time-limited and will expire after the TTL set during upload/signing
        Request.Method := 'GET';
        Request.SetRequestUri(ImageUrl);

        Client.Send(Request, Response);
        if (not Response.IsSuccessStatusCode()) then
            if (Response.Content().ReadAs(ResponseBody)) then
                Error('Error getting image data from Cloudflare: %1 - %2 - %3', Response.HttpStatusCode, Response.ReasonPhrase, ResponseBody)
            else
                Error('Error getting image data from Cloudflare: %1 - %2', Response.HttpStatusCode, Response.ReasonPhrase);

        Response.Content().ReadAs(ResponseBody);
        MediaResponse.ReadFrom(ResponseBody);
    end;
    #endregion


    #region Helper Functions
    local procedure RemoveInvalidURLCharacters(Input: Text): Text
    begin
        exit(DelChr(Input, '=', '<>#%&\/?^'''));
    end;

    local procedure GetStrictPrefix(MediaSelector: Enum "NPR CloudflareMediaSelector") Prefix: Text
    var
        AzureADTenant: Codeunit "Azure AD Tenant";
        EnvironmentInformation: Codeunit "Environment Information";
        EnvironmentName: Text;
        ThisCompanyName: Text;
        ContainerName: Text;
        WebUrl: Text;
        MediaSelectorName: Text;
    begin
        EnvironmentName := EnvironmentInformation.GetEnvironmentName();
        ThisCompanyName := RemoveInvalidURLCharacters(CompanyName());
        WebUrl := GetUrl(ClientType::Web);
        MediaSelectorName := MediaSelector.Names.Get(MediaSelector.Ordinals.IndexOf(MediaSelector.AsInteger())).ToLower();

        if (WebUrl.Contains('dynamics-retail.net')) then begin
            //Crane
            // https://np648693.hetzner.dynamics-retail.net/
            if (WebUrl.StartsWith('https://')) then
                ContainerName := WebUrl.Substring(StrLen('https://') + 1, StrPos(WebUrl.Substring(StrLen('https://')), '.') - 1);

            if (ContainerName = '') then
                Error('URL must start with "https://". Got "%1".', WebUrl);

            Prefix := StrSubstNo('%1/%2/%3/%4', ContainerName, MediaSelectorName, 'BC', ThisCompanyName);
        end else begin
            Prefix := StrSubstNo('%1/%2/%3/%4', AzureADTenant.GetAadTenantId(), MediaSelectorName, EnvironmentName, ThisCompanyName);
        end;
    end;

    [NonDebuggable]
    local procedure AddXApiKeyHeader(var Request: HttpRequestMessage)
    var
        Headers: HttpHeaders;
    begin
        Request.GetHeaders(Headers);
        Headers.Add('x-api-key', GetApiKey());
    end;

    [NonDebuggable]
    local procedure GetCFWorkerBaseUrl() WorkerBaseUrl: Text
    begin
        // Ensure no trailing slash
        if (IsProduction()) then
            WorkerBaseUrl := 'https://bc-media.npretail.app';

        if (IsSandbox()) then
            WorkerBaseUrl := 'https://bc-media-sandbox.npretail.app';

        if (IsCrane()) then
            WorkerBaseUrl := 'https://bc-media-crane.npretail.app';

#if CF_MEDIA_PRELIVE
        WorkerBaseUrl := 'https://bc-media-prelive.navipartner-prelive.workers.dev';
#endif
    end;

    local procedure IsProduction(): Boolean
    var
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        if (EnvironmentInformation.IsSaaS()) then
            exit(EnvironmentInformation.IsProduction());
    end;

    local procedure IsSandbox(): Boolean
    var
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        if (EnvironmentInformation.IsSaaS()) then
            exit(EnvironmentInformation.IsSandbox());
    end;

    local procedure IsCrane(): Boolean
    var
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        if (not EnvironmentInformation.IsSaaS()) then
            exit(true);
    end;
    #endregion



    #region Cloudflare Migration Job Management

    internal procedure LoadJobLineArray() JArray: JsonArray
    var
        FileName: Text;
        IStr: InStream;
        DotNetStreamReader: Codeunit DotNet_StreamReader;
        DotNetEncoding: Codeunit DotNet_Encoding;
    begin
        if not UploadIntoStream('Select .json-file', '', 'Json File|*.json', FileName, IStr) then
            exit;

        DotNetEncoding.UTF8();
        DotNetStreamReader.StreamReader(IStr, DotNetEncoding);
        JArray.ReadFrom(DotNetStreamReader.ReadToEnd());
    end;

    internal procedure CreateJobForLineArray(MediaSelector: Enum "NPR CloudflareMediaSelector"; BatchId: Guid; JArray: JsonArray): Guid;
    var
        JObject: JsonObject;
        JToken: JsonToken;
        Job: Record "NPR CloudflareMigrationJob";
        JobLine: Record "NPR CloudflareMigrationJobLine";
    begin
        Job.JobId := CreateGuid();
        Job.MediaSelector := MediaSelector;
        Job.BatchId := BatchId;
        Job.Insert();

        // Parsing issues throw hard errors
        foreach JToken in JArray do begin
            if (JToken.IsObject()) then begin
                JObject := JToken.AsObject();

                JobLine.Init();
                JobLine.JobId := Job.JobId;

                JObject.Get('public_id', JToken);
                JobLine.PublicId := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(JobLine.PublicId));

                JObject.Get('url', JToken);
                JobLine.ImageUrl := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(JobLine.ImageUrl));

                JobLine.Status := JobLine.Status::Pending;
                JobLine.Insert();
            end;
        end;

        exit(Job.JobId);
    end;

    internal procedure StartMigration(JobId: Guid; var JobResponse: JsonObject): Boolean
    var
        PayLoad: JsonObject;
    begin
        PayLoad := CreateMigrationPayload(JobId);
        exit(UploadJob(PayLoad, JobResponse));
    end;

    internal procedure FinalizeMigration(JobId: Guid): Boolean
    var
        Job: Record "NPR CloudflareMigrationJob";
        JobLine, JobLine2 : Record "NPR CloudflareMigrationJobLine";
        Interface: Interface "NPR CloudflareMigrationInterface";
        TableNumber: Integer;
        SystemId: Guid;
    begin
        if (not Job.Get(JobId)) then
            Error(_JobNotFoundError);

        ClearLastError();
        Interface := Job.MediaSelector;

        JobLine.SetFilter(JobId, '=%1', JobId);
        JobLine.SetFilter(Status, '%1', JobLine.Status::SUCCESS);
        if (JobLine.FindSet()) then
            repeat
                TableNumber := 0;
                Clear(SystemId);

                if (Interface.PublicIdLookup(JobLine.PublicId, TableNumber, SystemId)) then begin
                    if (StoreMediaLinkWorker(TableNumber, SystemId, JobLine.PublicId, Job.MediaSelector, JobLine.MediaKey)) then begin
                        JobLine2.Get(JobLine.JobId, JobLine.PublicId);
                        JobLine2.Status := JobLine.Status::FINALIZED;
                        JobLine2.Modify();
                    end;
                end;
            until (JobLine.Next() = 0);

        exit(true);
    end;

    local procedure CreateMigrationPayload(JobId: Guid) JobObject: JsonObject
    var
        ImagesArray: JsonArray;
        ImageObject: JsonObject;
        Job: Record "NPR CloudflareMigrationJob";
        JobLine: Record "NPR CloudflareMigrationJobLine";
    begin
        if (not Job.Get(JobId)) then
            Error(_JobNotFoundError);

        JobLine.SetFilter(JobLine.JobId, '=%1', JobId);
        JobLine.SetFilter(Status, '%1', JobLine.Status::Pending);
        if (not JobLine.FindSet()) then
            Error('No job lines found for this job.');

        repeat
            Clear(ImageObject);
            ImageObject.Add('public_id', JobLine.PublicId);
            ImageObject.Add('url', JobLine.ImageUrl);
            ImagesArray.Add(ImageObject);

            JobLine.Status := JobLine.Status::Queued;
            JobLine.Modify();
        until (JobLine.Next() = 0);

        Job.EnqueuedCount := ImagesArray.Count();
        Job.Modify();

        JobObject.Add('job_id', Format(Job.JobId, 0, 4).ToLower());
        JobObject.Add('prefix', GetStrictPrefix(Job.MediaSelector));
        JobObject.Add('rate_limit', Job.RateLimitPerSecond);
        JobObject.Add('images', ImagesArray);
    end;

    [NonDebuggable]
    [TryFunction]
    local procedure UploadJob(Payload: JsonObject; var JobResponse: JsonObject)
    var
        Client: HttpClient;
        Headers, ContentHeader : HttpHeaders;
        Content: HttpContent;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        ResponseBody: Text;
        PayloadText: Text;
    begin
        Payload.WriteTo(PayloadText);
        Content.WriteFrom(PayloadText);

        Content.GetHeaders(ContentHeader);
        ContentHeader.Remove('Content-Type');
        ContentHeader.Add('Content-Type', 'application/json');

        Request.GetHeaders(Headers);
        Headers.Add('Accept', '*/*');

        Request.Method := 'POST';
        Request.SetRequestUri(StrSubstNo('%1/jobs', GetCFWorkerBaseUrl()));
        Request.Content := Content;
        AddXApiKeyHeader(Request);

        Client.Send(Request, Response);
        if (not Response.IsSuccessStatusCode()) then
            if (Response.Content().ReadAs(ResponseBody)) then
                Error('Error uploading migration job to Cloudflare: %1 - %2 - %3', Response.HttpStatusCode, Response.ReasonPhrase, ResponseBody)
            else
                Error('Error uploading migration job to Cloudflare: %1 - %2', Response.HttpStatusCode, Response.ReasonPhrase);

        Response.Content().ReadAs(ResponseBody);
        JobResponse.ReadFrom(ResponseBody);
    end;

    internal procedure GetJobStatus(JobId: Guid; var JobStatusResponse: JsonObject): Boolean
    var
        Job: Record "NPR CloudflareMigrationJob";
    begin
        if (not Job.Get(JobId)) then
            Error(_JobNotFoundError);

        if (not GetJobStatusWorker(JobId, JobStatusResponse)) then
            exit(false);

        UpdateJob(JobId, JobStatusResponse);
        exit(true);
    end;

    internal procedure CancelMigration(JobId: Guid; var JobStatusResponse: JsonObject): Boolean
    var
        Job: Record "NPR CloudflareMigrationJob";
    begin
        if (not Job.Get(JobId)) then
            Error(_JobNotFoundError);

        if (not CancelJobWorker(JobId, JobStatusResponse)) then
            exit(false);

        UpdateJob(JobId, JobStatusResponse);
        exit(true);
    end;

    internal procedure GetJobResults(JobId: Guid; var JobResultsResponse: JsonObject): Boolean
    var
        Job: Record "NPR CloudflareMigrationJob";
        JToken: JsonToken;
        NextCursorObject: JsonObject;
        JobStatusResponse: JsonObject;
    begin
        if (not Job.Get(JobId)) then
            Error(_JobNotFoundError);

        if (not GetJobStatusWorker(JobId, JobStatusResponse)) then
            exit(false);
        UpdateJob(JobId, JobStatusResponse);

        if (not GetJobResultWorker(JobId, Job.LimitFetchCount, Job.NextCursorAfterTs, Job.NextCursorAfterRowId, JobResultsResponse)) then
            exit(false);
        UpdateJobLines(JobId, JobResultsResponse);

        Job.Get(JobId);
        Job.NextCursorAfterRowId := 0;
        Job.NextCursorAfterTs := 0;
        if (JobResultsResponse.Get('nextCursor', JToken)) then begin
            if (JToken.IsObject()) then begin
                NextCursorObject := JToken.AsObject();
                NextCursorObject.Get('afterTs', JToken);
                Job.NextCursorAfterTs := JToken.AsValue().AsBigInteger();
                NextCursorObject.Get('afterRowid', JToken);
                Job.NextCursorAfterRowId := JToken.AsValue().AsBigInteger();
            end;
        end;

        GetJobLineSummary(JobId, Job.TotalCount, Job.SuccessCount, Job.FailedCount, Job.EnqueuedCount);
        Job.Modify();

        exit(true);
    end;

    local procedure UpdateJob(JobId: Guid; JobStatusResponse: JsonObject)
    var
        Job: Record "NPR CloudflareMigrationJob";
        JsonToken: JsonToken;
    begin
        Job.Get(JobId);

        if (JobStatusResponse.Get('total_count', JsonToken)) then
            Job.TotalCount := JsonToken.AsValue().AsInteger();
        if (JobStatusResponse.Get('success_count', JsonToken)) then
            Job.SuccessCount := JsonToken.AsValue().AsInteger();
        if (JobStatusResponse.Get('failed_count', JsonToken)) then
            Job.FailedCount := JsonToken.AsValue().AsInteger();
        if (JobStatusResponse.Get('job_cancel', JsonToken)) then
            Job.JobCancelled := (JsonToken.AsValue().AsInteger() <> 0);

        Job.Modify();
    end;

    local procedure UpdateJobLines(JobId: Guid; var JobResultsResponse: JsonObject)
    var
        JobLine: Record "NPR CloudflareMigrationJobLine";
        JToken, ItemsToken : JsonToken;
        ItemsArray: JsonArray;
        ItemObject: JsonObject;
        PublicId: Text;
    begin

        if (not JobResultsResponse.Get('items', ItemsToken)) then
            Error('Missing items in results from Cloudflare.');

        if (not ItemsToken.IsArray()) then
            Error('Invalid items in results from Cloudflare.');

        ItemsArray := ItemsToken.AsArray();
        foreach JToken in ItemsArray do begin

            if (JToken.IsObject()) then begin
                ItemObject := JToken.AsObject();

                if (ItemObject.Get('job_id', JToken)) then
                    if (not (format(JobId, 0, 4).ToLower() = JToken.AsValue().AsText().ToLower())) then
                        Error('Mismatched JobId in results from Cloudflare.');

                if (not ItemObject.Get('public_id', JToken)) then
                    Error('Missing public_id in results from Cloudflare.');

                if (JToken.AsValue().IsNull()) then
                    Error('Null public_id in results from Cloudflare.');

                PublicId := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(JobLine.PublicId));
                if (JobLine.Get(JobId, PublicId)) then begin

                    JobLine.Status := JobLine.Status::Failed;
                    if (ItemObject.Get('job_status', JToken)) then
                        if (not JToken.AsValue().IsNull()) then
                            if (JToken.AsValue().AsText().ToLower() = 'ok') then
                                JobLine.Status := JobLine.Status::Success;

                    if (ItemObject.Get('image_key', JToken)) then
                        if (not JToken.AsValue().IsNull()) then
                            JobLine.MediaKey := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(JobLine.MediaKey));

                    if (ItemObject.Get('reason', JToken)) then
                        if (not JToken.AsValue().IsNull()) then
                            JobLine.Reason := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(JobLine.Reason));

                    if (ItemObject.Get('bytes', JToken)) then
                        if (not JToken.AsValue().IsNull()) then
                            JobLine.FileSize := JToken.AsValue().AsInteger();

                    if (ItemObject.Get('content_type', JToken)) then
                        if (not JToken.AsValue().IsNull()) then
                            JobLine.ContentType := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(JobLine.ContentType));

                    JobLine.Modify();
                end;
            end;
        end;
    end;

    local procedure GetJobLineSummary(JobId: Guid; var TotalCount: Integer; var SuccessCount: Integer; var FailedCount: Integer; var QueuedCount: Integer)
    var
        JobLine: Record "NPR CloudflareMigrationJobLine";
    begin
        TotalCount := 0;
        SuccessCount := 0;
        FailedCount := 0;
        QueuedCount := 0;

        JobLine.SetFilter(JobLine.JobId, '=%1', JobId);
        if (not JobLine.FindSet()) then
            exit;

        repeat
            // Queued and Pending are not counted
            TotalCount += 1;
            if (JobLine.Status in [JobLine.Status::SUCCESS, JobLine.Status::FINALIZED]) then
                SuccessCount += 1;
            if (JobLine.Status = JobLine.Status::FAILED) then
                FailedCount += 1;
            if (JobLine.Status = JobLine.Status::QUEUED) then
                QueuedCount += 1;
        until (JobLine.Next() = 0);
    end;

    [NonDebuggable]
    [TryFunction]
    local procedure GetJobStatusWorker(JobId: Guid; var JobStatusResponse: JsonObject)
    var
        Client: HttpClient;
        Headers, ContentHeader : HttpHeaders;
        Content: HttpContent;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        ResponseBody: Text;
    begin
        Content.GetHeaders(ContentHeader);
        ContentHeader.Remove('Content-Type');
        ContentHeader.Add('Content-Type', 'application/json');

        Request.GetHeaders(Headers);
        Headers.Add('Accept', '*/*');

        Request.Method := 'GET';
        Request.SetRequestUri(StrSubstNo('%1/jobs/%2/status', GetCFWorkerBaseUrl(), Format(JobId, 0, 4).ToLower()));
        Request.Content := Content;
        AddXApiKeyHeader(Request);

        Client.Send(Request, Response);
        if (not Response.IsSuccessStatusCode()) then
            if (Response.Content().ReadAs(ResponseBody)) then
                Error('Error getting migration job status from Cloudflare: %1 - %2 - %3', Response.HttpStatusCode, Response.ReasonPhrase, ResponseBody)
            else
                Error('Error getting migration job status from Cloudflare: %1 - %2', Response.HttpStatusCode, Response.ReasonPhrase);

        Response.Content().ReadAs(ResponseBody);
        JobStatusResponse.ReadFrom(ResponseBody);
    end;

    [NonDebuggable]
    [TryFunction]
    local procedure GetJobResultWorker(JobId: Guid; Limit: Integer; AfterTs: BigInteger; AfterRowId: BigInteger; var JobResultResponse: JsonObject)
    var
        Client: HttpClient;
        Headers, ContentHeader : HttpHeaders;
        Content: HttpContent;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        ResponseBody: Text;
    begin
        Content.GetHeaders(ContentHeader);
        ContentHeader.Remove('Content-Type');
        ContentHeader.Add('Content-Type', 'application/json');

        Request.GetHeaders(Headers);
        Headers.Add('Accept', '*/*');

        Request.Method := 'GET';
        Request.SetRequestUri(StrSubstNo('%1/jobs/%2?limit=%3&afterTs=%4&afterRowid=%5', GetCFWorkerBaseUrl(), Format(JobId, 0, 4).ToLower(), Format(Limit, 0, 9), Format(AfterTs, 0, 9), Format(AfterRowId, 0, 9)));
        Request.Content := Content;
        AddXApiKeyHeader(Request);

        Client.Send(Request, Response);
        if (not Response.IsSuccessStatusCode()) then
            if (Response.Content().ReadAs(ResponseBody)) then
                Error('Error getting migration job result from Cloudflare: %1 - %2 - %3', Response.HttpStatusCode, Response.ReasonPhrase, ResponseBody)
            else
                Error('Error getting migration job result from Cloudflare: %1 - %2', Response.HttpStatusCode, Response.ReasonPhrase);

        Response.Content().ReadAs(ResponseBody);
        JobResultResponse.ReadFrom(ResponseBody);
    end;


    [NonDebuggable]
    [TryFunction]
    local procedure CancelJobWorker(JobId: Guid; var JobStatusResponse: JsonObject)
    var
        Client: HttpClient;
        Headers, ContentHeader : HttpHeaders;
        Content: HttpContent;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        ResponseBody: Text;
    begin
        Content.GetHeaders(ContentHeader);
        ContentHeader.Remove('Content-Type');
        ContentHeader.Add('Content-Type', 'application/json');

        Request.GetHeaders(Headers);
        Headers.Add('Accept', '*/*');
        Request.Method := 'PUT';
        Request.SetRequestUri(StrSubstNo('%1/jobs/%2/cancel', GetCFWorkerBaseUrl(), Format(JobId, 0, 4).ToLower()));
        Request.Content := Content;
        AddXApiKeyHeader(Request);

        Client.Send(Request, Response);
        if (not Response.IsSuccessStatusCode()) then
            if (Response.Content().ReadAs(ResponseBody)) then
                Error('Error cancelling migration job in Cloudflare: %1 - %2 - %3', Response.HttpStatusCode, Response.ReasonPhrase, ResponseBody)
            else
                Error('Error cancelling migration job in Cloudflare: %1 - %2', Response.HttpStatusCode, Response.ReasonPhrase);

        Response.Content().ReadAs(ResponseBody);
        JobStatusResponse.ReadFrom(ResponseBody);
    end;

    #endregion

    # region License Management
    [NonDebuggable]
    internal procedure AddLicense(LicenseB64: Text): Boolean
    begin
        ClearLastError();

        if (not CheckLicenseSchema(LicenseB64ToJson(LicenseB64))) then
            Error(_InvalidLicense);

        if (IsolatedStorage.Contains(_StorageKey, DataScope::Company)) then begin
            if (not Confirm(_OverwriteExistingLicense, false)) then
                exit(false);
            IsolatedStorage.Delete(_StorageKey, DataScope::Company);
        end;

        IsolatedStorage.Set(_StorageKey, LicenseB64, DataScope::Company);
        Commit();

        exit(true);
    end;

    [NonDebuggable]
    internal procedure RemoveLicense(): Boolean
    begin
        ClearLastError();

        if (IsolatedStorage.Contains(_StorageKey, DataScope::Company)) then
            if (not Confirm(_ConfirmDeleteLicense, true)) then
                exit(false);

        exit(IsolatedStorage.Delete(_StorageKey, DataScope::Company));
    end;

    [NonDebuggable]
    [TryFunction]
    internal procedure GetLicenseInfo(var licenseId: Text; var ExpirationDate: DateTime);
    var
        LicenseJson: JsonObject;
        JToken: JsonToken;
    begin
        ClearLastError();
        LicenseJson := GetLicense();

        LicenseJson.Get('kid', JToken);
        licenseId := JToken.AsValue().AsText();

        LicenseJson.Get('exp', JToken);
        ExpirationDate := CreateDateTime(DMY2Date(1, 1, 1970), 0T) + JToken.AsValue().AsBigInteger() * 1000;
    end;

    [NonDebuggable]
    local procedure GetApiKey(): Text
    var
        LicenseJson: JsonObject;
        JToken: JsonToken;
        ExpirationDate: DateTime;
    begin
        ClearLastError();
        LicenseJson := GetLicense();

        LicenseJson.Get('exp', JToken);
        ExpirationDate := CreateDateTime(DMY2Date(1, 1, 1970), 0T) + JToken.AsValue().AsBigInteger() * 1000;

        if (ExpirationDate < CurrentDateTime()) then
            Error(_LicenseExpired, ExpirationDate);

        LicenseJson.Get('key', JToken);
        exit(JToken.AsValue().AsText());
    end;

    // [NonDebuggable]
    [TryFunction]
    local procedure GetSecret(var ExpirationDate: DateTime; var kid: Text; var sig: Text)
    var
        LicenseJson: JsonObject;
        JToken: JsonToken;
    begin
        ClearLastError();
        LicenseJson := GetLicense();

        ExpirationDate := 0DT;
        if (LicenseJson.Get('exp', JToken)) then begin
            // exp is in seconds since epoch
            ExpirationDate := CreateDateTime(DMY2Date(1, 1, 1970), 0T) + JToken.AsValue().AsBigInteger() * 1000;
        end;

        if (ExpirationDate < CurrentDateTime()) then
            Error(_LicenseExpired, ExpirationDate);

        LicenseJson.Get('kid', JToken);
        kid := JToken.AsValue().AsText();

        LicenseJson.Get('sig', JToken);
        sig := JToken.AsValue().AsText();
    end;

    [NonDebuggable]
    local procedure GetLicense(): JsonObject
    var
        LicenseB64: Text;
    begin
        if (not IsolatedStorage.Get(_StorageKey, DataScope::Company, LicenseB64)) then
            Error(_NoLicenseForSelector);

        if (LicenseB64 = '') then
            Error(_NoLicenseForSelector);

        exit(LicenseB64ToJson(LicenseB64));
    end;

    [NonDebuggable]
    local procedure LicenseB64ToJson(LicenseB64: Text) LicenseJson: JsonObject
    var
        Base64Convert: Codeunit "Base64 Convert";
        t1: Text;
    begin
        t1 := LicenseB64.Split('.').Get(1);
        if (StrLen(t1) mod 4) <> 0 then
            t1 := t1.PadRight(StrLen(t1) + ((4 - (StrLen(t1) mod 4)) mod 4), '=');
        LicenseJson.ReadFrom(Base64Convert.FromBase64(t1));
    end;

    [NonDebuggable]
    local procedure CheckLicenseSchema(LicenseJson: JsonObject): Boolean
    var
        JToken: JsonToken;
    begin
        LicenseJson.Get('ver', JToken);
        if (JToken.AsValue().AsInteger() <> 1) then
            exit(false);

        // Version 1 requires kid, exp, tid, key, sig
        if (not LicenseJson.Get('kid', JToken)) then
            exit(false);
        if (JToken.AsValue().AsText() = '') then
            exit(false);

        if (not LicenseJson.Get('exp', JToken)) then
            exit(false);
        if (JToken.AsValue().AsBigInteger() = 0) then
            exit(false);

        if (not LicenseJson.Get('tid', JToken)) then
            exit(false);
        if (JToken.AsValue().AsText() = '') then
            exit(false);
        if (not GetStrictPrefix(Enum::"NPR CloudflareMediaSelector"::NOOP).ToLower().StartsWith(JToken.AsValue().AsText().ToLower())) then // only check that tid is a prefix of the strict prefix. MediaSelector is not relevant here
            exit(false);

        if (not LicenseJson.Get('key', JToken)) then
            exit(false);
        if (JToken.AsValue().AsText() = '') then
            exit(false);

        if (not LicenseJson.Get('sig', JToken)) then
            exit(false);
        if (JToken.AsValue().AsText() = '') then
            exit(false);

        exit(true);
    end;

    #endregion
}