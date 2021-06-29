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
                        FindAndProcessRefunds(eftSetup);
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
    begin
        tempMobilePayV10Payment.Reset();
        tempMobilePayV10Payment.DeleteAll();

        tempMobilePayV10Payment2.Copy(tempMobilePayV10Payment, true);

        mobilePayV10UnitSetup.Get(EftSetup."POS Unit No.");

        eftFrameworkMgt.CreateAuxRequest(eftTransRequest, eftSetup, mobilePayV10AuxiliaryRequest::FindAllPayments.AsInteger(), EftSetup."POS Unit No.", '');

        Commit();

        mobilePayV10FindPayments.SetFilter(StrSubstNo('posId=%1', mobilePayV10UnitSetup."MobilePay POS ID"));
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
                            mobilePayProtocol.WriteLogEntry(eftSetup, not success, eftTransRequest."Entry No.", 'Invoked API to get trx ID', mobilePayCancelPayment.GetRequestResponse());
                            Commit();
                        end;
                end;

            until tempMobilePayV10Payment.Next() = 0;
        end;
    end;

    local procedure FindAndProcessRefunds(var EftSetup: Record "NPR EFT Setup")
    var
        mobilePayV10FindRefunds: Codeunit "NPR MobilePayV10 Find Refund";
        mobilePayV10GetRefund: Codeunit "NPR MobilePayV10 Get Refund";
        eftFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        eftTransRequest: Record "NPR EFT Transaction Request";
        mobilePayV10AuxiliaryRequest: Enum "NPR MobilePayV10 Auxiliary Request";
        mobilePayV10UnitSetup: Record "NPR MobilePayV10 Unit Setup";
        mobilePayV10RefundBuff: Record "NPR MobilePayV10 Refund" temporary;
        mobilePayV10RefundBuff2: Record "NPR MobilePayV10 Refund" temporary;
        mobilePayCancelRefund: Codeunit "NPR MobilePayV10 Can. Refund";
        mobilePayProtocol: Codeunit "NPR MobilePayV10 Protocol";
        eftEntryNo: Integer;
        success: Boolean;
    begin
        mobilePayV10RefundBuff.Reset();
        mobilePayV10RefundBuff.DeleteAll();

        mobilePayV10RefundBuff2.Copy(mobilePayV10RefundBuff, true);

        mobilePayV10UnitSetup.Get(EftSetup."POS Unit No.");

        eftFrameworkMgt.CreateAuxRequest(eftTransRequest, eftSetup, mobilePayV10AuxiliaryRequest::FindAllRefunds.AsInteger(), EftSetup."POS Unit No.", '');

        Commit();

        mobilePayV10FindRefunds.SetFilter(StrSubstNo('posId=%1', mobilePayV10UnitSetup."MobilePay POS ID"));
        mobilePayV10FindRefunds.SetRefundDetailBuffer(mobilePayV10RefundBuff);
        mobilePayV10FindRefunds.Run(eftTransRequest);  // TODO: Handling... (I will move this to MobilePay protocol codeunit, only the part that returns list of payments).

        mobilePayV10RefundBuff.Reset();
        if (mobilePayV10RefundBuff.FindSet()) then begin
            repeat
                mobilePayV10RefundBuff2 := mobilePayV10RefundBuff;

                Clear(eftTransRequest);
                eftFrameworkMgt.CreateAuxRequest(eftTransRequest, eftSetup, mobilePayV10AuxiliaryRequest::GetRefundDetail.AsInteger(), EftSetup."POS Unit No.", '');
                eftTransRequest."Reference Number Output" := mobilePayV10RefundBuff2.RefundId;
                eftTransRequest.Modify();
                Commit();

                mobilePayV10GetRefund.SetRefundDetailBuffer(mobilePayV10RefundBuff2);
                mobilePayV10GetRefund.Run(eftTransRequest);

                mobilePayV10RefundBuff2.Get(mobilePayV10RefundBuff);

                Evaluate(eftEntryNo, mobilePayV10RefundBuff2.RefundOrderId);
                eftTransRequest.Get(eftEntryNo);
                if (eftTransRequest."Reference Number Output" = '') then begin
                    eftTransRequest."Reference Number Output" := mobilePayV10RefundBuff2.RefundId;
                    eftTransRequest.Modify();
                end;

                Commit();

                case mobilePayV10RefundBuff2.Status of
                    "NPR MobilePayV10 Result Code"::Reserved:
                        begin
                            success := mobilePayCancelRefund.Run(eftTransRequest);
                            mobilePayProtocol.WriteLogEntry(eftSetup, not success, eftTransRequest."Entry No.", 'Invoked API to get trx ID', mobilePayCancelRefund.GetRequestResponse());
                            Commit();
                        end;
                end;

            until MobilePayV10RefundBuff.Next() = 0;
        end;
    end;
}