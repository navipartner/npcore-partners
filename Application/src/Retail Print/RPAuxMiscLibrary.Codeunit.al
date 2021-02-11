codeunit 6014550 "NPR RP Aux - Misc. Library"
{
    procedure ApplyCipher(var "Proccesing Value": Text[30]; HandleDecimals: Boolean) CifferCodeValue: Code[10]
    var
        RetailConfiguration: Record "NPR Retail Setup";
        CifferCode: Code[10];
        Index: Integer;
        Itt: Integer;
    begin
        RetailConfiguration.Get;
        CifferCode := RetailConfiguration."Purchace Price Code";

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

    procedure ApplyCurrencyConversion(var "Processing Value": Text[30]; "Conversion String": Code[30])
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

    procedure ApplyExchangeDeadline(var "Processing Value": Text[30])
    var
        RetailSetup: Record "NPR Retail Setup";
        Date: Date;
    begin
        RetailSetup.Get();
        if Evaluate(Date, "Processing Value") then
            "Processing Value" := Format(CalcDate(RetailSetup."Exchange Label Exchange Period", Date));
    end;

    procedure FormatNumberNoDecimal(var "Processing Value": Text[30])
    var
        Dec: Decimal;
        Int: Integer;
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
    var
        Decimal: Decimal;
    begin
        if ProcessingValue <> '' then
            ProcessingValue := Format(ParseAsDecimal(ProcessingValue) * -1);
    end;

    local procedure PrintReceiptText(var TemplateLine: Record "NPR RP Template Line"; RecordID: RecordID)
    var
        LinePrintMgt: Codeunit "NPR RP Line Print Mgt.";
        Utility: Codeunit "NPR Receipt Footer Mgt.";
        tmpRetailComment: Record "NPR Retail Comment" temporary;
        Register: Record "NPR Register";
        RecRef: RecordRef;
        AuditRoll: Record "NPR Audit Roll";
        POSEntry: Record "NPR POS Entry";
        POSUnit: Record "NPR POS Unit";
    begin
        case RecordID.TableNo of
            DATABASE::"NPR POS Entry":
                begin
                    RecRef := RecordID.GetRecord();
                    RecRef.SetTable(POSEntry);
                    POSEntry.Find;
                    POSUnit.Get(POSEntry."POS Unit No.");
                    Utility.GetPOSUnitTicketText(tmpRetailComment, POSUnit);
                end;
        end;
        LinePrintMgt.SetFont(TemplateLine."Type Option");
        if tmpRetailComment.FindSet then
            repeat
                LinePrintMgt.AddTextField(1, TemplateLine.Align, tmpRetailComment.Comment);
            until tmpRetailComment.Next = 0;
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
        IntPtr: DotNet NPRNetIntPtr;
    begin
        IntPtr := IntPtr.IntPtr(BigInt);
        exit(IntPtr.ToString('X'));
    end;

    procedure StringToHex(Text: Text): Text
    var
        Encoding: DotNet NPRNetEncoding;
        ByteArray: DotNet NPRNetArray;
        BitConverter: DotNet NPRNetBitConverter;
        Regex: DotNet NPRNetRegex;
    begin
        exit(Regex.Replace(BitConverter.ToString(Encoding.Unicode.GetBytes(Text)), '-', ''));
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
        tmpRetailList.Insert;
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


    [EventSubscriber(ObjectType::Table, 6014445, 'OnBuildFunctionCodeunitList', '', false, false)]
    local procedure OnBuildFunctionCodeunitList(var tmpAllObj: Record AllObj temporary)
    var
        AllObj: Record AllObj;
    begin
        AllObj.Get(AllObj."Object Type"::Codeunit, CODEUNIT::"NPR RP Aux - Misc. Library");
        tmpAllObj.Init;
        tmpAllObj := AllObj;
        tmpAllObj.Insert;
    end;

    [EventSubscriber(ObjectType::Table, 6014445, 'OnBuildFunctionList', '', false, false)]
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
    end;

    [EventSubscriber(ObjectType::Table, 6014445, 'OnFunction', '', false, false)]
    local procedure OnFunction(CodeunitID: Integer; FunctionName: Text; var TemplateLine: Record "NPR RP Template Line"; RecID: RecordID; var Skip: Boolean; var Handled: Boolean)
    begin
        if CodeunitID <> CODEUNIT::"NPR RP Aux - Misc. Library" then
            exit;

        Handled := true;

        with TemplateLine do
            case FunctionName of
                //Constants
                'CURRENTDATETIME':
                    "Processing Value" := Format(CurrentDateTime);
                'CURRENTDATE':
                    "Processing Value" := Format(Today);
                'CURRENTTIME':
                    "Processing Value" := Format(Time);
                'CURRENTDAY':
                    "Processing Value" := PadLeft(Format(Date2DMY(Today, 1)), '0', 2);
                'CURRENTMONTH':
                    "Processing Value" := PadLeft(Format(Date2DMY(Today, 2)), '0', 2);
                'CURRENTYEAR':
                    "Processing Value" := Format(Date2DMY(Today, 3));
                'CURRENTYEAR_SHORT':
                    "Processing Value" := CopyStr(Format(Date2DMY(Today, 3)), 3, 2);
                'RECEIPT_TEXT':
                    PrintReceiptText(TemplateLine, RecID);
                //Date formatting
                'DATE_DAY':
                    "Processing Value" := PadLeft(Format(Date2DMY(ParseAsDate("Processing Value"), 1)), '0', 2);
                'DATE_MONTH':
                    "Processing Value" := PadLeft(Format(Date2DMY(ParseAsDate("Processing Value"), 2)), '0', 2);
                'DATE_YEAR':
                    "Processing Value" := Format(Date2DMY(ParseAsDate("Processing Value"), 3));
                'DATE_YEAR_SHORT':
                    "Processing Value" := CopyStr(Format(Date2DMY(ParseAsDate("Processing Value"), 3)), 3, 2);
                'FORMAT_MONTH_FROM_DATE':
                    "Processing Value" := FormatMonthFromDate(ParseAsDate("Processing Value"));
                'FORMAT_MONTH_FROM_DATETIME':
                    "Processing Value" := FormatMonthFromDatetime(ParseAsDateTime("Processing Value"));
                'NUMBER_NO_DECIMAL':
                    FormatNumberNoDecimal("Processing Value");
                'NUMBER_ONE_DECIMAL':
                    FormatNumberOneDecimal("Processing Value");
                'NUMBER_TWO_DECIMAL':
                    FormatNumberTwoDecimal("Processing Value");
                'NUMBER_SEPARATOR_TWO_DECIMAL':
                    FormatNumberSeparator("Processing Value");
                'NUMBER_SEPARATOR_ROUND':
                    FormatNumberSeperatorAndRound("Processing Value");
                'CIFFERCODE':
                    ApplyCipher("Processing Value", false);
                'CIPHERCODE_WITHDECIMALS':
                    ApplyCipher("Processing Value", true);
                'EXCHANGEDEADLINE':
                    ApplyExchangeDeadline("Processing Value");
                'NEGATE_DECIMAL':
                    NegateDecimal("Processing Value");
                'INT_TO_HEX':
                    "Processing Value" := IntToHex(ParseAsBigInteger("Processing Value"));
                'STRING_TO_HEX':
                    "Processing Value" := StringToHex("Processing Value");
                'OBFUSCATE_MI':
                    "Processing Value" := Format(MultiplicativeInverseEncode(ParseAsBigInteger("Processing Value")), 0, 9);
                'CALC_DATE':
                    "Processing Value" := CalculateDate("Processing Value", "Processing Function Parameter");
                'DECTOINT':
                    FormatNumberNoDecimal("Processing Value");
                'ROUNDTO1DECIMAL':
                    FormatNumberOneDecimal("Processing Value");
                'FORMAT_THOUSANDSEP':
                    FormatNumberSeparator("Processing Value");
                'DECTOINT_WITHSEP':
                    FormatNumberSeperatorAndRound("Processing Value");
                else
                    case true of
                        CopyStr("Processing Function ID", 1, 7) = 'CONVERT':
                            ApplyCurrencyConversion("Processing Value", "Processing Function ID");
                    end;
            end;
    end;
}

