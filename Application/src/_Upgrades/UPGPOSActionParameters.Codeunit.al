codeunit 6059777 "NPR UPG POS Action Parameters"
{
    Access = Internal;
    Subtype = Upgrade;

    var
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagsDef: Codeunit "NPR Upgrade Tag Definitions";

    trigger OnUpgradePerCompany()
    begin
        SalesDocExpPaymentMethodCode();
        SalesDocExpRefreshMenuButtonActions();
        SalesDocImpRefreshMenuButtonActions();
        TakePhotoRefreshMenuButtonActions();
        ItemIdentifierType();
        RefreshReverseDirectSalePOSAction();
        ItemPriceIdentifierType();
        ItemLookupSmartSearch();
        CustomerNo();
        CustomerNoParam();
        POSWorkflow();
        SecurityParameter();
        UpgradePOSNamedActionsProfileItemActionParameters();
    end;

    local procedure SalesDocExpPaymentMethodCode()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG POS Action Parameters', 'SalesDocExpPaymentMethodCode');

        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'SalesDocExpPaymentMethodCode')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        UpgradeSalesDocExpPaymentMethodCode();

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'SalesDocExpPaymentMethodCode'));
        LogMessageStopwatch.LogFinish();
    end;

    /// <summary>
    /// This method will upgrade the POS Action parameters to ensure that if
    /// the configuration previously contained a specific payment method code
    /// the behaviour of the button will not change.
    ///
    /// Otherwise it will have the default value of "Sales Header Default" which
    /// was the default before the `PaymentMethodCode` parameter was
    /// added.
    /// </summary>
    local procedure UpgradeSalesDocExpPaymentMethodCode()
    var
        POSActionParameter: Record "NPR POS Parameter Value";
        POSActionParameter2: Record "NPR POS Parameter Value";
        POSMenuButton: Record "NPR POS Menu Button";
    begin
        POSActionParameter.SetRange("Table No.", Database::"NPR POS Menu Button");
        POSActionParameter.SetRange(Name, 'PaymentMethodCode');
        POSActionParameter.SetFilter(Value, '<>%1', '');
        if POSActionParameter.IsEmpty then
            exit;

        POSActionParameter.FindSet();
        repeat
            // We do a check here to ensure that any action parameters with out button does not cause the upgrade code to throw an error.
            if POSMenuButton.Get(POSActionParameter.Code, POSActionParameter.ID) then begin
                // Ensure we have the added parameter
                POSMenuButton.RefreshParameters();

                // Update option setting to ensure that we select the Payment Method Code specified
                if POSActionParameter2.Get(POSActionParameter."Table No.", POSActionParameter.Code, POSActionParameter.ID, POSActionParameter."Record ID", 'PaymentMethodCodeFrom') then begin
                    POSActionParameter2.Value := 'Specific Payment Method Code';
                    POSActionParameter2.Modify();
                end;
            end;
        until POSActionParameter.Next() = 0;
    end;

    local procedure ItemIdentifierType()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG POS Action Parameters', 'ItemIdentifierType');

        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'ItemIdentifierType')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        UpgradeItemIdentifierType();

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'ItemIdentifierType'));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpgradeItemIdentifierType()
    var
        POSActionParameter: Record "NPR POS Parameter Value";
        POSActionParameter2: Record "NPR POS Parameter Value";
    begin
        POSActionParameter.SetRange("Table No.", Database::"NPR POS Menu Button");
        POSActionParameter.SetRange("Action Code", 'ITEM');
        POSActionParameter.SetRange(Name, 'itemIdentifyerType');
        if POSActionParameter.FindSet() then
            repeat
                if not POSActionParameter2.Get(POSActionParameter."Table No.", POSActionParameter.Code, POSActionParameter.ID, POSActionParameter."Record ID", 'itemIdentifierType') then begin
                    POSActionParameter2.Init();
                    POSActionParameter2 := POSActionParameter;
                    POSActionParameter2.Name := 'itemIdentifierType';
                    POSActionParameter2.Insert();
                    POSActionParameter.Delete();
                end;
            until POSActionParameter.Next() = 0;
    end;

    local procedure ItemPriceIdentifierType()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG POS Action Parameters', 'ItemPriceIdentifierType');

        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'ItemPriceIdentifierType')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        UpgradeItemPriceIdentifierType();

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'ItemPriceIdentifierType'));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure CustomerNo()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG POS Action Parameters', 'CustomerNo');

        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'CustomerNo')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        UpgradeCustomerNo();

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'CustomerNo'));
        LogMessageStopwatch.LogFinish();

    end;

    local procedure CustomerNoParam()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG POS Action Parameters', 'CustomerNoParam');

        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'CustomerNoParam')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        UpgradeCustomerNoParam();

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'CustomerNoParam'));
        LogMessageStopwatch.LogFinish();

    end;

    local procedure POSWorkflow()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG POS Action Parameters', 'POSWorkflow');

        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'POSWorkflow')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        UpgradePOSWorkflow();

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'POSWorkflow'));
        LogMessageStopwatch.LogFinish();

    end;

    local procedure ItemLookupSmartSearch()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG POS Action Parameters', 'ItemLookupSmartSearch');

        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'ItemLookupSmartSearch')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        UpgradeItemLookupSmartSearch();

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'ItemLookupSmartSearch'));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpgradeItemLookupSmartSearch()
    var
        POSActionParameter: Record "NPR POS Parameter Value";
    begin
        POSActionParameter.SetRange("Table No.", Database::"NPR POS Menu Button");
        POSActionParameter.SetRange("Action Code", 'LOOKUP');
        POSActionParameter.SetRange(Name, 'SmartSearchPage');
        POSActionParameter.DeleteAll();
    end;

    local procedure UpgradeItemPriceIdentifierType()
    var
        POSActionParameter: Record "NPR POS Parameter Value";
    begin
        POSActionParameter.SetRange("Table No.", Database::"NPR POS Menu Button");
        POSActionParameter.SetRange("Action Code", 'ITEM_PRICE');
        POSActionParameter.SetRange(Name, 'itemIdentifyerType');
        if POSActionParameter.FindSet() then
            repeat
                If not POSActionParameter.Get(POSActionParameter."Table No.", POSActionParameter.Code, POSActionParameter.ID, POSActionParameter."Record ID", 'itemIdentifierType') then
                    POSActionParameter.Rename(POSActionParameter."Table No.", POSActionParameter.Code, POSActionParameter.ID, POSActionParameter."Record ID", 'itemIdentifierType');
            until POSActionParameter.Next() = 0;
    end;

    local procedure UpgradeCustomerNoParam()
    var
        POSActionParameter: Record "NPR POS Parameter Value";
    begin
        POSActionParameter.SetRange("Table No.", Database::"NPR POS Menu Button");
        POSActionParameter.SetRange("Action Code", 'CUSTOMER_SELECT');
        POSActionParameter.SetRange(Name, 'customerNo');
        if POSActionParameter.FindSet() then
            repeat
                POSActionParameter.Rename(POSActionParameter."Table No.", POSActionParameter.Code, POSActionParameter.ID, POSActionParameter."Record ID", 'CustomerNo');
            until POSActionParameter.Next() = 0;
    end;

    local procedure UpgradeCustomerNo()
    var
        EanBoxParameter: Record "NPR Ean Box Parameter";
    begin
        EanBoxParameter.SetRange("Event Code", 'CUSTOMERNO');
        EanBoxParameter.SetRange("Action Code", 'CUSTOMER_SELECT');
        EanBoxParameter.SetRange(Name, 'customerNo');
        if EanBoxParameter.FindSet() then
            repeat
                EanBoxParameter.Rename(EanBoxParameter."Setup Code", EanBoxParameter."Event Code", EanBoxParameter."Action Code", 'CustomerNo');
            until EanBoxParameter.Next() = 0;
    end;

    local procedure SalesDocExpRefreshMenuButtonActions()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG POS Action Parameters', 'SalesDocExpRefreshMenuButtonActions');

        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'SalesDocExpRefreshMenuButtonActions')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        RefreshPOSAction(Enum::"NPR POS Workflow"::SALES_DOC_EXP);

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'SalesDocExpRefreshMenuButtonActions'));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure TakePhotoRefreshMenuButtonActions()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG POS Action Parameters', 'TakePhotoRefreshMenuButtonActions');

        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'TakePhotoRefreshMenuButtonActions')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        RefreshPOSAction(Enum::"NPR POS Workflow"::QUANTITY);
        RefreshPOSAction(Enum::"NPR POS Workflow"::PAYMENT_PAYIN_PAYOUT);
        RefreshPOSAction(Enum::"NPR POS Workflow"::REVERSE_DIRECT_SALE);
        RefreshPOSAction(Enum::"NPR POS Workflow"::REVERSE_CREDIT_SALE);

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'TakePhotoRefreshMenuButtonActions'));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure SalesDocImpRefreshMenuButtonActions()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG POS Action Parameters', 'SalesDocImpRefreshMenuButtonActions');

        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'SalesDocImpRefreshMenuButtonActions')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        RefreshPOSAction(Enum::"NPR POS Workflow"::SALES_DOC_IMP);

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'SalesDocImpRefreshMenuButtonActions'));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure RefreshPOSAction(NPRPOSWorkflow: Enum "NPR POS Workflow")
    var
        NPRPOSAction: Record "NPR POS Action";
    begin
        NPRPOSAction.Reset();
        NPRPOSAction.SetRange(Blocked, false);
        NPRPOSAction.SetRange("Workflow Implementation", NPRPOSWorkflow);
        NPRPOSAction.SetLoadFields(Code);
        if not NPRPOSAction.FindSet(false) then
            exit;
        repeat
            RefreshMenuButtonParameters(NPRPOSAction)
        until NPRPOSAction.Next() = 0;
    end;

    #region RefreshMenuButtonParameters
    local procedure RefreshMenuButtonParameters(NPRPOSAction: Record "NPR POS Action")
    var
        NPRPOSMenuButton: Record "NPR POS Menu Button";
    begin
        NPRPOSMenuButton.Reset();
        NPRPOSMenuButton.SetRange("Action Type", NPRPOSMenuButton."Action Type"::Action);
        NPRPOSMenuButton.SetRange("Action Code", NPRPOSAction.Code);
        if not NPRPOSMenuButton.FindSet(true) then
            exit;

        repeat
            if NPRPOSMenuButton.RefreshParametersRequired() then
                NPRPOSMenuButton.RefreshParameters();
        until NPRPOSMenuButton.next() = 0;
    end;
    #endregion RefreshMenuButtonParameters

    local procedure UpgradePOSWorkflow()
    var
        EanBoxParameter: Record "NPR Ean Box Parameter";
    begin
        EanBoxParameter.SetRange("Event Code", 'MEMBER_ARRIVAL');
        EanBoxParameter.SetRange("Action Code", 'MM_MEMBER_ARRIVAL');
        EanBoxParameter.SetRange(Name, 'POSWorkflow');
        EanBoxParameter.SetRange(OptionValueInteger, -1);
        if EanBoxParameter.FindSet() then
            repeat
                case EanBoxParameter.Value of
                    'POSSales':
                        begin
                            EanBoxParameter.OptionValueInteger := 0;
                        end;
                    'Automatic':
                        begin
                            EanBoxParameter.OptionValueInteger := 1;
                        end;
                    'With Guests':
                        begin
                            EanBoxParameter.OptionValueInteger := 2;
                        end;
                end;
                EanBoxParameter.Modify();
            until EanBoxParameter.Next() = 0;
    end;

    local procedure SecurityParameter()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG POS Action Parameters', 'SecurityParameter');

        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'SecurityParameter')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;
        UpdateSecureMethods();
        RemoveSecurityParameterFromButtons();

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'SecurityParameter'));
        LogMessageStopwatch.LogFinish();

    end;

    local procedure UpdateSecureMethods()
    var
        POSActionParameter: Record "NPR POS Parameter Value";
        POSMenuButton: Record "NPR POS Menu Button";
    begin
        POSActionParameter.SetRange("Table No.", Database::"NPR POS Menu Button");
        POSActionParameter.SetFilter("Action Code", '%1|%2|%3', 'CANCEL_POS_SALE', 'ITEMCARD', 'DISCOUNT');
        POSActionParameter.SetRange(Name, 'Security');
        POSActionParameter.SetFilter(Value, '<>%1', 'None');
        if POSActionParameter.FindSet() then
            repeat
                if POSMenuButton.Get(POSActionParameter.Code, POSActionParameter.ID) then begin
                    case true of
                        POSActionParameter.Value = 'SalespersonPassword':
                            POSMenuButton.Validate("Secure Method Code", 'ANY-SALESP');
                        POSActionParameter.Value = 'CurrentSalespersonPassword':
                            POSMenuButton.Validate("Secure Method Code", 'CUR-SALESP');
                        POSActionParameter.Value = 'SupervisorPassword':
                            POSMenuButton.Validate("Secure Method Code", 'SUPERVISOR');
                    end;
                    POSActionParameter.Value := 'None';
                    POSActionParameter.Modify();
                    POSMenuButton.Modify();
                end;
            until POSActionParameter.Next() = 0;
    end;

    local procedure RemoveSecurityParameterFromButtons()
    var
        POSActionParameter: Record "NPR POS Parameter Value";
    begin
        POSActionParameter.SetCurrentKey("Action Code");
        POSActionParameter.SetRange("Table No.", Database::"NPR POS Menu Button");
        POSActionParameter.SetFilter("Action Code", '%1|%2|%3', 'CANCEL_POS_SALE', 'ITEMCARD', 'DISCOUNT');
        POSActionParameter.SetRange(Name, 'Security');
        POSActionParameter.DeleteAll();

        RefreshPOSAction(Enum::"NPR POS Workflow"::CANCEL_POS_SALE);
        RefreshPOSAction(Enum::"NPR POS Workflow"::ITEMCARD);
        RefreshPOSAction(Enum::"NPR POS Workflow"::DISCOUNT);
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(Codeunit::"NPR UPG POS Action Parameters");
    end;

    local procedure RefreshReverseDirectSalePOSAction()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG POS Action Parameters', 'RefreshReverseDirectSalePOSAction');
        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'RefreshReverseDirectSalePOSAction')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;
        RefreshPOSAction(Enum::"NPR POS Workflow"::REVERSE_DIRECT_SALE);
        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'RefreshReverseDirectSalePOSAction'));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpgradePOSNamedActionsProfileItemActionParameters()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG POS Action Parameters', 'UpgradePOSNamedActionsProfileItemActionParameters');

        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'UpgradePOSNamedActionsProfileItemActionParameters')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        RefreshPOSItemNamedActionSetup();

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'UpgradePOSNamedActionsProfileItemActionParameters'));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure RefreshPOSItemNamedActionSetup()
    var
        ItemInsertActionRefreshNeeded: Boolean;
        ParamMgt: Codeunit "NPR POS Action Param. Mgt.";
        POSSetup: Record "NPR POS Setup";
    begin

        POSSetup.Reset();
        if not POSSetup.FindSet(false) then
            exit;
        repeat
            ItemInsertActionRefreshNeeded := ParamMgt.RefreshParametersRequired(POSSetup.RecordId, '', POSSetup.FieldNo("Item Insert Action Code"), POSSetup."Item Insert Action Code");
            if ItemInsertActionRefreshNeeded then
                ParamMgt.RefreshParameters(POSSetup.RecordId, '', POSSetup.FieldNo("Item Insert Action Code"), POSSetup."Item Insert Action Code");
        until POSSetup.Next() = 0;
    end;
}
