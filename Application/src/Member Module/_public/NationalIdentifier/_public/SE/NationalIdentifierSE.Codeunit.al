codeunit 6150937 "NPR NationalIdentifier_SE"
{
    Access = Internal;

    var
        InvalidCheckDigit: Label 'Invalid check digit.';
        InvalidCharacter: Label 'Invalid characters in number.';
        InvalidSeparator: Label 'Invalid separator in number.';
        InvalidLength: Label 'Invalid length.';

    internal procedure TryParse_PNR(Input: Text; var Canonical: Text[30]; var ErrorMessage: Text): Boolean
    begin
        Clear(Canonical);
        Clear(ErrorMessage);

        if ParsePersonnummer(Input, Canonical) then
            exit(true);

        ErrorMessage := GetLastErrorText();
        exit(false);
    end;

    internal procedure TryParse_CNR(Input: Text; var Canonical: Text[30]; var ErrorMessage: Text): Boolean
    begin
        Clear(Canonical);
        Clear(ErrorMessage);

        if ParseSamordningsnummer(Input, Canonical) then
            exit(true);

        ErrorMessage := GetLastErrorText();
        exit(false);
    end;

    internal procedure TryParse_ONR(Input: Text; var Canonical: Text[30]; var ErrorMessage: Text): Boolean
    begin
        Clear(Canonical);
        Clear(ErrorMessage);

        if ParseOrganisationsnummer(Input, Canonical) then
            exit(true);

        ErrorMessage := GetLastErrorText();
        exit(false);
    end;

    internal procedure TryParse_VAT(Input: Text; var Canonical: Text[30]; var ErrorMessage: Text): Boolean
    begin
        Clear(Canonical);
        Clear(ErrorMessage);

        if ParseVatNumber(Input, Canonical) then
            exit(true);

        ErrorMessage := GetLastErrorText();
        exit(false);
    end;

    [TryFunction]
    local procedure ParsePersonnummer(Input: Text; var Canonical: Text[30])
    var
        CleanInput: Text;
        Length: Integer;
        DigitsToKeep: Label '0123456789', Locked = true;

        TextToRemove: Text;
        Year, Month, Day : Integer;
        CheckDate: Date;
    begin
        Input := DelChr(Input, '<=>', ' ');
        TextToRemove := DelChr(Input, '<=>', DigitsToKeep);
        CleanInput := DelChr(Input, '<=>', TextToRemove);

        if (StrLen(TextToRemove) > 1) then // allow one separator like hyphen
            Error(InvalidCharacter);

        if (StrLen(TextToRemove) = 1) and (TextToRemove <> '-') then
            Error(InvalidSeparator);

        Length := StrLen(CleanInput);
        if (not (Length = 12)) then
            Error(InvalidLength);

        Year := StrToInt(CopyStr(CleanInput, 1, 4));
        Month := StrToInt(CopyStr(CleanInput, 5, 2));
        Day := StrToInt(CopyStr(CleanInput, 7, 2));

        CheckDate := DMY2Date(Day, Month, Year); // Validate date

        if (not (CopyStr(CleanInput, Length, 1) = Format(CalcCheckDigit(CopyStr(CleanInput, 3, 9))))) then
            Error(InvalidCheckDigit);

#pragma warning disable AA0139
        Canonical := CleanInput;
#pragma warning restore AA0139
    end;

    [TryFunction]
    local procedure ParseSamordningsnummer(Input: Text; var Canonical: Text[30])
    var
        CleanInput: Text;
        Length: Integer;
        DigitsToKeep: Label '0123456789', Locked = true;
        CnrInvalidDayNumber: Label 'Invalid day. Day must be 61 or higher.';
        TextToRemove: Text;
        Year, Month, Day : Integer;
        CheckDate: Date;
    begin
        TextToRemove := DelChr(Input, '<=>', DigitsToKeep);
        CleanInput := DelChr(Input, '<=>', TextToRemove);

        if (StrLen(TextToRemove) > 1) then // allow one separator like hyphen
            Error(InvalidCharacter);

        if (StrLen(TextToRemove) = 1) and (TextToRemove <> '-') then
            Error(InvalidSeparator);

        Length := StrLen(CleanInput);
        if (not (Length = 12)) then
            Error(InvalidLength);

        Year := StrToInt(CopyStr(CleanInput, 1, 4));
        Month := StrToInt(CopyStr(CleanInput, 5, 2));
        Day := StrToInt(CopyStr(CleanInput, 7, 2));

        // Coordination number: day number is increased by 60
        if (Day < 61) then
            Error(CnrInvalidDayNumber);
        Day -= 60;
        CheckDate := DMY2Date(Day, Month, Year);

        if (not (CopyStr(CleanInput, Length, 1) = Format(CalcCheckDigit(CopyStr(CleanInput, 3, 9))))) then
            Error(InvalidCheckDigit);

#pragma warning disable AA0139
        Canonical := CleanInput;
#pragma warning restore AA0139

    end;

    [TryFunction]
    local procedure ParseOrganisationsnummer(Input: Text; var Canonical: Text[30])
    var
        CleanInput: Text;
        Length: Integer;
        DigitsToKeep: Label '0123456789', Locked = true;
        TextToRemove: Text;
        Month: Integer;
        InvalidMonthNumber: Label 'Invalid month number, must be 20 or higher.';
    begin
        TextToRemove := DelChr(Input, '<=>', DigitsToKeep);
        CleanInput := DelChr(Input, '<=>', TextToRemove);

        if (StrLen(TextToRemove) > 1) then // allow one separator like hyphen
            Error(InvalidCharacter);

        if (StrLen(TextToRemove) = 1) and (TextToRemove <> '-') then
            Error(InvalidSeparator);

        Length := StrLen(CleanInput);
        if (not (Length = 10)) then
            Error(InvalidLength);

        Month := StrToInt(CopyStr(CleanInput, 3, 2));

        // Organisationsnummer: month must be 20 or higher
        if (Month < 20) then
            Error(InvalidMonthNumber);

        if (not (CopyStr(CleanInput, Length, 1) = Format(CalcCheckDigit(CopyStr(CleanInput, 1, 9))))) then
            Error(InvalidCheckDigit);

#pragma warning disable AA0139
        Canonical := CleanInput;
#pragma warning restore AA0139

    end;

    [TryFunction]
    local procedure ParseVatNumber(Input: Text; var Canonical: Text[30])
    var
        SEVATNumberLength: Label 'Invalid SE VAT number length.';
        SEVATMustStartWith: Label 'SE VAT number must start with SE.';
    begin

        if (StrLen(Input) <> 14) then
            Error(SEVATNumberLength);

        if (CopyStr(Input, 1, 2) <> 'SE') then
            Error(SEVATMustStartWith);

        if (not ParseOrganisationsnummer(CopyStr(Input, 3, 10), Canonical)) then
            Error(GetLastErrorText());

#pragma warning disable AA0139
        Canonical := 'SE' + Canonical + '01';
#pragma warning restore AA0139

    end;

    // Swedish check digit is Luhn (mod 10) over the 9 digits YYMMDDNNN (century isn’t included). The 10th digit is the check digit.
    local procedure CalcCheckDigit(YYMMDDNNN: Text): Integer
    var
        i: Integer;
        d: Integer;
        sum: Integer;
        c: Char;
    begin

        if StrLen(YYMMDDNNN) <> 9 then
            Error('Expected 9 digits (YYMMDDNNN) in CalcCheckDigit.');

        sum := 0;

        for i := 1 to 9 do begin
            c := YYMMDDNNN[i];
            d := c - '0';

            // Luhn: double every other digit, starting with position 1
            if (i mod 2) = 1 then begin
                d := d * 2;
                if d >= 10 then
                    d := d - 9; // digit sum for 10..18
            end;

            sum += d;
        end;

        exit((10 - (sum mod 10)) mod 10);
    end;

    local procedure StrToInt(TextValue: Text) IntValue: Integer
    begin
        Evaluate(IntValue, TextValue);
    end;

}