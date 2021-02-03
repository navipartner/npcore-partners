codeunit 6014515 "NPR Send Register Balance"
{
    TableNo = "NPR Sale POS";

    trigger OnRun()
    begin
        SendRegisterBalance(Rec);
    end;

    procedure SendRegisterBalance(SalePOS: Record "NPR Sale POS")
    var
        AuditRoll: Record "NPR Audit Roll";
        IComm: Record "NPR I-Comm";
        PaymentTypePOS: Record "NPR Payment Type POS";
        Register: Record "NPR Register";
        RetailSetup: Record "NPR Retail Setup";
        CuSMS: Codeunit "NPR SMS";
        RegisterEndDate: Date;
        SMSLbl: Label '%5 register %6: At %2 the %1 the amount is %3. No. of transactions are %4, user: %7, difference: %8', Comment = '%1 = Register End Date, %2 = Start Time, %3 = Normal Sale in Audit Roll + Debit Sale in Audit Roll, %4 = No. of Sales in Audit Roll, %5 = Company Name, %6 = Register No, %7 = Salesperson Code, %8 = Difference';
        CouldnotSendEmailMsg: Label 'Could not send E-mail.';
        SMS: Text[250];
    begin
        //Sender SMS med bruttoomsætning
        RetailSetup.Get;
        if RetailSetup."Receive Register Turnover" <> RetailSetup."Receive Register Turnover"::None then begin
            if RegisterEndDate = 0D then
                RegisterEndDate := Today;
            Register.SetCurrentKey(Status);
            Register.SetFilter(Status, '<>%1', Register.Status::Afsluttet);
            Clear(AuditRoll);

            if not AuditRoll.Get(SalePOS."Register No.",
                                    SalePOS."Sales Ticket No.",
                                    AuditRoll."Sale Type"::Comment,
                                    0,
                                    SalePOS."Register No.",
                                    Today) then
                AuditRoll.Init();

            if (not Register.Find('-')) or
               (RetailSetup."Receive Register Turnover" = RetailSetup."Receive Register Turnover"::"Per Register") then begin

                PaymentTypePOS.Reset();
                if RetailSetup."Receive Register Turnover" = RetailSetup."Receive Register Turnover"::"Per Register" then
                    PaymentTypePOS.SetFilter("Register Filter", SalePOS."Register No.");
                PaymentTypePOS.SetFilter("Date Filter", Format(RegisterEndDate));
                PaymentTypePOS.CalcFields("Normal Sale in Audit Roll");
                PaymentTypePOS.CalcFields("Debit Sale in Audit Roll");
                PaymentTypePOS.CalcFields("No. of Sales in Audit Roll");

                IComm.Get();
                SMS := StrSubstNo(SMSLbl,
                                    RegisterEndDate, SalePOS."Start Time", PaymentTypePOS."Normal Sale in Audit Roll"
                                  + PaymentTypePOS."Debit Sale in Audit Roll",
                                    PaymentTypePOS."No. of Sales in Audit Roll", CompanyName, SalePOS."Register No.",
                                    SalePOS."Salesperson Code", AuditRoll.Difference);
                if IComm."Reg. Turnover Mobile No." <> '' then
                    CuSMS.SendSMS(IComm."Reg. Turnover Mobile No.", SMS);
                if IComm."Register Turnover Mobile 2" <> '' then
                    CuSMS.SendSMS(IComm."Register Turnover Mobile 2", SMS);
                if IComm."Register Turnover Mobile 3" <> '' then
                    CuSMS.SendSMS(IComm."Register Turnover Mobile 3", SMS);
                if IComm."Turnover - Email Addresses" <> '' then
                    Message(CouldnotSendEmailMsg);
            end;
        end;
    end;
}

