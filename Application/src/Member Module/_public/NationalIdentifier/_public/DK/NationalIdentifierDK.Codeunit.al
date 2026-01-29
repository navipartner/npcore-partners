codeunit 6150941 "NPR NationalIdentifier_DK"
{
    Access = Internal;
    internal procedure TryParse_CPR(Input: Text; var Canonical: Text[30]; Mod11Check: Boolean; var ErrorMessage: Text): Boolean;
    begin
        Clear(Canonical);
        Clear(ErrorMessage);

        if (ParseCprNumber(Input, Canonical, Mod11Check)) then
            exit(true);

        ErrorMessage := GetLastErrorText();
        exit(false);

    end;

    internal procedure TryParse_CVR(Input: Text; var Canonical: Text[30]; var ErrorMessage: Text): Boolean;
    begin
        Clear(Canonical);
        Clear(ErrorMessage);

        if (ParseCvrNumber(Input, Canonical)) then
            exit(true);

        ErrorMessage := GetLastErrorText();
        exit(false);
    end;

    internal procedure TryParse_VAT(Input: Text; var Canonical: Text[30]; var ErrorMessage: Text): Boolean;
    begin
        Clear(Canonical);
        Clear(ErrorMessage);

        if (ParseVatNumber(Input, Canonical)) then
            exit(true);

        ErrorMessage := GetLastErrorText();
        exit(false);
    end;

    [TryFunction]
    local procedure ParseCprNumber(Input: Text; var Canonical: Text[30]; EnforceMod11: Boolean)
    var
        Clean: Text;
        NonDigits: Text;
        DigitsToKeep: Label '0123456789', Locked = true;

        InvalidCharacter: Label 'Invalid characters in CPR.';
        InvalidSeparator: Label 'Invalid separator in CPR.';
        InvalidLength10: Label 'Invalid CPR length. Expected 10 digits.';
        InvalidChecksum: Label 'Invalid CPR modulus-11 checksum.';
        InvalidCentury: Label 'Cannot determine century from CPR number.';
        InvalidDate: Label 'Invalid date in CPR.';

        Day: Integer;
        Month: Integer;
        YY: Integer;
        Year4: Integer;
        Serial4: Integer;
        Weight: Text[10];
        CheckDate: Date;
    begin
        // Normalize input (allow spaces)
        Input := DelChr(Input, '<=>', ' ');

        // Allow at most one separator '-' and otherwise only digits
        NonDigits := DelChr(Input, '<=>', DigitsToKeep);

        if StrLen(NonDigits) > 1 then
            Error(InvalidCharacter);

        if (NonDigits <> '') and (NonDigits <> '-') then
            Error(InvalidSeparator);

        // Digits-only canonical: DDMMYYSSSS
        Clean := DelChr(Input, '<=>', NonDigits);
        if StrLen(Clean) <> 10 then
            Error(InvalidLength10);

        Day := StrToInt(CopyStr(Clean, 1, 2));
        Month := StrToInt(CopyStr(Clean, 3, 2));
        YY := StrToInt(CopyStr(Clean, 5, 2));
        Serial4 := StrToInt(CopyStr(Clean, 7, 4));

        // Determine century/year from CPR rules (YY + Serial range)
        Year4 := DetermineCprYear(YY, Serial4);
        if (Year4 = 0) then
            Error(InvalidCentury);

        // Validate real calendar date
        if (not TryMakeDate(Day, Month, Year4, CheckDate)) then
            Error(InvalidDate);

        // Optional: modulus-11 control (not mandatory for all CPR post-2007)
        if (EnforceMod11) then begin
            Weight := '4327654321';
            if (StrCheckSum(Clean, Weight, 11) <> 0) then
                Error(InvalidChecksum);
        end;

#pragma warning disable AA0139
        Canonical := Clean;
#pragma warning restore AA0139
    end;

    [TryFunction]
    local procedure ParseCvrNumber(Input: Text; var Canonical: Text[30])
    var
        Clean: Text;
        NonDigits: Text;
        DigitsToKeep: Label '0123456789', Locked = true;
        InvalidCvrCharacters: Label 'Invalid characters in CVR.';
        InvalidLength: Label 'Invalid CVR length. Expected 8 digits.';
        InvalidCvr: Label 'Invalid CVR (modulus 11 yields 10).';
        InvalidCheckDigit: Label 'Invalid CVR check digit.';
        Weights7: Text[7];
        Expected: Integer;
        Provided: Integer;
    begin
        // Keep digits only (canonical)
        NonDigits := DelChr(Input, '<=>', DigitsToKeep);
        NonDigits := DelChr(NonDigits, '<=>', ' '); // allow spaces
        if (StrLen(NonDigits) > 0) then
            Error(InvalidCvrCharacters);

        Clean := DelChr(Input, '<=>', NonDigits);
        if (StrLen(Clean) <> 8) then
            Error(InvalidLength);

        // Mod-11 check digit using StrCheckSum over first 7 digits.
        // CVR weights: 2,7,6,5,4,3,2,1  => for first 7 digits: 2,7,6,5,4,3,2
        Weights7 := '2765432';
        Expected := StrCheckSum(CopyStr(Clean, 1, 7), Weights7, 11);
        if (Expected = 10) then
            Error(InvalidCvr);

        Provided := StrToInt(CopyStr(Clean, 8, 1));
        if (Provided <> Expected) then
            Error(InvalidCheckDigit);

#pragma warning disable AA0139
        Canonical := Clean;
#pragma warning restore AA0139
    end;

    [TryFunction]
    local procedure ParseVatNumber(Input: Text; var Canonical: Text[30])
    var
        DkVatInvalid: Label 'Invalid DK VAT number format. Must start with ''DK''.';
    begin
        // Expected format: DKNNNNNNNN (DK + CVR number)
        if (CopyStr(Input, 1, 2) <> 'DK') then
            Error(DkVatInvalid);

        ParseCvrNumber(CopyStr(Input, 3), Canonical);

#pragma warning disable AA0139
        Canonical := 'DK' + Canonical;
#pragma warning restore AA0139
    end;

    local procedure DetermineCprYear(YY: Integer; Serial4: Integer): Integer
    begin
        // Serial ranges decide the century (per CPR rules)
        // 0001-3999  -> 1900-1999
        if (Serial4 >= 1) and (Serial4 <= 3999) then
            exit(1900 + YY);

        // 4000-4999 -> 2000-2036 if YY 00-36, else 1937-1999
        if (Serial4 >= 4000) and (Serial4 <= 4999) then begin
            if (YY <= 36) then
                exit(2000 + YY)
            else
                exit(1900 + YY); // 37-99
        end;

        // 5000-8999 -> 2000-2057 if YY 00-57, else 1858-1899
        if (Serial4 >= 5000) and (Serial4 <= 8999) then begin
            if (YY <= 57) then
                exit(2000 + YY)
            else
                exit(1800 + YY); // 58-99
        end;

        // 9000-9999 -> 2000-2036 if YY 00-36, else 1937-1999
        if (Serial4 >= 9000) and (Serial4 <= 9999) then begin
            if (YY <= 36) then
                exit(2000 + YY)
            else
                exit(1900 + YY); // 37-99
        end;

        exit(0);
    end;

    [TryFunction]
    local procedure TryMakeDate(Day: Integer; Month: Integer; Year4: Integer; var D: Date)
    begin
        D := DMY2Date(Day, Month, Year4);
    end;

    local procedure StrToInt(TextValue: Text) IntValue: Integer
    begin
        Evaluate(IntValue, TextValue);
    end;

}