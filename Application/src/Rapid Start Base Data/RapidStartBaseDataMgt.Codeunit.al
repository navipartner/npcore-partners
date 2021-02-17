codeunit 6014594 "NPR RapidStart Base Data Mgt."
{
    EventSubscriberInstance = Manual;
    [EventSubscriber(ObjectType::Table, Database::"Config. Package Table", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertConfigPackageTable(RunTrigger: Boolean; var Rec: Record "Config. Package Table")
    begin
        if (not TableObjectExists(Rec."Table ID")) then begin
            PreprocessNonExistingTable(Rec."Table ID", Rec."Package Code");
        end;
    end;

    local procedure TableObjectExists(TableID: Integer): Boolean
    var
        tableMetadata: Record "Table Metadata";
        configXmlExc: Codeunit "Config. XML Exchange";
    begin
        exit(configXmlExc.TableObjectExists(TableID));
    end;

    local procedure PreprocessNonExistingTable(TableId: Integer; PackageCode: Code[20])
    var
        ConfigPackageField: Record "Config. Package Field";
        Field: Record Field;
        FCounter: Integer;
    begin
        Field.SetRange(TableNo, TableId);
        if Field.FindSet() then begin
            repeat
                ConfigPackageField.Init();
                ConfigPackageField."Package Code" := PackageCode;
                ConfigPackageField."Table ID" := Field.TableNo;
                ConfigPackageField."Field ID" := Field."No.";
                if not ConfigPackageField.insert then;
            until Field.Next() = 0;
        end;
    end;

    procedure GetAllPackagesInBlobStorage(URL: Text; var Packages: List of [Text])
    var
        httpClient: HttpClient;
        httpResponseMessage: HttpResponseMessage;
        XMLDoc: XmlDocument;
        inStream: InStream;
        XMLNode: XmlNode;
        XMLNodeList: XmlNodeList;
        XMLInnerNode: XmlNode;
    begin
        httpClient.Get(URL, httpResponseMessage);
        httpResponseMessage.Content.ReadAs(inStream);
        XmlDocument.ReadFrom(inStream, XMLDoc);

        XMLDoc.SelectNodes('//Blob/Name', XMLNodeList);

        foreach XMLNode in XMLNodeList do begin
            Packages.Add(XMLNode.AsXmlElement().InnerText);
        end;
    end;

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
        httpRequestMessage: HttpRequestMessage;
        httpResponseMessage: HttpResponseMessage;
        file: Text;
        ConfirmImportQst: Label 'WARNING:\This will import test data in base & NPR tables.\Are you sure you want to continue?';
    begin
        if GuiAllowed then
            if not Confirm(ConfirmImportQst) then
                exit;

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
        ConfigPackageManagement.ApplyPackage(ConfigPackage, ConfigPackageTable, TRUE);
    end;
}