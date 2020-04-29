codeunit 6060093 "MM Admission Service WS"
{
    // NPR5.31/NPKNAV/20170502  CASE 263737 Transport NPR5.31 - 2 May 2017
    // NPR5.41/CLVA  /20180419  CASE 303493 Added function ValidateConnection
    // NPR5.43/CLVA  /20180612  CASE 318579 Added function GetTurnstileImages and GetImageContentAndExtension
    // NPR5.43/CLVA  /20180627  CASE 318579 Added extra info to MM Admission Service Entry. Added upgraded function GuestArrivalV2 to support additional info on the login screen/display name
    // NPR5.44/NPKNAV/20180727  CASE 318579-01 Transport NPR5.44 - 27 July 2018
    // NPR5.54/CLVA  /20200316  CASE 364422 Added function GuestValidationV2


    trigger OnRun()
    var
        WebService: Record "Web Service";
    begin
        Clear(WebService);

        if not WebService.Get(WebService."Object Type"::Codeunit,'admission_service') then begin
          WebService.Init;
          WebService."Object Type" := WebService."Object Type"::Codeunit;
          WebService."Service Name" := 'admission_service';
          WebService."Object ID" := 6060093;
          WebService.Published := true;
          WebService.Insert;
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

    [Scope('Personalization')]
    procedure GuestValidation(Barcode: Text[50];ScannerStationId: Code[10];var No: Code[20];var Token: Code[50];var ErrorNumber: Code[10];var ErrorDescription: Text): Boolean
    var
        MMMemberWebService: Codeunit "MM Member WebService";
        MemberCard: Record "MM Member Card";
        Member: Record "MM Member";
        TMTicketWebService: Codeunit "TM Ticket WebService";
        MMAdmissionServiceEntry: Record "MM Admission Service Entry";
        DataError: Boolean;
        AdmissionIsValid: Boolean;
        MMAdmissionServiceLog: Record "MM Admission Service Log";
        MMAdmissionServiceSetup: Record "MM Admission Service Setup";
        MessageText: Text[250];
        TMTicket: Record "TM Ticket";
        TMTicketType: Record "TM Ticket Type";
        MMMembership: Record "MM Membership";
        Item: Record Item;
        MMMembershipSetup: Record "MM Membership Setup";
    begin
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
        Commit;

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

        if not DataError then begin
          if MMAdmissionServiceSetup."Validate Members" and not AdmissionIsValid then begin
            if MMMemberWebService.MemberCardNumberValidation(Barcode,ScannerStationId) then begin
              MemberCard.SetCurrentKey("External Card No.");
              MemberCard.SetRange("External Card No.",Barcode);
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

                  //-NPR5.43 [318579]
                  if MMMembership.Get(MemberCard."Membership Entry No.") then begin
                    MMAdmissionServiceEntry."Membership Code" := MMMembership."Membership Code";
                    if MMMembershipSetup.Get(MMMembership."Membership Code") then
                      MMAdmissionServiceEntry."Membership Description" := MMMembershipSetup.Description;
                  end;
                  //+NPR5.43 [318579]

                  AdmissionIsValid := true;
                end;
              end;
            end;
          end;
          if MMAdmissionServiceSetup."Validate Tickes" and not AdmissionIsValid then begin
            if TMTicketWebService.ValidateTicketArrival('',Barcode,ScannerStationId,MessageText) then begin

              MMAdmissionServiceLog."Response No" := Barcode;
              MMAdmissionServiceLog."Response Token" := CreateToken();
              No := MMAdmissionServiceLog."Response No";
              Token := MMAdmissionServiceLog."Response Token";

              TMTicket.SetCurrentKey("External Ticket No.");
              TMTicket.SetFilter("External Ticket No.", '=%1', CopyStr (Barcode, 1, MaxStrLen(TMTicket."External Ticket No.")));
              TMTicket.FindFirst;

              MMAdmissionServiceEntry.Type := MMAdmissionServiceEntry.Type::Ticket;
              MMAdmissionServiceEntry.Key := MMAdmissionServiceLog."Response No";
              MMAdmissionServiceEntry."Display Name" := TicketDisplayName;
              MMAdmissionServiceEntry.Message := MessageText;
              MMAdmissionServiceEntry."Ticket Entry No." := TMTicket."No.";
              MMAdmissionServiceEntry."External Ticket No." := TMTicket."External Ticket No.";
              MMAdmissionServiceEntry."External Card No." := TMTicket."External Member Card No.";

              //-NPR5.44 [318579]
        //      IF TMTicketType.GET(TMTicket."Ticket Type Code") THEN BEGIN
        //        MMAdmissionServiceEntry."Ticket Type Code" := TMTicketType.Code;
        //        MMAdmissionServiceEntry."Ticket Type Description" := TMTicketType.Description;
        //      END;
              if Item.Get(TMTicket."Item No.") then begin
                MMAdmissionServiceEntry."Ticket Type Code" := Item."No.";
                if StrLen(Item.Description) > MaxStrLen(MMAdmissionServiceEntry."Ticket Type Description") then
                  MMAdmissionServiceEntry."Ticket Type Description" := CopyStr(Item.Description,1, MaxStrLen(MMAdmissionServiceEntry."Ticket Type Description"))
                else
                  MMAdmissionServiceEntry."Ticket Type Description" := Item.Description;
                //MMAdmissionServiceEntry."Ticket Type Description" := Item.Description;
              end;
              //+NPR5.44 [318579]

              MemberCard.SetCurrentKey("External Card No.");
              MemberCard.SetRange("External Card No.",MMAdmissionServiceEntry."External Card No.");
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
            if StrPos(MessageText,'-1004') > 0 then begin
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
        Commit;

        exit(MMAdmissionServiceLog."Return Value");
    end;

    [Scope('Personalization')]
    procedure GuestArrival(No: Text;Token: Text;ScannerStationId: Code[10];var Name: Text;var PictureBase64: Text;var Transaktion: Code[10];var ErrorNumber: Code[10];var ErrorDescription: Text): Boolean
    var
        MMAdmissionServiceLog: Record "MM Admission Service Log";
        MMAdmissionServiceEntry: Record "MM Admission Service Entry";
        MMAdmissionServiceSetup: Record "MM Admission Service Setup";
        DataError: Boolean;
        MMMemberWebService: Codeunit "MM Member WebService";
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
        Commit;

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
          MMAdmissionServiceEntry.SetRange("Scanner Station Id",MMAdmissionServiceLog."Scanner Station Id");
        MMAdmissionServiceEntry.SetRange(Key,MMAdmissionServiceLog.Key);
        MMAdmissionServiceEntry.SetRange(Token,MMAdmissionServiceLog.Token);
        MMAdmissionServiceEntry.SetRange("Admission Is Valid",true);
        MMAdmissionServiceEntry.SetRange(Arrived,false);
        if MMAdmissionServiceEntry.FindSet then begin

          Transaktion := Format(MMAdmissionServiceEntry."Entry No.");
          Name := MMAdmissionServiceEntry."Display Name";
          MMAdmissionServiceLog."Entry No." := MMAdmissionServiceEntry."Entry No.";

          case MMAdmissionServiceEntry.Type of
            MMAdmissionServiceEntry.Type::Blank :
              begin
                ErrorNumber := '6';
                ErrorDescription := ErrorAdmissionTypeIsBlank;
                DataError := true;
                MMAdmissionServiceEntry."Modify Date" := CurrentDateTime;
              end;
            MMAdmissionServiceEntry.Type::Membership :
              begin
                if MMMemberWebService.MemberCardRegisterArrival(MMAdmissionServiceEntry."External Card No.",'','',MessageText) then begin
                  MMMemberWebService.GetMemberImage(MMAdmissionServiceEntry.Key, PictureBase64, ScannerStationId);
                  if PictureBase64 = '' then
                    GetAvatarImage(MMAdmissionServiceSetup,PictureBase64);
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
            MMAdmissionServiceEntry.Type::Ticket :
              begin
                if MMAdmissionServiceEntry."External Card No." <> '' then
                  MMMemberWebService.GetMemberImage(MMAdmissionServiceEntry.Key, PictureBase64, ScannerStationId);
                if PictureBase64 = '' then
                  GetAvatarImage(MMAdmissionServiceSetup,PictureBase64);
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
        Commit;

        exit(MMAdmissionServiceLog."Return Value");
    end;

    [Scope('Personalization')]
    procedure GuestArrivalV2(No: Text;Token: Text;ScannerStationId: Code[10];var Name: Text;var PictureBase64: Text;var Transaktion: Code[10];var ErrorNumber: Code[10];var ErrorDescription: Text): Boolean
    var
        MMAdmissionServiceLog: Record "MM Admission Service Log";
        MMAdmissionServiceEntry: Record "MM Admission Service Entry";
        MMAdmissionServiceSetup: Record "MM Admission Service Setup";
        DataError: Boolean;
        MMMemberWebService: Codeunit "MM Member WebService";
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
        Commit;

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
          MMAdmissionServiceEntry.SetRange("Scanner Station Id",MMAdmissionServiceLog."Scanner Station Id");
        MMAdmissionServiceEntry.SetRange(Key,MMAdmissionServiceLog.Key);
        MMAdmissionServiceEntry.SetRange(Token,MMAdmissionServiceLog.Token);
        MMAdmissionServiceEntry.SetRange("Admission Is Valid",true);
        MMAdmissionServiceEntry.SetRange(Arrived,false);
        if MMAdmissionServiceEntry.FindSet then begin

          Transaktion := Format(MMAdmissionServiceEntry."Entry No.");
          Name := MMAdmissionServiceEntry."Display Name";
          MMAdmissionServiceLog."Entry No." := MMAdmissionServiceEntry."Entry No.";

          case MMAdmissionServiceEntry.Type of
            MMAdmissionServiceEntry.Type::Membership :
              begin
                Name := MMAdmissionServiceEntry."Membership Code" + ' - ' + MMAdmissionServiceEntry."Membership Description";
              end;
            MMAdmissionServiceEntry.Type::Ticket :
              begin
                Name := MMAdmissionServiceEntry."Ticket Type Description";
              end;
          end;

          case MMAdmissionServiceEntry.Type of
            MMAdmissionServiceEntry.Type::Blank :
              begin
                ErrorNumber := '6';
                ErrorDescription := ErrorAdmissionTypeIsBlank;
                DataError := true;
                MMAdmissionServiceEntry."Modify Date" := CurrentDateTime;
              end;
            MMAdmissionServiceEntry.Type::Membership :
              begin
                if MMMemberWebService.MemberCardRegisterArrival(MMAdmissionServiceEntry."External Card No.",'','',MessageText) then begin
                  MMMemberWebService.GetMemberImage(MMAdmissionServiceEntry.Key, PictureBase64, ScannerStationId);
                  if PictureBase64 = '' then
                    GetAvatarImageV2(MMAdmissionServiceSetup,PictureBase64,MMAdmissionServiceEntry."Scanner Station Id");
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
            MMAdmissionServiceEntry.Type::Ticket :
              begin
                if MMAdmissionServiceEntry."External Card No." <> '' then
                  MMMemberWebService.GetMemberImage(MMAdmissionServiceEntry.Key, PictureBase64, ScannerStationId);
                if PictureBase64 = '' then
                  GetAvatarImageV2(MMAdmissionServiceSetup,PictureBase64,MMAdmissionServiceEntry."Scanner Station Id");
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
        Commit;

        exit(MMAdmissionServiceLog."Return Value");
    end;

    [Scope('Personalization')]
    procedure ValidateConnection(ScannerStationId: Code[10]): Text
    begin
        exit('Hallo ' + ScannerStationId);
    end;

    [Scope('Personalization')]
    procedure GetTurnstileImages(ScannerStationId: Code[10];var PictureBase64Default: Text;var PictureExtensionDefault: Text;var PictureBase64Error: Text;var PictureExtensionError: Text): Text
    var
        InStrDefault: InStream;
        InStrError: InStream;
        MMAdmissionServiceSetup: Record "MM Admission Service Setup";
        MMAdmissionScannerStations: Record "MM Admission Scanner Stations";
    begin
        if MMAdmissionScannerStations.Get(ScannerStationId) then begin
          if MMAdmissionScannerStations.Activated then begin

            MMAdmissionScannerStations.CalcFields("Turnstile Default Image","Turnstile Error Image");

            if MMAdmissionScannerStations."Turnstile Default Image".HasValue then begin
              MMAdmissionScannerStations."Turnstile Default Image".CreateInStream(InStrDefault);
              GetImageContentAndExtension(InStrDefault,PictureBase64Default,PictureExtensionDefault);
              Clear(InStrDefault);
            end;

            if MMAdmissionScannerStations."Turnstile Error Image".HasValue then begin
              MMAdmissionScannerStations."Turnstile Error Image".CreateInStream(InStrError);
              GetImageContentAndExtension(InStrError,PictureBase64Error,PictureExtensionError);
              Clear(InStrError);
            end;
          end;
        end;

        MMAdmissionServiceSetup.Get;

        MMAdmissionServiceSetup.CalcFields("Turnstile Default Image","Turnstile Error Image");

        if MMAdmissionServiceSetup."Turnstile Default Image".HasValue and (PictureBase64Default = '') then begin
          MMAdmissionServiceSetup."Turnstile Default Image".CreateInStream(InStrDefault);
          GetImageContentAndExtension(InStrDefault,PictureBase64Default,PictureExtensionDefault);
          Clear(InStrDefault);
        end;

        if MMAdmissionServiceSetup."Turnstile Error Image".HasValue and (PictureBase64Error = '') then begin
          MMAdmissionServiceSetup."Turnstile Error Image".CreateInStream(InStrError);
          GetImageContentAndExtension(InStrError,PictureBase64Error,PictureExtensionError);
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
        Token := DelChr(CopyStr(Format(NewGuid),2,StrLen(Format(NewGuid))-2),'=','-');
        exit(Token);
    end;

    local procedure GetAvatarImage(var MMAdmissionServiceSetup: Record "MM Admission Service Setup";var Base64StringImage: Text) Success: Boolean
    var
        Member: Record "MM Member";
        BinaryReader: DotNet npNetBinaryReader;
        MemoryStream: DotNet npNetMemoryStream;
        Convert: DotNet npNetConvert;
        InStr: InStream;
    begin
        MMAdmissionServiceSetup.CalcFields("Guest Avatar");
        MMAdmissionServiceSetup."Guest Avatar".CreateInStream(InStr);
        MemoryStream := InStr;
        BinaryReader := BinaryReader.BinaryReader(InStr);

        Base64StringImage := Convert.ToBase64String(BinaryReader.ReadBytes(MemoryStream.Length));

        MemoryStream.Dispose;
        Clear(MemoryStream);

        exit(true);
    end;

    local procedure GetAvatarImageV2(var MMAdmissionServiceSetup: Record "MM Admission Service Setup";var Base64StringImage: Text;ScannerStationId: Code[10]) Success: Boolean
    var
        Member: Record "MM Member";
        BinaryReader: DotNet npNetBinaryReader;
        MemoryStream: DotNet npNetMemoryStream;
        Convert: DotNet npNetConvert;
        InStr: InStream;
        MMAdmissionScannerStations: Record "MM Admission Scanner Stations";
    begin
        if MMAdmissionScannerStations.Get(ScannerStationId) then begin
          if MMAdmissionScannerStations.Activated then begin
            MMAdmissionScannerStations.CalcFields("Guest Avatar");
            if MMAdmissionScannerStations."Guest Avatar".HasValue then begin
              MMAdmissionScannerStations."Guest Avatar".CreateInStream(InStr);
              MemoryStream := InStr;
              BinaryReader := BinaryReader.BinaryReader(InStr);

              Base64StringImage := Convert.ToBase64String(BinaryReader.ReadBytes(MemoryStream.Length));

              MemoryStream.Dispose;
              Clear(MemoryStream);

              exit(true);
            end;
          end;
        end;

        MMAdmissionServiceSetup.CalcFields("Guest Avatar");
        MMAdmissionServiceSetup."Guest Avatar".CreateInStream(InStr);
        MemoryStream := InStr;
        BinaryReader := BinaryReader.BinaryReader(InStr);

        Base64StringImage := Convert.ToBase64String(BinaryReader.ReadBytes(MemoryStream.Length));

        MemoryStream.Dispose;
        Clear(MemoryStream);

        exit(true);
    end;

    local procedure GetImageContentAndExtension(InS: InStream;var Base64: Text;var Extension: Text[10])
    var
        Convert: DotNet npNetConvert;
        Bytes: DotNet npNetArray;
        MemoryStream: DotNet npNetMemoryStream;
        Image: DotNet npNetImage;
        ImageFormat: DotNet npNetImageFormat;
        Converter: DotNet npNetImageConverter;
    begin
        MemoryStream := MemoryStream.MemoryStream();
        CopyStream(MemoryStream,InS);

        Bytes := MemoryStream.ToArray();

        Converter := Converter.ImageConverter;
        Image := Converter.ConvertFrom(Bytes);

        if (ImageFormat.Jpeg.Equals(Image.RawFormat)) then
          Extension := 'jpeg'
        else if (ImageFormat.Png.Equals(Image.RawFormat)) then
          Extension := 'png'
        else if (ImageFormat.Gif.Equals(Image.RawFormat)) then
          Extension := 'gif'
        else if (ImageFormat.Bmp.Equals(Image.RawFormat)) then
          Extension := 'bmp'
        else if (ImageFormat.Tiff.Equals(Image.RawFormat)) then
          Extension := 'tiff'
        else if (ImageFormat.Emf.Equals(Image.RawFormat)) then
          Extension := 'emf'
        else if (ImageFormat.Icon.Equals(Image.RawFormat)) then
          Extension := 'icon'
        else if (ImageFormat.Exif.Equals(Image.RawFormat)) then
          Extension := 'exif'
        else if (ImageFormat.Wmf.Equals(Image.RawFormat)) then
          Extension := 'wmf';

        Base64 := Convert.ToBase64String(Bytes);

        MemoryStream.Dispose;
        Clear(MemoryStream);
        Clear(Bytes);
        Clear(InS);
    end;

    [Scope('Personalization')]
    procedure GuestValidationV2(Barcode: Text[50];ScannerStationId: Code[10];var No: Code[20];var Token: Code[50];var ErrorNumber: Code[10];var ErrorDescription: Text;var LightColor: Text[30]): Boolean
    var
        MMMemberWebService: Codeunit "MM Member WebService";
        MemberCard: Record "MM Member Card";
        Member: Record "MM Member";
        TMTicketWebService: Codeunit "TM Ticket WebService";
        MMAdmissionServiceEntry: Record "MM Admission Service Entry";
        DataError: Boolean;
        AdmissionIsValid: Boolean;
        MMAdmissionServiceLog: Record "MM Admission Service Log";
        MMAdmissionServiceSetup: Record "MM Admission Service Setup";
        MessageText: Text[250];
        TMTicket: Record "TM Ticket";
        TMTicketType: Record "TM Ticket Type";
        MMMembership: Record "MM Membership";
        Item: Record Item;
        MMMembershipSetup: Record "MM Membership Setup";
    begin
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
        Commit;

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

        if not DataError then begin
          if MMAdmissionServiceSetup."Validate Members" and not AdmissionIsValid then begin
            if MMMemberWebService.MemberCardNumberValidation(Barcode,ScannerStationId) then begin
              MemberCard.SetCurrentKey("External Card No.");
              MemberCard.SetRange("External Card No.",Barcode);
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

                  //-NPR5.43 [318579]
                  if MMMembership.Get(MemberCard."Membership Entry No.") then begin
                    MMAdmissionServiceEntry."Membership Code" := MMMembership."Membership Code";
                    if MMMembershipSetup.Get(MMMembership."Membership Code") then
                      MMAdmissionServiceEntry."Membership Description" := MMMembershipSetup.Description;
                  end;
                  //+NPR5.43 [318579]

                  AdmissionIsValid := true;
                  LightColor := '2';
                end;
              end;
            end;
          end;
          if MMAdmissionServiceSetup."Validate Tickes" and not AdmissionIsValid then begin
            if TMTicketWebService.ValidateTicketArrival('',Barcode,ScannerStationId,MessageText) then begin

              MMAdmissionServiceLog."Response No" := Barcode;
              MMAdmissionServiceLog."Response Token" := CreateToken();
              No := MMAdmissionServiceLog."Response No";
              Token := MMAdmissionServiceLog."Response Token";

              TMTicket.SetCurrentKey("External Ticket No.");
              TMTicket.SetFilter("External Ticket No.", '=%1', CopyStr (Barcode, 1, MaxStrLen(TMTicket."External Ticket No.")));
              TMTicket.FindFirst;

              MMAdmissionServiceEntry.Type := MMAdmissionServiceEntry.Type::Ticket;
              MMAdmissionServiceEntry.Key := MMAdmissionServiceLog."Response No";
              MMAdmissionServiceEntry."Display Name" := TicketDisplayName;
              MMAdmissionServiceEntry.Message := MessageText;
              MMAdmissionServiceEntry."Ticket Entry No." := TMTicket."No.";
              MMAdmissionServiceEntry."External Ticket No." := TMTicket."External Ticket No.";
              MMAdmissionServiceEntry."External Card No." := TMTicket."External Member Card No.";

              //-NPR5.44 [318579]
        //      IF TMTicketType.GET(TMTicket."Ticket Type Code") THEN BEGIN
        //        MMAdmissionServiceEntry."Ticket Type Code" := TMTicketType.Code;
        //        MMAdmissionServiceEntry."Ticket Type Description" := TMTicketType.Description;
        //      END;
              if Item.Get(TMTicket."Item No.") then begin
                MMAdmissionServiceEntry."Ticket Type Code" := Item."No.";
                if StrLen(Item.Description) > MaxStrLen(MMAdmissionServiceEntry."Ticket Type Description") then
                  MMAdmissionServiceEntry."Ticket Type Description" := CopyStr(Item.Description,1, MaxStrLen(MMAdmissionServiceEntry."Ticket Type Description"))
                else
                  MMAdmissionServiceEntry."Ticket Type Description" := Item.Description;
                //MMAdmissionServiceEntry."Ticket Type Description" := Item.Description;
              end;
              //+NPR5.44 [318579]

              MemberCard.SetCurrentKey("External Card No.");
              MemberCard.SetRange("External Card No.",MMAdmissionServiceEntry."External Card No.");
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
            if StrPos(MessageText,'-1004') > 0 then begin
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
        Commit;

        exit(MMAdmissionServiceLog."Return Value");
    end;
}

