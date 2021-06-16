codeunit 6151019 "NPR NpRv Module Valid.: Global"
{
    var
        Text000: Label 'Validate Global Voucher';
        Text001: Label 'Voucher is being used';
        Text005: Label 'Invalid Reference No. %1';

        ErrorXmlDoc: XmlDocument;
        ErrorXmlElement: XmlElement;
        ErrorXmlNode: XmlNode;
        XmlDOMMgt: codeunit "XML DOM Management";

    [EventSubscriber(ObjectType::Table, 6151024, 'OnAfterInsertEvent', '', true, true)]
    local procedure OnInsertPartner(var Rec: Record "NPR NpRv Partner"; RunTrigger: Boolean)
    begin
        ValidateGlobalVoucherSetups(Rec);
    end;

    [EventSubscriber(ObjectType::Table, 6151024, 'OnAfterModifyEvent', '', true, true)]
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
            if NpRvGlobalVoucherSetup.Get(NpRvVoucherType.Code) then begin
                if TryValidateGlobalVoucherSetup(NpRvGlobalVoucherSetup) then;
            end;
        until NpRvVoucherType.Next() = 0;
    end;

    [TryFunction]
    procedure TryValidateGlobalVoucherSetup(NpRvGlobalVoucherSetup: Record "NPR NpRv Global Vouch. Setup")
    var
        NpRvPartner: Record "NPR NpRv Partner";
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
        Client: HttpClient;
        RequestContent: HttpContent;
        ContentHeader: HttpHeaders;
        RequestHeader: HttpHeaders;
        Response: HttpResponseMessage;
        RequestXmlText: Text;
        ResponseText: Text;
    begin
        NpRvVoucherType.Get(NpRvGlobalVoucherSetup."Voucher Type");
        if NpRvVoucherType."Validate Voucher Module" <> ModuleCode() then
            exit;

        NpRvPartner.Get(NpRvVoucherType."Partner Code");
        NpRvGlobalVoucherSetup.TestField("Service Url");

        RequestXmlText :=
          '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">' +
             '<soapenv:Body>' +
               '<UpsertPartners xmlns="urn:microsoft-dynamics-schemas/codeunit/' + GetServiceName(NpRvGlobalVoucherSetup) + '">' +
                 '<retail_voucher_partners>' +
                   '<retail_voucher_partner partner_code="' + NpRvPartner.Code + '">' +
                     '<name>' + NpRvPartner.Name + '</name>' +
                     '<service_url>' + NpRvPartner."Service Url" + '</service_url>' +
                     '<service_username>' + NpRvPartner."Service Username" + '</service_username>' +
                     '<service_password>' + NpRvPartner."Service Password" + '</service_password>' +
                     '<relations>' +
                       '<relation voucher_type="' + NpRvGlobalVoucherSetup."Voucher Type" + '" />' +
                     '</relations>' +
                   '</retail_voucher_partner>' +
                 '</retail_voucher_partners>' +
               '</UpsertPartners>' +
            '</soapenv:Body>' +
          '</soapenv:Envelope>';

        RequestContent.WriteFrom(RequestXmlText);
        RequestContent.GetHeaders(ContentHeader);

        if ContentHeader.Contains('Content-Type') then
            ContentHeader.Remove('Content-Type');
        ContentHeader.Add('Content-Type', 'text/xml; charset=utf-8');
        if ContentHeader.Contains('SOAPAction') then
            ContentHeader.Remove('SOAPAction');
        ContentHeader.Add('SOAPAction', 'UpsertPartners');

        RequestHeader := Client.DefaultRequestHeaders();
        if RequestHeader.Contains('Connection') then
            RequestHeader.Remove('Connection');

        Client.UseWindowsAuthentication(NpRvGlobalVoucherSetup."Service Username", NpRvGlobalVoucherSetup."Service Password");
        Client.Post(NpRvGlobalVoucherSetup."Service Url", RequestContent, Response);

        if not Response.IsSuccessStatusCode() then begin
            Response.Content.ReadAs(ResponseText);
            ResponseText := XmlDOMMgt.RemoveNamespaces(ResponseText);
            XmlDocument.ReadFrom(ResponseText, ErrorXmlDoc);
            ErrorXmlDoc.SelectSingleNode('//Envelope/Body/Fault/faultstring', ErrorXmlNode);
            ErrorXmlElement := ErrorXmlNode.AsXmlElement();
            Error('%1\\%2', Response.ReasonPhrase, ErrorXmlElement.InnerText);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151011, 'OnInitVoucherModules', '', true, true)]
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

    [EventSubscriber(ObjectType::Codeunit, 6151011, 'OnHasValidateVoucherSetup', '', true, true)]
    local procedure OnHasValidateVoucherSetup(VoucherType: Record "NPR NpRv Voucher Type"; var HasValidateSetup: Boolean)
    begin
        if not IsSubscriber(VoucherType) then
            exit;

        HasValidateSetup := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151011, 'OnSetupValidateVoucher', '', true, true)]
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

    [EventSubscriber(ObjectType::Codeunit, 6151011, 'OnRunValidateVoucher', '', true, true)]
    local procedure OnRunValidateVoucher(var NpRvVoucherBuffer: Record "NPR NpRv Voucher Buffer" temporary; var Handled: Boolean)
    begin
        if Handled then
            exit;
        if NpRvVoucherBuffer."Validate Voucher Module" <> ModuleCode() then
            exit;

        Handled := true;

        ReserveVoucher(NpRvVoucherBuffer);
    end;

    [EventSubscriber(ObjectType::Table, 6151015, 'OnBeforeDeleteEvent', '', true, true)]
    local procedure OnBeforeDeletePOSVoucher(var Rec: Record "NPR NpRv Sales Line"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary then
            exit;

        if TryCancelReservation(Rec) then;
    end;

    [TryFunction]
    local procedure TryCancelReservation(NpRvSaleLinePOSVoucher: Record "NPR NpRv Sales Line")
    var
        NpRvGlobalVoucherSetup: Record "NPR NpRv Global Vouch. Setup";
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
        Client: HttpClient;
        RequestContent: HttpContent;
        ContentHeader: HttpHeaders;
        RequestHeader: HttpHeaders;
        Response: HttpResponseMessage;
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

        RequestContent.WriteFrom(RequestXmlText);
        RequestContent.GetHeaders(ContentHeader);

        if ContentHeader.Contains('Content-Type') then
            ContentHeader.Remove('Content-Type');
        ContentHeader.Add('Content-Type', 'text/xml; charset=utf-8');
        if ContentHeader.Contains('SOAPAction') then
            ContentHeader.Remove('SOAPAction');
        ContentHeader.Add('SOAPAction', 'CancelReserveVouchers');

        RequestHeader := Client.DefaultRequestHeaders();
        if RequestHeader.Contains('Connection') then
            RequestHeader.Remove('Connection');

        Client.UseWindowsAuthentication(NpRvGlobalVoucherSetup."Service Username", NpRvGlobalVoucherSetup."Service Password");
        Client.Post(NpRvGlobalVoucherSetup."Service Url", RequestContent, Response);

        if not Response.IsSuccessStatusCode() then begin
            Response.Content.ReadAs(ResponseText);
            ResponseText := XmlDOMMgt.RemoveNamespaces(ResponseText);
            XmlDocument.ReadFrom(ResponseText, ErrorXmlDoc);
            ErrorXmlDoc.SelectSingleNode('//Envelope/Body/Fault/faultstring', ErrorXmlNode);
            ErrorXmlElement := ErrorXmlNode.AsXmlElement();
            Error('%1\\%2', Response.ReasonPhrase, ErrorXmlElement.InnerText);
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6151014, 'OnAfterInsertEvent', '', true, true)]
    local procedure OnInsertVoucherEntry(var Rec: Record "NPR NpRv Voucher Entry"; RunTrigger: Boolean)
    var
        NpRvPartner: Record "NPR NpRv Partner";
        Voucher: Record "NPR NpRv Voucher";
        VoucherEntry: Record "NPR NpRv Voucher Entry";
    begin
        if Rec.IsTemporary then
            exit;
        if not Voucher.Get(Rec."Voucher No.") then
            exit;

        case Rec."Entry Type" of
            Rec."Entry Type"::"Issue Voucher":
                CreateGlobalVoucher(Voucher);
            Rec."Entry Type"::Payment:
                begin
                    RedeemVoucher(Rec);

                    VoucherEntry.SetRange("Voucher No.", Rec."Voucher No.");
                    VoucherEntry.SetFilter("Entry Type", '%1|%2', VoucherEntry."Entry Type"::"Issue Voucher", VoucherEntry."Entry Type"::"Partner Issue Voucher");
                    VoucherEntry.SetFilter("Partner Code", '<>%1', Rec."Partner Code");
                    if not VoucherEntry.FindFirst() then
                        exit;
                    if not NpRvPartner.Get(VoucherEntry."Partner Code") then
                        exit;

                    RedeemPartnerVouchers(Rec);
                end;
            Rec."Entry Type"::"Partner Payment":
                begin
                    RedeemPartnerVouchers(Rec);
                end;
        end;
    end;

    local procedure CreateGlobalVoucher(Voucher: Record "NPR NpRv Voucher")
    var
        NpRvGlobalVoucherSetup: Record "NPR NpRv Global Vouch. Setup";
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
        Client: HttpClient;
        RequestContent: HttpContent;
        ContentHeader: HttpHeaders;
        RequestHeader: HttpHeaders;
        Response: HttpResponseMessage;
        RequestXmlText: Text;
        ResponseText: Text;
    begin
        Voucher.CalcFields("Validate Voucher Module");
        if Voucher."Validate Voucher Module" <> ModuleCode() then
            exit;
        NpRvVoucherType.Get(Voucher."Voucher Type");
        NpRvGlobalVoucherSetup.Get(Voucher."Voucher Type");
        NpRvGlobalVoucherSetup.TestField("Service Url");

        Voucher.CalcFields(Amount, "Issue Date", "Issue Register No.", "Issue Document No.", "Issue User ID");
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
                    '<issue_partner_code>' + NpRvVoucherType."Partner Code" + '</issue_partner_code>' +
                  '</voucher>' +
                '</vouchers>' +
              '</CreateVouchers>' +
            '</soapenv:Body>' +
          '</soapenv:Envelope>';

        RequestContent.WriteFrom(RequestXmlText);
        RequestContent.GetHeaders(ContentHeader);

        if ContentHeader.Contains('Content-Type') then
            ContentHeader.Remove('Content-Type');
        ContentHeader.Add('Content-Type', 'text/xml; charset=utf-8');
        if ContentHeader.Contains('SOAPAction') then
            ContentHeader.Remove('SOAPAction');
        ContentHeader.Add('SOAPAction', 'CreateVouchers');

        RequestHeader := Client.DefaultRequestHeaders();
        if RequestHeader.Contains('Connection') then
            RequestHeader.Remove('Connection');

        Client.UseWindowsAuthentication(NpRvGlobalVoucherSetup."Service Username", NpRvGlobalVoucherSetup."Service Password");
        Client.Post(NpRvGlobalVoucherSetup."Service Url", RequestContent, Response);

        if not Response.IsSuccessStatusCode() then begin
            Response.Content.ReadAs(ResponseText);
            ResponseText := XmlDOMMgt.RemoveNamespaces(ResponseText);
            XmlDocument.ReadFrom(ResponseText, ErrorXmlDoc);
            ErrorXmlDoc.SelectSingleNode('//Envelope/Body/Fault/faultstring', ErrorXmlNode);
            ErrorXmlElement := ErrorXmlNode.AsXmlElement();
            Error('%1\\%2', Response.ReasonPhrase, ErrorXmlElement.InnerText);
        end;
    end;

    procedure ReserveVoucher(var NpRvVoucherBuffer: Record "NPR NpRv Voucher Buffer" temporary)
    var
        Voucher: Record "NPR NpRv Voucher";
        NpRvGlobalVoucherSetup: Record "NPR NpRv Global Vouch. Setup";
        VoucherType: Record "NPR NpRv Voucher Type";
        VoucherEntry: Record "NPR NpRv Voucher Entry";
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        XmlDomManagement: codeunit "XML DOM Management";
        Client: HttpClient;
        RequestContent: HttpContent;
        ContentHeader: HttpHeaders;
        RequestHeader: HttpHeaders;
        Response: HttpResponseMessage;
        Document: XmlDocument;
        Node: XmlNode;
        RequestXmlText: Text;
        ReferenceNo: Text;
        ResponseText: Text;
    begin
        ReferenceNo := NpRvVoucherBuffer."Reference No.";
        VoucherType.Get(NpRvVoucherBuffer."Voucher Type");
        if VoucherType."Validate Voucher Module" <> ModuleCode() then
            exit;
        NpRvGlobalVoucherSetup.Get(VoucherType.Code);
        NpRvGlobalVoucherSetup.TestField("Service Url");

        Clear(Voucher);
        Voucher.SetRange("Reference No.", NpRvVoucherBuffer."Reference No.");
        Voucher.SetRange("Voucher Type", VoucherType.Code);
        if Voucher.FindFirst() then begin
            if Voucher.CalcInUseQty() > 0 then
                Error(Text001);
        end;
        RequestXmlText :=
          '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">' +
            '<soapenv:Body>' +
              '<ReserveVouchers xmlns="urn:microsoft-dynamics-schemas/codeunit/' + GetServiceName(NpRvGlobalVoucherSetup) + '">' +
                '<vouchers>' +
                  '<voucher reference_no="' + ReferenceNo + '" voucher_type="' + VoucherType.Code + '" xmlns="urn:microsoft-dynamics-schemas/codeunit/global_voucher_service">' +
                    '<redeem_date>' + Format(NpRvVoucherBuffer."Redeem Date", 0, 9) + '</redeem_date>' +
                    '<redeem_register_no>' + NpRvVoucherBuffer."Redeem Register No." + '</redeem_register_no>' +
                    '<redeem_sales_ticket_no>' + NpRvVoucherBuffer."Redeem Sales Ticket No." + '</redeem_sales_ticket_no>' +
                    '<redeem_user_id>' + NpRvVoucherBuffer."Redeem User ID" + '</redeem_user_id>' +
                    '<redeem_partner_code>' + VoucherType."Partner Code" + '</redeem_partner_code>' +
                  '</voucher>' +
                '</vouchers>' +
              '</ReserveVouchers>' +
            '</soapenv:Body>' +
          '</soapenv:Envelope>';

        RequestContent.WriteFrom(RequestXmlText);
        RequestContent.GetHeaders(ContentHeader);

        if ContentHeader.Contains('Content-Type') then
            ContentHeader.Remove('Content-Type');
        ContentHeader.Add('Content-Type', 'text/xml; charset=utf-8');
        if ContentHeader.Contains('SOAPAction') then
            ContentHeader.Remove('SOAPAction');
        ContentHeader.Add('SOAPAction', 'ReserveVouchers');

        RequestHeader := Client.DefaultRequestHeaders();
        if RequestHeader.Contains('Connection') then
            RequestHeader.Remove('Connection');

        Client.UseWindowsAuthentication(NpRvGlobalVoucherSetup."Service Username", NpRvGlobalVoucherSetup."Service Password");
        Client.Post(NpRvGlobalVoucherSetup."Service Url", RequestContent, Response);

        if not Response.IsSuccessStatusCode() then begin
            Response.Content.ReadAs(ResponseText);
            ResponseText := XmlDOMMgt.RemoveNamespaces(ResponseText);
            XmlDocument.ReadFrom(ResponseText, ErrorXmlDoc);
            ErrorXmlDoc.SelectSingleNode('//Envelope/Body/Fault/faultstring', ErrorXmlNode);
            ErrorXmlElement := ErrorXmlNode.AsXmlElement();
            Error('%1\\%2', Response.ReasonPhrase, ErrorXmlElement.InnerText);
        end;

        Response.Content.ReadAs(ResponseText);
        ResponseText := XmlDomManagement.RemoveNamespaces(ResponseText);
        XmlDocument.ReadFrom(ResponseText, Document);
        if not NpXmlDomMgt.FindNode(Document.AsXmlNode(), '//Body/ReserveVouchers_Result/vouchers/voucher', Node) then
            Error(Text005, ReferenceNo);

        Clear(Voucher);
        Voucher.SetRange("Reference No.", ReferenceNo);
        Voucher.SetRange("Voucher Type", VoucherType.Code);
        if not Voucher.FindLast() then begin
            Voucher.Init();
            Voucher."No." := '';
            Voucher."Reference No." := ReferenceNo;
            Voucher.Validate("Voucher Type", VoucherType.Code);
            Voucher.Insert(true);

            VoucherEntry.Init();
            VoucherEntry."Entry No." := 0;
            VoucherEntry."Voucher No." := Voucher."No.";
            VoucherEntry."Entry Type" := VoucherEntry."Entry Type"::"Partner Issue Voucher";
            VoucherEntry."Voucher Type" := Voucher."Voucher Type";
            if Evaluate(VoucherEntry.Amount, NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'amount', 0, false), 9) then;
            VoucherEntry."Remaining Amount" := VoucherEntry.Amount;
            VoucherEntry.Positive := VoucherEntry.Amount > 0;
            if Evaluate(VoucherEntry."Posting Date", NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'issue_date', 0, false), 9) then;
            VoucherEntry.Open := VoucherEntry.Amount <> 0;
            VoucherEntry."Register No." := NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'issue_register_no', MaxStrLen(VoucherEntry."Register No."), false);
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
        Voucher.Modify(true);
        Voucher.CalcFields(Amount);
        NpRvVoucherMgt.Voucher2Buffer(Voucher, NpRvVoucherBuffer);
    end;

    procedure RedeemVoucher(VoucherEntry: Record "NPR NpRv Voucher Entry")
    var
        NpRvGlobalVoucherSetup: Record "NPR NpRv Global Vouch. Setup";
        Voucher: Record "NPR NpRv Voucher";
        VoucherType: Record "NPR NpRv Voucher Type";
        Client: HttpClient;
        RequestContent: HttpContent;
        ContentHeader: HttpHeaders;
        RequestHeader: HttpHeaders;
        Response: HttpResponseMessage;
        RequestXmlText: Text;
        ResponseText: Text;
    begin
        if VoucherEntry."Entry Type" <> VoucherEntry."Entry Type"::Payment then
            exit;

        VoucherType.Get(VoucherEntry."Voucher Type");
        if VoucherType."Validate Voucher Module" <> ModuleCode() then
            exit;
        NpRvGlobalVoucherSetup.Get(VoucherType.Code);
        NpRvGlobalVoucherSetup.TestField("Service Url");

        Voucher.Get(VoucherEntry."Voucher No.");
        RequestXmlText :=
          '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">' +
            '<soapenv:Body>' +
              '<RedeemVouchers xmlns="urn:microsoft-dynamics-schemas/codeunit/' + GetServiceName(NpRvGlobalVoucherSetup) + '">' +
                '<vouchers>' +
                  '<voucher reference_no="' + Voucher."Reference No." + '" voucher_type="' + VoucherType.Code + '" xmlns="urn:microsoft-dynamics-schemas/codeunit/global_voucher_service">' +
                    '<amount>' + Format(-VoucherEntry.Amount, 0, 9) + '</amount>' +
                    '<redeem_date>' + Format(VoucherEntry."Posting Date", 0, 9) + '</redeem_date>' +
                    '<redeem_register_no>' + VoucherEntry."Register No." + '</redeem_register_no>' +
                    '<redeem_sales_ticket_no>' + VoucherEntry."Document No." + '</redeem_sales_ticket_no>' +
                    '<redeem_user_id>' + VoucherEntry."User ID" + '</redeem_user_id>' +
                    '<redeem_partner_code>' + VoucherType."Partner Code" + '</redeem_partner_code>' +
                  '</voucher>' +
                '</vouchers>' +
              '</RedeemVouchers>' +
            '</soapenv:Body>' +
          '</soapenv:Envelope>';

        RequestContent.WriteFrom(RequestXmlText);
        RequestContent.GetHeaders(ContentHeader);

        if ContentHeader.Contains('Content-Type') then
            ContentHeader.Remove('Content-Type');
        ContentHeader.Add('Content-Type', 'text/xml; charset=utf-8');
        if ContentHeader.Contains('SOAPAction') then
            ContentHeader.Remove('SOAPAction');
        ContentHeader.Add('SOAPAction', 'RedeemVouchers');

        RequestHeader := Client.DefaultRequestHeaders();
        if RequestHeader.Contains('Connection') then
            RequestHeader.Remove('Connection');

        Client.UseWindowsAuthentication(NpRvGlobalVoucherSetup."Service Username", NpRvGlobalVoucherSetup."Service Password");
        Client.Post(NpRvGlobalVoucherSetup."Service Url", RequestContent, Response);

        if not Response.IsSuccessStatusCode() then begin
            Response.Content.ReadAs(ResponseText);
            ResponseText := XmlDOMMgt.RemoveNamespaces(ResponseText);
            XmlDocument.ReadFrom(ResponseText, ErrorXmlDoc);
            ErrorXmlDoc.SelectSingleNode('//Envelope/Body/Fault/faultstring', ErrorXmlNode);
            ErrorXmlElement := ErrorXmlNode.AsXmlElement();
            Error('%1\\%2', Response.ReasonPhrase, ErrorXmlElement.InnerText);
        end;
    end;

    procedure RedeemPartnerVouchers(NpRvVoucherEntry: Record "NPR NpRv Voucher Entry")
    var
        NpRvPartner: Record "NPR NpRv Partner";
        NpRvPartnerRelation: Record "NPR NpRv Partner Relation";
        NpRvVoucher: Record "NPR NpRv Voucher";
        NpRvVoucherEntry2: Record "NPR NpRv Voucher Entry";
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
        NpRvPartnerMgt: Codeunit "NPR NpRv Partner Mgt.";
        Client: HttpClient;
        RequestContent: HttpContent;
        ContentHeader: HttpHeaders;
        RequestHeader: HttpHeaders;
        Response: HttpResponseMessage;
        RequestXmlText: Text;
        ResponseText: Text;
    begin
        if not (NpRvVoucherEntry."Entry Type" in [NpRvVoucherEntry."Entry Type"::Payment, NpRvVoucherEntry."Entry Type"::"Partner Payment"]) then
            exit;

        NpRvVoucher.Get(NpRvVoucherEntry."Voucher No.");
        NpRvVoucherType.Get(NpRvVoucher."Voucher Type");

        NpRvVoucherEntry2.SetRange("Voucher No.", NpRvVoucherEntry."Voucher No.");
        NpRvVoucherEntry2.SetFilter("Entry Type", '%1|%2', NpRvVoucherEntry2."Entry Type"::"Issue Voucher", NpRvVoucherEntry2."Entry Type"::"Partner Issue Voucher");
        NpRvVoucherEntry2.FindFirst();
        if NpRvVoucherEntry."Partner Code" = NpRvVoucherEntry2."Partner Code" then
            exit;
        if not NpRvPartner.Get(NpRvVoucherEntry2."Partner Code") then
            exit;
        if NpRvPartner."Service Url" = '' then
            exit;
        if not NpRvPartnerRelation.Get(NpRvPartner.Code, NpRvVoucherType.Code) then
            exit;

        RequestXmlText :=
          '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">' +
            '<soapenv:Body>' +
              '<RedeemPartnerVouchers xmlns="urn:microsoft-dynamics-schemas/codeunit/' + NpRvPartnerMgt.GetServiceName(NpRvPartner) + '">' +
                '<vouchers>' +
                  '<voucher reference_no="' + NpRvVoucher."Reference No." + '"' +
                  ' voucher_type="' + NpRvVoucher."Voucher Type" + '" xmlns="urn:microsoft-dynamics-schemas/codeunit/global_voucher_service">' +
                    '<amount>' + Format(-NpRvVoucherEntry.Amount, 0, 9) + '</amount>' +
                    '<redeem_date>' + Format(NpRvVoucherEntry."Posting Date", 0, 9) + '</redeem_date>' +
                    '<redeem_register_no>' + NpRvVoucherEntry."Register No." + '</redeem_register_no>' +
                    '<redeem_sales_ticket_no>' + NpRvVoucherEntry."Document No." + '</redeem_sales_ticket_no>' +
                    '<redeem_user_id>' + NpRvVoucherEntry."User ID" + '</redeem_user_id>' +
                    '<redeem_partner_code>' + NpRvVoucherEntry."Partner Code" + '</redeem_partner_code>' +
                  '</voucher>' +
                '</vouchers>' +
              '</RedeemPartnerVouchers>' +
            '</soapenv:Body>' +
          '</soapenv:Envelope>';

        RequestContent.WriteFrom(RequestXmlText);
        RequestContent.GetHeaders(ContentHeader);

        if ContentHeader.Contains('Content-Type') then
            ContentHeader.Remove('Content-Type');
        ContentHeader.Add('Content-Type', 'text/xml; charset=utf-8');
        if ContentHeader.Contains('SOAPAction') then
            ContentHeader.Remove('SOAPAction');
        ContentHeader.Add('SOAPAction', 'RedeemPartnerVouchers');

        RequestHeader := Client.DefaultRequestHeaders();
        if RequestHeader.Contains('Connection') then
            RequestHeader.Remove('Connection');

        Client.UseWindowsAuthentication(NpRvPartner."Service Username", NpRvPartner."Service Password");
        Client.Post(NpRvPartner."Service Url", RequestContent, Response);

        if not Response.IsSuccessStatusCode() then begin
            Response.Content.ReadAs(ResponseText);
            ResponseText := XmlDOMMgt.RemoveNamespaces(ResponseText);
            XmlDocument.ReadFrom(ResponseText, ErrorXmlDoc);
            ErrorXmlDoc.SelectSingleNode('//Envelope/Body/Fault/faultstring', ErrorXmlNode);
            ErrorXmlElement := ErrorXmlNode.AsXmlElement();
            Error('%1\\%2', Response.ReasonPhrase, ErrorXmlElement.InnerText);
        end;
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
}

