codeunit 6151020 "NPR NpRv Global Voucher WS"
{
    var
        Text000: Label 'Invalid Reference No. %1';
        Text001: Label 'Voucher %1 is already in use';
        Text002: Label 'Insufficient Remaining Voucher Amount %1';
        Text003: Label 'Voucher %1 has already been used';
        Text004: Label 'Voucher %1 is not valid yet';
        Text005: Label 'Voucher %1 is not valid anymore';

    procedure UpsertPartners(var retail_voucher_partners: XMLport "NPR NpRv Partners")
    var
        TempNpRvPartner: Record "NPR NpRv Partner" temporary;
        TempNpRvPartnerRelation: Record "NPR NpRv Partner Relation" temporary;
    begin
        retail_voucher_partners.Import();
        retail_voucher_partners.GetSourceTables(TempNpRvPartner, TempNpRvPartnerRelation);

        if not TempNpRvPartner.FindSet() then
            exit;

        repeat
            UpsertPartner(TempNpRvPartner, TempNpRvPartnerRelation);
        until TempNpRvPartner.Next() = 0;
    end;

    local procedure UpsertPartner(var TempNpRvPartner: Record "NPR NpRv Partner" temporary; var TempNpRvPartnerRelation: Record "NPR NpRv Partner Relation" temporary)
    var
        NpRvPartner: Record "NPR NpRv Partner";
        NpRvPartnerRelation: Record "NPR NpRv Partner Relation";
        PrevRec: Text;
    begin
        if not NpRvPartner.Get(TempNpRvPartner.Code) then begin
            NpRvPartner.Init();
            NpRvPartner := TempNpRvPartner;
            NpRvPartner.Insert(true);
        end;

        PrevRec := Format(NpRvPartner);
        NpRvPartner.TransferFields(TempNpRvPartner, false);
        if PrevRec <> Format(NpRvPartner) then
            NpRvPartner.Modify(true);

        Clear(TempNpRvPartnerRelation);
        TempNpRvPartnerRelation.SetRange("Partner Code", NpRvPartner.Code);
        if TempNpRvPartnerRelation.FindSet() then
            repeat
                if not NpRvPartnerRelation.Get(TempNpRvPartnerRelation."Partner Code", TempNpRvPartnerRelation."Voucher Type") then begin
                    NpRvPartnerRelation.Init();
                    NpRvPartnerRelation := TempNpRvPartnerRelation;
                    NpRvPartnerRelation.Insert(true);
                end;
            until TempNpRvPartnerRelation.Next() = 0;
    end;

    procedure CreateVouchers(var vouchers: XMLport "NPR NpRv Global Vouchers")
    var
        NpRvVoucherBuffer: Record "NPR NpRv Voucher Buffer" temporary;
    begin
        vouchers.Import();
        vouchers.GetSourceTable(NpRvVoucherBuffer);

        if NpRvVoucherBuffer.IsEmpty then
            exit;

        NpRvVoucherBuffer.FindSet();
        repeat
            CreateVoucher(NpRvVoucherBuffer);
        until NpRvVoucherBuffer.Next() = 0;
    end;

    local procedure CreateVoucher(var NpRvVoucherBuffer: Record "NPR NpRv Voucher Buffer" temporary)
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
        NpRvVoucherEntry: Record "NPR NpRv Voucher Entry";
    begin
        NpRvVoucherBuffer.TestField("Voucher Type");
        NpRvVoucherBuffer.TestField("Reference No.");
        if FindVoucher(NpRvVoucherBuffer."Voucher Type", NpRvVoucherBuffer."Reference No.", NpRvVoucher) then
            exit;

        NpRvVoucherType.Get(NpRvVoucherBuffer."Voucher Type");

        NpRvVoucher.Init();
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

        NpRvVoucherEntry.Init();
        NpRvVoucherEntry."Entry No." := 0;
        NpRvVoucherEntry."Voucher No." := NpRvVoucher."No.";
        NpRvVoucherEntry."Entry Type" := NpRvVoucherEntry."Entry Type"::"Issue Voucher";
        if NpRvVoucherType."Partner Code" <> NpRvVoucherBuffer."Issue Partner Code" then
            NpRvVoucherEntry."Entry Type" := NpRvVoucherEntry."Entry Type"::"Partner Issue Voucher";
        NpRvVoucherEntry."Voucher Type" := NpRvVoucher."Voucher Type";
        NpRvVoucherEntry.Amount := NpRvVoucherBuffer.Amount;
        NpRvVoucherEntry."Remaining Amount" := NpRvVoucherEntry.Amount;
        NpRvVoucherEntry.Positive := NpRvVoucherEntry.Amount > 0;
        NpRvVoucherEntry."Posting Date" := NpRvVoucherBuffer."Issue Date";
        NpRvVoucherEntry.Open := NpRvVoucherEntry.Amount <> 0;
        NpRvVoucherEntry."Register No." := NpRvVoucherBuffer."Issue Register No.";
        NpRvVoucherEntry."Document No." := NpRvVoucherBuffer."Issue Sales Ticket No.";
        NpRvVoucherEntry."User ID" := NpRvVoucherBuffer."Issue User ID";
        NpRvVoucherEntry."Partner Code" := NpRvVoucherBuffer."Issue Partner Code";
        NpRvVoucherEntry."Closed by Entry No." := 0;
        NpRvVoucherEntry.Insert();
    end;

    procedure ReserveVouchers(var vouchers: XMLport "NPR NpRv Global Vouchers")
    var
        NpRvVoucherBuffer: Record "NPR NpRv Voucher Buffer" temporary;
    begin
        SetGlobalLanguage(UserId);

        vouchers.Import();
        vouchers.GetSourceTable(NpRvVoucherBuffer);

        if NpRvVoucherBuffer.IsEmpty then
            exit;

        NpRvVoucherBuffer.FindSet();
        repeat
            ReserveVoucher(NpRvVoucherBuffer);
        until NpRvVoucherBuffer.Next() = 0;
    end;

    local procedure ReserveVoucher(var NpRvVoucherBuffer: Record "NPR NpRv Voucher Buffer" temporary)
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Timestamp: DateTime;
        InUseQty: Integer;
    begin
        if not FindVoucher(NpRvVoucherBuffer."Voucher Type", NpRvVoucherBuffer."Reference No.", NpRvVoucher) then
            Error(Text000, NpRvVoucherBuffer."Reference No.");

        Voucher2Buffer(NpRvVoucher, NpRvVoucherBuffer);
        NpRvVoucherBuffer.Modify();

        NpRvVoucher.CalcFields(Open);
        InUseQty := NpRvVoucher.CalcInUseQty();
        if not NpRvVoucher.Open then
            Error(Text003, NpRvVoucherBuffer."Reference No.");

        if InUseQty > 0 then begin
            NpRvSalesLine.SetRange("Register No.", NpRvVoucherBuffer."Redeem Register No.");
            NpRvSalesLine.SetRange("Sales Ticket No.", NpRvVoucherBuffer."Redeem Sales Ticket No.");
            NpRvSalesLine.SetRange("Sale Type", NpRvSalesLine."Sale Type"::Sale);
            NpRvSalesLine.SetRange("Sale Date", NpRvVoucherBuffer."Redeem Date");
            NpRvSalesLine.SetRange("Voucher Type", NpRvVoucher."Voucher Type");
            NpRvSalesLine.SetRange("Voucher No.", NpRvVoucher."No.");
            if InUseQty = NpRvSalesLine.Count() then
                exit;

            Error(Text001, NpRvVoucherBuffer."Reference No.");
        end;

        Timestamp := CurrentDateTime;
        if NpRvVoucher."Starting Date" > Timestamp then
            Error(Text004, NpRvVoucherBuffer."Reference No.");

        if (NpRvVoucher."Ending Date" < Timestamp) and (NpRvVoucher."Ending Date" <> 0DT) then
            Error(Text005, NpRvVoucherBuffer."Reference No.");


        NpRvSalesLine.Init();
        NpRvSalesLine.Id := CreateGuid();
        NpRvSalesLine."Register No." := NpRvVoucherBuffer."Redeem Register No.";
        NpRvSalesLine."Sales Ticket No." := NpRvVoucherBuffer."Redeem Sales Ticket No.";
        NpRvSalesLine."Sale Type" := NpRvSalesLine."Sale Type"::Sale;
        NpRvSalesLine."Sale Date" := NpRvVoucherBuffer."Redeem Date";
        NpRvSalesLine."Sale Line No." := 10000;
        NpRvSalesLine.Type := NpRvSalesLine.Type::Payment;
        NpRvSalesLine."Voucher Type" := NpRvVoucher."Voucher Type";
        NpRvSalesLine."Voucher No." := NpRvVoucher."No.";
        NpRvSalesLine.Description := NpRvVoucher.Description;
        NpRvSalesLine.Insert(true);
    end;

    procedure CancelReserveVouchers(var vouchers: XMLport "NPR NpRv Global Vouchers")
    var
        NpRvVoucherBuffer: Record "NPR NpRv Voucher Buffer" temporary;
    begin
        SetGlobalLanguage(UserId);

        vouchers.Import();
        vouchers.GetSourceTable(NpRvVoucherBuffer);

        if NpRvVoucherBuffer.IsEmpty then
            exit;

        NpRvVoucherBuffer.FindSet();
        repeat
            CancelReserveVoucher(NpRvVoucherBuffer);
        until NpRvVoucherBuffer.Next() = 0;
    end;

    local procedure CancelReserveVoucher(var NpRvVoucherBuffer: Record "NPR NpRv Voucher Buffer" temporary)
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        InUseQty: Integer;
    begin
        if not FindVoucher(NpRvVoucherBuffer."Voucher Type", NpRvVoucherBuffer."Reference No.", NpRvVoucher) then
            exit;

        Voucher2Buffer(NpRvVoucher, NpRvVoucherBuffer);
        NpRvVoucherBuffer.Modify();

        InUseQty := NpRvVoucher.CalcInUseQty();
        if InUseQty = 0 then
            exit;

        NpRvSalesLine.SetRange("Register No.", NpRvVoucherBuffer."Redeem Register No.");
        NpRvSalesLine.SetRange("Sales Ticket No.", NpRvVoucherBuffer."Redeem Sales Ticket No.");
        NpRvSalesLine.SetRange("Sale Type", NpRvSalesLine."Sale Type"::Sale);
        NpRvSalesLine.SetRange("Sale Date", NpRvVoucherBuffer."Redeem Date");
        NpRvSalesLine.SetRange("Voucher Type", NpRvVoucher."Voucher Type");
        NpRvSalesLine.SetRange("Voucher No.", NpRvVoucher."No.");
        if NpRvSalesLine.FindFirst() then
            NpRvSalesLine.DeleteAll();
    end;

    procedure RedeemVouchers(var vouchers: XMLport "NPR NpRv Global Vouchers")
    var
        NpRvVoucherBuffer: Record "NPR NpRv Voucher Buffer" temporary;
    begin
        SetGlobalLanguage(UserId);

        vouchers.Import();
        vouchers.GetSourceTable(NpRvVoucherBuffer);

        if NpRvVoucherBuffer.IsEmpty then
            exit;

        NpRvVoucherBuffer.FindSet();
        repeat
            RedeemVoucher(NpRvVoucherBuffer);
        until NpRvVoucherBuffer.Next() = 0;

        NpRvVoucherBuffer.FindSet();
        repeat
            InvokeRedeemPartnerVouchers(NpRvVoucherBuffer);
        until NpRvVoucherBuffer.Next() = 0;
    end;

    local procedure RedeemVoucher(var NpRvVoucherBuffer: Record "NPR NpRv Voucher Buffer" temporary)
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        NpRvVoucherEntry: Record "NPR NpRv Voucher Entry";
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        InUseQty: Integer;
    begin
        if not FindVoucher(NpRvVoucherBuffer."Voucher Type", NpRvVoucherBuffer."Reference No.", NpRvVoucher) then
            Error(Text000, NpRvVoucherBuffer."Reference No.");
        NpRvVoucher.CalcFields(Open, Amount);
        NpRvVoucher.TestField(Open);
        if NpRvVoucher.Amount < NpRvVoucherBuffer.Amount then
            Error(Text002, NpRvVoucher.Amount);

        NpRvVoucherType.Get(NpRvVoucher."Voucher Type");

        NpRvVoucherEntry.Init();
        NpRvVoucherEntry."Entry No." := 0;
        NpRvVoucherEntry."Voucher No." := NpRvVoucher."No.";
        NpRvVoucherEntry."Entry Type" := NpRvVoucherEntry."Entry Type"::Payment;
        if NpRvVoucherType."Partner Code" <> NpRvVoucherBuffer."Redeem Partner Code" then
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
        NpRvVoucherEntry.Insert();

        NpRvVoucherMgt.ApplyEntry(NpRvVoucherEntry);
        Voucher2Buffer(NpRvVoucher, NpRvVoucherBuffer);
        NpRvVoucherBuffer.Amount := -NpRvVoucherEntry.Amount;
        NpRvVoucherBuffer.Modify();

        NpRvVoucher.CalcFields(Open);
        if not NpRvVoucher.Open then
            NpRvVoucherMgt.ArchiveVouchers(NpRvVoucher);

        InUseQty := NpRvVoucher.CalcInUseQty();
        if InUseQty > 0 then begin
            NpRvSalesLine.SetRange("Register No.", NpRvVoucherBuffer."Redeem Register No.");
            NpRvSalesLine.SetRange("Sales Ticket No.", NpRvVoucherBuffer."Redeem Sales Ticket No.");
            NpRvSalesLine.SetRange("Sale Type", NpRvSalesLine."Sale Type"::Sale);
            NpRvSalesLine.SetRange("Sale Date", NpRvVoucherBuffer."Redeem Date");
            NpRvSalesLine.SetRange("Voucher Type", NpRvVoucher."Voucher Type");
            NpRvSalesLine.SetRange("Voucher No.", NpRvVoucher."No.");
            if InUseQty > NpRvSalesLine.Count() then
                Error(Text001, NpRvVoucherBuffer."Reference No.");

            NpRvSalesLine.DeleteAll();
        end;
    end;

    procedure InvokeRedeemPartnerVouchers(var NpRvVoucherBuffer: Record "NPR NpRv Voucher Buffer" temporary)
    var
        NpRvPartner: Record "NPR NpRv Partner";
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        Client: HttpClient;
        RequestContent: HttpContent;
        ContentHeader: HttpHeaders;
        Response: HttpResponseMessage;
        Document: XmlDocument;
        Node: XmlNode;
        RequestXmlText: Text;
        ErrorMessage: Text;
    begin
        if NpRvVoucherBuffer."Issue Partner Code" = NpRvVoucherBuffer."Redeem Partner Code" then
            exit;
        if not NpRvPartner.Get(NpRvVoucherBuffer."Issue Partner Code") then
            exit;
        if NpRvPartner."Service Url" = '' then
            exit;

        RequestXmlText :=
          '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">' +
            '<soapenv:Body>' +
              '<RedeemPartnerVouchers xmlns="urn:microsoft-dynamics-schemas/codeunit/' + GetServiceName(NpRvPartner) + '">' +
                '<vouchers>' +
                  '<voucher reference_no="' + NpRvVoucherBuffer."Reference No." + '"' +
                  ' voucher_type="' + NpRvVoucherBuffer."Voucher Type" + '" xmlns="urn:microsoft-dynamics-schemas/codeunit/global_voucher_service">' +
                    '<amount>' + Format(NpRvVoucherBuffer.Amount, 0, 9) + '</amount>' +
                    '<redeem_date>' + Format(NpRvVoucherBuffer."Redeem Date", 0, 9) + '</redeem_date>' +
                    '<redeem_register_no>' + NpRvVoucherBuffer."Redeem Register No." + '</redeem_register_no>' +
                    '<redeem_sales_ticket_no>' + NpRvVoucherBuffer."Redeem Sales Ticket No." + '</redeem_sales_ticket_no>' +
                    '<redeem_user_id>' + NpRvVoucherBuffer."Redeem User ID" + '</redeem_user_id>' +
                    '<redeem_partner_code>' + NpRvVoucherBuffer."Redeem Partner Code" + '</redeem_partner_code>' +
                  '</voucher>' +
                '</vouchers>' +
              '</RedeemPartnerVouchers>' +
            '</soapenv:Body>' +
          '</soapenv:Envelope>';

        RequestContent.WriteFrom(RequestXmlText);
        RequestContent.GetHeaders(ContentHeader);

        ContentHeader.Clear();
        ContentHeader.Remove('Content-Type');
        ContentHeader.Add('Content-Type', 'text/xml; charset=utf-8');
        ContentHeader.Add('SOAPAction', 'RedeemPartnerVouchers');
        ContentHeader.Remove('Connection');
        ContentHeader := Client.DefaultRequestHeaders();

        Client.UseWindowsAuthentication(NpRvPartner."Service Username", NpRvPartner."Service Password");
        Client.Post(NpRvPartner."Service Url", RequestContent, Response);

        if not Response.IsSuccessStatusCode then begin
            ErrorMessage := Response.ReasonPhrase;
            if XmlDocument.ReadFrom(ErrorMessage, Document) then begin
                if NpXmlDomMgt.FindNode(Document.AsXmlNode(), '//faultstring', Node) then
                    ErrorMessage := Node.AsXmlElement().InnerText();
            end;
            Error(CopyStr(ErrorMessage, 1, 1000));
        end;
    end;

    procedure RedeemPartnerVouchers(var vouchers: XMLport "NPR NpRv Global Vouchers")
    var
        NpRvVoucherBuffer: Record "NPR NpRv Voucher Buffer" temporary;
    begin
        SetGlobalLanguage(UserId);

        vouchers.Import();
        vouchers.GetSourceTable(NpRvVoucherBuffer);

        if NpRvVoucherBuffer.IsEmpty then
            exit;

        NpRvVoucherBuffer.FindSet();
        repeat
            RedeemPartnerVoucher(NpRvVoucherBuffer);
        until NpRvVoucherBuffer.Next() = 0;
    end;

    local procedure RedeemPartnerVoucher(var NpRvVoucherBuffer: Record "NPR NpRv Voucher Buffer" temporary)
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        NpRvVoucherEntry: Record "NPR NpRv Voucher Entry";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        InUseQty: Integer;
    begin
        if not FindVoucher(NpRvVoucherBuffer."Voucher Type", NpRvVoucherBuffer."Reference No.", NpRvVoucher) then
            exit;

        NpRvVoucher.CalcFields(Open, Amount);
        NpRvVoucher.TestField(Open);
        if NpRvVoucher.Amount < NpRvVoucherBuffer.Amount then
            Error(Text002, NpRvVoucher.Amount);

        NpRvVoucherEntry.Init();
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
        NpRvVoucherEntry.Insert();

        NpRvVoucherMgt.ApplyEntry(NpRvVoucherEntry);
        NpRvVoucher.CalcFields(Open);
        if not NpRvVoucher.Open then
            NpRvVoucherMgt.ArchiveVouchers(NpRvVoucher);

        InUseQty := NpRvVoucher.CalcInUseQty();
        if InUseQty > 0 then begin
            NpRvSalesLine.SetRange("Register No.", NpRvVoucherBuffer."Redeem Register No.");
            NpRvSalesLine.SetRange("Sales Ticket No.", NpRvVoucherBuffer."Redeem Sales Ticket No.");
            NpRvSalesLine.SetRange("Sale Type", NpRvSalesLine."Sale Type"::Sale);
            NpRvSalesLine.SetRange("Sale Date", NpRvVoucherBuffer."Redeem Date");
            NpRvSalesLine.SetRange("Voucher Type", NpRvVoucher."Voucher Type");
            NpRvSalesLine.SetRange("Voucher No.", NpRvVoucher."No.");
            NpRvSalesLine.DeleteAll();
        end;

        Voucher2Buffer(NpRvVoucher, NpRvVoucherBuffer);
        NpRvVoucherBuffer.Modify();
    end;

    procedure FindVoucher(VoucherTypeFilter: Text; ReferenceNo: Text[30]; var Voucher: Record "NPR NpRv Voucher"): Boolean
    begin
        Voucher.SetFilter("Voucher Type", UpperCase(VoucherTypeFilter));
        Voucher.SetRange("Reference No.", ReferenceNo);
        exit(Voucher.FindLast());
    end;

    local procedure GetServiceName(NpRvIssuer: Record "NPR NpRv Partner") ServiceName: Text
    var
        Position: Integer;
    begin
        ServiceName := NpRvIssuer."Service Url";
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

    local procedure Voucher2Buffer(var NpRvVoucher: Record "NPR NpRv Voucher"; var NpRvVoucherBuffer: Record "NPR NpRv Voucher Buffer")
    begin
        NpRvVoucher.CalcFields(Amount, "Issue Date", "Issue Register No.", "Issue Document No.", "Issue User ID", "Issue Partner Code");
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
        NpRvVoucherBuffer."Issue Partner Code" := NpRvVoucher."Issue Partner Code";
    end;

    local procedure SetGlobalLanguage(LanguageUsername: Text)
    var
        User: Record User;
        UserPersonalization: Record "User Personalization";
    begin
        User.SetRange("User Name", LanguageUsername);
        if not User.FindFirst() then
            exit;

        if not UserPersonalization.Get(User."User Security ID") then
            exit;

        if UserPersonalization."Language ID" > 0 then
            GlobalLanguage(UserPersonalization."Language ID");
    end;
}

