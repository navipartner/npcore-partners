/// <summary>
/// Codeunit that provides a facade for interacting with Cloudflare Media services.
/// This codeunit allows uploading images, storing and retrieving media keys, and generating media URLs.
/// </summary>
codeunit 6248556 "NPR CloudflareMediaFacade"
{

    Access = Public;

    #region License Management
    /// <summary>
    /// Adds a license for a specific media selector.
    /// </summary>
    /// <param name="LicenseB64">The base64-encoded license string.</param>
    /// <returns>True if the license was successfully added; otherwise, false.</returns>
    procedure AddLicense(LicenseB64: Text): Boolean
    var
        MediaImpl: Codeunit "NPR CloudflareMediaImpl";
    begin
        exit(MediaImpl.AddLicense(LicenseB64));
    end;

    /// <summary>
    /// Removes the license for a specific media selector.
    /// </summary>
    /// <returns>True if the license was successfully removed; otherwise, false.</returns>
    procedure RemoveLicense(): Boolean
    var
        MediaImpl: Codeunit "NPR CloudflareMediaImpl";
    begin
        exit(MediaImpl.RemoveLicense());
    end;

    /// <summary>
    /// Retrieves license information for a specific media selector.    
    /// </summary>
    /// <param name="MediaSelector">Specifies the type of media.</param>
    /// <param name="LicenseId">The Key ID (kid) of the license.</param>
    /// <param name="ExpiryDateTime">The expiration date and time of the license.</param>
    /// <returns>True if the license information was successfully retrieved; otherwise, false.</returns>
    procedure GetLicenseInfo(var LicenseId: Text; var ExpiryDateTime: DateTime): Boolean
    var
        MediaImpl: Codeunit "NPR CloudflareMediaImpl";
    begin
        exit(MediaImpl.GetLicenseInfo(LicenseId, ExpiryDateTime));
    end;
    #endregion

    #region Operations
    /// <summary>
    /// Uploads an image to Cloudflare Media.
    /// </summary>
    /// <param name="MediaSelector">Specifies the type of media being uploaded.</param>
    /// <param name="PublicId">The public identifier for the media.</param>
    /// <param name="ContentType">The content type of the media (e.g., "image/png").</param>
    /// <param name="ImageBase64">The base64-encoded string of the image content.</param>
    /// <param name="TimeToLive">The time-to-live (TTL) for the media in seconds.</param>
    /// <param name="Media">The resulting JSON object containing the upload response.</param>
    /// <returns>True if the upload was successful; otherwise, false.</returns>
    procedure Upload(MediaSelector: Enum "NPR CloudflareMediaSelector"; PublicId: Text[100]; ContentType: Text[100]; ImageBase64: Text; TimeToLive: integer; var Media: JsonObject): Boolean
    var
        MediaImpl: Codeunit "NPR CloudflareMediaImpl";
    begin
        if (not MediaImpl.Upload(MediaSelector, PublicId, ContentType, ImageBase64, TimeToLive, Media)) then
            exit(false);

        exit(StoreMediaKey(MediaSelector, PublicId, Media));

    end;

    /// <summary>
    /// Stores the media key for a specific record in the database, linking it to the Cloudflare media item.
    /// </summary>
    /// <param name="TableNumber">The table number record is stored in.</param>
    /// <param name="TableSystemId">The GUID of the record.</param>
    /// <param name="PublicId">The public identifier for the media. e.g., the item number</param>
    /// <param name="MediaSelector">Specifies the type of media - e.g., member photo, item image, etc.</param>
    /// <param name="MediaUploadResponse">The JSON object containing the upload response from Cloudflare.</param>
    procedure StoreMediaKey(TableNumber: Integer; TableSystemId: Guid; PublicId: Text[100]; MediaSelector: Enum "NPR CloudflareMediaSelector"; MediaUploadResponse: JsonObject)
    var
        MediaImpl: Codeunit "NPR CloudflareMediaImpl";
    begin
        MediaImpl.StoreMediaLink(TableNumber, TableSystemId, PublicId, MediaSelector, MediaUploadResponse);
    end;

    /// <summary>
    /// Stores the media key for a specific record in the database, linking it to the Cloudflare media item.
    /// </summary>
    /// <param name="PublicId">The public identifier for the media. e.g., the item number</param>
    /// <param name="MediaSelector">Specifies the type of media - e.g., member photo, item image, etc.</param>
    /// <param name="MediaUploadResponse">The JSON object containing the upload response from Cloudflare.</param>
    procedure StoreMediaKey(MediaSelector: Enum "NPR CloudflareMediaSelector"; PublicId: Text[100]; MediaUploadResponse: JsonObject): Boolean
    var
        MediaImpl: Codeunit "NPR CloudflareMediaImpl";
        TableNumber: Integer;
        TableSystemId: Guid;
        Interface: Interface "NPR CloudflareMigrationInterface";
    begin
        Interface := MediaSelector;
        if (not Interface.PublicIdLookup(PublicId, TableNumber, TableSystemId)) then
            exit(false);

        exit(MediaImpl.StoreMediaLink(TableNumber, TableSystemId, PublicId, MediaSelector, MediaUploadResponse));
    end;

    /// <summary>
    /// Retrieves the media key for a specific record.
    /// </summary>
    /// <param name="TableNumber">The table number of the record.</param>
    /// <param name="TableSystemId">The GUID of the record.</param>
    /// <param name="MediaSelector">Specifies the type of media we are retrieving the key for.</param>
    /// <param name="MediaKey">The media key retrieved from the database.</param>
    /// <returns>True if the media key was found; otherwise, false.</returns>
    procedure GetMediaKey(TableNumber: Integer; TableSystemId: Guid; MediaSelector: Enum "NPR CloudflareMediaSelector"; var MediaSystemId: guid; var MediaKey: Text): Boolean
    var
        MediaLink: Record "NPR CloudflareMediaLink";
    begin
        if (not MediaLink.Get(TableNumber, TableSystemId, MediaSelector)) then
            exit(false);

        MediaSystemId := MediaLink.SystemId;
        MediaKey := MediaLink.MediaKey;
        exit(true);
    end;


    /// <summary>
    /// Generates a URL for accessing a media item in Cloudflare.
    /// </summary>
    /// <param name="MediaKey">The media key of the item.</param>
    /// <param name="MediaVariant">Specifies the variant of the media (e.g., resolution or format).</param>
    /// <param name="TimeToLive">The time-to-live (TTL) for the URL in seconds.</param>
    /// <param name="Media">The resulting JSON object containing the media URL.</param>
    /// <returns>True if the URL generation was successful; otherwise, false.</returns>
    procedure GetMediaUrl(MediaKey: Text; MediaVariant: Enum "NPR CloudflareMediaVariants"; TimeToLive: integer; var Media: JsonObject): Boolean
    var
        MediaImpl: Codeunit "NPR CloudflareMediaImpl";
    begin
        exit(MediaImpl.GetMediaUrl(MediaKey, MediaVariant, TimeToLive, Media));
    end;

    /// <summary>
    /// Generates an inlined base64-encoded string for media stored in Cloudflare.
    /// </summary>
    /// <param name="MediaSelector">Specifies the type of media.</param>
    /// <param name="MediaKey">The media key of the item.</param>
    /// <param name="MediaVariant">Specifies the variant of the media (e.g., resolution or format).</param>
    /// <param name="Media">The resulting JSON object containing the base64 encoded media.</param>
    /// <returns>True if the URL generation was successful; otherwise, false.</returns>
    procedure GetMediaB64(MediaSelector: Enum "NPR CloudflareMediaSelector"; MediaKey: Text; MediaVariant: Enum "NPR CloudflareMediaVariants"; var Media: JsonObject): Boolean
    var
        MediaImpl: Codeunit "NPR CloudflareMediaImpl";
    begin
        exit(MediaImpl.GetMediaB64(MediaKey, MediaVariant, Media));
    end;


    /// <summary>
    /// Deletes a media item from Cloudflare Media bucket and all associated links from the database.
    /// </summary>
    /// <param name="MediaSelector">Specifies the type of media.</param>
    /// <param name="MediaKey">The media key of the item to be deleted.</param>
    /// <returns>True if the deletion was successful; otherwise, false.</returns>
    /// <remarks>This function is not yet implemented.</remarks>
    procedure Delete(MediaSelector: Enum "NPR CloudflareMediaSelector"; MediaKey: Text)
    var
        MediaLink: Record "NPR CloudflareMediaLink";
        MediaImpl: Codeunit "NPR CloudflareMediaImpl";
    begin
        MediaLink.SetCurrentKey(MediaKey);
        MediaLink.SetFilter(MediaKey, '=%1', CopyStr(MediaKey, 1, MaxStrLen(MediaLink.MediaKey)));
        MediaLink.DeleteAll();

        MediaImpl.Delete(MediaKey);
    end;

    /// <summary>
    /// Deletes the specific media key link from the database for a specific record.
    /// Note: This does not delete the actual media item from Cloudflare until there are no other links to it.
    /// </summary>
    /// <param name="TableNumber">The table number of the record.</param>   
    /// <param name="RecordId">The GUID of the record.</param>
    /// <param name="MediaSelector">Specifies the type of media.</param>
    procedure DeleteMediaKey(TableNumber: Integer; RecordId: Guid; MediaSelector: Enum "NPR CloudflareMediaSelector")
    var
        MediaLink: Record "NPR CloudflareMediaLink";
        MediaImpl: Codeunit "NPR CloudflareMediaImpl";
        MediaKey: Text[200];
    begin
        if (not MediaLink.Get(TableNumber, RecordId, MediaSelector)) then
            exit;

        MediaKey := MediaLink.MediaKey;
        MediaLink.Delete();

        MediaLink.SetCurrentKey(MediaKey);
        MediaLink.SetFilter(MediaKey, '=%1', MediaKey);
        if (MediaLink.FindFirst()) then
            exit; // There are other links to this media key, so do not delete the actual media item.

        MediaImpl.Delete(MediaKey);
    end;
    #endregion

    // *** Migration Job Related Methods ***
    #region Migration Job Related Methods

    /// <summary>
    /// Creates a migration job from a JSON file containing an array of job lines.
    /// Each array element should contain an object with "public_id" and "url" field.
    /// </summary>
    /// <param name="MediaSelector">Specifies the type of media being migrated.</param>
    /// <returns>The GUID of the created migration job.</returns>   
    procedure CreateMigrationJobFromJsonFileArray(MediaSelector: Enum "NPR CloudflareMediaSelector") JobId: Guid
    var
        MediaImpl: Codeunit "NPR CloudflareMediaImpl";
    begin
        exit(MediaImpl.CreateJobForLineArray(MediaSelector, CreateGuid(), MediaImpl.LoadJobLineArray()));
    end;


    /// <summary>
    /// Creates a migration job from a JSON array containing job lines.
    /// Each array element should contain an object with "public_id" and "url" field.
    /// </summary>
    /// <param name="MediaSelector">Specifies the type of media being migrated.</param>
    /// <returns>The GUID of the created migration job.</returns>
    procedure CreateMigrationJobFromJsonArray(MediaSelector: Enum "NPR CloudflareMediaSelector"; JobJson: JsonArray) JobId: Guid
    var
        MediaImpl: Codeunit "NPR CloudflareMediaImpl";
    begin
        exit(MediaImpl.CreateJobForLineArray(MediaSelector, CreateGuid(), JobJson));
    end;

    /// <summary>
    /// Creates a migration job from a JSON array containing job lines.
    /// Each array element should contain an object with "public_id" and "url" field.
    /// </summary>
    /// <param name="MediaSelector">Specifies the type of media being migrated.</param>
    /// <param name="BatchId">The batch identifier for grouping migration jobs.</param>
    /// <returns>The GUID of the created migration job.</returns>
    procedure CreateMigrationJobFromJsonArray(MediaSelector: Enum "NPR CloudflareMediaSelector"; BatchId: Guid; JobJson: JsonArray) JobId: Guid
    var
        MediaImpl: Codeunit "NPR CloudflareMediaImpl";
    begin
        exit(MediaImpl.CreateJobForLineArray(MediaSelector, BatchId, JobJson));
    end;

    /// <summary>
    /// Uploads a migration job to Cloudflare to migrate external media to Cloudflare Media according to the job lines defined in the job.
    /// </summary>
    /// <param name="JobId">The GUID of the migration job.</param>
    /// <param name="JobResponse">The resulting JSON object containing the job response.</param>
    /// <returns>True if the job was successfully started; otherwise, false.</returns>
    procedure StartMigrationJob(JobId: Guid; var JobResponse: JsonObject): Boolean
    var
        MediaImpl: Codeunit "NPR CloudflareMediaImpl";
    begin
        exit(MediaImpl.StartMigration(JobId, JobResponse));
    end;

    /// <summary>
    /// Finalizes a migration job in Cloudflare, creating the media links in BC.
    /// </summary>
    /// <param name="JobId">The GUID of the migration job.</param>
    /// <returns>True if the job was successfully finalized; otherwise, false.</returns>
    procedure FinalizeMigrationJob(JobId: Guid): Boolean
    var
        MediaImpl: Codeunit "NPR CloudflareMediaImpl";
    begin
        exit(MediaImpl.FinalizeMigration(JobId));
    end;

    /// <summary>
    /// Retrieves the status of a migration job from Cloudflare. The Job record is updated with the latest status information in JobStatusResponse.
    /// </summary>  
    /// <param name="JobId">The GUID of the migration job.</param>
    /// <param name="JobStatusResponse">The resulting JSON object containing the job status response.</param>
    /// <returns>True if the job status was successfully retrieved; otherwise, false.</returns>
    procedure GetMigrationJobStatus(JobId: Guid; var JobStatusResponse: JsonObject): Boolean
    var
        MediaImpl: Codeunit "NPR CloudflareMediaImpl";
    begin
        exit(MediaImpl.GetJobStatus(JobId, JobStatusResponse));
    end;

    /// <summary>
    /// Retrieves the results of a migration job from Cloudflare. The Job record is updated with the latest results information in JobResultsResponse.
    /// Call this function repeatedly until all results have been fetched. The job defines how many results are returned in each call.
    /// The Cloudflare queue is processed in the background, so it may take some time before the full result is available.
    /// </summary>
    /// <param name="JobId">The GUID of the migration job.</param>
    /// <param name="JobResultsResponse">The resulting JSON object containing the job results response.</param>
    /// <returns>True if the job results were successfully retrieved; otherwise, false.</returns>
    procedure GetMigrationJobResults(JobId: Guid; var JobResultsResponse: JsonObject): Boolean
    var
        MediaImpl: Codeunit "NPR CloudflareMediaImpl";
    begin
        exit(MediaImpl.GetJobResults(JobId, JobResultsResponse));
    end;

    /// <summary>
    /// Cancels an ongoing migration job in Cloudflare.
    /// </summary>
    /// <param name="JobId">The GUID of the migration job.</param>
    /// <param name="JobStatusResponse">The resulting JSON object containing the job response.</param>
    /// <returns>True if the job was successfully canceled; otherwise, false.</returns>
    procedure CancelMigrationJob(JobId: Guid; var JobStatusResponse: JsonObject): Boolean
    var
        MediaImpl: Codeunit "NPR CloudflareMediaImpl";
    begin
        exit(MediaImpl.CancelMigration(JobId, JobStatusResponse));
    end;

    #endregion
}