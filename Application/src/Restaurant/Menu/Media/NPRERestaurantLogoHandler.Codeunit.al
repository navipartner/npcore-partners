#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6248635 "NPR NPRERestaurantLogoHandler" implements "NPR CloudflareMigrationInterface"
{
    Access = Internal;

    internal procedure PublicIdLookup(PublicId: Text[100]; var TableNumber: Integer; var SystemId: Guid): Boolean
    var
        Restaurant: Record "NPR NPRE Restaurant";
        PublicIdGuid: Guid;
    begin
        if not Evaluate(PublicIdGuid, PublicId) then
            exit(false);

        if not Restaurant.GetBySystemId(PublicIdGuid) then
            exit(false);

        TableNumber := Database::"NPR NPRE Restaurant";
        SystemId := PublicIdGuid;
        exit(true);
    end;

    procedure ImportRestaurantLogoFromFileWithUI(RestaurantId: Guid): Boolean
    var
        FileManagement: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";
        ImageStream: InStream;
        FileName: Text;
    begin
        ClearLastError();

        FileName := FileManagement.BLOBImport(TempBlob, '');
        if (FileName = '') then
            exit(false);

        TempBlob.CreateInStream(ImageStream);
        if (not PutLogoFromStream(RestaurantId, '', ImageStream)) then
            Error('Error storing logo for restaurant %1: %2', RestaurantId, GetLastErrorText());

        exit(true);
    end;

    procedure PutLogoFromStream(RestaurantId: Guid; ContentType: Text[100]; ImageStream: InStream): Boolean
    var
        MediaUploadResponse: JsonObject;
        Base64Convert: Codeunit "Base64 Convert";
    begin
        exit(PutLogo(RestaurantId, ContentType, Base64Convert.ToBase64(ImageStream), MediaUploadResponse));
    end;

    procedure PutLogo(RestaurantId: Guid; ContentType: Text[100]; ImageBase64: Text; var MediaUploadResponse: JsonObject): Boolean
    var
        MediaFacade: Codeunit "NPR CloudflareMediaFacade";
        Restaurant: Record "NPR NPRE Restaurant";
        PublicId: Text[100];
    begin
        if not Restaurant.GetBySystemId(RestaurantId) then
            exit(false);

        PublicId := CopyStr(Format(Restaurant.SystemId, 0, 4).ToLower(), 1, MaxStrLen(PublicId));
        // 16 hours = 57600 seconds for keepalive
        if (not MediaFacade.Upload(Enum::"NPR CloudflareMediaSelector"::RESTAURANT_LOGO, PublicId, ContentType, ImageBase64, 57600, MediaUploadResponse)) then
            exit(false);

        exit(true);
    end;

    procedure GetLogoUrl(RestaurantId: Guid; Variant: Enum "NPR CloudflareMediaVariants"; TimeToLive: Integer; var ImageUrl: Text): Boolean
    var
        MediaResponse: JsonObject;
        JToken: JsonToken;
    begin
        if (not GetLogoMediaURL(RestaurantId, Variant, TimeToLive, MediaResponse)) then
            exit(false);

        if (not MediaResponse.Get('url', JToken)) then
            exit(false);

        ImageUrl := JToken.AsValue().AsText();
        exit(true);
    end;

    procedure GetLogoMediaURL(RestaurantId: Guid; Variant: Enum "NPR CloudflareMediaVariants"; TimeToLive: Integer; var MediaResponse: JsonObject): Boolean
    var
        MediaFacade: Codeunit "NPR CloudflareMediaFacade";
        Restaurant: Record "NPR NPRE Restaurant";
        MediaKey: Text;
        MediaId: Guid;
    begin
        if (IsNullGuid(RestaurantId)) then
            exit(false);

        if (not Restaurant.GetBySystemId(RestaurantId)) then
            exit(false);

        if (not MediaFacade.GetMediaKey(Database::"NPR NPRE Restaurant", RestaurantId, Enum::"NPR CloudflareMediaSelector"::RESTAURANT_LOGO, MediaId, MediaKey)) then
            exit(false);

        exit(MediaFacade.GetMediaUrl(MediaKey, Variant, TimeToLive, MediaResponse));
    end;

    procedure UnlinkLogo(RestaurantId: Guid): Boolean
    var
        MediaFacade: Codeunit "NPR CloudflareMediaFacade";
        Restaurant: Record "NPR NPRE Restaurant";
    begin
        if (IsNullGuid(RestaurantId)) then
            exit(false);

        if (not Restaurant.GetBySystemId(RestaurantId)) then
            exit(false);

        MediaFacade.DeleteMediaKey(Database::"NPR NPRE Restaurant", RestaurantId, Enum::"NPR CloudflareMediaSelector"::RESTAURANT_LOGO);
        exit(true);
    end;

    procedure HaveLogo(RestaurantId: Guid): Boolean
    var
        MediaFacade: Codeunit "NPR CloudflareMediaFacade";
        MediaKey: Text;
        MediaId: Guid;
    begin
        if (IsNullGuid(RestaurantId)) then
            exit(false);

        exit(MediaFacade.GetMediaKey(Database::"NPR NPRE Restaurant", RestaurantId, Enum::"NPR CloudflareMediaSelector"::RESTAURANT_LOGO, MediaId, MediaKey));
    end;

    procedure GetMediaDetails(RestaurantId: Guid; var MediaId: Guid; var MediaKey: Text): Boolean
    var
        MediaFacade: Codeunit "NPR CloudflareMediaFacade";
    begin
        if (IsNullGuid(RestaurantId)) then
            exit(false);

        exit(MediaFacade.GetMediaKey(Database::"NPR NPRE Restaurant", RestaurantId, Enum::"NPR CloudflareMediaSelector"::RESTAURANT_LOGO, MediaId, MediaKey));
    end;
}
#endif
