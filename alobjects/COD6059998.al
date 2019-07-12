codeunit 6059998 "Client Diagnostics Data Mgt."
{
    // NPR5.40/MHA /20180328 CASE 308907 Object created - Client Diagnostics Data Collection Mgt.
    // NPR5.42/CLVA/20180508 CASE 313575 Combined the collection of client ip address and geolocation in a single api.ipstack.com request
    // NPR5.44/MHA /20180724 CASE 323170 Changed Json parsing functions to Try functions
    // TM1.39/THRO/20181126  CASE 334644 Replaced Coudeunit 1 by Wrapper Codeunit
    // NPR5.50/MMV /20190529 CASE 356506 Send diagnostics on user session for logout to workaround session creation related crashes.

    TableNo = "Client Diagnostics";

    trigger OnRun()
    begin
        //-NPR5.50 [356506]
        //CollectClientData(Rec);
        CollectClientData(Rec, true);
        //+NPR5.50 [356506]
    end;

    var
        ActiveSession: Record "Active Session";
        NPRetailSetup: Record "NP Retail Setup";

    local procedure CollectClientData(var ClientDiagnostics: Record "Client Diagnostics"; NewSession: Boolean)
    var
        ClientDiagnosticsNpCaseMgt: Codeunit "Client Diagnostics NpCase Mgt.";
        PrevRec: Text;
        HasLicenseInfo: Boolean;
        HasPOSInfo: Boolean;
    begin
        if CommitClientDiagnostics(ClientDiagnostics) then begin
            //-NPR5.50 [356506]
            //  ClientDiagnosticsNpCaseMgt.ScheduleSendClientDiagnostics(ClientDiagnostics)
            if NewSession then
                ClientDiagnosticsNpCaseMgt.ScheduleSendClientDiagnostics(ClientDiagnostics)
            else
                ClientDiagnosticsNpCaseMgt.Run(ClientDiagnostics);
            //+NPR5.50 [356506]
        end;

        if not FindMySession() then
            exit;

        if not ClientDiagnostics.Find then
            exit;

        PrevRec := Format(ClientDiagnostics);

        HasLicenseInfo := SetLicenseInfo(ClientDiagnostics);
        HasPOSInfo := SetGeoPosition(ClientDiagnostics);

        if PrevRec = Format(ClientDiagnostics) then
            exit;

        ClientDiagnostics."Login Info" := false;
        ClientDiagnostics."License Info" := HasLicenseInfo;
        ClientDiagnostics."Computer Info" := false;
        ClientDiagnostics."POS Info" := HasPOSInfo;
        ClientDiagnostics."Logout Info" := false;
        if CommitClientDiagnostics(ClientDiagnostics) then begin
            //-NPR5.50 [356506]
            //  ClientDiagnosticsNpCaseMgt.ScheduleSendClientDiagnostics(ClientDiagnostics)
            if NewSession then
                ClientDiagnosticsNpCaseMgt.ScheduleSendClientDiagnostics(ClientDiagnostics)
            else
                ClientDiagnosticsNpCaseMgt.Run(ClientDiagnostics);
            //+NPR5.50 [356506]
        end;
    end;

    local procedure LoginCurrUser()
    var
        ClientDiagnostics: Record "Client Diagnostics";
        PrevRec: Text;
        HasComputerInfo: Boolean;
        HasLoginInfo: Boolean;
    begin
        if not InitCurrentUser(ClientDiagnostics) then
            exit;

        PrevRec := Format(ClientDiagnostics);

        HasLoginInfo := SetLoginInfo(ClientDiagnostics);
        HasComputerInfo := SetComputerInfo(ClientDiagnostics);

        if PrevRec = Format(ClientDiagnostics) then
            exit;

        ClientDiagnostics."Login Info" := HasLoginInfo;
        ClientDiagnostics."License Info" := false;
        ClientDiagnostics."Computer Info" := HasComputerInfo;
        ClientDiagnostics."POS Info" := false;
        ClientDiagnostics."Logout Info" := false;
        ScheduleDataCollection(ClientDiagnostics);
    end;

    local procedure LogoutCurrUser()
    var
        ClientDiagnostics: Record "Client Diagnostics";
        ClientDiagnosticsNpCaseMgt: Codeunit "Client Diagnostics NpCase Mgt.";
        PrevRec: Text;
        HasLogoutInfo: Boolean;
    begin
        if not InitCurrentUser(ClientDiagnostics) then
            exit;

        PrevRec := Format(ClientDiagnostics);

        HasLogoutInfo := SetLogoutInfo(ClientDiagnostics);

        if PrevRec = Format(ClientDiagnostics) then
            exit;

        ClientDiagnostics."Login Info" := false;
        ClientDiagnostics."License Info" := false;
        ClientDiagnostics."Computer Info" := false;
        ClientDiagnostics."POS Info" := false;
        ClientDiagnostics."Logout Info" := HasLogoutInfo;
        //-NPR5.50 [356506]
        //ScheduleDataCollection(ClientDiagnostics);
        CollectClientData(ClientDiagnostics, false);
        //+NPR5.50 [356506]
    end;

    local procedure UpdatePOSClientType(POSClientType: Integer)
    var
        ClientDiagnostics: Record "Client Diagnostics";
        ClientDiagnosticsNpCaseMgt: Codeunit "Client Diagnostics NpCase Mgt.";
        PrevRec: Text;
        HasPOSInfo: Boolean;
    begin
        InitCurrentUser(ClientDiagnostics);

        PrevRec := Format(ClientDiagnostics);

        HasPOSInfo := SetPosClientType(POSClientType, ClientDiagnostics);

        if PrevRec = Format(ClientDiagnostics) then
            exit;

        ClientDiagnostics."Login Info" := false;
        ClientDiagnostics."License Info" := false;
        ClientDiagnostics."Computer Info" := false;
        ClientDiagnostics."POS Info" := HasPOSInfo;
        ClientDiagnostics."Logout Info" := false;
        ScheduleDataCollection(ClientDiagnostics);
    end;

    local procedure UpdateIPAddress(IPAddress: Text)
    var
        ClientDiagnostics: Record "Client Diagnostics";
        ClientDiagnosticsNpCaseMgt: Codeunit "Client Diagnostics NpCase Mgt.";
        PrevRec: Text;
        HasPOSInfo: Boolean;
    begin
        InitCurrentUser(ClientDiagnostics);

        PrevRec := Format(ClientDiagnostics);

        HasPOSInfo := SetIPAddress(IPAddress, ClientDiagnostics);

        if PrevRec = Format(ClientDiagnostics) then
            exit;

        ClientDiagnostics."Login Info" := false;
        ClientDiagnostics."License Info" := false;
        ClientDiagnostics."Computer Info" := false;
        ClientDiagnostics."POS Info" := HasPOSInfo;
        ClientDiagnostics."Logout Info" := false;
        ScheduleDataCollection(ClientDiagnostics);
    end;

    procedure ScheduleDataCollection(ClientDiagnostics: Record "Client Diagnostics")
    var
        NewSessionID: Integer;
    begin
        StartSession(NewSessionID, CODEUNIT::"Client Diagnostics Data Mgt.", CompanyName, ClientDiagnostics);
    end;

    local procedure CommitClientDiagnostics(ClientDiagnosticsFrom: Record "Client Diagnostics") HasNewInfo: Boolean
    var
        ClientDiagnosticsTo: Record "Client Diagnostics";
        PrevRec: Text;
    begin
        HasNewInfo := false;

        ClientDiagnosticsTo.LockTable;
        ClientDiagnosticsTo.SetPosition(ClientDiagnosticsFrom.GetPosition(false));
        if not ClientDiagnosticsTo.Find then begin
            HasNewInfo := true;
            ClientDiagnosticsTo.Insert;
        end;

        PrevRec := Format(ClientDiagnosticsTo);

        if ClientDiagnosticsFrom."Login Info" then
            TransferLoginInfo(ClientDiagnosticsFrom, ClientDiagnosticsTo);
        if ClientDiagnosticsFrom."License Info" then
            TransferLicenseInfo(ClientDiagnosticsFrom, ClientDiagnosticsTo);
        if ClientDiagnosticsFrom."Computer Info" then
            TransferComputerInfo(ClientDiagnosticsFrom, ClientDiagnosticsTo);
        if ClientDiagnosticsFrom."POS Info" then
            TransferPosInfo(ClientDiagnosticsFrom, ClientDiagnosticsTo);
        if ClientDiagnosticsFrom."Logout Info" then
            TransferLogoutInfo(ClientDiagnosticsFrom, ClientDiagnosticsTo);

        if PrevRec <> Format(ClientDiagnosticsTo) then begin
            HasNewInfo := true;
            ClientDiagnosticsTo.Modify;
        end;
        Commit;

        exit(HasNewInfo);
    end;

    local procedure "--- Subscribers"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014427, 'OnBeforeCompanyOpen', '', true, true)]
    local procedure OnBeforeCompanyOpen()
    begin
        if not (CurrentClientType in [CLIENTTYPE::Windows, CLIENTTYPE::Web, CLIENTTYPE::Tablet, CLIENTTYPE::Phone, CLIENTTYPE::Desktop]) then
            exit;

        LoginCurrUser();
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014427, 'OnBeforeCompanyClose', '', true, true)]
    local procedure OnBeforeCompanyClose()
    begin
        if not (CurrentClientType in [CLIENTTYPE::Windows, CLIENTTYPE::Web, CLIENTTYPE::Tablet, CLIENTTYPE::Phone, CLIENTTYPE::Desktop]) then
            exit;

        LogoutCurrUser();
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150743, 'OnTrackGeoLocationByIP', '', true, true)]
    local procedure OnTrackGeoLocationByIP(IPAddress: Text)
    begin
        UpdateIPAddress(IPAddress);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150700, 'OnInitializationComplete', '', true, true)]
    local procedure OnInitializationCompletePOSTSD()
    var
        ClientDiagnostics: Record "Client Diagnostics";
    begin
        UpdatePOSClientType(ClientDiagnostics."POS Client Type"::Transcendence);
    end;

    [EventSubscriber(ObjectType::Page, 6014651, 'OnInitializePageCompleted', '', true, true)]
    local procedure OnInitializePageCompletedPOSSTD()
    var
        ClientDiagnostics: Record "Client Diagnostics";
    begin
        UpdatePOSClientType(ClientDiagnostics."POS Client Type"::Standard);
    end;

    local procedure "--- Current User"()
    begin
    end;

    local procedure FindMySession(): Boolean
    var
        i: Integer;
    begin
        if (ActiveSession."Server Instance ID" = ServiceInstanceId) and
           (ActiveSession."Session ID" = SessionId) then
            exit(true);

        if ActiveSession.Get(ServiceInstanceId, SessionId) then
            exit(true);

        for i := 0 to 200 do begin
            Sleep(10);
            if ActiveSession.Get(ServiceInstanceId, SessionId) then
                exit(true);
        end;

        exit(false);
    end;

    procedure InitCurrentUser(var ClientDiagnostics: Record "Client Diagnostics"): Boolean
    begin
        if not FindMySession() then
            exit(false);

        ClientDiagnostics.Init;
        ClientDiagnostics.Username := UserId;
        ClientDiagnostics."Database Name" := ActiveSession."Database Name";
        ClientDiagnostics."Tenant ID" := TenantId;
        if ClientDiagnostics.Find then;

        exit(true);
    end;

    local procedure "--- Set Client Diagnostics"()
    begin
    end;

    local procedure SetComputerInfo(var ClientDiagnostics: Record "Client Diagnostics") HasNewInfo: Boolean
    var
        EnvironmentMgt: Codeunit "NPR Environment Mgt.";
        PrevRec: Text;
    begin
        if not ClientDiagnosticsEnabled() then
            exit(false);
        PrevRec := Format(ClientDiagnostics);

        ClientDiagnostics."Client Name" := ActiveSession."Client Computer Name";
        ClientDiagnostics."Serial Number" := SerialNumber;
        ClientDiagnostics."OS Version" := EnvironmentMgt.GetOSVersion();
        ClientDiagnostics."Mac Adresses" := GetMacAddress();
        ClientDiagnostics."Platform Version" := GetPlatformVersion();

        exit(PrevRec <> Format(ClientDiagnostics));
    end;

    local procedure SetLicenseInfo(var ClientDiagnostics: Record "Client Diagnostics") HasNewInfo: Boolean
    var
        User: Record User;
        PrevRec: Text;
    begin
        PrevRec := Format(ClientDiagnostics);

        if User.Get(ActiveSession."User SID") then
            ClientDiagnostics."License Type" := (User."License Type" + 1);
        ClientDiagnostics."License Name" := SearchForLicenseText('Licensed to             : ');
        ClientDiagnostics."No. of Full Users" := SearchForGranule('450');
        ClientDiagnostics."No. of ISV Users" := SearchForGranule('490');
        ClientDiagnostics."No. of Limited Users" := SearchForGranule('460');

        exit(PrevRec <> Format(ClientDiagnostics));
    end;

    local procedure SetLoginInfo(var ClientDiagnostics: Record "Client Diagnostics") HasNewInfo: Boolean
    var
        IComm: Record "I-Comm";
        User: Record User;
        SystemEventWrapper: Codeunit "System Event Wrapper";
        PrevRec: Text;
    begin
        PrevRec := Format(ClientDiagnostics);

        ClientDiagnostics."Last Logon Date" := Today;
        ClientDiagnostics."Last Logon Time" := Time;
        if User.Get(ActiveSession."User SID") then
            ClientDiagnostics."Full Name" := User."Full Name";
        ClientDiagnostics."Service Server Name" := ActiveSession."Server Computer Name";
        ClientDiagnostics."Service Instance" := ActiveSession."Server Instance Name";
        ClientDiagnostics."Company Name" := CompanyName;
        if IComm.Get then
            ClientDiagnostics."Company ID" := IComm."Customer No.";
        ClientDiagnostics."User Security ID" := ActiveSession."User SID";
        ClientDiagnostics."Windows Security ID" := Format(User."Windows Security ID");
        ClientDiagnostics."User Login Type" := ClientDiagnostics."User Login Type"::NAV;
        if ClientDiagnostics."Windows Security ID" <> '' then
            ClientDiagnostics."User Login Type" := ClientDiagnostics."User Login Type"::Windows;
        //-TM1.39 [334644]
        ClientDiagnostics."Application Version" := SystemEventWrapper.ApplicationBuild();
        //+TM1.39 [334644]
        exit(PrevRec <> Format(ClientDiagnostics));
    end;

    local procedure SetLogoutInfo(var ClientDiagnostics: Record "Client Diagnostics") HasNewInfo: Boolean
    var
        PrevRec: Text;
    begin
        PrevRec := Format(ClientDiagnostics);

        ClientDiagnostics."Last Logout Date" := Today;
        ClientDiagnostics."Last Logout Time" := Time;

        exit(PrevRec <> Format(ClientDiagnostics));
    end;

    local procedure SetPosClientType(POSClientType: Integer; var ClientDiagnostics: Record "Client Diagnostics") HasNewInfo: Boolean
    var
        PrevRec: Text;
    begin
        PrevRec := Format(ClientDiagnostics);

        ClientDiagnostics."POS Client Type" := POSClientType;

        exit(PrevRec <> Format(ClientDiagnostics));
    end;

    local procedure SetIPAddress(IPAddress: Text; var ClientDiagnostics: Record "Client Diagnostics") HasNewInfo: Boolean
    var
        Latitude: Decimal;
        Longitude: Decimal;
        JObject: DotNet npNetJObject;
        JToken: DotNet npNetJToken;
        PrevRec: Text;
    begin
        if not ClientDiagnosticsEnabled() then
            exit(false);

        //-NPR5.42
        if not TryParseJson(IPAddress, JToken) then
            exit(false);

        JObject := JObject.Parse(JToken.ToString());
        //-NPR5.44 [323170]
        // IPAddress := GetJsonValueAsText(JObject,'ip');
        // Latitude := GetJsonValueAsDecimal(JObject,'latitude');
        // Longitude := GetJsonValueAsDecimal(JObject,'longitude');
        // //+NPR5.42
        //
        // IF STRLEN(IPAddress) > MAXSTRLEN(ClientDiagnostics."IP Address") THEN
        //  EXIT(FALSE);
        //
        // IF ClientDiagnostics."IP Address" = IPAddress THEN
        //  EXIT(FALSE);
        //
        // ClientDiagnostics."IP Address" := IPAddress;
        //
        // //-NPR5.42
        // //ClientDiagnostics."Geolocation Latitude" := 0;
        // //ClientDiagnostics."Geolocation Longitude" := 0;
        // ClientDiagnostics."Geolocation Latitude" := Latitude;
        // ClientDiagnostics."Geolocation Longitude" := Longitude;
        // //+NPR5.42
        //
        //EXIT(TRUE);
        PrevRec := Format(ClientDiagnostics);

        if TryGetJsonValueAsText(JObject, 'ip', IPAddress) and (StrLen(IPAddress) <= MaxStrLen(ClientDiagnostics."IP Address")) then
            ClientDiagnostics."IP Address" := IPAddress;
        if TryGetJsonValueAsDecimal(JObject, 'latitude', Latitude) then
            ClientDiagnostics."Geolocation Latitude" := Latitude;
        if TryGetJsonValueAsDecimal(JObject, 'longitude', Longitude) then
            ClientDiagnostics."Geolocation Longitude" := Longitude;

        exit(PrevRec <> Format(ClientDiagnostics));
        //+NPR5.44 [323170]
    end;

    local procedure SetGeoPosition(var ClientDiagnostics: Record "Client Diagnostics") HasNewInfo: Boolean
    var
        POSGeolocation: Codeunit "POS Geolocation";
        PrevRec: Text;
    begin
        if not ClientDiagnosticsEnabled() then
            exit(false);
        if ClientDiagnostics."IP Address" = '' then
            exit(false);

        PrevRec := Format(ClientDiagnostics);

        if (ClientDiagnostics."Geolocation Latitude" = 0) or (ClientDiagnostics."Geolocation Longitude" = 0) then
            POSGeolocation.IPAddress2GeoPosition(ClientDiagnostics."IP Address", ClientDiagnostics."Geolocation Latitude", ClientDiagnostics."Geolocation Longitude");

        exit(PrevRec <> Format(ClientDiagnostics));
    end;

    local procedure "--- Transfer Client Diagnostics"()
    begin
    end;

    local procedure TransferComputerInfo(ClientDiagnosticsFrom: Record "Client Diagnostics"; var ClientDiagnosticsTo: Record "Client Diagnostics")
    begin
        ClientDiagnosticsTo."Client Name" := ClientDiagnosticsFrom."Client Name";
        ClientDiagnosticsTo."Serial Number" := ClientDiagnosticsFrom."Serial Number";
        ClientDiagnosticsTo."OS Version" := ClientDiagnosticsFrom."OS Version";
        ClientDiagnosticsTo."Mac Adresses" := ClientDiagnosticsFrom."Mac Adresses";
        ClientDiagnosticsTo."Platform Version" := ClientDiagnosticsFrom."Platform Version";
    end;

    local procedure TransferLicenseInfo(ClientDiagnosticsFrom: Record "Client Diagnostics"; var ClientDiagnosticsTo: Record "Client Diagnostics")
    begin
        ClientDiagnosticsTo."License Type" := ClientDiagnosticsFrom."License Type";
        ClientDiagnosticsTo."License Name" := ClientDiagnosticsFrom."License Name";
        ClientDiagnosticsTo."No. of Full Users" := ClientDiagnosticsFrom."No. of Full Users";
        ClientDiagnosticsTo."No. of ISV Users" := ClientDiagnosticsFrom."No. of ISV Users";
        ClientDiagnosticsTo."No. of Limited Users" := ClientDiagnosticsFrom."No. of Limited Users";
    end;

    local procedure TransferLoginInfo(ClientDiagnosticsFrom: Record "Client Diagnostics"; var ClientDiagnosticsTo: Record "Client Diagnostics")
    begin
        ClientDiagnosticsTo."Last Logon Date" := ClientDiagnosticsFrom."Last Logon Date";
        ClientDiagnosticsTo."Last Logon Time" := ClientDiagnosticsFrom."Last Logon Time";
        ClientDiagnosticsTo."Full Name" := ClientDiagnosticsFrom."Full Name";
        ClientDiagnosticsTo."Service Server Name" := ClientDiagnosticsFrom."Service Server Name";
        ClientDiagnosticsTo."Service Instance" := ClientDiagnosticsFrom."Service Instance";
        ClientDiagnosticsTo."Company Name" := ClientDiagnosticsFrom."Company Name";
        ClientDiagnosticsTo."Company ID" := ClientDiagnosticsFrom."Company ID";
        ClientDiagnosticsTo."User Security ID" := ClientDiagnosticsFrom."User Security ID";
        ClientDiagnosticsTo."Windows Security ID" := ClientDiagnosticsFrom."Windows Security ID";
        ClientDiagnosticsTo."User Login Type" := ClientDiagnosticsFrom."User Login Type";
        ClientDiagnosticsTo."Application Version" := ClientDiagnosticsFrom."Application Version";
    end;

    local procedure TransferLogoutInfo(ClientDiagnosticsFrom: Record "Client Diagnostics"; var ClientDiagnosticsTo: Record "Client Diagnostics")
    begin
        ClientDiagnosticsTo."Last Logout Date" := ClientDiagnosticsFrom."Last Logout Date";
        ClientDiagnosticsTo."Last Logout Time" := ClientDiagnosticsFrom."Last Logout Time";
    end;

    local procedure TransferPosInfo(ClientDiagnosticsFrom: Record "Client Diagnostics"; var ClientDiagnosticsTo: Record "Client Diagnostics")
    begin
        ClientDiagnosticsTo."POS Client Type" := ClientDiagnosticsFrom."POS Client Type";
        ClientDiagnosticsTo."IP Address" := ClientDiagnosticsFrom."IP Address";
        ClientDiagnosticsTo."Geolocation Latitude" := ClientDiagnosticsFrom."Geolocation Latitude";
        ClientDiagnosticsTo."Geolocation Longitude" := ClientDiagnosticsFrom."Geolocation Longitude";
    end;

    local procedure "--- Computer Info Aux"()
    begin
    end;

    local procedure GetMacAddress() MacAddress: Text
    var
        [RunOnClient]
        NetworkInterface: DotNet npNetNetworkInterface;
        [RunOnClient]
        NetworkInterfaces: DotNet npNetArray;
        i: Integer;
    begin
        if not (CurrentClientType in [CLIENTTYPE::Windows, CLIENTTYPE::Desktop]) then
            exit('');

        NetworkInterfaces := NetworkInterface.GetAllNetworkInterfaces();
        for i := 0 to NetworkInterfaces.Length - 1 do begin
            NetworkInterface := NetworkInterfaces.GetValue(i);
            if NetworkInterface.GetIsNetworkAvailable() and (NetworkInterface.GetPhysicalAddress.ToString() <> '') then
                MacAddress += ';' + NetworkInterface.GetPhysicalAddress.ToString();
        end;

        MacAddress := CopyStr(MacAddress, 2);
        exit(MacAddress);
    end;

    local procedure GetPlatformVersion() PlatformVersion: Text[100]
    var
        [RunOnClient]
        Assembly: DotNet npNetAssembly;
        [RunOnClient]
        FileVersionInfo: DotNet npNetFileVersionInfo;
    begin
        if not (CurrentClientType in [CLIENTTYPE::Windows, CLIENTTYPE::Desktop]) then
            exit('');

        Assembly := Assembly.GetExecutingAssembly();
        FileVersionInfo := FileVersionInfo.GetVersionInfo(Assembly.Location);
        exit(FileVersionInfo.FileVersion)
    end;

    local procedure "--- License Info Aux"()
    begin
    end;

    local procedure SearchForGranule(GranuleIDText: Text) NoOfUsers: Integer
    var
        LicenseInfo: Record "License Information";
        LineFound: Boolean;
        InfoText: Text;
        NumberGroupSeparatorList: Text;
    begin
        NoOfUsers := 0;
        if LicenseInfo.FindSet then
            repeat
                LineFound := StrPos(LicenseInfo.Text, GranuleIDText) = 1;
                if LineFound then begin
                    NumberGroupSeparatorList := '.,�';
                    InfoText := DelChr(LicenseInfo.Text, '=', NumberGroupSeparatorList);
                    NoOfUsers += GetNoOfUsers(InfoText);
                end;
            until LicenseInfo.Next = 0;
        exit(NoOfUsers);
    end;

    local procedure GetNoOfUsers(InputString: Text): Integer
    var
        Pattern: Text;
        Regex: DotNet npNetRegex;
        IntFound: Integer;
        Match: DotNet npNetMatch;
        MatchCollection: DotNet npNetMatchCollection;
        NetConvHelper: Variant;
    begin
        Pattern := '.*?\d+.*?(\d+)';
        Match := Regex.Match(InputString, Pattern);
        if Match.Success then begin
            NetConvHelper := Match.Groups;
            MatchCollection := NetConvHelper;
            if Evaluate(IntFound, MatchCollection.Item(1).ToString) then
                exit(IntFound);
        end;
        exit(0);
    end;

    local procedure SearchForLicenseText(TextToFind: Text) InfoText: Text
    var
        LicenseInfo: Record "License Information";
    begin
        if TextToFind = '' then
            exit('');

        InfoText := '';
        LicenseInfo.SetFilter(Text, '%1*', TextToFind);
        if not LicenseInfo.FindFirst then
            exit('');

        InfoText := DelStr(LicenseInfo.Text, 1, StrLen(TextToFind));
        exit(InfoText);
    end;

    local procedure "--- Aux"()
    begin
    end;

    local procedure ClientDiagnosticsEnabled(): Boolean
    begin
        if not NPRetailSetup.Get then
            exit(false);

        exit(NPRetailSetup."Enable Client Diagnostics");
    end;

    [TryFunction]
    local procedure TryGetJsonValueAsText(JObject: DotNet npNetJObject; PropertyName: Text; var ReturnValue: Text)
    begin
        //-NPR5.42
        ReturnValue := JObject.GetValue(PropertyName).ToString;
        //+NPR5.42
    end;

    [TryFunction]
    local procedure TryGetJsonValueAsDecimal(JObject: DotNet npNetJObject; PropertyName: Text; var ReturnValue: Decimal)
    var
        DotNetDecimal: DotNet npNetDecimal;
        CultureInfo: DotNet npNetCultureInfo;
    begin
        //-NPR5.42
        ReturnValue := DotNetDecimal.Parse(JObject.GetValue(PropertyName).ToString, CultureInfo.InvariantCulture);
        //+NPR5.42
    end;

    [TryFunction]
    local procedure TryParseJson(json: Text; var JToken: DotNet npNetJToken)
    begin
        //-NPR5.42
        JToken := JToken.Parse(json);
        //+NPR5.42
    end;
}

