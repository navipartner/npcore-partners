codeunit 6014515 "Send Register Balance"
{
    // NPR4.000.002 RV 151110 - Case : 96756 - Moved further up, or else the CALCFIELDS won't take the filter into consideration
    // NPR4.18/RMT/20150909 Case 223387 include user and diff in sms
    // NPR5.36/TJ  /20170907 CASE 286283 Renamed variables/function into english and into proper naming terminology
    //                                   Removed unused variables

    TableNo = "Sale POS";

    trigger OnRun()
    begin
        SendRegisterBalance(Rec);
    end;

    procedure SendRegisterBalance(SalePOS: Record "Sale POS")
    var
        RetailSetup: Record "Retail Setup";
        IComm: Record "I-Comm";
        Register: Record Register;
        AuditRoll: Record "Audit Roll";
        PaymentTypePOS: Record "Payment Type POS";
        CuSMS: Codeunit SMS;
        SMS: Text[250];
        Txt001: Label '%5 register %6: At %2 the %1 the amount is %3. No. of transactions are %4, user: %7, difference: %8';
        RegisterEndDate: Date;
    begin
        //Sender SMS med bruttoomsætning
        with SalePOS do begin
        RetailSetup.Get;
        if RetailSetup."Receive Register Turnover" <> RetailSetup."Receive Register Turnover"::None then begin
          if RegisterEndDate = 0D then
            RegisterEndDate := Today;
            Register.Reset;
            Register.SetCurrentKey(Status);
            Register.SetFilter(Status,'<>%1',Register.Status::Afsluttet);
            Clear(AuditRoll);

            //-NPR4.18
            if not AuditRoll.Get(SalePOS."Register No.",
                                      SalePOS."Sales Ticket No.",
                                      AuditRoll."Sale Type"::Comment,
                                      0,
                                      SalePOS."Register No.",
                                      Today) then
              AuditRoll.Init;
            //+NPR4.18

            if (not Register.Find('-')) or
               (RetailSetup."Receive Register Turnover" = RetailSetup."Receive Register Turnover"::"Per Register") then begin

              PaymentTypePOS.Reset;
              if RetailSetup."Receive Register Turnover" = RetailSetup."Receive Register Turnover"::"Per Register" then
                PaymentTypePOS.SetFilter("Register Filter",SalePOS."Register No.");
              PaymentTypePOS.SetFilter("Date Filter",Format(RegisterEndDate));
              PaymentTypePOS.CalcFields("Normal Sale in Audit Roll");
              PaymentTypePOS.CalcFields("Debit Sale in Audit Roll");
              PaymentTypePOS.CalcFields("No. of Sales in Audit Roll");

              IComm.Get;
              //-NPR4.18
              //SMS := STRSUBSTNO( t001,
              //                    Kasseafslutningsdato, Eksp."Start Time", Betalingsvalg."Normal sale in audit roll"
              //                  + Betalingsvalg."Debit sale in audit roll",
              //                    Betalingsvalg."No. sales in audit roll", COMPANYNAME,Eksp."Register No.");
              SMS := StrSubstNo(Txt001,
                                  RegisterEndDate, SalePOS."Start Time",PaymentTypePOS."Normal Sale in Audit Roll"
                                + PaymentTypePOS."Debit Sale in Audit Roll",
                                  PaymentTypePOS."No. of Sales in Audit Roll",CompanyName,SalePOS."Register No.",
                                  SalePOS."Salesperson Code",AuditRoll.Difference);
              //+NPR4.18
              if IComm."Reg. Turnover Mobile No." <> '' then
                CuSMS.SendSMS(IComm."Reg. Turnover Mobile No.",SMS);
              if IComm."Register Turnover Mobile 2" <> '' then
                CuSMS.SendSMS(IComm."Register Turnover Mobile 2",SMS);
              if IComm."Register Turnover Mobile 3" <> '' then
                CuSMS.SendSMS(IComm."Register Turnover Mobile 3",SMS);
              if IComm."Turnover - Email Addresses" <> '' then
                Message('Could not send E-mail.');
          end;
        end;
        end;
    end;
}

