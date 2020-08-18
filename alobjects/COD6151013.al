codeunit 6151013 "NpRv Module Send - Default"
{
    // NPR5.37/MHA /20171023  CASE 267346 Object created - NaviPartner Retail Voucher
    // NPR5.43/MHA /20180606  CASE 307022 Added RecFilter in PrintVoucher()
    // NPR5.48/MHA /20190123  CASE 341711 Added Send Methods E-mail and SMS
    // NPR5.55/MHA /20200702  CASE 407070 Object created


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Send Voucher - Default (Print)';
        Text001: Label 'Sent using Print Template %1';
        Text002: Label 'Sent using E-mail Template %1';
        Text003: Label 'Sent using SMS Template %1';

    procedure SendVoucher(NpRvVoucher: Record "NpRv Voucher")
    var
        ErrorText: Text;
        LastErrorText: Text;
    begin
        //-NPR5.55 [407070]
        Commit;
        if NpRvVoucher."Send via Print" then begin
          LastErrorText := SendVoucherViaPrint(NpRvVoucher);
          if LastErrorText <> '' then
            ErrorText := LastErrorText;
        end;

        if NpRvVoucher."Send via E-mail" then begin
          LastErrorText := SendVoucherViaEmail(NpRvVoucher);
          if LastErrorText <> '' then begin
            if ErrorText <> '' then
              ErrorText += NewLine();
            ErrorText += LastErrorText;
          end;
        end;

        if NpRvVoucher."Send via SMS" then begin
          LastErrorText := SendVoucherViaSMS(NpRvVoucher);
          if LastErrorText <> '' then begin
            if ErrorText <> '' then
              ErrorText += NewLine();
            ErrorText += LastErrorText;
          end;
        end;

        if ErrorText <> '' then
          Error(CopyStr(ErrorText,1,1000));
        //+NPR5.55 [407070]
    end;

    procedure SendVoucherViaPrint(Voucher: Record "NpRv Voucher") LastErrorText: Text
    var
        NpRvSendingLog: Record "NpRv Sending Log";
        NpRvVoucherMgt: Codeunit "NpRv Voucher Mgt.";
        RPTemplateMgt: Codeunit "RP Template Mgt.";
    begin
        if Voucher."Print Template Code" = '' then
            exit;

        //-NPR5.43 [307022]
        Voucher.SetRecFilter;
        //+NPR5.43 [307022]

        //-NPR5.55 [407070]
        asserterror begin
          RPTemplateMgt.PrintTemplate(Voucher."Print Template Code",Voucher,0);
          Commit;
          Error('');
        end;
        LastErrorText := GetLastErrorText;
        NpRvVoucherMgt.LogSending(Voucher,NpRvSendingLog."Sending Type"::Print,StrSubstNo(Text001,Voucher."Print Template Code"),'',LastErrorText);
        Commit;
        exit(LastErrorText);
        //+NPR5.55 [407070]
    end;

    procedure SendVoucherViaEmail(Voucher: Record "NpRv Voucher") LastErrorText: Text
    var
        NpRvSendingLog: Record "NpRv Sending Log";
        EmailTemplateHeader: Record "E-mail Template Header";
        TempBlob: Codeunit "Temp Blob";
        BarcodeLibrary: Codeunit "Barcode Library";
        EmailManagement: Codeunit "E-mail Management";
        NpRvVoucherMgt: Codeunit "NpRv Voucher Mgt.";
        RecRef: RecordRef;
    begin
        //-NPR5.55 [407070]
        asserterror begin
          if Voucher."E-mail Template Code" <> '' then begin
            if EmailTemplateHeader.Get(Voucher."E-mail Template Code") then
              EmailTemplateHeader.SetRecFilter;
          end;

          if not Voucher.Barcode.HasValue then begin
            BarcodeLibrary.GenerateBarcode(Voucher."Reference No.", TempBlob);

            RecRef.GetTable(Voucher);
            TempBlob.ToRecordRef(RecRef, Voucher.FieldNo(Barcode));
            RecRef.SetTable(Voucher);

            Voucher.Modify;
          end;
          RecRef.GetTable(Voucher);
          RecRef.SetRecFilter;
          if EmailTemplateHeader."Report ID" > 0 then
            EmailManagement.SendReportTemplate(EmailTemplateHeader."Report ID",RecRef,EmailTemplateHeader,Voucher."E-mail",true)
          else
            EmailManagement.SendEmailTemplate(RecRef,EmailTemplateHeader,Voucher."E-mail",true);
          Commit;
          Error('');
        end;
        LastErrorText := GetLastErrorText;
        NpRvVoucherMgt.LogSending(Voucher,NpRvSendingLog."Sending Type"::"E-mail",StrSubstNo(Text002,EmailTemplateHeader.Code),Voucher."E-mail",LastErrorText);
        Commit;
        exit(LastErrorText);
        //+NPR5.55 [407070]
    end;

    procedure SendVoucherViaSMS(Voucher: Record "NpRv Voucher") LastErrorText: Text
    var
        NpRvSendingLog: Record "NpRv Sending Log";
        SMSTemplateHeader: Record "SMS Template Header";
        SMSManagement: Codeunit "SMS Management";
        NpRvVoucherMgt: Codeunit "NpRv Voucher Mgt.";
        SMSMessage: Text;
        Sender: Text;
    begin
        //-NPR5.55 [407070]
        asserterror begin
          if (Voucher."SMS Template Code" = '') or (not SMSTemplateHeader.Get(Voucher."SMS Template Code")) then begin
            if not SMSManagement.FindTemplate(Voucher,SMSTemplateHeader) then
              exit;
          end;

          SMSMessage := SMSManagement.MakeMessage(SMSTemplateHeader,Voucher);
          SMSManagement.SendSMS(Voucher."Phone No.",SMSTemplateHeader."Alt. Sender",SMSMessage);
          Commit;
          Error('');
        end;
        LastErrorText := GetLastErrorText;
        NpRvVoucherMgt.LogSending(Voucher,NpRvSendingLog."Sending Type"::SMS,StrSubstNo(Text003,SMSTemplateHeader.Code),Voucher."Phone No.",LastErrorText);
        Commit;
        exit(LastErrorText);
        //+NPR5.55 [407070]
    end;

    local procedure "--- Voucher Interface"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151011, 'OnInitVoucherModules', '', true, true)]
    local procedure OnInitVoucherModules(var VoucherModule: Record "NpRv Voucher Module")
    begin
        if VoucherModule.Get(VoucherModule.Type::"Send Voucher", ModuleCode()) then
            exit;

        VoucherModule.Init;
        VoucherModule.Type := VoucherModule.Type::"Send Voucher";
        VoucherModule.Code := ModuleCode();
        VoucherModule.Description := Text000;
        VoucherModule."Event Codeunit ID" := CurrCodeunitId();
        VoucherModule.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151011, 'OnHasSendVoucherSetup', '', true, true)]
    local procedure OnHasSendVoucherSetup(VoucherType: Record "NpRv Voucher Type"; var HasSendSetup: Boolean)
    begin
        if not IsSubscriber(VoucherType) then
            exit;

        HasSendSetup := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151011, 'OnSetupSendVoucher', '', true, true)]
    local procedure OnSetupSendVoucher(var VoucherType: Record "NpRv Voucher Type")
    var
        EmailTemplateHeader: Record "E-mail Template Header";
        RPTemplateHeader: Record "RP Template Header";
        SMSTemplateHeader: Record "SMS Template Header";
        Selection: Integer;
    begin
        if not IsSubscriber(VoucherType) then
            exit;

        //-NPR5.48 [341711]
        // VoucherType.TESTFIELD("Print Template Code");
        // RPTemplateHeader.GET(VoucherType."Print Template Code");
        // PAGE.RUN(PAGE::"RP Template Card",RPTemplateHeader);
        Selection := VoucherType."Send Method via POS";
        if Selection = VoucherType."Send Method via POS"::Ask then
            Selection := SelectSendMethod(VoucherType);

        case Selection of
            VoucherType."Send Method via POS"::Print:
                begin
                    VoucherType.TestField("Print Template Code");
                    RPTemplateHeader.Get(VoucherType."Print Template Code");
                    PAGE.Run(PAGE::"RP Template Card", RPTemplateHeader);
                end;
            VoucherType."Send Method via POS"::"E-mail":
                begin
                    VoucherType.TestField("E-mail Template Code");
                    EmailTemplateHeader.Get(VoucherType."E-mail Template Code");
                    PAGE.Run(PAGE::"E-mail Template", EmailTemplateHeader);
                end;
            VoucherType."Send Method via POS"::SMS:
                begin
                    VoucherType.TestField("SMS Template Code");
                    SMSTemplateHeader.Get(VoucherType."SMS Template Code");
                    PAGE.Run(PAGE::"SMS Template Card", SMSTemplateHeader);
                end;
        end;
        //+NPR5.48 [341711]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151011, 'OnRunSendVoucher', '', true, true)]
    local procedure OnRunSendVoucher(Voucher: Record "NpRv Voucher"; VoucherType: Record "NpRv Voucher Type"; var Handled: Boolean)
    begin
        if Handled then
            exit;
        if not IsSubscriber(VoucherType) then
            exit;

        Handled := true;

        //-NPR5.48 [341711]
        //PrintVoucher(Voucher);
        SendVoucher(Voucher);
        //+NPR5.48 [341711]
    end;

    local procedure "--- Aux"()
    begin
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NpRv Module Send - Default");
    end;

    local procedure IsSubscriber(VoucherType: Record "NpRv Voucher Type"): Boolean
    begin
        exit(VoucherType."Send Voucher Module" = ModuleCode());
    end;

    local procedure ModuleCode(): Code[20]
    begin
        exit('DEFAULT');
    end;

    procedure SelectSendMethod(VoucherType: Record "NpRv Voucher Type") Selection: Integer
    var
        SelectionStr: Text;
    begin
        //-NPR5.48 [341711]
        Selection := VoucherType."Send Method via POS";
        if VoucherType."Send Method via POS" = VoucherType."Send Method via POS"::Ask then begin
            SelectionStr := GetSendMethodSelectionStr(VoucherType, Selection);
            if Selection > 0 then
                Selection := StrMenu(SelectionStr, Selection, VoucherType.FieldCaption("Send Method via POS"));
            Selection -= 1;
        end;

        exit(Selection);
        //+NPR5.48 [341711]
    end;

    local procedure GetSendMethodSelectionStr(VoucherType: Record "NpRv Voucher Type"; var Selection: Integer) SelectionStr: Text
    begin
        //-NPR5.48 [341711]
        Selection := 0;
        if VoucherType."Print Template Code" <> '' then begin
            SelectionStr := Format(VoucherType."Send Method via POS"::Print);
            Selection := 1;
        end;

        SelectionStr += ',';
        if VoucherType."E-mail Template Code" <> '' then begin
            SelectionStr += Format(VoucherType."Send Method via POS"::"E-mail");
            Selection := 2;
        end;

        SelectionStr += ',';
        if VoucherType."SMS Template Code" <> '' then begin
            SelectionStr += Format(VoucherType."Send Method via POS"::SMS);
            Selection := 3;
        end;

        exit(SelectionStr);
        //+NPR5.48 [341711]
    end;

    local procedure NewLine() CRLF: Text[2]
    begin
        //-NPR5.55 [407070]
        CRLF[1] := 13;
        CRLF[2] := 10;
        exit(CRLF);
        //+NPR5.55 [407070]
    end;
}

