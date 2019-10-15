codeunit 6151020 "NpRv Global Voucher Webservice"
{
    // NPR5.42/MHA /20180525  CASE 307022 Object created - Global Retail Voucher
    // NPR5.48/MHA /20180921  CASE 302179 Replaced direct check on Voucher."In-Use Quantity" with CalcInUseQty
    // NPR5.49/MHA /20190228  CASE 342811 Added Retail Voucher Partner functionality used with Cross Company Vouchers
    // NPR5.51/MHA /20190705  CASE 361164 Updated Exception Message parsing in InvokeRedeemPartnerVouchers()


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Invalid Reference No. %1';
        Text001: Label 'Voucher %1 is already in use';
        Text002: Label 'Insufficient Remaining Voucher Amount %1';
        Text003: Label 'Voucher %1 has already been used';
        Text004: Label 'Voucher %1 is not valid yet';
        Text005: Label 'Voucher %1 is not valid anymore';

    local procedure "--- Upsert Partner"()
    begin
    end;

    [Scope('Personalization')]
    procedure UpsertPartners(var retail_voucher_partners: XMLport "NpRv Partners")
    var
        TempNpRvPartner: Record "NpRv Partner" temporary;
        TempNpRvPartnerRelation: Record "NpRv Partner Relation" temporary;
    begin
        //-NPR5.49 [342811]
        retail_voucher_partners.Import;
        retail_voucher_partners.GetSourceTables(TempNpRvPartner,TempNpRvPartnerRelation);

        if not TempNpRvPartner.FindSet then
          exit;

        repeat
          UpsertPartner(TempNpRvPartner,TempNpRvPartnerRelation);
        until TempNpRvPartner.Next = 0;
        //+NPR5.49 [342811]
    end;

    local procedure UpsertPartner(var TempNpRvPartner: Record "NpRv Partner" temporary;var TempNpRvPartnerRelation: Record "NpRv Partner Relation" temporary)
    var
        NpRvPartner: Record "NpRv Partner";
        NpRvPartnerRelation: Record "NpRv Partner Relation";
        PrevRec: Text;
    begin
        //-NPR5.49 [342811]
        if not NpRvPartner.Get(TempNpRvPartner.Code) then begin
          NpRvPartner.Init;
          NpRvPartner := TempNpRvPartner;
          NpRvPartner.Insert(true);
        end;

        PrevRec := Format(NpRvPartner);
        NpRvPartner.TransferFields(TempNpRvPartner,false);
        if PrevRec <> Format(NpRvPartner) then
          NpRvPartner.Modify(true);

        Clear(TempNpRvPartnerRelation);
        TempNpRvPartnerRelation.SetRange("Partner Code",NpRvPartner.Code);
        if TempNpRvPartnerRelation.FindSet then
          repeat
            if not NpRvPartnerRelation.Get(TempNpRvPartnerRelation."Partner Code",TempNpRvPartnerRelation."Voucher Type") then begin
              NpRvPartnerRelation.Init;
              NpRvPartnerRelation := TempNpRvPartnerRelation;
              NpRvPartnerRelation.Insert(true);
            end;
          until TempNpRvPartnerRelation.Next = 0;
        //+NPR5.49 [342811]
    end;

    local procedure "--- Create Voucher"()
    begin
    end;

    [Scope('Personalization')]
    procedure CreateVouchers(var vouchers: XMLport "NpRv Global Vouchers")
    var
        NpRvVoucherBuffer: Record "NpRv Voucher Buffer" temporary;
    begin
        vouchers.Import;
        vouchers.GetSourceTable(NpRvVoucherBuffer);

        if NpRvVoucherBuffer.IsEmpty then
          exit;

        NpRvVoucherBuffer.FindSet;
        repeat
          CreateVoucher(NpRvVoucherBuffer);
        until NpRvVoucherBuffer.Next = 0;
    end;

    local procedure CreateVoucher(var NpRvVoucherBuffer: Record "NpRv Voucher Buffer" temporary)
    var
        NpRvVoucher: Record "NpRv Voucher";
        NpRvVoucherType: Record "NpRv Voucher Type";
        NpRvVoucherEntry: Record "NpRv Voucher Entry";
    begin
        NpRvVoucherBuffer.TestField("Voucher Type");
        NpRvVoucherBuffer.TestField("Reference No.");
        if FindVoucher(NpRvVoucherBuffer."Voucher Type",NpRvVoucherBuffer."Reference No.",NpRvVoucher) then
          exit;

        //-NPR5.49 [342811]
        NpRvVoucherType.Get(NpRvVoucherBuffer."Voucher Type");
        //+NPR5.49 [342811]

        NpRvVoucher.Init;
        NpRvVoucher."No." := '';
        NpRvVoucher."Reference No." := NpRvVoucherBuffer."Reference No.";
        NpRvVoucher."Voucher Type" := NpRvVoucherBuffer."Voucher Type";
        NpRvVoucher.Description := NpRvVoucherBuffer.Description;
        NpRvVoucher."Starting Date" := NpRvVoucherBuffer."Starting Date";
        NpRvVoucher."Ending Date" := NpRvVoucherBuffer."Ending Date";
        NpRvVoucher."Account No." := NpRvVoucherBuffer."Account No.";
        NpRvVoucher.Amount := NpRvVoucherBuffer.Amount;
        NpRvVoucher.Name := NpRvVoucherBuffer.Name;
        NpRvVoucher."Name 2" := NpRvVoucherBuffer."Name 2";
        NpRvVoucher.Address := NpRvVoucherBuffer.Address;
        NpRvVoucher."Address 2" := NpRvVoucherBuffer."Address 2";
        NpRvVoucher."Post Code" := NpRvVoucherBuffer."Post Code";
        NpRvVoucher.City := NpRvVoucherBuffer.City;
        NpRvVoucher.County := NpRvVoucherBuffer.County;
        NpRvVoucher."Country/Region Code" := NpRvVoucherBuffer."Country/Region Code";
        NpRvVoucher."E-mail" := NpRvVoucherBuffer."E-mail";
        NpRvVoucher."Phone No." := NpRvVoucherBuffer."Phone No.";
        NpRvVoucher."Voucher Message" := NpRvVoucherBuffer."Voucher Message";
        NpRvVoucher."Issue Date" := NpRvVoucherBuffer."Issue Date";
        NpRvVoucher."Issue Register No." := NpRvVoucherBuffer."Issue Register No.";
        NpRvVoucher."Issue Document No." := NpRvVoucherBuffer."Issue Sales Ticket No.";
        NpRvVoucher."Issue User ID" := NpRvVoucherBuffer."Issue User ID";
        NpRvVoucher.Insert(true);

        NpRvVoucherEntry.Init;
        NpRvVoucherEntry."Entry No." := 0;
        NpRvVoucherEntry."Voucher No." := NpRvVoucher."No.";
        NpRvVoucherEntry."Entry Type" := NpRvVoucherEntry."Entry Type"::"Issue Voucher";
        //-NPR5.49 [342811]
        if NpRvVoucherType."Partner Code" <> NpRvVoucherBuffer."Issue Partner Code" then
          NpRvVoucherEntry."Entry Type" := NpRvVoucherEntry."Entry Type"::"Partner Issue Voucher";
        //+NPR5.49 [342811]
        NpRvVoucherEntry."Voucher Type" := NpRvVoucher."Voucher Type";
        NpRvVoucherEntry.Amount := NpRvVoucherBuffer.Amount;
        NpRvVoucherEntry."Remaining Amount" := NpRvVoucherEntry.Amount;
        NpRvVoucherEntry.Positive := NpRvVoucherEntry.Amount > 0;
        NpRvVoucherEntry."Posting Date" := NpRvVoucherBuffer."Issue Date";
        NpRvVoucherEntry.Open := NpRvVoucherEntry.Amount <> 0;
        NpRvVoucherEntry."Register No." := NpRvVoucherBuffer."Issue Register No.";
        NpRvVoucherEntry."Document No." := NpRvVoucherBuffer."Issue Sales Ticket No.";
        NpRvVoucherEntry."User ID" := NpRvVoucherBuffer."Issue User ID";
        //-NPR5.49 [342811]
        NpRvVoucherEntry."Partner Code" := NpRvVoucherBuffer."Issue Partner Code";
        //+NPR5.49 [342811]
        NpRvVoucherEntry."Closed by Entry No." := 0;
        NpRvVoucherEntry.Insert;
    end;

    local procedure "--- Reserve Voucher"()
    begin
    end;

    [Scope('Personalization')]
    procedure ReserveVouchers(var vouchers: XMLport "NpRv Global Vouchers")
    var
        NpRvVoucherBuffer: Record "NpRv Voucher Buffer" temporary;
    begin
        SetGlobalLanguage(UserId);

        vouchers.Import;
        vouchers.GetSourceTable(NpRvVoucherBuffer);

        if NpRvVoucherBuffer.IsEmpty then
          exit;

        NpRvVoucherBuffer.FindSet;
        repeat
          ReserveVoucher(NpRvVoucherBuffer);
        until NpRvVoucherBuffer.Next = 0;
    end;

    local procedure ReserveVoucher(var NpRvVoucherBuffer: Record "NpRv Voucher Buffer" temporary)
    var
        NpRvVoucher: Record "NpRv Voucher";
        NpRvSaleLinePOSVoucher: Record "NpRv Sale Line POS Voucher";
        LineNo: Integer;
        Timestamp: DateTime;
        InUseQty: Integer;
    begin
        if not FindVoucher(NpRvVoucherBuffer."Voucher Type",NpRvVoucherBuffer."Reference No.",NpRvVoucher) then
          Error(Text000,NpRvVoucherBuffer."Reference No.");

        Voucher2Buffer(NpRvVoucher,NpRvVoucherBuffer);
        NpRvVoucherBuffer.Modify;

        //-NPR5.48 [302179]
        //NpRvVoucher.CALCFIELDS("In-use Quantity",Open);
        NpRvVoucher.CalcFields(Open);
        InUseQty := NpRvVoucher.CalcInUseQty();
        //+NPR5.48 [302179]
        if not NpRvVoucher.Open then
          Error(Text003,NpRvVoucherBuffer."Reference No.");

        //-NPR5.48 [302179]
        //IF NpRvVoucher."In-use Quantity" > 0 THEN BEGIN
        if InUseQty > 0 then begin
        //+NPR5.48 [302179]
          NpRvSaleLinePOSVoucher.SetRange("Register No.",NpRvVoucherBuffer."Redeem Register No.");
          NpRvSaleLinePOSVoucher.SetRange("Sales Ticket No.",NpRvVoucherBuffer."Redeem Sales Ticket No.");
          NpRvSaleLinePOSVoucher.SetRange("Sale Type",NpRvSaleLinePOSVoucher."Sale Type"::Sale);
          NpRvSaleLinePOSVoucher.SetRange("Sale Date",NpRvVoucherBuffer."Redeem Date");
          NpRvSaleLinePOSVoucher.SetRange("Voucher Type",NpRvVoucher."Voucher Type");
          NpRvSaleLinePOSVoucher.SetRange("Voucher No.",NpRvVoucher."No.");
          //-NPR5.48 [302179]
          // IF NpRvVoucher."In-use Quantity" = NpRvSaleLinePOSVoucher.COUNT THEN
          //   EXIT;
          if InUseQty = NpRvSaleLinePOSVoucher.Count then
            exit;
          //+NPR5.48 [302179]

          Error(Text001,NpRvVoucherBuffer."Reference No.");
        end;

        Timestamp := CurrentDateTime;
        if NpRvVoucher."Starting Date" >  Timestamp then
          Error(Text004,NpRvVoucherBuffer."Reference No.");

        if (NpRvVoucher."Ending Date" < Timestamp) and (NpRvVoucher."Ending Date" <> 0DT) then
          Error(Text005,NpRvVoucherBuffer."Reference No.");

        NpRvSaleLinePOSVoucher.SetRange("Register No.",NpRvVoucherBuffer."Redeem Register No.");
        NpRvSaleLinePOSVoucher.SetRange("Sales Ticket No.",NpRvVoucherBuffer."Redeem Sales Ticket No.");
        NpRvSaleLinePOSVoucher.SetRange("Sale Type",NpRvSaleLinePOSVoucher."Sale Type"::Sale);
        NpRvSaleLinePOSVoucher.SetRange("Sale Date",NpRvVoucherBuffer."Redeem Date");
        NpRvSaleLinePOSVoucher.SetRange("Sale Line No.",10000);
        if NpRvSaleLinePOSVoucher.FindLast then;
        LineNo := NpRvSaleLinePOSVoucher."Line No." + 10000;

        NpRvSaleLinePOSVoucher.Init;
        NpRvSaleLinePOSVoucher."Register No." :=  NpRvVoucherBuffer."Redeem Register No.";
        NpRvSaleLinePOSVoucher."Sales Ticket No." := NpRvVoucherBuffer."Redeem Sales Ticket No.";
        NpRvSaleLinePOSVoucher."Sale Type" := NpRvSaleLinePOSVoucher."Sale Type"::Sale;
        NpRvSaleLinePOSVoucher."Sale Date" := NpRvVoucherBuffer."Redeem Date";
        NpRvSaleLinePOSVoucher."Sale Line No." := 10000;
        NpRvSaleLinePOSVoucher."Line No." := LineNo;
        NpRvSaleLinePOSVoucher.Type := NpRvSaleLinePOSVoucher.Type::Payment;
        NpRvSaleLinePOSVoucher."Voucher Type" := NpRvVoucher."Voucher Type";
        NpRvSaleLinePOSVoucher."Voucher No." := NpRvVoucher."No.";
        NpRvSaleLinePOSVoucher.Description := NpRvVoucher.Description;
        NpRvSaleLinePOSVoucher.Insert;
    end;

    local procedure "--- Cancel Reserve Voucher"()
    begin
    end;

    [Scope('Personalization')]
    procedure CancelReserveVouchers(var vouchers: XMLport "NpRv Global Vouchers")
    var
        NpRvVoucherBuffer: Record "NpRv Voucher Buffer" temporary;
    begin
        //-NPR5.49 [342811]
        SetGlobalLanguage(UserId);

        vouchers.Import;
        vouchers.GetSourceTable(NpRvVoucherBuffer);

        if NpRvVoucherBuffer.IsEmpty then
          exit;

        NpRvVoucherBuffer.FindSet;
        repeat
          CancelReserveVoucher(NpRvVoucherBuffer);
        until NpRvVoucherBuffer.Next = 0;
        //+NPR5.49 [342811]
    end;

    local procedure CancelReserveVoucher(var NpRvVoucherBuffer: Record "NpRv Voucher Buffer" temporary)
    var
        NpRvVoucher: Record "NpRv Voucher";
        NpRvSaleLinePOSVoucher: Record "NpRv Sale Line POS Voucher";
        LineNo: Integer;
        Timestamp: DateTime;
        InUseQty: Integer;
    begin
        //-NPR5.49 [342811]
        if not FindVoucher(NpRvVoucherBuffer."Voucher Type",NpRvVoucherBuffer."Reference No.",NpRvVoucher) then
          exit;

        Voucher2Buffer(NpRvVoucher,NpRvVoucherBuffer);
        NpRvVoucherBuffer.Modify;

        InUseQty := NpRvVoucher.CalcInUseQty();
        if InUseQty = 0 then
          exit;

        NpRvSaleLinePOSVoucher.SetRange("Register No.",NpRvVoucherBuffer."Redeem Register No.");
        NpRvSaleLinePOSVoucher.SetRange("Sales Ticket No.",NpRvVoucherBuffer."Redeem Sales Ticket No.");
        NpRvSaleLinePOSVoucher.SetRange("Sale Type",NpRvSaleLinePOSVoucher."Sale Type"::Sale);
        NpRvSaleLinePOSVoucher.SetRange("Sale Date",NpRvVoucherBuffer."Redeem Date");
        NpRvSaleLinePOSVoucher.SetRange("Voucher Type",NpRvVoucher."Voucher Type");
        NpRvSaleLinePOSVoucher.SetRange("Voucher No.",NpRvVoucher."No.");
        if NpRvSaleLinePOSVoucher.FindFirst then
          NpRvSaleLinePOSVoucher.DeleteAll;
        //+NPR5.49 [342811]
    end;

    local procedure "--- Redeem Voucher"()
    begin
    end;

    [Scope('Personalization')]
    procedure RedeemVouchers(var vouchers: XMLport "NpRv Global Vouchers")
    var
        NpRvVoucherBuffer: Record "NpRv Voucher Buffer" temporary;
    begin
        SetGlobalLanguage(UserId);

        vouchers.Import;
        vouchers.GetSourceTable(NpRvVoucherBuffer);

        if NpRvVoucherBuffer.IsEmpty then
          exit;

        NpRvVoucherBuffer.FindSet;
        repeat
          RedeemVoucher(NpRvVoucherBuffer);
        until NpRvVoucherBuffer.Next = 0;

        //-NPR5.49 [342811]
        NpRvVoucherBuffer.FindSet;
        repeat
          InvokeRedeemPartnerVouchers(NpRvVoucherBuffer);
        until NpRvVoucherBuffer.Next = 0;
        //+NPR5.49 [342811]
    end;

    local procedure RedeemVoucher(var NpRvVoucherBuffer: Record "NpRv Voucher Buffer" temporary)
    var
        NpRvVoucher: Record "NpRv Voucher";
        NpRvVoucherEntry: Record "NpRv Voucher Entry";
        NpRvVoucherType: Record "NpRv Voucher Type";
        NpRvSaleLinePOSVoucher: Record "NpRv Sale Line POS Voucher";
        NpRvVoucherMgt: Codeunit "NpRv Voucher Mgt.";
        LineNo: Integer;
        InUseQty: Integer;
    begin
        if not FindVoucher(NpRvVoucherBuffer."Voucher Type",NpRvVoucherBuffer."Reference No.",NpRvVoucher) then
          Error(Text000,NpRvVoucherBuffer."Reference No.");
        NpRvVoucher.CalcFields(Open,Amount);
        NpRvVoucher.TestField(Open);
        if NpRvVoucher.Amount < NpRvVoucherBuffer.Amount then
          Error(Text002,NpRvVoucher.Amount);

        //-NPR5.49 [342811]
        NpRvVoucherType.Get(NpRvVoucher."Voucher Type");
        //+NPR5.49 [342811]

        NpRvVoucherEntry.Init;
        NpRvVoucherEntry."Entry No." := 0;
        NpRvVoucherEntry."Voucher No." := NpRvVoucher."No.";
        NpRvVoucherEntry."Entry Type" := NpRvVoucherEntry."Entry Type"::Payment;
        //-NPR5.49 [342811]
        if NpRvVoucherType."Partner Code" <>  NpRvVoucherBuffer."Redeem Partner Code" then
          NpRvVoucherEntry."Entry Type" := NpRvVoucherEntry."Entry Type"::"Partner Payment";
        //+NPR5.49 [342811]
        NpRvVoucherEntry."Voucher Type" := NpRvVoucher."Voucher Type";
        NpRvVoucherEntry.Amount := -NpRvVoucherBuffer.Amount;
        NpRvVoucherEntry."Remaining Amount" := NpRvVoucherEntry.Amount;
        NpRvVoucherEntry.Positive := NpRvVoucherEntry.Amount > 0;
        NpRvVoucherEntry."Posting Date" := NpRvVoucherBuffer."Redeem Date";
        NpRvVoucherEntry.Open := NpRvVoucherEntry.Amount <> 0;
        NpRvVoucherEntry."Register No." := NpRvVoucherBuffer."Redeem Register No.";
        NpRvVoucherEntry."Document No." := NpRvVoucherBuffer."Redeem Sales Ticket No.";
        NpRvVoucherEntry."User ID" := NpRvVoucherBuffer."Redeem User ID";
        //-NPR5.49 [342811]
        NpRvVoucherEntry."Partner Code" := NpRvVoucherBuffer."Redeem Partner Code";
        //+NPR5.49 [342811]
        NpRvVoucherEntry."Closed by Entry No." := 0;
        NpRvVoucherEntry.Insert;

        //-NPR5.49 [342811]
        //ApplyEntry(NpRvVoucherEntry);
        NpRvVoucherMgt.ApplyEntry(NpRvVoucherEntry);
        Voucher2Buffer(NpRvVoucher,NpRvVoucherBuffer);
        NpRvVoucherBuffer.Amount := -NpRvVoucherEntry.Amount;
        NpRvVoucherBuffer.Modify;
        //+NPR5.49 [342811]

        NpRvVoucher.CalcFields(Open);
        if not NpRvVoucher.Open then
          NpRvVoucherMgt.ArchiveVouchers(NpRvVoucher);

        //-NPR5.48 [302179]
        // NpRvVoucher.CALCFIELDS("In-use Quantity");
        // IF NpRvVoucher."In-use Quantity" > 0 THEN BEGIN
        InUseQty := NpRvVoucher.CalcInUseQty();
        if InUseQty > 0 then begin
        //+NPR5.48 [302179]
          NpRvSaleLinePOSVoucher.SetRange("Register No.",NpRvVoucherBuffer."Redeem Register No.");
          NpRvSaleLinePOSVoucher.SetRange("Sales Ticket No.",NpRvVoucherBuffer."Redeem Sales Ticket No.");
          NpRvSaleLinePOSVoucher.SetRange("Sale Type",NpRvSaleLinePOSVoucher."Sale Type"::Sale);
          NpRvSaleLinePOSVoucher.SetRange("Sale Date",NpRvVoucherBuffer."Redeem Date");
          NpRvSaleLinePOSVoucher.SetRange("Voucher Type",NpRvVoucher."Voucher Type");
          NpRvSaleLinePOSVoucher.SetRange("Voucher No.",NpRvVoucher."No.");
          //-NPR5.48 [302179]
          // IF NpRvVoucher."In-use Quantity" > NpRvSaleLinePOSVoucher.COUNT THEN
          //  ERROR(Text001,NpRvVoucherBuffer."Reference No.");
          if InUseQty > NpRvSaleLinePOSVoucher.Count then
            Error(Text001,NpRvVoucherBuffer."Reference No.");
          //+NPR5.48 [302179]

          NpRvSaleLinePOSVoucher.DeleteAll;
        end;

        //-NPR5.49 [342811]
        //Voucher2Buffer(NpRvVoucher,NpRvVoucherBuffer);
        //NpRvVoucherBuffer.MODIFY;
        //+NPR5.49 [342811]
    end;

    local procedure "--- Partner Payment"()
    begin
    end;

    [Scope('Personalization')]
    procedure InvokeRedeemPartnerVouchers(var NpRvVoucherBuffer: Record "NpRv Voucher Buffer" temporary)
    var
        NpRvPartner: Record "NpRv Partner";
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
        if NpRvVoucherBuffer."Issue Partner Code" = NpRvVoucherBuffer."Redeem Partner Code" then
          exit;
        if not NpRvPartner.Get(NpRvVoucherBuffer."Issue Partner Code") then
          exit;
        if NpRvPartner."Service Url" = '' then
          exit;

        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.LoadXml(
          '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">' +
            '<soapenv:Body>' +
              '<RedeemPartnerVouchers xmlns="urn:microsoft-dynamics-schemas/codeunit/' + GetServiceName(NpRvPartner) + '">' +
                '<vouchers>' +
                  '<voucher reference_no="' + NpRvVoucherBuffer."Reference No." + '"' +
                  ' voucher_type="' + NpRvVoucherBuffer."Voucher Type" + '" xmlns="urn:microsoft-dynamics-schemas/codeunit/global_voucher_service">' +
                    '<amount>' + Format(NpRvVoucherBuffer.Amount,0,9) + '</amount>' +
                    '<redeem_date>' + Format(NpRvVoucherBuffer."Redeem Date",0,9) + '</redeem_date>' +
                    '<redeem_register_no>' + NpRvVoucherBuffer."Redeem Register No." + '</redeem_register_no>' +
                    '<redeem_sales_ticket_no>' + NpRvVoucherBuffer."Redeem Sales Ticket No." + '</redeem_sales_ticket_no>' +
                    '<redeem_user_id>' + NpRvVoucherBuffer."Redeem User ID" + '</redeem_user_id>' +
                    '<redeem_partner_code>' + NpRvVoucherBuffer."Redeem Partner Code" + '</redeem_partner_code>' +
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
          //-NPR5.51 [361164]
          ErrorMessage := NpXmlDomMgt.GetWebExceptionMessage(WebException);
          if NpXmlDomMgt.TryLoadXml(ErrorMessage,XmlDoc) then begin
            NpXmlDomMgt.RemoveNameSpaces(XmlDoc);
            if NpXmlDomMgt.FindNode(XmlDoc.DocumentElement,'//faultstring',XmlElement) then
              ErrorMessage := XmlElement.InnerText;
          end;
          Error(CopyStr(ErrorMessage,1,1000));
          //+NPR5.51 [361164]
        end;
        //+NPR5.49 [342811]
    end;

    [Scope('Personalization')]
    procedure RedeemPartnerVouchers(var vouchers: XMLport "NpRv Global Vouchers")
    var
        NpRvVoucherBuffer: Record "NpRv Voucher Buffer" temporary;
    begin
        //-NPR5.49 [342811]
        SetGlobalLanguage(UserId);

        vouchers.Import;
        vouchers.GetSourceTable(NpRvVoucherBuffer);

        if NpRvVoucherBuffer.IsEmpty then
          exit;

        NpRvVoucherBuffer.FindSet;
        repeat
          RedeemPartnerVoucher(NpRvVoucherBuffer);
        until NpRvVoucherBuffer.Next = 0;
        //+NPR5.49 [342811]
    end;

    local procedure RedeemPartnerVoucher(var NpRvVoucherBuffer: Record "NpRv Voucher Buffer" temporary)
    var
        NpRvVoucher: Record "NpRv Voucher";
        NpRvVoucherEntry: Record "NpRv Voucher Entry";
        NpRvSaleLinePOSVoucher: Record "NpRv Sale Line POS Voucher";
        NpRvVoucherMgt: Codeunit "NpRv Voucher Mgt.";
        LineNo: Integer;
        InUseQty: Integer;
    begin
        //-NPR5.49 [342811]
        if not FindVoucher(NpRvVoucherBuffer."Voucher Type",NpRvVoucherBuffer."Reference No.",NpRvVoucher) then
          exit;

        NpRvVoucher.CalcFields(Open,Amount);
        NpRvVoucher.TestField(Open);
        if NpRvVoucher.Amount < NpRvVoucherBuffer.Amount then
          Error(Text002,NpRvVoucher.Amount);

        NpRvVoucherEntry.Init;
        NpRvVoucherEntry."Entry No." := 0;
        NpRvVoucherEntry."Voucher No." := NpRvVoucher."No.";
        NpRvVoucherEntry."Entry Type" := NpRvVoucherEntry."Entry Type"::"Partner Payment";
        NpRvVoucherEntry."Voucher Type" := NpRvVoucher."Voucher Type";
        NpRvVoucherEntry.Amount := -NpRvVoucherBuffer.Amount;
        NpRvVoucherEntry."Remaining Amount" := NpRvVoucherEntry.Amount;
        NpRvVoucherEntry.Positive := NpRvVoucherEntry.Amount > 0;
        NpRvVoucherEntry."Posting Date" := NpRvVoucherBuffer."Redeem Date";
        NpRvVoucherEntry.Open := NpRvVoucherEntry.Amount <> 0;
        NpRvVoucherEntry."Register No." := NpRvVoucherBuffer."Redeem Register No.";
        NpRvVoucherEntry."Document No." := NpRvVoucherBuffer."Redeem Sales Ticket No.";
        NpRvVoucherEntry."User ID" := NpRvVoucherBuffer."Redeem User ID";
        NpRvVoucherEntry."Partner Code" := NpRvVoucherBuffer."Redeem Partner Code";
        NpRvVoucherEntry."Closed by Entry No." := 0;
        NpRvVoucherEntry.Insert;

        //-NPR5.49 [342811]
        //ApplyEntry(NpRvVoucherEntry);
        NpRvVoucherMgt.ApplyEntry(NpRvVoucherEntry);
        //+NPR5.49 [342811]
        NpRvVoucher.CalcFields(Open);
        if not NpRvVoucher.Open then
          NpRvVoucherMgt.ArchiveVouchers(NpRvVoucher);

        InUseQty := NpRvVoucher.CalcInUseQty();
        if InUseQty > 0 then begin
          NpRvSaleLinePOSVoucher.SetRange("Register No.",NpRvVoucherBuffer."Redeem Register No.");
          NpRvSaleLinePOSVoucher.SetRange("Sales Ticket No.",NpRvVoucherBuffer."Redeem Sales Ticket No.");
          NpRvSaleLinePOSVoucher.SetRange("Sale Type",NpRvSaleLinePOSVoucher."Sale Type"::Sale);
          NpRvSaleLinePOSVoucher.SetRange("Sale Date",NpRvVoucherBuffer."Redeem Date");
          NpRvSaleLinePOSVoucher.SetRange("Voucher Type",NpRvVoucher."Voucher Type");
          NpRvSaleLinePOSVoucher.SetRange("Voucher No.",NpRvVoucher."No.");
          NpRvSaleLinePOSVoucher.DeleteAll;
        end;

        Voucher2Buffer(NpRvVoucher,NpRvVoucherBuffer);
        NpRvVoucherBuffer.Modify;
        //+NPR5.49 [342811]
    end;

    local procedure "--- Aux"()
    begin
    end;

    [Scope('Personalization')]
    procedure FindVoucher(VoucherTypeFilter: Text;ReferenceNo: Text[30];var Voucher: Record "NpRv Voucher"): Boolean
    var
        VoucherType: Record "NpRv Voucher Type";
    begin
        Voucher.SetFilter("Voucher Type",UpperCase(VoucherTypeFilter));
        Voucher.SetRange("Reference No.",ReferenceNo);
        exit(Voucher.FindLast);
    end;

    local procedure GetServiceName(NpRvIssuer: Record "NpRv Partner") ServiceName: Text
    var
        Position: Integer;
    begin
        //-NPR5.49 [342811]
        ServiceName := NpRvIssuer."Service Url";
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
        //+NPR5.49 [342811]
    end;

    local procedure Voucher2Buffer(var NpRvVoucher: Record "NpRv Voucher";var NpRvVoucherBuffer: Record "NpRv Voucher Buffer")
    begin
        //-NPR5.49 [342811]
        //NpRvVoucher.CALCFIELDS(Amount,"Issue Date","Issue Register No.","Issue Document No.","Issue User ID");
        NpRvVoucher.CalcFields(Amount,"Issue Date","Issue Register No.","Issue Document No.","Issue User ID","Issue Partner Code");
        //+NPR5.49 [342811]
        NpRvVoucherBuffer."Voucher Type" := NpRvVoucher."Voucher Type";
        NpRvVoucherBuffer.Description := NpRvVoucher.Description;
        NpRvVoucherBuffer."Starting Date" := NpRvVoucher."Starting Date";
        NpRvVoucherBuffer."Ending Date" := NpRvVoucher."Ending Date";
        NpRvVoucherBuffer."Account No." := NpRvVoucher."Account No.";
        NpRvVoucherBuffer.Amount := NpRvVoucher.Amount;
        NpRvVoucherBuffer.Name := NpRvVoucher.Name;
        NpRvVoucherBuffer."Name 2" := NpRvVoucher."Name 2";
        NpRvVoucherBuffer.Address := NpRvVoucher.Address;
        NpRvVoucherBuffer."Address 2" := NpRvVoucher."Address 2";
        NpRvVoucherBuffer."Post Code" := NpRvVoucher."Post Code";
        NpRvVoucherBuffer.City := NpRvVoucher.City;
        NpRvVoucherBuffer.County := NpRvVoucher.County;
        NpRvVoucherBuffer."Country/Region Code" := NpRvVoucher."Country/Region Code";
        NpRvVoucherBuffer."E-mail" := NpRvVoucher."E-mail";
        NpRvVoucherBuffer."Phone No." := NpRvVoucher."Phone No.";
        NpRvVoucherBuffer."Voucher Message" := NpRvVoucher."Voucher Message";
        NpRvVoucherBuffer."Issue Date" := NpRvVoucher."Issue Date";
        NpRvVoucherBuffer."Issue Register No." := NpRvVoucher."Issue Register No.";
        NpRvVoucherBuffer."Issue Sales Ticket No." := NpRvVoucher."Issue Document No.";
        NpRvVoucherBuffer."Issue User ID" := NpRvVoucher."Issue User ID";
        //-NPR5.49 [342811]
        // NpRvVoucherBuffer.MODIFY;
        NpRvVoucherBuffer."Issue Partner Code" := NpRvVoucher."Issue Partner Code";
        //+NPR5.49 [342811]
    end;

    local procedure SetGlobalLanguage(LanguageUsername: Text)
    var
        User: Record User;
        UserPersonalization: Record "User Personalization";
    begin
        User.SetRange("User Name",LanguageUsername);
        if not User.FindFirst then
          exit;

        if not UserPersonalization.Get(User."User Security ID") then
          exit;

        if UserPersonalization."Language ID" > 0 then
          GlobalLanguage(UserPersonalization."Language ID");
    end;
}

