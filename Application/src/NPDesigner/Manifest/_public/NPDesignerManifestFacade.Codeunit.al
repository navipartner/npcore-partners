codeunit 6248596 "NPR NPDesignerManifestFacade"
{
    Access = Public;

    procedure CreateManifest(): Guid
    var
        NPDesigner: Codeunit "NPR NPDesigner";
    begin
        exit(NPDesigner.CreateManifest());
    end;

    procedure CreateManifest(ExternalTemplateId: Text[40]): Guid
    var
        NPDesigner: Codeunit "NPR NPDesigner";
    begin
        exit(NPDesigner.CreateManifest(ExternalTemplateId));
    end;

    procedure DeleteManifest(ManifestId: Guid): Boolean
    var
        NPDesigner: Codeunit "NPR NPDesigner";
    begin
        exit(NPDesigner.DeleteManifest(ManifestId));
    end;



    procedure AddAssetToManifest(ManifestId: Guid; AssetTableNumber: Integer; AssetId: Guid; AssetPublicId: Text[100]; ExternalTemplateId: Text[40]): Boolean
    var
        NPDesigner: Codeunit "NPR NPDesigner";
    begin
        exit(NPDesigner.AddAssetToManifest(ManifestId, AssetTableNumber, AssetId, AssetPublicId, ExternalTemplateId));
    end;

    procedure AddAssetToManifest(ManifestId: Guid; AssetTableNumber: Integer; Assets: Dictionary of [Guid, Text[100]]; ExternalTemplateId: Text[40]; var NotInsertedAssets: List of [Guid]): Boolean
    var
        NPDesigner: Codeunit "NPR NPDesigner";
    begin
        exit(NPDesigner.AddAssetToManifest(ManifestId, AssetTableNumber, Assets, ExternalTemplateId, NotInsertedAssets));
    end;



    procedure RemoveAssetFromManifest(ManifestId: Guid; AssetTableNumber: Integer; AssetId: Guid): Boolean
    var
        NPDesigner: Codeunit "NPR NPDesigner";
    begin
        exit(NPDesigner.RemoveAssetFromManifest(ManifestId, AssetTableNumber, AssetId));
    end;

    procedure RemoveAssetFromManifest(ManifestId: Guid; AssetTableNumber: Integer; Assets: List of [Guid]; var NotRemovedAssets: List of [Guid]): Boolean
    var
        NPDesigner: Codeunit "NPR NPDesigner";
    begin
        exit(NPDesigner.RemoveAssetFromManifest(ManifestId, AssetTableNumber, Assets, NotRemovedAssets));
    end;



    procedure GetManifestUrl(ManifestId: Guid; var Url: Text[250]): Boolean
    var
        NPDesigner: Codeunit "NPR NPDesigner";
    begin
        exit(NPDesigner.GetManifestUrl(ManifestId, Url));
    end;

    procedure GetManifestUrlForAsset(AssetTableNumber: Integer; AssetId: Guid; var Url: Text[250]): Boolean
    var
        NPDesigner: Codeunit "NPR NPDesigner";
    begin
        exit(NPDesigner.GetManifestUrlForAsset(AssetTableNumber, AssetId, Url));
    end;

    procedure GetManifest(ManifestId: Guid) JManifest: JsonObject
    var
        NPDesigner: Codeunit "NPR NPDesigner";
    begin
        exit(NPDesigner.GetManifest(ManifestId));
    end;
}