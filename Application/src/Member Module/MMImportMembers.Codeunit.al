codeunit 6060132 "NPR MM Import Members"
{

    // #xxx/TSA /20180316 CASE xxx Added iComm setup warning

    trigger OnRun()
    var
        FileManagement: Codeunit "File Management";
        SuggestFileName: Text[1024];
        FileName: Text[1024];
        Serverfilename: Text;
        Member: Record "NPR MM Member";
    begin

        if GuiAllowed then begin
            SuggestFileName := '';
            FileName := FileManagement.OpenFileDialog(SELECT_FILE_CAPTION, SuggestFileName, FILE_FILTER);

            if (SuggestFileName = FileName) then
                Error('');

            Serverfilename := FileManagement.UploadFileSilent(FileName);
            SetFileName(Serverfilename);

        end;

        Import;
    end;

    var
        GFileName: Text[250];
        GMessage: Text[250];
        GMemberInfo: Record "NPR MM Member Info Capture";
        GInvalidMemberCount: Integer;
        GValidMemberCount: Integer;
        GMembershipEntryNo1: Integer;
        GDateMask: Code[20];
        GLineCount: Integer;
        REQUIRED: Integer;
        OPTIONAL: Integer;
        "--Convert": Integer;
        AsciiStr: Text[250];
        AnsiStr: Text[250];
        InternalVars: Boolean;
        CharVar: array[32] of Char;
        "--FileFields": Integer;
        FldMemberNo: Text;
        FldFirstName: Text;
        FldMiddleName: Text;
        FldLastName: Text;
        FldPhone: Text;
        FldSSN: Text;
        FldAddress: Text;
        FldPostCode: Text;
        FldCity: Text;
        FldCountryCode: Text;
        FldCountry: Text;
        FldGender: Text;
        FldBirthDate: Text;
        FldEmail: Text;
        FldNotificationMethod: Text;
        FldNewsLetter: Text;
        FldPictureB64: Text;
        FldExternalMembershipNo: Text;
        FldPurchaseDate: Text;
        FldValidFromDate: Text;
        FldValidUntilDate: Text;
        FldRole: Text;
        FldNAVMembershipCode: Text;
        FldLoyaltyPoints: Text;
        FldExternalCardNo: Text;
        FldExternalCardNoValidUntilDate: Text;
        INVALID_VALUE: Label 'The value %1 specified for %2 on line %3 is not valid.';
        INVALID_LENGTH: Label 'The length of %1 exceeds the max length of %2 for %3 on line %4.';
        VALUE_REQUIRED: Label 'A value is required for field %1 on line %2.';
        INVALID_DATE: Label 'The date %1 specified for field %2 on line %3 does not conform to the expected date format %4.';
        UNSUCCESSFULL_IMPORT: Label 'Some of the import lines did not result in successfull member creation. Do you want to view the list?';
        IMPORT_MESSAGE_DIALOG: Label 'Importing :\#1#######################################################';
        PROCESS_INFO: Label 'Processing: (%1) %2 %3';
        SUCCESS_MSG: Label '%1 members imported successfully.';
        FILE_FILTER: Label 'CSV Files (*.csv)|*.csv|All Files (*.*)|*.*';
        SELECT_FILE_CAPTION: Label 'Member Import';
        NOT_IMPLEMENTED: Label 'Support for %1 %2 is not implemented.';
        DATE_MASK_ERROR: Label 'Date format mask %1 is not supported.';

    procedure SetFileName(PFileName: Text[250])
    begin
        GFileName := PFileName;
    end;

    procedure Import()
    var
        TxtFile: File;
        IStream: InStream;
        Fileline: Text;
        Window: Dialog;
        RunMode: Integer;
        LowEntryNo: Integer;
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MemberInfoCapturePage: Page "NPR MM Member Info Capture";
        IComm: Record "NPR I-Comm";
        SMSSetup: Record "NPR SMS Setup";
    begin

        // xxx
        if IComm.Get() then
            if IComm."Use Auto. Cust. Lookup" then
                if not Confirm('Warning: %1 is setup and may interfer with customer creation when importing members. Has the %1 been configured correctly?', false, IComm.TableCaption()) then
                    Error('');

        REQUIRED := 1;
        OPTIONAL := 2;
        GDateMask := 'YYYYMMDD'; // Should be setup or parameter

        TxtFile.TextMode(true);
        TxtFile.Open(GFileName);
        TxtFile.CreateInStream(IStream);

        MemberInfoCapture.SetFilter("Originates From File Import", '=%1', true);
        if (MemberInfoCapture.FindLast()) then;
        LowEntryNo := MemberInfoCapture."Entry No." + 1;

        RunMode := 1;

        if GuiAllowed then
            Window.Open(IMPORT_MESSAGE_DIALOG);

        while (not IStream.EOS) do begin

            if (IStream.ReadText(Fileline) > 0) then begin
                Fileline := Ansi2Ascii(Fileline);

                // UTF-8 files start with some bytes identifying the format, get rid of those bytes
                //IF (lineCount = 1) THEN WHILE (fileline[1] <> '"') DO fileline := COPYSTR (fileline, 2);

                decodeLine(Fileline);
                if GuiAllowed then
                    if ((GLineCount mod 50) = 0) then Window.Update(1, StrSubstNo(PROCESS_INFO, GLineCount, FldFirstName, FldLastName));

                GLineCount += 1;

                if (GLineCount <> 1) then begin
                    if (isValidMember() and (RunMode = 1)) then
                        insertMember(GMemberInfo."Entry No.");
                end;

            end;

            // break
            // IF lineCount > 35 THEN EXIT;

        end;

        TxtFile.Close();
        if GuiAllowed then
            Window.Close();

        //IF (runmode = 2) THEN
        //  ERROR ('Import was run in test mode, nothing has been imported.');

        MemberInfoCapture.Reset();
        MemberInfoCapture.SetFilter("Originates From File Import", '=%1', true);
        MemberInfoCapture.SetFilter("Entry No.", '%1..', LowEntryNo);
        if (MemberInfoCapture.Count() > 0) then begin
            if (GuiAllowed) then begin
                if (Confirm(UNSUCCESSFULL_IMPORT, true)) then begin
                    MemberInfoCapturePage.SetTableView(MemberInfoCapture);
                    MemberInfoCapturePage.SetShowImportAction();
                    MemberInfoCapturePage.Run();
                end;
            end;
        end else begin
            Message(SUCCESS_MSG, GLineCount - 1);
        end;
    end;

    local procedure decodeLine(PLine: Text)
    begin

        // -- member
        FldMemberNo := nextField(PLine);
        FldFirstName := nextField(PLine);
        FldMiddleName := nextField(PLine);
        FldLastName := nextField(PLine);
        FldPhone := nextField(PLine);
        FldSSN := nextField(PLine);
        FldAddress := nextField(PLine);
        FldPostCode := nextField(PLine);
        FldCountryCode := nextField(PLine);
        FldCountry := nextField(PLine);
        FldGender := nextField(PLine);
        FldBirthDate := nextField(PLine);
        FldEmail := LowerCase(nextField(PLine));
        FldNotificationMethod := nextField(PLine);
        FldNewsLetter := nextField(PLine);
        FldPictureB64 := nextField(PLine);

        // -- membership
        FldExternalMembershipNo := nextField(PLine);
        FldPurchaseDate := nextField(PLine);
        FldValidFromDate := nextField(PLine);
        FldValidUntilDate := nextField(PLine);
        FldRole := nextField(PLine);
        FldNAVMembershipCode := nextField(PLine);
        FldLoyaltyPoints := nextField(PLine);

        // -- card
        FldExternalCardNo := nextField(PLine);
        FldExternalCardNoValidUntilDate := nextField(PLine);
    end;

    local procedure isValidMember() isValid: Boolean
    var
        Member: Record "NPR MM Member";
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        MembershipSetup: Record "NPR MM Membership Setup";
        Community: Record "NPR MM Member Community";
    begin

        Clear(GMemberInfo);

        GMemberInfo."External Member No" := validateTextField(FldMemberNo, MaxStrLen(GMemberInfo."External Member No"), REQUIRED, GMemberInfo.FieldCaption("External Member No"));

        GMemberInfo."First Name" := validateTextField(FldFirstName, MaxStrLen(GMemberInfo."First Name"), REQUIRED, GMemberInfo.FieldCaption("First Name"));
        GMemberInfo."Middle Name" := validateTextField(FldMiddleName, MaxStrLen(GMemberInfo."Middle Name"), OPTIONAL, GMemberInfo.FieldCaption("Middle Name"));
        GMemberInfo."Last Name" := validateTextField(FldLastName, MaxStrLen(GMemberInfo."Last Name"), REQUIRED, GMemberInfo.FieldCaption("Last Name"));

        GMemberInfo."Phone No." := validateTextField(FldPhone, MaxStrLen(GMemberInfo."Phone No."), OPTIONAL, GMemberInfo.FieldCaption("Phone No."));
        GMemberInfo."Social Security No." := validateTextField(FldSSN, MaxStrLen(GMemberInfo."Social Security No."), OPTIONAL, GMemberInfo.FieldCaption("Social Security No."));
        GMemberInfo.Address := validateTextField(FldAddress, MaxStrLen(GMemberInfo.Address), OPTIONAL, GMemberInfo.FieldCaption(Address));
        GMemberInfo."Country Code" := validateTextField(FldCountryCode, MaxStrLen(GMemberInfo."Country Code"), OPTIONAL, GMemberInfo.FieldCaption("Country Code"));
        GMemberInfo.Validate("Post Code Code", validateTextField(FldPostCode, MaxStrLen(GMemberInfo."Post Code Code"), OPTIONAL, GMemberInfo.FieldCaption("Post Code Code")));
        GMemberInfo.Country := validateTextField(FldCountry, MaxStrLen(GMemberInfo.Country), OPTIONAL, GMemberInfo.FieldCaption(Country));

        case LowerCase(FldGender) of
            '':
                GMemberInfo.Gender := GMemberInfo.Gender::NOT_SPECIFIED;
            'k', 'female':
                GMemberInfo.Gender := GMemberInfo.Gender::FEMALE;
            'm', 'male':
                GMemberInfo.Gender := GMemberInfo.Gender::MALE;
            else
                GMemberInfo.Gender := GMemberInfo.Gender::OTHER;
        end;
        GMemberInfo.Birthday := validateDateField(FldBirthDate, GDateMask, OPTIONAL, GMemberInfo.FieldCaption(Birthday));

        GMemberInfo."E-Mail Address" := FldEmail;
        case LowerCase(FldNotificationMethod) of
            'email':
                GMemberInfo."Notification Method" := GMemberInfo."Notification Method"::EMAIL;
            'manual':
                GMemberInfo."Notification Method" := GMemberInfo."Notification Method"::MANUAL;
            'sms':
                GMemberInfo."Notification Method" := GMemberInfo."Notification Method"::SMS;
            else
                GMemberInfo."Notification Method" := GMemberInfo."Notification Method"::NO_THANKYOU;
        end;
        case LowerCase(FldNewsLetter) of
            'no':
                GMemberInfo."News Letter" := GMemberInfo."News Letter"::NO;
            'yes':
                GMemberInfo."News Letter" := GMemberInfo."News Letter"::YES;
            else
                GMemberInfo."Notification Method" := GMemberInfo."Notification Method"::NO_THANKYOU;
        end;

        // -- Membership

        //GMemberInfo."External Membership No." := validateTextField (GMemberInfo."External Membership No.", MAXSTRLEN (GMemberInfo."External Membership No."), OPTIONAL, GMemberInfo.FIELDCAPTION ("External Membership No."));
        GMemberInfo."External Membership No." := validateTextField(FldExternalMembershipNo, MaxStrLen(GMemberInfo."External Membership No."), OPTIONAL, GMemberInfo.FieldCaption("External Membership No."));

        // fldRole
        GMemberInfo."Membership Code" := validateTextField(FldNAVMembershipCode, MaxStrLen(GMemberInfo."Membership Code"), REQUIRED, GMemberInfo.FieldCaption("Membership Code"));

        MembershipSalesSetup.SetFilter("Business Flow Type", '=%1', MembershipSalesSetup."Business Flow Type"::MEMBERSHIP);

        MembershipSalesSetup.SetFilter("Membership Code", '=%1', GMemberInfo."Membership Code");
        if not (MembershipSalesSetup.FindFirst()) then
            Error(INVALID_VALUE, GMemberInfo."Membership Code", GMemberInfo.FieldCaption("Membership Code"), GLineCount);

        GMemberInfo."Item No." := MembershipSalesSetup."No.";

        // fldValidFromDate
        // fldValidUntilDate
        if (FldPurchaseDate = '') then begin
            if ((FldValidFromDate = '') and (FldValidUntilDate = '')) then
                validateDateField(FldPurchaseDate, GDateMask, REQUIRED, GMemberInfo.FieldCaption("Document Date"));

            if (FldValidFromDate <> '') then begin
                GMemberInfo."Document Date" := validateDateField(FldValidFromDate, GDateMask, REQUIRED, GMemberInfo.FieldCaption("Document Date"));
            end else begin
                GMemberInfo."Document Date" := validateDateField(FldValidUntilDate, GDateMask, REQUIRED, GMemberInfo.FieldCaption("Document Date"));
                GMemberInfo."Document Date" := GMemberInfo."Document Date" - (CalcDate(MembershipSalesSetup."Duration Formula", Today) - Today);
            end;

        end else begin
            GMemberInfo."Document Date" := validateDateField(FldPurchaseDate, GDateMask, REQUIRED, GMemberInfo.FieldCaption("Document Date"));
        end;

        GMemberInfo."Initial Loyalty Point Count" := validateIntegerField(FldLoyaltyPoints, OPTIONAL, GMemberInfo.FieldCaption("Initial Loyalty Point Count"));

        // -- Card
        GMemberInfo."External Card No." := validateTextField(FldExternalCardNo, MaxStrLen(GMemberInfo."External Card No."), OPTIONAL, GMemberInfo.FieldCaption("External Card No."));
        GMemberInfo."Valid Until" := validateDateField(FldExternalCardNoValidUntilDate, GDateMask, OPTIONAL, GMemberInfo.FieldCaption("Valid Until"));

        GMemberInfo."Originates From File Import" := true;
        GMemberInfo.Insert();

        if (StrLen(FldFirstName + FldLastName) = 0) then exit(false);
        if (GMemberInfo."Item No." = '') then exit(false);

        MembershipSetup.Get(MembershipSalesSetup."Membership Code");
        Community.Get(MembershipSetup."Community Code");

        Member.Reset();
        case Community."Member Unique Identity" of
            Community."Member Unique Identity"::NONE:
                if (FldMemberNo <> '') then begin
                    Member.SetFilter("External Member No.", '=%1', FldMemberNo);
                end else begin
                    exit(true);
                end;

            Community."Member Unique Identity"::EMAIL:
                if (FldEmail <> '') then begin
                    Member.SetFilter("E-Mail Address", '=%1', FldEmail);
                end else begin
                    exit(false);
                end;

            Community."Member Unique Identity"::PHONENO:
                if (FldPhone <> '') then begin
                    Member.SetFilter("Phone No.", '=%1', FldPhone);
                end else begin
                    exit(false);
                end;

            Community."Member Unique Identity"::SSN:
                if (FldSSN <> '') then begin
                    Member.SetFilter("Social Security No.", '=%1', FldSSN);
                end else begin
                    exit(false);
                end;

            else
                Error(NOT_IMPLEMENTED, Community.FieldCaption("Member Unique Identity"), Community."Member Unique Identity");
        end;

        if (Member.FindFirst()) then
            exit(false);

        exit(true);
    end;

    procedure insertMember(EntryNo: Integer)
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MemberManagement: Codeunit "NPR MM Membership Mgt.";
        LoyaltyPointManagement: Codeunit "NPR MM Loyalty Point Mgt.";
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        MemberEntryNo: Integer;
        MembershipEntryNo: Integer;
        Member: Record "NPR MM Member";
        CRLF: Text[2];
        ResponseMessage: Text;
    begin

        MemberInfoCapture.Get(EntryNo);

        MembershipSalesSetup.Get(MembershipSalesSetup.Type::ITEM, MemberInfoCapture."Item No.");

        MembershipEntryNo := 0;
        if (MemberInfoCapture."External Membership No." <> '') then
            MembershipEntryNo := MemberManagement.GetMembershipFromExtMembershipNo(MemberInfoCapture."External Membership No.");

        if (MembershipEntryNo = 0) then
            MembershipEntryNo := MemberManagement.CreateMembership(MembershipSalesSetup, MemberInfoCapture, true);

        if ((MembershipEntryNo <> 0) and (GMemberInfo."Initial Loyalty Point Count" > 0)) then
            LoyaltyPointManagement.ManualAddSalePoints(MembershipEntryNo, 'Import', GMemberInfo."Initial Loyalty Point Count", 0, 'Import');

        //MemberEntryNo := MemberManagement.AddMemberAndCard (MembershipEntryNo, MemberInfoCapture, FALSE);
        MemberManagement.AddMemberAndCard(MembershipEntryNo, MemberInfoCapture, false, MemberEntryNo, ResponseMessage);

        if (not (Member.Get(MemberEntryNo))) then
            exit;

        // Add comments.
        CRLF[1] := 13;
        CRLF[2] := 10;
        //MakeNote (Member, StrSubstNo ('Dato: %1 %2Salgsted: %3 %2%4', fldSalesDate, crlf, fldSalesLocation, fldComment));

        MemberInfoCapture.Delete();
    end;

    local procedure validateTextField(fieldValue: Text; fieldMaxLength: Integer; fieldValueIs: Integer; fieldCaptionName: Text): Text
    begin

        if (StrLen(fieldValue) > fieldMaxLength) then
            Error(INVALID_LENGTH, fieldValue, fieldMaxLength, fieldCaptionName, GLineCount);

        if ((fieldValue = '') and (fieldValueIs = REQUIRED)) then
            Error(VALUE_REQUIRED, fieldCaptionName, GLineCount);

        exit(fieldValue);
    end;

    local procedure validateDateField(fieldValue: Text; dateMask: Code[20]; fieldValueIs: Integer; fieldCaptionName: Text) rDate: Date
    begin

        rDate := 0D;

        if ((fieldValue = '') and (fieldValueIs = REQUIRED)) then
            Error(VALUE_REQUIRED, fieldCaptionName, GLineCount);

        if ((fieldValue = '') and (fieldValueIs = OPTIONAL)) then
            exit(0D);

        if (StrLen(fieldValue) <> StrLen(dateMask)) then
            Error(INVALID_DATE, fieldValue, fieldCaptionName, GLineCount, dateMask);

        case UpperCase(dateMask) of
            'YYYYMMDD':
                if (not Evaluate(rDate, StrSubstNo('%1-%2-%3', CopyStr(fieldValue, 1, 4), CopyStr(fieldValue, 5, 2), CopyStr(fieldValue, 7, 2)), 9)) then
                    Error(INVALID_DATE, fieldValue, fieldCaptionName, GLineCount, dateMask);

            'YYYY-MM-DD':
                if (not Evaluate(rDate, StrSubstNo('%1-%2-%3', CopyStr(fieldValue, 1, 4), CopyStr(fieldValue, 6, 2), CopyStr(fieldValue, 9, 2)), 9)) then
                    Error(INVALID_DATE, fieldValue, fieldCaptionName, GLineCount, dateMask);

            else
                Error(DATE_MASK_ERROR, dateMask);
        end;

        exit(rDate);
    end;

    local procedure validateDecimalField(fieldValue: Text; fieldValueIs: Integer; fieldCaptionName: Text) rDecimal: Decimal
    begin

        rDecimal := 0.0;

        if ((fieldValue = '') and (fieldValueIs = REQUIRED)) then
            Error(VALUE_REQUIRED, fieldCaptionName, GLineCount);

        if ((fieldValue = '') and (fieldValueIs = OPTIONAL)) then
            exit(0.0);

        if not (Evaluate(rDecimal, fieldValue)) then
            Error(INVALID_VALUE, fieldValue, fieldCaptionName, GLineCount);

        exit(rDecimal);
    end;

    local procedure validateIntegerField(fieldValue: Text; fieldValueIs: Integer; fieldCaptionName: Text) rInteger: Integer
    begin

        rInteger := 0;

        if ((fieldValue = '') and (fieldValueIs = REQUIRED)) then
            Error(VALUE_REQUIRED, fieldCaptionName, GLineCount);

        if ((fieldValue = '') and (fieldValueIs = OPTIONAL)) then
            exit(0);

        if not (Evaluate(rInteger, fieldValue)) then
            Error(INVALID_VALUE, fieldValue, fieldCaptionName, GLineCount);

        exit(rInteger);
    end;

    local procedure text2Money(pCents: Text[30]; pCurrency: Text[30]) rMoney: Decimal
    begin
        if ('' = pCents) then exit(0);

        Evaluate(rMoney, pCents);

        // Lookup currency to determinate decimal places...
        rMoney := rMoney / 100;

        exit(rMoney);
    end;

    local procedure nextField(var VarLineOfText: Text[1024]) rField: Text[1024]
    begin

        exit(forwardTokenizer(VarLineOfText, ';', '"'));
    end;

    local procedure forwardTokenizer(var VarText: Text[1024]; PSeparator: Char; PQuote: Char) RField: Text[1024]
    var
        Separator: Char;
        Quote: Char;
        IsQuoted: Boolean;
        InputText: Text[1024];
        NextFieldPos: Integer;
        IsNextField: Boolean;
        NextByte: Text[1];
    begin

        //  This function splits the textline into 2 parts at first occurence of separator
        //  Quotecharacter enables separator to occur inside datablock

        //  example:
        //  23;some text;"some text with a ;";xxxx

        //  result:
        //  1) 23
        //  2) some text
        //  3) some text with a ;
        //  4) xxxx

        //  Quoted text, variable length text tokenizer:
        //  forward searching tokenizer splitting string at separator.
        //  separator is protected by quoting string
        //  the separator is omitted from the resulting strings

        if ((VarText[1] = PQuote) and (StrLen(VarText) = 1)) then begin
            VarText := '';
            RField := '';
            exit(RField);
        end;

        IsQuoted := false;
        NextFieldPos := 1;
        IsNextField := false;

        InputText := VarText;

        if (PQuote = InputText[NextFieldPos]) then IsQuoted := true;
        while ((NextFieldPos <= StrLen(InputText)) and (not IsNextField)) do begin
            if (PSeparator = InputText[NextFieldPos]) then IsNextField := true;
            if (IsQuoted and IsNextField) then IsNextField := (InputText[NextFieldPos - 1] = PQuote);

            NextByte[1] := InputText[NextFieldPos];
            if (not IsNextField) then RField += NextByte;
            NextFieldPos += 1;
        end;
        if (IsQuoted) then RField := CopyStr(RField, 2, StrLen(RField) - 2);

        VarText := CopyStr(InputText, NextFieldPos);
        exit(RField);
    end;

    local procedure reverseTokenizer(var varText: Text[1024]; pSeparator: Char; pQuote: Char) rField: Text[1024]
    var
        Separator: Char;
        Quote: Char;
        IsQuoted: Boolean;
        LText: Text[1024];
        NextFieldPos: Integer;
        IsNextField: Boolean;
        AByte: Text[1];
    begin

        //  backward searching tokenizer splitting string at separator.
        //  separator is protected by quoting string
        //  the separator is omitted from the resulting strings

        IsQuoted := false;
        NextFieldPos := StrLen(varText);
        IsNextField := false;

        LText := varText;

        if (pQuote = LText[NextFieldPos]) then IsQuoted := true;
        while ((NextFieldPos <= StrLen(LText)) and (not IsNextField)) do begin
            if (pSeparator = LText[NextFieldPos]) then IsNextField := true;
            if (IsQuoted and IsNextField) then IsNextField := (LText[NextFieldPos + 1] = pQuote);

            AByte[1] := LText[NextFieldPos];
            if (not IsNextField) then rField := AByte + rField;
            NextFieldPos -= 1;
        end;
        if (IsQuoted) then rField := CopyStr(rField, 2, StrLen(rField) - 2);

        varText := CopyStr(LText, 1, NextFieldPos);
        exit(rField);
    end;

    local procedure "--Tools"()
    begin
    end;

    procedure Ansi2Ascii(_Text: Text): Text
    begin
        //Ansi2Ascii
        if not InternalVars then
            MakeVars;
        exit(ConvertStr(_Text, AnsiStr, AsciiStr));
    end;

    procedure Ascii2Ansi(_Text: Text): Text
    begin
        //Ascii2Ansi
        if not InternalVars then
            MakeVars;
        exit(ConvertStr(_Text, AsciiStr, AnsiStr));
    end;

    local procedure MakeVars()
    begin
        //MakeVars
        AsciiStr[1] := 128;
        AnsiStr[1] := 199;
        AsciiStr[2] := 129;
        AnsiStr[2] := 252;
        AsciiStr[3] := 130;
        AnsiStr[3] := 233;
        AsciiStr[4] := 131;
        AnsiStr[4] := 226;
        AsciiStr[5] := 132;
        AnsiStr[5] := 228;
        AsciiStr[6] := 133;
        AnsiStr[6] := 224;
        AsciiStr[7] := 134;
        AnsiStr[7] := 229;
        AsciiStr[8] := 135;
        AnsiStr[8] := 231;
        AsciiStr[9] := 136;
        AnsiStr[9] := 234;
        AsciiStr[10] := 137;
        AnsiStr[10] := 235;
        AsciiStr[11] := 138;
        AnsiStr[11] := 232;
        AsciiStr[12] := 139;
        AnsiStr[12] := 239;
        AsciiStr[13] := 140;
        AnsiStr[13] := 238;
        AsciiStr[14] := 141;
        AnsiStr[14] := 236;
        AsciiStr[15] := 142;
        AnsiStr[15] := 196;
        AsciiStr[16] := 143;
        AnsiStr[16] := 197;
        AsciiStr[17] := 144;
        AnsiStr[17] := 201;
        AsciiStr[18] := 145;
        AnsiStr[18] := 230;
        AsciiStr[19] := 146;
        AnsiStr[19] := 198;
        AsciiStr[20] := 147;
        AnsiStr[20] := 244;
        AsciiStr[21] := 148;
        AnsiStr[21] := 246;
        AsciiStr[22] := 149;
        AnsiStr[22] := 242;
        AsciiStr[23] := 150;
        AnsiStr[23] := 251;
        AsciiStr[24] := 151;
        AnsiStr[24] := 249;
        AsciiStr[25] := 152;
        AnsiStr[25] := 255;
        AsciiStr[26] := 153;
        AnsiStr[26] := 214;
        AsciiStr[27] := 154;
        AnsiStr[27] := 220;
        AsciiStr[28] := 155;
        AnsiStr[28] := 248;
        AsciiStr[29] := 156;
        AnsiStr[29] := 163;
        AsciiStr[30] := 157;
        AnsiStr[30] := 216;
        AsciiStr[31] := 158;
        AnsiStr[31] := 215;
        AsciiStr[32] := 159;
        AnsiStr[32] := 131;
        AsciiStr[33] := 160;
        AnsiStr[33] := 225;
        AsciiStr[34] := 161;
        AnsiStr[34] := 237;
        AsciiStr[35] := 162;
        AnsiStr[35] := 243;
        AsciiStr[36] := 163;
        AnsiStr[36] := 250;
        AsciiStr[37] := 164;
        AnsiStr[37] := 241;
        AsciiStr[38] := 165;
        AnsiStr[38] := 209;
        AsciiStr[39] := 166;
        AnsiStr[39] := 170;
        AsciiStr[40] := 167;
        AnsiStr[40] := 186;
        AsciiStr[41] := 168;
        AnsiStr[41] := 191;
        AsciiStr[42] := 169;
        AnsiStr[42] := 174;
        AsciiStr[43] := 170;
        AnsiStr[43] := 172;
        AsciiStr[44] := 171;
        AnsiStr[44] := 189;
        AsciiStr[45] := 172;
        AnsiStr[45] := 188;
        AsciiStr[46] := 173;
        AnsiStr[46] := 161;
        AsciiStr[47] := 174;
        AnsiStr[47] := 171;
        AsciiStr[48] := 175;
        AnsiStr[48] := 187;
        AsciiStr[49] := 181;
        AnsiStr[49] := 193;
        AsciiStr[50] := 182;
        AnsiStr[50] := 194;
        AsciiStr[51] := 183;
        AnsiStr[51] := 192;
        AsciiStr[52] := 184;
        AnsiStr[52] := 169;
        AsciiStr[53] := 189;
        AnsiStr[53] := 162;
        AsciiStr[54] := 190;
        AnsiStr[54] := 165;
        AsciiStr[55] := 198;
        AnsiStr[55] := 227;
        AsciiStr[56] := 199;
        AnsiStr[56] := 195;
        AsciiStr[57] := 207;
        AnsiStr[57] := 164;
        AsciiStr[58] := 208;
        AnsiStr[58] := 240;
        AsciiStr[59] := 209;
        AnsiStr[59] := 208;
        AsciiStr[60] := 210;
        AnsiStr[60] := 202;
        AsciiStr[61] := 211;
        AnsiStr[61] := 203;
        AsciiStr[62] := 212;
        AnsiStr[62] := 200;
        AsciiStr[63] := 214;
        AnsiStr[63] := 205;
        AsciiStr[64] := 215;
        AnsiStr[64] := 206;
        AsciiStr[65] := 216;
        AnsiStr[65] := 207;
        AsciiStr[66] := 221;
        AnsiStr[66] := 166;
        AsciiStr[67] := 222;
        AnsiStr[67] := 204;
        AsciiStr[68] := 224;
        AnsiStr[68] := 211;
        AsciiStr[69] := 225;
        AnsiStr[69] := 223;
        AsciiStr[70] := 226;
        AnsiStr[70] := 212;
        AsciiStr[71] := 227;
        AnsiStr[71] := 210;
        AsciiStr[72] := 228;
        AnsiStr[72] := 245;
        AsciiStr[73] := 229;
        AnsiStr[73] := 213;
        AsciiStr[74] := 230;
        AnsiStr[74] := 181;
        AsciiStr[75] := 231;
        AnsiStr[75] := 254;
        AsciiStr[76] := 232;
        AnsiStr[76] := 222;
        AsciiStr[77] := 233;
        AnsiStr[77] := 218;
        AsciiStr[78] := 234;
        AnsiStr[78] := 219;
        AsciiStr[79] := 235;
        AnsiStr[79] := 217;
        AsciiStr[80] := 236;
        AnsiStr[80] := 253;
        AsciiStr[81] := 237;
        AnsiStr[81] := 221;
        AsciiStr[82] := 238;
        AnsiStr[82] := 175;
        AsciiStr[83] := 239;
        AnsiStr[83] := 180;
        AsciiStr[84] := 240;
        AnsiStr[84] := 173;
        AsciiStr[85] := 241;
        AnsiStr[85] := 177;
        AsciiStr[86] := 243;
        AnsiStr[86] := 190;
        AsciiStr[87] := 244;
        AnsiStr[87] := 182;
        AsciiStr[88] := 245;
        AnsiStr[88] := 167;
        AsciiStr[89] := 246;
        AnsiStr[89] := 247;
        AsciiStr[90] := 247;
        AnsiStr[90] := 184;
        AsciiStr[91] := 248;
        AnsiStr[91] := 176;
        AsciiStr[92] := 249;
        AnsiStr[92] := 168;
        AsciiStr[93] := 250;
        AnsiStr[93] := 183;
        AsciiStr[94] := 251;
        AnsiStr[94] := 185;
        AsciiStr[95] := 252;
        AnsiStr[95] := 179;
        AsciiStr[96] := 253;
        AnsiStr[96] := 178;
        AsciiStr[97] := 255;
        AnsiStr[97] := 160;
        InternalVars := true;
    end;

    local procedure MakeVars2()
    begin
        AsciiStr := 'ÆüéâäàåçêëèïîìÄÅÉæÆôöòûùÿÖÜø£Ø×ƒáíóúñÑªº¿®¬½¼¡«»¦¦¦¦¦ÁÂÀ©¦¦++¢¥++--+-+ãÃ++--¦-+';
        AsciiStr := AsciiStr + '¤ðÐÊËÈiÍÎÏ++¦_¦Ì¯ÓßÔÒõÕµþÞÚÛÙýÝ¯´­±=¾¶§÷¸°¨·¹³²¦ ';
        CharVar[1] := 196;
        CharVar[2] := 197;
        CharVar[3] := 201;
        CharVar[4] := 242;
        CharVar[5] := 220;
        CharVar[6] := 186;
        CharVar[7] := 191;
        CharVar[8] := 188;
        CharVar[9] := 187;
        CharVar[10] := 193;
        CharVar[11] := 194;
        CharVar[12] := 192;
        CharVar[13] := 195;
        CharVar[14] := 202;
        CharVar[15] := 203;
        CharVar[16] := 200;
        CharVar[17] := 205;
        CharVar[18] := 206;
        CharVar[19] := 204;
        CharVar[20] := 175;
        CharVar[21] := 223;
        CharVar[22] := 213;
        CharVar[23] := 254;
        CharVar[24] := 218;
        CharVar[25] := 219;
        CharVar[26] := 217;
        CharVar[27] := 180;
        CharVar[28] := 177;
        CharVar[29] := 176;
        CharVar[30] := 185;
        CharVar[31] := 179;
        CharVar[32] := 178;
        AnsiStr := 'Ã³ÚÔõÓÕþÛÙÞ´¯ý' + FORMAT(CharVar[1]) + FORMAT(CharVar[2]) + FORMAT(CharVar[3]) + 'µã¶÷' + FORMAT(CharVar[4]);
        AnsiStr := AnsiStr + '¹¨ Í' + FORMAT(CharVar[5]) + '°úÏÎâßÝ¾·±Ð¬' + FORMAT(CharVar[6]) + FORMAT(CharVar[7]);
        AnsiStr := AnsiStr + '«¼¢' + FORMAT(CharVar[8]) + 'í½' + FORMAT(CharVar[9]) + '___ªª' + FORMAT(CharVar[10]) + FORMAT(CharVar[11]);
        AnsiStr := AnsiStr + FORMAT(CharVar[12]) + '®ªª++óÑ++--+-+Ò' + FORMAT(CharVar[13]) + '++--ª-+ñ­ð';
        AnsiStr := AnsiStr + FORMAT(CharVar[14]) + FORMAT(CharVar[15]) + FORMAT(CharVar[16]) + 'i' + FORMAT(CharVar[17]) + FORMAT(CharVar[18]);
        AnsiStr := AnsiStr + '¤++__ª' + FORMAT(CharVar[19]) + FORMAT(CharVar[20]) + 'Ë' + FORMAT(CharVar[21]) + 'ÈÊ§';
        AnsiStr := AnsiStr + FORMAT(CharVar[22]) + 'Á' + FORMAT(CharVar[23]) + 'Ì' + FORMAT(CharVar[24]) + FORMAT(CharVar[25]);
        AnsiStr := AnsiStr + FORMAT(CharVar[26]) + '²¦»' + FORMAT(CharVar[27]) + '¡' + FORMAT(CharVar[28]) + '=¥Âº¸©' + FORMAT(CharVar[29]);
        AnsiStr := AnsiStr + '¿À' + FORMAT(CharVar[30]) + FORMAT(CharVar[31]) + FORMAT(CharVar[32]) + '_ ';
    end;

    local procedure MakeNote(Member: Record "NPR MM Member"; CommentText: Text)
    var
        RecordLink: Record "Record Link";
        OutStr: OutStream;
        BinaryWriter: DotNet NPRNetBinaryWriter;
        Encoding: DotNet NPRNetEncoding;
    begin

        RecordLink.Get(Member.AddLink('', 'Notes'));

        RecordLink.Type := RecordLink.Type::Note;
        RecordLink.Note.CreateOutStream(OutStr);

        Encoding := Encoding.UTF8;
        BinaryWriter := BinaryWriter.BinaryWriter(OutStr, Encoding);
        BinaryWriter.Write(CommentText);

        RecordLink.Modify();
    end;

    local procedure TextToNote(CommentText: Text) NoteText: Text
    var
        TextLength: Integer;
        Char1: Char;
        Char2: Char;
    begin
        TextLength := StrLen(CommentText);
        if (TextLength <= 255) then begin
            Char1 := TextLength;
            NoteText := Format(Char1) + CommentText;
        end else begin
            Char1 := 128 + (TextLength - 256) mod 128;
            Char2 := 2 + (TextLength - 256) div 128;
            NoteText := Format(Char1) + Format(Char2) + CommentText;
        end;
    end;
}

