codeunit 6150649 "NPR POS Action Tax Free B."
{
    Access = Internal;

    procedure OnActionTaxFree(SettingParam: Integer; POSSale: Codeunit "NPR POS Sale"; POSSetup: Codeunit "NPR POS Setup")
    var
        POSUnit: Record "NPR POS Unit";
        TaxFreeProfile: Record "NPR POS Tax Free Profile";
        TaxFreeVoucher: Record "NPR Tax Free Voucher";
        TaxFreeInterface: Codeunit "NPR Tax Free Handler Mgt.";
        Setting: Option "Sale Toggle","Voucher List","Unit List","Print Last",Consolidate;
    begin
        POSSetup.GetPOSUnit(POSUnit);
        TaxFreeProfile.Get(POSUnit."POS Tax Free Prof.");

        case SettingParam of
            Setting::"Sale Toggle":
                ToggleTaxFree(POSSale);
            Setting::"Voucher List":
                Page.RunModal(0, TaxFreeVoucher);
            Setting::"Unit List":
                Page.RunModal(0, TaxFreeProfile);
            Setting::"Print Last":
                TaxFreeInterface.VoucherPrintLast();
            Setting::Consolidate:
                Consolidate(TaxFreeProfile);
        end;
    end;

    local procedure ToggleTaxFree(POSSale: Codeunit "NPR POS Sale")
    var
        SalePOS: Record "NPR POS Sale";
    begin
        POSSale.GetCurrentSale(SalePOS);

        SalePOS."Issue Tax Free Voucher" := not SalePOS."Issue Tax Free Voucher";
        POSSale.Refresh(SalePOS);
        POSSale.Modify(true, false);
    end;

    local procedure Consolidate(var TaxFreeProfile: Record "NPR POS Tax Free Profile")
    var
        TaxFreeConsolidation: Page "NPR Tax Free Consolidation";
    begin
        TaxFreeConsolidation.SetTaxFreeUnit(TaxFreeProfile);
        TaxFreeConsolidation.RunModal();
    end;

    local procedure ThisExtension(): Text
    begin

        exit('TAX_FREE');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnDiscoverDataSourceExtensions', '', false, false)]
    local procedure OnDiscoverDataSourceExtensions(DataSourceName: Text; Extensions: List of [Text])
    var
        TaxFreeProfile: Record "NPR POS Tax Free Profile";
        POSDataMgt: Codeunit "NPR POS Data Management";
    begin
        if POSDataMgt.POSDataSource_BuiltInSale() <> DataSourceName then
            exit;

        if TaxFreeProfile.IsEmpty then //Only activate data extension in companies using tax free.
            exit;

        Extensions.Add(ThisExtension());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnGetDataSourceExtension', '', false, false)]
    local procedure OnGetDataSourceExtension(DataSourceName: Text; ExtensionName: Text; var DataSource: Codeunit "NPR Data Source"; var Handled: Boolean; Setup: Codeunit "NPR POS Setup")
    var
        POSDataMgt: Codeunit "NPR POS Data Management";
        DataType: Enum "NPR Data Type";
    begin
        if (DataSourceName <> POSDataMgt.POSDataSource_BuiltInSale()) or (ExtensionName <> ThisExtension()) then
            exit;

        DataSource.AddColumn('Status', 'Tax Free Enabled', DataType::String, false);

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnDataSourceExtensionReadData', '', false, false)]
    local procedure OnDataSourceExtensionReadData(DataSourceName: Text; ExtensionName: Text; var RecRef: RecordRef; DataRow: Codeunit "NPR Data Row"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        SalePOS: Record "NPR POS Sale";
        POSDataMgt: Codeunit "NPR POS Data Management";
        POSSale: Codeunit "NPR POS Sale";
        Caption_Disabled: Label 'Disabled';
        Caption_Enabled: Label 'Enabled';
    begin

        if (DataSourceName <> POSDataMgt.POSDataSource_BuiltInSale()) or (ExtensionName <> ThisExtension()) then
            exit;

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        if SalePOS."Issue Tax Free Voucher" then
            DataRow.Add('Status', Caption_Enabled)
        else
            DataRow.Add('Status', Caption_Disabled);

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale", 'OnAttemptEndSale', '', false, false)]
    local procedure OnAttemptEndSale(var Sender: Codeunit "NPR POS Sale"; SalePOS: Record "NPR POS Sale")
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        TaxFreeProfile: Record "NPR POS Tax Free Profile";
        TaxFreeMgt: Codeunit "NPR Tax Free Handler Mgt.";
        Valid: Boolean;
        Caption_IssueTaxFreeVoucher: Label 'Foreign credit card detected. Should a tax free voucher be issued for this sale?';
        POSUnit: Record "NPR POS Unit";
    begin
        if SalePOS."Issue Tax Free Voucher" then //Already enabled
            exit;

        POSUnit.Get(SalePOS."Register No.");
        if not TaxFreeProfile.Get(POSUnit."POS Tax Free Prof.") then
            exit;

        if not TaxFreeProfile."Check POS Terminal IIN" then
            exit;

        EFTTransactionRequest.SetCurrentKey("Sales Ticket No.");
        EFTTransactionRequest.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        EFTTransactionRequest.SetRange(Successful, true);
        EFTTransactionRequest.SetRange("Processing Type", EFTTransactionRequest."Processing Type"::PAYMENT);
        if EFTTransactionRequest.FindSet() then
            repeat
                Valid := TaxFreeMgt.IsValidTerminalIIN(TaxFreeProfile, PadStr(CopyStr(EFTTransactionRequest."Card Number", 1, 6), StrLen(EFTTransactionRequest."Card Number"), 'X'));
            until (EFTTransactionRequest.Next() = 0) or Valid;

        if not Valid then
            exit;

        if not TaxFreeMgt.IsActiveSaleEligible(TaxFreeProfile, SalePOS."Sales Ticket No.") then
            exit;

        if Confirm(Caption_IssueTaxFreeVoucher) then begin
            SalePOS."Issue Tax Free Voucher" := true;
            Sender.Refresh(SalePOS);
            Sender.Modify(true, false);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Action: Rev.Dir.Sale B", 'OnBeforeReverseSalesTicket', '', false, false)]
    local procedure OnBeforeReverseSalesTicket(SalesTicketNo: Code[20])
    var
        TaxFreeVoucher: Record "NPR Tax Free Voucher";
        TaxFreeMgt: Codeunit "NPR Tax Free Handler Mgt.";
        Caption_ReverseVoucher: Label 'Sales ticket %1 is linked to an active tax free voucher.\Proceed with void of voucher? "No" will cancel the reverse attempt';
        Caption_VoidCritical: Label 'WARNING: The tax free voucher linked to sales ticket %1 could not be voided!\Do you want to proceed with sales ticket reverse?';
        Error_CancelReverse: Label 'An active tax free voucher is linked to sales ticket %1. It must be voided if you are reversing the sales ticket!';
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