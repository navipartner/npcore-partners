codeunit 6150794 "NPR POS Action: Tax Free"
{
    var
        ActionDescription: Label 'This is a built-in action for toggling tax free before completing sale';
        Caption_Enabled: Label 'Enabled';
        Caption_Disabled: Label 'Disabled';
        Caption_IssueTaxFreeVoucher: Label 'Foreign credit card detected. Should a tax free voucher be issued for this sale?';
        Caption_ReverseVoucher: Label 'Sales ticket %1 is linked to an active tax free voucher.\Proceed with void of voucher? "No" will cancel the reverse attempt';
        Caption_VoidCritical: Label 'WARNING: The tax free voucher linked to sales ticket %1 could not be voided!\Do you want to proceed with sales ticket reverse?';
        Error_CancelReverse: Label 'An active tax free voucher is linked to sales ticket %1. It must be voided if you are reversing the sales ticket!';
        ReadingErr: Label 'reading in %1';

    local procedure ActionCode(): Text
    begin
        exit('TAX_FREE');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.2');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        with Sender do
            if DiscoverAction(
              ActionCode,
              ActionDescription,
              ActionVersion,
              Type::Generic,
              "Subscriber Instances Allowed"::Multiple)
            then begin
                RegisterWorkflowStep('1', 'respond();');
                RegisterOptionParameter('Operation', 'Sale Toggle,Voucher List,Unit List,Print Last,Consolidate', 'Sale Toggle');
                RegisterWorkflow(false);

                RegisterDataSourceBinding('BUILTIN_SALE');
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
        Setting: Option "Sale Toggle","Voucher List","Unit List","Print Last",Consolidate;
        TaxFreeInterface: Codeunit "NPR Tax Free Handler Mgt.";
        POSUnit: Record "NPR POS Unit";
        POSSetup: Codeunit "NPR POS Setup";
        TaxFreeUnit: Record "NPR Tax Free POS Unit";
        TaxFreeVoucher: Record "NPR Tax Free Voucher";
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        JSON.SetScopeParameters(ActionCode());
        Setting := JSON.GetIntegerOrFail('Operation', StrSubstNo(ReadingErr, ActionCode()));

        POSSession.GetSetup(POSSetup);
        POSSetup.GetPOSUnit(POSUnit);
        TaxFreeUnit.Get(POSUnit."No.");

        case Setting of
            Setting::"Sale Toggle":
                ToggleTaxFree(POSSession);
            Setting::"Voucher List":
                PAGE.RunModal(0, TaxFreeVoucher);
            Setting::"Unit List":
                PAGE.RunModal(0, TaxFreeUnit);
            Setting::"Print Last":
                TaxFreeInterface.VoucherPrintLast();
            Setting::Consolidate:
                Consolidate(TaxFreeUnit);
        end;

        Handled := true;
    end;

    local procedure ToggleTaxFree(POSSession: Codeunit "NPR POS Session")
    var
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        SalePOS."Issue Tax Free Voucher" := not SalePOS."Issue Tax Free Voucher";
        POSSale.Refresh(SalePOS);
        POSSale.Modify(true, false);

        POSSession.RequestRefreshData(); //For the data extension.
    end;

    local procedure Consolidate(var TaxFreeUnit: Record "NPR Tax Free POS Unit")
    var
        TaxFreeConsolidation: Page "NPR Tax Free Consolidation";
    begin
        TaxFreeConsolidation.SetTaxFreeUnit(TaxFreeUnit);
        TaxFreeConsolidation.RunModal();
    end;

    local procedure "--- DataSource Extension"()
    begin
    end;

    local procedure ThisDataSource(): Text
    begin

        exit('BUILTIN_SALE');
    end;

    local procedure ThisExtension(): Text
    begin

        exit('TAX_FREE');
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150710, 'OnDiscoverDataSourceExtensions', '', false, false)]
    local procedure OnDiscoverDataSourceExtensions(DataSourceName: Text; Extensions: List of [Text])
    var
        TaxFreeUnit: Record "NPR Tax Free POS Unit";
    begin
        if ThisDataSource <> DataSourceName then
            exit;

        if TaxFreeUnit.IsEmpty then //Only activate data extension in companies using tax free.
            exit;

        Extensions.Add(ThisExtension);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150710, 'OnGetDataSourceExtension', '', false, false)]
    local procedure OnGetDataSourceExtension(DataSourceName: Text; ExtensionName: Text; var DataSource: Codeunit "NPR Data Source"; var Handled: Boolean; Setup: Codeunit "NPR POS Setup")
    var
        DataType: Enum "NPR Data Type";
    begin
        if (DataSourceName <> ThisDataSource) or (ExtensionName <> ThisExtension) then
            exit;

        DataSource.AddColumn('Status', 'Tax Free Enabled', DataType::String, false);

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150710, 'OnDataSourceExtensionReadData', '', false, false)]
    local procedure OnDataSourceExtensionReadData(DataSourceName: Text; ExtensionName: Text; var RecRef: RecordRef; DataRow: Codeunit "NPR Data Row"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        DataType: Enum "NPR Data Type";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
    begin

        if (DataSourceName <> ThisDataSource) or (ExtensionName <> ThisExtension) then
            exit;

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        if SalePOS."Issue Tax Free Voucher" then
            DataRow.Add('Status', Caption_Enabled)
        else
            DataRow.Add('Status', Caption_Disabled);

        Handled := true;
    end;

    local procedure "--- Subscribers"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150705, 'OnAttemptEndSale', '', false, false)]
    local procedure OnAttemptEndSale(var Sender: Codeunit "NPR POS Sale"; SalePOS: Record "NPR POS Sale")
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        TaxFreeUnit: Record "NPR Tax Free POS Unit";
        TaxFreeMgt: Codeunit "NPR Tax Free Handler Mgt.";
        Valid: Boolean;
        POSSession: Codeunit "NPR POS Session";
        POSFrontEndManagement: Codeunit "NPR POS Front End Management";
    begin
        if SalePOS."Issue Tax Free Voucher" then //Already enabled
            exit;

        if not TaxFreeUnit.Get(SalePOS."Register No.") then
            exit;

        if not TaxFreeUnit."Check POS Terminal IIN" then
            exit;

        EFTTransactionRequest.SetCurrentKey("Sales Ticket No.");
        EFTTransactionRequest.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        EFTTransactionRequest.SetRange(Successful, true);
        EFTTransactionRequest.SetRange("Processing Type", EFTTransactionRequest."Processing Type"::PAYMENT);
        if EFTTransactionRequest.FindSet then
            repeat
                Valid := TaxFreeMgt.IsValidTerminalIIN(TaxFreeUnit, PadStr(CopyStr(EFTTransactionRequest."Card Number", 1, 6), StrLen(EFTTransactionRequest."Card Number"), 'X'));
            until (EFTTransactionRequest.Next = 0) or Valid;

        if not Valid then
            exit;

        if not TaxFreeMgt.IsActiveSaleEligible(TaxFreeUnit, SalePOS."Sales Ticket No.") then
            exit;

        if Confirm(Caption_IssueTaxFreeVoucher) then begin
            SalePOS."Issue Tax Free Voucher" := true;
            Sender.Refresh(SalePOS);
            Sender.Modify(true, false);

            if POSSession.IsActiveSession(POSFrontEndManagement) then begin
                POSFrontEndManagement.GetSession(POSSession);
                POSSession.RequestRefreshData(); //For the data extension
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150798, 'OnBeforeReverseSalesTicket', '', false, false)]
    local procedure OnBeforeReverseSalesTicket(SalesTicketNo: Code[20])
    var
        TaxFreeMgt: Codeunit "NPR Tax Free Handler Mgt.";
        TaxFreeVoucher: Record "NPR Tax Free Voucher";
    begin
        if not TaxFreeMgt.TryGetActiveVoucherFromReceiptNo(SalesTicketNo, TaxFreeVoucher) then
            exit;

        if not Confirm(Caption_ReverseVoucher, false, SalesTicketNo) then
            Error(Error_CancelReverse, SalesTicketNo);

        TaxFreeMgt.VoucherVoid(TaxFreeVoucher);
        if not TaxFreeVoucher.Void then
            if not Confirm(Caption_VoidCritical, false, SalesTicketNo) then
                Error(Error_CancelReverse);
    end;
}
