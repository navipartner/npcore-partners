codeunit 6150702 "NPR POS UI Management"
{
    var
        FrontEnd: Codeunit "NPR POS Front End Management";
        WaterMarkDemo: Label 'DEMO demo DEMO demo';
        WaterMarkTest: Label 'TEST test TEST test';

    procedure Initialize(FrontEndIn: Codeunit "NPR POS Front End Management")
    begin
        FrontEnd := FrontEndIn;
    end;

    procedure InitializeCaptions()
    var
        Language: Record "Windows Language";
        Caption: Record "NPR POS Localized Caption";
        CaptionMgt: Codeunit "NPR POS Caption Management";
        Captions: JsonObject;
    begin
        Language.Get(GlobalLanguage);
        ConfigureCaptions(Captions);

        Caption.SetFilter("Caption ID", '<>%1', '');
        Caption.SetFilter("Language Code", '%1|%2', '', Language."Abbreviated Name");
        if Caption.FindSet then
            repeat
                if Captions.Contains(Caption."Caption ID") then
                    Captions.Remove(Caption."Caption ID");
                Captions.Add(Caption."Caption ID", Caption.Caption);
            until Caption.Next = 0;

        CaptionMgt.Initialize(FrontEnd);
        OnInitializeCaptions(CaptionMgt);
        CaptionMgt.Finalize(Captions);

        FrontEnd.ConfigureCaptions(Captions);
    end;

    procedure InitializeNumberAndDateFormat(POSUnit: Record "NPR POS Unit")
    var
        POSViewProfile: Record "NPR POS View Profile";
    begin
        if not POSViewProfile.Get(POSUnit."POS View Profile") then
            Clear(POSViewProfile);

        FrontEnd.ConfigureNumberAndDateFormats(POSViewProfile);
    end;

    procedure InitializeLogo(POSUnit: Record "NPR POS Unit")
    var
        InStr: InStream;
        Base64: Codeunit "Base64 Convert";
        POSViewProfile: Record "NPR POS View Profile";
    begin
        if (not POSViewProfile.Get(POSUnit."POS View Profile")) or (not POSViewProfile.Picture.HasValue()) then
            exit;

        POSViewProfile.CalcFields(Picture);
        POSViewProfile.Picture.CreateInStream(InStr);
        FrontEnd.ConfigureLogo(Base64.ToBase64(InStr));
    end;

    procedure InitializeMenus(POSUnit: Record "NPR POS Unit"; Salesperson: Record "Salesperson/Purchaser"; POSSession: Codeunit "NPR POS Session")
    var
        Menu: Record "NPR POS Menu";
        tmpPOSParameterValue: Record "NPR POS Parameter Value" temporary;
        POSViewProfile: Record "NPR POS View Profile";
        MenuObj: Codeunit "NPR POS Menu";
        Menus: JsonArray;
    begin
        if not POSViewProfile.Get(POSUnit."POS View Profile") then
            Clear(POSViewProfile);

        PreloadParameters(tmpPOSParameterValue);

        Menu.SetRange(Blocked, false);
        Menu.SetFilter("Register Type", '%1|%2', POSViewProfile.Code, '');
        Menu.SetFilter("Register No.", '%1|%2', POSUnit."No.", '');
        Menu.SetFilter("Salesperson Code", '%1|%2', Salesperson.Code, '');

        if Menu.FindSet() then
            repeat
                Clear(MenuObj);
                InitializeMenu(Menu, MenuObj, POSSession, tmpPOSParameterValue);
                Menus.Add(MenuObj.GetJson);
            until Menu.Next() = 0;
        FrontEnd.ConfigureMenu(Menus);
    end;

    local procedure InitializeMenu(var Menu: Record "NPR POS Menu"; MenuObj: Codeunit "NPR POS Menu"; POSSession: Codeunit "NPR POS Session"; var tmpPOSParameterValue: Record "NPR POS Parameter Value" temporary)
    var
        MenuButton: Record "NPR POS Menu Button";
    begin
        POSSession.DebugWithTimestamp('Initializing menu [' + Menu.Code + ']');
        InitializeMenuObject(Menu, MenuObj);

        MenuButton.SetRange("Menu Code", Menu.Code);
        MenuButton.SetRange(Blocked, false);
        Menu.CopyFilter("Register Type", MenuButton."Register Type");
        Menu.CopyFilter("Register No.", MenuButton."Register No.");
        MenuButton.SetRange("Parent ID", 0);

        InitializeMenuButtons(MenuButton, MenuObj, POSSession, tmpPOSParameterValue);
    end;

    local procedure InitializeMenuObject(Menu: Record "NPR POS Menu"; MenuObj: Codeunit "NPR POS Menu")
    begin
        MenuObj.SetId(Menu.Code);
        MenuObj.SetCaption(Menu.Caption);
        MenuObj.SetTooltip(Menu.Tooltip);
        MenuObj.SetClass(Menu."Custom Class Attribute");
    end;

    local procedure InitializeSubmenu(var MenuButton: Record "NPR POS Menu Button"; ISubMenu: Interface "NPR ISubMenu"; POSSession: Codeunit "NPR POS Session"; var tmpPOSParameterValue: Record "NPR POS Parameter Value" temporary)
    var
        SubMenuButton: Record "NPR POS Menu Button";
    begin
        SubMenuButton.CopyFilters(MenuButton);
        SubMenuButton.SetRange("Parent ID", MenuButton.ID);
        InitializeMenuButtons(SubMenuButton, ISubMenu, POSSession, tmpPOSParameterValue);
    end;

    local procedure InitializeMenuButtons(var SubMenuButton: Record "NPR POS Menu Button"; ISubMenu: Interface "NPR ISubMenu"; POSSession: Codeunit "NPR POS Session"; var tmpPOSParameterValue: Record "NPR POS Parameter Value" temporary)
    var
        MenuButtonObj: Codeunit "NPR POS Menu Button";
    begin
        if SubMenuButton.FindSet() then
            repeat
                InitializeMenuButtonObject(SubMenuButton, MenuButtonObj, POSSession, tmpPOSParameterValue);
                ISubMenu.AddMenuButton(MenuButtonObj);
                if SubMenuButton."Action Type" = SubMenuButton."Action Type"::Submenu then
                    InitializeSubmenu(SubMenuButton, MenuButtonObj, POSSession, tmpPOSParameterValue);
            until SubMenuButton.Next() = 0;
    end;

    local procedure InitializeMenuButtonObject(MenuButton: Record "NPR POS Menu Button"; var MenuButtonObj: Codeunit "NPR POS Menu Button"; POSSession: Codeunit "NPR POS Session"; var tmpPOSParameterValue: Record "NPR POS Parameter Value" temporary)
    var
        ActionObj: Interface "NPR IAction";
    begin
        Clear(MenuButtonObj);
        MenuButtonObj.SetCaption(MenuButton.GetLocalizedCaption(MenuButton.FieldNo(Caption)));
        MenuButtonObj.SetTooltip(MenuButton.Tooltip);
        MenuButtonObj.SetBackgroundColor(MenuButton."Background Color");
        MenuButtonObj.SetColor(MenuButton."Foreground Color");
        MenuButtonObj.SetIconClass(MenuButton."Icon Class");
        MenuButtonObj.SetClass(MenuButton."Custom Class Attribute");
        MenuButtonObj.SetBold(MenuButton.Bold);
        MenuButtonObj.SetRow(MenuButton."Position Y");
        MenuButtonObj.SetColumn(MenuButton."Position X");
        MenuButtonObj.SetFontSize(MenuButton."Font Size");
        MenuButtonObj.SetEnabledState(MenuButton.Enabled);
        MenuButtonObj.Content.Add('keyMenu', MenuButton."Menu Code");
        MenuButtonObj.Content.Add('keyId', MenuButton.ID);

        InitializeMenuButtonObjectFilters(MenuButton, MenuButtonObj);

        if MenuButton.GetAction(ActionObj, POSSession, StrSubstNo('%1 [%2, %3]', MenuButton.TableCaption, MenuButton."Menu Code", MenuButton.Caption), tmpPOSParameterValue) then
            MenuButtonObj.SetAction(ActionObj);

        MenuButton.StoreButtonConfiguration(MenuButtonObj);
    end;

    local procedure InitializeMenuButtonObjectFilters(MenuButton: Record "NPR POS Menu Button"; MenuButtonObj: Codeunit "NPR POS Menu Button")
    begin
        if MenuButton."Salesperson Code" <> '' then
            MenuButtonObj.Content.Add('filterSalesPerson', MenuButton."Salesperson Code");
        if MenuButton."Register No." <> '' then
            MenuButtonObj.Content.Add('filterRegister', MenuButton."Register No.");
    end;

    procedure InitializeTheme(POSUnit: Record "NPR POS Unit")
    var
        POSTheme: Record "NPR POS Theme";
        ThemeDep: Record "NPR POS Theme Dependency";
        WebClientDep: Record "NPR Web Client Dependency";
        POSViewProfile: Record "NPR POS View Profile";
        ThemeLine: JsonObject;
        Theme: JsonArray;
        DependencyContent: Text;
    begin
        if (not POSViewProfile.Get(POSUnit."POS View Profile")) or (not POSTheme.Get(POSViewProfile."POS Theme Code")) or POSTheme.Blocked then
            exit;

        ThemeDep.SetRange("POS Theme Code", POSViewProfile."POS Theme Code");
        ThemeDep.SetRange(Blocked, false);
        ThemeDep.SetFilter("Dependency Code", '<>%1', '');
        if not ThemeDep.FindSet() then
            exit;

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
                Clear(ThemeLine);
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
    end;

    procedure InitializeAdministrativeTemplates(POSUnit: Record "NPR POS Unit")
    var
        AdminTemplate: Record "NPR POS Admin. Template";
        AdminTemplateScope: Record "NPR POS Admin. Template Scope";
        AdminTemplateScopeTmp: Record "NPR POS Admin. Template Scope" temporary;
        Templates: JsonArray;
        Template: JsonObject;
    begin
        AdminTemplateScope.SetRange("Applies To", AdminTemplateScope."Applies To"::All);
        if AdminTemplateScope.FindSet then
            repeat
                AdminTemplateScopeTmp := AdminTemplateScope;
                AdminTemplateScopeTmp.Insert();
            until AdminTemplateScope.Next = 0;

        AdminTemplateScope.SetRange("Applies To", AdminTemplateScope."Applies To"::"POS Unit");
        AdminTemplateScope.SetRange("Applies To Code", POSUnit."No.");
        if AdminTemplateScope.FindSet then
            repeat
                AdminTemplateScopeTmp := AdminTemplateScope;
                AdminTemplateScopeTmp.Insert();
            until AdminTemplateScope.Next = 0;

        AdminTemplateScope.SetRange("Applies To", AdminTemplateScope."Applies To"::User);
        AdminTemplateScope.SetRange("Applies To Code", UserId);
        if AdminTemplateScope.FindSet then
            repeat
                AdminTemplateScopeTmp := AdminTemplateScope;
                AdminTemplateScopeTmp.Insert();
            until AdminTemplateScope.Next = 0;

        if AdminTemplateScopeTmp.IsEmpty then
            exit;

        AdminTemplateScopeTmp.FindSet();
        repeat
            if AdminTemplate.Get(AdminTemplateScopeTmp."POS Admin. Template Id") and (AdminTemplate.Status <> AdminTemplate.Status::Draft) then begin
                Template := CreateAdministrativeTemplatePolicy(AdminTemplate.Id, AdminTemplate."Persist on Client", AdminTemplateScopeTmp."Applies To");
                case AdminTemplate.Status of
                    AdminTemplate.Status::Active:
                        begin
                            ApplyAdministrativeTemplatePasswordPolicy(Template, 'roleCenter', AdminTemplate."Role Center", AdminTemplate."Role Center Password");
                            ApplyAdministrativeTemplatePasswordPolicy(Template, 'configuration', AdminTemplate.Configuration, AdminTemplate."Configuration Password");
                        end;
                    AdminTemplate.Status::Retired:
                        Template.Add('retired', true);
                end;
            end;
            Templates.Add(Template);
        until AdminTemplateScopeTmp.Next = 0;
        FrontEnd.ApplyAdministrativeTemplates(Templates);
    end;

    local procedure CreateAdministrativeTemplatePolicy(Id: Guid; Persist: Boolean; AppliesTo: Integer) Template: JsonObject;
    begin
        Template.Add('id', Id);
        Template.Add('persist', Persist);
        Template.Add('strength', AppliesTo);
    end;

    local procedure ApplyAdministrativeTemplatePasswordPolicy(Template: JsonObject; PolicyName: Text; Policy: Option "Not Defined",Visible,Disabled,Hidden,Password; Password: Text)
    var
        PolicyObject: JsonObject;
    begin
        case Policy of
            Policy::Disabled:
                Template.Add(PolicyName, 'deny');
            Policy::Hidden:
                Template.Add(PolicyName, 'hide');
            Policy::Visible:
                Template.Add(PolicyName, 'allow');
            Policy::Password:
                begin
                    PolicyObject.Add('password', Password);
                    Template.Add(PolicyName, PolicyObject);
                end;
        end;
    end;

    procedure ConfigureFonts()
    var
        WebFont: Record "NPR POS Web Font";
        Font: Codeunit "NPR Web Font";
    begin
        WebFont.SetFilter("Company Name", '%1|%2', '', CompanyName);
        if WebFont.FindSet then
            repeat
                WebFont.GetWebFont(Font);
                FrontEnd.ConfigureFont(Font);
            until WebFont.Next = 0;
    end;

    local procedure ConfigureCaptions(Captions: JsonObject)
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
        i: Integer;
        CaptionLabelReceiptNo: Label 'Sale';
        CaptionLabelEANHeader: Label 'Item No.';
        CaptionLabelLastSale: Label 'Last Sale';
        CaptionFunctionButtonText: Label 'Function';
        CaptionMainMenuButtonText: Label 'Main Menu';
        CaptionLabelReturnAmount: Label 'Balance';
        CaptionLabelRegisterNo: Label 'POS Unit';
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
        CaptionGlobalAbort: Label 'Abort';
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
        CaptionItemCount: Label 'Item Count';
        Sale_TimeoutTitle: Label 'We seem to have lost you...';
        Sale_TimeoutCaption: Label 'Do you wish to continue?';
        Sale_TimeoutButtonCaption: Label 'Yes please, I need some more time.';
        Payment_TimeoutTitle: Label 'We seem to have lost you...';
        Payment_TimeoutCaption: Label 'Do you wish to continue?';
        Payment_TimeoutButtonCaption: Label 'Yes please, I need some more time.';
    begin
        Captions.Add('Sale_ReceiptNo', CaptionLabelReceiptNo);
        Captions.Add('Sale_EANHeader', CaptionLabelEANHeader);
        Captions.Add('Sale_LastSale', CaptionLabelLastSale);
        Captions.Add('Login_FunctionButtonText', CaptionFunctionButtonText);
        Captions.Add('Login_MainMenuButtonText', CaptionMainMenuButtonText);
        Captions.Add('Sale_PaymentAmount', CaptionLabelPaymentAmount);
        Captions.Add('Sale_TimeoutTitle', Sale_TimeoutTitle);
        Captions.Add('Sale_TimeoutCaption', Sale_TimeoutCaption);
        Captions.Add('Sale_TimeoutButtonCaption', Sale_TimeoutButtonCaption);
        Captions.Add('Payment_TimeoutTitle', Payment_TimeoutTitle);
        Captions.Add('Payment_TimeoutCaption', Payment_TimeoutCaption);
        Captions.Add('Payment_TimeoutButtonCaption', Payment_TimeoutButtonCaption);
        Captions.Add('Sale_PaymentTotal', StrSubstNo(CaptionLabelPaymentTotal2, GetLCYCode()));
        Captions.Add('Sale_ReturnAmount', CaptionLabelReturnAmount);
        Captions.Add('Sale_RegisterNo', CaptionLabelRegisterNo);
        Captions.Add('Sale_SalesPersonCode', CaptionLabelSalesPersonCode);
        Captions.Add('Login_Clear', CaptionLabelClear);
        Captions.Add('Sale_SubTotal', StrSubstNo(CaptionLabelSubtotal, GetLCYCode));
        Captions.Add('Item_Count', CaptionItemCount);
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
        Captions.Add('Global_Abort', CaptionGlobalAbort);
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
        Captions.Add('Payment_SaleLCY', CaptionPayment_SaleLCY);
        Captions.Add('Payment_Paid', CaptionPayment_Paid);
        Captions.Add('Payment_Balance', CaptionPayment_Balance);

        RecRef.Open(DATABASE::"NPR Sale Line POS");
        for i := 1 to RecRef.FieldCount do begin
            FieldRef := RecRef.FieldIndex(i);
            Captions.Add(StrSubstNo('Global_Record_%1_Field_%2', RecRef.Number, FieldRef.Number), FieldRef.Caption);
        end;
    end;

    procedure ConfigureReusableWorkflows(POSSession: Codeunit "NPR POS Session"; Setup: Codeunit "NPR POS Setup")
    var
        "Action": Record "NPR POS Action" temporary;
        POSSetup: Record "NPR POS Setup";
    begin
        Setup.Action_Item(Action, POSSession);
        ConfigureReusableWorkflow(Action, POSSession, StrSubstNo('%1, %2', POSSetup.TableCaption, POSSetup.FieldCaption("Item Insert Action Code")), POSSetup.FieldNo("Item Insert Action Code"));

        Setup.Action_Payment(Action, POSSession);
        ConfigureReusableWorkflow(Action, POSSession, StrSubstNo('%1, %2', POSSetup.TableCaption, POSSetup.FieldCaption("Payment Action Code")), POSSetup.FieldNo("Payment Action Code"));

        Setup.Action_Customer(Action, POSSession);
        ConfigureReusableWorkflow(Action, POSSession, StrSubstNo('%1, %2', POSSetup.TableCaption, POSSetup.FieldCaption("Customer Action Code")), POSSetup.FieldNo("Customer Action Code"));

        Setup.Action_LockPOS(Action, POSSession);
        ConfigureReusableWorkflow(Action, POSSession, StrSubstNo('%1, %2', POSSetup.TableCaption, POSSetup.FieldCaption("Lock POS Action Code")), POSSetup.FieldNo("Lock POS Action Code"));

        Setup.Action_UnlockPOS(Action, POSSession);
        ConfigureReusableWorkflow(Action, POSSession, StrSubstNo('%1, %2', POSSetup.TableCaption, POSSetup.FieldCaption("Unlock POS Action Code")), POSSetup.FieldNo("Unlock POS Action Code"));

        Setup.Action_Login(Action, POSSession);
        ConfigureReusableWorkflow(Action, POSSession, StrSubstNo('%1, %2', POSSetup.TableCaption, POSSetup.FieldCaption("Login Action Code")), POSSetup.FieldNo("Login Action Code"));

        Setup.Action_TextEnter(Action, POSSession);
        ConfigureReusableWorkflow(Action, POSSession, StrSubstNo('%1, %2', POSSetup.TableCaption, POSSetup.FieldCaption("Text Enter Action Code")), POSSetup.FieldNo("Text Enter Action Code"));

        Setup.Action_IdleTimeout(Action, POSSession);
        ConfigureReusableWorkflow(Action, POSSession, StrSubstNo('%1, %2', POSSetup.TableCaption, POSSetup.FieldCaption("Idle Timeout Action Code")), POSSetup.FieldNo("Idle Timeout Action Code"));

        Setup.Action_AdminMenu(Action, POSSession);
        ConfigureReusableWorkflow(Action, POSSession, StrSubstNo('%1, %2', POSSetup.TableCaption, POSSetup.FieldCaption("Admin Menu Action Code")), POSSetup.FieldNo("Admin Menu Action Code"));

        OnConfigureReusableWorkflows(POSSession, Setup);
    end;

    procedure ConfigureReusableWorkflow("Action": Record "NPR POS Action"; POSSession: Codeunit "NPR POS Session"; Source: Text; FieldNumber: Integer)
    var
        Button: Record "NPR POS Menu Button";
        POSParameterValue: Record "NPR POS Parameter Value" temporary;
        POSUnit: Record "NPR POS Unit";
        WorkflowAction: Codeunit "NPR Workflow Action";
        POSSetup: Codeunit "NPR POS Setup";
    begin
        POSSession.GetSetup(POSSetup);
        POSSetup.GetPOSUnit(POSUnit);

        Button."Action Type" := Button."Action Type"::Action;
        Button."Action Code" := Action.Code;

        RetrieveReusableWorkflowParameters(FieldNumber, POSUnit."POS Named Actions Profile", POSParameterValue);
        WorkflowAction.ConfigureFromMenuButton(Button, POSSession, WorkflowAction);

        POSParameterValue.Reset();
        FrontEnd.ConfigureReusableWorkflow(WorkflowAction);
    end;

    procedure SetOptions(Setup: Codeunit "NPR POS Setup")
    var
        POSSetup: Record "NPR POS Setup";
        POSActionParameterMgt: Codeunit "NPR POS Action Param. Mgt.";
        LicenseInformation: Codeunit "NPR License Information";
        Options: JsonObject;
    begin
        Options.Add('itemWorkflow', Setup.ActionCode_Item);
        Options.Add('paymentWorkflow', Setup.ActionCode_Payment);
        Options.Add('customerWorkflow', Setup.ActionCode_Customer);
        Options.Add('lockWorkflow', Setup.ActionCode_LockPOS);
        Options.Add('unlockWorkflow', Setup.ActionCode_UnlockPOS);
        Options.Add('autoLockTimeout', Setup.GetLockTimeout());
        Options.Add('loginWorkflow', Setup.ActionCode_Login);
        Options.Add('textEnterWorkflow', Setup.ActionCode_TextEnter);
        Options.Add('kioskUnlockEnabled', Setup.GetKioskUnlockEnabled());
        Options.Add('idleTimeoutWorkflow', Setup.ActionCode_IdleTimeout());
        Options.Add('posUnitType', Format(GetPOSUnitType(Setup), 0, 9));
        Options.Add('adminMenuWorkflow', Setup.ActionCode_AdminMenu());
        Setup.GetNamedActionSetup(POSSetup);
        Options.Add('adminMenuWorkflow_parameters', POSActionParameterMgt.GetParametersAsJson(POSSetup.RecordId, POSSetup.FieldNo("Admin Menu Action Code")));
        Options.Add('nprVersion', LicenseInformation.GetRetailVersion());

        OnSetOptions(Setup, Options);

        FrontEnd.SetOptions(Options);
    end;

    procedure AddActionCaption(Captions: Dictionary of [Text, Text]; ActionCode: Text; CaptionId: Text; CaptionText: Text)
    begin
        if (Captions.ContainsKey(ActionCode + '.' + CaptionId)) then
            exit;
        Captions.Add(ActionCode + '.' + CaptionId, CaptionText);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    begin
    end;

    local procedure GetLCYCode(): Code[20]
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        if (GeneralLedgerSetup.Get()) then
            if (GeneralLedgerSetup."LCY Code" <> '') then
                exit(StrSubstNo('(%1)', GeneralLedgerSetup."LCY Code"));

        exit('');
    end;

    local procedure PreloadParameters(var tmpPOSParameterValue: Record "NPR POS Parameter Value" temporary)
    var
        POSParameterValue: Record "NPR POS Parameter Value";
    begin
        POSParameterValue.SetRange("Table No.", DATABASE::"NPR POS Menu Button");
        if POSParameterValue.FindSet then
            repeat
                tmpPOSParameterValue := POSParameterValue;
                tmpPOSParameterValue.Insert;
            until POSParameterValue.Next = 0;
    end;

    local procedure RetrieveReusableWorkflowParameters(FieldNumber: Integer; POSSetupProfileCode: Code[20]; var TmpPOSParameterValue: Record "NPR POS Parameter Value" temporary)
    var
        POSParameterValue: Record "NPR POS Parameter Value";
        POSSetup: Record "NPR POS Setup";
    begin
        POSSetup.Get(POSSetupProfileCode);
        POSParameterValue.SetRange("Table No.", DATABASE::"NPR POS Setup");
        POSParameterValue.SetRange(ID, FieldNumber);
        POSParameterValue.SetRange("Record ID", POSSetup.RecordId);
        if POSParameterValue.FindSet then
            repeat
                TmpPOSParameterValue := POSParameterValue;
                TmpPOSParameterValue.Insert;
            until POSParameterValue.Next = 0;
        TmpPOSParameterValue.SetParamFilterIndicator();
    end;

    local procedure GetPOSUnitType(POSSetup: Codeunit "NPR POS Setup"): Integer
    var
        POSUnit: Record "NPR POS Unit";
    begin
        POSSetup.GetPOSUnit(POSUnit);
        exit(POSUnit."POS Type");
    end;

    [IntegrationEvent(true, false)]
    local procedure OnConfigureReusableWorkflows(POSSession: Codeunit "NPR POS Session"; Setup: Codeunit "NPR POS Setup")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSetOptions(Setup: Codeunit "NPR POS Setup"; var Options: JsonObject)
    begin
    end;
}
