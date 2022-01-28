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

    local procedure CurrCodeunitId(): Integer
    begin
        exit(Codeunit::"NPR UPG POS Action Parameters");
    end;
}