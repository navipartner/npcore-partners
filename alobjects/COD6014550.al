codeunit 6014550 "RP Aux - Misc. Library"
{
    // NPR4.10/MMV/20150506 CASE 167059 New method DecToInt
    // NPR4.10/MMV/20150527 CASE 213523 Fixed method ApplyExchangeDeadline
    // NPR4.16/MMV/20151029 CASE 226091 Added function ID 'ROUNDTO1DECIMAL'
    // NPR5.23/JDH /20160513 CASE 240916 Removed old VariaX functionality
    // NPR5.26/MMV /20160905 CASE 251044 Added function ID 'FORMAT_THOUSANDSEP'.
    //                                   Removed VariaX.
    // NPR5.27/MMV /20161004 CASE 249733 Added function ID 'DECTOINT_WITHSEP';
    // NPR5.30/MMV /20170208 CASE 265858 Fixed ParseAsDecimal regional bug.
    // NPR5.32/MMV /20170501 CASE 241995 Retail Print 2.0
    // NPR5.38/MMV /20171108 CASE 295865 Added function ID 'CIPHERCODE_WITHDECIMALS'
    // NPR5.40/MMV /20180208 CASE 301032 Added function 'NEGATE_DECIMAL';
    // NPR5.40/MMV /20180208 CASE 304639 Removed non-functional 'VAT_BREAKDOWN'
    // NPR5.41/MMV /20180416 CASE 308701 Renamed number formatting functions for clarity.
    // NPR5.42/MMV /20180516 CASE 305852 Added more date functionality
    // NPR5.44/MMV /20180706 CASE 315362 Pull receipt text from specific register if possible.
    // NPR5.48/MITH/20181112 CASE 314067 Added auxiliary functions for date and datetime
    //                                   to return formatted month.
    // NPR5.48/MMV /20181206 CASE 327107 Added hex conversions
    // NPR5.49/TSA /20190218 CASE 342244 Added functions MultiplicativeInverseEncode() and MultiplicativeInverseDecode() to obfuscation of numbers (receipt number)


    trigger OnRun()
    begin
    end;

    procedure ApplyCipher(var "Proccesing Value": Text[30];HandleDecimals: Boolean) CifferCodeValue: Code[10]
    var
        RetailConfiguration: Record "Retail Setup";
        CifferCode: Code[10];
        Index: Integer;
        Itt: Integer;
    begin
        RetailConfiguration.Get;
        CifferCode := RetailConfiguration."Purchace Price Code";

        for Itt := 1 to StrLen("Proccesing Value") do begin
          if Evaluate(Index,Format("Proccesing Value"[Itt])) and (Format("Proccesing Value"[Itt]) <> '.') then begin
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

    procedure ApplyCurrencyConversion(var "Processing Value": Text[30];"Conversion String": Code[30])
    var
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        String: Codeunit "String Library";
        RoundingPrecision: Decimal;
        RoundingDirection: Text[1];
        CurrencyCode: Code[10];
        "Amount (LCY)": Decimal;
        "Amount (FCY)": Decimal;
        Multiplier: Decimal;
    begin
        String.Construct("Conversion String");
        CurrencyCode := String.SelectStringSep(2,' ');

        if String.CountOccurences(' ') > 1 then begin
          Evaluate(RoundingPrecision,CopyStr(String.SelectStringSep(3,' '),2));
          RoundingDirection := CopyStr(String.SelectStringSep(3,' '),1,1)
        end else begin
          RoundingPrecision := 0.1;
          RoundingDirection := '>'
        end;

        "Amount (LCY)"     := ParseAsDecimal("Processing Value");
        Multiplier         := CurrencyExchangeRate.ExchangeRate(Today,CurrencyCode);
        "Amount (FCY)"     := Round(Multiplier * "Amount (LCY)", RoundingPrecision, RoundingDirection);
        "Processing Value" := FormatDecimal("Amount (FCY)");
    end;

    procedure ApplyExchangeDeadline(var "Processing Value": Text[30])
    var
        RetailSetup: Record "Retail Setup";
        Date: Date;
    begin
        RetailSetup.Get();
        if Evaluate(Date, "Processing Value") then
          "Processing Value" := Format(CalcDate(RetailSetup."Exchange Label Exchange Period",Date));
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
          ProcessingValue := Format(ParseAsDecimal(ProcessingValue),0,'<Precision,1:1><Standard Format,2>');
    end;

    local procedure FormatNumberTwoDecimal(var ProcessingValue: Text)
    begin
        //-NPR5.41 [308701]
        if ProcessingValue <> '' then
          ProcessingValue := Format(ParseAsDecimal(ProcessingValue),0,'<Precision,2:2><Standard Format,2>');
        //+NPR5.41 [308701]
    end;

    procedure FormatNumberSeparator(var ProcessingValue: Text)
    begin
        if ProcessingValue <> '' then
          ProcessingValue := Format(ParseAsDecimal(ProcessingValue),0,'<Precision,2:2><Standard Format,0>');
    end;

    procedure FormatNumberSeperatorAndRound(var ProcessingValue: Text)
    begin
        if ProcessingValue <> '' then
        //-NPR5.41 [308701]
        //  ProcessingValue := FORMAT(ParseAsDecimal(ProcessingValue),0,'<Precision,0:2><Standard Format,0>');
          ProcessingValue := Format(ParseAsDecimal(ProcessingValue),0,'<Precision,0:5><Standard Format,0>');
        //+NPR5.41 [308701]
    end;

    local procedure NegateDecimal(var ProcessingValue: Text)
    var
        Decimal: Decimal;
    begin
        //-NPR5.40 [301032]
        if ProcessingValue <> '' then
          ProcessingValue := Format(ParseAsDecimal(ProcessingValue) * -1);
        //+NPR5.40 [301032]
    end;

    local procedure PrintReceiptText(var TemplateLine: Record "RP Template Line";RecordID: RecordID)
    var
        LinePrintMgt: Codeunit "RP Line Print Mgt.";
        Utility: Codeunit Utility;
        tmpRetailComment: Record "Retail Comment" temporary;
        RetailFormCode: Codeunit "Retail Form Code";
        Register: Record Register;
        RecRef: RecordRef;
        AuditRoll: Record "Audit Roll";
        POSEntry: Record "POS Entry";
    begin
        //-NPR5.44 [315362]
        //Register.GET(RetailFormCode.FetchRegisterNumber());
        case RecordID.TableNo of
          DATABASE::"Audit Roll" :
            begin
              RecRef := RecordID.GetRecord();
              RecRef.SetTable(AuditRoll);
              AuditRoll.Find;
              Register.Get(AuditRoll."Register No.");
            end;
          DATABASE::"POS Entry" :
            begin
              RecRef := RecordID.GetRecord();
              RecRef.SetTable(POSEntry);
              POSEntry.Find;
              Register.Get(POSEntry."POS Unit No.");
            end;
          else
            Register.Get(RetailFormCode.FetchRegisterNumber());
        end;
        //+NPR5.44 [315362]

        Utility.GetTicketText(tmpRetailComment, Register);

        LinePrintMgt.SetFont(TemplateLine."Type Option");
        if tmpRetailComment.FindSet then repeat
          LinePrintMgt.AddTextField(1, TemplateLine.Align, tmpRetailComment.Comment);
        until tmpRetailComment.Next = 0;
    end;

    procedure FormatMonthFromDate(ProcessingDate: Date) FormattedMonth: Text
    begin
        //-NPR5.48 [314067]
        if ProcessingDate <> 0D then
          exit(Format(ProcessingDate,0,'<Month Text>'));
        //+NPR5.48 [314067]
    end;

    procedure FormatMonthFromDatetime(ProcessingDateTime: DateTime) FormattedMonth: Text
    var
        tmpProcessingDate: Date;
    begin
        //-NPR5.48 [314067]
        if ProcessingDateTime <> 0DT then begin
          tmpProcessingDate := DT2Date(ProcessingDateTime);
          exit(Format(tmpProcessingDate,0,'<Month Text>'));
        end;
        //+NPR5.48 [314067]
    end;

    procedure IntToHex(BigInt: BigInteger): Text
    var
        IntPtr: DotNet IntPtr;
    begin
        //-NPR5.48 [327107]
        IntPtr := IntPtr.IntPtr(BigInt);
        exit(IntPtr.ToString('X'));
        //+NPR5.48 [327107]
    end;

    procedure StringToHex(Text: Text): Text
    var
        Encoding: DotNet Encoding;
        ByteArray: DotNet Array;
        BitConverter: DotNet BitConverter;
        Regex: DotNet Regex;
    begin
        //-NPR5.48 [327107]
        exit(Regex.Replace(BitConverter.ToString(Encoding.Unicode.GetBytes(Text)), '-', ''));
        //+NPR5.48 [327107]
    end;

    procedure MultiplicativeInverseEncode(plain: Integer) encoded: BigInteger
    var
        m: BigInteger;
        x: BigInteger;
    begin

        //-NPR5.49 [342244]
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

        //+NPR5.49 [342244]
    end;

    procedure MultiplicativeInverseDecode(encoded: BigInteger) plain: Integer
    var
        m: BigInteger;
        y: BigInteger;
    begin

        //-NPR5.49 [342244]
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

        //+NPR5.49 [342244]
    end;

    procedure "// Locals"()
    begin
    end;

    local procedure ParseAsDecimal(Value: Text[30]) DecimalValue: Decimal
    begin
        Evaluate(DecimalValue,Value,9);
    end;

    local procedure ParseAsDate(Value: Text) DateValue: Date
    begin
        //-NPR5.42 [305852]
        Evaluate(DateValue,Value);
        //+NPR5.42 [305852]
    end;

    local procedure ParseAsDateTime(Value: Text) DateTimeValue: DateTime
    begin
        //-NPR5.48 [314067]
        Evaluate(DateTimeValue,Value);
        //+NPR5.48 [314067]
    end;

    local procedure ParseAsBigInteger(Value: Text) BigIntValue: BigInteger
    begin
        //-NPR5.48 [327107]
        Evaluate(BigIntValue, Value);
        //+NPR5.48 [327107]
    end;

    local procedure FormatDecimal(DecimalValue: Decimal): Text
    begin
        exit(Format(DecimalValue,0,'<Precision,2:2><Standard Format,2>'));
    end;

    local procedure AddFunction(var tmpRetailList: Record "Retail List" temporary;Choice: Text)
    begin
        tmpRetailList.Number += 1;
        tmpRetailList.Choice := Choice;
        tmpRetailList.Insert;
    end;

    local procedure PadLeft(Value: Text;PadChar: Text;Length: Integer): Text
    var
        ValueLength: Integer;
    begin
        //-NPR5.42 [305852]
        ValueLength := StrLen(Value);

        if ValueLength >= Length then
          exit(Value);

        exit(PadStr('', Length-ValueLength, PadChar) + Value);
        //+NPR5.42 [305852]
    end;

    local procedure "// Event Subscribers"()
    begin
    end;

    [EventSubscriber(ObjectType::Table, 6014445, 'OnBuildFunctionCodeunitList', '', false, false)]
    local procedure OnBuildFunctionCodeunitList(var tmpAllObj: Record AllObj temporary)
    var
        AllObj: Record AllObj;
    begin
        AllObj.Get(AllObj."Object Type"::Codeunit, CODEUNIT::"RP Aux - Misc. Library");
        tmpAllObj.Init;
        tmpAllObj := AllObj;
        tmpAllObj.Insert;
    end;

    [EventSubscriber(ObjectType::Table, 6014445, 'OnBuildFunctionList', '', false, false)]
    local procedure OnBuildFunctionList(CodeunitID: Integer;var tmpRetailList: Record "Retail List" temporary)
    begin
        if CodeunitID <> CODEUNIT::"RP Aux - Misc. Library" then
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
        //-NPR5.41 [308701]
        // AddFunction(tmpRetailList, 'DECTOINT');
        // AddFunction(tmpRetailList, 'DECTOINT_WITHSEP');
        // AddFunction(tmpRetailList, 'ROUNDTO1DECIMAL');
        // AddFunction(tmpRetailList, 'FORMAT_THOUSANDSEP');

        AddFunction(tmpRetailList, 'NUMBER_NO_DECIMAL');
        AddFunction(tmpRetailList, 'NUMBER_ONE_DECIMAL');
        AddFunction(tmpRetailList, 'NUMBER_TWO_DECIMAL');
        AddFunction(tmpRetailList, 'NUMBER_SEPARATOR_TWO_DECIMAL');
        AddFunction(tmpRetailList, 'NUMBER_SEPARATOR_ROUND');
        //+NPR5.41 [308701]

        //-NPR5.42 [305852]
        AddFunction(tmpRetailList, 'CURRENTDAY');
        AddFunction(tmpRetailList, 'CURRENTMONTH');
        AddFunction(tmpRetailList, 'CURRENTYEAR');
        AddFunction(tmpRetailList, 'CURRENTYEAR_SHORT');
        AddFunction(tmpRetailList, 'DATE_DAY');
        AddFunction(tmpRetailList, 'DATE_MONTH');
        AddFunction(tmpRetailList, 'DATE_YEAR');
        AddFunction(tmpRetailList, 'DATE_YEAR_SHORT');
        //+NPR5.42 [305852]

        //-NPR5.48 [314067]
        AddFunction(tmpRetailList, 'FORMAT_MONTH_FROM_DATE');
        AddFunction(tmpRetailList, 'FORMAT_MONTH_FROM_DATETIME');
        //+NPR5.48 [314067]

        //-NPR5.48 [327107]
        AddFunction(tmpRetailList, 'INT_TO_HEX');
        AddFunction(tmpRetailList, 'STRING_TO_HEX');
        //+NPR5.48 [327107]

        //-NPR5.49 [342244]
        AddFunction(tmpRetailList, 'OBFUSCATE_MI');
        //+NPR5.49 [342244]
    end;

    [EventSubscriber(ObjectType::Table, 6014445, 'OnFunction', '', false, false)]
    local procedure OnFunction(CodeunitID: Integer;FunctionName: Text;var TemplateLine: Record "RP Template Line";RecID: RecordID;var Skip: Boolean;var Handled: Boolean)
    begin
        if CodeunitID <> CODEUNIT::"RP Aux - Misc. Library" then
          exit;

        Handled := true;

        with TemplateLine do
          case FunctionName of
            //Constants
            'CURRENTDATETIME' : "Processing Value" := Format(CurrentDateTime);
            'CURRENTDATE' : "Processing Value" := Format(Today);
            'CURRENTTIME' : "Processing Value" := Format(Time);
            //-NPR5.42 [305852]
            'CURRENTDAY' : "Processing Value" := PadLeft(Format(Date2DMY(Today, 1)), '0', 2);
            'CURRENTMONTH' : "Processing Value" := PadLeft(Format(Date2DMY(Today, 2)), '0', 2);
            'CURRENTYEAR' : "Processing Value" := Format(Date2DMY(Today, 3));
            'CURRENTYEAR_SHORT' : "Processing Value" := CopyStr(Format(Date2DMY(Today, 3)), 3, 2);
            //+NPR5.42 [305852]

            //Custom sections
            //-NPR5.44 [315362]
            //'RECEIPT_TEXT' : PrintReceiptText(TemplateLine);
            'RECEIPT_TEXT' : PrintReceiptText(TemplateLine, RecID);
            //+NPR5.44 [315362]

            //-NPR5.42 [305852]
            //Date formatting
            'DATE_DAY' : "Processing Value" := PadLeft(Format(Date2DMY(ParseAsDate("Processing Value"),1)), '0', 2);
            'DATE_MONTH' : "Processing Value" := PadLeft(Format(Date2DMY(ParseAsDate("Processing Value"),2)), '0', 2);
            'DATE_YEAR' : "Processing Value" := Format(Date2DMY(ParseAsDate("Processing Value"), 3));
            'DATE_YEAR_SHORT' : "Processing Value" := CopyStr(Format(Date2DMY(ParseAsDate("Processing Value"), 3)), 3, 2);
            //+NPR5.42 [305852]
            //-NPR5.48 [314067]
            'FORMAT_MONTH_FROM_DATE' : "Processing Value" := FormatMonthFromDate(ParseAsDate("Processing Value"));
            'FORMAT_MONTH_FROM_DATETIME' : "Processing Value" := FormatMonthFromDatetime(ParseAsDateTime("Processing Value"));
            //+NPR5.48 [314067]

            //Number formatting
            //-NPR5.41 [308701]
            'NUMBER_NO_DECIMAL' : FormatNumberNoDecimal("Processing Value");
            'NUMBER_ONE_DECIMAL' : FormatNumberOneDecimal("Processing Value");
            'NUMBER_TWO_DECIMAL' : FormatNumberTwoDecimal("Processing Value");
            'NUMBER_SEPARATOR_TWO_DECIMAL' : FormatNumberSeparator("Processing Value");
            'NUMBER_SEPARATOR_ROUND' : FormatNumberSeperatorAndRound("Processing Value");
            //+NPR5.41 [308701]

            //Conversions
            'CIFFERCODE'      : ApplyCipher("Processing Value", false);
            'CIPHERCODE_WITHDECIMALS' : ApplyCipher("Processing Value", true);
            'EXCHANGEDEADLINE': ApplyExchangeDeadline("Processing Value");
            'NEGATE_DECIMAL' : NegateDecimal("Processing Value");
        //-NPR5.48 [327107]
            'INT_TO_HEX' : "Processing Value" := IntToHex(ParseAsBigInteger("Processing Value"));
            'STRING_TO_HEX' : "Processing Value" := StringToHex("Processing Value");
        //+NPR5.48 [327107]

            //-NPR5.49 [342244]
            'OBFUSCATE_MI' : "Processing Value" := Format ( MultiplicativeInverseEncode (ParseAsBigInteger ("Processing Value")), 0, 9);
            //+NPR5.49 [342244]

            //Legacy syntax (can no longer be selected on the list)
            'DECTOINT'        : FormatNumberNoDecimal("Processing Value");
            'ROUNDTO1DECIMAL' : FormatNumberOneDecimal("Processing Value");
            'FORMAT_THOUSANDSEP' : FormatNumberSeparator("Processing Value");
            'DECTOINT_WITHSEP' : FormatNumberSeperatorAndRound("Processing Value");

            else case true of
              CopyStr("Processing Function ID",1,7) = 'CONVERT' :
                ApplyCurrencyConversion("Processing Value","Processing Function ID");
            end;
          end;
    end;
}

