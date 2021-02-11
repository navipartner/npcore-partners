codeunit 6014594 "NPR RapidStart Base Data Mgt."
{
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