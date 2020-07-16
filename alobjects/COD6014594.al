codeunit 6014594 "RapidStart Base Data Mgt."
{
    trigger OnRun()
    begin
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

    procedure ImportPackage(URL: Text; PackageCode: Text)
    var
        configPackage: Record "Config. Package";
        configPackageTable: Record "Config. Package Table";
        configPackageManagement: Codeunit "Config. Package Management";
        configXMLExchange: Codeunit "Config. XML Exchange";
        inStream: InStream;
        file: Text;
        compressedBlob: Codeunit "Temp Blob";
        outStream: OutStream;
        decompressedBlob: Codeunit "Temp Blob";
        httpClient: HttpClient;
        httpRequestMessage: HttpRequestMessage;
        httpResponseMessage: HttpResponseMessage;
    begin
        if GuiAllowed then begin
            if not Confirm('WARNING:\This will import test data in base & NPR tables.\Are you sure you want to continue?') then
                exit;
        end;

        IF configPackage.GET(PackageCode) THEN BEGIN
            configPackage.DELETE(TRUE);
        END;

        httpClient.Get(URL, httpResponseMessage);
        httpResponseMessage.Content.ReadAs(inStream);

        compressedBlob.CreateOutStream(outStream);
        CopyStream(outStream, inStream);
        configXMLExchange.DecompressPackageToBlob(compressedBlob, decompressedBlob);
        decompressedBlob.CreateInStream(inStream);

        ConfigXMLExchange.ImportPackageXMLFromStream(inStream);
        ConfigPackage.GET(PackageCode);
        ConfigPackage.SETRECFILTER;
        ConfigPackageTable.SETRANGE("Package Code", ConfigPackage.Code);
        ConfigPackageManagement.ApplyPackage(ConfigPackage, ConfigPackageTable, TRUE);
    end;


}