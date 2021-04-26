codeunit 6059965 "NPR MPOS Webservice"
{
    trigger OnRun()
    var
        WebServiceMgt: Codeunit "Web Service Management";
    begin
        WebServiceMgt.CreateTenantWebService(5, Codeunit::"NPR MPOS Webservice", 'mpos_service', true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Web Service Aggregate", 'OnBeforeInsertEvent', '', true, true)]
    local procedure OnBeforeInsertWebServiceAggregate(var Rec: Record "Web Service Aggregate"; RunTrigger: Boolean)
    var
    begin
        if Rec."Object Type" <> Rec."Object Type"::Codeunit then
            exit;
        if Rec."Service Name" <> 'mpos_service' then
            exit;

        Rec."All Tenants" := false;
    end;

    var
        EmptyJasonResult: Label '{}';

    procedure GetCompanyLogo() PictureBase64: Text
    var
        CompanyInformation: Record "Company Information";
        Base64Convert: Codeunit "Base64 Convert";
        InStr: InStream;
    begin
        CompanyInformation.Get;

        CompanyInformation.CalcFields(Picture);
        if CompanyInformation.Picture.HasValue then begin
            CompanyInformation.Picture.CreateInStream(InStr);
            PictureBase64 := Base64Convert.ToBase64(InStr);
        end;

        exit(PictureBase64);
    end;

    procedure GetRegisterList() RegisterList: Text
    var
        Register: Record "NPR Register";
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

    procedure SetRegister(CurrentUser: Code[50]; RegisterId: Code[10]): Boolean
    var
        Register: Record "NPR Register";
        UserSetup: Record "User Setup";
        POSUnitIdentity: Record "NPR POS Unit Identity";
    begin
        if not UserSetup.Get(CurrentUser) then
            exit;

        if not Register.Get(RegisterId) then
            exit;

        if UserSetup."NPR Backoffice Register No." <> RegisterId then begin
            UserSetup.Validate("NPR Backoffice Register No.", RegisterId);
            UserSetup.Modify(true);
        end;

        POSUnitIdentity.SetRange("Device ID", 'WebBrowser');
        if POSUnitIdentity.FindSet then begin
            if POSUnitIdentity."Default POS Unit No." <> RegisterId then begin
                POSUnitIdentity.Validate("Default POS Unit No.", RegisterId);
                POSUnitIdentity.Modify(true);
            end;
        end;

        exit(true);
    end;

    procedure GetCompanyInfo(): Text
    var
        CompanyInformation: Record "Company Information";
        InStr: InStream;
        JObject: JsonObject;
        Base64String: Text;
        MPOSHelperFunctions: Codeunit "NPR MPOS Helper Functions";
        Base64Convert: Codeunit "Base64 Convert";
        Result: Text;
    begin
        CompanyInformation.Get;

        CompanyInformation.CalcFields(Picture);
        if CompanyInformation.Picture.HasValue then begin
            CompanyInformation.Picture.CreateInStream(InStr);
            Base64String := Base64Convert.ToBase64(InStr);
        end;

        JObject.Add('Base64Image', Base64String);
        JObject.Add('Username', MPOSHelperFunctions.GetUsername());
        JObject.Add('DatabaseName', MPOSHelperFunctions.GetDatabaseName());
        JObject.Add('TenantID', MPOSHelperFunctions.GetTenantID());
        JObject.Add('CompanyName', CompanyName);
        JObject.WriteTo(Result);
        exit(Result);
    end;

    local procedure "// EFT Api"()
    begin
    end;

    procedure SetTransactionResponse(json: Text): Boolean
    begin
        if json = '' then
            exit(false);

        exit(ParseNetsTransactionJson(json));
    end;

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
        JToken: JsonToken;
        JObject: JsonObject;
        IStream: InStream;
        BigTextVar: BigText;
        Ostream: OutStream;
        TransactionNo: Integer;
        MPOSNetsTransactions: Record "NPR MPOS Nets Transactions";
    begin
        if ResponsData = EmptyJasonResult then
            exit(false);

        JObject.ReadFrom(ResponsData);

        TransactionNo := GetInt(JObject, 'transactionNo');

        if not MPOSNetsTransactions.Get(TransactionNo) then
            exit(false);

        BigTextVar.AddText(ResponsData);
        MPOSNetsTransactions."Response Json".CreateOutStream(Ostream);
        BigTextVar.Write(Ostream);
        MPOSNetsTransactions.Modify(true);
        Commit;

        MPOSNetsTransactions."Callback Result" := GetInt(JObject, 'result');
        MPOSNetsTransactions."Callback StatusDescription" := GetString(JObject, 'statusDescription');

        if MPOSNetsTransactions."Callback Result" <> 99 then begin
            MPOSNetsTransactions."Callback AccumulatorUpdate" := GetInt(JObject, 'accumulatorUpdate');
            MPOSNetsTransactions."Callback IssuerId" := GetInt(JObject, 'issuerId');
            MPOSNetsTransactions."Callback TruncatedPan" := GetString(JObject, 'truncatedPan');
            MPOSNetsTransactions."Callback EncryptedPan" := GetString(JObject, 'encryptedPan');
            MPOSNetsTransactions."Callback Timestamp" := GetString(JObject, 'timestamp');
            MPOSNetsTransactions."Callback VerificationMethod" := GetInt(JObject, 'verificationMethod');
            MPOSNetsTransactions."Callback SessionNumber" := GetString(JObject, 'sessionNumber');
            MPOSNetsTransactions."Callback StanAuth" := GetString(JObject, 'stanAuth');
            MPOSNetsTransactions."Callback SequenceNumber" := GetString(JObject, 'sequenceNumber');
            MPOSNetsTransactions."Callback TotalAmount" := GetInt(JObject, 'totalAmount');
            MPOSNetsTransactions."Callback TipAmount" := GetInt(JObject, 'tipAmount');
            MPOSNetsTransactions."Callback SurchargeAmount" := GetInt(JObject, 'surchargeAmount');
            MPOSNetsTransactions."Callback AcquiereMerchantID" := GetString(JObject, 'acquiereMerchantID');
            MPOSNetsTransactions."Callback CardIssuerName" := GetString(JObject, 'cardIssuerName');
            MPOSNetsTransactions."Callback TCC" := GetString(JObject, 'TCC');
            MPOSNetsTransactions."Callback AID" := GetString(JObject, 'AID');
            MPOSNetsTransactions."Callback TVR" := GetString(JObject, 'TVR');
            MPOSNetsTransactions."Callback TSI" := GetString(JObject, 'TSI');
            MPOSNetsTransactions."Callback ATC" := GetString(JObject, 'ATC');
            MPOSNetsTransactions."Callback AED" := GetString(JObject, 'AED');
            MPOSNetsTransactions."Callback IAC" := GetString(JObject, 'IAC');
            MPOSNetsTransactions."Callback OrganisationNumber" := GetString(JObject, 'organisationNumber');
            MPOSNetsTransactions."Callback BankAgent" := GetString(JObject, 'bankAgent');
            MPOSNetsTransactions."Callback AccountType" := GetString(JObject, 'accountType');
            MPOSNetsTransactions."Callback ResponseCode" := GetString(JObject, 'responseCode');
            MPOSNetsTransactions."Callback RejectionSource" := GetInt(JObject, 'rejectionSource');
            MPOSNetsTransactions."Callback RejectionReason" := GetString(JObject, 'rejectionReason');
            MPOSNetsTransactions."Callback MerchantReference" := GetString(JObject, 'merchantReference');

            MPOSNetsTransactions.Handled := true;

            Clear(BigTextVar);
            BigTextVar.AddText(GetString(JObject, 'receipt1'));
            MPOSNetsTransactions."Callback Receipt 1".CreateOutStream(Ostream);
            BigTextVar.Write(Ostream);

            Clear(BigTextVar);
            BigTextVar.AddText(GetString(JObject, 'receipt2'));
            MPOSNetsTransactions."Callback Receipt 2".CreateOutStream(Ostream);
            BigTextVar.Write(Ostream);
        end;

        MPOSNetsTransactions.Modify(true);

        exit(true);
    end;

    local procedure ParseNetsEODJson(ResponsData: Text): Boolean
    var
        JObject: JsonObject;
        IStream: InStream;
        BigTextVar: BigText;
        Ostream: OutStream;
        MPOSEODRecipts: Record "NPR MPOS EOD Recipts";
    begin
        if ResponsData = EmptyJasonResult then
            exit(false);

        JObject.ReadFrom(ResponsData);

        MPOSEODRecipts.Init;
        MPOSEODRecipts.Created := CurrentDateTime;
        MPOSEODRecipts."Created By" := UserId;

        BigTextVar.AddText(ResponsData);
        MPOSEODRecipts."Response Json".CreateOutStream(Ostream);
        BigTextVar.Write(Ostream);

        MPOSEODRecipts.Insert(true);
        Commit;

        MPOSEODRecipts."Callback Timestamp" := GetString(JObject, 'timestamp');
        MPOSEODRecipts."Callback Device Id" := GetString(JObject, 'deviceid');
        MPOSEODRecipts."Callback Register No." := GetString(JObject, 'registerno');

        Clear(BigTextVar);
        BigTextVar.AddText(GetString(JObject, 'receipt1'));
        MPOSEODRecipts."Callback Receipt 1".CreateOutStream(Ostream);
        BigTextVar.Write(Ostream);

        MPOSEODRecipts.Modify(true);

        exit(true);
    end;

    local procedure GetString(var JObject: JsonObject; JTokenName: Text): Text
    var
        JToken: JsonToken;
    begin
        if JObject.SelectToken(JTokenName, JToken) then
            exit(JToken.AsValue().AsText())
        else
            exit('');
    end;

    local procedure GetInt(var JObject: JsonObject; JTokenName: Text): Integer
    var
        JToken: JsonToken;
    begin
        if JObject.SelectToken(JTokenName, JToken) then
            exit(JToken.AsValue().AsInteger())
        else
            exit(0);
    end;
}

