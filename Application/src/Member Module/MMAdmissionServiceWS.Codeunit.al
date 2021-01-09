codeunit 6060093 "NPR MM Admission Service WS"
{

    trigger OnRun()
    var
        WebService: Record "Web Service";
    begin
        Clear(WebService);

        if not WebService.Get(WebService."Object Type"::Codeunit, 'admission_service') then begin
            WebService.Init;
            WebService."Object Type" := WebService."Object Type"::Codeunit;
            WebService."Service Name" := 'admission_service';
            WebService."Object ID" := 6060093;
            WebService.Published := true;
            WebService.Insert();
        end;
    end;

    var
        ErrorBarcodeIsBlank: Label 'Barcode Is Blank';
        ErrorScannerStationIdIsBlank: Label 'ScannerStationId Is Blank';
        ErrorInvalidGuest: Label 'Invalid Guest';
        ErrorNoIsBlank: Label 'No Is Blank';
        ErrorTokenIsBlank: Label 'Token Is Blank';
        ErrorNoOrTokenNotValid: Label 'No Or Token Is Not Valid';
        ErrorAdmissionTypeIsBlank: Label 'Admission Type Is Blank';
        ErrorTooManyLogins: Label 'TooManyLogins';
        TicketDisplayName: Label 'Ticket';

    procedure GuestValidation(Barcode: Text[50]; ScannerStationId: Code[10]; var No: Code[20]; var Token: Code[50]; var ErrorNumber: Code[10]; var ErrorDescription: Text): Boolean
    var
        MMMemberWebService: Codeunit "NPR MM Member WebService";
        MemberCard: Record "NPR MM Member Card";
        Member: Record "NPR MM Member";
        TMTicketWebService: Codeunit "NPR TM Ticket WebService";
        MMAdmissionServiceEntry: Record "NPR MM Admis. Service Entry";
        DataError: Boolean;
        AdmissionIsValid: Boolean;
        MMAdmissionServiceLog: Record "NPR MM Admis. Service Log";
        MMAdmissionServiceSetup: Record "NPR MM Admis. Service Setup";
        MessageText: Text[250];
        TMTicket: Record "NPR TM Ticket";
        TMTicketType: Record "NPR TM Ticket Type";
        MMMembership: Record "NPR MM Membership";
        Item: Record Item;
        MMMembershipSetup: Record "NPR MM Membership Setup";
        AdmissionCode: Code[20];
        MMAdmissionScannerStations: Record "NPR MM Admis. Scanner Stations";
    begin

        SelectLatestVersion;

        MMAdmissionServiceLog.Init;
        MMAdmissionServiceLog.Action := MMAdmissionServiceLog.Action::"Guest Validation";
        MMAdmissionServiceLog."Request Barcode" := Barcode;
        MMAdmissionServiceLog."Scanner Station Id" := ScannerStationId;
        MMAdmissionServiceLog."Request Scanner Station Id" := MMAdmissionServiceLog."Scanner Station Id";
        MMAdmissionServiceLog."Created Date" := CurrentDateTime;
        MMAdmissionServiceLog.Insert(true);

        MMAdmissionServiceSetup.Get;

        MMAdmissionServiceEntry.Init;
        MMAdmissionServiceEntry."Created Date" := MMAdmissionServiceLog."Created Date";
        MMAdmissionServiceEntry.Insert(true);

        MMAdmissionServiceLog."Entry No." := MMAdmissionServiceEntry."Entry No.";
        MMAdmissionServiceLog.Modify(true);
        Commit();

        No := '';
        Token := '';

        ErrorNumber := '';
        ErrorDescription := '';

        if Barcode = '' then begin
            ErrorNumber := '1';
            ErrorDescription := ErrorBarcodeIsBlank;
            DataError := true;
        end;

        if (ScannerStationId = '') and MMAdmissionServiceSetup."Validate Scanner Station" then begin
            ErrorNumber := '2';
            ErrorDescription := ErrorScannerStationIdIsBlank;
            DataError := true;
        end;

        AdmissionCode := '';
        if MMAdmissionScannerStations.Get(ScannerStationId) then
            AdmissionCode := MMAdmissionScannerStations."Admission Code";

        if not DataError then begin
            if MMAdmissionServiceSetup."Validate Members" and not AdmissionIsValid then begin
                if MMMemberWebService.MemberCardNumberValidation(Barcode, ScannerStationId) then begin
                    MemberCard.SetCurrentKey("External Card No.");
                    MemberCard.SetRange("External Card No.", Barcode);
                    if MemberCard.FindLast then begin
                        if Member.Get(MemberCard."Member Entry No.") then begin
                            MMAdmissionServiceLog."Response No" := Member."External Member No.";
                            MMAdmissionServiceLog."Response Token" := CreateToken();
                            No := MMAdmissionServiceLog."Response No";
                            Token := MMAdmissionServiceLog."Response Token";

                            MMAdmissionServiceEntry.Type := MMAdmissionServiceEntry.Type::Membership;
                            MMAdmissionServiceEntry.Key := MMAdmissionServiceLog."Response No";
                            MMAdmissionServiceEntry."Card Entry No." := MemberCard."Entry No.";
                            MMAdmissionServiceEntry."External Card No." := MemberCard."External Card No.";
                            MMAdmissionServiceEntry."Member Entry No." := MemberCard."Member Entry No.";
                            MMAdmissionServiceEntry."External Member No." := MemberCard."External Member No.";
                            MMAdmissionServiceEntry."Membership Entry No." := MemberCard."Membership Entry No.";
                            MMAdmissionServiceEntry."External Membership No." := MemberCard."External Membership No.";
                            MMAdmissionServiceEntry."Display Name" := Member."Display Name";

                            if MMMembership.Get(MemberCard."Membership Entry No.") then begin
                                MMAdmissionServiceEntry."Membership Code" := MMMembership."Membership Code";
                                if MMMembershipSetup.Get(MMMembership."Membership Code") then
                                    MMAdmissionServiceEntry."Membership Description" := MMMembershipSetup.Description;
                            end;

                            AdmissionIsValid := true;
                        end;
                    end;
                end;
            end;
            if MMAdmissionServiceSetup."Validate Tickes" and not AdmissionIsValid then begin

                //IF TMTicketWebService.ValidateTicketArrival('',Barcode,ScannerStationId,MessageText) THEN BEGIN
                if TMTicketWebService.ValidateTicketArrival(AdmissionCode, Barcode, ScannerStationId, MessageText) then begin

                    MMAdmissionServiceLog."Response No" := Barcode;
                    MMAdmissionServiceLog."Response Token" := CreateToken();
                    No := MMAdmissionServiceLog."Response No";
                    Token := MMAdmissionServiceLog."Response Token";

                    TMTicket.SetCurrentKey("External Ticket No.");
                    TMTicket.SetFilter("External Ticket No.", '=%1', CopyStr(Barcode, 1, MaxStrLen(TMTicket."External Ticket No.")));
                    TMTicket.FindFirst;

                    MMAdmissionServiceEntry.Type := MMAdmissionServiceEntry.Type::Ticket;
                    MMAdmissionServiceEntry.Key := MMAdmissionServiceLog."Response No";
                    MMAdmissionServiceEntry."Display Name" := TicketDisplayName;
                    MMAdmissionServiceEntry.Message := MessageText;
                    MMAdmissionServiceEntry."Ticket Entry No." := TMTicket."No.";
                    MMAdmissionServiceEntry."External Ticket No." := TMTicket."External Ticket No.";
                    MMAdmissionServiceEntry."External Card No." := TMTicket."External Member Card No.";

                    //      IF TMTicketType.GET(TMTicket."Ticket Type Code") THEN BEGIN
                    //        MMAdmissionServiceEntry."Ticket Type Code" := TMTicketType.Code;
                    //        MMAdmissionServiceEntry."Ticket Type Description" := TMTicketType.Description;
                    //      END;
                    if Item.Get(TMTicket."Item No.") then begin
                        MMAdmissionServiceEntry."Ticket Type Code" := Item."No.";
                        if StrLen(Item.Description) > MaxStrLen(MMAdmissionServiceEntry."Ticket Type Description") then
                            MMAdmissionServiceEntry."Ticket Type Description" := CopyStr(Item.Description, 1, MaxStrLen(MMAdmissionServiceEntry."Ticket Type Description"))
                        else
                            MMAdmissionServiceEntry."Ticket Type Description" := Item.Description;
                        //MMAdmissionServiceEntry."Ticket Type Description" := Item.Description;
                    end;

                    MemberCard.SetCurrentKey("External Card No.");
                    MemberCard.SetRange("External Card No.", MMAdmissionServiceEntry."External Card No.");
                    if MemberCard.FindLast then begin
                        if Member.Get(MemberCard."Member Entry No.") then begin
                            MMAdmissionServiceEntry."Card Entry No." := MemberCard."Entry No.";
                            MMAdmissionServiceEntry."Member Entry No." := MemberCard."Member Entry No.";
                            MMAdmissionServiceEntry."External Member No." := MemberCard."External Member No.";
                            MMAdmissionServiceEntry."Membership Entry No." := MemberCard."Membership Entry No.";
                            MMAdmissionServiceEntry."External Membership No." := MemberCard."External Membership No.";
                            MMAdmissionServiceEntry."Display Name" := Member."Display Name";

                            if MMMembership.Get(MemberCard."Membership Entry No.") then begin
                                MMAdmissionServiceEntry."Membership Code" := MemberCard."Membership Code";
                                MMAdmissionServiceEntry."Membership Description" := MMMembership.Description;
                            end;
                        end;
                    end;
                    AdmissionIsValid := true;
                end else begin
                    MMAdmissionServiceLog."Response No" := Barcode;

                    MMAdmissionServiceEntry.Type := MMAdmissionServiceEntry.Type::Ticket;
                    MMAdmissionServiceEntry.Key := MMAdmissionServiceLog."Response No";
                    MMAdmissionServiceEntry."Display Name" := TicketDisplayName;
                    MMAdmissionServiceEntry.Message := MessageText;
                end;
            end;
            if not AdmissionIsValid then begin
                if StrPos(MessageText, '-1004') > 0 then begin
                    //ErrorNumber := '1002';
                    //ErrorDescription := ErrorTooManyLogins;
                    //DataError := TRUE;
                end else begin
                    ErrorNumber := '3';
                    ErrorDescription := ErrorInvalidGuest;
                    DataError := true;
                end;
            end;
        end;

        MMAdmissionServiceEntry.Token := Token;
        MMAdmissionServiceEntry."Scanner Station Id" := MMAdmissionServiceLog."Scanner Station Id";
        MMAdmissionServiceEntry."Admission Is Valid" := AdmissionIsValid;
        MMAdmissionServiceEntry.Modify(true);

        MMAdmissionServiceLog."Error Number" := ErrorNumber;
        MMAdmissionServiceLog."Error Description" := ErrorDescription;
        MMAdmissionServiceLog."Return Value" := (DataError <> true);
        MMAdmissionServiceLog."Entry No." := MMAdmissionServiceEntry."Entry No.";
        MMAdmissionServiceLog.Key := No;
        MMAdmissionServiceLog.Token := Token;
        MMAdmissionServiceLog.Modify(true);
        Commit();

        exit(MMAdmissionServiceLog."Return Value");
    end;

    procedure GuestArrival(No: Text; Token: Text; ScannerStationId: Code[10]; var Name: Text; var PictureBase64: Text; var Transaktion: Code[10]; var ErrorNumber: Code[10]; var ErrorDescription: Text): Boolean
    var
        MMAdmissionServiceLog: Record "NPR MM Admis. Service Log";
        MMAdmissionServiceEntry: Record "NPR MM Admis. Service Entry";
        MMAdmissionServiceSetup: Record "NPR MM Admis. Service Setup";
        DataError: Boolean;
        MMMemberWebService: Codeunit "NPR MM Member WebService";
        MessageText: Text[250];
    begin
        SelectLatestVersion;

        MMAdmissionServiceSetup.Get;

        MMAdmissionServiceLog.Init;
        MMAdmissionServiceLog.Action := MMAdmissionServiceLog.Action::"Guest Arrival";
        MMAdmissionServiceLog.Token := Token;
        MMAdmissionServiceLog.Key := No;
        MMAdmissionServiceLog."Request No" := MMAdmissionServiceLog.Key;
        MMAdmissionServiceLog."Request Token" := MMAdmissionServiceLog.Token;
        MMAdmissionServiceLog."Scanner Station Id" := ScannerStationId;
        MMAdmissionServiceLog."Request Scanner Station Id" := MMAdmissionServiceLog."Scanner Station Id";
        MMAdmissionServiceLog."Created Date" := CurrentDateTime;
        MMAdmissionServiceLog.Insert(true);
        Commit();

        Name := '';
        PictureBase64 := '';

        ErrorNumber := '';
        ErrorDescription := '';

        if (ScannerStationId = '') and MMAdmissionServiceSetup."Validate Scanner Station" then begin
            ErrorNumber := '2';
            ErrorDescription := ErrorScannerStationIdIsBlank;
            DataError := true;
        end;

        if No = '' then begin
            ErrorNumber := '4';
            ErrorDescription := ErrorNoIsBlank;
            DataError := true;
        end;

        if Token = '' then begin
            ErrorNumber := '5';
            ErrorDescription := ErrorTokenIsBlank;
            DataError := true;
        end;

        if MMAdmissionServiceSetup."Validate Scanner Station" then
            MMAdmissionServiceEntry.SetRange("Scanner Station Id", MMAdmissionServiceLog."Scanner Station Id");
        MMAdmissionServiceEntry.SetRange(Key, MMAdmissionServiceLog.Key);
        MMAdmissionServiceEntry.SetRange(Token, MMAdmissionServiceLog.Token);
        MMAdmissionServiceEntry.SetRange("Admission Is Valid", true);
        MMAdmissionServiceEntry.SetRange(Arrived, false);
        if MMAdmissionServiceEntry.FindSet then begin

            Transaktion := Format(MMAdmissionServiceEntry."Entry No.");
            Name := MMAdmissionServiceEntry."Display Name";
            MMAdmissionServiceLog."Entry No." := MMAdmissionServiceEntry."Entry No.";

            case MMAdmissionServiceEntry.Type of
                MMAdmissionServiceEntry.Type::Blank:
                    begin
                        ErrorNumber := '6';
                        ErrorDescription := ErrorAdmissionTypeIsBlank;
                        DataError := true;
                        MMAdmissionServiceEntry."Modify Date" := CurrentDateTime;
                    end;
                MMAdmissionServiceEntry.Type::Membership:
                    begin
                        if MMMemberWebService.MemberCardRegisterArrival(MMAdmissionServiceEntry."External Card No.", '', '', MessageText) then begin
                            MMMemberWebService.GetMemberImage(MMAdmissionServiceEntry.Key, PictureBase64, ScannerStationId);
                            if PictureBase64 = '' then
                                GetAvatarImage(MMAdmissionServiceSetup, PictureBase64);
                            MMAdmissionServiceEntry.Message := MessageText;
                            MMAdmissionServiceEntry.Arrived := true;
                            MMAdmissionServiceEntry."Modify Date" := CurrentDateTime;
                            MMAdmissionServiceEntry.Modify(true);
                        end else begin
                            ErrorNumber := '7';
                            ErrorDescription := MessageText;
                            DataError := true;
                        end;
                    end;
                MMAdmissionServiceEntry.Type::Ticket:
                    begin
                        if MMAdmissionServiceEntry."External Card No." <> '' then
                            MMMemberWebService.GetMemberImage(MMAdmissionServiceEntry.Key, PictureBase64, ScannerStationId);
                        if PictureBase64 = '' then
                            GetAvatarImage(MMAdmissionServiceSetup, PictureBase64);
                        MMAdmissionServiceEntry.Arrived := true;
                        MMAdmissionServiceEntry."Modify Date" := CurrentDateTime;
                        MMAdmissionServiceEntry.Modify(true);
                    end;
            end;
        end else begin
            //ErrorNumber := '7';
            //ErrorDescription := ErrorNoOrTokenNotValid;
            ErrorNumber := '1002';
            ErrorDescription := ErrorTooManyLogins;
            DataError := true;
        end;

        MMAdmissionServiceLog."Error Number" := ErrorNumber;
        MMAdmissionServiceLog."Error Description" := ErrorDescription;
        MMAdmissionServiceLog."Return Value" := (DataError <> true);
        MMAdmissionServiceLog."Response PictureBase64" := (PictureBase64 <> '');
        MMAdmissionServiceLog.Modify(true);
        Commit();

        exit(MMAdmissionServiceLog."Return Value");
    end;

    procedure GuestArrivalV2(No: Text; Token: Text; ScannerStationId: Code[10]; var Name: Text; var PictureBase64: Text; var Transaktion: Code[10]; var ErrorNumber: Code[10]; var ErrorDescription: Text): Boolean
    var
        MMAdmissionServiceLog: Record "NPR MM Admis. Service Log";
        MMAdmissionServiceEntry: Record "NPR MM Admis. Service Entry";
        MMAdmissionServiceSetup: Record "NPR MM Admis. Service Setup";
        DataError: Boolean;
        MMMemberWebService: Codeunit "NPR MM Member WebService";
        MessageText: Text[250];
    begin
        SelectLatestVersion;

        MMAdmissionServiceSetup.Get;

        MMAdmissionServiceLog.Init;
        MMAdmissionServiceLog.Action := MMAdmissionServiceLog.Action::"Guest Arrival";
        MMAdmissionServiceLog.Token := Token;
        MMAdmissionServiceLog.Key := No;
        MMAdmissionServiceLog."Request No" := MMAdmissionServiceLog.Key;
        MMAdmissionServiceLog."Request Token" := MMAdmissionServiceLog.Token;
        MMAdmissionServiceLog."Scanner Station Id" := ScannerStationId;
        MMAdmissionServiceLog."Request Scanner Station Id" := MMAdmissionServiceLog."Scanner Station Id";
        MMAdmissionServiceLog."Created Date" := CurrentDateTime;
        MMAdmissionServiceLog.Insert(true);
        Commit();

        Name := '';
        PictureBase64 := '';

        ErrorNumber := '';
        ErrorDescription := '';

        if (ScannerStationId = '') and MMAdmissionServiceSetup."Validate Scanner Station" then begin
            ErrorNumber := '2';
            ErrorDescription := ErrorScannerStationIdIsBlank;
            DataError := true;
        end;

        if No = '' then begin
            ErrorNumber := '4';
            ErrorDescription := ErrorNoIsBlank;
            DataError := true;
        end;

        if Token = '' then begin
            ErrorNumber := '5';
            ErrorDescription := ErrorTokenIsBlank;
            DataError := true;
        end;

        if MMAdmissionServiceSetup."Validate Scanner Station" then
            MMAdmissionServiceEntry.SetRange("Scanner Station Id", MMAdmissionServiceLog."Scanner Station Id");
        MMAdmissionServiceEntry.SetRange(Key, MMAdmissionServiceLog.Key);
        MMAdmissionServiceEntry.SetRange(Token, MMAdmissionServiceLog.Token);
        MMAdmissionServiceEntry.SetRange("Admission Is Valid", true);
        MMAdmissionServiceEntry.SetRange(Arrived, false);
        if MMAdmissionServiceEntry.FindSet then begin

            Transaktion := Format(MMAdmissionServiceEntry."Entry No.");
            Name := MMAdmissionServiceEntry."Display Name";
            MMAdmissionServiceLog."Entry No." := MMAdmissionServiceEntry."Entry No.";

            case MMAdmissionServiceEntry.Type of
                MMAdmissionServiceEntry.Type::Membership:
                    begin
                        Name := MMAdmissionServiceEntry."Membership Code" + ' - ' + MMAdmissionServiceEntry."Membership Description";
                    end;
                MMAdmissionServiceEntry.Type::Ticket:
                    begin
                        Name := MMAdmissionServiceEntry."Ticket Type Description";
                    end;
            end;

            case MMAdmissionServiceEntry.Type of
                MMAdmissionServiceEntry.Type::Blank:
                    begin
                        ErrorNumber := '6';
                        ErrorDescription := ErrorAdmissionTypeIsBlank;
                        DataError := true;
                        MMAdmissionServiceEntry."Modify Date" := CurrentDateTime;
                    end;
                MMAdmissionServiceEntry.Type::Membership:
                    begin
                        if MMMemberWebService.MemberCardRegisterArrival(MMAdmissionServiceEntry."External Card No.", '', '', MessageText) then begin
                            MMMemberWebService.GetMemberImage(MMAdmissionServiceEntry.Key, PictureBase64, ScannerStationId);
                            if PictureBase64 = '' then
                                GetAvatarImageV2(MMAdmissionServiceSetup, PictureBase64, MMAdmissionServiceEntry."Scanner Station Id");
                            MMAdmissionServiceEntry.Message := MessageText;
                            MMAdmissionServiceEntry.Arrived := true;
                            MMAdmissionServiceEntry."Modify Date" := CurrentDateTime;
                            MMAdmissionServiceEntry.Modify(true);
                        end else begin
                            ErrorNumber := '7';
                            ErrorDescription := MessageText;
                            DataError := true;
                        end;
                    end;
                MMAdmissionServiceEntry.Type::Ticket:
                    begin
                        if MMAdmissionServiceEntry."External Card No." <> '' then
                            MMMemberWebService.GetMemberImage(MMAdmissionServiceEntry.Key, PictureBase64, ScannerStationId);
                        if PictureBase64 = '' then
                            GetAvatarImageV2(MMAdmissionServiceSetup, PictureBase64, MMAdmissionServiceEntry."Scanner Station Id");
                        MMAdmissionServiceEntry.Arrived := true;
                        MMAdmissionServiceEntry."Modify Date" := CurrentDateTime;
                        MMAdmissionServiceEntry.Modify(true);
                    end;
            end;
        end else begin
            //ErrorNumber := '7';
            //ErrorDescription := ErrorNoOrTokenNotValid;
            ErrorNumber := '1002';
            ErrorDescription := ErrorTooManyLogins;
            DataError := true;
        end;

        MMAdmissionServiceLog."Error Number" := ErrorNumber;
        MMAdmissionServiceLog."Error Description" := ErrorDescription;
        MMAdmissionServiceLog."Return Value" := (DataError <> true);
        MMAdmissionServiceLog."Response PictureBase64" := (PictureBase64 <> '');
        MMAdmissionServiceLog.Modify(true);
        Commit();

        exit(MMAdmissionServiceLog."Return Value");
    end;

    procedure ValidateConnection(ScannerStationId: Code[10]): Text
    begin
        exit('Hallo ' + ScannerStationId);
    end;

    procedure GetTurnstileImages(ScannerStationId: Code[10]; var PictureBase64Default: Text; var PictureExtensionDefault: Text; var PictureBase64Error: Text; var PictureExtensionError: Text): Text
    var
        InStrDefault: InStream;
        InStrError: InStream;
        MMAdmissionServiceSetup: Record "NPR MM Admis. Service Setup";
        MMAdmissionScannerStations: Record "NPR MM Admis. Scanner Stations";
    begin
        if MMAdmissionScannerStations.Get(ScannerStationId) then begin
            if MMAdmissionScannerStations.Activated then begin

                MMAdmissionScannerStations.CalcFields("Turnstile Default Image", "Turnstile Error Image");

                if MMAdmissionScannerStations."Turnstile Default Image".HasValue then begin
                    MMAdmissionScannerStations."Turnstile Default Image".CreateInStream(InStrDefault);
                    GetImageContent(InStrDefault, PictureBase64Default);
                    MMAdmissionScannerStations."Turnstile Default Image".CreateInStream(InStrDefault);
                    GetImageExtension(InStrDefault, PictureExtensionDefault);
                    Clear(InStrDefault);
                end;

                if MMAdmissionScannerStations."Turnstile Error Image".HasValue then begin
                    MMAdmissionScannerStations."Turnstile Error Image".CreateInStream(InStrError);
                    GetImageContent(InStrError, PictureBase64Error);
                    MMAdmissionScannerStations."Turnstile Error Image".CreateInStream(InStrError);
                    GetImageExtension(InStrError, PictureExtensionError);
                    Clear(InStrError);
                end;
            end;
        end;

        MMAdmissionServiceSetup.Get;

        MMAdmissionServiceSetup.CalcFields("Turnstile Default Image", "Turnstile Error Image");

        if MMAdmissionServiceSetup."Turnstile Default Image".HasValue and (PictureBase64Default = '') then begin
            MMAdmissionServiceSetup."Turnstile Default Image".CreateInStream(InStrDefault);
            GetImageContent(InStrDefault, PictureBase64Default);
            MMAdmissionServiceSetup."Turnstile Default Image".CreateInStream(InStrDefault);
            GetImageExtension(InStrDefault, PictureExtensionDefault);
            Clear(InStrDefault);
        end;

        if MMAdmissionServiceSetup."Turnstile Error Image".HasValue and (PictureBase64Error = '') then begin
            MMAdmissionServiceSetup."Turnstile Error Image".CreateInStream(InStrError);
            GetImageContent(InStrError, PictureBase64Error);
            MMAdmissionServiceSetup."Turnstile Error Image".CreateInStream(InStrError);
            GetImageExtension(InStrError, PictureExtensionError);
            Clear(InStrError);
        end;

        exit('Hallo ' + ScannerStationId);
    end;

    local procedure CreateToken(): Code[50]
    var
        Token: Text;
        NewGuid: Guid;
    begin
        NewGuid := CreateGuid();
        Token := DelChr(CopyStr(Format(NewGuid), 2, StrLen(Format(NewGuid)) - 2), '=', '-');
        exit(Token);
    end;

    local procedure GetAvatarImage(var MMAdmissionServiceSetup: Record "NPR MM Admis. Service Setup"; var Base64StringImage: Text) Success: Boolean
    var
        Member: Record "NPR MM Member";
        InStr: InStream;
        Base64Convert: Codeunit "Base64 Convert";
    begin
        MMAdmissionServiceSetup.CalcFields("Guest Avatar");
        MMAdmissionServiceSetup."Guest Avatar".CreateInStream(InStr);
        Base64StringImage := Base64Convert.ToBase64(InStr);
        exit(true);
    end;

    local procedure GetAvatarImageV2(var MMAdmissionServiceSetup: Record "NPR MM Admis. Service Setup"; var Base64StringImage: Text; ScannerStationId: Code[10]) Success: Boolean
    var
        Member: Record "NPR MM Member";
        InStr: InStream;
        MMAdmissionScannerStations: Record "NPR MM Admis. Scanner Stations";
        Base64Convert: Codeunit "Base64 Convert";
    begin
        if MMAdmissionScannerStations.Get(ScannerStationId) then begin
            if MMAdmissionScannerStations.Activated then begin
                MMAdmissionScannerStations.CalcFields("Guest Avatar");
                if MMAdmissionScannerStations."Guest Avatar".HasValue then begin
                    MMAdmissionScannerStations."Guest Avatar".CreateInStream(InStr);
                    Base64StringImage := Base64Convert.ToBase64(InStr);
                    exit(true);
                end;
            end;
        end;

        MMAdmissionServiceSetup.CalcFields("Guest Avatar");
        MMAdmissionServiceSetup."Guest Avatar".CreateInStream(InStr);
        Base64StringImage := Base64Convert.ToBase64(InStr);
        exit(true);
    end;

    local procedure ToHex(ByteValue: Byte): Text;
    var
        a: byte;
        b: byte;
        left: Text;
        right: Text;
    begin
        a := ByteValue DIV 16;
        b := ByteValue MOD 16;

        case a of
            0:
                left := '0';
            1:
                left := '1';
            2:
                left := '2';
            3:
                left := '3';
            4:
                left := '4';
            5:
                left := '5';
            6:
                left := '6';
            7:
                left := '7';
            8:
                left := '8';
            9:
                left := '9';
            10:
                left := 'A';
            11:
                left := 'B';
            12:
                left := 'C';
            13:
                left := 'D';
            14:
                left := 'E';
            15:
                left := 'F';
        end;

        case b of
            0:
                right := '0';
            1:
                right := '1';
            2:
                right := '2';
            3:
                right := '3';
            4:
                right := '4';
            5:
                right := '5';
            6:
                right := '6';
            7:
                right := '7';
            8:
                right := '8';
            9:
                right := '9';
            10:
                right := 'A';
            11:
                right := 'B';
            12:
                right := 'C';
            13:
                right := 'D';
            14:
                right := 'E';
            15:
                right := 'F';
        end;
        exit(left + right);
    end;

    local procedure GetSignature(SignatureBytes: array[10] of Byte; NoOfBytes: integer): Text;
    var
        i: Integer;
        Result: text;
    begin
        for i := 1 to NoOfBytes do
            Result := Result + ToHex(SignatureBytes[i]);
        exit(Result);
    end;

    local procedure GetImageExtensionFromHeader(InS: InStream): Text;
    var
        SignatureBytes: array[10] of Byte;
        c: Char;
        i: Integer;
        UnknownImageFormatErr: Label 'Unknown/unrecognized image format.';
    begin
        for i := 1 to ArrayLen(SignatureBytes) do begin
            InS.Read(c);
            SignatureBytes[i] := c;
        end;

        //File signatues:
        //  https://en.wikipedia.org/wiki/List_of_file_signatures

        //FF D8 FF DB - jpeg
        //FF D8 FF E0 - jpeg
        //FF D8 FF EE - jpeg
        //FF D8 FF E1 - jpeg
        if GetSignature(SignatureBytes, 4) = 'FFD8FFDB' then exit('jpeg');
        if GetSignature(SignatureBytes, 4) = 'FFD8FFE0' then exit('jpeg');
        if GetSignature(SignatureBytes, 4) = 'FFD8FFEE' then exit('jpeg');
        if GetSignature(SignatureBytes, 4) = 'FFD8FFE1' then exit('jpeg');
        //89 50 4E 47 - png
        if GetSignature(SignatureBytes, 4) = '89504E47' then exit('png');
        //42 4D - bmp
        if GetSignature(SignatureBytes, 2) = '424D' then exit('bmp');
        //47 49 46 38 37 61 - gif
        //47 49 46 38 39 61 - gif
        if GetSignature(SignatureBytes, 6) = '474946383761' then exit('gif');
        if GetSignature(SignatureBytes, 6) = '474946383961' then exit('gif');
        //49 49 2A 00 - tiff
        //4D 4D 00 2A - tiff
        if GetSignature(SignatureBytes, 4) = '49492A00' then exit('tiff');
        if GetSignature(SignatureBytes, 4) = '4D4D002A' then exit('tiff');
        //00 00 01 00 - ico
        if GetSignature(SignatureBytes, 4) = '00000100' then exit('ico');
        //D7 CD C6 9A - wmf
        if GetSignature(SignatureBytes, 4) = 'D7CDC69A' then exit('wmf');

        Error(UnknownImageFormatErr);
    end;

    local procedure GetImageContent(InS: InStream; var Base64: Text)
    var
        Base64Convert: Codeunit "Base64 Convert";
    begin
        Base64 := Base64Convert.ToBase64(InS);
    end;

    local procedure GetImageExtension(InS: InStream; var Extension: Text[10])
    begin
        Extension := GetImageExtensionFromHeader(InS);
    end;

    procedure GuestValidationV2(Barcode: Text[50]; ScannerStationId: Code[10]; var No: Code[20]; var Token: Code[50]; var ErrorNumber: Code[10]; var ErrorDescription: Text; var LightColor: Text[30]): Boolean
    var
        MMMemberWebService: Codeunit "NPR MM Member WebService";
        MemberCard: Record "NPR MM Member Card";
        Member: Record "NPR MM Member";
        TMTicketWebService: Codeunit "NPR TM Ticket WebService";
        MMAdmissionServiceEntry: Record "NPR MM Admis. Service Entry";
        DataError: Boolean;
        AdmissionIsValid: Boolean;
        MMAdmissionServiceLog: Record "NPR MM Admis. Service Log";
        MMAdmissionServiceSetup: Record "NPR MM Admis. Service Setup";
        MessageText: Text[250];
        TMTicket: Record "NPR TM Ticket";
        TMTicketType: Record "NPR TM Ticket Type";
        MMMembership: Record "NPR MM Membership";
        Item: Record Item;
        MMMembershipSetup: Record "NPR MM Membership Setup";
        AdmissionCode: Code[20];
        MMAdmissionScannerStations: Record "NPR MM Admis. Scanner Stations";
    begin

        SelectLatestVersion;

        MMAdmissionServiceLog.Init;
        MMAdmissionServiceLog.Action := MMAdmissionServiceLog.Action::"Guest Validation";
        MMAdmissionServiceLog."Request Barcode" := Barcode;
        MMAdmissionServiceLog."Scanner Station Id" := ScannerStationId;
        MMAdmissionServiceLog."Request Scanner Station Id" := MMAdmissionServiceLog."Scanner Station Id";
        MMAdmissionServiceLog."Created Date" := CurrentDateTime;
        MMAdmissionServiceLog.Insert(true);

        MMAdmissionServiceSetup.Get;

        MMAdmissionServiceEntry.Init;
        MMAdmissionServiceEntry."Created Date" := MMAdmissionServiceLog."Created Date";
        MMAdmissionServiceEntry.Insert(true);

        MMAdmissionServiceLog."Entry No." := MMAdmissionServiceEntry."Entry No.";
        MMAdmissionServiceLog.Modify(true);
        Commit();

        No := '';
        Token := '';

        ErrorNumber := '';
        ErrorDescription := '';

        LightColor := '0';

        if Barcode = '' then begin
            ErrorNumber := '1';
            ErrorDescription := ErrorBarcodeIsBlank;
            DataError := true;
        end;

        if (ScannerStationId = '') and MMAdmissionServiceSetup."Validate Scanner Station" then begin
            ErrorNumber := '2';
            ErrorDescription := ErrorScannerStationIdIsBlank;
            DataError := true;
        end;

        AdmissionCode := '';
        if MMAdmissionScannerStations.Get(ScannerStationId) then
            AdmissionCode := MMAdmissionScannerStations."Admission Code";

        if not DataError then begin
            if MMAdmissionServiceSetup."Validate Members" and not AdmissionIsValid then begin
                if MMMemberWebService.MemberCardNumberValidation(Barcode, ScannerStationId) then begin
                    MemberCard.SetCurrentKey("External Card No.");
                    MemberCard.SetRange("External Card No.", Barcode);
                    if MemberCard.FindLast then begin
                        if Member.Get(MemberCard."Member Entry No.") then begin
                            MMAdmissionServiceLog."Response No" := Member."External Member No.";
                            MMAdmissionServiceLog."Response Token" := CreateToken();
                            No := MMAdmissionServiceLog."Response No";
                            Token := MMAdmissionServiceLog."Response Token";

                            MMAdmissionServiceEntry.Type := MMAdmissionServiceEntry.Type::Membership;
                            MMAdmissionServiceEntry.Key := MMAdmissionServiceLog."Response No";
                            MMAdmissionServiceEntry."Card Entry No." := MemberCard."Entry No.";
                            MMAdmissionServiceEntry."External Card No." := MemberCard."External Card No.";
                            MMAdmissionServiceEntry."Member Entry No." := MemberCard."Member Entry No.";
                            MMAdmissionServiceEntry."External Member No." := MemberCard."External Member No.";
                            MMAdmissionServiceEntry."Membership Entry No." := MemberCard."Membership Entry No.";
                            MMAdmissionServiceEntry."External Membership No." := MemberCard."External Membership No.";
                            MMAdmissionServiceEntry."Display Name" := Member."Display Name";

                            if MMMembership.Get(MemberCard."Membership Entry No.") then begin
                                MMAdmissionServiceEntry."Membership Code" := MMMembership."Membership Code";
                                if MMMembershipSetup.Get(MMMembership."Membership Code") then
                                    MMAdmissionServiceEntry."Membership Description" := MMMembershipSetup.Description;
                            end;

                            AdmissionIsValid := true;
                            LightColor := '2';
                        end;
                    end;
                end;
            end;
            if MMAdmissionServiceSetup."Validate Tickes" and not AdmissionIsValid then begin
                if TMTicketWebService.ValidateTicketArrival(AdmissionCode, Barcode, ScannerStationId, MessageText) then begin
                    MMAdmissionServiceLog."Response No" := Barcode;
                    MMAdmissionServiceLog."Response Token" := CreateToken();
                    No := MMAdmissionServiceLog."Response No";
                    Token := MMAdmissionServiceLog."Response Token";

                    TMTicket.SetCurrentKey("External Ticket No.");
                    TMTicket.SetFilter("External Ticket No.", '=%1', CopyStr(Barcode, 1, MaxStrLen(TMTicket."External Ticket No.")));
                    TMTicket.FindFirst;

                    MMAdmissionServiceEntry.Type := MMAdmissionServiceEntry.Type::Ticket;
                    MMAdmissionServiceEntry.Key := MMAdmissionServiceLog."Response No";
                    MMAdmissionServiceEntry."Display Name" := TicketDisplayName;
                    MMAdmissionServiceEntry.Message := MessageText;
                    MMAdmissionServiceEntry."Ticket Entry No." := TMTicket."No.";
                    MMAdmissionServiceEntry."External Ticket No." := TMTicket."External Ticket No.";
                    MMAdmissionServiceEntry."External Card No." := TMTicket."External Member Card No.";

                    if Item.Get(TMTicket."Item No.") then begin
                        MMAdmissionServiceEntry."Ticket Type Code" := Item."No.";
                        if StrLen(Item.Description) > MaxStrLen(MMAdmissionServiceEntry."Ticket Type Description") then
                            MMAdmissionServiceEntry."Ticket Type Description" := CopyStr(Item.Description, 1, MaxStrLen(MMAdmissionServiceEntry."Ticket Type Description"))
                        else
                            MMAdmissionServiceEntry."Ticket Type Description" := Item.Description;
                    end;

                    MemberCard.SetCurrentKey("External Card No.");
                    MemberCard.SetRange("External Card No.", MMAdmissionServiceEntry."External Card No.");
                    if MemberCard.FindLast then begin
                        if Member.Get(MemberCard."Member Entry No.") then begin
                            MMAdmissionServiceEntry."Card Entry No." := MemberCard."Entry No.";
                            MMAdmissionServiceEntry."Member Entry No." := MemberCard."Member Entry No.";
                            MMAdmissionServiceEntry."External Member No." := MemberCard."External Member No.";
                            MMAdmissionServiceEntry."Membership Entry No." := MemberCard."Membership Entry No.";
                            MMAdmissionServiceEntry."External Membership No." := MemberCard."External Membership No.";
                            MMAdmissionServiceEntry."Display Name" := Member."Display Name";

                            if MMMembership.Get(MemberCard."Membership Entry No.") then begin
                                MMAdmissionServiceEntry."Membership Code" := MemberCard."Membership Code";
                                MMAdmissionServiceEntry."Membership Description" := MMMembership.Description;
                            end;
                        end;
                    end;
                    AdmissionIsValid := true;
                    LightColor := '2';
                end else begin
                    MMAdmissionServiceLog."Response No" := Barcode;

                    MMAdmissionServiceEntry.Type := MMAdmissionServiceEntry.Type::Ticket;
                    MMAdmissionServiceEntry.Key := MMAdmissionServiceLog."Response No";
                    MMAdmissionServiceEntry."Display Name" := TicketDisplayName;
                    MMAdmissionServiceEntry.Message := MessageText;
                end;
            end;
            if not AdmissionIsValid then begin
                if StrPos(MessageText, '-1004') > 0 then begin
                    //ErrorNumber := '1002';
                    //ErrorDescription := ErrorTooManyLogins;
                    //DataError := TRUE;
                end else begin
                    ErrorNumber := '3';
                    ErrorDescription := ErrorInvalidGuest;
                    DataError := true;
                end;
            end;
        end;

        MMAdmissionServiceEntry.Token := Token;
        MMAdmissionServiceEntry."Scanner Station Id" := MMAdmissionServiceLog."Scanner Station Id";
        MMAdmissionServiceEntry."Admission Is Valid" := AdmissionIsValid;
        MMAdmissionServiceEntry.Modify(true);

        MMAdmissionServiceLog."Error Number" := ErrorNumber;
        MMAdmissionServiceLog."Error Description" := ErrorDescription;
        MMAdmissionServiceLog."Return Value" := (DataError <> true);
        MMAdmissionServiceLog."Entry No." := MMAdmissionServiceEntry."Entry No.";
        MMAdmissionServiceLog.Key := No;
        MMAdmissionServiceLog.Token := Token;
        MMAdmissionServiceLog.Modify(true);
        Commit();

        exit(MMAdmissionServiceLog."Return Value");
    end;
}
