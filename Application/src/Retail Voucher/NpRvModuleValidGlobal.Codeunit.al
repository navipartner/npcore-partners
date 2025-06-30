codeunit 6151019 "NPR NpRv Module Valid.: Global"
{
    Access = Internal;

    var
        Text000: Label 'Validate Global Voucher';
        Text001: Label 'Voucher is being used';
        Text005: Label 'Invalid Reference No. %1';

    [EventSubscriber(ObjectType::Table, Database::"NPR NpRv Partner", 'OnAfterInsertEvent', '', true, true)]
    local procedure OnInsertPartner(var Rec: Record "NPR NpRv Partner"; RunTrigger: Boolean)
    begin
        ValidateGlobalVoucherSetups(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NpRv Partner", 'OnAfterModifyEvent', '', true, true)]
    local procedure OnModifyPartner(var Rec: Record "NPR NpRv Partner"; var xRec: Record "NPR NpRv Partner"; RunTrigger: Boolean)
    begin
        ValidateGlobalVoucherSetups(Rec);
    end;

    local procedure ValidateGlobalVoucherSetups(NpRvPartner: Record "NPR NpRv Partner")
    var
        NpRvGlobalVoucherSetup: Record "NPR NpRv Global Vouch. Setup";
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
    begin
        NpRvVoucherType.SetRange("Partner Code", NpRvPartner.Code);
        NpRvVoucherType.SetRange("Validate Voucher Module", ModuleCode());
        if not NpRvVoucherType.FindSet() then
            exit;

        repeat
            if NpRvGlobalVoucherSetup.Get(NpRvVoucherType.Code) then
                if TryValidateGlobalVoucherSetup(NpRvGlobalVoucherSetup) then;
        until NpRvVoucherType.Next() = 0;
    end;

    [TryFunction]
    procedure TryValidateGlobalVoucherSetup(NpRvGlobalVoucherSetup: Record "NPR NpRv Global Vouch. Setup")
    var
        NpRvPartner: Record "NPR NpRv Partner";
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
        WebServiceAuthHelper: Codeunit "NPR Web Service Auth. Helper";
        Client: HttpClient;
        RequestMessage: HttpRequestMessage;
        ContentHeader: HttpHeaders;
        [NonDebuggable]
        RequestHeaders: HttpHeaders;
        ResponseMessage: HttpResponseMessage;
        ResponseText: Text;
        RequestXmlText: Text;
    begin
        NpRvVoucherType.Get(NpRvGlobalVoucherSetup."Voucher Type");
        if NpRvVoucherType."Validate Voucher Module" <> ModuleCode() then
            exit;

        NpRvPartner.Get(NpRvVoucherType."Partner Code");
        NpRvGlobalVoucherSetup.TestField("Service Url");

        RequestXmlText
         :=
          '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">' +
             '<soapenv:Body>' +
               '<UpsertPartners xmlns="urn:microsoft-dynamics-schemas/codeunit/' + GetServiceName(NpRvGlobalVoucherSetup) + '">' +
                 '<retail_voucher_partners>' +
                   '<retail_voucher_partner partner_code="' + NpRvPartner.Code + '">' +
                     '<name>' + '<![CDATA[' + NpRvPartner.Name + ']]>' + '</name>' +
                     '<service_url>' + '<![CDATA[' + NpRvPartner."Service Url" + ']]>' + '</service_url>' +
                     '<service_username>' + '<![CDATA[' + NpRvPartner."Service Username" + ']]>' + '</service_username>' +
                     '<service_password>' + '<![CDATA[' + WebServiceAuthHelper.GetApiPassword(NpRvPartner."API Password Key") + ']]>' + '</service_password>' +
                     '<relations>' +
                       '<relation voucher_type="' + NpRvGlobalVoucherSetup."Voucher Type" + '" />' +
                     '</relations>' +
                   '</retail_voucher_partner>' +
                 '</retail_voucher_partners>' +
               '</UpsertPartners>' +
            '</soapenv:Body>' +
          '</soapenv:Envelope>';

        RequestMessage.GetHeaders(RequestHeaders);
        if RequestHeaders.Contains('Connection') then
            RequestHeaders.Remove('Connection');
        NpRvGlobalVoucherSetup.SetRequestHeadersAuthorization(RequestHeaders);

        RequestMessage.Content.WriteFrom(RequestXmlText);
        RequestMessage.Content.GetHeaders(ContentHeader);
        if ContentHeader.Contains('Content-Type') then
            ContentHeader.Remove('Content-Type');
        ContentHeader.Add('Content-Type', 'text/xml; charset=utf-8');
        if ContentHeader.Contains('SOAPAction') then
            ContentHeader.Remove('SOAPAction');
        ContentHeader.Add('SOAPAction', 'UpsertPartners');

        RequestMessage.Method := 'POST';
        RequestMessage.SetRequestUri(NpRvGlobalVoucherSetup."Service Url");

        Client.Send(RequestMessage, ResponseMessage);

        if not ResponseMessage.IsSuccessStatusCode() then begin
            ResponseMessage.Content.ReadAs(ResponseText);
            ThrowGlobalVoucherWSError(ResponseMessage.ReasonPhrase, ResponseText);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRv Module Mgt.", 'OnInitVoucherModules', '', true, true)]
    local procedure OnInitVoucherModules(var VoucherModule: Record "NPR NpRv Voucher Module")
    begin
        if VoucherModule.Get(VoucherModule.Type::"Validate Voucher", ModuleCode()) then
            exit;

        VoucherModule.Init();
        VoucherModule.Type := VoucherModule.Type::"Validate Voucher";
        VoucherModule.Code := ModuleCode();
        VoucherModule.Description := Text000;
        VoucherModule."Event Codeunit ID" := CurrCodeunitId();
        VoucherModule.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRv Module Mgt.", 'OnHasValidateVoucherSetup', '', true, true)]
    local procedure OnHasValidateVoucherSetup(VoucherType: Record "NPR NpRv Voucher Type"; var HasValidateSetup: Boolean)
    begin
        if not IsSubscriber(VoucherType) then
            exit;

        HasValidateSetup := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRv Module Mgt.", 'OnSetupValidateVoucher', '', true, true)]
    local procedure OnSetupValidateVoucher(var VoucherType: Record "NPR NpRv Voucher Type")
    var
        NpRvGlobalVoucherSetup: Record "NPR NpRv Global Vouch. Setup";
    begin
        if not IsSubscriber(VoucherType) then
            exit;

        VoucherType.TestField("Partner Code");
        if not NpRvGlobalVoucherSetup.Get(VoucherType.Code) then begin
            NpRvGlobalVoucherSetup.Init();
            NpRvGlobalVoucherSetup."Voucher Type" := VoucherType.Code;
            NpRvGlobalVoucherSetup.Insert(true);
        end;

        NpRvGlobalVoucherSetup.FilterGroup(2);
        NpRvGlobalVoucherSetup.SetRecFilter();
        NpRvGlobalVoucherSetup.FilterGroup(0);
        PAGE.Run(PAGE::"NPR NpRv Global Voucher Setup", NpRvGlobalVoucherSetup);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRv Module Mgt.", 'OnRunValidateVoucher', '', true, true)]
    local procedure OnRunValidateVoucher(var TempNpRvVoucherBuffer: Record "NPR NpRv Voucher Buffer" temporary; var Handled: Boolean)
    begin
        if Handled then
            exit;
        if TempNpRvVoucherBuffer."Validate Voucher Module" <> ModuleCode() then
            exit;

        Handled := true;

        ReserveVoucher(TempNpRvVoucherBuffer);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRv Module Mgt.", 'OnAfterApplyPaymentV3', '', true, true)]
    local procedure OnAfterApplyPaymentV3(var TempNpRvVoucherBuffer: Record "NPR NpRv Voucher Buffer" temporary; SaleLinePOSVoucher: Record "NPR NpRv Sales Line"; POSLine: Record "NPR POS Sale Line")
    var
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
    begin

        if TempNpRvVoucherBuffer."Validate Voucher Module" <> ModuleCode() then
            exit;
        if NpRvVoucherMgt.VoucherReservationByAmountFeatureEnabled() then
            SendVoucherReservation(TempNpRvVoucherBuffer, SaleLinePOSVoucher, POSLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRv Module Mgt.", 'OnRunFindVoucher', '', true, true)]
    local procedure OnRunFindVoucher(VoucherTypeCode: Code[20]; ReferenceNo: Text[50]; var Voucher: Record "NPR NpRv Voucher"; var Handled: Boolean)
    var
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
    begin
        if Handled then
            exit;
        if NpRvVoucherType.Get(VoucherTypeCode) then;
        if NpRvVoucherType."Validate Voucher Module" <> ModuleCode() then
            exit;

        if FindVoucher(ReferenceNo, NpRvVoucherType, Voucher) then
            Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRv Module Mgt.", 'OnRunRedeemVoucher', '', true, true)]
    local procedure OnRunRedeemVoucher(VoucherEntry: Record "NPR NpRv Voucher Entry"; Voucher: Record "NPR NpRv Voucher"; var Handled: Boolean)
    var
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
    begin
        if Handled then
            exit;

        NpRvVoucherType.Get(Voucher."Voucher Type");
        if NpRvVoucherType."Validate Voucher Module" <> ModuleCode() then
            exit;

        Handled := true;

        RedeemVoucher(VoucherEntry, Voucher);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRv Module Mgt.", 'OnRunCreateGlobalVoucher', '', true, true)]
    local procedure OnRunCreateGlobalVoucher(Voucher: Record "NPR NpRv Voucher"; var Handled: Boolean)
    var
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
    begin
        if Handled then
            exit;

        NpRvVoucherType.Get(Voucher."Voucher Type");
        if NpRvVoucherType."Validate Voucher Module" <> ModuleCode() then
            exit;

        Handled := true;

        CreateGlobalVoucher(Voucher);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRv Module Mgt.", 'OnRunTopUpVoucher', '', true, true)]
    local procedure OnRunTopUpVoucher(VoucherEntry: Record "NPR NpRv Voucher Entry"; Voucher: Record "NPR NpRv Voucher"; var Handled: Boolean)
    var
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
    begin
        if Handled then
            exit;

        NpRvVoucherType.Get(Voucher."Voucher Type");
        if NpRvVoucherType."Validate Voucher Module" <> ModuleCode() then
            exit;

        Handled := true;

        TopUpVoucher(VoucherEntry, Voucher);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRv Module Mgt.", 'OnRunUpdateVoucherAmount', '', true, true)]
    local procedure OnRunUpdateVoucherAmount(Voucher: Record "NPR NpRv Voucher"; var Handled: Boolean)
    var
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
    begin
        if Handled then
            exit;

        NpRvVoucherType.Get(Voucher."Voucher Type");
        if NpRvVoucherType."Validate Voucher Module" <> ModuleCode() then
            exit;

        Handled := true;

        UpdateVoucherAmount(Voucher);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRv Module Mgt.", 'OnRunTryValidateGlobalVoucherSetup', '', true, true)]
    local procedure OnRunTryValidateGlobalVoucherSetup(NpRvGlobalVoucherSetup: Record "NPR NpRv Global Vouch. Setup"; var Handled: Boolean)
    var
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
    begin
        if Handled then
            exit;

        NpRvVoucherType.Get(NpRvGlobalVoucherSetup."Voucher Type");
        if NpRvVoucherType."Validate Voucher Module" <> ModuleCode() then
            exit;

        Handled := true;

        TryValidateGlobalVoucherSetup(NpRvGlobalVoucherSetup);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NpRv Sales Line", 'OnBeforeDeleteEvent', '', true, true)]
    local procedure OnBeforeDeletePOSVoucher(var Rec: Record "NPR NpRv Sales Line"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary then
            exit;

        if TryCancelReservation(Rec) then;
    end;

    [TryFunction]
    procedure TryCancelReservation(NpRvSaleLinePOSVoucher: Record "NPR NpRv Sales Line")
    var
        NpRvGlobalVoucherSetup: Record "NPR NpRv Global Vouch. Setup";
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
        Client: HttpClient;
        RequestMessage: HttpRequestMessage;
        [NonDebuggable]
        RequestHeaders: HttpHeaders;
        ContentHeader: HttpHeaders;
        ResponseMessage: HttpResponseMessage;
        RequestXmlText: Text;
        ResponseText: Text;
    begin
        if not NpRvVoucherType.Get(NpRvSaleLinePOSVoucher."Voucher Type") then
            exit;
        if NpRvVoucherType."Validate Voucher Module" <> ModuleCode() then
            exit;
        if not NpRvGlobalVoucherSetup.Get(NpRvVoucherType.Code) then
            exit;
        if NpRvGlobalVoucherSetup."Service Url" = '' then
            exit;

        RequestXmlText :=
          '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">' +
            '<soapenv:Body>' +
              '<CancelReserveVouchers xmlns="urn:microsoft-dynamics-schemas/codeunit/' + GetServiceName(NpRvGlobalVoucherSetup) + '">' +
                '<vouchers>' +
                  '<voucher reference_no="' + NpRvSaleLinePOSVoucher."Reference No." + '" voucher_type="' + NpRvSaleLinePOSVoucher."Voucher Type" + '"' +
                  ' xmlns="urn:microsoft-dynamics-schemas/codeunit/' + GetServiceName(NpRvGlobalVoucherSetup) + '">' +
                    '<redeem_date>' + Format(NpRvSaleLinePOSVoucher."Sale Date", 0, 9) + '</redeem_date>' +
                    '<redeem_register_no>' + NpRvSaleLinePOSVoucher."Register No." + '</redeem_register_no>' +
                    '<redeem_sales_ticket_no>' + NpRvSaleLinePOSVoucher."Sales Ticket No." + '</redeem_sales_ticket_no>' +
                  '</voucher>' +
                '</vouchers>' +
              '</CancelReserveVouchers>' +
            '</soapenv:Body>' +
          '</soapenv:Envelope>';

        RequestMessage.GetHeaders(RequestHeaders);
        if RequestHeaders.Contains('Connection') then
            RequestHeaders.Remove('Connection');
        NpRvGlobalVoucherSetup.SetRequestHeadersAuthorization(RequestHeaders);

        RequestMessage.Content.WriteFrom(RequestXmlText);
        RequestMessage.Content.GetHeaders(ContentHeader);
        if ContentHeader.Contains('Content-Type') then
            ContentHeader.Remove('Content-Type');
        ContentHeader.Add('Content-Type', 'text/xml; charset=utf-8');
        if ContentHeader.Contains('SOAPAction') then
            ContentHeader.Remove('SOAPAction');
        ContentHeader.Add('SOAPAction', 'CancelReserveVouchers');

        RequestMessage.Method := 'POST';
        RequestMessage.SetRequestUri(NpRvGlobalVoucherSetup."Service Url");

        Client.Send(RequestMessage, ResponseMessage);

        if not ResponseMessage.IsSuccessStatusCode() then begin
            ResponseMessage.Content.ReadAs(ResponseText);
            ThrowGlobalVoucherWSError(ResponseMessage.ReasonPhrase, ResponseText);
        end;
    end;

    internal procedure CreateGlobalVoucher(Voucher: Record "NPR NpRv Voucher")
    var
        NpRvGlobalVoucherSetup: Record "NPR NpRv Global Vouch. Setup";
        POSUnit: Record "NPR POS Unit";
        StoreCode: Code[10];
        Client: HttpClient;
        RequestMessage: HttpRequestMessage;
        ContentHeader: HttpHeaders;
        [NonDebuggable]
        RequestHeaders: HttpHeaders;
        ResponseMessage: HttpResponseMessage;
        RequestXmlText: Text;
        ResponseText: Text;
    begin
        Voucher.CalcFields("Validate Voucher Module");
        if Voucher."Validate Voucher Module" <> ModuleCode() then
            exit;

        NpRvGlobalVoucherSetup.Get(Voucher."Voucher Type");
        NpRvGlobalVoucherSetup.TestField("Service Url");

        Voucher.CalcFields(Amount, "Issue Date", "Issue Register No.", "Issue Document No.", "Issue User ID");
        if POSUnit.Get(Voucher."Issue Register No.") then
            StoreCode := POSUnit."POS Store Code";
        RequestXmlText :=
          '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">' +
            '<soapenv:Body>' +
              '<CreateVouchers xmlns="urn:microsoft-dynamics-schemas/codeunit/' + GetServiceName(NpRvGlobalVoucherSetup) + '">' +
                '<vouchers>' +
                  '<voucher reference_no="' + Voucher."Reference No." + '" voucher_type="' + Voucher."Voucher Type" + '" xmlns="urn:microsoft-dynamics-schemas/codeunit/global_voucher_service">' +
                    '<description>' + Voucher.Description + '</description>' +
                    '<starting_date>' + Format(Voucher."Starting Date", 0, 9) + '</starting_date>' +
                    '<ending_date>' + Format(Voucher."Ending Date", 0, 9) + '</ending_date>' +
                    '<account_no>' + Voucher."Account No." + '</account_no>' +
                    '<amount>' + Format(Voucher.Amount, 0, 9) + '</amount>' +
                    '<name>' + Voucher.Name + '</name>' +
                    '<name_2>' + Voucher."Name 2" + '</name_2>' +
                    '<address>' + Voucher.Address + '</address>' +
                    '<address_2>' + Voucher."Address 2" + '</address_2>' +
                    '<post_code>' + Voucher."Post Code" + '</post_code>' +
                    '<city>' + Voucher.City + '</city>' +
                    '<county>' + Voucher.County + '</county>' +
                    '<country_code>' + Voucher."Country/Region Code" + '</country_code>' +
                    '<email>' + Voucher."E-mail" + '</email>' +
                    '<phone_no>' + Voucher."Phone No." + '</phone_no>' +
                    '<voucher_message>' + Voucher."Voucher Message" + '</voucher_message>' +
                    '<issue_date>' + Format(Voucher."Issue Date", 0, 9) + '</issue_date>' +
                    '<issue_register_no>' + Voucher."Issue Register No." + '</issue_register_no>' +
                    '<issue_sales_ticket_no>' + Voucher."Issue Document No." + '</issue_sales_ticket_no>' +
                    '<issue_user_id>' + Voucher."Issue User ID" + '</issue_user_id>' +
                    '<issue_partner_code>' + '<![CDATA[' + CopyStr(CompanyName(), 1, 20) + ']]>' + '</issue_partner_code>' +
                    '<issue_posstore_code>' + StoreCode + '</issue_posstore_code>' +
                    '<company>' + '<![CDATA[' + CompanyName() + ']]>' + '</company>' +
                  '</voucher>' +
                '</vouchers>' +
              '</CreateVouchers>' +
            '</soapenv:Body>' +
          '</soapenv:Envelope>';

        RequestMessage.GetHeaders(RequestHeaders);
        if RequestHeaders.Contains('Connection') then
            RequestHeaders.Remove('Connection');
        NpRvGlobalVoucherSetup.SetRequestHeadersAuthorization(RequestHeaders);

        RequestMessage.Content.WriteFrom(RequestXmlText);
        RequestMessage.Content.GetHeaders(ContentHeader);
        if ContentHeader.Contains('Content-Type') then
            ContentHeader.Remove('Content-Type');
        ContentHeader.Add('Content-Type', 'text/xml; charset=utf-8');
        if ContentHeader.Contains('SOAPAction') then
            ContentHeader.Remove('SOAPAction');
        ContentHeader.Add('SOAPAction', 'CreateVouchers');

        RequestMessage.Method := 'POST';
        RequestMessage.SetRequestUri(NpRvGlobalVoucherSetup."Service Url");

        Client.Send(RequestMessage, ResponseMessage);
        if not ResponseMessage.IsSuccessStatusCode() then begin
            ResponseMessage.Content.ReadAs(ResponseText);
            ThrowGlobalVoucherWSError(ResponseMessage.ReasonPhrase, ResponseText);
        end;
    end;

    procedure FindVoucher(ReferenceNo: Text[50]; NpRvVoucherType: Record "NPR NpRv Voucher Type"; var Voucher: Record "NPR NpRv Voucher") Found: Boolean
    var
        NpRvGlobalVoucherSetup: Record "NPR NpRv Global Vouch. Setup";
        VoucherEntry: Record "NPR NpRv Voucher Entry";
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        XmlDomManagement: codeunit "XML DOM Management";
        Client: HttpClient;
        RequestMessage: HttpRequestMessage;
        ContentHeader: HttpHeaders;
        [NonDebuggable]
        RequestHeaders: HttpHeaders;
        ResponseMessage: HttpResponseMessage;
        Document: XmlDocument;
        Node: XmlNode;
        RequestXmlText: Text;
        ResponseText: Text;
        VoucherAmount: Decimal;
        VoucherTypeCode: Code[20];
        AvailableAmount: Decimal;
    begin
        if not NpRvGlobalVoucherSetup.Get(NpRvVoucherType.Code) then
            NpRvGlobalVoucherSetup.FindFirst();
        NpRvGlobalVoucherSetup.TestField("Service Url");

        RequestXmlText :=
          '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">' +
            '<soapenv:Body>' +
              '<FindVouchers xmlns="urn:microsoft-dynamics-schemas/codeunit/' + GetServiceName(NpRvGlobalVoucherSetup) + '">' +
                '<vouchers>' +
                  '<voucher reference_no="' + ReferenceNo + '" voucher_type="' + NpRvVoucherType.Code + '" xmlns="urn:microsoft-dynamics-schemas/codeunit/global_voucher_service">' +
                    '<redeem_partner_code>' + NpRvVoucherType."Partner Code" + '</redeem_partner_code>' +
                  '</voucher>' +
                '</vouchers>' +
              '</FindVouchers>' +
            '</soapenv:Body>' +
          '</soapenv:Envelope>';

        RequestMessage.GetHeaders(RequestHeaders);
        if RequestHeaders.Contains('Connection') then
            RequestHeaders.Remove('Connection');
        NpRvGlobalVoucherSetup.SetRequestHeadersAuthorization(RequestHeaders);

        RequestMessage.Content.WriteFrom(RequestXmlText);
        RequestMessage.Content.GetHeaders(ContentHeader);
        if ContentHeader.Contains('Content-Type') then
            ContentHeader.Remove('Content-Type');
        ContentHeader.Add('Content-Type', 'text/xml; charset=utf-8');
        if ContentHeader.Contains('SOAPAction') then
            ContentHeader.Remove('SOAPAction');
        ContentHeader.Add('SOAPAction', 'FindVouchers');

        RequestMessage.Method := 'POST';
        RequestMessage.SetRequestUri(NpRvGlobalVoucherSetup."Service Url");
        Client.Send(RequestMessage, ResponseMessage);
        ResponseMessage.Content.ReadAs(ResponseText);
        if not ResponseMessage.IsSuccessStatusCode() then
            ThrowGlobalVoucherWSError(ResponseMessage.ReasonPhrase, ResponseText);

        ResponseText := XmlDomManagement.RemoveNamespaces(ResponseText);
        XmlDocument.ReadFrom(ResponseText, Document);
        if not NpXmlDomMgt.FindNode(Document.AsXmlNode(), '//Body/FindVouchers_Result/vouchers/voucher', Node) then
            Error(Text005, ReferenceNo);

        if Evaluate(VoucherAmount, NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'amount', 0, false), 9) then;
        if NpRvVoucherType.Code = '' then begin
#pragma warning disable AA0139
            VoucherTypeCode := NpXmlDomMgt.GetAttributeCode(Node.AsXmlElement(), '', 'voucher_type', MaxStrLen(VoucherTypeCode), true);
#pragma warning restore
            NpRvVoucherType.Get(VoucherTypeCode);
        end;
        Clear(Voucher);
        Voucher.SetRange("Reference No.", ReferenceNo);
        Voucher.SetRange("Voucher Type", NpRvVoucherType.Code);
        if not Voucher.FindLast() then begin
            NpRvVoucherMgt.InitVoucher(NpRvVoucherType, '', ReferenceNo, 0DT, true, Voucher);

            VoucherEntry.Init();
            VoucherEntry."Entry No." := 0;
            VoucherEntry."Voucher No." := Voucher."No.";
            VoucherEntry."Entry Type" := VoucherEntry."Entry Type"::"Partner Issue Voucher";
            VoucherEntry."Voucher Type" := Voucher."Voucher Type";
            VoucherEntry.Amount := VoucherAmount;
            VoucherEntry."Remaining Amount" := VoucherEntry.Amount;
            VoucherEntry.Positive := VoucherEntry.Amount > 0;
            if Evaluate(VoucherEntry."Posting Date", NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'issue_date', 0, false), 9) then;
            VoucherEntry.Open := VoucherEntry.Amount <> 0;
#pragma warning disable AA0139
            VoucherEntry."Register No." := NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'issue_register_no', MaxStrLen(VoucherEntry."Register No."), false);
            VoucherEntry."Document No." := NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'issue_sales_ticket_no', MaxStrLen(VoucherEntry."Document No."), false);
            VoucherEntry."User ID" := NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'issue_user_id', MaxStrLen(VoucherEntry."User ID"), false);
            VoucherEntry."Closed by Entry No." := 0;
            VoucherEntry."Partner Code" := UpperCase(NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'issue_partner_code', MaxStrLen(VoucherEntry."Partner Code"), false));
            VoucherEntry."POS Store Code" := NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'issue_posstore_code', MaxStrLen(VoucherEntry."POS Store Code"), false);
            VoucherEntry.Company := NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'issue_company', MaxStrLen(VoucherEntry.Company), false);
            VoucherEntry.Insert();
            Found := true;
        end;

        Voucher.Description := NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'description', MaxStrLen(Voucher.Description), false);
        if Evaluate(Voucher."Starting Date", NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'starting_date', 0, false), 9) then;
        if Evaluate(Voucher."Ending Date", NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'ending_date', 0, false), 9) then;
        Voucher."Account No." := NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'account_no', MaxStrLen(Voucher."Account No."), false);
        Voucher.Name := NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'name', MaxStrLen(Voucher.Name), false);
        Voucher."Name 2" := NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'name_2', MaxStrLen(Voucher."Name 2"), false);
        Voucher.Address := NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'address', MaxStrLen(Voucher.Address), false);
        Voucher."Address 2" := NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'address_2', MaxStrLen(Voucher."Address 2"), false);
        Voucher."Post Code" := NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'post_code', MaxStrLen(Voucher."Post Code"), false);
        Voucher.City := NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'city', MaxStrLen(Voucher.City), false);
        Voucher.County := NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'county', MaxStrLen(Voucher.County), false);
        Voucher."Country/Region Code" := NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'country_code', MaxStrLen(Voucher."Country/Region Code"), false);
        Voucher."E-mail" := NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'email', MaxStrLen(Voucher."E-mail"), false);
        Voucher."Phone No." := NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'pohone_no', MaxStrLen(Voucher."Phone No."), false);
        Voucher."Voucher Message" := NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'voucher_message', MaxStrLen(Voucher."Voucher Message"), false);
        if Evaluate(Voucher."Issue Date", NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'issue_date', 0, false), 9) then;
#pragma warning restore
        Voucher.Modify(true);
        Commit();

        if NpRvVoucherMgt.VoucherReservationByAmountFeatureEnabled() then begin
            UpdateReservationEntries(Node.AsXmlElement(), Voucher);

            Commit();

            Voucher.CalcFields(Amount);
            AvailableAmount := Voucher.Amount;
            if AvailableAmount <> VoucherAmount then
                PostSyncEntry(Voucher, VoucherAmount - AvailableAmount, Node);
        end;
    end;

    local procedure UpdateReservationEntries(XmlElement: XmlElement; NpRvVoucher: Record "NPR NpRv Voucher")
    var
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        TempNpRvSalesLineBuffer: Record "NPR NpRv Sales Line Buffer" temporary;
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        NodeList: XmlNodeList;
        Node: XmlNode;

    begin
        if XmlElement.SelectSingleNode('reservation_lines', Node) then begin
            Node.SelectNodes('reservation_line', NodeList);
            foreach Node in NodeList do begin
                TempNpRvSalesLineBuffer.Init();
                Evaluate(TempNpRvSalesLineBuffer.Id, NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'id_', 0, false), 9);
                TempNpRvSalesLineBuffer."Reservation Line Id" := NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'reservation_line_id', 0, false);
                if Evaluate(TempNpRvSalesLineBuffer.Amount, NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'amount_', 0, false), 9) then;
                TempNpRvSalesLineBuffer.Insert();

            end;
        end;

        if TempNpRvSalesLineBuffer.IsEmpty then
            exit;

        if TempNpRvSalesLineBuffer.FindSet() then
            repeat
                if not NpRvSalesLine.Get(TempNpRvSalesLineBuffer.Id) then begin
                    NpRvSalesLine.Init();
                    NpRvSalesLine.Id := TempNpRvSalesLineBuffer.Id;
                    NpRvSalesLine."Reference No." := NpRvVoucher."Reference No.";
                    NpRvSalesLine."Voucher No." := NpRvVoucher."No.";
                    NpRvSalesLine.Type := NpRvSalesLine.Type::Payment;
                    NpRvSalesLine."Voucher Type" := NpRvVoucher."Voucher Type";
                    NpRvSalesLine."Reservation Line Id" := TempNpRvSalesLineBuffer."Reservation Line Id";
                    NpRvSalesLine.Amount := TempNpRvSalesLineBuffer.Amount;
                    NpRvSalesLine.Insert();
                end;
            until TempNpRvSalesLineBuffer.Next() = 0;

        Commit();
        clear(NpRvSalesLine);
        NpRvSalesLine.SetRange("Voucher No.", NpRvVoucher."No.");
        if NpRvSalesLine.FindSet() then
            repeat
                if not TempNpRvSalesLineBuffer.Get(NpRvSalesLine.id) then
                    NpRvSalesLine.Delete();
            until NpRvSalesLine.Next() = 0;


    end;

    procedure ReserveVoucher(var TempNpRvVoucherBuffer: Record "NPR NpRv Voucher Buffer" temporary)
    var
        Voucher: Record "NPR NpRv Voucher";
        NpRvGlobalVoucherSetup: Record "NPR NpRv Global Vouch. Setup";
        VoucherType: Record "NPR NpRv Voucher Type";
        VoucherEntry: Record "NPR NpRv Voucher Entry";
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        XmlDomManagement: codeunit "XML DOM Management";
        Client: HttpClient;
        RequestMessage: HttpRequestMessage;
        ContentHeader: HttpHeaders;
        [NonDebuggable]
        RequestHeaders: HttpHeaders;
        ResponseMessage: HttpResponseMessage;
        Document: XmlDocument;
        Node: XmlNode;
        RequestXmlText: Text;
        ReferenceNo: Text[50];
        ResponseText: Text;
        AvailableAmount: Decimal;
        VoucherAmount: Decimal;
        GlobalReservationId: Guid;
    begin
        ReferenceNo := TempNpRvVoucherBuffer."Reference No.";
        VoucherType.Get(TempNpRvVoucherBuffer."Voucher Type");
        if VoucherType."Validate Voucher Module" <> ModuleCode() then
            exit;
        NpRvGlobalVoucherSetup.Get(VoucherType.Code);
        NpRvGlobalVoucherSetup.TestField("Service Url");

        if not NpRvVoucherMgt.VoucherReservationByAmountFeatureEnabled() then begin
            Voucher.SetRange("Reference No.", ReferenceNo);
            Voucher.SetRange("Voucher Type", VoucherType.Code);
            if Voucher.FindFirst() then begin
                if Voucher.CalcInUseQty() > 0 then
                    Error(Text001);
            end;
        end;

        RequestXmlText :=
          '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">' +
            '<soapenv:Body>' +
              '<ReserveVouchers xmlns="urn:microsoft-dynamics-schemas/codeunit/' + GetServiceName(NpRvGlobalVoucherSetup) + '">' +
                '<vouchers>' +
                  '<voucher reference_no="' + ReferenceNo + '" voucher_type="' + VoucherType.Code + '" xmlns="urn:microsoft-dynamics-schemas/codeunit/global_voucher_service">' +
                    '<redeem_date>' + Format(TempNpRvVoucherBuffer."Redeem Date", 0, 9) + '</redeem_date>' +
                    '<redeem_register_no>' + TempNpRvVoucherBuffer."Redeem Register No." + '</redeem_register_no>' +
                    '<redeem_sales_ticket_no>' + TempNpRvVoucherBuffer."Redeem Sales Ticket No." + '</redeem_sales_ticket_no>' +
                    '<redeem_user_id>' + TempNpRvVoucherBuffer."Redeem User ID" + '</redeem_user_id>' +
                    '<redeem_partner_code>' + '<![CDATA[' + CopyStr(CompanyName(), 1, 20) + ']]>' + '</redeem_partner_code>' +
                    '<issue_posstore_code>' + TempNpRvVoucherBuffer."POS Store Code" + '</issue_posstore_code>' +
                    '<company>' + '<![CDATA[' + TempNpRvVoucherBuffer.Company + ']]>' + '</company>' +
                  '</voucher>' +
                '</vouchers>' +
              '</ReserveVouchers>' +
            '</soapenv:Body>' +
          '</soapenv:Envelope>';

        RequestMessage.GetHeaders(RequestHeaders);
        if RequestHeaders.Contains('Connection') then
            RequestHeaders.Remove('Connection');

        NpRvGlobalVoucherSetup.SetRequestHeadersAuthorization(RequestHeaders);

        RequestMessage.Content.WriteFrom(RequestXmlText);
        RequestMessage.Content.GetHeaders(ContentHeader);
        if ContentHeader.Contains('Content-Type') then
            ContentHeader.Remove('Content-Type');
        ContentHeader.Add('Content-Type', 'text/xml; charset=utf-8');
        if ContentHeader.Contains('SOAPAction') then
            ContentHeader.Remove('SOAPAction');
        ContentHeader.Add('SOAPAction', 'ReserveVouchers');

        RequestMessage.Method := 'POST';
        RequestMessage.SetRequestUri(NpRvGlobalVoucherSetup."Service Url");

        Client.Send(RequestMessage, ResponseMessage);
        ResponseMessage.Content.ReadAs(ResponseText);
        if not ResponseMessage.IsSuccessStatusCode() then
            ThrowGlobalVoucherWSError(ResponseMessage.ReasonPhrase, ResponseText);

        ResponseText := XmlDomManagement.RemoveNamespaces(ResponseText);
        XmlDocument.ReadFrom(ResponseText, Document);
        if not NpXmlDomMgt.FindNode(Document.AsXmlNode(), '//Body/ReserveVouchers_Result/vouchers/voucher', Node) then
            Error(Text005, ReferenceNo);

        if Evaluate(VoucherAmount, NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'amount', 0, false), 9) then;
        if Evaluate(GlobalReservationId, NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'global_reservation_id', 0, false), 9) then;
        Clear(Voucher);
        Voucher.SetRange("Reference No.", ReferenceNo);
        Voucher.SetRange("Voucher Type", VoucherType.Code);
        if not Voucher.FindLast() then begin
            NpRvVoucherMgt.InitVoucher(VoucherType, '', ReferenceNo, 0DT, true, Voucher);

            VoucherEntry.Init();
            VoucherEntry."Entry No." := 0;
            VoucherEntry."Voucher No." := Voucher."No.";
            VoucherEntry."Entry Type" := VoucherEntry."Entry Type"::"Partner Issue Voucher";
            VoucherEntry."Voucher Type" := Voucher."Voucher Type";
            VoucherEntry.Amount := VoucherAmount;
            VoucherEntry."Remaining Amount" := VoucherEntry.Amount;
            VoucherEntry.Positive := VoucherEntry.Amount > 0;
            if Evaluate(VoucherEntry."Posting Date", NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'issue_date', 0, false), 9) then;
            VoucherEntry.Open := VoucherEntry.Amount <> 0;
#pragma warning disable AA0139
            VoucherEntry."Register No." := NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'issue_register_no', MaxStrLen(VoucherEntry."Register No."), false);
            VoucherEntry."POS Store Code" := NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'issue_posstore_code', MaxStrLen(VoucherEntry."POS Store Code"), false);
            VoucherEntry.Company := NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'issue_company', MaxStrLen(VoucherEntry.Company), false);
            VoucherEntry."Document No." := NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'issue_sales_ticket_no', MaxStrLen(VoucherEntry."Document No."), false);
            VoucherEntry."User ID" := NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'issue_user_id', MaxStrLen(VoucherEntry."User ID"), false);
            VoucherEntry."Closed by Entry No." := 0;
            VoucherEntry."Partner Code" := UpperCase(NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'issue_partner_code', MaxStrLen(VoucherEntry."Partner Code"), false));
            VoucherEntry.Insert();
        end;

        Voucher.Description := NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'description', MaxStrLen(Voucher.Description), false);
        if Evaluate(Voucher."Starting Date", NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'starting_date', 0, false), 9) then;
        if Evaluate(Voucher."Ending Date", NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'ending_date', 0, false), 9) then;
        Voucher."Account No." := NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'account_no', MaxStrLen(Voucher."Account No."), false);

        Voucher.Name := NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'name', MaxStrLen(Voucher.Name), false);
        Voucher."Name 2" := NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'name_2', MaxStrLen(Voucher."Name 2"), false);
        Voucher.Address := NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'address', MaxStrLen(Voucher.Address), false);
        Voucher."Address 2" := NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'address_2', MaxStrLen(Voucher."Address 2"), false);
        Voucher."Post Code" := NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'post_code', MaxStrLen(Voucher."Post Code"), false);
        Voucher.City := NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'city', MaxStrLen(Voucher.City), false);
        Voucher.County := NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'county', MaxStrLen(Voucher.County), false);
        Voucher."Country/Region Code" := NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'country_code', MaxStrLen(Voucher."Country/Region Code"), false);
        Voucher."E-mail" := NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'email', MaxStrLen(Voucher."E-mail"), false);
        Voucher."Phone No." := NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'pohone_no', MaxStrLen(Voucher."Phone No."), false);
        Voucher."Voucher Message" := NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'voucher_message', MaxStrLen(Voucher."Voucher Message"), false);
        if Evaluate(Voucher."Issue Date", NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'issue_date', 0, false), 9) then;
#pragma warning restore
        Voucher.Modify(true);
        Voucher.CalcFields(Amount);
        AvailableAmount := Voucher.Amount;
        if AvailableAmount <> VoucherAmount then
            PostSyncEntry(Voucher, VoucherAmount - AvailableAmount, Node);

        TempNpRvVoucherBuffer."Global Reservation Id" := NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'global_reservation_id', 0, false);
        NpRvVoucherMgt.Voucher2Buffer(Voucher, TempNpRvVoucherBuffer);
    end;

    procedure SendVoucherReservation(var TempNpRvVoucherBuffer: Record "NPR NpRv Voucher Buffer" temporary; SaleLinePOSVoucher: Record "NPR NpRv Sales Line"; POSLine: Record "NPR POS Sale Line")
    var
        Voucher: Record "NPR NpRv Voucher";
        NpRvGlobalVoucherSetup: Record "NPR NpRv Global Vouch. Setup";
        VoucherType: Record "NPR NpRv Voucher Type";
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        Client: HttpClient;
        RequestMessage: HttpRequestMessage;
        ContentHeader: HttpHeaders;
        [NonDebuggable]
        RequestHeaders: HttpHeaders;
        ResponseMessage: HttpResponseMessage;
        RequestXmlText: Text;
        ReferenceNo: Text[50];
        ResponseText: Text;
    begin
        ReferenceNo := TempNpRvVoucherBuffer."Reference No.";
        VoucherType.Get(TempNpRvVoucherBuffer."Voucher Type");
        if VoucherType."Validate Voucher Module" <> ModuleCode() then
            exit;
        NpRvGlobalVoucherSetup.Get(VoucherType.Code);
        NpRvGlobalVoucherSetup.TestField("Service Url");

        if not NpRvVoucherMgt.VoucherReservationByAmountFeatureEnabled() then begin
            Voucher.SetRange("Reference No.", ReferenceNo);
            Voucher.SetRange("Voucher Type", VoucherType.Code);
            if Voucher.FindFirst() then begin
                if Voucher.CalcInUseQty() > 0 then
                    Error(Text001);
            end;
        end;

        RequestXmlText :=
          '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">' +
            '<soapenv:Body>' +
              '<VoucherReservationbyAmount xmlns="urn:microsoft-dynamics-schemas/codeunit/' + GetServiceName(NpRvGlobalVoucherSetup) + '">' +
                '<vouchers>' +
                  '<voucher reference_no="' + ReferenceNo + '" voucher_type="' + VoucherType.Code + '" xmlns="urn:microsoft-dynamics-schemas/codeunit/global_voucher_service">' +
                    '<redeem_date>' + Format(TempNpRvVoucherBuffer."Redeem Date", 0, 9) + '</redeem_date>' +
                    '<redeem_register_no>' + TempNpRvVoucherBuffer."Redeem Register No." + '</redeem_register_no>' +
                    '<redeem_sales_ticket_no>' + TempNpRvVoucherBuffer."Redeem Sales Ticket No." + '</redeem_sales_ticket_no>' +
                    '<redeem_user_id>' + TempNpRvVoucherBuffer."Redeem User ID" + '</redeem_user_id>' +
                    '<redeem_partner_code>' + '<![CDATA[' + CopyStr(CompanyName(), 1, 20) + ']]>' + '</redeem_partner_code>' +
                    '<issue_posstore_code>' + TempNpRvVoucherBuffer."POS Store Code" + '</issue_posstore_code>' +
                    '<company>' + '<![CDATA[' + TempNpRvVoucherBuffer.Company + ']]>' + '</company>' +
                    '<reservation_lines>' +
                        '<reservation_line>' +
                          '<id_>' + SaleLinePOSVoucher.Id + '</id_>' +
                          '<reservation_line_id>' + POSLine.SystemId + '</reservation_line_id>' +
                          '<amount_>' + Format(POSLine."Amount Including VAT", 0, 9) + '</amount_>' +
                        '</reservation_line>' +
                    '</reservation_lines>' +
                  '</voucher>' +
                '</vouchers>' +
              '</VoucherReservationbyAmount>' +
            '</soapenv:Body>' +
          '</soapenv:Envelope>';

        RequestMessage.GetHeaders(RequestHeaders);
        if RequestHeaders.Contains('Connection') then
            RequestHeaders.Remove('Connection');

        NpRvGlobalVoucherSetup.SetRequestHeadersAuthorization(RequestHeaders);

        RequestMessage.Content.WriteFrom(RequestXmlText);
        RequestMessage.Content.GetHeaders(ContentHeader);
        if ContentHeader.Contains('Content-Type') then
            ContentHeader.Remove('Content-Type');
        ContentHeader.Add('Content-Type', 'text/xml; charset=utf-8');
        if ContentHeader.Contains('SOAPAction') then
            ContentHeader.Remove('SOAPAction');
        ContentHeader.Add('SOAPAction', 'VoucherReservationbyAmount');

        RequestMessage.Method := 'POST';
        RequestMessage.SetRequestUri(NpRvGlobalVoucherSetup."Service Url");

        Client.Send(RequestMessage, ResponseMessage);
        ResponseMessage.Content.ReadAs(ResponseText);
        if not ResponseMessage.IsSuccessStatusCode() then
            ThrowGlobalVoucherWSError(ResponseMessage.ReasonPhrase, ResponseText);
    end;

    procedure RedeemVoucher(VoucherEntry: Record "NPR NpRv Voucher Entry"; Voucher: Record "NPR NpRv Voucher")
    var
        NpRvGlobalVoucherSetup: Record "NPR NpRv Global Vouch. Setup";
        Client: HttpClient;
        RequestMessage: HttpRequestMessage;
        ContentHeader: HttpHeaders;
        [NonDebuggable]
        RequestHeaders: HttpHeaders;
        ResponseMessage: HttpResponseMessage;
        RequestXmlText: Text;
        ResponseText: Text;
    begin
        Voucher.CalcFields("Validate Voucher Module");
        if Voucher."Validate Voucher Module" <> ModuleCode() then
            exit;
        NpRvGlobalVoucherSetup.Get(Voucher."Voucher Type");
        NpRvGlobalVoucherSetup.TestField("Service Url");

        //PaymentLineRecordIdText := Format(VoucherEntry."Reservation Line Id", 0, 9);

        RequestXmlText :=
          '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">' +
            '<soapenv:Body>' +
              '<RedeemVouchers xmlns="urn:microsoft-dynamics-schemas/codeunit/' + GetServiceName(NpRvGlobalVoucherSetup) + '">' +
                '<vouchers>' +
                  '<voucher reference_no="' + Voucher."Reference No." + '" voucher_type="' + Voucher."Voucher Type" + '" xmlns="urn:microsoft-dynamics-schemas/codeunit/global_voucher_service">' +
                    '<amount>' + Format(-VoucherEntry.Amount, 0, 9) + '</amount>' +
                    '<redeem_date>' + Format(VoucherEntry."Posting Date", 0, 9) + '</redeem_date>' +
                    '<redeem_register_no>' + VoucherEntry."Register No." + '</redeem_register_no>' +
                    '<redeem_sales_ticket_no>' + VoucherEntry."Document No." + '</redeem_sales_ticket_no>' +
                    '<redeem_user_id>' + VoucherEntry."User ID" + '</redeem_user_id>' +
                    '<redeem_partner_code>' + '<![CDATA[' + CopyStr(CompanyName(), 1, 20) + ']]>' + '</redeem_partner_code>' +
                    '<reservation_line_id>' + VoucherEntry."Reservation Line Id" + '</reservation_line_id>' +
                    '<issue_posstore_code>' + VoucherEntry."POS Store Code" + '</issue_posstore_code>' +
                    '<company>' + '<![CDATA[' + VoucherEntry.Company + ']]>' + '</company>' +
                    '<global_redeem_checked>true</global_redeem_checked>' +
                  '</voucher>' +
                '</vouchers>' +
              '</RedeemVouchers>' +
            '</soapenv:Body>' +
          '</soapenv:Envelope>';

        RequestMessage.GetHeaders(RequestHeaders);
        if RequestHeaders.Contains('Connection') then
            RequestHeaders.Remove('Connection');
        NpRvGlobalVoucherSetup.SetRequestHeadersAuthorization(RequestHeaders);

        RequestMessage.Content.WriteFrom(RequestXmlText);
        RequestMessage.Content.GetHeaders(ContentHeader);
        if ContentHeader.Contains('Content-Type') then
            ContentHeader.Remove('Content-Type');
        ContentHeader.Add('Content-Type', 'text/xml; charset=utf-8');
        if ContentHeader.Contains('SOAPAction') then
            ContentHeader.Remove('SOAPAction');
        ContentHeader.Add('SOAPAction', 'RedeemVouchers');

        RequestMessage.Method := 'POST';
        RequestMessage.SetRequestUri(NpRvGlobalVoucherSetup."Service Url");

        Client.Send(RequestMessage, ResponseMessage);

        if not ResponseMessage.IsSuccessStatusCode() then begin
            ResponseMessage.Content.ReadAs(ResponseText);
            ThrowGlobalVoucherWSError(ResponseMessage.ReasonPhrase, ResponseText);
        end;
    end;

    procedure RedeemPartnerVouchers(VoucherEntry: Record "NPR NpRv Voucher Entry"; Voucher: Record "NPR NpRv Voucher")
    var
        NpRvPartner: Record "NPR NpRv Partner";
        NpRvPartnerRelation: Record "NPR NpRv Partner Relation";
        PartnerVoucherEntry: Record "NPR NpRv Voucher Entry";
        NpRvPartnerMgt: Codeunit "NPR NpRv Partner Mgt.";
        Client: HttpClient;
        RequestMessage: HttpRequestMessage;
        ContentHeader: HttpHeaders;
        [NonDebuggable]
        RequestHeaders: HttpHeaders;
        ResponseMessage: HttpResponseMessage;
        RequestXmlText: Text;
        ResponseText: Text;
    begin
        PartnerVoucherEntry.SetCurrentKey("Voucher No.", "Entry Type", "Partner Code");
        PartnerVoucherEntry.SetRange("Voucher No.", VoucherEntry."Voucher No.");
        PartnerVoucherEntry.SetFilter("Entry Type", '%1|%2', PartnerVoucherEntry."Entry Type"::"Issue Voucher", PartnerVoucherEntry."Entry Type"::"Partner Issue Voucher");

        case VoucherEntry."Entry Type" of
            VoucherEntry."Entry Type"::Payment:
                begin
                    PartnerVoucherEntry.SetFilter("Partner Code", '<>%1', VoucherEntry."Partner Code");
                    if not PartnerVoucherEntry.FindFirst() then
                        exit;
                end;
            VoucherEntry."Entry Type"::"Partner Payment":
                begin
                    PartnerVoucherEntry.FindFirst();
                    if VoucherEntry."Partner Code" = PartnerVoucherEntry."Partner Code" then
                        exit;
                end;
        end;

        if not NpRvPartner.Get(PartnerVoucherEntry."Partner Code") then
            exit;
        if NpRvPartner."Service Url" = '' then
            exit;
        if not NpRvPartnerRelation.Get(NpRvPartner.Code, Voucher."Voucher Type") then
            exit;

        RequestXmlText :=
          '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">' +
            '<soapenv:Body>' +
              '<RedeemPartnerVouchers xmlns="urn:microsoft-dynamics-schemas/codeunit/' + NpRvPartnerMgt.GetServiceName(NpRvPartner) + '">' +
                '<vouchers>' +
                  '<voucher reference_no="' + Voucher."Reference No." + '"' +
                  ' voucher_type="' + Voucher."Voucher Type" + '" xmlns="urn:microsoft-dynamics-schemas/codeunit/' + NpRvPartnerMgt.GetServiceName(NpRvPartner) + '">' +
                    '<amount>' + Format(-VoucherEntry.Amount, 0, 9) + '</amount>' +
                    '<redeem_date>' + Format(VoucherEntry."Posting Date", 0, 9) + '</redeem_date>' +
                    '<redeem_register_no>' + VoucherEntry."Register No." + '</redeem_register_no>' +
                    '<redeem_sales_ticket_no>' + VoucherEntry."Document No." + '</redeem_sales_ticket_no>' +
                    '<redeem_user_id>' + VoucherEntry."User ID" + '</redeem_user_id>' +
                    '<redeem_partner_code>' + '<![CDATA[' + CopyStr(CompanyName(), 1, 20) + ']]>' + '</redeem_partner_code>' +
                    '<issue_posstore_code>' + VoucherEntry."POS Store Code" + '</issue_posstore_code>' +
                    '<company>' + '<![CDATA[' + VoucherEntry.Company + ']]>' + '</company>' +
                  '</voucher>' +
                '</vouchers>' +
              '</RedeemPartnerVouchers>' +
            '</soapenv:Body>' +
          '</soapenv:Envelope>';

        RequestMessage.GetHeaders(RequestHeaders);
        if RequestHeaders.Contains('Connection') then
            RequestHeaders.Remove('Connection');
        NpRvPartner.SetRequestHeadersAuthorization(RequestHeaders);

        RequestMessage.Content.WriteFrom(RequestXmlText);
        RequestMessage.Content.GetHeaders(ContentHeader);

        if ContentHeader.Contains('Content-Type') then
            ContentHeader.Remove('Content-Type');
        ContentHeader.Add('Content-Type', 'text/xml; charset=utf-8');
        if ContentHeader.Contains('SOAPAction') then
            ContentHeader.Remove('SOAPAction');
        ContentHeader.Add('SOAPAction', 'RedeemPartnerVouchers');

        RequestMessage.Method := 'POST';
        RequestMessage.SetRequestUri(NpRvPartner."Service Url");

        Client.Send(RequestMessage, ResponseMessage);

        if not ResponseMessage.IsSuccessStatusCode() then begin
            ResponseMessage.Content.ReadAs(ResponseText);
            ThrowGlobalVoucherWSError(ResponseMessage.ReasonPhrase, ResponseText);
        end;
    end;

    procedure TopUpVoucher(VoucherEntry: Record "NPR NpRv Voucher Entry"; Voucher: Record "NPR NpRv Voucher")
    var
        NpRvGlobalVoucherSetup: Record "NPR NpRv Global Vouch. Setup";
        Client: HttpClient;
        RequestMessage: HttpRequestMessage;
        [NonDebuggable]
        RequestHeaders: HttpHeaders;
        ResponseMessage: HttpResponseMessage;
        ContentHeader: HttpHeaders;
        RequestXmlText: Text;
        ResponseText: Text;
    begin
        if not NpRvGlobalVoucherSetup.Get(Voucher."Voucher Type") then
            exit;
        NpRvGlobalVoucherSetup.TestField("Service Url");

        RequestXmlText :=
          '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">' +
            '<soapenv:Body>' +
              '<TopUpVouchers xmlns="urn:microsoft-dynamics-schemas/codeunit/' + GetServiceName(NpRvGlobalVoucherSetup) + '">' +
                '<vouchers>' +
                  '<voucher reference_no="' + Voucher."Reference No." + '" voucher_type="' + Voucher."Voucher Type" + '" xmlns="urn:microsoft-dynamics-schemas/codeunit/global_voucher_service">' +
                    '<amount>' + Format(VoucherEntry.Amount, 0, 9) + '</amount>' +
                    '<redeem_date>' + Format(VoucherEntry."Posting Date", 0, 9) + '</redeem_date>' +
                    '<redeem_register_no>' + VoucherEntry."Register No." + '</redeem_register_no>' +
                    '<redeem_sales_ticket_no>' + VoucherEntry."Document No." + '</redeem_sales_ticket_no>' +
                    '<redeem_user_id>' + VoucherEntry."User ID" + '</redeem_user_id>' +
                    '<redeem_partner_code>' + '<![CDATA[' + CopyStr(CompanyName(), 1, 20) + ']]>' + '</redeem_partner_code>' +
                    '<issue_posstore_code>' + VoucherEntry."POS Store Code" + '</issue_posstore_code>' +
                    '<company>' + '<![CDATA[' + VoucherEntry.Company + ']]>' + '</company>' +
                  '</voucher>' +
                '</vouchers>' +
              '</TopUpVouchers>' +
            '</soapenv:Body>' +
          '</soapenv:Envelope>';

        RequestMessage.GetHeaders(RequestHeaders);
        if RequestHeaders.Contains('Connection') then
            RequestHeaders.Remove('Connection');
        NpRvGlobalVoucherSetup.SetRequestHeadersAuthorization(RequestHeaders);

        RequestMessage.Content.WriteFrom(RequestXmlText);
        RequestMessage.Content.GetHeaders(ContentHeader);
        if ContentHeader.Contains('Content-Type') then
            ContentHeader.Remove('Content-Type');
        ContentHeader.Add('Content-Type', 'text/xml; charset=utf-8');
        if ContentHeader.Contains('SOAPAction') then
            ContentHeader.Remove('SOAPAction');
        ContentHeader.Add('SOAPAction', 'TopUpVouchers');

        RequestMessage.Method := 'POST';
        RequestMessage.SetRequestUri(NpRvGlobalVoucherSetup."Service Url");
        Client.Send(RequestMessage, ResponseMessage);
        ResponseMessage.Content.ReadAs(ResponseText);
        if not ResponseMessage.IsSuccessStatusCode() then
            ThrowGlobalVoucherWSError(ResponseMessage.ReasonPhrase, ResponseText);
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR NpRv Module Valid.: Global");
    end;

    local procedure GetServiceName(NpRvGlobalVoucherSetup: Record "NPR NpRv Global Vouch. Setup") ServiceName: Text
    var
        Position: Integer;
    begin
        ServiceName := NpRvGlobalVoucherSetup."Service Url";
        Position := StrPos(ServiceName, '?');
        if Position > 0 then
            ServiceName := DelStr(ServiceName, Position);

        if ServiceName = '' then
            exit('');

        if ServiceName[StrLen(ServiceName)] = '/' then
            ServiceName := DelStr(ServiceName, StrLen(ServiceName));

        Position := StrPos(ServiceName, '/');
        while Position > 0 do begin
            ServiceName := DelStr(ServiceName, 1, Position);
            Position := StrPos(ServiceName, '/');
        end;

        exit(ServiceName);
    end;

    local procedure IsSubscriber(VoucherType: Record "NPR NpRv Voucher Type"): Boolean
    begin
        exit(VoucherType."Validate Voucher Module" = ModuleCode());
    end;

    local procedure ModuleCode(): Code[20]
    begin
        exit('GLOBAL');
    end;

    local procedure PostSyncEntry(NpRvVoucher: Record "NPR NpRv Voucher"; SyncAmount: Decimal; Node: XmlNode)
    var
        NpRvVoucherEntry: Record "NPR NpRv Voucher Entry";
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
    begin
        if SyncAmount = 0 then
            exit;
        NpRvVoucherEntry.Init();
        NpRvVoucherEntry."Entry No." := 0;
        NpRvVoucherEntry."Voucher No." := NpRvVoucher."No.";
        NpRvVoucherEntry."Entry Type" := NpRvVoucherEntry."Entry Type"::Synchronisation;
        NpRvVoucherEntry."Voucher Type" := NpRvVoucher."Voucher Type";
        NpRvVoucherEntry.Amount := SyncAmount;
        NpRvVoucherEntry."Remaining Amount" := NpRvVoucherEntry.Amount;
        NpRvVoucherEntry.Positive := NpRvVoucherEntry.Amount > 0;
        NpRvVoucherEntry."Posting Date" := WorkDate();
        NpRvVoucherEntry.Open := NpRvVoucherEntry.Amount <> 0;
#pragma warning disable AA0139
        NpRvVoucherEntry."Register No." := NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'issue_register_no', MaxStrLen(NpRvVoucherEntry."Register No."), false);

        NpRvVoucherEntry."Document No." := NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'issue_sales_ticket_no', MaxStrLen(NpRvVoucherEntry."Document No."), false);
        NpRvVoucherEntry."User ID" := NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'issue_user_id', MaxStrLen(NpRvVoucherEntry."User ID"), false);
        NpRvVoucherEntry."Closed by Entry No." := 0;
        NpRvVoucherEntry."Partner Code" := UpperCase(NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'issue_partner_code', MaxStrLen(NpRvVoucherEntry."Partner Code"), false));
        NpRvVoucherEntry."POS Store Code" := UpperCase(NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'issue_posstore_code', MaxStrLen(NpRvVoucherEntry."POS Store Code"), false));
        NpRvVoucherEntry.Company := NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'company', MaxStrLen(NpRvVoucherEntry.Company), false);
#pragma warning restore
        NpRvVoucherEntry.Insert();
        NpRvVoucherMgt.ApplyEntry(NpRvVoucherEntry);
        Commit();
    end;

    internal procedure UpdateVoucherAmount(NpRvVoucher: Record "NPR NpRv Voucher")
    var
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        AvailableAmount: Decimal;
        VoucherAmount: Decimal;
        Node: XmlNode;
    begin
        NpRvVoucherType.Get(NpRvVoucher."Voucher Type");
        if NpRvVoucherType."Partner Code" = '' then
            exit;
        if NpRvVoucherType."Validate Voucher Module" <> ModuleCode() then
            exit;
        if FindVoucherAmount(NpRvVoucher."Reference No.", NpRvVoucherType, VoucherAmount, Node) then begin
            if NpRvVoucherMgt.VoucherReservationByAmountFeatureEnabled() then
                UpdateReservationEntries(Node.AsXmlElement(), NpRvVoucher);
            NpRvVoucher.CalcFields(Amount);
            AvailableAmount := NpRvVoucher.Amount;
            if (VoucherAmount <> 0) and (AvailableAmount <> VoucherAmount) then
                PostSyncEntry(NpRvVoucher, VoucherAmount - AvailableAmount, Node);
        end;
    end;

    procedure FindVoucherAmount(ReferenceNo: Text; NpRvVoucherType: Record "NPR NpRv Voucher Type"; var VoucherAmount: Decimal; var Node: XmlNode) Found: Boolean
    var
        NpRvGlobalVoucherSetup: Record "NPR NpRv Global Vouch. Setup";
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        XmlDomManagement: codeunit "XML DOM Management";
        Client: HttpClient;
        RequestMessage: HttpRequestMessage;
        ContentHeader: HttpHeaders;
        [NonDebuggable]
        RequestHeaders: HttpHeaders;
        ResponseMessage: HttpResponseMessage;
        Document: XmlDocument;
        RequestXmlText: Text;
        ResponseText: Text;
    begin
        NpRvGlobalVoucherSetup.Get(NpRvVoucherType.Code);
        NpRvGlobalVoucherSetup.TestField("Service Url");

        RequestXmlText :=
          '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">' +
            '<soapenv:Body>' +
              '<FindVouchers xmlns="urn:microsoft-dynamics-schemas/codeunit/' + GetServiceName(NpRvGlobalVoucherSetup) + '">' +
                '<vouchers>' +
                  '<voucher reference_no="' + ReferenceNo + '" voucher_type="' + NpRvVoucherType.Code + '" xmlns="urn:microsoft-dynamics-schemas/codeunit/global_voucher_service">' +
                    '<redeem_partner_code>' + NpRvVoucherType."Partner Code" + '</redeem_partner_code>' +
                  '</voucher>' +
                '</vouchers>' +
              '</FindVouchers>' +
            '</soapenv:Body>' +
          '</soapenv:Envelope>';

        RequestMessage.GetHeaders(RequestHeaders);
        if RequestHeaders.Contains('Connection') then
            RequestHeaders.Remove('Connection');
        NpRvGlobalVoucherSetup.SetRequestHeadersAuthorization(RequestHeaders);

        RequestMessage.Content.WriteFrom(RequestXmlText);
        RequestMessage.Content.GetHeaders(ContentHeader);
        if ContentHeader.Contains('Content-Type') then
            ContentHeader.Remove('Content-Type');
        ContentHeader.Add('Content-Type', 'text/xml; charset=utf-8');
        if ContentHeader.Contains('SOAPAction') then
            ContentHeader.Remove('SOAPAction');
        ContentHeader.Add('SOAPAction', 'FindVouchers');

        RequestMessage.Method := 'POST';
        RequestMessage.SetRequestUri(NpRvGlobalVoucherSetup."Service Url");
        Client.Send(RequestMessage, ResponseMessage);
        ResponseMessage.Content.ReadAs(ResponseText);
        if not ResponseMessage.IsSuccessStatusCode() then begin
            ThrowGlobalVoucherWSError(ResponseMessage.ReasonPhrase, ResponseText);
        end;

        ResponseText := XmlDomManagement.RemoveNamespaces(ResponseText);
        XmlDocument.ReadFrom(ResponseText, Document);
        if not NpXmlDomMgt.FindNode(Document.AsXmlNode(), '//Body/FindVouchers_Result/vouchers/voucher', Node) then
            Error(Text005, ReferenceNo);

        if Evaluate(VoucherAmount, NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'amount', 0, false), 9) then
            Found := true;
    end;

    procedure CalcAvailableVoucherAmount(ReferenceNo: Text; VoucherType: Code[20]) AvailableAmount: Decimal;
    var
        NpRvGlobalVoucherSetup: Record "NPR NpRv Global Vouch. Setup";
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        XmlDomManagement: codeunit "XML DOM Management";
        Client: HttpClient;
        RequestMessage: HttpRequestMessage;
        ContentHeader: HttpHeaders;
        [NonDebuggable]
        RequestHeaders: HttpHeaders;
        ResponseMessage: HttpResponseMessage;
        Document: XmlDocument;
        Node: XmlNode;
        VoucherAmount: Decimal;
        ReservedVoucherAmount: Decimal;
        RequestXmlText: Text;
        ResponseText: Text;
    begin
        NpRvGlobalVoucherSetup.Get(VoucherType);
        NpRvGlobalVoucherSetup.TestField("Service Url");

        NpRvVoucherType.Get(VoucherType);

        RequestXmlText :=
          '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">' +
            '<soapenv:Body>' +
              '<FindVouchers xmlns="urn:microsoft-dynamics-schemas/codeunit/' + GetServiceName(NpRvGlobalVoucherSetup) + '">' +
                '<vouchers>' +
                  '<voucher reference_no="' + ReferenceNo + '" voucher_type="' + NpRvVoucherType.Code + '" xmlns="urn:microsoft-dynamics-schemas/codeunit/global_voucher_service">' +
                    '<redeem_partner_code>' + NpRvVoucherType."Partner Code" + '</redeem_partner_code>' +
                  '</voucher>' +
                '</vouchers>' +
              '</FindVouchers>' +
            '</soapenv:Body>' +
          '</soapenv:Envelope>';

        RequestMessage.GetHeaders(RequestHeaders);
        if RequestHeaders.Contains('Connection') then
            RequestHeaders.Remove('Connection');
        NpRvGlobalVoucherSetup.SetRequestHeadersAuthorization(RequestHeaders);

        RequestMessage.Content.WriteFrom(RequestXmlText);
        RequestMessage.Content.GetHeaders(ContentHeader);
        if ContentHeader.Contains('Content-Type') then
            ContentHeader.Remove('Content-Type');
        ContentHeader.Add('Content-Type', 'text/xml; charset=utf-8');
        if ContentHeader.Contains('SOAPAction') then
            ContentHeader.Remove('SOAPAction');
        ContentHeader.Add('SOAPAction', 'FindVouchers');

        RequestMessage.Method := 'POST';
        RequestMessage.SetRequestUri(NpRvGlobalVoucherSetup."Service Url");
        Client.Send(RequestMessage, ResponseMessage);
        ResponseMessage.Content.ReadAs(ResponseText);
        if not ResponseMessage.IsSuccessStatusCode() then begin
            ThrowGlobalVoucherWSError(ResponseMessage.ReasonPhrase, ResponseText);
        end;

        ResponseText := XmlDomManagement.RemoveNamespaces(ResponseText);
        XmlDocument.ReadFrom(ResponseText, Document);
        if not NpXmlDomMgt.FindNode(Document.AsXmlNode(), '//Body/FindVouchers_Result/vouchers/voucher', Node) then
            Error(Text005, ReferenceNo);

        Evaluate(VoucherAmount, NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'amount', 0, false), 9);
        Evaluate(ReservedVoucherAmount, NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'reserved_amount', 0, false), 9);

        exit(VoucherAmount - ReservedVoucherAmount);
    end;

    internal procedure ThrowGlobalVoucherWSError(ResponseReasonPhrase: Text; ResponseText: Text)
    var
        ErrorXmlDoc: XmlDocument;
        ErrorXmlElement: XmlElement;
        ErrorXmlNode: XmlNode;
        XmlDOMMgt: codeunit "XML DOM Management";
    begin
        if ResponseText <> '' then begin
            ResponseText := XmlDOMMgt.RemoveNamespaces(ResponseText);
            XmlDocument.ReadFrom(ResponseText, ErrorXmlDoc);
            ErrorXmlDoc.SelectSingleNode('//Envelope/Body/Fault/faultstring', ErrorXmlNode);
            ErrorXmlElement := ErrorXmlNode.AsXmlElement();
            Error('%1\\%2', ResponseReasonPhrase, ErrorXmlElement.InnerText);
        end else
            Error(ResponseReasonPhrase);
    end;
}
