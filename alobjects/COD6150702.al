codeunit 6150702 "POS UI Management"
{
    // NPR5.32.11/VB /20170621  CASE 281618 Added watermark initialization.
    // NPR5.36/VB  /20170926  CASE 291454 Fixing bug with non-action button configuration not showing up in UI
    // NPR5.37/VB  /20171013  CASE 290485 Providing localization support for button captions (and other data)
    // NPR5.37/TSA /20171025 CASE 292323 Changed Caption for CaptionLabelSubtotal to include LCY Code
    // NPR5.37/VB  /20171025  CASE 293905 Added support for locked view and corresponding actions and options
    // NPR5.38/VB  /20171204  CASE 255773 Implementing front-end WYSIWYG support for buttons
    // NPR5.38/VB  /20180123  CASE 303053 Changing captions for the payment view
    // NPR5.39/TSA /20180206 CASE 299908 Added CaptionLabelPaymentTotal2 as Sale %1 to get currency code on login page
    // NPR5.40/VB  /20180213 CASE 306347 Performance improvement due to parameters in BLOB and physical-table action discovery
    // NPR5.40/MMV /20180314 CASE 307453 Performance
    // NPR5.42/MMV /20180508 CASE 314128 Re-added support for button parameters when type <> Action
    // NPR5.45/TJ  /20180809 CASE 323728 New option setup added for kiosk unlock
    // NPR5.49/VB  /20181106 CASE 335141 Introducing the POS Theme functionality
    // NPR5.49/TJ  /20190102 CASE 335739 Using POS View Profile instead of Register
    // NPR5.50/JAKUBV/20190603  CASE 338666 Transport NPR5.50 - 3 June 2019
    // NPR5.51/MMV /20190625 CASE 359825 Added missing filter
    // NPR5.51/VB  /20190709 CASE 361184 Passing NPR Version number to front end
    // NPR5.51/VB  /20190719  CASE 352582 POS Administrative Templates feature


    trigger OnRun()
    begin
    end;

    var
        FrontEnd: Codeunit "POS Front End Management";
        WaterMarkDemo: Label 'DEMO demo DEMO demo';
        WaterMarkTest: Label 'TEST test TEST test';

    procedure Initialize(FrontEndIn: Codeunit "POS Front End Management")
    begin
        FrontEnd := FrontEndIn;
    end;

    procedure InitializeCaptions()
    var
        Language: Record "Windows Language";
        Caption: Record "POS Localized Caption";
        CaptionMgt: Codeunit "POS Caption Management";
        Captions: DotNet npNetDictionary_Of_T_U;
    begin
        Language.Get(GlobalLanguage);
        Captions := Captions.Dictionary();
        ConfigureCaptions(Captions);

        Caption.SetFilter("Caption ID", '<>%1', '');
        Caption.SetFilter("Language Code", '%1|%2', '', Language."Abbreviated Name");
        if Caption.FindSet then
            repeat
                if Captions.ContainsKey(Caption."Caption ID") then
                    Captions.Remove(Caption."Caption ID");
                Captions.Add(Caption."Caption ID", Caption.Caption);
            until Caption.Next = 0;

        CaptionMgt.Initialize(FrontEnd);
        OnInitializeCaptions(CaptionMgt);
        CaptionMgt.Finalize(Captions);

        FrontEnd.ConfigureCaptions(Captions);
    end;

    procedure InitializeNumberAndDateFormat(Register: Record Register)
    var
        CultureInfo: DotNet npNetCultureInfo;
        NumberFormat: DotNet npNetNumberFormatInfo;
        DateFormat: DotNet npNetDateTimeFormatInfo;
        POSUnit: Record "POS Unit";
        POSViewProfile: Record "POS View Profile";
    begin
        //-NPR5.49 [335739]
        /*
        IF Register."Client Formatting Culture ID" <> '' THEN
          CultureInfo := CultureInfo.CultureInfo(Register."Client Formatting Culture ID")
        */
        if (not POSUnit.Get(Register."Register No.")) or (not POSViewProfile.Get(POSUnit."POS View Profile")) then
            Clear(POSViewProfile);
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

        FrontEnd.ConfigureFormat(NumberFormat, DateFormat);

    end;

    procedure InitializeLogo(Register: Record Register)
    var
        InStr: InStream;
        MemStream: DotNet npNetMemoryStream;
        Convert: DotNet npNetConvert;
        POSUnit: Record "POS Unit";
        POSViewProfile: Record "POS View Profile";
    begin
        //-NPR5.49 [335739]
        //IF NOT Register.Picture.HASVALUE() THEN
        if (not POSUnit.Get(Register."Register No.")) or (not POSViewProfile.Get(POSUnit."POS View Profile")) or (not POSViewProfile.Picture.HasValue()) then
            //+NPR5.49 [335739]
            exit;

        //-NPR5.49 [335739]
        /*
        Register.CALCFIELDS(Picture);
        Register.Picture.CREATEINSTREAM(InStr);
        */
        POSViewProfile.CalcFields(Picture);
        POSViewProfile.Picture.CreateInStream(InStr);
        //+NPR5.49 [335739]
        MemStream := MemStream.MemoryStream();
        CopyStream(MemStream, InStr);

        FrontEnd.ConfigureLogo(Convert.ToBase64String(MemStream.ToArray()));

    end;

    procedure InitializeMenus(Register: Record Register; Salesperson: Record "Salesperson/Purchaser"; POSSession: Codeunit "POS Session")
    var
        Menu: Record "POS Menu";
        Menus: DotNet npNetList_Of_T;
        MenuObj: DotNet npNetMenu;
        tmpPOSParameterValue: Record "POS Parameter Value" temporary;
    begin
        //-NPR5.42 [314128]
        //PreloadActionParameters(tmpPOSParameterValue,tmpPOSActionParameter);
        PreloadParameters(tmpPOSParameterValue);
        //+NPR5.42 [314128]

        with Menu do begin
            SetRange(Blocked, false);
            SetFilter("Register Type", '%1|%2', Register."Register Type", '');
            SetFilter("Register No.", '%1|%2', Register."Register No.", '');
            SetFilter("Salesperson Code", '%1|%2', Salesperson.Code, '');
            // SETFILTER("Available in App",'%1|%2',TRUE,FALSE);  // TODO: fix this after developing app stuff
            SetRange("Available on Desktop", true);                // TODO: fix this after developing app stuff

            if FindSet then begin
                Menus := Menus.List();
                repeat
                    //-NPR5.42 [314128]
                    //InitializeMenu(Menu,MenuObj,POSSession,tmpPOSParameterValue,tmpPOSActionParameter);
                    InitializeMenu(Menu, MenuObj, POSSession, tmpPOSParameterValue);
                    //+NPR5.42 [314128]
                    Menus.Add(MenuObj);
                until Next = 0;
                FrontEnd.ConfigureMenu(Menus);
            end;
        end;
    end;

    local procedure InitializeMenu(var Menu: Record "POS Menu"; var MenuObj: DotNet npNetMenu; POSSession: Codeunit "POS Session"; var tmpPOSParameterValue: Record "POS Parameter Value" temporary)
    var
        MenuButton: Record "POS Menu Button";
        MenuButtonObj: DotNet npNetMenuButton;
    begin
        //-NPR5.40 [306347]
        POSSession.DebugWithTimestamp('Initializing menu [' + Menu.Code + ']');
        //+NPR5.40 [306347]
        InitializeMenuObject(Menu, MenuObj);

        with MenuButton do begin
            SetRange("Menu Code", Menu.Code);
            SetRange(Blocked, false);
            Menu.CopyFilter("Register Type", "Register Type");
            Menu.CopyFilter("Register No.", "Register No.");
            //Menu.COPYFILTER("Salesperson Code","Salesperson Code"); // TODO: this must happen in the front end
            Menu.CopyFilter("Available in App", "Available in App");
            Menu.CopyFilter("Available on Desktop", "Available on Desktop");
            SetRange("Parent ID", 0);

            //-NPR5.42 [314128]
            //InitializeMenuButtons(MenuButton,MenuObj,POSSession,tmpPOSParameterValue,tmpPOSActionParameter);
            InitializeMenuButtons(MenuButton, MenuObj, POSSession, tmpPOSParameterValue);
            //+NPR5.42 [314128]
        end;
    end;

    local procedure InitializeMenuObject(Menu: Record "POS Menu"; var MenuObj: DotNet npNetMenu)
    begin
        with Menu do begin
            MenuObj := MenuObj.Menu();

            MenuObj.Id := Code;
            MenuObj.Caption := Caption;
            MenuObj.Tooltip := Tooltip;
            MenuObj.Class := "Custom Class Attribute";
        end;
    end;

    local procedure InitializeSubmenu(var MenuButton: Record "POS Menu Button"; ISubMenu: DotNet npNetISubMenu; POSSession: Codeunit "POS Session"; var tmpPOSParameterValue: Record "POS Parameter Value" temporary)
    var
        SubMenuButton: Record "POS Menu Button";
    begin
        with SubMenuButton do begin
            CopyFilters(MenuButton);
            SetRange("Parent ID", MenuButton.ID);

            //-NPR5.42 [314128]
            //InitializeMenuButtons(SubMenuButton,ISubMenu,POSSession,tmpPOSParameterValue,tmpPOSActionParameter);
            InitializeMenuButtons(SubMenuButton, ISubMenu, POSSession, tmpPOSParameterValue);
            //+NPR5.42 [314128]
        end;
    end;

    local procedure InitializeMenuButtons(var SubMenuButton: Record "POS Menu Button"; ISubMenu: DotNet npNetISubMenu; POSSession: Codeunit "POS Session"; var tmpPOSParameterValue: Record "POS Parameter Value" temporary)
    var
        MenuButtonObj: DotNet npNetMenuButton;
    begin
        with SubMenuButton do begin
            if FindSet then
                repeat
                    //-NPR5.42 [314128]
                    //InitializeMenuButtonObject(SubMenuButton,MenuButtonObj,POSSession,tmpPOSParameterValue,tmpPOSActionParameter);
                    InitializeMenuButtonObject(SubMenuButton, MenuButtonObj, POSSession, tmpPOSParameterValue);
                    //+NPR5.42 [314128]
                    ISubMenu.MenuButtons.Add(MenuButtonObj);
                    if "Action Type" = "Action Type"::Submenu then
                        //-NPR5.42 [314128]
                        //InitializeSubmenu(SubMenuButton,MenuButtonObj,POSSession,tmpPOSParameterValue,tmpPOSActionParameter);
                        InitializeSubmenu(SubMenuButton, MenuButtonObj, POSSession, tmpPOSParameterValue);
                    //+NPR5.42 [314128]
                until Next = 0;
        end;
    end;

    local procedure InitializeMenuButtonObject(MenuButton: Record "POS Menu Button"; var MenuButtonObj: DotNet npNetMenuButton; POSSession: Codeunit "POS Session"; var tmpPOSParameterValue: Record "POS Parameter Value" temporary)
    var
        "Action": DotNet npNetAction;
        DotNetHelper: Variant;
        DotNetEnum: DotNet npNetEnum;
    begin
        with MenuButton do begin
            MenuButtonObj := MenuButtonObj.MenuButton();
            //-NPR5.38 [290485]
            //  MenuButtonObj.Caption := Caption;
            MenuButtonObj.Caption := MenuButton.GetLocalizedCaption(FieldNo(Caption));
            //+NPR5.38 [290485]
            MenuButtonObj.Tooltip := Tooltip;
            MenuButtonObj.BackgroundColor := "Background Color";
            MenuButtonObj.Color := "Foreground Color";
            MenuButtonObj.IconClass := "Icon Class";
            MenuButtonObj.Class := "Custom Class Attribute";
            MenuButtonObj.Bold := Bold;
            MenuButtonObj.FontSize := DotNetEnum.Parse(MenuButtonObj.FontSize.GetType(), Format("Font Size"));
            MenuButtonObj.Row := "Position Y";
            MenuButtonObj.Column := "Position X";
            MenuButtonObj.Enabled := DotNetEnum.Parse(MenuButtonObj.Enabled.GetType(), Format(Enabled));

            //-NPR5.38 [255773]
            MenuButtonObj.Content.Add('keyMenu', "Menu Code");
            MenuButtonObj.Content.Add('keyId', ID);
            //+NPR5.38 [255773]

            InitializeMenuButtonObjectFilters(MenuButton, MenuButtonObj);

            //-NPR5.42 [314128]
            //GetAction(Action,POSSession,STRSUBSTNO('%1 [%2, %3]',MenuButton.TABLECAPTION,"Menu Code",Caption),tmpPOSParameterValue,tmpPOSActionParameter);
            GetAction(Action, POSSession, StrSubstNo('%1 [%2, %3]', MenuButton.TableCaption, "Menu Code", Caption), tmpPOSParameterValue);
            //+NPR5.42 [314128]
            if not IsNull(Action) then
                MenuButtonObj.Action := Action;
            //-NPR5.36 [291454]
            StoreButtonConfiguration(MenuButtonObj);
            //+NPR5.36 [291454]
        end;
    end;

    local procedure InitializeMenuButtonObjectFilters(MenuButton: Record "POS Menu Button"; var MenuButtonObj: DotNet npNetMenuButton)
    begin
        if MenuButton."Salesperson Code" <> '' then
            MenuButtonObj.Content.Add('filterSalesPerson', MenuButton."Salesperson Code");
        if MenuButton."Register No." <> '' then
            MenuButtonObj.Content.Add('filterRegister', MenuButton."Register No.");
    end;

    procedure InitializeWatermark()
    var
        NPRetailSetup: Record "NP Retail Setup";
        ActiveSession: Record "Active Session";
    begin
        // a) the first parameter is a watermark image, you can set one the same way logo is set
        // b) the second parameter is a watermark text, you can pass whatever you want
        // If image is present, text won't be shown.
        //-NPR5.32.11 [281618]

        if (not NPRetailSetup.Get()) then
            exit;

        case NPRetailSetup."Environment Type" of
            NPRetailSetup."Environment Type"::DEMO:
                FrontEnd.ConfigureWatermark('', WaterMarkDemo);
            NPRetailSetup."Environment Type"::DEV:
                begin
                    ActiveSession.SetFilter("Session ID", '=%1', SessionId);
                    if (ActiveSession.FindFirst()) then
                        FrontEnd.ConfigureWatermark('', ConvertStr(ActiveSession."Database Name", '_', ' '));
                end;
            NPRetailSetup."Environment Type"::TEST:
                FrontEnd.ConfigureWatermark('', WaterMarkTest);
            NPRetailSetup."Environment Type"::PROD:
                ;
        end;
        //+NPR5.32.11 [281618]
    end;

    procedure InitializeTheme(Register: Record Register)
    var
        POSTheme: Record "POS Theme";
        ThemeDep: Record "POS Theme Dependency";
        WebClientDep: Record "Web Client Dependency";
        ThemeLine: DotNet npNetDictionary_Of_T_U;
        Theme: DotNet npNetList_Of_T;
        DependencyContent: Text;
        POSUnit: Record "POS Unit";
        POSViewProfile: Record "POS View Profile";
    begin
        //-NPR5.49 [335739]
        /*
        //-NPR5.49 [335141]
        IF (Register."POS Theme Code" = '') OR (NOT POSTheme.GET(Register."POS Theme Code")) OR POSTheme.Blocked THEN
          EXIT;
        
        ThemeDep.SETRANGE("POS Theme Code",Register."POS Theme Code");
        */
        if (not POSUnit.Get(Register."Register No.")) or (not POSViewProfile.Get(POSUnit."POS View Profile")) or (not POSTheme.Get(POSViewProfile."POS Theme Code")) or POSTheme.Blocked then
            exit;

        ThemeDep.SetRange("POS Theme Code", POSViewProfile."POS Theme Code");
        //+NPR5.49 [335739]
        ThemeDep.SetRange(Blocked, false);
        ThemeDep.SetFilter("Dependency Code", '<>%1', '');
        if not ThemeDep.FindSet() then
            exit;

        Theme := Theme.List();
        repeat
            Clear(DependencyContent);
            case ThemeDep."Dependency Type" of
                ThemeDep."Dependency Type"::Background, ThemeDep."Dependency Type"::Logo:
                    DependencyContent := WebClientDep.GetDataUri(ThemeDep."Dependency Code");
                ThemeDep."Dependency Type"::JavaScript:
                    DependencyContent := WebClientDep.GetJavaScript(ThemeDep."Dependency Code");
                ThemeDep."Dependency Type"::Stylesheet:
                    DependencyContent := WebClientDep.GetStyleSheet(ThemeDep."Dependency Code");
            end;

            if DependencyContent <> '' then begin
                ThemeLine := ThemeLine.Dictionary();
                Theme.Add(ThemeLine);

                ThemeLine.Add('targetType', ThemeDep."Target Type");
                case ThemeDep."Target Type" of
                    ThemeDep."Target Type"::Client:
                        ThemeLine.Add('guid', ThemeDep."Auto-Update GUID");
                    ThemeDep."Target Type"::View:
                        ThemeLine.Add('view', ThemeDep."Target Code");
                    ThemeDep."Target Type"::"View Type":
                        ThemeLine.Add('viewType', ThemeDep."Target View Type");
                end;
                ThemeLine.Add('type', ThemeDep."Dependency Type");
                ThemeLine.Add('content', DependencyContent);
            end;
        until ThemeDep.Next = 0;
        FrontEnd.ConfigureTheme(Theme);
        //+NPR5.49 [335141]

    end;

    procedure InitializeAdministrativeTemplates(Register: Record Register)
    var
        AdminTemplate: Record "POS Administrative Template";
        AdminTemplateScope: Record "POS Admin. Template Scope";
        AdminTemplateScopeTmp: Record "POS Admin. Template Scope" temporary;
        POSUnit: Record "POS Unit";
        Templates: DotNet npNetList_Of_T;
        Template: DotNet npNetDictionary_Of_T_U;
    begin
        //-NPR5.51 [352582]
        AdminTemplateScope.SetRange("Applies To",AdminTemplateScope."Applies To"::All);
        if AdminTemplateScope.FindSet then
          repeat
            AdminTemplateScopeTmp := AdminTemplateScope;
            AdminTemplateScopeTmp.Insert();
          until AdminTemplateScope.Next = 0;

        if POSUnit.Get(Register."Register No.") then begin
          AdminTemplateScope.SetRange("Applies To",AdminTemplateScope."Applies To"::"POS Unit");
          AdminTemplateScope.SetRange("Applies To Code",POSUnit."No.");
          if AdminTemplateScope.FindSet then
            repeat
              AdminTemplateScopeTmp := AdminTemplateScope;
              AdminTemplateScopeTmp.Insert();
            until AdminTemplateScope.Next = 0;
        end;

        AdminTemplateScope.SetRange("Applies To",AdminTemplateScope."Applies To"::User);
        AdminTemplateScope.SetRange("Applies To Code",UserId);
        if AdminTemplateScope.FindSet then
          repeat
            AdminTemplateScopeTmp := AdminTemplateScope;
            AdminTemplateScopeTmp.Insert();
          until AdminTemplateScope.Next = 0;

        if AdminTemplateScopeTmp.IsEmpty then
          exit;

        Templates := Templates.List();
        AdminTemplateScopeTmp.FindSet();
        repeat
          if AdminTemplate.Get(AdminTemplateScopeTmp."POS Admin. Template Id") and (AdminTemplate.Status <> AdminTemplate.Status::Draft) then begin
            InitializeAdministrativeTemplatePolicy(Template,AdminTemplate.Id,AdminTemplate."Persist on Client",AdminTemplateScopeTmp."Applies To");
            case AdminTemplate.Status of
              AdminTemplate.Status::Active:
                begin
                  InitialiteAdministrativeTemplatePasswordPolicy(Template,'roleCenter',AdminTemplate."Role Center",AdminTemplate."Role Center Password");
                  InitialiteAdministrativeTemplatePasswordPolicy(Template,'configuration',AdminTemplate.Configuration,AdminTemplate."Configuration Password");
                end;
              AdminTemplate.Status::Retired:
                Template.Add('retired',true);
            end;
          end;
          Templates.Add(Template);
        until AdminTemplateScopeTmp.Next = 0;
        FrontEnd.ApplyAdministrativeTemplates(Templates);
        //+NPR5.51 [352582]
    end;

    local procedure InitializeAdministrativeTemplatePolicy(var Template: DotNet npNetDictionary_Of_T_U;Id: Guid;Persist: Boolean;AppliesTo: Integer)
    begin
        //-NPR5.51 [352582]
        Template := Template.Dictionary();
        Template.Add('id',Id);
        Template.Add('persist',Persist);
        Template.Add('strength',AppliesTo);
        //+NPR5.51 [352582]
    end;

    local procedure InitialiteAdministrativeTemplatePasswordPolicy(Template: DotNet npNetDictionary_Of_T_U;PolicyName: Text;Policy: Option "Not Defined",Visible,Disabled,Hidden,Password;Password: Text)
    var
        PolicyObject: DotNet npNetDictionary_Of_T_U;
    begin
        //-NPR5.51 [352582]
        case Policy of
          Policy::Disabled:
            Template.Add(PolicyName,'deny');
          Policy::Hidden:
            Template.Add(PolicyName,'hide');
          Policy::Visible:
            Template.Add(PolicyName,'allow');
          Policy::Password:
            begin
              PolicyObject := PolicyObject.Dictionary();
              PolicyObject.Add('password',Password);
              Template.Add(PolicyName,PolicyObject);
            end;
        end;
        //+NPR5.51 [352582]
    end;

    procedure ConfigureFonts()
    var
        WebFont: Record "POS Web Font";
        Font: DotNet npNetFont0;
    begin
        WebFont.SetFilter("Company Name", '%1|%2', '', CompanyName);
        if WebFont.FindSet then
            repeat
                WebFont.GetFontDotNet(Font);
                FrontEnd.ConfigureFont(Font);
            until WebFont.Next = 0;
    end;

    local procedure ConfigureCaptions(Captions: DotNet npNetDictionary_Of_T_U)
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
        NumberFormat: DotNet npNetNumberFormatInfo;
        i: Integer;
        CaptionLabelReceiptNo: Label 'Sale';
        CaptionLabelEANHeader: Label 'Item No.';
        CaptionLabelLastSale: Label 'Last Sale';
        CaptionFunctionButtonText: Label 'Function';
        CaptionMainMenuButtonText: Label 'Main Menu';
        CaptionLabelReturnAmount: Label 'Balance';
        CaptionLabelRegisterNo: Label 'Register';
        CaptionLabelSalesPersonCode: Label 'Salesperson Code';
        CaptionLabelClear: Label 'Erase';
        CaptionLabelPaymentAmount: Label 'Total';
        CaptionLabelPaymentTotal: Label 'Sale (LCY)';
        CaptionLabelPaymentTotal2: Label 'Sale %1';
        CaptionLabelTotalPayed: Label 'Payed';
        CaptionLabelSubtotal: Label 'SUBTOTAL %1';
        CaptionPaymentInfo: Label 'Payment info';
        CaptionGlobalCancel: Label 'Cancel';
        CaptionGlobalClose: Label 'Close';
        CaptionGlobalBack: Label 'Back';
        CaptionGlobalOK: Label 'OK';
        CaptionGlobalYes: Label 'Yes';
        CaptionGlobalNo: Label 'No';
        CaptionGlobalPrevious: Label 'Previous';
        CaptionGlobalNext: Label 'Next';
        CaptionGlobalToday: Label 'today';
        CaptionGlobalTomorrow: Label 'tomorrow';
        CaptionGlobalYesterday: Label 'yesterday';
        CaptionBalancingRegisterTransactions: Label 'Register Transactions';
        CaptionBalancingRegisters: Label 'Registers';
        CaptionBalancingReceipts: Label 'Receipts';
        CaptionBalancingBeginningBalance: Label 'Beginning Balance';
        CaptionBalancingCashMovements: Label 'Cash Movements';
        CaptionBalancingMidTotal: Label 'Mid-Total';
        CaptionBalancingManualCards: Label 'Credit Cards (Manual)';
        CaptionBalancingTerminalCards: Label 'Credit Cards (Terminal)';
        CaptionBalancingOtherCreditCards: Label 'Credit Cards (Other)';
        CaptionBalancingTerminal: Label 'Terminal';
        CaptionBalancingGiftCards: Label 'Gift Cards';
        CaptionBalancingCreditVouchers: Label 'Credit Vouchers';
        CaptionBalancingCustomerOutPayments: Label 'Customer Out-Payments';
        CaptionBalancingDebitSales: Label 'Debit Sales';
        CaptionBalancingStaffSales: Label 'Staff Sales';
        CaptionBalancingNegativeReceiptAmount: Label 'Negative Receipt Amount';
        CaptionBalancingForeignCurrency: Label 'Foreign Currency';
        CaptionBalancingReceiptStatistics: Label 'Receipt Statistics';
        CaptionBalancingNumberOfSales: Label 'Number Of Sales';
        CaptionBalancingCancelledSales: Label 'Cancelled Sales';
        CaptionBalancingNumberOfNegativeReceipts: Label 'Number of Negative Receipts';
        CaptionBalancingTurnover: Label 'Turnover';
        CaptionBalancingCOGS: Label 'Cost of Goods Sold';
        CaptionBalancingContributionMargin: Label 'Contribution Margin';
        CaptionBalancingDiscounts: Label 'Discounts';
        CaptionBalancingCampaign: Label 'Campaign Discounts';
        CaptionBalancingMixed: Label 'Mixed Discounts';
        CaptionBalancingQuantityDiscounts: Label 'Quantity Discounts';
        CaptionBalancingSalespersonDiscounts: Label 'Salesperson Discounts';
        CaptionBalancingBOMDiscounts: Label 'BOM Discounts';
        CaptionBalancingCustomerDiscounts: Label 'Customer Discounts';
        CaptionBalancingOtherDiscounts: Label 'Other Discounts';
        CaptionBalancingTotalDiscounts: Label 'Total Discounts';
        CaptionBalancingOpenDrawer: Label 'Open Drawer';
        CaptionBalancingAuditRoll: Label 'Audit Roll';
        CaptionBalancingCashCount: Label '%1 Count';
        CaptionBalancingCountedLCY: Label 'Counted (LCY)';
        CaptionBalancingDifferenceLCY: Label 'Difference (LCY)';
        CaptionBalancingNewCashAmount: Label 'New Cash Amount';
        CaptionBalancingPutInTheBank: Label 'Put in the Bank';
        CaptionBalancingMoneybagNo: Label 'Moneybag No.';
        CaptionBalancingAmount: Label 'Amount';
        CaptionBalancingNumber: Label 'Number';
        CaptionBalancingRemainderTransferred: Label 'Remainder Transferred to Safe / Exchange Desk';
        CaptionBalancingDelete: Label 'Delete';
        CaptionBalancingClose: Label 'Close';
        CaptionBalancing1Turnover: Label '[1] Turnover';
        CaptionBalancing2Counting: Label '[2] Counting';
        CaptionBalancing3Close: Label '[3] Close';
        CaptionDataGridSelected: Label 'Selected';
        CaptionLookupSearch: Label 'Search';
        CaptionLookup: Label 'Lookup: ';
        CaptionLookupNew: Label 'New';
        CaptionLookupShowCard: Label 'Show Card';
        CaptionMessage: Label 'You might want to know...';
        CaptionConfirmation: Label 'We need your confirmation...';
        CaptionError: Label 'Something is wrong...';
        CaptionNumpad: Label 'We need more information...';
        CaptionLockedRegisterLocked: Label 'This register is locked';
        CaptionTabletButtonItems: Label 'Items';
        CaptionTabletButtonMore: Label 'More...';
        CaptionTabletButtonPayments: Label 'Payment Methods';
        CaptionLastSale_Total: Label 'Total';
        CaptionLastSale_Paid: Label 'Total paid';
        CaptionLastSale_Change: Label 'Change';
        CaptionPayment_SaleLCY: Label 'Sale (LCY)';
        CaptionPayment_Paid: Label 'Paid';
        CaptionPayment_Balance: Label 'Balance';
    begin
        Captions.Add('Sale_ReceiptNo', CaptionLabelReceiptNo);
        Captions.Add('Sale_EANHeader', CaptionLabelEANHeader);
        Captions.Add('Sale_LastSale', CaptionLabelLastSale);
        Captions.Add('Login_FunctionButtonText', CaptionFunctionButtonText);
        Captions.Add('Login_MainMenuButtonText', CaptionMainMenuButtonText);
        Captions.Add('Sale_PaymentAmount', CaptionLabelPaymentAmount);

        //-NPR5.39 [299908]
        //Captions.Add('Sale_PaymentTotal',CaptionLabelPaymentTotal);
        Captions.Add('Sale_PaymentTotal', StrSubstNo(CaptionLabelPaymentTotal2, GetLCYCode()));
        //+NPR5.39 [299908]

        Captions.Add('Sale_ReturnAmount', CaptionLabelReturnAmount);
        Captions.Add('Sale_RegisterNo', CaptionLabelRegisterNo);
        Captions.Add('Sale_SalesPersonCode', CaptionLabelSalesPersonCode);
        Captions.Add('Login_Clear', CaptionLabelClear);

        //-NPR5.37 [292323]
        //Captions.Add('Sale_SubTotal',CaptionLabelSubtotal);
        Captions.Add('Sale_SubTotal', StrSubstNo(CaptionLabelSubtotal, GetLCYCode));
        //+NPR5.37 [292323]

        Captions.Add('Payment_PaymentInfo', CaptionPaymentInfo);
        Captions.Add('Global_Cancel', CaptionGlobalCancel);
        Captions.Add('Global_Close', CaptionGlobalClose);
        Captions.Add('Global_Back', CaptionGlobalBack);
        Captions.Add('Global_OK', CaptionGlobalOK);
        Captions.Add('Global_Yes', CaptionGlobalYes);
        Captions.Add('Global_No', CaptionGlobalNo);
        Captions.Add('Global_Today', CaptionGlobalToday);
        Captions.Add('Global_Tomorrow', CaptionGlobalTomorrow);
        Captions.Add('Global_Yesterday', CaptionGlobalYesterday);
        Captions.Add('CaptionBalancingRegisterTransactions', CaptionBalancingRegisterTransactions);
        Captions.Add('CaptionBalancingRegisters', CaptionBalancingRegisters);
        Captions.Add('CaptionBalancingReceipts', CaptionBalancingReceipts);
        Captions.Add('CaptionBalancingBeginningBalance', CaptionBalancingBeginningBalance);
        Captions.Add('CaptionBalancingCashMovements', CaptionBalancingCashMovements);
        Captions.Add('CaptionBalancingMidTotal', CaptionBalancingMidTotal);
        Captions.Add('CaptionBalancingManualCards', CaptionBalancingManualCards);
        Captions.Add('CaptionBalancingTerminalCards', CaptionBalancingTerminalCards);
        Captions.Add('CaptionBalancingOtherCreditCards', CaptionBalancingOtherCreditCards);
        Captions.Add('CaptionBalancingTerminal', CaptionBalancingTerminal);
        Captions.Add('CaptionBalancingGiftCards', CaptionBalancingGiftCards);
        Captions.Add('CaptionBalancingCreditVouchers', CaptionBalancingCreditVouchers);
        Captions.Add('CaptionBalancingCustomerOutPayments', CaptionBalancingCustomerOutPayments);
        Captions.Add('CaptionBalancingDebitSales', CaptionBalancingDebitSales);
        Captions.Add('CaptionBalancingStaffSales', CaptionBalancingStaffSales);
        Captions.Add('CaptionBalancingNegativeReceiptAmount', CaptionBalancingNegativeReceiptAmount);
        Captions.Add('CaptionBalancingForeignCurrency', CaptionBalancingForeignCurrency);
        Captions.Add('CaptionBalancingReceiptStatistics', CaptionBalancingReceiptStatistics);
        Captions.Add('CaptionBalancingNumberOfSales', CaptionBalancingNumberOfSales);
        Captions.Add('CaptionBalancingCancelledSales', CaptionBalancingCancelledSales);
        Captions.Add('CaptionBalancingNumberOfNegativeReceipts', CaptionBalancingNumberOfNegativeReceipts);
        Captions.Add('CaptionBalancingTurnover', CaptionBalancingTurnover);
        Captions.Add('CaptionBalancingCOGS', CaptionBalancingCOGS);
        Captions.Add('CaptionBalancingContributionMargin', CaptionBalancingContributionMargin);
        Captions.Add('CaptionBalancingDiscounts', CaptionBalancingDiscounts);
        Captions.Add('CaptionBalancingCampaign', CaptionBalancingCampaign);
        Captions.Add('CaptionBalancingMixed', CaptionBalancingMixed);
        Captions.Add('CaptionBalancingQuantityDiscounts', CaptionBalancingQuantityDiscounts);
        Captions.Add('CaptionBalancingSalespersonDiscounts', CaptionBalancingSalespersonDiscounts);
        Captions.Add('CaptionBalancingBOMDiscounts', CaptionBalancingBOMDiscounts);
        Captions.Add('CaptionBalancingCustomerDiscounts', CaptionBalancingCustomerDiscounts);
        Captions.Add('CaptionBalancingOtherDiscounts', CaptionBalancingOtherDiscounts);
        Captions.Add('CaptionBalancingTotalDiscounts', CaptionBalancingTotalDiscounts);
        Captions.Add('CaptionBalancingOpenDrawer', CaptionBalancingOpenDrawer);
        Captions.Add('CaptionBalancingAuditRoll', CaptionBalancingAuditRoll);
        Captions.Add('CaptionBalancingCashCount', CaptionBalancingCashCount);
        Captions.Add('CaptionBalancingCountedLCY', CaptionBalancingCountedLCY);
        Captions.Add('CaptionBalancingDifferenceLCY', CaptionBalancingDifferenceLCY);
        Captions.Add('CaptionBalancingNewCashAmount', CaptionBalancingNewCashAmount);
        Captions.Add('CaptionBalancingPutInTheBank', CaptionBalancingPutInTheBank);
        Captions.Add('CaptionBalancingMoneybagNo', CaptionBalancingMoneybagNo);
        Captions.Add('CaptionBalancingAmount', CaptionBalancingAmount);
        Captions.Add('CaptionBalancingNumber', CaptionBalancingNumber);
        Captions.Add('CaptionBalancingRemainderTransferred', CaptionBalancingRemainderTransferred);
        Captions.Add('CaptionBalancingDelete', CaptionBalancingDelete);
        Captions.Add('CaptionBalancingClose', CaptionBalancingClose);
        Captions.Add('CaptionBalancing1Turnover', CaptionBalancing1Turnover);
        Captions.Add('CaptionBalancing2Counting', CaptionBalancing2Counting);
        Captions.Add('CaptionBalancing3Close', CaptionBalancing3Close);
        Captions.Add('CaptionDataGridSelected', CaptionDataGridSelected);
        Captions.Add('Lookup_Search', CaptionLookupSearch);
        Captions.Add('Lookup_Caption', CaptionLookup);
        Captions.Add('Lookup_New', CaptionLookupNew);
        Captions.Add('Lookup_Card', CaptionLookupShowCard);
        Captions.Add('DialogCaption_Message', CaptionMessage);
        Captions.Add('DialogCaption_Confirmation', CaptionConfirmation);
        Captions.Add('DialogCaption_Error', CaptionError);
        Captions.Add('DialogCaption_Numpad', CaptionNumpad);
        Captions.Add('Locked_RegisterLocked', CaptionLockedRegisterLocked);
        Captions.Add('CaptionTablet_ButtonItems', CaptionTabletButtonItems);
        Captions.Add('CaptionTablet_ButtonMore', CaptionTabletButtonMore);
        Captions.Add('CaptionTablet_ButtonPaymentMethods', CaptionTabletButtonPayments);
        Captions.Add('LastSale_Total', CaptionLastSale_Total);
        Captions.Add('LastSale_Paid', CaptionLastSale_Paid);
        Captions.Add('LastSale_Change', CaptionLastSale_Change);
        //-NPR5.38 [303053]
        Captions.Add('Payment_SaleLCY', CaptionPayment_SaleLCY);
        Captions.Add('Payment_Paid', CaptionPayment_Paid);
        Captions.Add('Payment_Balance', CaptionPayment_Balance);
        //+NPR5.38 [303053]

        RecRef.Open(DATABASE::"Sale Line POS");
        for i := 1 to RecRef.FieldCount do begin
            FieldRef := RecRef.FieldIndex(i);
            Captions.Add(StrSubstNo('Global_Record_%1_Field_%2', RecRef.Number, FieldRef.Number), FieldRef.Caption);
        end;
    end;

    procedure ConfigureReusableWorkflows(POSSession: Codeunit "POS Session"; Setup: Codeunit "POS Setup")
    var
        "Action": Record "POS Action" temporary;
        POSSetup: Record "POS Setup";
    begin
        //-NPR5.40 [306347]
        //Setup.Action_Item(Action);
        Setup.Action_Item(Action, POSSession);
        //+NPR5.40 [306347]
        //-NPR5.50 [338666]
        //ConfigureReusableWorkflow(Action,POSSession,STRSUBSTNO('%1, %2',POSSetup.TABLECAPTION,POSSetup.FIELDCAPTION("Item Insert Action Code")));
        ConfigureReusableWorkflow(Action, POSSession, StrSubstNo('%1, %2', POSSetup.TableCaption, POSSetup.FieldCaption("Item Insert Action Code")), POSSetup.FieldNo("Item Insert Action Code"));
        //+NPR5.50 [338666]

        //-NPR5.40 [306347]
        //Setup.Action_Payment(Action);
        Setup.Action_Payment(Action, POSSession);
        //+NPR5.40 [306347]
        //-NPR5.50 [338666]
        //ConfigureReusableWorkflow(Action,POSSession,STRSUBSTNO('%1, %2',POSSetup.TABLECAPTION,POSSetup.FIELDCAPTION("Payment Action Code")));
        ConfigureReusableWorkflow(Action, POSSession, StrSubstNo('%1, %2', POSSetup.TableCaption, POSSetup.FieldCaption("Payment Action Code")), POSSetup.FieldNo("Payment Action Code"));
        //+NPR5.50 [338666]

        //-NPR5.40 [306347]
        //Setup.Action_Customer(Action);
        Setup.Action_Customer(Action, POSSession);
        //+NPR5.40 [306347]
        //-NPR5.50 [338666]
        //ConfigureReusableWorkflow(Action,POSSession,STRSUBSTNO('%1, %2',POSSetup.TABLECAPTION,POSSetup.FIELDCAPTION("Customer Action Code")));
        ConfigureReusableWorkflow(Action, POSSession, StrSubstNo('%1, %2', POSSetup.TableCaption, POSSetup.FieldCaption("Customer Action Code")), POSSetup.FieldNo("Customer Action Code"));
        //+NPR5.50 [338666]

        //-NPR5.37 [293905]
        //-NPR5.40 [306347]
        //Setup.Action_LockPOS(Action);
        Setup.Action_LockPOS(Action, POSSession);
        //+NPR5.40 [306347]
        //-NPR5.50 [338666]
        //ConfigureReusableWorkflow(Action,POSSession,STRSUBSTNO('%1, %2',POSSetup.TABLECAPTION,POSSetup.FIELDCAPTION("Lock POS Action Code")));
        ConfigureReusableWorkflow(Action, POSSession, StrSubstNo('%1, %2', POSSetup.TableCaption, POSSetup.FieldCaption("Lock POS Action Code")), POSSetup.FieldNo("Lock POS Action Code"));
        //+NPR5.50 [338666]

        //-NPR5.40 [306347]
        //Setup.Action_UnlockPOS(Action);
        Setup.Action_UnlockPOS(Action, POSSession);
        //+NPR5.40 [306347]
        //-NPR5.50 [338666]
        //ConfigureReusableWorkflow(Action,POSSession,STRSUBSTNO('%1, %2',POSSetup.TABLECAPTION,POSSetup.FIELDCAPTION("Unlock POS Action Code")));
        ConfigureReusableWorkflow(Action, POSSession, StrSubstNo('%1, %2', POSSetup.TableCaption, POSSetup.FieldCaption("Unlock POS Action Code")), POSSetup.FieldNo("Unlock POS Action Code"));
        //+NPR5.50 [338666]
        //+NPR5.37 [293905]
    end;

    procedure ConfigureReusableWorkflow("Action": Record "POS Action"; POSSession: Codeunit "POS Session"; Source: Text; FieldNumber: Integer)
    var
        Button: Record "POS Menu Button";
        WorkflowAction: DotNet npNetWorkflowAction;
        POSParameterValue: Record "POS Parameter Value" temporary;
    begin
        with Button do begin
            "Action Type" := "Action Type"::Action;
            "Action Code" := Action.Code;
            //-NPR5.42 [314128]
            //GetAction(WorkflowAction,POSSession,Source,POSParameterValue,POSActionParameter);
            //-NPR5.50 [338666]
            RetrieveReusableWorkflowParameters(FieldNumber, POSParameterValue);
            //+NPR5.50 [338666]
            GetAction(WorkflowAction, POSSession, Source, POSParameterValue);
            //-NPR5.50 [338666]
            POSParameterValue.Reset();
            //+NPR5.50 [338666]
            //+NPR5.42 [314128]
            FrontEnd.ConfigureReusableWorkflow(WorkflowAction);
        end;
    end;

    procedure SetOptions(Setup: Codeunit "POS Setup")
    var
        Request: DotNet npNetSetOptionJsonRequest;
        Options: DotNet npNetDictionary_Of_T_U;
    begin
        Options := Request.GetDictionary();

        Options.Add('itemWorkflow', Setup.ActionCode_Item);
        Options.Add('paymentWorkflow', Setup.ActionCode_Payment);
        Options.Add('customerWorkflow', Setup.ActionCode_Customer);
        //-NPR5.37 [293905]
        Options.Add('lockWorkflow', Setup.ActionCode_LockPOS);
        Options.Add('unlockWorkflow', Setup.ActionCode_UnlockPOS);
        Options.Add('autoLockTimeout', Setup.GetLockTimeout());
        //+NPR5.37 [293905]
        //-NPR5.45 [323728]
        Options.Add('kioskUnlockEnabled', Setup.GetKioskUnlockEnabled());
        //+NPR5.45 [323728]
        //-NPR5.51 [361184]
        Options.Add('nprVersion',GetNPRVersion());
        //+NPR5.51 [361184]
        FrontEnd.SetOptions(Options);
    end;

    procedure AddActionCaption(Captions: DotNet npNetDictionary_Of_T_U; ActionCode: Text; CaptionId: Text; CaptionText: Text)
    begin
        if (Captions.ContainsKey(ActionCode + '.' + CaptionId)) then
            exit;
        Captions.Add(ActionCode + '.' + CaptionId, CaptionText);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "POS Caption Management")
    begin
    end;

    local procedure GetLCYCode(): Code[20]
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin

        //-NPR5.37 [292323]
        if (GeneralLedgerSetup.Get()) then
            if (GeneralLedgerSetup."LCY Code" <> '') then
                exit(StrSubstNo('(%1)', GeneralLedgerSetup."LCY Code"));

        exit('');
        //+NPR5.37 [292323]
    end;

    local procedure PreloadParameters(var tmpPOSParameterValue: Record "POS Parameter Value" temporary)
    var
        POSParameterValue: Record "POS Parameter Value";
    begin
        //-NPR5.40 [307453]
        //-NPR5.42 [314128]
        // IF POSActionParameter.FINDSET THEN
        //  REPEAT
        //    tmpPOSActionParameter := POSActionParameter;
        //    tmpPOSActionParameter.INSERT;
        //  UNTIL POSActionParameter.NEXT = 0;
        //+NPR5.42 [314128]

        POSParameterValue.SetRange("Table No.", DATABASE::"POS Menu Button");
        if POSParameterValue.FindSet then
            repeat
                tmpPOSParameterValue := POSParameterValue;
                tmpPOSParameterValue.Insert;
            until POSParameterValue.Next = 0;
        //+NPR5.40 [307453]
    end;

    local procedure RetrieveReusableWorkflowParameters(FieldNumber: Integer; var TmpPOSParameterValue: Record "POS Parameter Value" temporary)
    var
        POSParameterValue: Record "POS Parameter Value";
        POSSetup: Record "POS Setup";
    begin
        //-NPR5.51 [359825]
        POSSetup.Get;
        //+NPR5.51 [359825]

        //-NPR5.50 [338666]
        POSParameterValue.SetRange("Table No.", DATABASE::"POS Setup");
        POSParameterValue.SetRange(ID, FieldNumber);
        //-NPR5.51 [359825]
        POSParameterValue.SetRange("Record ID", POSSetup.RecordId);
        //+NPR5.51 [359825]
        if POSParameterValue.FindSet then
            repeat
                TmpPOSParameterValue := POSParameterValue;
                TmpPOSParameterValue.Insert;
            until POSParameterValue.Next = 0;
        TmpPOSParameterValue.SetParamFilterIndicator();
        //+NPR5.50 [338666]
    end;

    procedure GetNPRVersion(): Text
    var
        NPRUpgradeHistory: Record "NPR Upgrade History";
    begin
        //-NPR5.51 [361184]
        with NPRUpgradeHistory do begin
          SetCurrentKey("Upgrade Time");
          SetAscending("Upgrade Time",false);
          if not FindFirst then
            exit('');
          exit(Version);
        end;
        //+NPR5.51 [361184]
    end;
}

