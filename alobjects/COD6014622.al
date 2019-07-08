codeunit 6014622 "POS Web Session Management"
{
    // NPR4.10/VB/20150602 CASE 213003 Support for Web Client (JavaScript) client
    // NPR4.12/VB/20150703 CASE 213003 Custom logo management for JavaScript client
    // NPR4.14/VB/20150904 CASE 213003 Merged changes
    // NPR4.14/VB/20150925 CASE 222938 Version increase for NaviPartner.POS.Web assembly reference(s), due to refactoring of QUANTITY_POS and QUANTITY_NEG functions.
    // NPR4.14/VB/20151001 CASE 224232 Number formatting
    // NPR4.14/VB/20151001 CASE 224312 Caching per session
    // NPR5.00/VB/20151130 CASE 226832 Changed to support POS device protocol functionality
    // NPR5.00/VB/20151221 CASE 229508 Support for number formatting
    // NPR5.00/VB/20160105  CASE 230373 Refactoring due to client-side formatting of decimal and date/time values
    // NPR5.01/VB/20160205 CASE 233815 Forcing deployment of assemblies
    // NPR5.20/VB/20160301 CASE 235863 Filtering by salesperson fixed.
    // NPR5.22/VB/20160316 CASE 236519 Added support for configurable lookup templates and caching.
    // NPR5.22/VB/20160407 CASE 237866 Added field "Line Order on Screen"
    // NPR5.22/VB/20160414 CASE 238895 Added support for filtering of menu lines by register type.
    // NPR5.26/TSA/20160919 CASE 248043 Changed .NET Version on PaymentGateway from 5.0.398.0 to 5.0.398.1
    // NPR5.28/VB/20161122 CASE 259086 Removing last remnants of the .NET Control Add-in
    // NPR5.49/TJ/20190201 CASE 335739 Using POS View Profile instead Register

    SingleInstance = true;

    trigger OnRun()
    begin
        //-NPR5.01
        TriggerDatabaseDeploymentOfAssemblies();
        Message(Text001);
        //+NPR5.01
    end;

    var
        Register: Record Register;
        UserSetup: Record "User Setup";
        TouchScreenLayout: Record "Touch Screen - Layout";
        POSUnit: Record "POS Unit";
        POSViewProfile: Record "POS View Profile";
        RetailFormCode: Codeunit "Retail Form Code";
        NumberFormat: DotNet npNetNumberFormatInfo;
        DateFormat: DotNet npNetDateTimeFormatInfo;
        LookupCache: DotNet npNetDictionary_Of_T_U;
        SalespersonCode: Code[10];
        SessionStarted: Boolean;
        _ScreenWidth: Integer;
        _ScreenHeight: Integer;
        _ViewportWidth: Integer;
        _ViewportHeight: Integer;
        Text001: Label 'Assemblies have either been successfully deployed from the database, or the service tier waas otherwise able to load them. If this is the first time you are running this command, then restart the service tier.';

    procedure ResolutionWidth(): Integer
    begin
        MakeSureSessionIsStarted();
        exit(TouchScreenLayout."Resolution Width");
    end;

    procedure ResolutionHeight(): Integer
    begin
        MakeSureSessionIsStarted();
        exit(TouchScreenLayout."Resolution Height");
    end;

    procedure ButtonCountVertical(): Integer
    begin
        MakeSureSessionIsStarted();
        exit(TouchScreenLayout."Button Count Vertical");
    end;

    procedure ButtonCountHorizontal(): Integer
    begin
        MakeSureSessionIsStarted();
        exit(TouchScreenLayout."Button Count Horizontal");
    end;

    procedure ButtonsEnabledByDefault(): Boolean
    begin
        MakeSureSessionIsStarted();
        exit(false);
    end;

    local procedure TriggerDatabaseDeploymentOfAssemblies()
    var
        Json: DotNet npNetJsonSerializer;
        Nav: DotNet npNetScreen;
        Device: DotNet npNetPathHelper;
        Service: DotNet npNetRequestHandler;
        PaymentGateway: DotNet npNetPaymentGateway;
        Print: DotNet npNetPrintRequest;
    begin
        //-NPR5.01
        if CanLoadType(Json) then;
        if CanLoadType(Nav) then;
        if CanLoadType(Device) then;
        if CanLoadType(Service) then;
        if CanLoadType(PaymentGateway) then;
        if CanLoadType(Print) then;
        //+NPR5.01
    end;

    procedure GetSalespersonCode(): Code[10]
    begin
        MakeSureSessionIsStarted();
        //-NPR5.20
        if SalespersonCode = '' then
          exit(UserSetup."Salespers./Purch. Code");
        exit(SalespersonCode);
        //+NPR5.20
    end;

    procedure SetSalespersonCode(NewSalespersonCode: Code[10])
    begin
        //-NPR5.20
        SalespersonCode := NewSalespersonCode;
        //+NPR5.20
    end;

    procedure RegisterNo(): Code[10]
    begin
        MakeSureSessionIsStarted();
        exit(Register."Register No.");
    end;

    procedure StartPOSSession()
    var
        CultureInfo: DotNet npNetCultureInfo;
    begin
        //-NPR5.01
        TriggerDatabaseDeploymentOfAssemblies();
        //+NPR5.01
        //-NPR5.49 [335739]
        //Register.GET(RetailFormCode.FetchRegisterNumber);
        POSUnit.Get(RetailFormCode.FetchRegisterNumber);
        if not POSViewProfile.Get(POSUnit."POS View Profile") then
          Clear(POSViewProfile);
        //+NPR5.49 [335739]
        if not TouchScreenLayout.Get(Register."Register Layout") then begin
          TouchScreenLayout.Init;
          TouchScreenLayout."Resolution Width" := 0;
          TouchScreenLayout."Resolution Height" := 0;
          TouchScreenLayout."Button Count Vertical" := 5;
          TouchScreenLayout."Button Count Horizontal" := 5;
        end;
        //-NPR5.49 [335739]
        /*
        IF Register."Client Formatting Culture ID" <> '' THEN
          CultureInfo := CultureInfo.CultureInfo(Register."Client Formatting Culture ID")
        */
        if POSViewProfile."Client Formatting Culture ID" <> '' then
          CultureInfo := CultureInfo.CultureInfo(POSViewProfile."Client Formatting Culture ID")
        //+NPR5.49 [335739]
        else
          CultureInfo := CultureInfo.CultureInfo(CultureInfo.CurrentUICulture.Name);
        NumberFormat := CultureInfo.NumberFormat;
        //-NPR5.49 [335739]
        /*
        IF Register."Client Decimal Separator" <> '' THEN
          NumberFormat.NumberDecimalSeparator := Register."Client Decimal Separator";
        IF Register."Client Thousands Separator" <> '' THEN
          NumberFormat.NumberGroupSeparator := Register."Client Thousands Separator";
        */
        if POSViewProfile."Client Decimal Separator" <> '' then
          NumberFormat.NumberDecimalSeparator := POSViewProfile."Client Decimal Separator";
        if POSViewProfile."Client Thousands Separator" <> '' then
          NumberFormat.NumberGroupSeparator := POSViewProfile."Client Thousands Separator";
        //+NPR5.49 [335739]
        
        DateFormat := CultureInfo.DateTimeFormat;
        //-NPR5.49 [335739]
        /*
        IF Register."Client Date Separator" <> '' THEN
          DateFormat.DateSeparator := Register."Client Date Separator";
        */
        if POSViewProfile."Client Date Separator" <> '' then
          DateFormat.DateSeparator := POSViewProfile."Client Date Separator";
        //+NPR5.49 [335739]
        
        //-NPR5.20
        if UserSetup.Get(UserId) then;
        //+NPR5.20
        
        SessionStarted := true;

    end;

    procedure EndPOSSession()
    begin
        ClearAll();
    end;

    local procedure MakeSureSessionIsStarted()
    begin
        if not SessionStarted then
          StartPOSSession();
    end;

    procedure SetScreenMetrics(ScreenWidthIn: Integer;ScreenHeightIn: Integer;ViewportWidthIn: Integer;ViewportHeightIn: Integer)
    begin
        _ScreenWidth := ScreenWidthIn;
        _ScreenHeight := ScreenHeightIn;
        _ViewportHeight := ViewportHeightIn;
        _ViewportWidth := ViewportWidthIn;
    end;

    procedure ScreenWidth(): Integer
    begin
        exit(_ScreenWidth);
    end;

    procedure ScreenHeight(): Integer
    begin
        exit(_ScreenHeight);
    end;

    procedure ViewportWidth(): Integer
    begin
        exit(_ViewportWidth);
    end;

    procedure ViewportHeight(): Integer
    begin
        exit(_ViewportHeight);
    end;

    procedure HasCustomLogo(): Boolean
    begin
        MakeSureSessionIsStarted();
        //-NPR5.49 [335739]
        //EXIT(Register.Picture.HASVALUE);
        exit(POSViewProfile.Picture.HasValue);
        //+NPR5.49 [335739]
    end;

    procedure GetCustomLogo() DataUri: Text
    var
        InStr: InStream;
        MemStream: DotNet npNetMemoryStream;
        Convert: DotNet npNetConvert;
    begin
        MakeSureSessionIsStarted();
        //-NPR5.49 [335739]
        /*
        IF Register.Picture.HASVALUE THEN BEGIN
          Register.CALCFIELDS(Picture);
          Register.Picture.CREATEINSTREAM(InStr);
        */
        if POSViewProfile.Picture.HasValue then begin
          POSViewProfile.CalcFields(Picture);
          POSViewProfile.Picture.CreateInStream(InStr);
        //+NPR5.49 [335739]
          MemStream := MemStream.MemoryStream();
          CopyStream(MemStream,InStr);
          exit('data:image/png;base64,' + Convert.ToBase64String(MemStream.ToArray));
        end;

    end;

    procedure DecimalSeparator(): Text
    var
        String: DotNet npNetString;
    begin
        MakeSureSessionIsStarted();
        //-NPR5.49 [335739]
        //EXIT(Register."Client Decimal Separator");
        exit(POSViewProfile."Client Decimal Separator");
        //+NPR5.49 [335739]
    end;

    procedure ThousandsSeparator(): Text
    var
        String: DotNet npNetString;
    begin
        MakeSureSessionIsStarted();
        //-NPR5.49 [335739]
        //EXIT(Register."Client Thousands Separator");
        exit(POSViewProfile."Client Thousands Separator");
        //+NPR5.49 [335739]
    end;

    procedure GetNumberFormat(var NumberFormatOut: DotNet npNetNumberFormatInfo)
    begin
        MakeSureSessionIsStarted();
        NumberFormatOut := NumberFormat;
    end;

    procedure GetDateFormat(var DateFormatOut: DotNet npNetDateTimeFormatInfo)
    begin
        MakeSureSessionIsStarted();
        DateFormatOut := DateFormat;
    end;

    procedure GetProtocolBehavior(var DoEncrypt: Boolean;var DoSecure: Boolean;var DoInstallAssemblies: Boolean)
    begin
        MakeSureSessionIsStarted();

        DoEncrypt := Register."Encrypt Protocol Data";
        DoSecure := Register."Secure Protocol Data";
        DoInstallAssemblies := Register."Install Client-side Assemblies";
    end;

    procedure StoreLookupCache(RecRef: RecordRef): Boolean
    var
        Cache: DotNet npNetDictionary_Of_T_U;
    begin
        //-NPR5.22
        if IsNull(LookupCache) then
          LookupCache := LookupCache.Dictionary();

        if not LookupCache.ContainsKey(RecRef.Number) then
          LookupCache.Add(RecRef.Number,LookupCache.Dictionary());

        Cache := LookupCache.Item(RecRef.Number);
        if Cache.ContainsKey(RecRef.GetPosition()) then
          exit(false);

        Cache.Add(RecRef.GetPosition(),0);
        exit(true);
        //+NPR5.22
    end;

    procedure InvalidateLookupCache(RecRef: RecordRef)
    var
        Cache: DotNet npNetDictionary_Of_T_U;
    begin
        //-NPR5.22
        if IsNull(LookupCache) then
          exit;

        if not LookupCache.ContainsKey(RecRef.Number) then
          exit;

        LookupCache.Remove(RecRef.Number);
        //+NPR5.22
    end;

    procedure LineOrderOnScreen(): Integer
    begin
        //-NPR5.22
        MakeSureSessionIsStarted();
        //-NPR5.49 [335739]
        //EXIT(Register."Line Order on Screen");
        exit(POSViewProfile."Line Order on Screen");
        //+NPR5.49 [335739]
        //+NPR5.22
    end;

    procedure RegisterType(): Code[10]
    begin
        //-NPR5.22
        MakeSureSessionIsStarted();
        exit(Register."Register Type");
        //+NPR5.22
    end;
}

