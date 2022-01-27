codeunit 6151453 "NPR Magento NpXml FIK"
{
    Access = Internal;
    TableNo = "NPR NpXml Custom Val. Buffer";

    trigger OnRun()
    var
        NpXmlElement: Record "NPR NpXml Element";
        RecRef: RecordRef;
        CustomValue: Text;
        OutStr: OutStream;
    begin
        if not NpXmlElement.Get(Rec."Xml Template Code", Rec."Xml Element Line No.") then
            exit;
        Clear(RecRef);
        RecRef.Open(Rec."Table No.");
        RecRef.SetPosition(Rec."Record Position");
        if not RecRef.Find() then
            exit;

        CustomValue := Format(GetFIK('71', RecRef), 0, 9);
        RecRef.Close();

        Clear(RecRef);

        Rec.Value.CreateOutStream(OutStr);
        OutStr.WriteText(CustomValue);
        Rec.Modify();
    end;

    local procedure GetFIK(FIKType: Code[2]; RecRef: RecordRef) FIKNo: Text
    var
        CompanyInfo: Record "Company Information";
        SalesInvHeader: Record "Sales Invoice Header";
        PaymentID: Text;
        CheckDigit: Text[1];
        SubSum: Integer;
        CheckSum: Integer;
        i: Integer;
        IntBuffer: Integer;
        PmtIDLength: Integer;
    begin
        CompanyInfo.Get();
        CompanyInfo.TestField("Giro No.");

        case FIKType of
            '01':
                PmtIDLength := 0;
            '04':
                PmtIDLength := 16;
            '15':
                PmtIDLength := 16;
            '41':
                PmtIDLength := 10;
            '71':
                PmtIDLength := 15;
            '73':
                PmtIDLength := 0;
            '75':
                PmtIDLength := 16;
            else
                exit('');
        end;

        case RecRef.Number of
            DATABASE::"Sales Invoice Header":
                begin
                    RecRef.SetTable(SalesInvHeader);
                    if not SalesInvHeader.Find() then
                        exit('');
                    PaymentID := PadStr('', PmtIDLength - 2 - StrLen(SalesInvHeader."No."), '0') + SalesInvHeader."No." + '0';
                end;
        end;

        CheckSum := 0;
        for i := 1 to StrLen(PaymentID) do begin
            Evaluate(IntBuffer, Format(PaymentID[i]));
            SubSum := IntBuffer;
            if i mod 2 = 0 then begin
                SubSum := SubSum * 2;
                if SubSum >= 10 then
                    SubSum := (SubSum mod 10) + (SubSum div 10);
            end;
            CheckSum += SubSum;
        end;
        CheckSum := CheckSum mod 10;
        if CheckSum = 0 then
            CheckSum := 10;
        CheckDigit := Format(10 - CheckSum);

        FIKNo := '+' + FIKType + '<' + PaymentID + CheckDigit + ' +' + CompanyInfo."Giro No." + '<';
        exit(FIKNo);
    end;
}
