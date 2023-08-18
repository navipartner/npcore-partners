﻿codeunit 6014434 "NPR Tax Free Execute"
{
    Access = Internal;
    trigger OnRun()
    begin

        ClearLastError();

        OnRunHandled := true;

        case OnRunFunction of
            OnRunFunction::UnitAutoConfigure:
                TaxFreeHandlerInterface.OnUnitAutoConfigure(OnRunTaxFreeRequest, OnRunSilent);
            OnRunFunction::UnitTestConnection:
                TaxFreeHandlerInterface.OnUnitTestConnection(OnRunTaxFreeRequest);
            OnRunFunction::VoucherIssueFromPOSSale:
                TaxFreeHandlerInterface.OnVoucherIssueFromPOSSale(OnRunTaxFreeRequest, OnRunSalesReceiptNo, OnRunSkipRecordHandling);
            OnRunFunction::VoucherVoid:
                TaxFreeHandlerInterface.OnVoucherVoid(OnRunTaxFreeRequest, OnRunTaxFreeVoucher);
            OnRunFunction::VoucherReissue:
                TaxFreeHandlerInterface.OnVoucherReissue(OnRunTaxFreeRequest, OnRunTaxFreeVoucher);
            OnRunFunction::VoucherLookup:
                TaxFreeHandlerInterface.OnVoucherLookup(OnRunTaxFreeRequest, OnRunVoucherNo);
            OnRunFunction::VoucherPrint:
                TaxFreeHandlerInterface.OnVoucherPrint(OnRunTaxFreeRequest, OnRunTaxFreeVoucher, OnRunIsRecentVoucher);
            OnRunFunction::VoucherConsolidate:
                TaxFreeHandlerInterface.OnVoucherConsolidate(OnRunTaxFreeRequest, TempOnRunTaxFreeConsolidation);
            OnRunFunction::IsValidTerminalIIN:
                TaxFreeHandlerInterface.OnIsValidTerminalIIN(OnRunTaxFreeRequest, OnRunMaskedCardNo, OnRunIsForeignIIN);
            OnRunFunction::IsStoredSaleEligible:
                TaxFreeHandlerInterface.OnIsStoredSaleEligible(OnRunTaxFreeRequest, OnRunSalesReceiptNo, OnRunEligible);
            OnRunFunction::IsActiveSaleEligible:
                TaxFreeHandlerInterface.OnIsActiveSaleEligible(OnRunTaxFreeRequest, OnRunSalesReceiptNo, OnRunEligible);
            else begin
                OnRunHandled := false;
                exit;
            end;
        end;
        Commit();
    end;

    var
        OnRunTaxFreeRequest: Record "NPR Tax Free Request";
        OnRunTaxFreeVoucher: Record "NPR Tax Free Voucher";
        TempOnRunTaxFreeConsolidation: Record "NPR Tax Free Consolidation" temporary;
        TaxFreeHandlerInterface: Interface "NPR Tax Free Handler IF";
        OnRunFunction: Enum "NPR Tax Free OnRunFunction";
        OnRunSalesReceiptNo: Code[20];
        OnRunVoucherNo: Text;
        OnRunMaskedCardNo: Text;
        OnRunHandled: Boolean;
        OnRunSilent: Boolean;
        OnRunSkipRecordHandling: Boolean;
        OnRunIsForeignIIN: Boolean;
        OnRunIsRecentVoucher: Boolean;
        OnRunEligible: Boolean;

    procedure TaxFreeHandlerInterfaceSet(TaxFreeHandlerInterfacePar: Interface "NPR Tax Free Handler IF")
    begin
        TaxFreeHandlerInterface := TaxFreeHandlerInterfacePar
    end;

    procedure OnRunTaxFreeRequestGetSet(var TaxFreeRequest: Record "NPR Tax Free Request"; SetPar: Boolean)
    begin
        if SetPar then
            OnRunTaxFreeRequest.Copy(TaxFreeRequest)
        else
            TaxFreeRequest.Copy(OnRunTaxFreeRequest);
    end;

    procedure OnRunTaxFreeVoucherGetSet(var TaxFreeVoucher: Record "NPR Tax Free Voucher"; SetPar: Boolean)
    begin
        if SetPar then
            OnRunTaxFreeVoucher.Copy(TaxFreeVoucher)
        else
            TaxFreeVoucher.Copy(OnRunTaxFreeVoucher);
    end;

    procedure OnRunHandledGetSet(var Handled: Boolean; SetPar: Boolean)
    begin
        if SetPar then
            OnRunHandled := Handled
        else
            Handled := OnRunHandled;
    end;

    procedure OnRunIsForeignIINGetSet(var IsForeignIINPar: Boolean; SetPar: Boolean)
    begin
        if SetPar then
            OnRunIsForeignIIN := IsForeignIINPar
        else
            IsForeignIINPar := OnRunIsForeignIIN;
    end;

    procedure OnRunEligibleGetSet(var EligiblePar: Boolean; SetPar: Boolean)
    begin
        if SetPar then
            OnRunEligible := EligiblePar
        else
            EligiblePar := OnRunEligible;
    end;

    procedure OnRunSilentSet(Silent: Boolean)
    begin
        OnRunHandled := Silent
    end;

    procedure OnRunFunctionSet(OnRunFunctionPar: Enum "NPR Tax Free OnRunFunction")
    begin
        OnRunFunction := OnRunFunctionPar
    end;

    procedure OnRunTaxFreeRequestSuccessSet(SuccessPar: Boolean)
    begin
        OnRunTaxFreeRequest.Success := SuccessPar
    end;

    procedure OnRunSalesReceiptNoSet(SalesReceiptNoPar: Code[20])
    begin
        OnRunSalesReceiptNo := SalesReceiptNoPar;
    end;

    procedure OnRunIsrecentVoucherSet(IsRecentVoucherPar: Boolean)
    begin
        OnRunIsrecentVoucher := IsRecentVoucherPar;
    end;

    procedure OnRunMaskedCardNoSet(MaskedCardNoPar: Text)
    begin
        OnRunMaskedCardNo := MaskedCardNoPar;
    end;

    procedure OnRunSkipRecordHandlingGetSet(var SkipRecordHandlingPar: Boolean; SetPar: Boolean)
    begin
        if SetPar then
            OnRunSkipRecordHandling := SkipRecordHandlingPar
        else
            SkipRecordHandlingPar := OnRunSkipRecordHandling;
    end;

    procedure OnRunTmpTaxFreeConsolidationGetSet(var tmpTaxFreeConsolidation: Record "NPR Tax Free Consolidation" temporary; SetPar: Boolean)
    begin
        if SetPar then begin
            TempOnRunTaxFreeConsolidation.reset();
            If (TempOnRunTaxFreeConsolidation.IsTemporary()) then
                TempOnRunTaxFreeConsolidation.DeleteAll();

            tmpTaxFreeConsolidation.Reset();
            if (tmpTaxFreeConsolidation.FindSet()) then begin
                repeat
                    TempOnRunTaxFreeConsolidation.TransferFields(tmpTaxFreeConsolidation, true);
                    if (not TempOnRunTaxFreeConsolidation.Insert()) then;
                until (tmpTaxFreeConsolidation.next() = 0);
            end;
        end
        else begin
            TempOnRunTaxFreeConsolidation.Reset();
            if (TempOnRunTaxFreeConsolidation.FindSet()) then begin
                repeat
                    TmpTaxFreeConsolidation.TransferFields(TempOnRunTaxFreeConsolidation, true);
                    if (not TmpTaxFreeConsolidation.Insert()) then;
                until (TempOnRunTaxFreeConsolidation.next() = 0);
            end;
        end;
    end;
}
