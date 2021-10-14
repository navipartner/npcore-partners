codeunit 6014510 "NPR MobilePayV10 CancelDead"
{
    var
        TempDefaultMobilePayEftIntType: Record "NPR EFT Integration Type" temporary;

    trigger OnRun()
    begin
        ProcessAllMobilePayUnits();
    end;

    local procedure ProcessAllMobilePayUnits()
    var
        eftSetup: Record "NPR EFT Setup";
        mobilePayV10Integration: Codeunit "NPR MobilePayV10 Integration";
    begin
        mobilePayV10Integration.FindAndSetDefaultMobilePayV10IntegrationType(TempDefaultMobilePayEftIntType);
        if TempDefaultMobilePayEftIntType.FindSet() then begin
            repeat
                eftSetup.SetRange("EFT Integration Type", TempDefaultMobilePayEftIntType.Code);
                if eftSetup.FindSet() then begin
                    repeat
                        FindAndProcessPayments(eftSetup);
                    until eftSetup.Next() = 0;
                end;
            until TempDefaultMobilePayEftIntType.Next() = 0;
        end;
    end;

    local procedure FindAndProcessPayments(var EftSetup: Record "NPR EFT Setup")
    var
        mobilePayV10FindPayments: Codeunit "NPR MobilePayV10 Find Payment";
        mobilePayV10GetPayment: Codeunit "NPR MobilePayV10 Get Payment";
        eftFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        eftTransRequest: Record "NPR EFT Transaction Request";
        mobilePayV10AuxiliaryRequest: Enum "NPR MobilePayV10 Auxiliary Request";
        mobilePayV10UnitSetup: Record "NPR MobilePayV10 Unit Setup";
        tempMobilePayV10Payment: Record "NPR MobilePayV10 Payment" temporary;
        tempMobilePayV10Payment2: Record "NPR MobilePayV10 Payment" temporary;
        mobilePayCancelPayment: Codeunit "NPR MobilePayV10 Can.Payment";
        mobilePayProtocol: Codeunit "NPR MobilePayV10 Protocol";
        eftEntryNo: Integer;
        success: Boolean;
        PosIdLbl: Label 'posId=%1', Locked = true;
    begin
        tempMobilePayV10Payment.Reset();
        tempMobilePayV10Payment.DeleteAll();

        tempMobilePayV10Payment2.Copy(tempMobilePayV10Payment, true);

        mobilePayV10UnitSetup.Get(EftSetup."POS Unit No.");

        eftFrameworkMgt.CreateAuxRequest(eftTransRequest, eftSetup, mobilePayV10AuxiliaryRequest::FindAllPayments.AsInteger(), EftSetup."POS Unit No.", '');

        Commit();

        mobilePayV10FindPayments.SetFilter(StrSubstNo(PosIdLbl, mobilePayV10UnitSetup."MobilePay POS ID"));
        mobilePayV10FindPayments.SetPaymentDetailBuffer(tempMobilePayV10Payment);
        mobilePayV10FindPayments.Run(eftTransRequest);  // TODO: Handling... (I will move this to MobilePay protocol codeunit, only the part that returns list of payments).

        tempMobilePayV10Payment.Reset();
        if (tempMobilePayV10Payment.FindSet()) then begin
            repeat
                tempMobilePayV10Payment2 := tempMobilePayV10Payment;

                Clear(eftTransRequest);
                eftFrameworkMgt.CreateAuxRequest(eftTransRequest, eftSetup, mobilePayV10AuxiliaryRequest::GetPaymentDetail.AsInteger(), EftSetup."POS Unit No.", '');
                eftTransRequest."Reference Number Output" := tempMobilePayV10Payment2.PaymentId;
                eftTransRequest.Modify();
                Commit();

                mobilePayV10GetPayment.SetPaymentDetailBuffer(tempMobilePayV10Payment2);
                mobilePayV10GetPayment.Run(eftTransRequest);

                tempMobilePayV10Payment2.Get(tempMobilePayV10Payment.PaymentId);

                Evaluate(eftEntryNo, tempMobilePayV10Payment2.OrderId);
                eftTransRequest.Get(eftEntryNo);
                if (eftTransRequest."Reference Number Output" = '') then begin
                    eftTransRequest."Reference Number Output" := tempMobilePayV10Payment2.PaymentId;
                    eftTransRequest.Modify();
                end;

                Commit();

                case tempMobilePayV10Payment2.Status of
                    "NPR MobilePayV10 Result Code"::Reserved:
                        begin
                            success := mobilePayCancelPayment.Run(eftTransRequest);
                            mobilePayProtocol.WriteLogEntry(eftSetup, not success, eftTransRequest."Entry No.", 'Invoked API to get trx ID',
                                mobilePayCancelPayment.GetRequestResponse(), true);
                        end;
                end;

            until tempMobilePayV10Payment.Next() = 0;
        end;
    end;
}