codeunit 6150702 "NPR POS UI Management"
{
    var
        FrontEnd: Codeunit "NPR POS Front End Management";

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
        if Caption.FindSet() then
            repeat
                if Captions.Contains(Caption."Caption ID") then
                    Captions.Remove(Caption."Caption ID");
                Captions.Add(Caption."Caption ID", Caption.Caption);
            until Caption.Next() = 0;

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
        OutStr: OutStream;
        Base64: Codeunit "Base64 Convert";
        TempBlob: Codeunit "Temp Blob";

        POSViewProfile: Record "NPR POS View Profile";
    begin
        if not POSViewProfile.Get(POSUnit."POS View Profile") then
            exit;
        if not POSViewProfile.Image.HasValue() then
            exit;

        TempBlob.CreateOutStream(OutStr);
        POSViewProfile.Image.ExportStream(OutStr);
        TempBlob.CreateInStream(InStr);

        FrontEnd.ConfigureLogo(Base64.ToBase64(InStr));
    end;

    procedure InitializeMenus(POSUnit: Record "NPR POS Unit"; Salesperson: Record "Salesperson/Purchaser"; POSSession: Codeunit "NPR POS Session")
    var
        Menu: Record "NPR POS Menu";
        TempPOSParameterValue: Record "NPR POS Parameter Value" temporary;
        POSViewProfile: Record "NPR POS View Profile";
        MenuObj: Codeunit "NPR POS Menu";
        Menus: JsonArray;
    begin
        if not POSViewProfile.Get(POSUnit."POS View Profile") then
            Clear(POSViewProfile);

        PreloadParameters(TempPOSParameterValue);

        Menu.SetRange(Blocked, false);
        Menu.SetFilter("Register Type", '%1|%2', POSViewProfile.Code, '');
        Menu.SetFilter("Register No.", '%1|%2', POSUnit."No.", '');
        Menu.SetFilter("Salesperson Code", '%1|%2', Salesperson.Code, '');

        if Menu.FindSet() then
            repeat
                Clear(MenuObj);
                InitializeMenu(Menu, MenuObj, POSSession, TempPOSParameterValue);
                Menus.Add(MenuObj.GetJson());
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
        MenuButtonLbl: Label '%1 [%2, %3]', Locked = true;
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
        MenuButtonObj.Content().Add('keyMenu', MenuButton."Menu Code");
        MenuButtonObj.Content().Add('keyId', MenuButton.ID);

        InitializeMenuButtonObjectFilters(MenuButton, MenuButtonObj);

        if MenuButton.GetAction(ActionObj, POSSession, StrSubstNo(MenuButtonLbl, MenuButton.TableCaption, MenuButton."Menu Code", MenuButton.Caption), tmpPOSParameterValue) then
            MenuButtonObj.SetAction(ActionObj);

        MenuButton.StoreButtonConfiguration(MenuButtonObj);
    end;

    local procedure InitializeMenuButtonObjectFilters(MenuButton: Record "NPR POS Menu Button"; MenuButtonObj: Codeunit "NPR POS Menu Button")
    begin
        if MenuButton."Salesperson Code" <> '' then
            MenuButtonObj.Content().Add('filterSalesPerson', MenuButton."Salesperson Code");
        if MenuButton."Register No." <> '' then
            MenuButtonObj.Content().Add('filterRegister', MenuButton."Register No.");
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
        until ThemeDep.Next() = 0;
        FrontEnd.ConfigureTheme(Theme);
    end;

    procedure InitializeAdministrativeTemplates(POSUnit: Record "NPR POS Unit")
    var
        AdminTemplate: Record "NPR POS Admin. Template";
        AdminTemplateScope: Record "NPR POS Admin. Template Scope";
        TempAdminTemplateScope: Record "NPR POS Admin. Template Scope" temporary;
        Templates: JsonArray;
        Template: JsonObject;
    begin
        AdminTemplateScope.SetRange("Applies To", AdminTemplateScope."Applies To"::All);
        if AdminTemplateScope.FindSet() then
            repeat
                TempAdminTemplateScope := AdminTemplateScope;
                TempAdminTemplateScope.Insert();
            until AdminTemplateScope.Next() = 0;

        AdminTemplateScope.SetRange("Applies To", AdminTemplateScope."Applies To"::"POS Unit");
        AdminTemplateScope.SetRange("Applies To Code", POSUnit."No.");
        if AdminTemplateScope.FindSet() then
            repeat
                TempAdminTemplateScope := AdminTemplateScope;
                TempAdminTemplateScope.Insert();
            until AdminTemplateScope.Next() = 0;

        AdminTemplateScope.SetRange("Applies To", AdminTemplateScope."Applies To"::User);
        AdminTemplateScope.SetRange("Applies To Code", UserId);
        if AdminTemplateScope.FindSet() then
            repeat
                TempAdminTemplateScope := AdminTemplateScope;
                TempAdminTemplateScope.Insert();
            until AdminTemplateScope.Next() = 0;

        if TempAdminTemplateScope.IsEmpty then
            exit;

        TempAdminTemplateScope.FindSet();
        repeat
            if AdminTemplate.Get(TempAdminTemplateScope."POS Admin. Template Id") and (AdminTemplate.Status <> AdminTemplate.Status::Draft) then begin
                Template := CreateAdministrativeTemplatePolicy(AdminTemplate.Id, AdminTemplate."Persist on Client", TempAdminTemplateScope."Applies To");
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
        until TempAdminTemplateScope.Next() = 0;
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
        if WebFont.FindSet() then
            repeat
                WebFont.GetWebFont(Font);
                FrontEnd.ConfigureFont(Font);
            until WebFont.Next() = 0;
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
        CaptionLabelPaymentTotal2: Label 'Sale %1';
        CaptionLabelSubtotal: Label 'SUBTOTAL %1';
        CaptionLabelTotal: Label 'TOTAL %1';
        CaptionLabelVATAmt: Label 'VAT AMOUNT %1';
        CaptionLabelTaxAmt: Label 'TAX AMOUNT %1';
        CaptionPaymentInfo: Label 'Payment info';
        CaptionGlobalCancel: Label 'Cancel';
        CaptionGlobalClose: Label 'Close';
        CaptionGlobalBack: Label 'Back';
        CaptionGlobalOK: Label 'OK';
        CaptionGlobalYes: Label 'Yes';
        CaptionGlobalNo: Label 'No';
        CaptionGlobalToday: Label 'today';
        CaptionGlobalTomorrow: Label 'tomorrow';
        CaptionGlobalYesterday: Label 'yesterday';
        CaptionGlobalAbort: Label 'Abort';
        BalancingCashMovementsLbl: Label 'Cash Movements';
        BalancingBalancingLbl: Label 'Balancing';
        BalancingCreatedAtLbl: Label 'Created At';
        BalancingDirectSalesCountLbl: Label 'Direct Sales Count';
        BalancingDirectItemsReturnLineLbl: Label 'Direct Items Return Line';
        BalancingOverviewLbl: Label 'Overview';
        BalancingSalesLbl: Label 'Sales';
        BalancingDirectItemSalesLCYLbl: Label 'Direct Item Sales (LCY)';
        BalancingDirectItemReturnsLCYLbl: Label 'Direct Item Returns (LCY)';
        BalancingLocalCurrencyLCYLbl: Label 'Local Currency (LCY)';
        BalancingForeignCurrencyLCYLbl: Label 'Foreign Currency (LCY)';
        BalancingOtherPaymentsLbl: Label 'Other Payments';
        BalancingDebtorPaymentLCYLbl: Label 'Debtor Payment (LCY)';
        BalancingEFTLCYLbl: Label 'EFT (LCY)';
        BalancingGLPaymentLCYLbl: Label 'GL Payment (LCY)';
        BalancingVoucherLbl: Label 'Voucher';
        BalancingRedeemedVouchersLCYLbl: Label 'Redeemed Vouchers (LCY)';
        BalancingIssuedVouchersLCYLbl: Label 'Issued Vouchers (LCY)';
        BalancingOtherLbl: Label 'Other';
        BalancingRoundingLCYLbl: Label 'Rounding (LCY)';
        BalancingBinTransferOutAmountLCYLbl: Label 'Bin Transfer Out Amount (LCY)';
        BalancingBinTransferInAmountLCYLbl: Label 'Bin Transfer In Amount (LCY)';
        BalancingCreditSalesLbl: Label 'Credit Sales';
        BalancingCreditSalesCountLCYLbl: Label 'Credit Sales Count (LCY)';
        BalancingCreditSalesAmountLCYLbl: Label 'Credit Sales Amount (LCY)';
        BalancingCreditNetSalesAmountLCYLbl: Label 'Credit Net Sales Amount (LCY)';
        BalancingDetailsLbl: Label 'Details';
        BalancingCreditUnrealSaleAmtLCYLbl: Label 'Credit Unreal. Sale Amt. (LCY)';
        BalancingCreditUnrealRetAmtLCYLbl: Label 'Credit Unreal. Ret. Amt. (LCY)';
        BalancingCreditRealSaleAmtLCYLbl: Label 'Credit Real. Sale Amt. (LCY)';
        BalancingCreditRealReturnAmtLCYLbl: Label 'Credit Real. Return Amt. (LCY)';
        BalancingDiscountLbl: Label 'Discount';
        BalancingDiscountAmountsLbl: Label 'Discount Amounts';
        BalancingCampaignDiscountLCYLbl: Label 'Campaign Discount (LCY)';
        BalancingMixDiscountLCYLbl: Label 'Mix Discount (LCY)';
        BalancingQuantityDiscountLCYLbl: Label 'Quantity Discount (LCY)';
        BalancingCustomDiscountLCYLbl: Label 'Custom Discount (LCY)';
        BalancingBOMDiscountLCYLbl: Label 'BOM Discount (LCY)';
        BalancingCustomerDiscountLCYLbl: Label 'Customer Discount (LCY)';
        BalancingLineDiscountLCYLbl: Label 'Line Discount (LCY)';
        BalancingDiscountPercentLbl: Label 'Discount Percent';
        BalancingCampaignDiscountPctLbl: Label 'Campaign Discount %';
        BalancingMixDiscountPctLbl: Label 'Mix Discount %';
        BalancingQuantityDiscountPctLbl: Label 'Quantity Discount %';
        BalancingCustomDiscountPctLbl: Label 'Custom Discount %';
        BalancingBOMDiscountPctLbl: Label 'BOM Discount %';
        BalancingCustomerDiscountPctLbl: Label 'Customer Discount %';
        BalancingLineDiscountPctLbl: Label 'Line Discount %';
        BalancingDiscountTotalLbl: Label 'Discount Total';
        BalancingTotalDiscountLCYLbl: Label 'Total Discount (LCY)';
        BalancingTotalDiscountPctLbl: Label 'Total Discount %';
        BalancingTurnoverLbl: Label 'Turnover';
        BalancingTurnoverLCYLbl: Label 'Turnover (LCY)';
        BalancingNetTurnoverLCYLbl: Label 'Net Turnover (LCY)';
        BalancingNetCostLCYLbl: Label 'Net Cost (LCY)';
        BalancingProfitLbl: Label 'Profit';
        BalancingProfitAmountLCYLbl: Label 'Profit Amount (LCY)';
        BalancingProfitPctLbl: Label 'Profit %';
        BalancingDirectLbl: Label 'Direct';
        BalancingDirectTurnoverLCYLbl: Label 'Direct Turnover (LCY)';
        BalancingDirectNetTurnoverLCYLbl: Label 'Direct Net Turnover (LCY)';
        BalancingCreditLbl: Label 'Credit';
        BalancingCreditTurnoverLCYLbl: Label 'Credit Turnover (LCY)';
        BalancingCreditNetTurnoverLCYLbl: Label 'Credit Net Turnover (LCY)';
        BalancingTaxIdentifierLbl: Label 'Tax Identifier';
        BalancingTaxPctLbl: Label 'Tax %';
        BalancingTaxBaseAmountLbl: Label 'Tax Base Amount';
        BalancingTaxAmountLbl: Label 'Tax Amount';
        BalancingAmountIncludingTaxLbl: Label 'Amount Including Tax';
        BalancingPaymentTypeNoLbl: Label 'Payment Type No.';
        BalancingDescriptionLbl: Label 'Description';
        BalancingDifferenceLbl: Label 'Difference';
        BalancingCalculatedAmountInclFloatLbl: Label 'Calculated Amount Incl. Float';
        BalancingCountedAmountInclFloatLbl: Label 'Counted Amount Incl. Float';
        BalancingFloatAmountLbl: Label 'Float Amount';
        BalancingTransferedAmountLbl: Label 'Transfered Amount';
        BalancingNewFloatAmountLbl: Label 'New Float Amount';
        BalancingBankDepositAmountLbl: Label 'Bank Deposit Amount';
        BalancingBankDepositBinCodeLbl: Label 'Bank Deposit Bin Code';
        BalancingBankDepositReferenceLbl: Label 'Bank Deposit Reference';
        BalancingMovetoBinAmountLbl: Label 'Move to Bin Amount';
        BalancingMovetoBinNoLbl: Label 'Move to Bin No.';
        BalancingMovetoBinTransIDLbl: Label 'Move to Bin Trans. ID';
        BalancingTaxSummaryLbl: Label 'Tax Summary';
        BalancingShowAllLbl: Label 'Show All';
        BalancingNotCompletedConfirmationLbl: Label 'You have not reviewed and confirmed the counting. Are you sure you want to complete balancing?';
        BalancingButtonPrintStatisticsLbl: Label 'Print Statistics';
        BalancingButtonCashCountLbl: Label 'Cash Count';
        BalancingButtonCashCountNotCompletedLbl: Label '(not completed)';
        BalancingButtonCompleteLbl: Label 'Close';
        BalancingCashCountCountingLbl: Label 'Counting';
        BalancingCashCountClosingAndTransferLbl: Label 'Closing and Transfer';
        BalancingCashCountBankDepositLbl: Label 'Bank Deposit';
        BalancingCashCountMoveToBinLbl: Label 'Move To Bin';
        BalancingCashCountCoinTypesLbl: Label 'Coin Types';
        BalancingCashCountCountCoinTypesLbl: Label 'Count Coin Types';
        BalancingCashCountTypeLbl: Label 'Type';
        BalancingCashCountDescriptionLbl: Label 'Description';
        BalancingCashCountQuantityLbl: Label 'Quantity';
        BalancingCashCountAmountLbl: Label 'Amount';
        BalancingCashCountTotalLbl: Label 'Total';
        BalancingCountByTypeCompletedLbl: Label 'You have counted by coin type. Entering a value manually will lose counting by coin type data you entered. Are you sure you want to continue?';
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
        GlobalRecordLbl: Label 'Global_Record_%1_Field_%2', Locked = true;
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
        Captions.Add('Sale_SubTotal', StrSubstNo(CaptionLabelSubtotal, GetLCYCode()));
        Captions.Add('Sale_Total', StrSubstNo(CaptionLabelTotal, GetLCYCode()));
        Captions.Add('Sale_VATAmt', StrSubstNo(CaptionLabelVATAmt, GetLCYCode()));
        Captions.Add('Sale_TaxAmt', StrSubstNo(CaptionLabelTaxAmt, GetLCYCode()));
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
        Captions.Add('Balancing_CashMovements', BalancingCashMovementsLbl);
        Captions.Add('Balancing_Balancing', BalancingBalancingLbl);
        Captions.Add('Balancing_CreatedAt', BalancingCreatedAtLbl);
        Captions.Add('Balancing_DirectSalesCount', BalancingDirectSalesCountLbl);
        Captions.Add('Balancing_DirectItemsReturnLine', BalancingDirectItemsReturnLineLbl);
        Captions.Add('Balancing_Overview', BalancingOverviewLbl);
        Captions.Add('Balancing_Sales', BalancingSalesLbl);
        Captions.Add('Balancing_DirectItemSalesLCY', BalancingDirectItemSalesLCYLbl);
        Captions.Add('Balancing_DirectItemReturnsLCY', BalancingDirectItemReturnsLCYLbl);
        Captions.Add('Balancing_LocalCurrencyLCY', BalancingLocalCurrencyLCYLbl);
        Captions.Add('Balancing_ForeignCurrencyLCY', BalancingForeignCurrencyLCYLbl);
        Captions.Add('Balancing_OtherPayments', BalancingOtherPaymentsLbl);
        Captions.Add('Balancing_DebtorPaymentLCY', BalancingDebtorPaymentLCYLbl);
        Captions.Add('Balancing_EFTLCY', BalancingEFTLCYLbl);
        Captions.Add('Balancing_GLPaymentLCY', BalancingGLPaymentLCYLbl);
        Captions.Add('Balancing_Voucher', BalancingVoucherLbl);
        Captions.Add('Balancing_RedeemedVouchersLCY', BalancingRedeemedVouchersLCYLbl);
        Captions.Add('Balancing_IssuedVouchersLCY', BalancingIssuedVouchersLCYLbl);
        Captions.Add('Balancing_Other', BalancingOtherLbl);
        Captions.Add('Balancing_RoundingLCY', BalancingRoundingLCYLbl);
        Captions.Add('Balancing_BinTransferOutAmountLCY', BalancingBinTransferOutAmountLCYLbl);
        Captions.Add('Balancing_BinTransferInAmountLCY', BalancingBinTransferInAmountLCYLbl);
        Captions.Add('Balancing_CreditSales', BalancingCreditSalesLbl);
        Captions.Add('Balancing_CreditSalesCountLCY', BalancingCreditSalesCountLCYLbl);
        Captions.Add('Balancing_CreditSalesAmountLCY', BalancingCreditSalesAmountLCYLbl);
        Captions.Add('Balancing_CreditNetSalesAmountLCY', BalancingCreditNetSalesAmountLCYLbl);
        Captions.Add('Balancing_Details', BalancingDetailsLbl);
        Captions.Add('Balancing_CreditUnrealSaleAmtLCY', BalancingCreditUnrealSaleAmtLCYLbl);
        Captions.Add('Balancing_CreditUnrealRetAmtLCY', BalancingCreditUnrealRetAmtLCYLbl);
        Captions.Add('Balancing_CreditRealSaleAmtLCY', BalancingCreditRealSaleAmtLCYLbl);
        Captions.Add('Balancing_CreditRealReturnAmtLCY', BalancingCreditRealReturnAmtLCYLbl);
        Captions.Add('Balancing_Discount', BalancingDiscountLbl);
        Captions.Add('Balancing_DiscountAmounts', BalancingDiscountAmountsLbl);
        Captions.Add('Balancing_CampaignDiscountLCY', BalancingCampaignDiscountLCYLbl);
        Captions.Add('Balancing_MixDiscountLCY', BalancingMixDiscountLCYLbl);
        Captions.Add('Balancing_QuantityDiscountLCY', BalancingQuantityDiscountLCYLbl);
        Captions.Add('Balancing_CustomDiscountLCY', BalancingCustomDiscountLCYLbl);
        Captions.Add('Balancing_BOMDiscountLCY', BalancingBOMDiscountLCYLbl);
        Captions.Add('Balancing_CustomerDiscountLCY', BalancingCustomerDiscountLCYLbl);
        Captions.Add('Balancing_LineDiscountLCY', BalancingLineDiscountLCYLbl);
        Captions.Add('Balancing_DiscountPercent', BalancingDiscountPercentLbl);
        Captions.Add('Balancing_CampaignDiscountPct', BalancingCampaignDiscountPctLbl);
        Captions.Add('Balancing_MixDiscountPct', BalancingMixDiscountPctLbl);
        Captions.Add('Balancing_QuantityDiscountPct', BalancingQuantityDiscountPctLbl);
        Captions.Add('Balancing_CustomDiscountPct', BalancingCustomDiscountPctLbl);
        Captions.Add('Balancing_BOMDiscountPct', BalancingBOMDiscountPctLbl);
        Captions.Add('Balancing_CustomerDiscountPct', BalancingCustomerDiscountPctLbl);
        Captions.Add('Balancing_LineDiscountPct', BalancingLineDiscountPctLbl);
        Captions.Add('Balancing_DiscountTotal', BalancingDiscountTotalLbl);
        Captions.Add('Balancing_TotalDiscountLCY', BalancingTotalDiscountLCYLbl);
        Captions.Add('Balancing_TotalDiscountPct', BalancingTotalDiscountPctLbl);
        Captions.Add('Balancing_Turnover', BalancingTurnoverLbl);
        Captions.Add('Balancing_TurnoverLCY', BalancingTurnoverLCYLbl);
        Captions.Add('Balancing_NetTurnoverLCY', BalancingNetTurnoverLCYLbl);
        Captions.Add('Balancing_NetCostLCY', BalancingNetCostLCYLbl);
        Captions.Add('Balancing_Profit', BalancingProfitLbl);
        Captions.Add('Balancing_ProfitAmountLCY', BalancingProfitAmountLCYLbl);
        Captions.Add('Balancing_ProfitPct', BalancingProfitPctLbl);
        Captions.Add('Balancing_Direct', BalancingDirectLbl);
        Captions.Add('Balancing_DirectTurnoverLCY', BalancingDirectTurnoverLCYLbl);
        Captions.Add('Balancing_DirectNetTurnoverLCY', BalancingDirectNetTurnoverLCYLbl);
        Captions.Add('Balancing_Credit', BalancingCreditLbl);
        Captions.Add('Balancing_CreditTurnoverLCY', BalancingCreditTurnoverLCYLbl);
        Captions.Add('Balancing_CreditNetTurnoverLCY', BalancingCreditNetTurnoverLCYLbl);
        Captions.Add('Balancing_TaxIdentifier', BalancingTaxIdentifierLbl);
        Captions.Add('Balancing_TaxPct', BalancingTaxPctLbl);
        Captions.Add('Balancing_TaxBaseAmount', BalancingTaxBaseAmountLbl);
        Captions.Add('Balancing_TaxAmount', BalancingTaxAmountLbl);
        Captions.Add('Balancing_AmountIncludingTax', BalancingAmountIncludingTaxLbl);
        Captions.Add('Balancing_PaymentTypeNo', BalancingPaymentTypeNoLbl);
        Captions.Add('Balancing_Description', BalancingDescriptionLbl);
        Captions.Add('Balancing_Difference', BalancingDifferenceLbl);
        Captions.Add('Balancing_CalculatedAmountInclFloat', BalancingCalculatedAmountInclFloatLbl);
        Captions.Add('Balancing_CountedAmountInclFloat', BalancingCountedAmountInclFloatLbl);
        Captions.Add('Balancing_FloatAmount', BalancingFloatAmountLbl);
        Captions.Add('Balancing_TransferedAmount', BalancingTransferedAmountLbl);
        Captions.Add('Balancing_NewFloatAmount', BalancingNewFloatAmountLbl);
        Captions.Add('Balancing_BankDepositAmount', BalancingBankDepositAmountLbl);
        Captions.Add('Balancing_BankDepositBinCode', BalancingBankDepositBinCodeLbl);
        Captions.Add('Balancing_BankDepositReference', BalancingBankDepositReferenceLbl);
        Captions.Add('Balancing_MovetoBinAmount', BalancingMovetoBinAmountLbl);
        Captions.Add('Balancing_MovetoBinNo', BalancingMovetoBinNoLbl);
        Captions.Add('Balancing_MovetoBinTransID', BalancingMovetoBinTransIDLbl);
        Captions.Add('Balancing_TaxSummary', BalancingTaxSummaryLbl);
        Captions.Add('Balancing_ShowAll', BalancingShowAllLbl);
        Captions.Add('Balancing_NotCompletedConfirmation', BalancingNotCompletedConfirmationLbl);
        Captions.Add('Balancing_ButtonPrintStatistics', BalancingButtonPrintStatisticsLbl);
        Captions.Add('Balancing_ButtonCashCount', BalancingButtonCashCountLbl);
        Captions.Add('Balancing_ButtonCashCountNotCompleted', BalancingButtonCashCountNotCompletedLbl);
        Captions.Add('Balancing_ButtonComplete', BalancingButtonCompleteLbl);
        Captions.Add('Balancing_CashCountCounting', BalancingCashCountCountingLbl);
        Captions.Add('Balancing_CashCountClosingAndTransfer', BalancingCashCountClosingAndTransferLbl);
        Captions.Add('Balancing_CashCountBankDeposit', BalancingCashCountBankDepositLbl);
        Captions.Add('Balancing_CashCountMoveToBin', BalancingCashCountMoveToBinLbl);
        Captions.Add('Balancing_CashCountCoinTypes', BalancingCashCountCoinTypesLbl);
        Captions.Add('Balancing_CashCountCountCoinTypes', BalancingCashCountCountCoinTypesLbl);
        Captions.Add('Balancing_CashCountType', BalancingCashCountTypeLbl);
        Captions.Add('Balancing_CashCountDescription', BalancingCashCountDescriptionLbl);
        Captions.Add('Balancing_CashCountQuantity', BalancingCashCountQuantityLbl);
        Captions.Add('Balancing_CashCountAmount', BalancingCashCountAmountLbl);
        Captions.Add('Balancing_CashCountTotal', BalancingCashCountTotalLbl);
        Captions.Add('Balancing_CountByTypeCompletedLbl', BalancingCountByTypeCompletedLbl);
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

        RecRef.Open(DATABASE::"NPR POS Sale Line");
        for i := 1 to RecRef.FieldCount do begin
            FieldRef := RecRef.FieldIndex(i);
            Captions.Add(StrSubstNo(GlobalRecordLbl, RecRef.Number, FieldRef.Number), FieldRef.Caption);
        end;
    end;

    procedure ConfigureReusableWorkflows(POSSession: Codeunit "NPR POS Session"; Setup: Codeunit "NPR POS Setup")
    var
        TempAction: Record "NPR POS Action" temporary;
        POSSetup: Record "NPR POS Setup";
        ConfigureReusableWorkflowLbl: Label '%1, %2', Locked = true;
    begin
        Setup.Action_Item(TempAction, POSSession);
        ConfigureReusableWorkflow(TempAction, POSSession, StrSubstNo(ConfigureReusableWorkflowLbl, POSSetup.TableCaption(), POSSetup.FieldCaption("Item Insert Action Code")), POSSetup.FieldNo("Item Insert Action Code"));

        Setup.Action_Payment(TempAction, POSSession);
        ConfigureReusableWorkflow(TempAction, POSSession, StrSubstNo(ConfigureReusableWorkflowLbl, POSSetup.TableCaption(), POSSetup.FieldCaption("Payment Action Code")), POSSetup.FieldNo("Payment Action Code"));

        Setup.Action_Customer(TempAction, POSSession);
        ConfigureReusableWorkflow(TempAction, POSSession, StrSubstNo(ConfigureReusableWorkflowLbl, POSSetup.TableCaption(), POSSetup.FieldCaption("Customer Action Code")), POSSetup.FieldNo("Customer Action Code"));

        Setup.Action_LockPOS(TempAction, POSSession);
        ConfigureReusableWorkflow(TempAction, POSSession, StrSubstNo(ConfigureReusableWorkflowLbl, POSSetup.TableCaption(), POSSetup.FieldCaption("Lock POS Action Code")), POSSetup.FieldNo("Lock POS Action Code"));

        Setup.Action_UnlockPOS(TempAction, POSSession);
        ConfigureReusableWorkflow(TempAction, POSSession, StrSubstNo(ConfigureReusableWorkflowLbl, POSSetup.TableCaption(), POSSetup.FieldCaption("Unlock POS Action Code")), POSSetup.FieldNo("Unlock POS Action Code"));

        Setup.Action_Login(TempAction, POSSession);
        ConfigureReusableWorkflow(TempAction, POSSession, StrSubstNo(ConfigureReusableWorkflowLbl, POSSetup.TableCaption(), POSSetup.FieldCaption("Login Action Code")), POSSetup.FieldNo("Login Action Code"));

        Setup.Action_TextEnter(TempAction, POSSession);
        ConfigureReusableWorkflow(TempAction, POSSession, StrSubstNo(ConfigureReusableWorkflowLbl, POSSetup.TableCaption(), POSSetup.FieldCaption("Text Enter Action Code")), POSSetup.FieldNo("Text Enter Action Code"));

        Setup.Action_IdleTimeout(TempAction, POSSession);
        ConfigureReusableWorkflow(TempAction, POSSession, StrSubstNo(ConfigureReusableWorkflowLbl, POSSetup.TableCaption(), POSSetup.FieldCaption("Idle Timeout Action Code")), POSSetup.FieldNo("Idle Timeout Action Code"));

        Setup.Action_AdminMenu(TempAction, POSSession);
        ConfigureReusableWorkflow(TempAction, POSSession, StrSubstNo(ConfigureReusableWorkflowLbl, POSSetup.TableCaption(), POSSetup.FieldCaption("Admin Menu Action Code")), POSSetup.FieldNo("Admin Menu Action Code"));

        OnConfigureReusableWorkflows(POSSession, Setup);
    end;

    procedure ConfigureReusableWorkflow("Action": Record "NPR POS Action"; POSSession: Codeunit "NPR POS Session"; Source: Text; FieldNumber: Integer)
    var
        Button: Record "NPR POS Menu Button";
        TempPOSParameterValue: Record "NPR POS Parameter Value" temporary;
        POSUnit: Record "NPR POS Unit";
        WorkflowAction: Codeunit "NPR Workflow Action";
        POSSetup: Codeunit "NPR POS Setup";
    begin
        POSSession.GetSetup(POSSetup);
        POSSetup.GetPOSUnit(POSUnit);

        Button."Action Type" := Button."Action Type"::Action;
        Button."Action Code" := Action.Code;

        RetrieveReusableWorkflowParameters(FieldNumber, POSUnit."POS Named Actions Profile", TempPOSParameterValue);
        WorkflowAction.ConfigureFromMenuButton(Button, POSSession, WorkflowAction);
        TempPOSParameterValue.AddParametersToAction(WorkflowAction);

        FrontEnd.ConfigureReusableWorkflow(WorkflowAction);
    end;

    procedure SetOptions(Setup: Codeunit "NPR POS Setup")
    var
        POSSetup: Record "NPR POS Setup";
        POSViewProfile: Record "NPR POS View Profile";
        POSActionParameterMgt: Codeunit "NPR POS Action Param. Mgt.";
        Options: JsonObject;
    begin
        Options.Add('itemWorkflow', Setup.ActionCode_Item());
        Options.Add('paymentWorkflow', Setup.ActionCode_Payment());
        Options.Add('customerWorkflow', Setup.ActionCode_Customer());
        Options.Add('lockWorkflow', Setup.ActionCode_LockPOS());
        Options.Add('unlockWorkflow', Setup.ActionCode_UnlockPOS());
        Options.Add('autoLockTimeout', Setup.GetLockTimeout());
        Options.Add('loginWorkflow', Setup.ActionCode_Login());
        Options.Add('textEnterWorkflow', Setup.ActionCode_TextEnter());
        Options.Add('kioskUnlockEnabled', Setup.GetKioskUnlockEnabled());
        Options.Add('idleTimeoutWorkflow', Setup.ActionCode_IdleTimeout());
        Options.Add('posUnitType', Format(GetPOSUnitType(Setup), 0, 9));
        Options.Add('adminMenuWorkflow', Setup.ActionCode_AdminMenu());
        Setup.GetNamedActionSetup(POSSetup);
        Options.Add('adminMenuWorkflow_parameters', POSActionParameterMgt.GetParametersAsJson(POSSetup.RecordId, POSSetup.FieldNo("Admin Menu Action Code")));
        Options.Add('nprVersion', GetDisplayVersion());
        Setup.GetPOSViewProfile(POSViewProfile);
        Options.Add('taxationType', Format(POSViewProfile."Tax Type", 0, 9));
        Options.Add('lineOrderOnScreen', POSViewProfile."Line Order on Screen");

        OnSetOptions(Setup, Options);

        FrontEnd.SetOptions(Options);
    end;

    local procedure GetDisplayVersion(): Text
    var
        versionNumber: Text;
        LicenseInformation: Codeunit "NPR License Information";
    begin
        versionNumber := LicenseInformation.GetRetailVersion();
        OnGetDisplayVersion(versionNumber);
        exit(versionNumber);
    end;

    [InternalEvent(false)]
    local procedure OnGetDisplayVersion(var displayVersion: Text)
    begin
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
        GeneralLedgerSetupLCYLbl: Label '(%1)', Locked = true;
    begin
        if (GeneralLedgerSetup.Get()) then
            if (GeneralLedgerSetup."LCY Code" <> '') then
                exit(StrSubstNo(GeneralLedgerSetupLCYLbl, GeneralLedgerSetup."LCY Code"));

        exit('');
    end;

    local procedure PreloadParameters(var tmpPOSParameterValue: Record "NPR POS Parameter Value" temporary)
    var
        POSParameterValue: Record "NPR POS Parameter Value";
    begin
        POSParameterValue.SetRange("Table No.", DATABASE::"NPR POS Menu Button");
        if POSParameterValue.FindSet() then
            repeat
                tmpPOSParameterValue := POSParameterValue;
                tmpPOSParameterValue.Insert();
            until POSParameterValue.Next() = 0;
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
        if POSParameterValue.FindSet() then
            repeat
                TmpPOSParameterValue := POSParameterValue;
                TmpPOSParameterValue.Insert();
            until POSParameterValue.Next() = 0;
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
