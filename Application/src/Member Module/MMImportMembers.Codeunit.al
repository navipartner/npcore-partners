codeunit 6060132 "NPR MM Import Members"
{

    trigger OnRun()
    var
        FileManagement: Codeunit "File Management";
        FileName: Text[1024];
    begin

        if GuiAllowed then begin
            FileName := FileManagement.BLOBImportWithFilter(_TempBlob, SELECT_FILE_CAPTION, '', 'Membership Import Files (*.csv;*.txt)|*.csv;*.txt', 'csv,txt');

            if (FileName = '') then
                exit;

        end;

        Import();
    end;

    var
        _TempBlob: Codeunit "Temp Blob";
        GMemberInfo: Record "NPR MM Member Info Capture";
        GDateMask: Code[20];
        GLineCount: Integer;
        REQUIRED: Integer;
        OPTIONAL: Integer;
        FldMemberNo: Text;
        FldFirstName: Text;
        FldMiddleName: Text;
        FldLastName: Text;
        FldPhone: Text;
        FldSSN: Text;
        FldAddress: Text;
        FldPostCode: Text;
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
        UNSUCCESSFUL_IMPORT: Label 'Some of the import lines did not result in successful member creation. Do you want to view the list?';
        IMPORT_MESSAGE_DIALOG: Label 'Importing :\#1#######################################################';
        PROCESS_INFO: Label 'Processing: (%1) %2 %3';
        SUCCESS_MSG: Label '%1 members imported successfully.';
        SELECT_FILE_CAPTION: Label 'Member Import';
        NOT_IMPLEMENTED: Label 'Support for %1 %2 is not implemented.';
        DATE_MASK_ERROR: Label 'Date format mask %1 is not supported.';

    procedure Import()
    var
        IStream: InStream;
        FileLine: Text;
        Window: Dialog;
        RunMode: Integer;
        LowEntryNo: Integer;
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MemberInfoCapturePage: Page "NPR MM Member Info Capture";
        IComm: Record "NPR I-Comm";
    begin

        // xxx
        if IComm.Get() then
            if IComm."Use Auto. Cust. Lookup" then
                if not Confirm('Warning: %1 is setup and may interfere with customer creation when importing members. Has the %1 been configured correctly?', false, IComm.TableCaption()) then
                    Error('');

        REQUIRED := 1;
        OPTIONAL := 2;
        GDateMask := 'YYYYMMDD'; // Should be setup or parameter

        _TempBlob.CreateInStream(IStream, TextEncoding::UTF8);

        MemberInfoCapture.SetFilter("Originates From File Import", '=%1', true);
        if (MemberInfoCapture.FindLast()) then;
        LowEntryNo := MemberInfoCapture."Entry No." + 1;

        RunMode := 1;

        if GuiAllowed then
            Window.Open(IMPORT_MESSAGE_DIALOG);

        while (not IStream.EOS) do begin

            if (IStream.ReadText(FileLine) > 0) then begin

                decodeLine(FileLine);
                if GuiAllowed then
                    if ((GLineCount mod 50) = 0) then Window.Update(1, StrSubstNo(PROCESS_INFO, GLineCount, FldFirstName, FldLastName));

                GLineCount += 1;

                if (GLineCount <> 1) then begin
                    if (isValidMember() and (RunMode = 1)) then
                        insertMember(GMemberInfo."Entry No.");
                end;

            end;

        end;

        if GuiAllowed then
            Window.Close();

        MemberInfoCapture.Reset();
        MemberInfoCapture.SetFilter("Originates From File Import", '=%1', true);
        MemberInfoCapture.SetFilter("Entry No.", '%1..', LowEntryNo);
        if (MemberInfoCapture.Count() > 0) then begin
            if (GuiAllowed) then begin
                if (Confirm(UNSUCCESSFUL_IMPORT, true)) then begin
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

    local procedure isValidMember(): Boolean
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

    local procedure nextField(var VarLineOfText: Text[1024]): Text[1024]
    begin

        exit(forwardTokenizer(VarLineOfText, ';', '"'));
    end;

    local procedure forwardTokenizer(var VarText: Text[1024]; PSeparator: Char; PQuote: Char) RField: Text[1024]
    var
        IsQuoted: Boolean;
        InputText: Text[1024];
        NextFieldPos: Integer;
        IsNextField: Boolean;
        NextByte: Text[1];
    begin

        //  This function splits the text line into 2 parts at first occurrence of separator
        //  Quote character enables separator to occur inside data block

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

    local procedure MakeNote(Member: Record "NPR MM Member"; CommentText: Text)
    var
        RecordLink: Record "Record Link";
        OutStr: OutStream;
    begin
        RecordLink.Get(Member.AddLink('', 'Notes'));
        RecordLink.Type := RecordLink.Type::Note;
        RecordLink.Note.CreateOutStream(OutStr, TextEncoding::UTF8);
        OutStr.WriteText(CommentText);
        RecordLink.Modify();
    end;

}

