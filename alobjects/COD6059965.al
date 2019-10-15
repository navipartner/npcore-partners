codeunit 6059965 "MPOS Webservice"
{
    // NPR5.34/CLVA/20170703 CASE 280444 Upgrading MPOS functionality to transcendence
    // NPR5.36/CLVA/20170830 CASE 288630 Added register handling
    // NPR5.38/CLVA/20170830 CASE 297273 Added function GetCompanyInfo
    // NPR5.51/CLVA/20190808 CASE 364011 Added functions SetTransactionResponse, ParseNetsJson, GetString and GetInt


    trigger OnRun()
    var
        WebService: Record "Web Service";
    begin
        Clear(WebService);

        if not WebService.Get(WebService."Object Type"::Codeunit, 'mpos_service') then begin
            WebService.Init;
            WebService."Object Type" := WebService."Object Type"::Codeunit;
            WebService."Service Name" := 'mpos_service';
            WebService."Object ID" := 6059965;
            WebService.Published := true;
            WebService.Insert;
        end;
    end;

    var
        EmptyJasonResult: Label '{}';

    [Scope('Personalization')]
    procedure GetCompanyLogo() PictureBase64: Text
    var
        CompanyInformation: Record "Company Information";
        BinaryReader: DotNet npNetBinaryReader;
        MemoryStream: DotNet npNetMemoryStream;
        Convert: DotNet npNetConvert;
        InStr: InStream;
    begin
        CompanyInformation.Get;

        CompanyInformation.CalcFields(Picture);
        if CompanyInformation.Picture.HasValue then begin
            CompanyInformation.Picture.CreateInStream(InStr);
            MemoryStream := InStr;
            BinaryReader := BinaryReader.BinaryReader(InStr);
            PictureBase64 := Convert.ToBase64String(BinaryReader.ReadBytes(MemoryStream.Length));
            MemoryStream.Dispose;
            Clear(MemoryStream);
        end;

        exit(PictureBase64);
    end;

    [Scope('Personalization')]
    procedure GetRegisterList() RegisterList: Text
    var
        Register: Record Register;
        Counter: Integer;
    begin
        if Register.FindFirst then begin
            repeat
                if Counter = 0 then
                    RegisterList += StrSubstNo('%1 - %2', Register."Register No.", Register.Description)
                else
                    RegisterList += StrSubstNo(',%1 - %2', Register."Register No.", Register.Description);
                Counter += 1;
            until Register.Next = 0;
        end;

        exit(RegisterList);
    end;

    [Scope('Personalization')]
    procedure SetRegister(CurrentUser: Code[50]; RegisterId: Code[10]): Boolean
    var
        Register: Record Register;
        UserSetup: Record "User Setup";
        POSUnitIdentity: Record "POS Unit Identity";
    begin
        if not UserSetup.Get(CurrentUser) then
            exit;

        if not Register.Get(RegisterId) then
            exit;

        if UserSetup."Backoffice Register No." <> RegisterId then begin
            UserSetup.Validate("Backoffice Register No.", RegisterId);
            UserSetup.Modify(true);
        end;

        //NPR5.36-
        POSUnitIdentity.SetRange("Device ID", 'WebBrowser');
        if POSUnitIdentity.FindSet then begin
            if POSUnitIdentity."Default POS Unit No." <> RegisterId then begin
                POSUnitIdentity.Validate("Default POS Unit No.", RegisterId);
                POSUnitIdentity.Modify(true);
            end;
        end;
        //NPR5.36+

        exit(true);
    end;

    [Scope('Personalization')]
    procedure GetCompanyInfo(): Text
    var
        CompanyInformation: Record "Company Information";
        BinaryReader: DotNet npNetBinaryReader;
        MemoryStream: DotNet npNetMemoryStream;
        Convert: DotNet npNetConvert;
        InStr: InStream;
        JObject: DotNet JObject;
        JTokenWriter: DotNet npNetJTokenWriter;
        Base64String: Text;
        MPOSHelperFunctions: Codeunit "MPOS Helper Functions";
    begin
        CompanyInformation.Get;

        CompanyInformation.CalcFields(Picture);
        if CompanyInformation.Picture.HasValue then begin
            CompanyInformation.Picture.CreateInStream(InStr);
            MemoryStream := InStr;
            BinaryReader := BinaryReader.BinaryReader(InStr);
            Base64String := Convert.ToBase64String(BinaryReader.ReadBytes(MemoryStream.Length));
            MemoryStream.Dispose;
            Clear(MemoryStream);
        end;

        JTokenWriter := JTokenWriter.JTokenWriter;
        with JTokenWriter do begin
            WriteStartObject;
            WritePropertyName('Base64Image');
            WriteValue(Base64String);
            WritePropertyName('Username');
            WriteValue(MPOSHelperFunctions.GetUsername());
            WritePropertyName('DatabaseName');
            WriteValue(MPOSHelperFunctions.GetDatabaseName());
            WritePropertyName('TenantID');
            WriteValue(MPOSHelperFunctions.GetTenantID());
            WritePropertyName('CompanyName');
            WriteValue(CompanyName);
            WriteEndObject;
            JObject := Token;
        end;

        exit(JObject.ToString);
    end;

    local procedure "// EFT Api"()
    begin
    end;

    [Scope('Personalization')]
    procedure SetTransactionResponse(json: Text): Boolean
    begin
        if json = '' then
            exit(false);

        exit(ParseNetsTransactionJson(json));
    end;

    [Scope('Personalization')]
    procedure SetEODResponse(json: Text): Boolean
    begin
        if json = '' then
            exit(false);

        exit(ParseNetsEODJson(json));
    end;

    local procedure "// Helpers"()
    begin
    end;

    local procedure ParseNetsTransactionJson(ResponsData: Text): Boolean
    var
        JToken: DotNet JToken;
        JObject: DotNet JObject;
        IStream: InStream;
        BigTextVar: BigText;
        Ostream: OutStream;
        TransactionNo: Integer;
        MPOSNetsTransactions: Record "MPOS Nets Transactions";
    begin
        if ResponsData = EmptyJasonResult then
            exit(false);

        JToken := JObject.Parse(ResponsData);

        TransactionNo := GetInt(JToken, 'transactionNo');

        if not MPOSNetsTransactions.Get(TransactionNo) then
            exit(false);

        BigTextVar.AddText(ResponsData);
        MPOSNetsTransactions."Response Json".CreateOutStream(Ostream);
        BigTextVar.Write(Ostream);
        MPOSNetsTransactions.Modify(true);
        Commit;

        MPOSNetsTransactions."Callback Result" := GetInt(JToken, 'result');
        MPOSNetsTransactions."Callback StatusDescription" := GetString(JToken, 'statusDescription');

        if MPOSNetsTransactions."Callback Result" <> 99 then begin
            MPOSNetsTransactions."Callback AccumulatorUpdate" := GetInt(JToken, 'accumulatorUpdate');
            MPOSNetsTransactions."Callback IssuerId" := GetInt(JToken, 'issuerId');
            MPOSNetsTransactions."Callback TruncatedPan" := GetString(JToken, 'truncatedPan');
            MPOSNetsTransactions."Callback EncryptedPan" := GetString(JToken, 'encryptedPan');
            MPOSNetsTransactions."Callback Timestamp" := GetString(JToken, 'timestamp');
            MPOSNetsTransactions."Callback VerificationMethod" := GetInt(JToken, 'verificationMethod');
            MPOSNetsTransactions."Callback SessionNumber" := GetString(JToken, 'sessionNumber');
            MPOSNetsTransactions."Callback StanAuth" := GetString(JToken, 'stanAuth');
            MPOSNetsTransactions."Callback SequenceNumber" := GetString(JToken, 'sequenceNumber');
            MPOSNetsTransactions."Callback TotalAmount" := GetInt(JToken, 'totalAmount');
            MPOSNetsTransactions."Callback TipAmount" := GetInt(JToken, 'tipAmount');
            MPOSNetsTransactions."Callback SurchargeAmount" := GetInt(JToken, 'surchargeAmount');
            MPOSNetsTransactions."Callback AcquiereMerchantID" := GetString(JToken, 'acquiereMerchantID');
            MPOSNetsTransactions."Callback CardIssuerName" := GetString(JToken, 'cardIssuerName');
            MPOSNetsTransactions."Callback TCC" := GetString(JToken, 'TCC');
            MPOSNetsTransactions."Callback AID" := GetString(JToken, 'AID');
            MPOSNetsTransactions."Callback TVR" := GetString(JToken, 'TVR');
            MPOSNetsTransactions."Callback TSI" := GetString(JToken, 'TSI');
            MPOSNetsTransactions."Callback ATC" := GetString(JToken, 'ATC');
            MPOSNetsTransactions."Callback AED" := GetString(JToken, 'AED');
            MPOSNetsTransactions."Callback IAC" := GetString(JToken, 'IAC');
            MPOSNetsTransactions."Callback OrganisationNumber" := GetString(JToken, 'organisationNumber');
            MPOSNetsTransactions."Callback BankAgent" := GetString(JToken, 'bankAgent');
            MPOSNetsTransactions."Callback AccountType" := GetString(JToken, 'accountType');
            MPOSNetsTransactions."Callback OptionalData" := GetString(JToken, 'optionalData');
            MPOSNetsTransactions."Callback ResponseCode" := GetString(JToken, 'responseCode');
            MPOSNetsTransactions."Callback RejectionSource" := GetInt(JToken, 'rejectionSource');
            MPOSNetsTransactions."Callback RejectionReason" := GetString(JToken, 'rejectionReason');
            MPOSNetsTransactions."Callback MerchantReference" := GetString(JToken, 'merchantReference');

            MPOSNetsTransactions.Handled := true;

            Clear(BigTextVar);
            BigTextVar.AddText(GetString(JToken, 'receipt1'));
            MPOSNetsTransactions."Callback Receipt 1".CreateOutStream(Ostream);
            BigTextVar.Write(Ostream);

            Clear(BigTextVar);
            BigTextVar.AddText(GetString(JToken, 'receipt2'));
            MPOSNetsTransactions."Callback Receipt 2".CreateOutStream(Ostream);
            BigTextVar.Write(Ostream);
        end;

        MPOSNetsTransactions.Modify(true);

        exit(true);
    end;

    local procedure ParseNetsEODJson(ResponsData: Text): Boolean
    var
        JToken: DotNet JToken;
        JObject: DotNet JObject;
        IStream: InStream;
        BigTextVar: BigText;
        Ostream: OutStream;
        MPOSEODRecipts: Record "MPOS EOD Recipts";
    begin
        if ResponsData = EmptyJasonResult then
            exit(false);

        JToken := JObject.Parse(ResponsData);

        MPOSEODRecipts.Init;
        MPOSEODRecipts.Created := CurrentDateTime;
        MPOSEODRecipts."Created By" := UserId;

        BigTextVar.AddText(ResponsData);
        MPOSEODRecipts."Response Json".CreateOutStream(Ostream);
        BigTextVar.Write(Ostream);

        MPOSEODRecipts.Insert(true);
        Commit;

        MPOSEODRecipts."Callback Timestamp" := GetString(JToken, 'timestamp');
        MPOSEODRecipts."Callback Device Id" := GetString(JToken, 'deviceid');
        MPOSEODRecipts."Callback Register No." := GetString(JToken, 'registerno');

        Clear(BigTextVar);
        BigTextVar.AddText(GetString(JToken, 'receipt1'));
        MPOSEODRecipts."Callback Receipt 1".CreateOutStream(Ostream);
        BigTextVar.Write(Ostream);

        MPOSEODRecipts.Modify(true);

        exit(true);
    end;

    local procedure GetString(var JToken: DotNet JToken; JTokenName: Text): Text
    var
        JsonValue: Text;
    begin
        JsonValue := Format(JToken.SelectToken(JTokenName));
        if UpperCase(JsonValue) = 'NULL' then
            exit('');

        exit(JsonValue);
    end;

    local procedure GetInt(var JToken: DotNet JToken; JTokenName: Text): Integer
    var
        JsonValue: Text;
        JsonIntValue: Integer;
    begin
        JsonValue := Format(JToken.SelectToken(JTokenName));
        if UpperCase(JsonValue) = 'NULL' then
            exit(0);

        if Evaluate(JsonIntValue, JsonValue) then
            exit(JsonIntValue)
        else
            exit(0);
    end;
}

