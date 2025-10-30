#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6248597 "NPR NPDesignerManifestAPI" implements "NPR API Request Handler"
{
    Access = Internal;

    procedure Handle(var Request: Codeunit "NPR API Request"): Codeunit "NPR API Response"
    begin
        case true of
            Request.Match('GET', '/pdfdesigner/manifest/:manifestId'):
                exit(GetManifest(Request));
        end;
    end;

    local procedure GetManifest(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        Manifest: Record "NPR NPDesignerManifest";
    begin
        if (not GetManifestByManifestId(Request, 3, Manifest)) then
            exit(Response.RespondBadRequest('Invalid Manifest - Manifest Id not valid.'));

        Response.RespondOK(GetManifestDTO(Manifest).Build());
    end;

    internal procedure GetManifestByManifestId(var Request: Codeunit "NPR API Request"; PathPosition: Integer; var Manifest: Record "NPR NPDesignerManifest"): Boolean
    var
        IdText: Text[50];
        Id: Guid;
    begin
        IdText := CopyStr(Request.Paths().Get(PathPosition), 1, MaxStrLen(IdText));
        if (IdText = '') then
            exit(false);

        if (not Evaluate(Id, IdText)) then
            exit(false);

        Manifest.SetCurrentKey(ManifestId);
        Manifest.SetFilter(ManifestId, '=%1', Id);
        if (not Manifest.FindFirst()) then
            exit(false);

        exit(true);
    end;

    local procedure GetManifestDTO(Manifest: Record "NPR NPDesignerManifest") Json: Codeunit "NPR Json Builder";
    var
        ManifestLine: Record "NPR NPDesignerManifestLine";
    begin
        Json.StartObject()
            .AddProperty('manifestId', Format(Manifest.ManifestId, 0, 4).ToLower())
            .AddProperty('languageCode', Manifest.PreferredAssetLanguage)
            .AddProperty('toc', Manifest.ShowTableOfContents)
            .AddProperty('createdAt', Manifest.SystemCreatedAt);

        ManifestLine.SetCurrentKey(EntryNo, RenderGroupOrder);
        ManifestLine.SetFilter(EntryNo, '=%1', Manifest.EntryNo);
        if (ManifestLine.FindSet()) then begin
            Json.StartArray('assets');
            repeat
                Json.StartObject()
                    .AddProperty('id', Format(ManifestLine.SystemId, 0, 4).ToLower())
                    .AddProperty('assetTableNumber', ManifestLine.AssetTableNumber)
                    .AddProperty('assetId', Format(ManifestLine.AssetId, 0, 4).ToLower())
                    .AddProperty('assetPublicId', ManifestLine.AssetPublicId)
                    .AddProperty('renderWithTemplateId', ManifestLine.RenderWithTemplateId)
                    .AddProperty('renderGroup', ManifestLine.RenderGroup)
                    .AddProperty('renderGroupOrder', ManifestLine.RenderGroupOrder)
                    .AddProperty('createdAt', ManifestLine.SystemCreatedAt)
                .EndObject();
            until (ManifestLine.Next() = 0);
            Json.EndArray();
        end;
    end;
}
#endif