codeunit 6014589 "GCP Mgt."
{
    // NPR5.22/MMV/20160401 CASE 228382 Created CU
    // 
    // NP Google Account Info:
    //   navipartnerprint@gmail.com
    // 
    //   OAuth2 Client ID:
    //   991631407104-i42nu6qrb75n8it7s3cf79tr942mccoi.apps.googleusercontent.com
    //   OAuth2 Client secret:
    //   8wgdbmpow5hkSXpDVKx4pKNi
    // 
    // Google API Project (Above account is owner):
    //   https://console.developers.google.com/apis/credentials?project=cloudprint-1254
    // 
    // For supported content types (MIME types) see https://developers.google.com/cloud-print/docs/appInterfaces#submit
    // 
    // NPR5.23/MMV/20160519 CASE 241549 Reduced max file size from test value (15MB) to 2MB.
    // NPR5.26/MMV /20160824 CASE 246209 Added support for in-memory base64 printing.
    //                                   Added support for stored print job specifications.
    //                                   Renamed to GCP Mgt.
    //                                   Refactored.
    // NPR5.29/MMV /20161207 CASE 260366 Handle BLOB tokens.
    // NPR5.30/MMV /20170208 CASE 261964 Refactored completely.
    // NPR5.51/MMV /20190617 CASE 358889 Improved lock timing.
    // NPR5.53/MMV /20191029 CASE 374501 Fixed #358889


    trigger OnRun()
    begin
    end;

    var
        Text000001: Label 'Invalid authentication code. Please copy the code directly from the google URL above';
        Text000002: Label 'No Google Cloud Print setup found. Please setup a google account first.';
        Text000003: Label 'An error occured with Google Cloud Print';
        Text000004: Label 'An error occured while attempting to authenticate Google account';
        Text000005: Label 'Existing Google Account Setup found. Do you wish to continue and overwrite the current setup?';
        Text000006: Label 'Google account attached to this company successfully';
        Text000007: Label 'Overwrite existing print settings?';

    local procedure "// Operations"()
    begin
    end;

    procedure PrintFile(PrinterID: Text; var Content: DotNet npNetMemoryStream; ContentType: Text; TicketCJT: Text; Title: Text; Tag: Text) Success: Boolean
    var
        AccessTokenValue: Text;
        RefreshTokenValue: Text;
        API: Codeunit "GCP API";
        Token: Record "OAuth Token";
    begin
        Commit;

        GetTokens(AccessTokenValue, RefreshTokenValue);
        API.SetAccessTokenValue(AccessTokenValue);
        API.SetRefreshTokenValue(RefreshTokenValue);

        if TicketCJT = '' then
            TicketCJT := BuildCJT('"1.0"', '', '', '', '', '', '', '', '', '', '', '', '');  //Use default printer settings

        if Title = '' then
            Title := 'NaviPartner Document Print';

        Success := API.SubmitJob(PrinterID, Title, TicketCJT, Content, ContentType, Tag, true);

        if API.GetAccessTokenValue() <> AccessTokenValue then
            Token.AddOrUpdate('GOOGLE_PRINT_ACCESS', API.GetAccessTokenValue(), API.GetAccessTokenTimeStamp(), API.GetAccessTokenExpiresIn());

        //-NPR5.51 [358889]
        Commit; //In case access token was refreshed manually or as part of job ping-pong.
        //+NPR5.51 [358889]

        if not Success then begin
            if GetLastErrorText() <> '' then
                Error(GetLastErrorText)
            else
                Error(Text000003)
        end;

        exit(Success);
    end;

    procedure CreateAccountTokens(AuthCode: Text)
    var
        ErrorMsg: Text;
        API: Codeunit "GCP API";
        Token: Record "OAuth Token";
    begin
        if AuthCode = '' then
            Error(Text000001);

        if Token.Get('GOOGLE_PRINT_ACCESS') or Token.Get('GOOGLE_PRINT_REFRESH') then
            if not Confirm(Text000005) then
                exit;

        ClearLastError();

        if API.AuthenticateUser(AuthCode) then
            if Token.AddOrUpdate('GOOGLE_PRINT_ACCESS', API.GetAccessTokenValue(), API.GetAccessTokenTimeStamp(), API.GetAccessTokenExpiresIn())
               and Token.AddOrUpdate('GOOGLE_PRINT_REFRESH', API.GetRefreshTokenValue(), API.GetRefreshTokenTimeStamp(), API.GetRefreshTokenExpiresIn())
              then begin
                Message(Text000006);
                exit;
            end;

        if GetLastErrorText() <> '' then
            ErrorMsg := GetLastErrorText()
        else
            ErrorMsg := Text000004;
        Error(ErrorMsg);
    end;

    procedure LookupPrinters(var PrinterIDOut: Text) Success: Boolean
    var
        AccessTokenValue: Text;
        RefreshTokenValue: Text;
        TempRetailList: Record "Retail List" temporary;
        RetailList: Page "Retail List";
        JObject: DotNet JObject;
        i: Integer;
        API: Codeunit "GCP API";
        Token: Record "OAuth Token";
    begin
        GetTokens(AccessTokenValue, RefreshTokenValue);
        API.SetAccessTokenValue(AccessTokenValue);
        API.SetRefreshTokenValue(RefreshTokenValue);

        Success := API.GetPrinters(JObject, true);

        if Success then begin
            JObject := JObject.SelectToken('printers');
            if JObject.Count > 0 then begin
                for i := 0 to JObject.Count - 1 do begin
                    TempRetailList.Number += 1;
                    TempRetailList.Choice := Format(JObject.Item(i).Item('displayName'));
                    TempRetailList.Value := Format(JObject.Item(i).Item('id'));
                    TempRetailList.Insert;
                end;

                RetailList.SetRec(TempRetailList);
                RetailList.SetShowValue(true);
                RetailList.LookupMode(true);
                if RetailList.RunModal = ACTION::LookupOK then begin
                    RetailList.GetRecord(TempRetailList);
                    PrinterIDOut := TempRetailList.Value;
                end else
                    Success := false;
            end;
        end;

        if API.GetAccessTokenValue() <> AccessTokenValue then
            Token.AddOrUpdate('GOOGLE_PRINT_ACCESS', API.GetAccessTokenValue(), API.GetAccessTokenTimeStamp(), API.GetAccessTokenExpiresIn());

        exit(Success);
    end;

    procedure GetPrinterInfo(ID: Text; var JObject: DotNet JObject) Success: Boolean
    var
        API: Codeunit "GCP API";
        AccessTokenValue: Text;
        RefreshTokenValue: Text;
        Token: Record "OAuth Token";
    begin
        GetTokens(AccessTokenValue, RefreshTokenValue);
        API.SetAccessTokenValue(AccessTokenValue);
        API.SetRefreshTokenValue(RefreshTokenValue);

        Success := API.LookupPrinter(ID, JObject, true);

        if API.GetAccessTokenValue() <> AccessTokenValue then
            Token.AddOrUpdate('GOOGLE_PRINT_ACCESS', API.GetAccessTokenValue(), API.GetAccessTokenTimeStamp(), API.GetAccessTokenExpiresIn());

        exit(Success);
    end;

    local procedure "// Aux"()
    begin
    end;

    procedure BuildCJT(Version: Text; Color: Text; Copies: Text; VendorTicketItem: Text; PageOrientation: Text; Duplex: Text; DPI: Text; MediaSize: Text; Collate: Text; Margins: Text; FitToPage: Text; PageRange: Text; ReverseOrder: Text): Text
    var
        CJT: Text;
        PrintSettings: Text;
    begin
        //Define printer options in a CJT JSON format specified by Google:
        //https://developers.google.com/cloud-print/docs/cdd#cjt

        //Required fields
        CJT :=
        '{' +
          '"version":' + Version + ',' +
          '"print":{';

        //Optional fields

        if VendorTicketItem <> '' then
            PrintSettings += '"vendor_ticket_item":' + VendorTicketItem + ',';

        if Color <> '' then
            PrintSettings += '"color":' + Color + ',';

        if Duplex <> '' then
            PrintSettings += '"duplex":' + Duplex + ',';

        if PageOrientation <> '' then
            PrintSettings += '"page_orientation":' + PageOrientation + ',';

        if Copies <> '' then
            PrintSettings += '"copies":' + Copies + ',';

        if Margins <> '' then
            PrintSettings += '"margins":' + Margins + ',';

        if DPI <> '' then
            PrintSettings += '"dpi":' + DPI + ',';

        if FitToPage <> '' then
            PrintSettings += '"fit_to_page":' + FitToPage + ',';

        if PageRange <> '' then
            PrintSettings += '"page_range":' + PageRange + ',';

        if MediaSize <> '' then
            PrintSettings += '"media_size":' + MediaSize + ',';

        if Collate <> '' then
            PrintSettings += '"collate":' + Collate + ',';

        if ReverseOrder <> '' then
            PrintSettings += '"reverse_order":' + ReverseOrder + ',';

        if PrintSettings <> '' then begin
            PrintSettings := CopyStr(PrintSettings, 1, StrLen(PrintSettings) - 1);
            CJT += PrintSettings;
        end;

        CJT += '}}';

        exit(CJT)
    end;

    procedure GetCustomCJT(PrinterID: Text; ObjectType: Option "Report","Codeunit"; ObjectID: Integer): Text
    var
        GCPSetup: Record "GCP Setup";
        InStream: InStream;
        JSON: Text;
    begin
        GCPSetup.SetAutoCalcFields("Cloud Job Ticket");
        if not GCPSetup.Get(PrinterID, ObjectType, ObjectID) then
            if not GCPSetup.Get(PrinterID, ObjectType, 0) then
                exit('');

        if not GCPSetup."Cloud Job Ticket".HasValue then
            exit('');

        GCPSetup."Cloud Job Ticket".CreateInStream(InStream, TEXTENCODING::UTF8);
        InStream.Read(JSON);
        exit(JSON);
    end;

    procedure GetAuthURL(): Text
    var
        response_type: Text;
        redirect_uri: Text;
        scope: Text;
        state: Text;
        login_hint: Text;
        AuthURL: Text;
        access_type: Text;
        ClientID: Text;
    begin
        response_type := 'code';
        scope := 'https://www.googleapis.com/auth/cloudprint';
        state := '';
        login_hint := '';
        access_type := 'offline';
        AuthURL := 'https://accounts.google.com/o/oauth2/v2/auth';
        redirect_uri := 'urn:ietf:wg:oauth:2.0:oob';
        ClientID := '991631407104-i42nu6qrb75n8it7s3cf79tr942mccoi.apps.googleusercontent.com';

        exit(AuthURL + '?scope=' + scope + '&redirect_uri=' + redirect_uri + '&response_type=' + response_type + '&client_id=' + ClientID + '&access_type=' + access_type);
    end;

    procedure SetTicketOptions(var GCPSetup: Record "GCP Setup")
    var
        JObject: DotNet JObject;
        GCPTicketOptions: Page "GCP Ticket Options";
        OutStream: OutStream;
        TicketJson: Text;
        InStream: InStream;
    begin
        GCPSetup.SetAutoCalcFields("Cloud Job Ticket");
        if not GCPSetup.FindFirst then
            exit;

        if not GetPrinterInfo(GCPSetup."Printer ID", JObject) then
            exit;

        JObject := JObject.SelectToken('printers[0].capabilities.printer');
        if not (JObject.Count > 0) then
            exit;

        if GCPSetup."Cloud Job Ticket".HasValue then begin
            //Load existing blob into page view
            GCPSetup."Cloud Job Ticket".CreateInStream(InStream);
            InStream.Read(TicketJson);
            GCPTicketOptions.LoadExistingTicketJSON(TicketJson);
        end;

        GCPTicketOptions.LookupMode(true);
        GCPTicketOptions.SetPrinterJSON(JObject.ToString());
        if GCPTicketOptions.RunModal = ACTION::LookupOK then begin
            TicketJson := GCPTicketOptions.BuildNewTicketJSON();
            if TicketJson <> '' then begin
                if GCPSetup."Cloud Job Ticket".HasValue then
                    if not Confirm(Text000007) then
                        exit;

                GCPSetup."Cloud Job Ticket".CreateOutStream(OutStream, TEXTENCODING::UTF8);
                OutStream.Write(TicketJson);
                GCPSetup.Modify;
            end;
        end;
    end;

    procedure ViewPrinterInfo(PrinterID: Text)
    var
        JSON: Text;
        TempBlob: Codeunit "Temp Blob";
        OutStream: OutStream;
        InStream: InStream;
        FileName: Variant;
        JObject: DotNet JObject;
    begin
        if not GetPrinterInfo(PrinterID, JObject) then
            exit;

        TempBlob.CreateOutStream(OutStream);
        OutStream.Write(JObject.ToString());
        if not TempBlob.HasValue then
            exit;

        TempBlob.CreateInStream(InStream);
        FileName := StrSubstNo('%1 Config.json', PrinterID);
        DownloadFromStream(InStream, 'Printer Config', '', 'JSON File (*.json)|*.json', FileName);
    end;

    [TryFunction]
    procedure TryParseJSON(JSON: Text; Path: Text; var JObjectOut: DotNet JObject)
    begin
        Clear(JObjectOut);
        JObjectOut := JObjectOut.Parse(JSON);
        JObjectOut := JObjectOut.SelectToken(Path);
        if not (JObjectOut.Count > 0) then
            Error('');
    end;

    local procedure GetTokens(var OutAccessTokenValue: Text; var OutRefreshTokenValue: Text)
    var
        Token: Record "OAuth Token";
        API: Codeunit "GCP API";
    begin
        Clear(OutAccessTokenValue);
        Clear(OutRefreshTokenValue);

        if Token.Get('GOOGLE_PRINT_REFRESH') then
            OutRefreshTokenValue := Token.GetValue();

        //-NPR5.51 [358889]
        Token.LockTable;
        //+NPR5.51 [358889]
        if Token.Get('GOOGLE_PRINT_ACCESS') then begin
            if Token.IsExpired then begin
                API.SetRefreshTokenValue(OutRefreshTokenValue);
                API.RefreshAccessToken();
                Token.AddOrUpdate('GOOGLE_PRINT_ACCESS', API.GetAccessTokenValue, API.GetAccessTokenTimeStamp, API.GetAccessTokenExpiresIn);
                OutAccessTokenValue := API.GetAccessTokenValue;
                //-NPR5.53 [374501]
                //    COMMIT;
                //+NPR5.53 [374501]
            end else
                OutAccessTokenValue := Token.GetValue();
        end;

        if (StrLen(OutAccessTokenValue) = 0) or (StrLen(OutRefreshTokenValue) = 0) then
            Error(Text000002);

        //-NPR5.53 [374501]
        Commit;
        //+NPR5.53 [374501]
    end;
}

