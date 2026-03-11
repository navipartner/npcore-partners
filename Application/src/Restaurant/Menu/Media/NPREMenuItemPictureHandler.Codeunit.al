#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6150991 "NPR NPREMenuItemPictureHandler" implements "NPR CloudflareMigrationInterface"
{
    Access = Internal;

    internal procedure PublicIdLookup(PublicId: Text[100]; var TableNumber: Integer; var SystemId: Guid): Boolean
    var
        MenuItem: Record "NPR NPRE Menu Item";
        PublicIdGuid: Guid;
    begin
        if not Evaluate(PublicIdGuid, PublicId) then
            exit(false);

        if not MenuItem.GetBySystemId(PublicIdGuid) then
            exit(false);

        TableNumber := Database::"NPR NPRE Menu Item";
        SystemId := PublicIdGuid;
        exit(true);
    end;

    procedure PutPictureFromStream(MenuItemId: Guid; ContentType: Text[100]; ImageStream: InStream): Boolean
    var
        MediaUploadResponse: JsonObject;
        Base64Convert: Codeunit "Base64 Convert";
    begin
        exit(PutPicture(MenuItemId, ContentType, Base64Convert.ToBase64(ImageStream), MediaUploadResponse));
    end;

    procedure PutPicture(MenuItemId: Guid; ContentType: Text[100]; ImageBase64: Text; var MediaUploadResponse: JsonObject): Boolean
    var
        MediaFacade: Codeunit "NPR CloudflareMediaFacade";
        MenuItem: Record "NPR NPRE Menu Item";
        PublicId: Text[100];
    begin
        if not MenuItem.GetBySystemId(MenuItemId) then
            exit(false);

        PublicId := CopyStr(Format(MenuItemId, 0, 4).ToLower(), 1, MaxStrLen(PublicId));
        // 16 hours = 57600 seconds for keepalive
        if (not MediaFacade.Upload(Enum::"NPR CloudflareMediaSelector"::MENU_ITEM_PICTURE, PublicId, ContentType, ImageBase64, 57600, MediaUploadResponse)) then
            exit(false);

        exit(true);
    end;

    procedure GetPictureUrl(MenuItemId: Guid; Variant: Enum "NPR CloudflareMediaVariants"; TimeToLive: Integer; var ImageUrl: Text): Boolean
    var
        MediaResponse: JsonObject;
        JToken: JsonToken;
    begin
        if (not GetPictureMediaURL(MenuItemId, Variant, TimeToLive, MediaResponse)) then
            exit(false);

        if (not MediaResponse.Get('url', JToken)) then
            exit(false);

        ImageUrl := JToken.AsValue().AsText();
        exit(true);
    end;

    procedure GetPictureMediaURL(MenuItemId: Guid; Variant: Enum "NPR CloudflareMediaVariants"; TimeToLive: Integer; var MediaResponse: JsonObject): Boolean
    var
        MediaFacade: Codeunit "NPR CloudflareMediaFacade";
        MenuItem: Record "NPR NPRE Menu Item";
        MediaKey: Text;
        MediaId: Guid;
    begin
        if (IsNullGuid(MenuItemId)) then
            exit(false);

        if (not MenuItem.GetBySystemId(MenuItemId)) then
            exit(false);

        if (not MediaFacade.GetMediaKey(Database::"NPR NPRE Menu Item", MenuItemId, Enum::"NPR CloudflareMediaSelector"::MENU_ITEM_PICTURE, MediaId, MediaKey)) then
            exit(false);

        exit(MediaFacade.GetMediaUrl(MediaKey, Variant, TimeToLive, MediaResponse));
    end;

    procedure UnlinkPicture(MenuItemId: Guid): Boolean
    var
        MediaFacade: Codeunit "NPR CloudflareMediaFacade";
        MenuItem: Record "NPR NPRE Menu Item";
    begin
        if (IsNullGuid(MenuItemId)) then
            exit(false);

        if (not MenuItem.GetBySystemId(MenuItemId)) then
            exit(false);

        MediaFacade.DeleteMediaKey(Database::"NPR NPRE Menu Item", MenuItemId, Enum::"NPR CloudflareMediaSelector"::MENU_ITEM_PICTURE);
        exit(true);
    end;

    procedure ImportMenuItemPictureFromFileWithUI(MenuItemId: Guid): Boolean
    var
        FileManagement: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";
        MenuItem: Record "NPR NPRE Menu Item";
        ImageStream: InStream;
        FileName: Text;
    begin
        ClearLastError();

        if not MenuItem.GetBySystemId(MenuItemId) then
            exit(false);

        FileName := FileManagement.BLOBImport(TempBlob, '');
        if (FileName = '') then
            exit(false);

        TempBlob.CreateInStream(ImageStream);
        if (not PutPictureFromStream(MenuItemId, '', ImageStream)) then
            Error('Error storing image for menu item %1: %2', MenuItemId, GetLastErrorText());

        exit(true);
    end;

    procedure HavePicture(MenuItemId: Guid): Boolean
    var
        MediaFacade: Codeunit "NPR CloudflareMediaFacade";
        MediaKey: Text;
        MediaId: Guid;
    begin
        if (IsNullGuid(MenuItemId)) then
            exit(false);

        exit(MediaFacade.GetMediaKey(Database::"NPR NPRE Menu Item", MenuItemId, Enum::"NPR CloudflareMediaSelector"::MENU_ITEM_PICTURE, MediaId, MediaKey));
    end;

    procedure GetMediaDetails(MenuItemId: Guid; var MediaId: Guid; var MediaKey: Text): Boolean
    var
        MediaFacade: Codeunit "NPR CloudflareMediaFacade";
    begin
        if (IsNullGuid(MenuItemId)) then
            exit(false);

        exit(MediaFacade.GetMediaKey(Database::"NPR NPRE Menu Item", MenuItemId, Enum::"NPR CloudflareMediaSelector"::MENU_ITEM_PICTURE, MediaId, MediaKey));
    end;
}
#endif
