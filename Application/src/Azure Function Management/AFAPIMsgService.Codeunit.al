codeunit 6151576 "NPR AF API - Msg Service"
{
    // NPR5.38/CLVA/20171024 CASE 289636 AF API - Msg Service
    // NPR5.40/CLVA/20180315 CASE 307195 Added CreateSMSBody
    // NPR5.42/CLVA/20180315 CASE 308861 Added function CreateSite


    trigger OnRun()
    var
        AuditRoll: Record "NPR Audit Roll";
    begin
        AuditRoll.FindLast;
        Message(CreateSMSBody(AuditRoll.RecordId, 6014410, ''));
    end;

    var
        SITEALREADYCREATED: Label 'Site is already created';
        SITEDONOTEXIST: Label 'Site do not exist';
        DELETESITE: Label 'If you delete the site, all links to the site will be broken';
        ABORTDELETESITE: Label 'Site deletion was cancelled';

    procedure CreateSMSBodyBySalesTicket("Sales Ticket No.": Code[20]): Text
    var
        AFSetup: Record "NPR AF Setup";
        JObject: DotNet JObject;
        JTokenWriter: DotNet NPRNetJTokenWriter;
        TextString: Text;
        AFHelperFunctions: Codeunit "NPR AF Helper Functions";
    begin
        if "Sales Ticket No." = '' then
            exit;

        if not AFSetup.Get then
            exit;

        AFSetup.TestField("Web Service Url");
        AFSetup.TestField("Msg Service - NAV WS User");
        AFSetup.TestField("Msg Service - NAV WS Password");

        JTokenWriter := JTokenWriter.JTokenWriter;
        with JTokenWriter do begin
            WriteStartObject;
            WritePropertyName('type');
            WriteValue(AFSetup."Msg Service - Source Type");
            WritePropertyName('url');
            WriteValue(GetWebServiceUrl(AFSetup."Web Service Url"));
            WritePropertyName('user');
            WriteValue(AFSetup."Msg Service - NAV WS User");
            WritePropertyName('password');
            WriteValue(AFSetup."Msg Service - NAV WS Password");
            WritePropertyName('id');
            WriteValue("Sales Ticket No.");
            WriteEndObject;
            JObject := Token;
        end;


        TextString := AFSetup."Msg Service - Base Web Url" + AFSetup."Msg Service - Name" + '/?p=' + UrlEncodeString(EncryptString(JObject.ToString, AFSetup."Msg Service - Encryption Key", true));
        exit(TextString);
    end;

    procedure CreateSMSBody(RecID: RecordID; ReportID: Integer; Filename: Text): Text
    var
        AFSetup: Record "NPR AF Setup";
        JObject: DotNet JObject;
        JTokenWriter: DotNet NPRNetJTokenWriter;
        TextString: Text;
        AFHelperFunctions: Codeunit "NPR AF Helper Functions";
        RecRef: RecordRef;
        AllObj: Record AllObj;
    begin
        //-NPR5.40 [307195]
        if not RecRef.Get(RecID) then
            exit;

        if not AllObj.Get(OBJECTTYPE::Report, ReportID) then
            exit;

        if not AFSetup.Get then
            exit;

        //Not mandatory. If filename is blank it will be DateTime.Now.Ticks.ToString()
        if StrPos(Filename, '.') > 0 then
            if (StrLen(Filename) > 1) and (StrPos(Filename, '.') > 1) then
                Filename := CopyStr(Filename, 1, StrPos(Filename, '.') - 1)
            else
                Filename := '';

        AFSetup.TestField("Web Service Url");
        AFSetup.TestField("Msg Service - NAV WS User");
        AFSetup.TestField("Msg Service - NAV WS Password");

        JTokenWriter := JTokenWriter.JTokenWriter;
        with JTokenWriter do begin
            WriteStartObject;
            WritePropertyName('type');
            WriteValue(AFSetup."Msg Service - Source Type");
            WritePropertyName('url');
            WriteValue(GetWebServiceUrl(AFSetup."Web Service Url"));
            WritePropertyName('user');
            WriteValue(AFSetup."Msg Service - NAV WS User");
            WritePropertyName('password');
            WriteValue(AFSetup."Msg Service - NAV WS Password");
            WritePropertyName('recordID');
            WriteValue(Format(RecID, 0, 9));
            WritePropertyName('reportID');
            WriteValue(Format(ReportID));
            WritePropertyName('filename');
            WriteValue(Filename);
            WriteEndObject;
            JObject := Token;
        end;

        TextString := AFSetup."Msg Service - Base Web Url" + AFSetup."Msg Service - Name" + '/?p=' + UrlEncodeString(EncryptString(JObject.ToString, AFSetup."Msg Service - Encryption Key", true));
        exit(TextString);
        //+NPR5.40 [307195]
    end;

    procedure PostSiteInfo(var AFSetup: Record "NPR AF Setup"; SiteAction: Option Create,Update,Delete)
    var
        Parameters: DotNet NPRNetDictionary_Of_T_U;
        AFManagement: Codeunit "NPR AF Management";
        AFHelperFunctions: Codeunit "NPR AF Helper Functions";
        HttpResponseMessage: DotNet NPRNetHttpResponseMessage;
        Path: Text;
        Window: Dialog;
        OutStr: OutStream;
        JObject: DotNet JObject;
        JTokenWriter: DotNet NPRNetJTokenWriter;
        StringContent: DotNet NPRNetStringContent;
        Ostream: OutStream;
        TextString: Text;
        Status: Boolean;
        Encoding: DotNet NPRNetEncoding;
        SiteUrl: Text;
        SiteActionInt: Integer;
    begin
        AFSetup.TestField("Msg Service - Name");

        if SiteAction = SiteAction::Create then
            if AFSetup."Msg Service - Site Created" then
                Error(SITEALREADYCREATED);

        if SiteAction = SiteAction::Delete then
            if not AFSetup."Msg Service - Site Created" then
                Error(SITEDONOTEXIST)
            else
                if not Confirm(DELETESITE, true) then
                    Error(ABORTDELETESITE);

        if SiteAction in [SiteAction::Update, SiteAction::Delete] then
            if not AFSetup."Msg Service - Site Created" then
                Error(SITEDONOTEXIST);

        SiteActionInt := SiteAction;

        JTokenWriter := JTokenWriter.JTokenWriter;
        with JTokenWriter do begin
            WriteStartObject;
            WritePropertyName('SiteName');
            WriteValue(AFSetup."Msg Service - Name");
            WritePropertyName('SiteTitle');
            WriteValue(AFSetup."Msg Service - Title");
            WritePropertyName('SiteDescription');
            WriteValue(AFSetup."Msg Service - Description");
            WritePropertyName('SiteImage');
            WriteValue(GetPDFSiteImage(AFSetup, 0));
            WritePropertyName('SiteIco');
            WriteValue(GetPDFSiteImage(AFSetup, 1));
            WritePropertyName('SiteUrl');
            WriteValue(AFSetup."Msg Service - Base Web Url");
            WritePropertyName('SiteAction');
            WriteValue(Format(SiteActionInt));
            WriteEndObject;
            JObject := Token;
        end;

        StringContent := StringContent.StringContent(JObject.ToString, Encoding.UTF8, 'application/json');

        Parameters := Parameters.Dictionary();
        Parameters.Add('baseurl', AFSetup."Msg Service - Base Url");
        Parameters.Add('restmethod', 'POST');
        Parameters.Add('path', AFRequestUrl(AFSetup."Msg Service - API Routing", AFSetup."Msg Service - API Key"));
        Parameters.Add('httpcontent', StringContent);

        Status := AFManagement.CallRESTWebService(Parameters, HttpResponseMessage);
        TextString := HttpResponseMessage.Content.ReadAsStringAsync.Result;

        if Status then begin
            if (StrLen(TextString) < 3) then begin
                case SiteAction of
                    SiteAction::Create:
                        begin
                            AFSetup."Msg Service - Site Created" := true;
                            AFSetup.Modify(true);
                            SiteUrl := AFSetup."Msg Service - Base Web Url" + AFSetup."Msg Service - Name";
                            HyperLink(SiteUrl);
                        end;
                    SiteAction::Update:
                        begin
                            SiteUrl := AFSetup."Msg Service - Base Web Url" + AFSetup."Msg Service - Name";
                            HyperLink(SiteUrl);
                        end;
                    SiteAction::Delete:
                        begin
                            AFSetup."Msg Service - Site Created" := false;
                            AFSetup.Modify(true);
                        end;
                end;
            end else begin
                if SiteAction = SiteAction::Delete then begin
                    AFSetup."Msg Service - Site Created" := false;
                    AFSetup.Modify(true);
                end else
                    Error(TextString);
            end;
        end else begin
            Error(TextString);
        end;
    end;

    procedure GetPDFSiteImage(var AFSetup: Record "NPR AF Setup"; Type: Option Image,Ico) Base64String: Text
    var
        BinaryReader: DotNet NPRNetBinaryReader;
        MemoryStream: DotNet NPRNetMemoryStream;
        Convert: DotNet NPRNetConvert;
        InStr: InStream;
    begin
        AFSetup.CalcFields("Msg Service - Image", "Msg Service - Icon");

        if Type = Type::Ico then
            if not AFSetup."Msg Service - Icon".HasValue then
                exit(Base64String)
            else
                AFSetup."Msg Service - Icon".CreateInStream(InStr);

        if Type = Type::Image then
            if not AFSetup."Msg Service - Image".HasValue then
                exit(Base64String)
            else
                AFSetup."Msg Service - Image".CreateInStream(InStr);

        MemoryStream := InStr;
        BinaryReader := BinaryReader.BinaryReader(InStr);

        Base64String := Convert.ToBase64String(BinaryReader.ReadBytes(MemoryStream.Length));

        MemoryStream.Dispose;
        Clear(MemoryStream);

        exit(Base64String);
    end;

    local procedure EncryptString(toEncrypt: Text; encryptionKey: Text; useHashing: Boolean): Text
    var
        keyArray: DotNet NPRNetArray;
        toEncryptArray: DotNet NPRNetArray;
        UTF8Encoding: DotNet NPRNetUTF8Encoding;
        tdes: DotNet NPRNetTripleDESCryptoServiceProvider;
        hashmd5: DotNet NPRNetMD5CryptoServiceProvider;
        cTransform: DotNet NPRNetICryptoTransform;
        resultArray: DotNet NPRNetArray;
        Convert: DotNet NPRNetConvert;
        CipherModeENUM: DotNet NPRNetCipherMode;
        PaddingModeENUM: DotNet NPRNetPaddingMode;
    begin
        if (toEncrypt = '') or (encryptionKey = '') then
            exit;

        toEncryptArray := UTF8Encoding.UTF8.GetBytes(toEncrypt);

        if (useHashing) then begin
            hashmd5 := hashmd5.MD5CryptoServiceProvider();
            keyArray := hashmd5.ComputeHash(UTF8Encoding.UTF8.GetBytes(encryptionKey));
            hashmd5.Clear();
        end else
            keyArray := UTF8Encoding.UTF8.GetBytes(encryptionKey);

        tdes := tdes.TripleDESCryptoServiceProvider();
        tdes.Key := keyArray;
        tdes.Mode := CipherModeENUM.ECB;
        tdes.Padding := PaddingModeENUM.PKCS7;

        cTransform := tdes.CreateEncryptor();
        resultArray := cTransform.TransformFinalBlock(toEncryptArray, 0, toEncryptArray.Length);
        tdes.Clear();

        exit(Convert.ToBase64String(resultArray, 0, resultArray.Length));
    end;

    local procedure DecryptString(cipherString: Text; encryptionKey: Text; useHashing: Boolean): Text
    var
        keyArray: DotNet NPRNetArray;
        toEncryptArray: DotNet NPRNetArray;
        UTF8Encoding: DotNet NPRNetUTF8Encoding;
        tdes: DotNet NPRNetTripleDESCryptoServiceProvider;
        hashmd5: DotNet NPRNetMD5CryptoServiceProvider;
        cTransform: DotNet NPRNetICryptoTransform;
        resultArray: DotNet NPRNetArray;
        Convert: DotNet NPRNetConvert;
        CipherModeENUM: DotNet NPRNetCipherMode;
        PaddingModeENUM: DotNet NPRNetPaddingMode;
    begin
        if (cipherString = '') or (encryptionKey = '') then
            exit;

        toEncryptArray := Convert.FromBase64String(cipherString);

        if (useHashing) then begin
            hashmd5 := hashmd5.MD5CryptoServiceProvider();
            keyArray := hashmd5.ComputeHash(UTF8Encoding.UTF8.GetBytes(encryptionKey));
            hashmd5.Clear();
        end else
            keyArray := UTF8Encoding.UTF8.GetBytes(encryptionKey);

        tdes := tdes.TripleDESCryptoServiceProvider();
        tdes.Key := keyArray;
        tdes.Mode := CipherModeENUM.ECB;
        tdes.Padding := PaddingModeENUM.PKCS7;

        cTransform := tdes.CreateDecryptor();
        resultArray := cTransform.TransformFinalBlock(toEncryptArray, 0, toEncryptArray.Length);
        tdes.Clear();

        exit(UTF8Encoding.UTF8.GetString(resultArray));
    end;

    local procedure UrlEncodeString(TextToEncode: Text): Text
    var
        WebUtility: DotNet NPRNetWebUtility;
    begin
        exit(WebUtility.UrlEncode(TextToEncode));
    end;

    local procedure UrlDecodeString(TextToDecode: Text): Text
    var
        WebUtility: DotNet NPRNetWebUtility;
    begin
        exit(WebUtility.UrlDecode(TextToDecode));
    end;

    local procedure AFRequestUrl(APIRouting: Text; APIKey: Text): Text
    begin
        exit(APIRouting + '?code=' + APIKey);
    end;

    local procedure IsAFEnabled(): Boolean
    var
        AFSetup: Record "NPR AF Setup";
    begin
        if AFSetup.Get() then
            exit(AFSetup."Enable Azure Functions");

        exit(false);
    end;

    local procedure GetWebServiceUrl(CustomWSUrl: Text) SOAPUrl: Text
    var
        WebService: Record "Web Service";
    begin
        if CustomWSUrl <> '' then
            exit(CustomWSUrl);

        if not WebService.Get(WebService."Object Type"::Codeunit, 'azurefunction_service') then begin
            WebService.Init;
            WebService."Object Type" := WebService."Object Type"::Codeunit;
            WebService."Service Name" := 'azurefunction_service';
            WebService."Object ID" := 6151572;
            WebService.Published := true;
            WebService.Insert;
        end;

        SOAPUrl := GetUrl(CLIENTTYPE::SOAP, CompanyName, OBJECTTYPE::Codeunit, 6151572);
        exit(SOAPUrl);
    end;

    procedure CreateSite(var AFSetup: Record "NPR AF Setup")
    var
        Parameters: DotNet NPRNetDictionary_Of_T_U;
        AFManagement: Codeunit "NPR AF Management";
        AFHelperFunctions: Codeunit "NPR AF Helper Functions";
        HttpResponseMessage: DotNet NPRNetHttpResponseMessage;
        Path: Text;
        Window: Dialog;
        OutStr: OutStream;
        JObject: DotNet JObject;
        JTokenWriter: DotNet NPRNetJTokenWriter;
        StringContent: DotNet NPRNetStringContent;
        Ostream: OutStream;
        TextString: Text;
        Status: Boolean;
        Encoding: DotNet NPRNetEncoding;
        SiteUrl: Text;
        SiteActionInt: Integer;
    begin
        JTokenWriter := JTokenWriter.JTokenWriter;
        with JTokenWriter do begin
            WriteStartObject;
            WritePropertyName('SiteName');
            WriteValue(AFSetup."Msg Service - Name");
            WritePropertyName('SiteTitle');
            WriteValue(AFSetup."Msg Service - Title");
            WritePropertyName('SiteDescription');
            WriteValue(AFSetup."Msg Service - Description");
            WritePropertyName('SiteImage');
            WriteValue(GetPDFSiteImage(AFSetup, 0));
            WritePropertyName('SiteIco');
            WriteValue(GetPDFSiteImage(AFSetup, 1));
            WritePropertyName('SiteUrl');
            WriteValue(AFSetup."Msg Service - Base Web Url");
            WritePropertyName('SiteAction');
            WriteValue(Format(SiteActionInt));
            WriteEndObject;
            JObject := Token;
        end;

        StringContent := StringContent.StringContent(JObject.ToString, Encoding.UTF8, 'application/json');

        Parameters := Parameters.Dictionary();
        Parameters.Add('baseurl', AFSetup."Msg Service - Base Url");
        Parameters.Add('restmethod', 'POST');
        Parameters.Add('path', AFRequestUrl(AFSetup."Msg Service - API Routing", AFSetup."Msg Service - API Key"));
        Parameters.Add('httpcontent', StringContent);

        Status := AFManagement.CallRESTWebService(Parameters, HttpResponseMessage);
        TextString := HttpResponseMessage.Content.ReadAsStringAsync.Result;

        AFSetup."Msg Service - Site Created" := true;
        AFSetup.Modify(true);
    end;
}

