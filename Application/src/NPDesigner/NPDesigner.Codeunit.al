codeunit 6248190 "NPR NPDesigner"
{
    Access = Internal;
    internal procedure LookupDesignLayouts(Type: Text; LookupCaption: Text; var NPDesignerTemplateId: Text[40]; var NPDesignerTemplateLabel: Text[80])
    var
        TemporaryNPDesignerTemplates: Record "NPR NPDesignerTemplates" temporary;
    begin
        GetDesignerTemplates(Type, TemporaryNPDesignerTemplates);
        SelectDesignLayout(Type, LookupCaption, NPDesignerTemplateId, NPDesignerTemplateLabel, TemporaryNPDesignerTemplates);
    end;

    internal procedure ValidateDesignLayouts(Type: Text; var NPDesignerTemplateId: Text[40]; var NPDesignerTemplateLabel: Text[80])
    var
        TemporaryNPDesignerTemplates: Record "NPR NPDesignerTemplates" temporary;
    begin
        if (NPDesignerTemplateLabel = '') then begin
            NPDesignerTemplateId := '';
            exit;
        end;
        GetDesignerTemplates(Type, TemporaryNPDesignerTemplates);
        FindDesignLayout(NPDesignerTemplateId, NPDesignerTemplateLabel, TemporaryNPDesignerTemplates);
    end;

    internal procedure SelectDesignLayout(Type: Text; LookupCaption: Text; var NPDesignerTemplateId: Text[40]; var NPDesignerTemplateLabel: Text[80]; var DesignerTemplates: Record "NPR NPDesignerTemplates" temporary)
    var
        SelectDesignLayouts: Page "NPR NPDesignerTemplateList";
    begin
        if (DesignerTemplates.FindFirst()) then;
        if (DesignerTemplates.Get(NPDesignerTemplateId)) then;

        SelectDesignLayouts.SetData(DesignerTemplates);
        SelectDesignLayouts.SetCaption(StrSubstNo('%1 - %2', Type, LookupCaption));
        SelectDesignLayouts.LookupMode(true);
        if (SelectDesignLayouts.RunModal() <> Action::LookupOK) then
            exit;

        SelectDesignLayouts.GetRecord(DesignerTemplates);
        NPDesignerTemplateId := DesignerTemplates.ExternalId;
        NPDesignerTemplateLabel := CopyStr(DesignerTemplates.Description, 1, MaxStrLen(NPDesignerTemplateLabel));
    end;

    internal procedure FindDesignLayout(var NPDesignerTemplateId: Text[40]; var NPDesignerTemplateLabel: Text[80]; var DesignerTemplates: Record "NPR NPDesignerTemplates" temporary)
    var
        NotFound: Label 'Design Layout %1 not found';
    begin
        DesignerTemplates.SetFilter(Description, '%1', '@' + NPDesignerTemplateLabel + '*');
        if (not DesignerTemplates.FindFirst()) then
            Error(NotFound, NPDesignerTemplateLabel);

        NPDesignerTemplateId := DesignerTemplates.ExternalId;
        NPDesignerTemplateLabel := CopyStr(DesignerTemplates.Description, 1, MaxStrLen(NPDesignerTemplateLabel));
    end;

    #region Manifest Management
    internal procedure CreateManifest() ManifestId: Guid
    begin
        exit(CreateManifest('', '', false));
    end;

    internal procedure CreateManifest(ExternalTemplateId: Text[40]; LanguageCode: Code[10]; ShowToC: Boolean) ManifestId: Guid
    var
        Manifest: Record "NPR NPDesignerManifest";
        Webhook: Codeunit "NPR NPDesignerManifestWebHook";
    begin
        Manifest.Init();
        Manifest.ManifestId := CreateGuid();
        Manifest.MasterTemplateId := ExternalTemplateId;
        Manifest.PreferredAssetLanguage := LanguageCode;
        Manifest.ShowTableOfContents := ShowToC;

        if (not Manifest.Insert()) then
            Error('Could not create new NP Designer Manifest');

        Webhook.OnManifestCreated(Manifest.ManifestId);
        exit(Manifest.ManifestId);
    end;

    internal procedure GetManifest(ManifestId: Guid) JManifest: JsonObject
    var
        Manifest: Record "NPR NPDesignerManifest";
        ManifestLine: Record "NPR NPDesignerManifestLine";
        Asset: JsonObject;
        Assets: JsonArray;
    begin
        Manifest.SetCurrentKey(ManifestId);
        Manifest.SetFilter(ManifestId, '=%1', ManifestId);
        if (not Manifest.FindFirst()) then
            Error('Manifest with Id %1 not found', ManifestId);

        JManifest.Add('manifestId', Format(Manifest.ManifestId, 0, 4).toLower());
        JManifest.Add('languageCode', Manifest.PreferredAssetLanguage);
        JManifest.Add('toc', Manifest.ShowTableOfContents);

        ManifestLine.SetCurrentKey(EntryNo, RenderGroup, RenderGroupOrder);
        ManifestLine.SetFilter(EntryNo, '=%1', Manifest.EntryNo);
        if (ManifestLine.FindSet()) then
            repeat
                Clear(Asset);
                Asset.Add('id', Format(ManifestLine.SystemId, 0, 4).ToLower());
                Asset.Add('assetTableNumber', ManifestLine.AssetTableNumber);
                Asset.Add('assetId', Format(ManifestLine.AssetId, 0, 4).ToLower());
                Asset.Add('assetPublicId', ManifestLine.AssetPublicId);
                Asset.Add('renderWithTemplateId', ManifestLine.RenderWithTemplateId);
                Asset.Add('renderGroup', ManifestLine.RenderGroup);
                Asset.Add('renderGroupOrder', ManifestLine.RenderGroupOrder);
                Assets.Add(Asset);
            until (ManifestLine.Next() = 0);

        JManifest.Add('assets', Assets);
    end;

    internal procedure SetPreferredAssetLanguage(ManifestId: Guid; PreferredAssetLanguage: Code[10]): Boolean
    var
        Manifest: Record "NPR NPDesignerManifest";
    begin
        Manifest.SetCurrentKey(ManifestId);
        Manifest.SetFilter(ManifestId, '=%1', ManifestId);
        if (not Manifest.FindFirst()) then
            exit(false);

        Manifest.PreferredAssetLanguage := PreferredAssetLanguage;
        exit(Manifest.Modify());
    end;

    internal procedure SetShowTableOfContents(ManifestId: Guid; ShowTableOfContents: Boolean): Boolean
    var
        Manifest: Record "NPR NPDesignerManifest";
    begin
        Manifest.SetCurrentKey(ManifestId);
        Manifest.SetFilter(ManifestId, '=%1', ManifestId);
        if (not Manifest.FindFirst()) then
            exit(false);
        Manifest.ShowTableOfContents := ShowTableOfContents;
        exit(Manifest.Modify());
    end;

    internal procedure AddAssetToManifest(ManifestId: Guid; AssetTableNumber: Integer; AssetId: Guid; AssetPublicId: Text[100]; ExternalTemplateId: Text[40]): Boolean
    var
        Manifest: Record "NPR NPDesignerManifest";
        Webhook: Codeunit "NPR NPDesignerManifestWebHook";
        LineSystemId: Guid;
    begin
        Manifest.SetCurrentKey(ManifestId);
        Manifest.SetFilter(ManifestId, '=%1', ManifestId);
        if (not Manifest.FindFirst()) then
            exit(false);

        if (not AddAssetToManifestWorker(Manifest.EntryNo, AssetTableNumber, AssetId, AssetPublicId, ExternalTemplateId, LineSystemId)) then
            exit(false);

        Webhook.OnManifestContentAdded(ManifestId, LineSystemId, AssetTableNumber, AssetId, AssetPublicId, ExternalTemplateId);
        exit(true);
    end;

    internal procedure AddAssetToManifest(ManifestId: Guid; AssetTableNumber: Integer; Assets: Dictionary of [Guid, Text[100]]; ExternalTemplateId: Text[40]; var FailedAssets: List of [Guid]): Boolean
    var
        Manifest: Record "NPR NPDesignerManifest";
        AssetId: Guid;
        Webhook: Codeunit "NPR NPDesignerManifestWebHook";
        LineSystemId: Guid;
    begin
        Manifest.SetCurrentKey(ManifestId);
        Manifest.SetFilter(ManifestId, '=%1', ManifestId);
        if (not Manifest.FindFirst()) then
            exit(false);

        foreach AssetId in Assets.Keys() do
            if (not AddAssetToManifestWorker(Manifest.EntryNo, AssetTableNumber, AssetId, Assets.Get(AssetId), ExternalTemplateId, LineSystemId)) then
                FailedAssets.Add(AssetId);

        if (FailedAssets.Count() = Assets.Count()) then
            exit(false); // all failed

        Webhook.OnManifestContentChange(ManifestId);
        exit(FailedAssets.Count() = 0);
    end;

    local procedure AddAssetToManifestWorker(ManifestEntryNo: Integer; AssetTableNumber: Integer; AssetId: Guid; AssetPublicId: Text[100]; ExternalTemplateId: Text[40]; var LineSystemId: Guid): Boolean
    var
        ManifestLine: Record "NPR NPDesignerManifestLine";
    begin
        if (AssetTableNumber = 0) then
            Error('Asset Table Number is required to add asset to manifest');

        if (IsNullGuid(AssetId)) then
            Error('Asset Id is required to add asset to manifest');

        if (ExternalTemplateId = '') then
            Error('External Template Id is required to add asset to manifest');

        // prevent duplicate assets
        ManifestLine.SetCurrentKey(AssetTableNumber, AssetId);
        ManifestLine.SetFilter(EntryNo, '=%1', ManifestEntryNo); // Auto added field on key
        ManifestLine.SetFilter(AssetTableNumber, '=%1', AssetTableNumber);
        ManifestLine.SetFilter(AssetId, '=%1', AssetId);
        if (ManifestLine.FindFirst()) then
            exit(true);

        ManifestLine.Init();
        ManifestLine.EntryNo := ManifestEntryNo;
        ManifestLine.AssetTableNumber := AssetTableNumber;
        ManifestLine.AssetId := AssetId;
        ManifestLine.AssetPublicId := AssetPublicId;
        ManifestLine.RenderWithTemplateId := ExternalTemplateId;

        LineSystemId := CreateGuid();
        ManifestLine.SystemId := LineSystemId;

        exit(ManifestLine.Insert(true));
    end;

    internal procedure RemoveAssetFromManifest(ManifestId: Guid; AssetTableNumber: Integer; AssetId: Guid): Boolean
    var
        Manifest: Record "NPR NPDesignerManifest";
        Webhook: Codeunit "NPR NPDesignerManifestWebHook";
        LineSystemId: Guid;
    begin
        Manifest.SetCurrentKey(ManifestId);
        Manifest.SetFilter(ManifestId, '=%1', ManifestId);
        if (not Manifest.FindFirst()) then
            exit(false);

        if (not RemoveAssetFromManifestWorker(Manifest.EntryNo, AssetTableNumber, AssetId, LineSystemId)) then
            exit(false);

        Webhook.OnManifestContentRemoved(ManifestId, LineSystemId, AssetTableNumber, AssetId);
        exit(true);
    end;

    internal procedure RemoveAssetFromManifest(ManifestId: Guid; AssetTableNumber: Integer; Assets: List of [Guid]; var FailedAssets: List of [Guid]): Boolean
    var
        Manifest: Record "NPR NPDesignerManifest";
        AssetId: Guid;
        Webhook: Codeunit "NPR NPDesignerManifestWebHook";
        LineSystemId: Guid;
    begin
        Manifest.SetCurrentKey(ManifestId);
        Manifest.SetFilter(ManifestId, '=%1', ManifestId);
        if (not Manifest.FindFirst()) then
            exit(false);

        foreach AssetId in Assets do
            if (not RemoveAssetFromManifestWorker(Manifest.EntryNo, AssetTableNumber, AssetId, LineSystemId)) then
                FailedAssets.Add(AssetId);

        if (FailedAssets.Count() = Assets.Count()) then
            exit(false); // all failed

        Webhook.OnManifestContentChange(ManifestId);
        exit(FailedAssets.Count() = 0);
    end;

    local procedure RemoveAssetFromManifestWorker(ManifestEntryNo: Integer; AssetTableNumber: Integer; AssetId: Guid; var LineSystemId: Guid): Boolean
    var
        ManifestLine: Record "NPR NPDesignerManifestLine";
    begin
        ManifestLine.SetCurrentKey(AssetTableNumber, AssetId);
        ManifestLine.SetFilter(EntryNo, '=%1', ManifestEntryNo); // Auto added field on key
        ManifestLine.SetFilter(AssetTableNumber, '=%1', AssetTableNumber);
        ManifestLine.SetFilter(AssetId, '=%1', AssetId);
        if (not ManifestLine.FindFirst()) then
            exit(false);

        LineSystemId := ManifestLine.SystemId;
        ManifestLine.Delete();
        exit(true);
    end;

    internal procedure DeleteManifest(ManifestId: Guid): Boolean
    var
        Manifest: Record "NPR NPDesignerManifest";
        Webhook: Codeunit "NPR NPDesignerManifestWebHook";
    begin
        Manifest.SetCurrentKey(ManifestId);
        Manifest.SetFilter(ManifestId, '=%1', ManifestId);
        if (not Manifest.FindFirst()) then
            exit(false);

        if (not Manifest.Delete(true)) then
            exit(false);

        Webhook.OnManifestDeleted(ManifestId);
        exit(true);
    end;

    internal procedure GetManifestUrl(ManifestId: Guid; var Url: Text[250]): Boolean
    var
        Manifest: Record "NPR NPDesignerManifest";
        ManifestLine: Record "NPR NPDesignerManifestLine";
        Kid, Gen, Sig, Mid, Gid : Text;
        ToSign: Text;
        CryptographyManagement: Codeunit "Cryptography Management";
        HashAlgorithm: Option MD5,SHA1,SHA256,SHA384,SHA512;
        NpDesignerSetup: Record "NPR NPDesignerSetup";
        AssetsUrl, TempUrl : Text;
    begin
        NpDesignerSetup.Get();
        if (not NpDesignerSetup.EnableManifest) then
            exit(false);

        AssetsUrl := 'https://assets.npretail.app/'; // Default
        if (NpDesignerSetup.AssetsUrl <> '') then
            AssetsUrl := NpDesignerSetup.AssetsUrl;

        Manifest.SetCurrentKey(ManifestId);
        Manifest.SetFilter(ManifestId, '=%1', ManifestId);
        if (not Manifest.FindFirst()) then
            exit(false);

        if (Manifest.MasterTemplateId = '') then begin
            ManifestLine.SetCurrentKey(EntryNo);
            ManifestLine.SetFilter(EntryNo, '=%1', Manifest.EntryNo);
            if (not ManifestLine.FindFirst()) then
                exit(false);
        end;

        Kid := '0';
        Gen := Format(Round((CurrentDateTime() - CreateDateTime(DMY2Date(1, 1, 1970), 0T)) / 1000, 1), 0, 9);
        Mid := Format(ManifestId, 0, 4).ToLower();
        Gid := Manifest.MasterTemplateId;
        if (Gid = '') then
            Gid := ManifestLine.RenderWithTemplateId;

        if (Gid = '') then
            exit(false); // Gid is required for designer engine to render the manifest

        ToSign := StrSubstNo('GET|%1|%2|%3|%4', Kid, Gen, Mid, Gid);
        Sig := CryptographyManagement.GenerateHash(ToSign, HashAlgorithm::SHA256).Replace('=', '').Replace('/', '_').Replace('+', '-').ToLower();

        if (AssetsUrl.EndsWith('/')) then
            AssetsUrl := CopyStr(AssetsUrl, 1, StrLen(AssetsUrl) - 1);

        // depending the host name the length is about 200 characters long 
        TempUrl := StrSubstNo('%1/manifest?mid=%2&gid=%3&kid=%4&gen=%5&sig=%6', AssetsUrl, Mid, Gid, Kid, Gen, Sig);
        if (StrLen(TempUrl) > MaxStrLen(Url)) then
            exit(false);

        Url := CopyStr(TempUrl, 1, MaxStrLen(Url));
        exit(true);
    end;

    internal procedure GetManifestUrlForAsset(AssetTableNumber: Integer; AssetId: Guid; var Url: Text[250]): Boolean
    var
        ManifestLine: Record "NPR NPDesignerManifestLine";
        Manifest: Record "NPR NPDesignerManifest";
    begin
        ManifestLine.SetCurrentKey(AssetTableNumber, AssetId);
        ManifestLine.SetFilter(AssetTableNumber, '=%1', AssetTableNumber);
        ManifestLine.SetFilter(AssetId, '=%1', AssetId);
        if (not ManifestLine.FindLast()) then
            exit(false);

        Manifest.SetCurrentKey(EntryNo);
        Manifest.SetFilter(EntryNo, '=%1', ManifestLine.EntryNo);
        if (not Manifest.FindFirst()) then
            exit(false);

        exit(GetManifestUrl(Manifest.ManifestId, Url));
    end;
    #endregion

    internal procedure GetDesignerTemplates(Type: Text; var DesignerTemplates: Record "NPR NPDesignerTemplates" temporary)
    var
        NoTemplatesFound: Label 'Could not retrieve design layouts from NP Designer: %1';
        Result: JsonToken;
    begin
        ClearLastError();
        if (not DesignerTemplateApi(Type, Result)) then begin
            Message(NoTemplatesFound, GetLastErrorText);
            exit;
        end;

        PopulateTemplatesFromResult(Result, DesignerTemplates);
    end;

    internal procedure GetDesignerTemplates(Source: Text; Type: Text; ApiUrl: Text; ApiToken: SecretText; var DesignerTemplates: Record "NPR NPDesignerTemplates" temporary): Boolean
    var
        NoExternalTemplatesFound: Label 'Could not retrieve design layouts: %1';
        Result: JsonToken;
    begin
        ClearLastError();
        if (not DesignerTemplateApiExternal(ApiUrl, ApiToken, Source, Type, Result)) then begin
            Message(NoExternalTemplatesFound, GetLastErrorText);
            exit(false);
        end;

        PopulateTemplatesFromResult(Result, DesignerTemplates);
        exit(true);
    end;

    local procedure PopulateTemplatesFromResult(Result: JsonToken; var DesignerTemplates: Record "NPR NPDesignerTemplates" temporary)
    var
        Layouts: JsonObject;
        DesignLayouts: JsonArray;
        Design, Designs : JsonToken;
    begin
        if (Result.IsObject()) then begin
            Layouts := Result.AsObject();
            Layouts.Get('designs', Designs);
            if (Designs.IsArray()) then
                DesignLayouts := Designs.AsArray();
        end;

        if (Result.IsArray()) then
            DesignLayouts := Result.AsArray();

        foreach Design in DesignLayouts do begin
            DesignerTemplates.ExternalId := CopyStr(AsText(Design, 'value'), 1, MaxStrLen(DesignerTemplates.ExternalId));
            DesignerTemplates.Description := CopyStr(AsText(Design, 'label'), 1, MaxStrLen(DesignerTemplates.Description));
            DesignerTemplates.Insert(true);
        end;
    end;

    [TryFunction]
    [NonDebuggable]
    local procedure DesignerTemplateApi(Type: Text; Result: JsonToken)
    var
        Setup: Record "NPR NPDesignerSetup";
    begin
        Setup.Get();
        Setup.TestField(DesignerURL);
        Setup.TestField(ApiAuthorization);
        DesignerTemplateApiExternal(Setup.DesignerURL, Setup.ApiAuthorization, 'designer', Type, Result);
    end;

    [TryFunction]
    [NonDebuggable]
    local procedure DesignerTemplateApiExternal(ApiUrl: Text; ApiToken: SecretText; Source: Text; Type: Text; Result: JsonToken)
    var
        HttpWebRequest: HttpRequestMessage;
        HttpWebResponse: HttpResponseMessage;
        Client: HttpClient;
        Headers: HttpHeaders;
        Response: Text;
    begin
        Clear(Response);

        HttpWebRequest.SetRequestUri(StrSubstNo('%1?source=%2&type=%3', ApiUrl, CopyStr(Source, 1, 20), CopyStr(Type, 1, 50)));
        HttpWebRequest.Method('GET');
        HttpWebRequest.GetHeaders(Headers);
        Headers.Add('Authorization', SecretStrSubstNo('Bearer %1', ApiToken));

        Client.Timeout := 60000;
        Client.Send(HttpWebRequest, HttpWebResponse);
        HttpWebResponse.Content.ReadAs(Response);
        if (not HttpWebResponse.IsSuccessStatusCode()) then
            Error('%1 - %2  \%3', HttpWebResponse.HttpStatusCode, HttpWebResponse.ReasonPhrase, Response);

        Result.ReadFrom(Response);
    end;


    local procedure AsText(JToken: JsonToken; JPath: Text) Value: Text
    var
        JToken2: JsonToken;
    begin
        if not JToken.SelectToken(JPath, JToken2) then
            exit('');

        Value := JToken2.AsValue().AsText();
        exit(Value);
    end;
}