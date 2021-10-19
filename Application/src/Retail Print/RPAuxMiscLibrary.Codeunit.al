codeunit 6014550 "NPR RP Aux - Misc. Library"
{

#pragma warning disable AA0150
    procedure ApplyCipher(var "Proccesing Value": Text[30]; HandleDecimals: Boolean) CifferCodeValue: Code[10]
#pragma warning restore
    var
        ExchangeLabelSetup: Record "NPR Exchange Label Setup";
        CifferCode: Code[10];
        Index: Integer;
        Itt: Integer;
    begin
        ExchangeLabelSetup.Get();

        for Itt := 1 to StrLen("Proccesing Value") do begin
            if Evaluate(Index, Format("Proccesing Value"[Itt])) and (Format("Proccesing Value"[Itt]) <> '.') then begin
                Index += 1;
                CifferCodeValue += Format(CifferCode[Index]);
            end else begin
                if HandleDecimals then
                    Index += 1
                else
                    Itt := StrLen("Proccesing Value");
            end;
        end;

        "Proccesing Value" := CifferCodeValue;
    end;

#pragma warning disable AA0150
    procedure ApplyCurrencyConversion(var "Processing Value": Text[30]; "Conversion String": Code[30])
#pragma warning restore
    var
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        String: Codeunit "NPR String Library";
        RoundingPrecision: Decimal;
        RoundingDirection: Text[1];
        CurrencyCode: Code[10];
        "Amount (LCY)": Decimal;
        "Amount (FCY)": Decimal;
        Multiplier: Decimal;
    begin
        String.Construct("Conversion String");
        CurrencyCode := String.SelectStringSep(2, ' ');

        if String.CountOccurences(' ') > 1 then begin
            Evaluate(RoundingPrecision, CopyStr(String.SelectStringSep(3, ' '), 2));
            RoundingDirection := CopyStr(String.SelectStringSep(3, ' '), 1, 1)
        end else begin
            RoundingPrecision := 0.1;
            RoundingDirection := '>'
        end;

        "Amount (LCY)" := ParseAsDecimal("Processing Value");
        Multiplier := CurrencyExchangeRate.ExchangeRate(Today, CurrencyCode);
        "Amount (FCY)" := Round(Multiplier * "Amount (LCY)", RoundingPrecision, RoundingDirection);
        "Processing Value" := FormatDecimal("Amount (FCY)");
    end;

#pragma warning disable AA0150
    procedure ApplyExchangeDeadline(var "Processing Value": Text[30])
#pragma warning restore
    var
        ExchangeLabelSetup: Record "NPR Exchange Label Setup";
        Date: Date;
    begin
        ExchangeLabelSetup.Get();
        if Evaluate(Date, "Processing Value") then
            "Processing Value" := Format(CalcDate(ExchangeLabelSetup."Exchange Label Exchange Period", Date));
    end;

#pragma warning disable AA0150
    procedure FormatNumberNoDecimal(var "Processing Value": Text[30])
#pragma warning restore
    var
        Dec: Decimal;
    begin
        if Evaluate(Dec, "Processing Value", 9) then
            "Processing Value" := Format(Dec div 1); //always round down
    end;

    procedure FormatNumberOneDecimal(var ProcessingValue: Text[30])
    begin
        if ProcessingValue <> '' then
            ProcessingValue := Format(ParseAsDecimal(ProcessingValue), 0, '<Precision,1:1><Standard Format,2>');
    end;

    local procedure FormatNumberTwoDecimal(var ProcessingValue: Text)
    begin
        if ProcessingValue <> '' then
            ProcessingValue := Format(ParseAsDecimal(ProcessingValue), 0, '<Precision,2:2><Standard Format,2>');
    end;

    procedure FormatNumberSeparator(var ProcessingValue: Text)
    begin
        if ProcessingValue <> '' then
            ProcessingValue := Format(ParseAsDecimal(ProcessingValue), 0, '<Precision,2:2><Standard Format,0>');
    end;

    procedure FormatNumberSeperatorAndRound(var ProcessingValue: Text)
    begin
        if ProcessingValue <> '' then
            ProcessingValue := Format(ParseAsDecimal(ProcessingValue), 0, '<Precision,0:5><Standard Format,0>');
    end;

    local procedure NegateDecimal(var ProcessingValue: Text)
    begin
        if ProcessingValue <> '' then
            ProcessingValue := Format(ParseAsDecimal(ProcessingValue) * -1);
    end;

    local procedure PrintReceiptText(var TemplateLine: Record "NPR RP Template Line"; RecordID: RecordID)
    var
        LinePrintMgt: Codeunit "NPR RP Line Print Mgt.";
        Utility: Codeunit "NPR Receipt Footer Mgt.";
        TicketRcptText: Record "NPR POS Ticket Rcpt. Text";
        RecRef: RecordRef;
        POSEntry: Record "NPR POS Entry";
        POSUnit: Record "NPR POS Unit";
    begin
        case RecordID.TableNo of
            DATABASE::"NPR POS Entry":
                begin
                    RecRef := RecordID.GetRecord();
                    RecRef.SetTable(POSEntry);
                    POSEntry.Find();
                    POSUnit.Get(POSEntry."POS Unit No.");
                    Utility.GetSalesTicketReceiptText(TicketRcptText, POSUnit);
                end;
        end;
        LinePrintMgt.SetFont(TemplateLine."Type Option");
        repeat
            LinePrintMgt.AddTextField(1, TemplateLine.Align, TicketRcptText."Receipt Text");
        until TicketRcptText.Next() = 0;
    end;

    procedure FormatMonthFromDate(ProcessingDate: Date) FormattedMonth: Text
    begin
        if ProcessingDate <> 0D then
            exit(Format(ProcessingDate, 0, '<Month Text>'));
    end;

    procedure FormatMonthFromDatetime(ProcessingDateTime: DateTime) FormattedMonth: Text
    var
        tmpProcessingDate: Date;
    begin
        if ProcessingDateTime <> 0DT then begin
            tmpProcessingDate := DT2Date(ProcessingDateTime);
            exit(Format(tmpProcessingDate, 0, '<Month Text>'));
        end;
    end;

    procedure IntToHex(BigInt: BigInteger): Text
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        exit(TypeHelper.IntToHex(BigInt));
    end;

    procedure StringToHex(Text: Text): Text
    var
        TypeHelper: Codeunit "Type Helper";
        TmpInt: Integer;
        ResultText: Text;
        i: Integer;
    begin
        for i := 1 to StrLen(Text) do begin
            TmpInt := Text[i];
            ResultText += TypeHelper.IntToHex(TmpInt).PadRight(4, '0');
        end;
        exit(ResultText);
    end;

    procedure MultiplicativeInverseEncode(plain: Integer) encoded: BigInteger
    var
        m: BigInteger;
        x: BigInteger;
    begin
        // OBFUSCATION of an integer number using modular math
        // (x * y * plain) MOD m == plain MOD m when plain > 0

        // For explaination of multiplicative inverse see wikipedia
        // Too calculate multiplicative inverse there is an online tool at
        // https://planetcalc.com/3311/

        m := 1000000000;  // Our result numbers will be in range 0..999999999

        // x is any number but must be a coprime to m
        // m is dividable with 2 and 5,
        // numbers that are dividable with 2 or 5 ends with 0, 2, 4, 6, 8
        // a number ending in a 9 cannot be dividable by 2 or 5
        x := 487620189;
        encoded := plain * x mod m;
    end;

    procedure MultiplicativeInverseDecode(encoded: BigInteger) plain: Integer
    var
        m: BigInteger;
        y: BigInteger;
    begin
        // OBFUSCATION of an integer number using modular math
        // (x * y * plain) MOD m == plain MOD m when plain > 0

        // For explaination of multiplicative inverse see wikipedia
        // Too calculate multiplicative inverse there is an online tool at
        // https://planetcalc.com/3311/

        m := 1000000000;

        // modular multiplicative inverse for 487620189 mod 1000000000
        // (487620189 * 959774709) MOD 1000000000 == 1
        y := 959774709;
        plain := encoded * y mod m;
    end;

    local procedure CalculateDate(FormattedDate: Text; DateFormula: Text): Text
    var
        Date: Date;
    begin
        Evaluate(Date, FormattedDate);
        exit(Format(CalcDate('<' + DateFormula + '>', Date)));
    end;

    local procedure ParseAsDecimal(Value: Text[30]) DecimalValue: Decimal
    begin
        Evaluate(DecimalValue, Value, 9);
    end;

    local procedure ParseAsDate(Value: Text) DateValue: Date
    begin
        Evaluate(DateValue, Value);
    end;

    local procedure ParseAsDateTime(Value: Text) DateTimeValue: DateTime
    begin
        Evaluate(DateTimeValue, Value);
    end;

    local procedure ParseAsBigInteger(Value: Text) BigIntValue: BigInteger
    begin
        Evaluate(BigIntValue, Value);
    end;

    local procedure FormatDecimal(DecimalValue: Decimal): Text
    begin
        exit(Format(DecimalValue, 0, '<Precision,2:2><Standard Format,2>'));
    end;

    local procedure AddFunction(var tmpRetailList: Record "NPR Retail List" temporary; Choice: Text)
    begin
        tmpRetailList.Number += 1;
        tmpRetailList.Choice := Choice;
        tmpRetailList.Insert();
    end;

    local procedure PadLeft(Value: Text; PadChar: Text; Length: Integer): Text
    var
        ValueLength: Integer;
    begin
        ValueLength := StrLen(Value);

        if ValueLength >= Length then
            exit(Value);

        exit(PadStr('', Length - ValueLength, PadChar) + Value);
    end;

    local procedure GetReceiptPrintCount(var ProcessingValue: Text[250]; var RecID: RecordId; IncludeFirstPrint: Boolean)
    var
        POSEntryOutputLog: Record "NPR POS Entry Output Log";
        POSEntryOutputLog2: Record "NPR POS Entry Output Log";
        RecRef: RecordRef;
    begin
        RecRef := RecID.GetRecord();
        RecRef.SetTable(POSEntryOutputLog);
        POSEntryOutputLog.Find();

        POSEntryOutputLog2.SetRange("POS Entry No.", POSEntryOutputLog."POS Entry No.");
        POSEntryOutputLog2.SetRange("Output Method", POSEntryOutputLog2."Output Method"::Print);
        POSEntryOutputLog2.SetFilter("Output Type", '=%1|=%2', POSEntryOutputLog2."Output Type"::SalesReceipt, POSEntryOutputLog2."Output Type"::LargeSalesReceipt);

        //Since POSEntryOutputLog is populated after the print, not before, we have to +1 to count the first print:
        if IncludeFirstPrint then begin
            ProcessingValue := Format(POSEntryOutputLog2.Count() + 1);
        end else begin
            ProcessingValue := Format(POSEntryOutputLog2.Count());
        end;
    end;


    [EventSubscriber(ObjectType::Table, Database::"NPR RP Template Line", 'OnBuildFunctionCodeunitList', '', false, false)]
    local procedure OnBuildFunctionCodeunitList(var tmpAllObj: Record AllObj temporary)
    var
        AllObj: Record AllObj;
    begin
        AllObj.Get(AllObj."Object Type"::Codeunit, CODEUNIT::"NPR RP Aux - Misc. Library");
        tmpAllObj.Init();
        tmpAllObj := AllObj;
        tmpAllObj.Insert();
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR RP Template Line", 'OnBuildFunctionList', '', false, false)]
    local procedure OnBuildFunctionList(CodeunitID: Integer; var tmpRetailList: Record "NPR Retail List" temporary)
    begin
        if CodeunitID <> CODEUNIT::"NPR RP Aux - Misc. Library" then
            exit;

        AddFunction(tmpRetailList, 'CURRENTDATETIME');
        AddFunction(tmpRetailList, 'CURRENTDATE');
        AddFunction(tmpRetailList, 'CURRENTTIME');
        AddFunction(tmpRetailList, 'RECEIPT_TEXT');
        AddFunction(tmpRetailList, 'CIFFERCODE');
        AddFunction(tmpRetailList, 'EXCHANGEDEADLINE');
        AddFunction(tmpRetailList, 'CONVERT EUR');
        AddFunction(tmpRetailList, 'CONVERT GBP');
        AddFunction(tmpRetailList, 'CONVERT SEK');
        AddFunction(tmpRetailList, 'CIPHERCODE_WITHDECIMALS');
        AddFunction(tmpRetailList, 'NEGATE_DECIMAL');

        AddFunction(tmpRetailList, 'NUMBER_NO_DECIMAL');
        AddFunction(tmpRetailList, 'NUMBER_ONE_DECIMAL');
        AddFunction(tmpRetailList, 'NUMBER_TWO_DECIMAL');
        AddFunction(tmpRetailList, 'NUMBER_SEPARATOR_TWO_DECIMAL');
        AddFunction(tmpRetailList, 'NUMBER_SEPARATOR_ROUND');

        AddFunction(tmpRetailList, 'CURRENTDAY');
        AddFunction(tmpRetailList, 'CURRENTMONTH');
        AddFunction(tmpRetailList, 'CURRENTYEAR');
        AddFunction(tmpRetailList, 'CURRENTYEAR_SHORT');
        AddFunction(tmpRetailList, 'DATE_DAY');
        AddFunction(tmpRetailList, 'DATE_MONTH');
        AddFunction(tmpRetailList, 'DATE_YEAR');
        AddFunction(tmpRetailList, 'DATE_YEAR_SHORT');

        AddFunction(tmpRetailList, 'FORMAT_MONTH_FROM_DATE');
        AddFunction(tmpRetailList, 'FORMAT_MONTH_FROM_DATETIME');

        AddFunction(tmpRetailList, 'INT_TO_HEX');
        AddFunction(tmpRetailList, 'STRING_TO_HEX');

        AddFunction(tmpRetailList, 'OBFUSCATE_MI');

        AddFunction(tmpRetailList, 'CALC_DATE');
        AddFunction(tmpRetailList, 'RECEIPT_PRINT_COUNT');
        AddFunction(tmpRetailList, 'RECEIPT_REPRINT_COUNT');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR RP Template Line", 'OnFunction', '', false, false)]
    local procedure OnFunction(CodeunitID: Integer; FunctionName: Text; var TemplateLine: Record "NPR RP Template Line"; RecID: RecordID; var Skip: Boolean; var Handled: Boolean)
    begin
        if CodeunitID <> CODEUNIT::"NPR RP Aux - Misc. Library" then
            exit;

        Handled := true;

        case FunctionName of
            //Constants
            'CURRENTDATETIME':
                TemplateLine."Processing Value" := Format(CurrentDateTime);
            'CURRENTDATE':
                TemplateLine."Processing Value" := Format(Today);
            'CURRENTTIME':
                TemplateLine."Processing Value" := Format(Time);
            'CURRENTDAY':
                TemplateLine."Processing Value" := PadLeft(Format(Date2DMY(Today, 1)), '0', 2);
            'CURRENTMONTH':
                TemplateLine."Processing Value" := PadLeft(Format(Date2DMY(Today, 2)), '0', 2);
            'CURRENTYEAR':
                TemplateLine."Processing Value" := Format(Date2DMY(Today, 3));
            'CURRENTYEAR_SHORT':
                TemplateLine."Processing Value" := CopyStr(Format(Date2DMY(Today, 3)), 3, 2);
            'RECEIPT_TEXT':
                PrintReceiptText(TemplateLine, RecID);
            //Date formatting
            'DATE_DAY':
                TemplateLine."Processing Value" := PadLeft(Format(Date2DMY(ParseAsDate(TemplateLine."Processing Value"), 1)), '0', 2);
            'DATE_MONTH':
                TemplateLine."Processing Value" := PadLeft(Format(Date2DMY(ParseAsDate(TemplateLine."Processing Value"), 2)), '0', 2);
            'DATE_YEAR':
                TemplateLine."Processing Value" := Format(Date2DMY(ParseAsDate(TemplateLine."Processing Value"), 3));
            'DATE_YEAR_SHORT':
                TemplateLine."Processing Value" := CopyStr(Format(Date2DMY(ParseAsDate(TemplateLine."Processing Value"), 3)), 3, 2);
            'FORMAT_MONTH_FROM_DATE':
                TemplateLine."Processing Value" := FormatMonthFromDate(ParseAsDate(TemplateLine."Processing Value"));
            'FORMAT_MONTH_FROM_DATETIME':
                TemplateLine."Processing Value" := FormatMonthFromDatetime(ParseAsDateTime(TemplateLine."Processing Value"));
            'NUMBER_NO_DECIMAL':
                FormatNumberNoDecimal(TemplateLine."Processing Value");
            'NUMBER_ONE_DECIMAL':
                FormatNumberOneDecimal(TemplateLine."Processing Value");
            'NUMBER_TWO_DECIMAL':
                FormatNumberTwoDecimal(TemplateLine."Processing Value");
            'NUMBER_SEPARATOR_TWO_DECIMAL':
                FormatNumberSeparator(TemplateLine."Processing Value");
            'NUMBER_SEPARATOR_ROUND':
                FormatNumberSeperatorAndRound(TemplateLine."Processing Value");
            'CIFFERCODE':
                ApplyCipher(TemplateLine."Processing Value", false);
            'CIPHERCODE_WITHDECIMALS':
                ApplyCipher(TemplateLine."Processing Value", true);
            'EXCHANGEDEADLINE':
                ApplyExchangeDeadline(TemplateLine."Processing Value");
            'NEGATE_DECIMAL':
                NegateDecimal(TemplateLine."Processing Value");
            'INT_TO_HEX':
                TemplateLine."Processing Value" := IntToHex(ParseAsBigInteger(TemplateLine."Processing Value"));
            'STRING_TO_HEX':
                TemplateLine."Processing Value" := StringToHex(TemplateLine."Processing Value");
            'OBFUSCATE_MI':
                TemplateLine."Processing Value" := Format(MultiplicativeInverseEncode(ParseAsBigInteger(TemplateLine."Processing Value")), 0, 9);
            'CALC_DATE':
                TemplateLine."Processing Value" := CalculateDate(TemplateLine."Processing Value", TemplateLine."Processing Function Parameter");
            'DECTOINT':
                FormatNumberNoDecimal(TemplateLine."Processing Value");
            'ROUNDTO1DECIMAL':
                FormatNumberOneDecimal(TemplateLine."Processing Value");
            'FORMAT_THOUSANDSEP':
                FormatNumberSeparator(TemplateLine."Processing Value");
            'DECTOINT_WITHSEP':
                FormatNumberSeperatorAndRound(TemplateLine."Processing Value");
            'RECEIPT_PRINT_COUNT':
                GetReceiptPrintCount(TemplateLine."Processing Value", RecID, true);
            'RECEIPT_REPRINT_COUNT':
                GetReceiptPrintCount(TemplateLine."Processing Value", RecID, false);
            else
                case true of
                    CopyStr(TemplateLine."Processing Function ID", 1, 7) = 'CONVERT':
                        ApplyCurrencyConversion(TemplateLine."Processing Value", TemplateLine."Processing Function ID");
                end;
        end;
    end;
}

