codeunit 6151019 "NpRv Module Validate - Global"
{
    // NPR5.42/MHA /20180525  CASE 307022 Object created - Global Retail Voucher
    // NPR5.48/MHA /20180921  CASE 302179 Replaced direct check on Voucher."In-Use Quantity" with CalcInUseQty
    // NPR5.49/MHA /20190228  CASE 342811 Added Retail Voucher Partner functionality used with Cross Company Vouchers
    // #361164/MHA /20190705  CASE 361164 Updated Exception Message parsing


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Validate Global Voucher';
        Text001: Label 'Voucher is being used';
        Text005: Label 'Invalid Reference No. %1';

    [EventSubscriber(ObjectType::Table, 6151024, 'OnAfterInsertEvent', '', true, true)]
    local procedure OnInsertPartner(var Rec: Record "NpRv Partner";RunTrigger: Boolean)
    begin
        //-NPR5.49 [342811]
        ValidateGlobalVoucherSetups(Rec);
        //+NPR5.49 [342811]
    end;

    [EventSubscriber(ObjectType::Table, 6151024, 'OnAfterModifyEvent', '', true, true)]
    local procedure OnModifyPartner(var Rec: Record "NpRv Partner";var xRec: Record "NpRv Partner";RunTrigger: Boolean)
    begin
        //-NPR5.49 [342811]
        ValidateGlobalVoucherSetups(Rec);
        //+NPR5.49 [342811]
    end;

    local procedure ValidateGlobalVoucherSetups(NpRvPartner: Record "NpRv Partner")
    var
        NpRvGlobalVoucherSetup: Record "NpRv Global Voucher Setup";
        NpRvVoucherType: Record "NpRv Voucher Type";
    begin
        //-NPR5.49 [342811]
        NpRvVoucherType.SetRange("Partner Code",NpRvPartner.Code);
        NpRvVoucherType.SetRange("Validate Voucher Module",ModuleCode());
        if not NpRvVoucherType.FindSet then
          exit;

        repeat
          if NpRvGlobalVoucherSetup.Get(NpRvVoucherType.Code) then begin
            if TryValidateGlobalVoucherSetup(NpRvGlobalVoucherSetup) then;
          end;
        until NpRvVoucherType.Next = 0;
        //+NPR5.49 [342811]
    end;

    [TryFunction]
    procedure TryValidateGlobalVoucherSetup(NpRvGlobalVoucherSetup: Record "NpRv Global Voucher Setup")
    var
        NpRvPartner: Record "NpRv Partner";
        NpRvVoucherType: Record "NpRv Voucher Type";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        Credential: DotNet npNetNetworkCredential;
        HttpWebRequest: DotNet npNetHttpWebRequest;
        HttpWebResponse: DotNet npNetHttpWebResponse;
        XmlDoc: DotNet npNetXmlDocument;
        XmlElement: DotNet npNetXmlElement;
        WebException: DotNet npNetWebException;
        ErrorMessage: Text;
    begin
        //-NPR5.49 [342811]
        NpRvVoucherType.Get(NpRvGlobalVoucherSetup."Voucher Type");
        if NpRvVoucherType."Validate Voucher Module" <> ModuleCode() then
          exit;

        NpRvPartner.Get(NpRvVoucherType."Partner Code");
        NpRvGlobalVoucherSetup.TestField("Service Url");

        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.LoadXml(
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
          '</soapenv:Envelope>'
        );

        HttpWebRequest := HttpWebRequest.Create(NpRvGlobalVoucherSetup."Service Url");
        HttpWebRequest.UseDefaultCredentials(false);
        Credential := Credential.NetworkCredential(NpRvGlobalVoucherSetup."Service Username",NpRvGlobalVoucherSetup."Service Password");
        HttpWebRequest.Credentials(Credential);
        HttpWebRequest.Method := 'POST';
        HttpWebRequest.ContentType := 'text/xml; charset=utf-8';
        HttpWebRequest.Headers.Add('SOAPAction','UpsertPartners');
        NpXmlDomMgt.SetTrustedCertificateValidation(HttpWebRequest);

        if NpXmlDomMgt.SendWebRequest(XmlDoc,HttpWebRequest,HttpWebResponse,WebException) then
          exit;

        //-#361164 [361164]
        ErrorMessage := NpXmlDomMgt.GetWebExceptionMessage(WebException);
        //+#361164 [361164]
        if NpXmlDomMgt.TryLoadXml(ErrorMessage,XmlDoc) then begin
          NpXmlDomMgt.RemoveNameSpaces(XmlDoc);
          if NpXmlDomMgt.FindNode(XmlDoc.DocumentElement,'//faultstring',XmlElement) then begin
            ErrorMessage := XmlElement.InnerText;
            //-#361164 [361164]
            Error(CopyStr(ErrorMessage,1,1000));
            //+#361164 [361164]
          end;
        end;
        //-#361164 [361164]
        Error(CopyStr(ErrorMessage,1,1000));
        //+#361164 [361164]
        //+NPR5.49 [342811]
    end;

    local procedure "--- Voucher Interface"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151011, 'OnInitVoucherModules', '', true, true)]
    local procedure OnInitVoucherModules(var VoucherModule: Record "NpRv Voucher Module")
    begin
        if VoucherModule.Get(VoucherModule.Type::"Validate Voucher",ModuleCode()) then
          exit;

        VoucherModule.Init;
        VoucherModule.Type := VoucherModule.Type::"Validate Voucher";
        VoucherModule.Code := ModuleCode();
        VoucherModule.Description := Text000;
        VoucherModule."Event Codeunit ID" := CurrCodeunitId();
        VoucherModule.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151011, 'OnHasValidateVoucherSetup', '', true, true)]
    local procedure OnHasValidateVoucherSetup(VoucherType: Record "NpRv Voucher Type";var HasValidateSetup: Boolean)
    begin
        if not IsSubscriber(VoucherType) then
          exit;

        HasValidateSetup := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151011, 'OnSetupValidateVoucher', '', true, true)]
    local procedure OnSetupValidateVoucher(var VoucherType: Record "NpRv Voucher Type")
    var
        NpRvGlobalVoucherSetup: Record "NpRv Global Voucher Setup";
    begin
        if not IsSubscriber(VoucherType) then
          exit;

        //-NPR5.49 [342811]
        VoucherType.TestField("Partner Code");
        //+NPR5.49 [342811]
        if not NpRvGlobalVoucherSetup.Get(VoucherType.Code) then begin
          NpRvGlobalVoucherSetup.Init;
          NpRvGlobalVoucherSetup."Voucher Type" := VoucherType.Code;
          //-NPR5.49 [342811]
          //NpRvGlobalVoucherSetup.INSERT;
          NpRvGlobalVoucherSetup.Insert(true);
          //+NPR5.49 [342811]
        end;

        NpRvGlobalVoucherSetup.FilterGroup(2);
        NpRvGlobalVoucherSetup.SetRecFilter;
        NpRvGlobalVoucherSetup.FilterGroup(0);
        PAGE.Run(PAGE::"NpRv Global Voucher Setup",NpRvGlobalVoucherSetup);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151011, 'OnRunValidateVoucher', '', true, true)]
    local procedure OnRunValidateVoucher(var NpRvVoucherBuffer: Record "NpRv Voucher Buffer" temporary;var Handled: Boolean)
    begin
        if Handled then
          exit;
        //-NPR5.49 [342811]
        // IF NOT IsSubscriber(VoucherType) THEN
        //  EXIT;
        //
        // Handled := TRUE;
        //
        // ValidateVoucher(SalePOS,VoucherType,Voucher);
        if NpRvVoucherBuffer."Validate Voucher Module" <> ModuleCode() then
          exit;

        Handled := true;

        ReserveVoucher(NpRvVoucherBuffer);
        //+NPR5.49 [342811]
    end;

    [EventSubscriber(ObjectType::Table, 6151015, 'OnBeforeDeleteEvent', '', true, true)]
    local procedure OnBeforeDeletePOSVoucher(var Rec: Record "NpRv Sale Line POS Voucher";RunTrigger: Boolean)
    begin
        //-NPR5.49 [342811]
        if Rec.IsTemporary then
          exit;

        if TryCancelReservation(Rec) then;
        //+NPR5.49 [342811]
    end;

    [TryFunction]
    local procedure TryCancelReservation(NpRvSaleLinePOSVoucher: Record "NpRv Sale Line POS Voucher")
    var
        NpRvGlobalVoucherSetup: Record "NpRv Global Voucher Setup";
        NpRvVoucherType: Record "NpRv Voucher Type";
        SaleLinePOSReference: Record "NpRv Sale Line POS Reference";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        Credential: DotNet npNetNetworkCredential;
        HttpWebRequest: DotNet npNetHttpWebRequest;
        HttpWebResponse: DotNet npNetHttpWebResponse;
        XmlDoc: DotNet npNetXmlDocument;
        XmlElement: DotNet npNetXmlElement;
        WebException: DotNet npNetWebException;
        ErrorMessage: Text;
    begin
        //-NPR5.49 [342811]
        if not NpRvVoucherType.Get(NpRvSaleLinePOSVoucher."Voucher Type") then
          exit;
        if NpRvVoucherType."Validate Voucher Module" <> ModuleCode() then
          exit;
        if not NpRvGlobalVoucherSetup.Get(NpRvVoucherType.Code) then
          exit;
        if NpRvGlobalVoucherSetup."Service Url" = '' then
          exit;

        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.LoadXml(
          '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">' +
            '<soapenv:Body>' +
              '<CancelReserveVouchers xmlns="urn:microsoft-dynamics-schemas/codeunit/' + GetServiceName(NpRvGlobalVoucherSetup) + '">' +
                '<vouchers>' +
                  '<voucher reference_no="' + NpRvSaleLinePOSVoucher."Reference No." + '" voucher_type="' + NpRvSaleLinePOSVoucher."Voucher Type" + '"' +
                  ' xmlns="urn:microsoft-dynamics-schemas/codeunit/' + GetServiceName(NpRvGlobalVoucherSetup) + '">' +
                    '<redeem_date>' + Format(NpRvSaleLinePOSVoucher."Sale Date",0,9) + '</redeem_date>' +
                    '<redeem_register_no>' + NpRvSaleLinePOSVoucher."Register No." + '</redeem_register_no>' +
                    '<redeem_sales_ticket_no>' + NpRvSaleLinePOSVoucher."Sales Ticket No." + '</redeem_sales_ticket_no>' +
                  '</voucher>' +
                '</vouchers>' +
              '</CancelReserveVouchers>' +
            '</soapenv:Body>' +
          '</soapenv:Envelope>'
        );

        HttpWebRequest := HttpWebRequest.Create(NpRvGlobalVoucherSetup."Service Url");
        HttpWebRequest.UseDefaultCredentials(false);
        Credential := Credential.NetworkCredential(NpRvGlobalVoucherSetup."Service Username",NpRvGlobalVoucherSetup."Service Password");
        HttpWebRequest.Credentials(Credential);
        HttpWebRequest.Method := 'POST';
        HttpWebRequest.ContentType := 'text/xml; charset=utf-8';
        HttpWebRequest.Headers.Add('SOAPAction','CancelReserveVouchers');
        NpXmlDomMgt.SetTrustedCertificateValidation(HttpWebRequest);

        if not NpXmlDomMgt.SendWebRequest(XmlDoc,HttpWebRequest,HttpWebResponse,WebException) then begin
          //-#361164 [361164]
          ErrorMessage := NpXmlDomMgt.GetWebExceptionMessage(WebException);
          //+#361164 [361164]
          if NpXmlDomMgt.TryLoadXml(ErrorMessage,XmlDoc) then begin
            NpXmlDomMgt.RemoveNameSpaces(XmlDoc);
            ErrorMessage := NpXmlDomMgt.GetXmlText(XmlDoc.DocumentElement,'Body/Fault/faultstring',1000,false);
          end;

          Error(CopyStr(ErrorMessage,1,1000));
        end;
        //+NPR5.49 [342811]
    end;

    [EventSubscriber(ObjectType::Table, 6151014, 'OnAfterInsertEvent', '', true, true)]
    local procedure OnInsertVoucherEntry(var Rec: Record "NpRv Voucher Entry";RunTrigger: Boolean)
    var
        NpRvPartner: Record "NpRv Partner";
        Voucher: Record "NpRv Voucher";
        VoucherEntry: Record "NpRv Voucher Entry";
    begin
        if Rec.IsTemporary then
          exit;
        if not Voucher.Get(Rec."Voucher No.") then
          exit;

        case Rec."Entry Type" of
          Rec."Entry Type"::"Issue Voucher":
            CreateGlobalVoucher(Voucher);
          //-NPR5.49 [342811]
          // Rec."Entry Type"::Payment:
          //  RedeemVoucher(Rec);
          Rec."Entry Type"::Payment:
            begin
              RedeemVoucher(Rec);

              VoucherEntry.SetRange("Voucher No.",Rec."Voucher No.");
              VoucherEntry.SetFilter("Entry Type",'%1|%2',VoucherEntry."Entry Type"::"Issue Voucher",VoucherEntry."Entry Type"::"Partner Issue Voucher");
              VoucherEntry.SetFilter("Partner Code",'<>%1',Rec."Partner Code");
              if not VoucherEntry.FindFirst then
                exit;
              if not NpRvPartner.Get(VoucherEntry."Partner Code") then
                exit;

              RedeemPartnerVouchers(Rec);
            end;
          Rec."Entry Type"::"Partner Payment":
            begin
              RedeemPartnerVouchers(Rec);
            end;
          //+NPR5.49 [342811]
        end;
    end;

    local procedure "--- Sync"()
    begin
    end;

    local procedure CreateGlobalVoucher(Voucher: Record "NpRv Voucher")
    var
        NpRvGlobalVoucherSetup: Record "NpRv Global Voucher Setup";
        NpRvVoucherType: Record "NpRv Voucher Type";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        Credential: DotNet npNetNetworkCredential;
        HttpWebRequest: DotNet npNetHttpWebRequest;
        HttpWebResponse: DotNet npNetHttpWebResponse;
        XmlDoc: DotNet npNetXmlDocument;
        WebException: DotNet npNetWebException;
        ErrorMessage: Text;
    begin
        Voucher.CalcFields("Validate Voucher Module");
        if Voucher."Validate Voucher Module" <> ModuleCode() then
          exit;
        //-NPR5.49 [342811]
        NpRvVoucherType.Get(Voucher."Voucher Type");
        //+NPR5.49 [342811]
        NpRvGlobalVoucherSetup.Get(Voucher."Voucher Type");
        NpRvGlobalVoucherSetup.TestField("Service Url");

        Voucher.CalcFields(Amount,"Issue Date","Issue Register No.","Issue Document No.","Issue User ID");
        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.LoadXml(
          '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">' +
            '<soapenv:Body>' +
              '<CreateVouchers xmlns="urn:microsoft-dynamics-schemas/codeunit/' + GetServiceName(NpRvGlobalVoucherSetup) + '">' +
                '<vouchers>' +
                  '<voucher reference_no="' + Voucher."Reference No." + '" voucher_type="' + Voucher."Voucher Type" + '" xmlns="urn:microsoft-dynamics-schemas/codeunit/global_voucher_service">' +
                    '<description>' + Voucher.Description + '</description>' +
                    '<starting_date>' + Format(Voucher."Starting Date",0,9) + '</starting_date>' +
                    '<ending_date>' + Format(Voucher."Ending Date",0,9) + '</ending_date>' +
                    //-NPR5.49 [342811]
                    //'<account_no>' + NpRvGlobalVoucherSetup."Issuer Id" + '</account_no>' +
                    '<account_no>' + Voucher."Account No." + '</account_no>' +
                    //+NPR5.49 [342811]
                    '<amount>' + Format(Voucher.Amount,0,9) + '</amount>' +
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
                    '<issue_date>' + Format(Voucher."Issue Date",0,9) + '</issue_date>' +
                    '<issue_register_no>' + Voucher."Issue Register No." + '</issue_register_no>' +
                    '<issue_sales_ticket_no>' + Voucher."Issue Document No." + '</issue_sales_ticket_no>' +
                    '<issue_user_id>' + Voucher."Issue User ID" + '</issue_user_id>' +
                    //-NPR5.49 [342811]
                    '<issue_partner_code>' + NpRvVoucherType."Partner Code" + '</issue_partner_code>' +
                    //+NPR5.49 [342811]
                  '</voucher>' +
                '</vouchers>' +
              '</CreateVouchers>' +
            '</soapenv:Body>' +
          '</soapenv:Envelope>'
        );

        HttpWebRequest := HttpWebRequest.Create(NpRvGlobalVoucherSetup."Service Url");
        HttpWebRequest.UseDefaultCredentials(false);
        Credential := Credential.NetworkCredential(NpRvGlobalVoucherSetup."Service Username",NpRvGlobalVoucherSetup."Service Password");
        HttpWebRequest.Credentials(Credential);
        HttpWebRequest.Method := 'POST';
        HttpWebRequest.ContentType := 'text/xml; charset=utf-8';
        HttpWebRequest.Headers.Add('SOAPAction','CreateVouchers');
        NpXmlDomMgt.SetTrustedCertificateValidation(HttpWebRequest);

        if NpXmlDomMgt.SendWebRequest(XmlDoc,HttpWebRequest,HttpWebResponse,WebException) then
          exit;

        //-#361164 [361164]
        ErrorMessage := NpXmlDomMgt.GetWebExceptionMessage(WebException);
        //+#361164 [361164]
        if NpXmlDomMgt.TryLoadXml(ErrorMessage,XmlDoc) then begin
          NpXmlDomMgt.RemoveNameSpaces(XmlDoc);
          ErrorMessage := NpXmlDomMgt.GetXmlText(XmlDoc.DocumentElement,'Body/Fault/faultstring',1000,false);
        end;

        Error(CopyStr(ErrorMessage,1,1000));
        //+NPR5.49 [342811]
    end;

    procedure ReserveVoucher(var NpRvVoucherBuffer: Record "NpRv Voucher Buffer" temporary)
    var
        Voucher: Record "NpRv Voucher";
        NpRvGlobalVoucherSetup: Record "NpRv Global Voucher Setup";
        VoucherType: Record "NpRv Voucher Type";
        VoucherEntry: Record "NpRv Voucher Entry";
        NpRvVoucherMgt: Codeunit "NpRv Voucher Mgt.";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        Credential: DotNet npNetNetworkCredential;
        HttpWebRequest: DotNet npNetHttpWebRequest;
        HttpWebResponse: DotNet npNetHttpWebResponse;
        XmlDoc: DotNet npNetXmlDocument;
        XmlElement: DotNet npNetXmlElement;
        WebException: DotNet npNetWebException;
        ErrorMessage: Text;
        ReferenceNo: Text;
        Response: Text;
        i: Integer;
    begin
        //-NPR5.49 [342811]
        // VoucherType.GET(VoucherTypeCode);
        ReferenceNo := NpRvVoucherBuffer."Reference No.";
        VoucherType.Get(NpRvVoucherBuffer."Voucher Type");
        //+NPR5.49 [342811]
        if VoucherType."Validate Voucher Module" <> ModuleCode() then
          exit;
        NpRvGlobalVoucherSetup.Get(VoucherType.Code);
        NpRvGlobalVoucherSetup.TestField("Service Url");

        Clear(Voucher);
        //-NPR5.49 [342811]
        // Voucher.SETRANGE("Reference No.",ReferenceNo);
        Voucher.SetRange("Reference No.",NpRvVoucherBuffer."Reference No.");
        //+NPR5.49 [342811]
        Voucher.SetRange("Voucher Type",VoucherType.Code);
        if Voucher.FindFirst then begin
          //-NPR5.48 [302179]
          // Voucher.CALCFIELDS("In-use Quantity");
          // IF Voucher."In-use Quantity" > 0 THEN
          //  ERROR(Text001);
          if Voucher.CalcInUseQty() > 0 then
            Error(Text001);
          //+NPR5.48 [302179]
        end;
        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.LoadXml(
          '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">' +
            '<soapenv:Body>' +
              '<ReserveVouchers xmlns="urn:microsoft-dynamics-schemas/codeunit/' + GetServiceName(NpRvGlobalVoucherSetup) + '">' +
                '<vouchers>' +
                  //-NPR5.49 [342811]
                  // '<voucher reference_no="' + ReferenceNo + '" voucher_type="' + VoucherType.Code + '" xmlns="urn:microsoft-dynamics-schemas/codeunit/global_voucher_service">' +
                  //   '<redeem_date>' + FORMAT(SalePOS.Date,0,9) + '</redeem_date>' +
                  //   '<redeem_register_no>' + SalePOS."Register No." + '</redeem_register_no>' +
                  //   '<redeem_sales_ticket_no>' + SalePOS."Sales Ticket No." + '</redeem_sales_ticket_no>' +
                  //   '<redeem_user_id>' + SalePOS."Salesperson Code" + '</redeem_user_id>' +
                  // '</voucher>' +
                  '<voucher reference_no="' + ReferenceNo + '" voucher_type="' + VoucherType.Code + '" xmlns="urn:microsoft-dynamics-schemas/codeunit/global_voucher_service">' +
                    '<redeem_date>' + Format(NpRvVoucherBuffer."Redeem Date",0,9) + '</redeem_date>' +
                    '<redeem_register_no>' + NpRvVoucherBuffer."Redeem Register No." + '</redeem_register_no>' +
                    '<redeem_sales_ticket_no>' + NpRvVoucherBuffer."Redeem Sales Ticket No." + '</redeem_sales_ticket_no>' +
                    '<redeem_user_id>' + NpRvVoucherBuffer."Redeem User ID" + '</redeem_user_id>' +
                    //-NPR5.49 [342811]
                    '<redeem_partner_code>' + VoucherType."Partner Code" + '</redeem_partner_code>' +
                    //+NPR5.49 [342811]
                  '</voucher>' +
                  //+NPR5.49 [342811]
                '</vouchers>' +
              '</ReserveVouchers>' +
            '</soapenv:Body>' +
          '</soapenv:Envelope>'
        );

        HttpWebRequest := HttpWebRequest.Create(NpRvGlobalVoucherSetup."Service Url");
        HttpWebRequest.UseDefaultCredentials(false);
        Credential := Credential.NetworkCredential(NpRvGlobalVoucherSetup."Service Username",NpRvGlobalVoucherSetup."Service Password");
        HttpWebRequest.Credentials(Credential);
        HttpWebRequest.Method := 'POST';
        HttpWebRequest.ContentType := 'text/xml; charset=utf-8';
        HttpWebRequest.Headers.Add('SOAPAction','ReserveVouchers');
        NpXmlDomMgt.SetTrustedCertificateValidation(HttpWebRequest);

        if not NpXmlDomMgt.SendWebRequest(XmlDoc,HttpWebRequest,HttpWebResponse,WebException) then begin
          //-#361164 [361164]
          ErrorMessage := NpXmlDomMgt.GetWebExceptionMessage(WebException);
          //+#361164 [361164]
          if NpXmlDomMgt.TryLoadXml(ErrorMessage,XmlDoc) then begin
            NpXmlDomMgt.RemoveNameSpaces(XmlDoc);
            ErrorMessage := NpXmlDomMgt.GetXmlText(XmlDoc.DocumentElement,'Body/Fault/faultstring',1000,false);
          end;
          Error(CopyStr(ErrorMessage,1,1000));
        end;

        Response := NpXmlDomMgt.GetWebResponseText(HttpWebResponse);
        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.LoadXml(Response);
        NpXmlDomMgt.RemoveNameSpaces(XmlDoc);
        if not NpXmlDomMgt.FindNode(XmlDoc.DocumentElement,'Body/ReserveVouchers_Result/vouchers/voucher',XmlElement) then
          Error(Text005,ReferenceNo);

        Clear(Voucher);
        Voucher.SetRange("Reference No.",ReferenceNo);
        Voucher.SetRange("Voucher Type",VoucherType.Code);
        if not Voucher.FindLast then begin
          Voucher.Init;
          Voucher."No." := '';
          Voucher."Reference No." := ReferenceNo;
          Voucher.Validate("Voucher Type",VoucherType.Code);
          Voucher.Insert(true);

          VoucherEntry.Init;
          VoucherEntry."Entry No." := 0;
          VoucherEntry."Voucher No." := Voucher."No.";
          //-NPR5.49 [342811]
          // VoucherEntry."Entry Type" := VoucherEntry."Entry Type"::"Issue Voucher";
          VoucherEntry."Entry Type" := VoucherEntry."Entry Type"::"Partner Issue Voucher";
          //+NPR5.49 [342811]
          VoucherEntry."Voucher Type" := Voucher."Voucher Type";
          if Evaluate(VoucherEntry.Amount,NpXmlDomMgt.GetXmlText(XmlElement,'amount',0,false),9) then;
          VoucherEntry."Remaining Amount" := VoucherEntry.Amount;
          VoucherEntry.Positive := VoucherEntry.Amount > 0;
          if Evaluate(VoucherEntry."Posting Date",NpXmlDomMgt.GetXmlText(XmlElement,'issue_date',0,false),9) then;
          VoucherEntry.Open := VoucherEntry.Amount <> 0;
          VoucherEntry."Register No." := NpXmlDomMgt.GetXmlText(XmlElement,'issue_register_no',MaxStrLen(VoucherEntry."Register No."),false);
          VoucherEntry."Document No." := NpXmlDomMgt.GetXmlText(XmlElement,'issue_sales_ticket_no',MaxStrLen(VoucherEntry."Document No."),false);
          VoucherEntry."User ID" := NpXmlDomMgt.GetXmlText(XmlElement,'issue_user_id',MaxStrLen(VoucherEntry."User ID"),false);
          VoucherEntry."Closed by Entry No." := 0;
          //-NPR5.49 [342811]
          VoucherEntry."Partner Code" := UpperCase(NpXmlDomMgt.GetXmlText(XmlElement,'issue_partner_code',MaxStrLen(VoucherEntry."Partner Code"),false));
          //+NPR5.49 [342811]
          VoucherEntry.Insert;
        end;

        Voucher.Description := NpXmlDomMgt.GetXmlText(XmlElement,'description',MaxStrLen(Voucher.Description),false);
        if Evaluate(Voucher."Starting Date",NpXmlDomMgt.GetXmlText(XmlElement,'starting_date',0,false),9) then;
        if Evaluate(Voucher."Ending Date",NpXmlDomMgt.GetXmlText(XmlElement,'ending_date',0,false),9) then;
        Voucher."Account No." := NpXmlDomMgt.GetXmlText(XmlElement,'account_no',MaxStrLen(Voucher."Account No."),false);

        Voucher.Name := NpXmlDomMgt.GetXmlText(XmlElement,'name',MaxStrLen(Voucher.Name),false);
        Voucher."Name 2" := NpXmlDomMgt.GetXmlText(XmlElement,'name_2',MaxStrLen(Voucher."Name 2"),false);
        Voucher.Address := NpXmlDomMgt.GetXmlText(XmlElement,'address',MaxStrLen(Voucher.Address),false);
        Voucher."Address 2" := NpXmlDomMgt.GetXmlText(XmlElement,'address_2',MaxStrLen(Voucher."Address 2"),false);
        Voucher."Post Code" := NpXmlDomMgt.GetXmlText(XmlElement,'post_code',MaxStrLen(Voucher."Post Code"),false);
        Voucher.City := NpXmlDomMgt.GetXmlText(XmlElement,'city',MaxStrLen(Voucher.City),false);
        Voucher.County := NpXmlDomMgt.GetXmlText(XmlElement,'county',MaxStrLen(Voucher.County),false);
        Voucher."Country/Region Code" := NpXmlDomMgt.GetXmlText(XmlElement,'country_code',MaxStrLen(Voucher."Country/Region Code"),false);
        Voucher."E-mail" := NpXmlDomMgt.GetXmlText(XmlElement,'email',MaxStrLen(Voucher."E-mail"),false);
        Voucher."Phone No." := NpXmlDomMgt.GetXmlText(XmlElement,'pohone_no',MaxStrLen(Voucher."Phone No."),false);
        Voucher."Voucher Message" := NpXmlDomMgt.GetXmlText(XmlElement,'voucher_message',MaxStrLen(Voucher."Voucher Message"),false);
        if Evaluate(Voucher."Issue Date",NpXmlDomMgt.GetXmlText(XmlElement,'issue_date',0,false),9) then;
        Voucher.Modify(true);
        Voucher.CalcFields(Amount);
        //-NPR5.49 [342811]
        NpRvVoucherMgt.Voucher2Buffer(Voucher,NpRvVoucherBuffer);
        //+NPR5.49 [342811]
    end;

    procedure RedeemVoucher(VoucherEntry: Record "NpRv Voucher Entry")
    var
        NpRvGlobalVoucherSetup: Record "NpRv Global Voucher Setup";
        Voucher: Record "NpRv Voucher";
        VoucherType: Record "NpRv Voucher Type";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        Credential: DotNet npNetNetworkCredential;
        HttpWebRequest: DotNet npNetHttpWebRequest;
        HttpWebResponse: DotNet npNetHttpWebResponse;
        XmlDoc: DotNet npNetXmlDocument;
        XmlElement: DotNet npNetXmlElement;
        WebException: DotNet npNetWebException;
        ErrorMessage: Text;
    begin
        if VoucherEntry."Entry Type" <> VoucherEntry."Entry Type"::Payment then
          exit;

        VoucherType.Get(VoucherEntry."Voucher Type");
        if VoucherType."Validate Voucher Module" <> ModuleCode() then
          exit;
        NpRvGlobalVoucherSetup.Get(VoucherType.Code);
        NpRvGlobalVoucherSetup.TestField("Service Url");

        Voucher.Get(VoucherEntry."Voucher No.");
        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.LoadXml(
          '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">' +
            '<soapenv:Body>' +
              '<RedeemVouchers xmlns="urn:microsoft-dynamics-schemas/codeunit/' + GetServiceName(NpRvGlobalVoucherSetup) + '">' +
                '<vouchers>' +
                  '<voucher reference_no="' + Voucher."Reference No." + '" voucher_type="' + VoucherType.Code + '" xmlns="urn:microsoft-dynamics-schemas/codeunit/global_voucher_service">' +
                    '<amount>' + Format(-VoucherEntry.Amount,0,9) + '</amount>' +
                    '<redeem_date>' + Format(VoucherEntry."Posting Date",0,9) + '</redeem_date>' +
                    '<redeem_register_no>' + VoucherEntry."Register No." + '</redeem_register_no>' +
                    '<redeem_sales_ticket_no>' + VoucherEntry."Document No." + '</redeem_sales_ticket_no>' +
                    '<redeem_user_id>' + VoucherEntry."User ID" + '</redeem_user_id>' +
                    //-NPR5.49 [342811]
                    '<redeem_partner_code>' + VoucherType."Partner Code" + '</redeem_partner_code>' +
                    //+NPR5.49 [342811]
                  '</voucher>' +
                '</vouchers>' +
              '</RedeemVouchers>' +
            '</soapenv:Body>' +
          '</soapenv:Envelope>'
        );

        HttpWebRequest := HttpWebRequest.Create(NpRvGlobalVoucherSetup."Service Url");
        HttpWebRequest.UseDefaultCredentials(false);
        Credential := Credential.NetworkCredential(NpRvGlobalVoucherSetup."Service Username",NpRvGlobalVoucherSetup."Service Password");
        HttpWebRequest.Credentials(Credential);
        HttpWebRequest.Method := 'POST';
        HttpWebRequest.ContentType := 'text/xml; charset=utf-8';
        HttpWebRequest.Headers.Add('SOAPAction','RedeemVouchers');
        NpXmlDomMgt.SetTrustedCertificateValidation(HttpWebRequest);

        if not NpXmlDomMgt.SendWebRequest(XmlDoc,HttpWebRequest,HttpWebResponse,WebException) then begin
          //-#361164 [361164]
          ErrorMessage := NpXmlDomMgt.GetWebExceptionMessage(WebException);
          //+#361164 [361164]
          if NpXmlDomMgt.TryLoadXml(ErrorMessage,XmlDoc) then begin
            NpXmlDomMgt.RemoveNameSpaces(XmlDoc);
            ErrorMessage := NpXmlDomMgt.GetXmlText(XmlDoc.DocumentElement,'Body/Fault/faultstring',1000,false);
          end;
          Error(CopyStr(ErrorMessage,1,1000));
        end;
    end;

    procedure RedeemPartnerVouchers(NpRvVoucherEntry: Record "NpRv Voucher Entry")
    var
        NpRvPartner: Record "NpRv Partner";
        NpRvPartnerRelation: Record "NpRv Partner Relation";
        NpRvVoucher: Record "NpRv Voucher";
        NpRvVoucherEntry2: Record "NpRv Voucher Entry";
        NpRvVoucherType: Record "NpRv Voucher Type";
        NpRvPartnerMgt: Codeunit "NpRv Partner Mgt.";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        Credential: DotNet npNetNetworkCredential;
        HttpWebRequest: DotNet npNetHttpWebRequest;
        HttpWebResponse: DotNet npNetHttpWebResponse;
        XmlDoc: DotNet npNetXmlDocument;
        XmlElement: DotNet npNetXmlElement;
        WebException: DotNet npNetWebException;
        ErrorMessage: Text;
    begin
        //-NPR5.49 [342811]
        if not (NpRvVoucherEntry."Entry Type" in [NpRvVoucherEntry."Entry Type"::Payment,NpRvVoucherEntry."Entry Type"::"Partner Payment"]) then
          exit;

        NpRvVoucher.Get(NpRvVoucherEntry."Voucher No.");
        NpRvVoucherType.Get(NpRvVoucher."Voucher Type");

        NpRvVoucherEntry2.SetRange("Voucher No.",NpRvVoucherEntry."Voucher No.");
        NpRvVoucherEntry2.SetFilter("Entry Type",'%1|%2',NpRvVoucherEntry2."Entry Type"::"Issue Voucher",NpRvVoucherEntry2."Entry Type"::"Partner Issue Voucher");
        NpRvVoucherEntry2.FindFirst;
        if NpRvVoucherEntry."Partner Code" = NpRvVoucherEntry2."Partner Code" then
          exit;
        if not NpRvPartner.Get(NpRvVoucherEntry2."Partner Code") then
          exit;
        if NpRvPartner."Service Url" = '' then
          exit;
        if not NpRvPartnerRelation.Get(NpRvPartner.Code,NpRvVoucherType.Code) then
          exit;

        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.LoadXml(
          '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">' +
            '<soapenv:Body>' +
              '<RedeemPartnerVouchers xmlns="urn:microsoft-dynamics-schemas/codeunit/' + NpRvPartnerMgt.GetServiceName(NpRvPartner) + '">' +
                '<vouchers>' +
                  '<voucher reference_no="' + NpRvVoucher."Reference No." + '"' +
                  ' voucher_type="' + NpRvVoucher."Voucher Type" + '" xmlns="urn:microsoft-dynamics-schemas/codeunit/global_voucher_service">' +
                    '<amount>' + Format(-NpRvVoucherEntry.Amount,0,9) + '</amount>' +
                    '<redeem_date>' + Format(NpRvVoucherEntry."Posting Date",0,9) + '</redeem_date>' +
                    '<redeem_register_no>' + NpRvVoucherEntry."Register No." + '</redeem_register_no>' +
                    '<redeem_sales_ticket_no>' + NpRvVoucherEntry."Document No." + '</redeem_sales_ticket_no>' +
                    '<redeem_user_id>' + NpRvVoucherEntry."User ID" + '</redeem_user_id>' +
                    '<redeem_partner_code>' + NpRvVoucherEntry."Partner Code" + '</redeem_partner_code>' +
                  '</voucher>' +
                '</vouchers>' +
              '</RedeemPartnerVouchers>' +
            '</soapenv:Body>' +
          '</soapenv:Envelope>'
        );

        HttpWebRequest := HttpWebRequest.Create(NpRvPartner."Service Url");
        HttpWebRequest.UseDefaultCredentials(false);
        Credential := Credential.NetworkCredential(NpRvPartner."Service Username",NpRvPartner."Service Password");
        HttpWebRequest.Credentials(Credential);
        HttpWebRequest.Method := 'POST';
        HttpWebRequest.ContentType := 'text/xml; charset=utf-8';
        HttpWebRequest.Headers.Add('SOAPAction','RedeemPartnerVouchers');
        NpXmlDomMgt.SetTrustedCertificateValidation(HttpWebRequest);

        if not NpXmlDomMgt.SendWebRequest(XmlDoc,HttpWebRequest,HttpWebResponse,WebException) then begin
          //-#361164 [361164]
          ErrorMessage := NpXmlDomMgt.GetWebExceptionMessage(WebException);
          //+#361164 [361164]
          if NpXmlDomMgt.TryLoadXml(ErrorMessage,XmlDoc) then begin
            NpXmlDomMgt.RemoveNameSpaces(XmlDoc);
            ErrorMessage := NpXmlDomMgt.GetXmlText(XmlDoc.DocumentElement,'Body/Fault/faultstring',1000,false);
          end;
          Error(CopyStr(ErrorMessage,1,1000));
        end;
        //+NPR5.49 [342811]
    end;

    local procedure "--- Aux"()
    begin
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NpRv Module Validate - Global");
    end;

    local procedure GetServiceName(NpRvGlobalVoucherSetup: Record "NpRv Global Voucher Setup") ServiceName: Text
    var
        Position: Integer;
    begin
        ServiceName := NpRvGlobalVoucherSetup."Service Url";
        Position := StrPos(ServiceName,'?');
        if Position > 0 then
          ServiceName := DelStr(ServiceName,Position);

        if ServiceName = '' then
          exit('');

        if ServiceName[StrLen(ServiceName)] = '/' then
          ServiceName := DelStr(ServiceName,StrLen(ServiceName));

        Position := StrPos(ServiceName,'/');
        while Position > 0 do begin
          ServiceName := DelStr(ServiceName,1,Position);
          Position := StrPos(ServiceName,'/');
        end;

        exit(ServiceName);
    end;

    local procedure IsSubscriber(VoucherType: Record "NpRv Voucher Type"): Boolean
    begin
        exit(VoucherType."Validate Voucher Module" = ModuleCode());
    end;

    local procedure ModuleCode(): Code[20]
    begin
        exit('GLOBAL');
    end;
}

