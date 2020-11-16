codeunit 6059982 "NPR Add-In Management"
{
    // NPR4.12/VB/20150629 CASE 213003 - Support for Web Client (JavaScript) client (auto-deployment)
    // NPR4.17/LS/20151022  CASE 225607  corrected code for field name of ClientAddIn
    // NPR9   /VB/20150104 CASE 225607 Changed references for compiling under NAV 2016
    // NPR5.22.03/JDH/20160711 CASE 241848 Removed references to deprecated and obsolete Add-ins


    trigger OnRun()
    var
    begin
    end;

    var
        ClientAddInDirectory: Text;
        PatchAddinDirectory: Text;

    procedure CheckPatchDirectory(Path: Text)
    var
        [RunOnClient]
        Directory: DotNet NPRNetDirectory;
        [RunOnClient]
        DirectoryInfo: DotNet NPRNetDirectoryInfo;
        File: DotNet NPRNetFile;
        [RunOnClient]
        FileInfo: DotNet NPRNetFileInfo;
        [RunOnClient]
        FileVersionInfo: DotNet NPRNetFileVersionInfo;
        [RunOnClient]
        PatchFiles: DotNet NPRNetArray;
        Itt: Integer;
        LocalFilePath: Text;
        PatchVersion: Text;
        CurrentVersion: Text;
    begin
        PatchFiles := Directory.GetFiles(Path);
        DirectoryInfo := DirectoryInfo.DirectoryInfo(Path);

        for Itt := 0 to PatchFiles.Length - 1 do begin
            FileVersionInfo := FileVersionInfo.GetVersionInfo(PatchFiles.GetValue(Itt));
            FileInfo := FileInfo.FileInfo(PatchFiles.GetValue(Itt));
            PatchVersion := FileVersionInfo.FileVersion;
            LocalFilePath := ClientAddInDirectory + '\' + DirectoryInfo.Name + '\' + FileInfo.Name;
            if File.Exists(LocalFilePath) then begin
                FileVersionInfo := FileVersionInfo.GetVersionInfo(LocalFilePath);
                CurrentVersion := FileVersionInfo.FileVersion;
                if CurrentVersion < PatchVersion then
                    File.Copy(Format(PatchFiles.GetValue(Itt)), LocalFilePath, true)
            end else begin
                File.Copy(Format(PatchFiles.GetValue(Itt)), LocalFilePath, true)
            end;
            RegisterAddInByFile(PatchFiles.GetValue(Itt));
        end;
    end;

    procedure GetPublicKeyToken(Path: Text) StrongName: Text
    var
        [RunOnClient]
        Assembly: DotNet NPRNetAssembly;
        [RunOnClient]
        AssemblyName: DotNet NPRNetAssemblyName;
        String: Codeunit "NPR String Library";
    begin
        AssemblyName := AssemblyName.GetAssemblyName(Path);
        String.Construct(AssemblyName.FullName);
        exit(String.SelectStringSep(2, 'KeyToken='));
    end;

    procedure RegisterAddInByFile(Path: Text)
    var
        [RunOnClient]
        FileInfo: DotNet NPRNetFileInfo;
        [RunOnClient]
        FileVersionInfo: DotNet NPRNetFileVersionInfo;
        ClientAddIn: Record "Add-in";
        Extension: Text;
    begin
        FileVersionInfo := FileVersionInfo.GetVersionInfo(Path);
        FileInfo := FileInfo.FileInfo(Path);
        Extension := FileInfo.Extension;

        if not (Extension = '.dll') or not (StrPos(FileInfo.Name, 'NaviPartner') > 0) then exit;
        //-NPR4.17
        //ClientAddIn."Control Add-in Name" := COPYSTR(FileInfo.Name, 1, STRLEN(FileInfo.Name) - 4);
        ClientAddIn."Add-in Name" := CopyStr(FileInfo.Name, 1, StrLen(FileInfo.Name) - 4);
        //+NPR4.17
        ClientAddIn.Description := FileVersionInfo.ProductName;
        ClientAddIn.Version := FileVersionInfo.FileVersion;
        ClientAddIn."Public Key Token" := GetPublicKeyToken(Path);
        if not ClientAddIn.Insert then ClientAddIn.Modify;
    end;

    procedure "-- AddIn Registration"()
    begin
    end;

    procedure RegisterAddIns()
    begin
        //-NPR4.12
        //RegisterAddIn('NaviPartner.POS.ButtonGrid','867142ff84820aec','1.0.0.0','NaviPartner.POS.ButtonGrid');
        //RegisterAddIn('NaviPartner.POS.ClientAddInBase','867142ff84820aec','1.0.0.0','NaviPartner.POS.ClientAddInBase');
        //RegisterAddIn('NaviPartner.POS.CreditCardDialog','867142ff84820aec','1.0.0.0','NaviPartner.POS.CreditCardDialog');
        //RegisterAddIn('NaviPartner.POS.MessageScreen','867142ff84820aec','1.0.0.0','NaviPartner.POS.MessageScreen');
        //RegisterAddIn('NaviPartner.POS.NumPad','867142ff84820aec','1.0.0.0','NaviPartner.POS.NumPad');
        //RegisterAddIn('NaviPartner.POS.OptionMenu','867142ff84820aec','1.0.0.0','NaviPartner.POS.OptionMenu');
        //RegisterAddIn('NaviPartner.POS.RegisterBalancing','867142ff84820aec','1.0.0.0','NaviPartner.POS.RegisterBalancing');
        //RegisterAddIn('NaviPartner.POS.ScreenHandle','867142ff84820aec','1.0.0.0','NaviPartner.POS.ScreenHandle');
        //RegisterAddIn('NaviPartner.POS.SearchBox','867142ff84820aec','1.0.0.0','NaviPartner.POS.SearchBox');
        //RegisterAddIn('NaviPartner.POS.TouchScreenAddIn','867142ff84820aec','1.0.0.1','NaviPartner.POS.TouchScreen');
        //RegisterAddIn('NaviPartner.Utility.NaviPingPongAddin','867142ff84820aec','1.0.0.0','Navi Partner Utility PingPongAddin');
        //RegisterAddIn('NaviPartner.Utility.UserHookAddIn','867142ff84820aec','1.0.0.0','Navi Partner UserHook Addin');
        //RegisterAddIn('NaviPartner.Widgets.GoogleAnalyticsProtocol','48f3911b65e24838','1.0.0.0','GoogleAnalytics');
        //RegisterAddIn('NaviPartner.Widgets.RSSReader','48f3911b65e24838','1.0.0.0','RSS client reader');
        //RegisterAddIn('NaviPartner.Widgets.WeatherWidget','48f3911b65e24838','1.0.0.0','WeatherWidget');
        RegisterAddIn('NaviPartner.POS.ButtonGrid', '867142ff84820aec', '1.0.0.0', 'NaviPartner.POS.ButtonGrid', '');
        RegisterAddIn('NaviPartner.POS.ClientAddInBase', '867142ff84820aec', '1.0.0.0', 'NaviPartner.POS.ClientAddInBase', '');
        RegisterAddIn('NaviPartner.POS.CreditCardDialog', '867142ff84820aec', '1.0.0.0', 'NaviPartner.POS.CreditCardDialog', '');
        RegisterAddIn('NaviPartner.POS.MessageScreen', '867142ff84820aec', '1.0.0.0', 'NaviPartner.POS.MessageScreen', '');
        RegisterAddIn('NaviPartner.POS.NumPad', '867142ff84820aec', '1.0.0.0', 'NaviPartner.POS.NumPad', '');
        RegisterAddIn('NaviPartner.POS.OptionMenu', '867142ff84820aec', '1.0.0.0', 'NaviPartner.POS.OptionMenu', '');
        RegisterAddIn('NaviPartner.POS.RegisterBalancing', '867142ff84820aec', '1.0.0.0', 'NaviPartner.POS.RegisterBalancing', '');
        RegisterAddIn('NaviPartner.POS.ScreenHandle', '867142ff84820aec', '1.0.0.0', 'NaviPartner.POS.ScreenHandle', '');
        RegisterAddIn('NaviPartner.POS.SearchBox', '867142ff84820aec', '1.0.0.0', 'NaviPartner.POS.SearchBox', '');
        RegisterAddIn('NaviPartner.POS.TouchScreenAddIn', '867142ff84820aec', '1.0.0.1', 'NaviPartner.POS.TouchScreen', '');
        //-NPR5.22.03
        //RegisterAddIn('NaviPartner.Utility.NaviPingPongAddin','867142ff84820aec','1.0.0.0','Navi Partner Utility PingPongAddin','');
        //RegisterAddIn('NaviPartner.Utility.UserHookAddIn','867142ff84820aec','1.0.0.0','Navi Partner UserHook Addin','');
        //RegisterAddIn('NaviPartner.Widgets.GoogleAnalyticsProtocol','48f3911b65e24838','1.0.0.0','GoogleAnalytics','');
        //RegisterAddIn('NaviPartner.Widgets.RSSReader','48f3911b65e24838','1.0.0.0','RSS client reader','');
        //RegisterAddIn('NaviPartner.Widgets.WeatherWidget','48f3911b65e24838','1.0.0.0','WeatherWidget','');
        //+NPR5.22.03
        //+NPR4.12
    end;

    procedure RegisterAddInsJavaScript()
    begin
        //-NPR4.12
        RegisterAddIn('NaviPartner.POS.Web.IFramework', '909fa1bba7619e33', '1.0.0.0', 'NaviPartner POS Control Framework', 'NaviPartner.POS.Web.IFramework_1.0.0.0.zip');
        RegisterAddIn('NaviPartner.POS.Web.TweakPage', '909fa1bba7619e33', '1.0.0.0', 'NaviPartner POS Control Dialog', '');
        //+NPR4.12
    end;

    procedure RegisterJavaScriptAddInFromBase64(Content: Text)
    var
        ClientAddIn: Record "Add-in";
        Delimiters: DotNet NPRNetArray;
        Parts: DotNet NPRNetArray;
        String: DotNet NPRNetString;
        Convert: DotNet NPRNetConvert;
        MemoryStream: DotNet NPRNetMemoryStream;
        OutStr: OutStream;
        Delimiter: Char;
    begin
        Delimiter := ';';
        Delimiters := Delimiters.CreateInstance(GetDotNetType(Delimiter), 1);
        Delimiters.SetValue(Delimiter, 0);

        String := Content;
        Parts := String.Split(Delimiters);
        //-NPR4.17
        //ClientAddIn."Control Add-in Name" := Parts.GetValue(0);
        ClientAddIn."Add-in Name" := Parts.GetValue(0);
        //+NPR4.17
        ClientAddIn."Public Key Token" := Parts.GetValue(1);
        if not ClientAddIn.Find() then
            ClientAddIn.Insert();

        ClientAddIn.Description := Parts.GetValue(3);

        if Parts.Length > 4 then begin
            String := Parts.GetValue(4);
            if String.Length > 0 then begin
                MemoryStream := MemoryStream.MemoryStream(Convert.FromBase64String(Parts.GetValue(4)));
                ClientAddIn.Resource.CreateOutStream(OutStr);
                CopyStream(OutStr, MemoryStream);
            end;
        end;
        ClientAddIn.Modify(true);
    end;

    procedure RegisterAddIn(AddInName: Text; AddInToken: Text; AddInVersion: Text; AddInDescription: Text; Resource: Text)
    var
        ClientAddIn: Record "Add-in";
        MemoryStream: DotNet NPRNetMemoryStream;
        WebClient: DotNet NPRNetWebClient;
        NetworkCredential: DotNet NPRNetNetworkCredential;
        OutStream: OutStream;
    begin
        ClientAddIn.Init;
        //-NPR4.17
        //ClientAddIn."Control Add-in Name" := AddInName;
        ClientAddIn."Add-in Name" := AddInName;
        //+NPR4.17
        ClientAddIn."Public Key Token" := AddInToken;
        //-NPR4.12
        //ClientAddIn.Version               := AddInVersion;
        //ClientAddIn.Description           := AddInDescription;
        //IF ClientAddIn.INSERT THEN;
        if not ClientAddIn.Find() then
            ClientAddIn.Insert();

        ClientAddIn.Version := AddInVersion;
        ClientAddIn.Description := AddInDescription;

        if Resource <> '' then begin
            WebClient := WebClient.WebClient;
            MemoryStream := MemoryStream.MemoryStream(WebClient.DownloadData('http://xsd.navipartner.dk/NaviPartner.POS.Web/Add-ins/' + Resource));

            ClientAddIn.Resource.CreateOutStream(OutStream);
            CopyStream(OutStream, MemoryStream);
            ClientAddIn.Modify(true);
        end;
        //+NPR4.12
    end;
}

