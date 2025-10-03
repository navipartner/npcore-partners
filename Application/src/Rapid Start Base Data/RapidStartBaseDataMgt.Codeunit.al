codeunit 6014594 "NPR RapidStart Base Data Mgt."
{
    Access = Internal;
    EventSubscriberInstance = Manual;

#if BC17 or BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::"Config. Package Table", 'OnBeforeInsertEvent', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::"Config. Package Table", OnBeforeInsertEvent, '', false, false)]
#endif
    local procedure OnBeforeInsertConfigPackageTable(RunTrigger: Boolean; var Rec: Record "Config. Package Table")
    begin
        if (not TableObjectExists(Rec."Table ID")) then begin
            PreprocessNonExistingTable(Rec."Table ID", Rec."Package Code");
        end;
    end;

#if BC17 or BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Variety Wrapper", 'OnBeforeCheckModifyAllowed', '', true, false)]
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Variety Wrapper", OnBeforeCheckModifyAllowed, '', true, false)]
#endif
    local procedure SkipVarietyCheckDuringConfigPackageImport(var IsAllowed: Boolean; var IsHandled: Boolean)
    begin
        IsAllowed := true;
        IsHandled := true;
    end;

    local procedure TableObjectExists(TableID: Integer): Boolean
    var
        configXmlExc: Codeunit "Config. XML Exchange";
    begin
        exit(configXmlExc.TableObjectExists(TableID));
    end;

    local procedure PreprocessNonExistingTable(TableId: Integer; PackageCode: Code[20])
    var
        ConfigPackageField: Record "Config. Package Field";
        Field: Record Field;
    begin
        Field.SetRange(TableNo, TableId);
        if Field.FindSet() then begin
            repeat
                ConfigPackageField.Init();
                ConfigPackageField."Package Code" := PackageCode;
                ConfigPackageField."Table ID" := Field.TableNo;
                ConfigPackageField."Field ID" := Field."No.";
                if not ConfigPackageField.Insert() then;
            until Field.Next() = 0;
        end;
    end;

    [NonDebuggable]
    procedure GetAllPackagesInBlobStorage(URL: Text; var Packages: List of [Text])
    var
        httpClient: HttpClient;
        httpResponseMessage: HttpResponseMessage;
        XMLDoc: XmlDocument;
        inStream: InStream;
        XMLNode: XmlNode;
        XMLNodeList: XmlNodeList;
    begin
        CheckAndUnblockOutboundHttpCallsForInternalDevPlatform();
        httpClient.Get(URL, httpResponseMessage);
        httpResponseMessage.Content.ReadAs(inStream);
        XmlDocument.ReadFrom(inStream, XMLDoc);

        XMLDoc.SelectNodes('//Blob/Name', XMLNodeList);

        foreach XMLNode in XMLNodeList do begin
            Packages.Add(XMLNode.AsXmlElement().InnerText);
        end;
    end;

    [NonDebuggable]
    procedure GetAllPackagesMetadataInBlobStorage(URL: Text; var Packages: List of [Text])
    var
        HttpClient: HttpClient;
        HttpResponseMessage: HttpResponseMessage;
        XMLDoc: XmlDocument;
        InStream: InStream;
        XMLNode: XmlNode;
        XMLNodeList: XmlNodeList;
        HelperXMLNode: XMLNode;
    begin
        CheckAndUnblockOutboundHttpCallsForInternalDevPlatform();
        HttpClient.Get(URL, HttpResponseMessage);
        httpResponseMessage.Content.ReadAs(InStream);
        XmlDocument.ReadFrom(InStream, XMLDoc);

        XMLDoc.SelectNodes('//Blob/Metadata', XMLNodeList);
        foreach XMLNode in XMLNodeList do
            if XMLNode.SelectSingleNode('Description', HelperXMLNode) then
                Packages.Add(HelperXMLNode.AsXmlElement().InnerText())
            else
                Packages.Add('');
    end;

    [NonDebuggable]
    procedure ImportPackage(URL: Text; PackageCode: Text; AdjustPackageTableNames: Boolean)
    var
        configPackage: Record "Config. Package";
        configPackageTable: Record "Config. Package Table";
        configPackageManagement: Codeunit "Config. Package Management";
        configXMLExchange: Codeunit "Config. XML Exchange";
        compressedBlob: Codeunit "Temp Blob";
        decompressedBlob: Codeunit "Temp Blob";
        PckgeTableNameModifier: Codeunit "NPR Pckge Table Name Modifier";
        inStream: InStream;
        outStream: OutStream;
        httpClient: HttpClient;
        httpResponseMessage: HttpResponseMessage;
        ConfirmImportQst: Label 'WARNING:\This will import test data in base & NPR tables.\Are you sure you want to continue?';
    begin
        if GuiAllowed then
            if not Confirm(ConfirmImportQst) then
                exit;

        CheckAndUnblockOutboundHttpCallsForInternalDevPlatform();

        if configPackage.Get(PackageCode) then
            configPackage.Delete(true);

        httpClient.Get(URL, httpResponseMessage);
        httpResponseMessage.Content.ReadAs(inStream);

        compressedBlob.CreateOutStream(outStream);
        CopyStream(outStream, inStream);
        configXMLExchange.DecompressPackageToBlob(compressedBlob, decompressedBlob);
        decompressedBlob.CreateInStream(inStream);

        if AdjustPackageTableNames then
            BindSubscription(PckgeTableNameModifier);
        ConfigXMLExchange.ImportPackageXMLFromStream(inStream);
        if AdjustPackageTableNames then
            UnbindSubscription(PckgeTableNameModifier);

        ConfigPackage.Get(PackageCode);
        ConfigPackage.SetRecFilter();
        ConfigPackageTable.SETRANGE("Package Code", ConfigPackage.Code);

        RemoveObsoleteTables(configPackageTable);

        ConfigPackageManagement.ApplyPackage(ConfigPackage, ConfigPackageTable, TRUE);
    end;

    local procedure RemoveObsoleteTables(var ConfigPackageTable: Record "Config. Package Table")
    begin
        if ConfigPackageTable.FindSet(true) then begin
            repeat
                if not TableObjectExists(ConfigPackageTable."Table ID") then begin
                    ConfigPackageTable.Delete();
                end;
            until ConfigPackageTable.Next() = 0;
        end;
    end;

    /// <summary>
    /// Local method that will enable outbound HTTP calls for the internal dev platform.
    /// This method might be needed somewhere else in the future but until that momement let's keep it
    /// here, by purpose. We don't want to enable outbound HTTP calls blindly here and there.
    /// </summary>
    local procedure CheckAndUnblockOutboundHttpCallsForInternalDevPlatform()
    var
        NAVAppSetting: Record "NAV App Setting";
#if not BC1700
        EnvironmentInfo: Codeunit "Environment Information";
#endif
        AppInfo: ModuleInfo;
        WebUrl: Text;
    begin
        // If UI sesssion let's force the user to click on the button to enable outbound HTTP calls.
        // This is a safety measure to avoid enabling outbound HTTP calls by mistake.
        if (GuiAllowed) then
            exit;

        // For good reason we don't want to enable outbound HTTP calls for the SaaS infrastructure without a human interaction.
#if not BC1700
        if (EnvironmentInfo.IsSaaSInfrastructure()) then
            exit;
#endif

        WebUrl := GetUrl(ClientType::Web);

        // Let's enable it for the dev platform only for now.
        if (not (WebUrl.Contains('dynamics-retail.net'))) then
            exit;

        NavApp.GetCurrentModuleInfo(AppInfo);

        // Let's exit silently and avoid permission errors here.
        if ((not NAVAppSetting.ReadPermission) and (not NAVAppSetting.WritePermission)) then
            exit;

        if not NAVAppSetting.Get(AppInfo.Id) then begin
            NAVAppSetting.Init();
            NAVAppSetting."App ID" := AppInfo.Id;
            if not NAVAppSetting.Insert() then
                exit;
        end;

        if (NAVAppSetting."Allow HttpClient Requests") then
            exit;

        NAVAppSetting."Allow HttpClient Requests" := true;
        if not NavAppSetting.Modify(true) then;
    end;
}
