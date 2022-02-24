codeunit 6059790 "NPR Pay-in Payout Mgr"
{
    Access = Internal;
    procedure CreatePayInOutPayment(SaleLine: Codeunit "NPR POS Sale Line"; PaymentType: Integer; AccountNo: Code[20]; Description: Text[100]; Amount: Decimal; ReasonCode: Code[10]): Boolean
    var
        Line: Record "NPR POS Sale Line";
        Quantity: Decimal;
    begin
        Amount := Abs(Amount);
        Quantity := 1;

        if (PaymentType = 1) then // Pay-In 
            Quantity := -1;

        SaleLine.InitPayoutPayInLine(Line);

        Line.Validate("No.", AccountNo);
        Line."Custom Descr" := (Description <> '');
        if Line."Custom Descr" then
            Line.Description := CopyStr(Description, 1, MaxStrLen(Line.Description));
        Line.Quantity := Quantity;
        Line."Amount Including VAT" := Amount;
        Line."Unit Price" := Amount;
        Line."Reason Code" := ReasonCode;

        exit(SaleLine.InsertLine(Line));
    end;
}