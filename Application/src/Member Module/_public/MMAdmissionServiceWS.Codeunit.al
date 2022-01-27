codeunit 6060093 "NPR MM Admission Service WS"
{
    trigger OnRun()
    var
        WebServiceMgt: Codeunit "Web Service Management";
    begin
        WebServiceMgt.CreateTenantWebService(5, Codeunit::"NPR MM Admission Service WS", 'admission_service', true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Web Service Aggregate", 'OnBeforeInsertEvent', '', true, true)]
    local procedure OnBeforeInsertWebServiceAggregate(var Rec: Record "Web Service Aggregate"; RunTrigger: Boolean)
    var
    begin
        if Rec."Object Type" <> Rec."Object Type"::Codeunit then
            exit;
        if Rec."Service Name" <> 'admission_service' then
            exit;

        Rec."All Tenants" := false;
    end;

    var
        ErrorBarcodeIsBlank: Label 'Barcode Is Blank';
        ErrorScannerStationIdIsBlank: Label 'ScannerStationId Is Blank';
        ErrorInvalidGuest: Label 'Invalid Guest';
        ErrorNoIsBlank: Label 'No Is Blank';
        ErrorTokenIsBlank: Label 'Token Is Blank';
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
        MessageText: Text;
        TMTicket: Record "NPR TM Ticket";
        MMMembership: Record "NPR MM Membership";
        Item: Record Item;
        MMMembershipSetup: Record "NPR MM Membership Setup";
        AdmissionCode: Code[20];
        MMAdmissionScannerStations: Record "NPR MM Admis. Scanner Stations";
    begin

        SelectLatestVersion();

        MMAdmissionServiceLog.Init();
        MMAdmissionServiceLog.Action := MMAdmissionServiceLog.Action::"Guest Validation";
        MMAdmissionServiceLog."Request Barcode" := Barcode;
        MMAdmissionServiceLog."Scanner Station Id" := ScannerStationId;
        MMAdmissionServiceLog."Request Scanner Station Id" := MMAdmissionServiceLog."Scanner Station Id";
        MMAdmissionServiceLog."Created Date" := CurrentDateTime;
        MMAdmissionServiceLog.Insert(true);

        MMAdmissionServiceSetup.Get();

        MMAdmissionServiceEntry.Init();
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
                    if MemberCard.FindLast() then begin
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
#pragma warning disable AA0139
                    MMAdmissionServiceLog."Response No" := Barcode;
#pragma warning restore
                    MMAdmissionServiceLog."Response Token" := CreateToken();
                    No := MMAdmissionServiceLog."Response No";
                    Token := MMAdmissionServiceLog."Response Token";

                    TMTicket.SetCurrentKey("External Ticket No.");
                    TMTicket.SetFilter("External Ticket No.", '=%1', CopyStr(Barcode, 1, MaxStrLen(TMTicket."External Ticket No.")));
                    TMTicket.FindFirst();

                    MMAdmissionServiceEntry.Type := MMAdmissionServiceEntry.Type::Ticket;
                    MMAdmissionServiceEntry.Key := MMAdmissionServiceLog."Response No";
                    MMAdmissionServiceEntry."Display Name" := TicketDisplayName;
                    MMAdmissionServiceEntry.Message := CopyStr(MessageText, 1, MaxStrLen(MMAdmissionServiceEntry.Message));
                    MMAdmissionServiceEntry."Ticket Entry No." := TMTicket."No.";
                    MMAdmissionServiceEntry."External Ticket No." := TMTicket."External Ticket No.";
                    MMAdmissionServiceEntry."External Card No." := TMTicket."External Member Card No.";

                    //      IF TMTicketType.GET(TMTicket."Ticket Type Code") THEN BEGIN
                    //        MMAdmissionServiceEntry."Ticket Type Code" := TMTicketType.Code;
                    //        MMAdmissionServiceEntry."Ticket Type Description" := TMTicketType.Description;
                    //      END;
                    if Item.Get(TMTicket."Item No.") then begin
                        MMAdmissionServiceEntry."Ticket Type Code" := Item."NPR Ticket Type";
                        if StrLen(Item.Description) > MaxStrLen(MMAdmissionServiceEntry."Ticket Type Description") then
                            MMAdmissionServiceEntry."Ticket Type Description" := CopyStr(Item.Description, 1, MaxStrLen(MMAdmissionServiceEntry."Ticket Type Description"))
                        else
                            MMAdmissionServiceEntry."Ticket Type Description" := Item.Description;
                        //MMAdmissionServiceEntry."Ticket Type Description" := Item.Description;
                    end;

                    MemberCard.SetCurrentKey("External Card No.");
                    MemberCard.SetRange("External Card No.", MMAdmissionServiceEntry."External Card No.");
                    if MemberCard.FindLast() then begin
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
#pragma warning disable AA0139
                    MMAdmissionServiceLog."Response No" := Barcode;
#pragma warning restore
                    MMAdmissionServiceEntry.Type := MMAdmissionServiceEntry.Type::Ticket;
                    MMAdmissionServiceEntry.Key := MMAdmissionServiceLog."Response No";
                    MMAdmissionServiceEntry."Display Name" := TicketDisplayName;
                    MMAdmissionServiceEntry.Message := CopyStr(MessageText, 1, MaxStrLen(MMAdmissionServiceEntry.Message));
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
        MMAdmissionServiceLog."Error Description" := CopyStr(ErrorDescription, 1, MaxStrLen(MMAdmissionServiceLog."Error Description"));
        MMAdmissionServiceLog."Return Value" := (DataError <> true);
        MMAdmissionServiceLog."Entry No." := MMAdmissionServiceEntry."Entry No.";
        MMAdmissionServiceLog.Key := No;
        MMAdmissionServiceLog.Token := Token;
        MMAdmissionServiceLog.Modify(true);
        Commit();

        exit(MMAdmissionServiceLog."Return Value");
    end;

    procedure GuestArrival(No: Text[20]; Token: Text[50]; ScannerStationId: Code[10]; var Name: Text; var PictureBase64: Text; var Transaktion: Code[10]; var ErrorNumber: Code[10]; var ErrorDescription: Text): Boolean
    var
        MMAdmissionServiceLog: Record "NPR MM Admis. Service Log";
        MMAdmissionServiceEntry: Record "NPR MM Admis. Service Entry";
        MMAdmissionServiceSetup: Record "NPR MM Admis. Service Setup";
        DataError: Boolean;
        MMMemberWebService: Codeunit "NPR MM Member WebService";
        MessageText: Text;
    begin
        SelectLatestVersion();

        MMAdmissionServiceSetup.Get();

        MMAdmissionServiceLog.Init();
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
        if MMAdmissionServiceEntry.FindSet() then begin

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
                            MMAdmissionServiceEntry.Message := CopyStr(MessageText, 1, MaxStrLen(MMAdmissionServiceEntry.Message));
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
        MMAdmissionServiceLog."Error Description" := CopyStr(ErrorDescription, 1, MaxStrLen(MMAdmissionServiceLog."Error Description"));
        MMAdmissionServiceLog."Return Value" := (DataError <> true);
        MMAdmissionServiceLog."Response PictureBase64" := (PictureBase64 <> '');
        MMAdmissionServiceLog.Modify(true);
        Commit();

        exit(MMAdmissionServiceLog."Return Value");
    end;

    procedure GuestArrivalV2(No: Text[20]; Token: Text[50]; ScannerStationId: Code[10]; var Name: Text; var PictureBase64: Text; var Transaktion: Code[10]; var ErrorNumber: Code[10]; var ErrorDescription: Text): Boolean
    var
        MMAdmissionServiceLog: Record "NPR MM Admis. Service Log";
        MMAdmissionServiceEntry: Record "NPR MM Admis. Service Entry";
        MMAdmissionServiceSetup: Record "NPR MM Admis. Service Setup";
        DataError: Boolean;
        MMMemberWebService: Codeunit "NPR MM Member WebService";
        MessageText: Text;
    begin
        SelectLatestVersion();

        MMAdmissionServiceSetup.Get();

        MMAdmissionServiceLog.Init();
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
        if MMAdmissionServiceEntry.FindSet() then begin

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
                            MMAdmissionServiceEntry.Message := CopyStr(MessageText, 1, MaxStrLen(MMAdmissionServiceEntry.Message));
                            MMAdmissionServiceEntry.Arrived := true;
                            MMAdmissionServiceEntry."Modify Date" := CurrentDateTime;
                            MMAdmissionServiceEntry.Modify(true);
                        end else begin
                            ErrorNumber := '7';
                            ErrorDescription := CopyStr(MessageText, 1, MaxStrLen(MMAdmissionServiceEntry.Message));
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
        MMAdmissionServiceLog."Error Description" := CopyStr(ErrorDescription, 1, MaxStrLen(MMAdmissionServiceLog."Error Description"));
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
        MMAdmissionServiceSetup: Record "NPR MM Admis. Service Setup";
        MMAdmissionScannerStations: Record "NPR MM Admis. Scanner Stations";
        TenantMedia: Record "Tenant Media";
        InStrDefault: InStream;
        InStrError: InStream;
    begin
        if MMAdmissionScannerStations.Get(ScannerStationId) then begin
            if MMAdmissionScannerStations.Activated then begin

                if TenantMedia.Get(MMAdmissionScannerStations."Default Turnstile Image".MediaId()) then
                    TenantMedia.CalcFields(Content);
                if TenantMedia.Content.HasValue() then begin
                    TenantMedia.Content.CreateInStream(InStrDefault);
                    GetImageContentAndExtension(InStrDefault, TenantMedia."Mime Type", PictureBase64Error, PictureExtensionDefault);

                    Clear(InStrDefault);
                end;

                Clear(TenantMedia);
                if TenantMedia.Get(MMAdmissionScannerStations."Error Image of Turnstile".MediaId()) then
                    TenantMedia.CalcFields(Content);
                if TenantMedia.Content.HasValue() then begin
                    TenantMedia.Content.CreateInStream(InStrError);
                    GetImageContentAndExtension(InStrError, TenantMedia."Mime Type", PictureBase64Error, PictureExtensionError);
                    Clear(InStrError);
                end;
            end;
        end;

        MMAdmissionServiceSetup.Get();
        Clear(TenantMedia);
        if TenantMedia.Get(MMAdmissionServiceSetup."Default Turnstile Image".MediaId()) then
            TenantMedia.CalcFields(Content);
        if TenantMedia.Content.HasValue() and (PictureBase64Default = '') then begin
            TenantMedia.Content.CreateInStream(InStrDefault);
            GetImageContentAndExtension(InStrDefault, TenantMedia."Mime Type", PictureBase64Default, PictureExtensionDefault);
            Clear(InStrDefault);
        end;

        Clear(TenantMedia);
        if TenantMedia.Get(MMAdmissionServiceSetup."Error Image of Turnstile".MediaId()) then
            TenantMedia.CalcFields(Content);
        if TenantMedia.Content.HasValue() and (PictureBase64Error = '') then begin
            TenantMedia.Content.CreateInStream(InStrError);
            GetImageContentAndExtension(InStrError, TenantMedia."Mime Type", PictureBase64Error, PictureExtensionError);
            Clear(InStrError);
        end;

        exit('Hallo ' + ScannerStationId);
    end;

    local procedure CreateToken(): Code[50]
    var
        Token: Text[50];
        NewGuid: Guid;
    begin
        NewGuid := CreateGuid();
        Token := CopyStr(DelChr(CopyStr(Format(NewGuid), 2, StrLen(Format(NewGuid)) - 2), '=', '-'), 1, MaxStrLen(Token));
        exit(Token);
    end;

    local procedure GetAvatarImage(var MMAdmissionServiceSetup: Record "NPR MM Admis. Service Setup"; var Base64StringImage: Text): Boolean
    var
        TenantMedia: Record "Tenant Media";
        Base64Convert: Codeunit "Base64 Convert";
        InStr: InStream;
    begin
        if TenantMedia.Get(MMAdmissionServiceSetup."Guest Avatar Image".MediaId()) then
            TenantMedia.CalcFields(Content);
        if TenantMedia.Content.HasValue() then begin
            TenantMedia.Content.CreateInStream(InStr);
            Base64StringImage := Base64Convert.ToBase64(InStr);
            exit(true);
        end;
    end;

    local procedure GetAvatarImageV2(var MMAdmissionServiceSetup: Record "NPR MM Admis. Service Setup"; var Base64StringImage: Text; ScannerStationId: Code[10]): Boolean
    var
        TenantMedia: Record "Tenant Media";
        MMAdmissionScannerStations: Record "NPR MM Admis. Scanner Stations";
        Base64Convert: Codeunit "Base64 Convert";
        InStr: InStream;
    begin
        if MMAdmissionScannerStations.Get(ScannerStationId) then begin
            if MMAdmissionScannerStations.Activated then begin
                if TenantMedia.Get(MMAdmissionScannerStations."Guest Avatar Image".MediaId()) then
                    TenantMedia.CalcFields(Content);
                if TenantMedia.Content.HasValue() then begin
                    TenantMedia.Content.CreateInStream(InStr);
                    Base64StringImage := Base64Convert.ToBase64(InStr);
                    exit(true);
                end;
            end;
        end;

        Clear(TenantMedia);
        if TenantMedia.Get(MMAdmissionServiceSetup."Guest Avatar Image".MediaId()) then
            TenantMedia.CalcFields(Content);
        if TenantMedia.Content.HasValue() then begin
            TenantMedia.Content.CreateInStream(InStr);
            Base64StringImage := Base64Convert.ToBase64(InStr);
            exit(true);
        end;
    end;

    local procedure GetImageContentAndExtension(InS: InStream; MimeType: Text[100]; var Base64: Text; var Extension: Text)
    var
        Base64Convert: Codeunit "Base64 Convert";
    begin
        Base64 := Base64Convert.ToBase64(InS);

        Extension := 'unknown';
        if (MimeType.StartsWith('image/')) then
            Extension := MimeType.Substring(StrLen('image/'));
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
        MessageText: Text;
        TMTicket: Record "NPR TM Ticket";
        MMMembership: Record "NPR MM Membership";
        Item: Record Item;
        MMMembershipSetup: Record "NPR MM Membership Setup";
        AdmissionCode: Code[20];
        MMAdmissionScannerStations: Record "NPR MM Admis. Scanner Stations";
    begin

        SelectLatestVersion();

        MMAdmissionServiceLog.Init();
        MMAdmissionServiceLog.Action := MMAdmissionServiceLog.Action::"Guest Validation";
        MMAdmissionServiceLog."Request Barcode" := Barcode;
        MMAdmissionServiceLog."Scanner Station Id" := ScannerStationId;
        MMAdmissionServiceLog."Request Scanner Station Id" := MMAdmissionServiceLog."Scanner Station Id";
        MMAdmissionServiceLog."Created Date" := CurrentDateTime;
        MMAdmissionServiceLog.Insert(true);

        MMAdmissionServiceSetup.Get();

        MMAdmissionServiceEntry.Init();
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
                    if MemberCard.FindLast() then begin
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

                //IF TMTicketWebService.ValidateTicketArrival('',Barcode,ScannerStationId,MessageText) THEN BEGIN
                if TMTicketWebService.ValidateTicketArrival(AdmissionCode, Barcode, ScannerStationId, MessageText) then begin
#pragma warning disable AA0139
                    MMAdmissionServiceLog."Response No" := Barcode;
#pragma warning restore
                    MMAdmissionServiceLog."Response Token" := CreateToken();
                    No := MMAdmissionServiceLog."Response No";
                    Token := MMAdmissionServiceLog."Response Token";

                    TMTicket.SetCurrentKey("External Ticket No.");
                    TMTicket.SetFilter("External Ticket No.", '=%1', CopyStr(Barcode, 1, MaxStrLen(TMTicket."External Ticket No.")));
                    TMTicket.FindFirst();

                    MMAdmissionServiceEntry.Type := MMAdmissionServiceEntry.Type::Ticket;
                    MMAdmissionServiceEntry.Key := MMAdmissionServiceLog."Response No";
                    MMAdmissionServiceEntry."Display Name" := TicketDisplayName;
                    MMAdmissionServiceEntry.Message := CopyStr(MessageText, 1, MaxStrLen(MMAdmissionServiceEntry.Message));
                    MMAdmissionServiceEntry."Ticket Entry No." := TMTicket."No.";
                    MMAdmissionServiceEntry."External Ticket No." := TMTicket."External Ticket No.";
                    MMAdmissionServiceEntry."External Card No." := TMTicket."External Member Card No.";

                    //      IF TMTicketType.GET(TMTicket."Ticket Type Code") THEN BEGIN
                    //        MMAdmissionServiceEntry."Ticket Type Code" := TMTicketType.Code;
                    //        MMAdmissionServiceEntry."Ticket Type Description" := TMTicketType.Description;
                    //      END;
                    if Item.Get(TMTicket."Item No.") then begin
                        MMAdmissionServiceEntry."Ticket Type Code" := Item."NPR Ticket Type";
                        if StrLen(Item.Description) > MaxStrLen(MMAdmissionServiceEntry."Ticket Type Description") then
                            MMAdmissionServiceEntry."Ticket Type Description" := CopyStr(Item.Description, 1, MaxStrLen(MMAdmissionServiceEntry."Ticket Type Description"))
                        else
                            MMAdmissionServiceEntry."Ticket Type Description" := Item.Description;
                        //MMAdmissionServiceEntry."Ticket Type Description" := Item.Description;
                    end;

                    MemberCard.SetCurrentKey("External Card No.");
                    MemberCard.SetRange("External Card No.", MMAdmissionServiceEntry."External Card No.");
                    if MemberCard.FindLast() then begin
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
#pragma warning disable AA0139
                    MMAdmissionServiceLog."Response No" := Barcode;
#pragma warning restore

                    MMAdmissionServiceEntry.Type := MMAdmissionServiceEntry.Type::Ticket;
                    MMAdmissionServiceEntry.Key := MMAdmissionServiceLog."Response No";
                    MMAdmissionServiceEntry."Display Name" := TicketDisplayName;
                    MMAdmissionServiceEntry.Message := CopyStr(MessageText, 1, MaxStrLen(MMAdmissionServiceEntry.Message));
                end;
            end;
            if not AdmissionIsValid then begin
                if StrPos(MessageText, '-1004') > 0 then begin
                    ErrorNumber := '1002';
                    ErrorDescription := ErrorTooManyLogins;
                    DataError := true;
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
        MMAdmissionServiceLog."Error Description" := CopyStr(ErrorDescription, 1, MaxStrLen(MMAdmissionServiceLog."Error Description"));
        MMAdmissionServiceLog."Return Value" := (DataError <> true);
        MMAdmissionServiceLog."Entry No." := MMAdmissionServiceEntry."Entry No.";
        MMAdmissionServiceLog.Key := No;
        MMAdmissionServiceLog.Token := Token;
        MMAdmissionServiceLog.Modify(true);
        Commit();

        exit(MMAdmissionServiceLog."Return Value");
    end;

    #region Admis. Scanner Stations
    procedure ImportGuestAvatarImage(var AdminsScannerStation: Record "NPR MM Admis. Scanner Stations")
    var
        FileManagement: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";
        InStr: Instream;
    begin
        FileManagement.BLOBImport(TempBlob, '');
        if not TempBlob.Hasvalue() then
            Error('');

        TempBlob.CreateInStream(InStr);
        Clear(AdminsScannerStation."Guest Avatar Image");
        AdminsScannerStation."Guest Avatar Image".ImportStream(InStr, AdminsScannerStation.FieldCaption("Guest Avatar Image"));
        AdminsScannerStation.Modify(true);
    end;

    procedure DeleteGuestAvatarImage(AdminsScannerStation: Record "NPR MM Admis. Scanner Stations")
    var
        DeleteImageQst: Label 'Do you want to delete %1?', Comment = '%1 = Guest Avatar Image';
    begin
        if not Confirm(DeleteImageQst, false, AdminsScannerStation.FieldCaption("Guest Avatar Image")) then
            exit;

        Clear(AdminsScannerStation."Guest Avatar Image");
        AdminsScannerStation.Modify(true);
    end;

    procedure ImportTurnstileErrorImage(var AdminsScannerStation: Record "NPR MM Admis. Scanner Stations")
    var
        FileManagement: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";
        InStr: Instream;
    begin
        AdminsScannerStation.Find();
        FileManagement.BLOBImport(TempBlob, '');
        if not TempBlob.Hasvalue() then
            Error('');

        TempBlob.CreateInStream(InStr);

        Clear(AdminsScannerStation."Error Image of Turnstile");
        AdminsScannerStation."Error Image of Turnstile".ImportStream(InStr, AdminsScannerStation.FieldCaption("Error Image of Turnstile"));
        AdminsScannerStation.Modify(true);
    end;

    procedure DeleteTurnstileErrorImage(AdminsScannerStation: Record "NPR MM Admis. Scanner Stations")
    var
        DeleteImageQst: Label 'Do you want to delete %1?', Comment = '%1 = Turnstile Error Image';
    begin
        if not Confirm(DeleteImageQst, false, AdminsScannerStation.FieldCaption("Error Image of Turnstile")) then
            exit;

        Clear(AdminsScannerStation."Error Image of Turnstile");
        AdminsScannerStation.Modify(true);
    end;

    procedure ImportDefaultTurnstileImage(var AdminsScannerStation: Record "NPR MM Admis. Scanner Stations")
    var
        FileManagement: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";
        InStr: Instream;
    begin
        AdminsScannerStation.Find();
        FileManagement.BLOBImport(TempBlob, '');
        if not TempBlob.Hasvalue() then
            Error('');

        TempBlob.CreateInStream(InStr);

        Clear(AdminsScannerStation."Default Turnstile Image");
        AdminsScannerStation."Default Turnstile Image".ImportStream(InStr, AdminsScannerStation.FieldCaption("Default Turnstile Image"));
        AdminsScannerStation.Modify(true);
    end;

    procedure DeleteDefaultTurnstileImage(AdminsScannerStation: Record "NPR MM Admis. Scanner Stations")
    var
        DeleteImageQst: Label 'Do you want to delete %1?', Comment = '%1 = Default Turnstile Image';
    begin
        if not Confirm(DeleteImageQst, false, AdminsScannerStation.FieldCaption("Default Turnstile Image")) then
            exit;

        Clear(AdminsScannerStation."Default Turnstile Image");
        AdminsScannerStation.Modify(true);
    end;

    #endregion
    #region Admis. Service Setup

    procedure ImportGuestAvatarImageToSetup(var AdminsServiceSetup: Record "NPR MM Admis. Service Setup")
    var
        FileManagement: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";
        InStr: Instream;
    begin
        FileManagement.BLOBImport(TempBlob, '');
        if not TempBlob.Hasvalue() then
            Error('');

        TempBlob.CreateInStream(InStr);

        Clear(AdminsServiceSetup."Guest Avatar Image");
        AdminsServiceSetup."Guest Avatar Image".ImportStream(InStr, AdminsServiceSetup.FieldCaption("Guest Avatar Image"));
        AdminsServiceSetup.Modify(true);
    end;

    procedure DeleteGuestAvatarImageToSetup(AdminsServiceSetup: Record "NPR MM Admis. Service Setup")
    var
        DeleteImageQst: Label 'Do you want to delete %1?', Comment = '%1 = Guest Avatar Image';
    begin
        if not Confirm(DeleteImageQst, false, AdminsServiceSetup.FieldCaption("Guest Avatar Image")) then
            exit;

        Clear(AdminsServiceSetup."Guest Avatar Image");
        AdminsServiceSetup.Modify(true);
    end;

    procedure ImportTurnstileErrorImageToSetup(var AdminsServiceSetup: Record "NPR MM Admis. Service Setup")
    var
        FileManagement: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";
        InStr: Instream;
    begin
        AdminsServiceSetup.Find();
        FileManagement.BLOBImport(TempBlob, '');
        if not TempBlob.Hasvalue() then
            Error('');

        TempBlob.CreateInStream(InStr);

        Clear(AdminsServiceSetup."Error Image of Turnstile");
        AdminsServiceSetup."Error Image of Turnstile".ImportStream(InStr, AdminsServiceSetup.FieldCaption("Error Image of Turnstile"));
        AdminsServiceSetup.Modify(true);
    end;

    procedure DeleteTurnstileErrorImageToSetup(AdminsServiceSetup: Record "NPR MM Admis. Service Setup")
    var
        DeleteImageQst: Label 'Do you want to delete %1?', Comment = '%1 = Turnstile Error Image';
    begin
        if not Confirm(DeleteImageQst, false, AdminsServiceSetup.FieldCaption("Error Image of Turnstile")) then
            exit;

        Clear(AdminsServiceSetup."Error Image of Turnstile");
        AdminsServiceSetup.Modify(true);
    end;

    procedure ImportDefaultTurnstileImageToSetup(var AdminsServiceSetup: Record "NPR MM Admis. Service Setup")
    var
        FileManagement: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";
        InStr: Instream;
    begin
        AdminsServiceSetup.Find();
        FileManagement.BLOBImport(TempBlob, '');
        if not TempBlob.Hasvalue() then
            Error('');

        TempBlob.CreateInStream(InStr);

        Clear(AdminsServiceSetup."Default Turnstile Image");
        AdminsServiceSetup."Default Turnstile Image".ImportStream(InStr, AdminsServiceSetup.FieldCaption("Default Turnstile Image"));
        AdminsServiceSetup.Modify(true);
    end;

    procedure DeleteDefaultTurnstileImageToSetup(AdminsServiceSetup: Record "NPR MM Admis. Service Setup")
    var
        DeleteImageQst: Label 'Do you want to delete %1?', Comment = '%1 = Default Turnstile Image';
    begin
        if not Confirm(DeleteImageQst, false, AdminsServiceSetup.FieldCaption("Default Turnstile Image")) then
            exit;

        Clear(AdminsServiceSetup."Default Turnstile Image");
        AdminsServiceSetup.Modify(true);
    end;

    #endregion
}

