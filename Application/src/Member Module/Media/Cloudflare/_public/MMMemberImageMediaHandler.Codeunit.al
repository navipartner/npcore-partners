codeunit 6248559 "NPR MMMemberImageMediaHandler" implements "NPR CloudflareMigrationInterface"
{
    Access = Public;

    procedure IsFeatureEnabled(): Boolean
    var
        MemberCFMediaFeature: Codeunit "NPR MemberImageMediaFeature";
    begin
        exit(MemberCFMediaFeature.IsFeatureEnabled());
    end;

    internal procedure PublicIdLookup(PublicId: Text[100]; var TableNumber: Integer; var SystemId: Guid): Boolean;
    var
        Member: Record "NPR MM Member";
    begin
        Member.SetLoadFields("External Member No.");
        Member.SetFilter("External Member No.", '=%1', CopyStr(PublicId.ToUpper(), 1, MaxStrLen(Member."External Member No.")));
        if (not Member.FindFirst()) then
            exit(false);

        TableNumber := Database::"NPR MM Member";
        SystemId := Member.SystemId;
        exit(true);
    end;

    procedure ImportMemberImageFromFileWithUI(MemberId: Guid): Boolean
    var
        FileManagement: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";
        ImageStream: InStream;
        FileName: Text;
    begin
        ClearLastError();

        FileName := FileManagement.BLOBImport(TempBlob, '');
        if (FileName = '') then
            exit;

        TempBlob.CreateInStream(ImageStream);
        if (not PutMemberImageFromStream(MemberId, '', ImageStream)) then
            Error('Error storing image for member %1: %2', MemberId, GetLastErrorText());
    end;

    procedure PutMemberImageB64(MemberId: Guid; ContentType: Text[100]; ImageBase64: Text): Boolean
    var
        MediaUploadResponse: JsonObject;
        Member: Record "NPR MM Member";
    begin
        Member.SetLoadFields("External Member No.");
        if (not Member.GetBySystemId(MemberId)) then
            exit(false);

        exit(PutMemberImage(Member."External Member No.", ContentType, ImageBase64, MediaUploadResponse));
    end;

    procedure PutMemberImageFromStream(MemberId: Guid; ContentType: Text[100]; ImageStream: InStream): Boolean
    var
        MediaUploadResponse: JsonObject;
        Base64Convert: Codeunit "Base64 Convert";
        Member: Record "NPR MM Member";
    begin
        Member.SetLoadFields("External Member No.");
        if (not Member.GetBySystemId(MemberId)) then
            exit(false);

        exit(PutMemberImage(Member."External Member No.", ContentType, Base64Convert.ToBase64(ImageStream), MediaUploadResponse));
    end;

    /// <summary>
    /// Stores the member image in Cloudflare and links it to the member record.
    /// Internal function relying on MemberId and MemberExternalNo existing and valid.
    /// Used when members are created but have not been inserted yet.
    /// </summary>
    internal procedure PutMemberImage(MemberExternalNo: Code[20]; ContentType: Text[100]; ImageBase64: Text; var MediaUploadResponse: JsonObject): Boolean
    var
        MediaFacade: Codeunit "NPR CloudflareMediaFacade";
    begin
        if (not MediaFacade.Upload(Enum::"NPR CloudflareMediaSelector"::MEMBER_PHOTO, MemberExternalNo, ContentType, ImageBase64, 300, MediaUploadResponse)) then
            exit(false);

        exit(true);
    end;

    procedure GetMemberImageUrl(MemberId: Guid; Variant: Enum "NPR CloudflareMediaVariants"; TimeToLive: Integer; var ImageUrl: Text): Boolean
    var
        MediaResponse: JsonObject;
        JToken: JsonToken;
    begin
        if (not GetMemberImageMediaURL(MemberId, Variant, TimeToLive, false, MediaResponse)) then
            exit(false);

        if (not MediaResponse.Get('url', JToken)) then
            exit(false);

        ImageUrl := JToken.AsValue().AsText();
        exit(true);
    end;

    procedure GetMemberImageB64(MemberId: Guid; Variant: Enum "NPR CloudflareMediaVariants"; var ImageB64: Text): Boolean
    var
        MediaResponse: JsonObject;
        JToken: JsonToken;
    begin
        if (not GetMemberImageMediaUrl(MemberId, Variant, 60, true, MediaResponse)) then
            exit(false);

        if (not MediaResponse.Get('imageB64', JToken)) then
            exit(false);

        ImageB64 := JToken.AsValue().AsText();
        exit(true);
    end;


    procedure GetMemberImageMediaURL(MemberId: Guid; Variant: Enum "NPR CloudflareMediaVariants"; TimeToLive: Integer;
                                                                  AsB64: Boolean; var MediaResponse: JsonObject): Boolean
    var
        MediaFacade: Codeunit "NPR CloudflareMediaFacade";
        Member: Record "NPR MM Member";
        MediaKey: Text;
        MediaId: Guid;
    begin
        if (IsNullGuid(MemberId)) then
            exit(false);

        Member.SetLoadFields("External Member No.");
        if (not Member.GetBySystemId(MemberId)) then
            exit(false);

        if (not MediaFacade.GetMediaKey(Database::"NPR MM Member", MemberId, Enum::"NPR CloudflareMediaSelector"::MEMBER_PHOTO, MediaId, MediaKey)) then
            exit(false);

        if (AsB64) then
            exit(MediaFacade.GetMediaB64(Enum::"NPR CloudflareMediaSelector"::MEMBER_PHOTO, MediaKey, Variant, MediaResponse));

        exit(MediaFacade.GetMediaUrl(MediaKey, Variant, TimeToLive, MediaResponse));
    end;

    procedure UnlinkMemberImage(MemberId: Guid): Boolean
    var
        MediaFacade: Codeunit "NPR CloudflareMediaFacade";
        Member: Record "NPR MM Member";
    begin
        if (IsNullGuid(MemberId)) then
            exit(false);

        Member.SetLoadFields("External Member No.");
        if (not Member.GetBySystemId(MemberId)) then
            exit(false);

        // Note: We do not delete the image from Cloudflare, just unlink it from the member record.
        MediaFacade.DeleteMediaKey(Database::"NPR MM Member", MemberId, Enum::"NPR CloudflareMediaSelector"::MEMBER_PHOTO);
        exit(true);
    end;

    procedure HaveMemberImage(MemberId: Guid): Boolean
    var
        MediaFacade: Codeunit "NPR CloudflareMediaFacade";
        MediaKey: Text;
        MediaId: Guid;
    begin
        if (IsNullGuid(MemberId)) then
            exit(false);

        exit(MediaFacade.GetMediaKey(Database::"NPR MM Member", MemberId, Enum::"NPR CloudflareMediaSelector"::MEMBER_PHOTO, MediaId, MediaKey));
    end;

    procedure GetMediaDetails(MemberId: Guid; var MediaId: Guid; var MediaKey: Text): Boolean
    var
        MediaFacade: Codeunit "NPR CloudflareMediaFacade";
    begin
        if (IsNullGuid(MemberId)) then
            exit(false);

        exit(MediaFacade.GetMediaKey(Database::"NPR MM Member", MemberId, Enum::"NPR CloudflareMediaSelector"::MEMBER_PHOTO, MediaId, MediaKey));
    end;
}