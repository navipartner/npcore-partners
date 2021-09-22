codeunit 6151013 "NPR NpRv Module Send: Def."
{
    TableNo = "NPR NpRv Voucher";

    trigger OnRun()
    var
        Voucher: Record "NPR NpRv Voucher";
    begin
        Voucher := Rec;

        case true of
            Voucher."Send via Print":
                TrySendVoucherViaPrint(Voucher);
            Voucher."Send via E-mail":
                TrySendVoucherViaEmail(Voucher);
            Voucher."Send via SMS":
                TrySendVoucherViaSMS(Voucher);
        end;

        Rec := Voucher;
    end;

    var
        Text000: Label 'Send Voucher - Default (Print)';
        Text001: Label 'Sent using Print Template %1';
        Text002: Label 'Sent using E-mail Template %1';
        Text003: Label 'Sent using SMS Template %1';

    procedure SendVoucher(NpRvVoucher: Record "NPR NpRv Voucher")
    var
        ErrorText: Text;
        LastErrorText: Text;
    begin
        Commit();
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
            Error(CopyStr(ErrorText, 1, 1000));
    end;

    procedure SendVoucherViaPrint(Voucher: Record "NPR NpRv Voucher") LastErrorText: Text
    var
        NpRvSendingLog: Record "NPR NpRv Sending Log";
        Voucher2: Record "NPR NpRv Voucher";
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
    begin
        Voucher2 := Voucher;
        Voucher2."Send via E-mail" := false;
        Voucher2."Send via SMS" := false;

        ClearLastError();
        if not Codeunit.Run(Codeunit::"NPR NpRv Module Send: Def.", Voucher2) then begin
            LastErrorText := GetLastErrorText;
            NpRvVoucherMgt.LogSending(Voucher, NpRvSendingLog."Sending Type"::Print, StrSubstNo(Text001, Voucher."Print Template Code"), '', LastErrorText);
        end;
        Commit();
        exit(LastErrorText);
    end;

    local procedure TrySendVoucherViaPrint(var Voucher: Record "NPR NpRv Voucher")
    var
        RPTemplateMgt: Codeunit "NPR RP Template Mgt.";
    begin
        if Voucher.Find() then;
        if Voucher."Print Template Code" = '' then
            exit;
        Voucher.SetRecFilter();
        RPTemplateMgt.PrintTemplate(Voucher."Print Template Code", Voucher, 0);
    end;

    procedure SendVoucherViaEmail(Voucher: Record "NPR NpRv Voucher") LastErrorText: Text
    var
        NpRvSendingLog: Record "NPR NpRv Sending Log";
        Voucher2: Record "NPR NpRv Voucher";
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
    begin
        Voucher2 := Voucher;
        Voucher2."Send via Print" := false;
        Voucher2."Send via SMS" := false;

        ClearLastError();
        if not Codeunit.Run(Codeunit::"NPR NpRv Module Send: Def.", Voucher2) then begin
            LastErrorText := GetLastErrorText;
            NpRvVoucherMgt.LogSending(Voucher, NpRvSendingLog."Sending Type"::"E-mail", StrSubstNo(Text002, Voucher2."E-mail Template Code"), Voucher."E-mail", LastErrorText);
        end;
        Commit();
        exit(LastErrorText);
    end;

    local procedure TrySendVoucherViaEmail(var Voucher: Record "NPR NpRv Voucher")
    var
        EmailTemplateHeader: Record "NPR E-mail Template Header";
        EmailManagement: Codeunit "NPR E-mail Management";
        RecRef: RecordRef;
    begin
        if Voucher.Find() then;
        if Voucher."E-mail Template Code" <> '' then begin
            if EmailTemplateHeader.Get(Voucher."E-mail Template Code") then
                EmailTemplateHeader.SetRecFilter();
        end;

        RecRef.GetTable(Voucher);
        RecRef.SetRecFilter();
        if EmailTemplateHeader."Report ID" > 0 then
            EmailManagement.SendReportTemplate(EmailTemplateHeader."Report ID", RecRef, EmailTemplateHeader, Voucher."E-mail", true)
        else
            EmailManagement.SendEmailTemplate(RecRef, EmailTemplateHeader, Voucher."E-mail", true);
        Voucher."E-mail Template Code" := EmailTemplateHeader.Code;
    end;

    procedure SendVoucherViaSMS(Voucher: Record "NPR NpRv Voucher") LastErrorText: Text
    var
        NpRvSendingLog: Record "NPR NpRv Sending Log";
        Voucher2: Record "NPR NpRv Voucher";
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
    begin
        Voucher2 := Voucher;
        Voucher2."Send via Print" := false;
        Voucher2."Send via E-mail" := false;

        ClearLastError();
        if not Codeunit.Run(Codeunit::"NPR NpRv Module Send: Def.", Voucher2) then begin
            LastErrorText := GetLastErrorText;
            NpRvVoucherMgt.LogSending(Voucher, NpRvSendingLog."Sending Type"::SMS, StrSubstNo(Text003, Voucher."SMS Template Code"), Voucher."Phone No.", LastErrorText);
        end;
        Commit();
        exit(LastErrorText);
    end;

    local procedure TrySendVoucherViaSMS(var Voucher: Record "NPR NpRv Voucher")
    var
        SMSTemplateHeader: Record "NPR SMS Template Header";
        SMSManagement: Codeunit "NPR SMS Management";
        SMSMessage: Text;
    begin
        if Voucher.Find() then;
        if (Voucher."SMS Template Code" = '') or (not SMSTemplateHeader.Get(Voucher."SMS Template Code")) then begin
            if not SMSManagement.FindTemplate(Voucher, SMSTemplateHeader) then
                exit;
            Voucher."SMS Template Code" := SMSTemplateHeader.Code;
        end;

        SMSMessage := SMSManagement.MakeMessage(SMSTemplateHeader, Voucher);
        SMSManagement.SendSMS(Voucher."Phone No.", SMSTemplateHeader."Alt. Sender", SMSMessage);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151011, 'OnInitVoucherModules', '', true, true)]
    local procedure OnInitVoucherModules(var VoucherModule: Record "NPR NpRv Voucher Module")
    begin
        if VoucherModule.Get(VoucherModule.Type::"Send Voucher", ModuleCode()) then
            exit;

        VoucherModule.Init();
        VoucherModule.Type := VoucherModule.Type::"Send Voucher";
        VoucherModule.Code := ModuleCode();
        VoucherModule.Description := Text000;
        VoucherModule."Event Codeunit ID" := CurrCodeunitId();
        VoucherModule.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151011, 'OnHasSendVoucherSetup', '', true, true)]
    local procedure OnHasSendVoucherSetup(VoucherType: Record "NPR NpRv Voucher Type"; var HasSendSetup: Boolean)
    begin
        if not IsSubscriber(VoucherType) then
            exit;

        HasSendSetup := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151011, 'OnSetupSendVoucher', '', true, true)]
    local procedure OnSetupSendVoucher(var VoucherType: Record "NPR NpRv Voucher Type")
    var
        EmailTemplateHeader: Record "NPR E-mail Template Header";
        RPTemplateHeader: Record "NPR RP Template Header";
        SMSTemplateHeader: Record "NPR SMS Template Header";
        Selection: Integer;
    begin
        if not IsSubscriber(VoucherType) then
            exit;

        Selection := VoucherType."Send Method via POS";
        if Selection = VoucherType."Send Method via POS"::Ask then
            Selection := SelectSendMethod(VoucherType);

        case Selection of
            VoucherType."Send Method via POS"::Print:
                begin
                    VoucherType.TestField("Print Template Code");
                    RPTemplateHeader.Get(VoucherType."Print Template Code");
                    PAGE.Run(PAGE::"NPR RP Template Card", RPTemplateHeader);
                end;
            VoucherType."Send Method via POS"::"E-mail":
                begin
                    VoucherType.TestField("E-mail Template Code");
                    EmailTemplateHeader.Get(VoucherType."E-mail Template Code");
                    PAGE.Run(PAGE::"NPR E-mail Template", EmailTemplateHeader);
                end;
            VoucherType."Send Method via POS"::SMS:
                begin
                    VoucherType.TestField("SMS Template Code");
                    SMSTemplateHeader.Get(VoucherType."SMS Template Code");
                    PAGE.Run(PAGE::"NPR SMS Template Card", SMSTemplateHeader);
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151011, 'OnRunSendVoucher', '', true, true)]
    local procedure OnRunSendVoucher(Voucher: Record "NPR NpRv Voucher"; VoucherType: Record "NPR NpRv Voucher Type"; var Handled: Boolean)
    begin
        if Handled then
            exit;
        if not IsSubscriber(VoucherType) then
            exit;

        Handled := true;

        SendVoucher(Voucher);
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR NpRv Module Send: Def.");
    end;

    local procedure IsSubscriber(VoucherType: Record "NPR NpRv Voucher Type"): Boolean
    begin
        exit(VoucherType."Send Voucher Module" = ModuleCode());
    end;

    local procedure ModuleCode(): Code[20]
    begin
        exit('DEFAULT');
    end;

    procedure SelectSendMethod(VoucherType: Record "NPR NpRv Voucher Type") Selection: Integer
    var
        SelectionStr: Text;
    begin
        Selection := VoucherType."Send Method via POS";
        if VoucherType."Send Method via POS" = VoucherType."Send Method via POS"::Ask then begin
            SelectionStr := GetSendMethodSelectionStr(VoucherType, Selection);
            if Selection > 0 then
                Selection := StrMenu(SelectionStr, Selection, VoucherType.FieldCaption("Send Method via POS"));
            Selection -= 1;
        end;

        exit(Selection);
    end;

    local procedure GetSendMethodSelectionStr(VoucherType: Record "NPR NpRv Voucher Type"; var Selection: Integer) SelectionStr: Text
    begin
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
    end;

    local procedure NewLine() CRLF: Text[2]
    begin
        CRLF[1] := 13;
        CRLF[2] := 10;
        exit(CRLF);
    end;
}