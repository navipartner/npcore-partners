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
        ItemIdentifierType();
        ItemPriceIdentifierType();
        ItemLookupSmartSearch();
        CustomerNo();
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
    begin
        POSActionParameter.SetRange("Table No.", Database::"NPR POS Menu Button");
        POSActionParameter.SetRange("Action Code", 'ITEM');
        POSActionParameter.SetRange(Name, 'itemIdentifyerType');
        if POSActionParameter.FindSet() then
            repeat
                POSActionParameter.Rename(POSActionParameter."Table No.", POSActionParameter.Code, POSActionParameter.ID, POSActionParameter."Record ID", 'itemIdentifierType');
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
                POSActionParameter.Rename(POSActionParameter."Table No.", POSActionParameter.Code, POSActionParameter.ID, POSActionParameter."Record ID", 'itemIdentifierType');
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

    local procedure CurrCodeunitId(): Integer
    begin
        exit(Codeunit::"NPR UPG POS Action Parameters");
    end;
}