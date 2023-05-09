﻿codeunit 6151020 "NPR NpRv Global Voucher WS"
{
    var
        [NonDebuggable]
        _ServicePassword: Text;
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
        retail_voucher_partners.GetSourceTables(TempNpRvPartner, TempNpRvPartnerRelation, _ServicePassword);

        if not TempNpRvPartner.FindSet() then
            exit;

        repeat
            UpsertPartner(TempNpRvPartner, TempNpRvPartnerRelation, _ServicePassword);
        until TempNpRvPartner.Next() = 0;
    end;

    [NonDebuggable]
    local procedure UpsertPartner(var TempNpRvPartner: Record "NPR NpRv Partner" temporary; var TempNpRvPartnerRelation: Record "NPR NpRv Partner Relation" temporary; ServicePassword: Text)
    var
        NpRvPartner: Record "NPR NpRv Partner";
        NpRvPartnerRelation: Record "NPR NpRv Partner Relation";
        WebServiceAuthHelper: Codeunit "NPR Web Service Auth. Helper";
        PrevRec: Text;
    begin
        if not NpRvPartner.Get(TempNpRvPartner.Code) then begin
            NpRvPartner.Init();
            NpRvPartner := TempNpRvPartner;
            NpRvPartner.Insert(true);
            WebServiceAuthHelper.SetApiPassword(ServicePassword, NpRvPartner."API Password Key");
            NpRvPartner.Modify();
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
        TempNpRvVoucherBuffer: Record "NPR NpRv Voucher Buffer" temporary;
    begin
        vouchers.Import();
        vouchers.GetSourceTable(TempNpRvVoucherBuffer);

        if TempNpRvVoucherBuffer.IsEmpty then
            exit;

        TempNpRvVoucherBuffer.FindSet();
        repeat
            CreateVoucher(TempNpRvVoucherBuffer);
        until TempNpRvVoucherBuffer.Next() = 0;
    end;

    local procedure CreateVoucher(var TempNpRvVoucherBuffer: Record "NPR NpRv Voucher Buffer" temporary)
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
        NpRvVoucherEntry: Record "NPR NpRv Voucher Entry";
        NpRvModuleValidGlobal: Codeunit "NPR NpRv Module Valid.: Global";
    begin
        TempNpRvVoucherBuffer.TestField("Voucher Type");
        TempNpRvVoucherBuffer.TestField("Reference No.");
        if FindVoucher(TempNpRvVoucherBuffer."Voucher Type", TempNpRvVoucherBuffer."Reference No.", NpRvVoucher) then
            exit;

        NpRvVoucherType.Get(TempNpRvVoucherBuffer."Voucher Type");

        NpRvVoucher.Init();
        NpRvVoucher."No." := '';
        NpRvVoucher."Reference No." := TempNpRvVoucherBuffer."Reference No.";
        NpRvVoucher."Voucher Type" := TempNpRvVoucherBuffer."Voucher Type";
        NpRvVoucher.Description := TempNpRvVoucherBuffer.Description;
        NpRvVoucher."Starting Date" := TempNpRvVoucherBuffer."Starting Date";
        NpRvVoucher."Ending Date" := TempNpRvVoucherBuffer."Ending Date";
        NpRvVoucher."Account No." := TempNpRvVoucherBuffer."Account No.";
        NpRvVoucher.Name := TempNpRvVoucherBuffer.Name;
        NpRvVoucher."Name 2" := TempNpRvVoucherBuffer."Name 2";
        NpRvVoucher.Address := TempNpRvVoucherBuffer.Address;
        NpRvVoucher."Address 2" := TempNpRvVoucherBuffer."Address 2";
        NpRvVoucher."Post Code" := TempNpRvVoucherBuffer."Post Code";
        NpRvVoucher.City := TempNpRvVoucherBuffer.City;
        NpRvVoucher.County := TempNpRvVoucherBuffer.County;
        NpRvVoucher."Country/Region Code" := TempNpRvVoucherBuffer."Country/Region Code";
        NpRvVoucher."E-mail" := TempNpRvVoucherBuffer."E-mail";
        NpRvVoucher."Phone No." := TempNpRvVoucherBuffer."Phone No.";
        NpRvVoucher."Voucher Message" := TempNpRvVoucherBuffer."Voucher Message";
        NpRvVoucher."Allow Top-up" := NpRvVoucherType."Allow Top-up";
        NpRvVoucher.Insert(true);

        NpRvVoucherEntry.Init();
        NpRvVoucherEntry."Entry No." := 0;
        NpRvVoucherEntry."Voucher No." := NpRvVoucher."No.";
        NpRvVoucherEntry."Entry Type" := NpRvVoucherEntry."Entry Type"::"Issue Voucher";
        if NpRvVoucherType."Partner Code" <> TempNpRvVoucherBuffer."Issue Partner Code" then
            NpRvVoucherEntry."Entry Type" := NpRvVoucherEntry."Entry Type"::"Partner Issue Voucher";
        NpRvVoucherEntry."Voucher Type" := NpRvVoucher."Voucher Type";
        NpRvVoucherEntry.Amount := TempNpRvVoucherBuffer.Amount;
        NpRvVoucherEntry."Remaining Amount" := NpRvVoucherEntry.Amount;
        NpRvVoucherEntry.Positive := NpRvVoucherEntry.Amount > 0;
        NpRvVoucherEntry."Posting Date" := TempNpRvVoucherBuffer."Issue Date";
        NpRvVoucherEntry.Open := NpRvVoucherEntry.Amount <> 0;
        NpRvVoucherEntry."Register No." := TempNpRvVoucherBuffer."Issue Register No.";
        NpRvVoucherEntry."Document No." := TempNpRvVoucherBuffer."Issue Sales Ticket No.";
        NpRvVoucherEntry."User ID" := TempNpRvVoucherBuffer."Issue User ID";
        NpRvVoucherEntry."Partner Code" := TempNpRvVoucherBuffer."Issue Partner Code";
        NpRvVoucherEntry."POS Store Code" := TempNpRvVoucherBuffer."POS Store Code";
        NpRvVoucherEntry."Closed by Entry No." := 0;
        NpRvVoucherEntry.Insert();

        if NpRvVoucherEntry."Entry Type" = NpRvVoucherEntry."Entry Type"::"Issue Voucher" then
            NpRvModuleValidGlobal.CreateGlobalVoucher(NpRvVoucher);
    end;

    procedure FindVouchers(var vouchers: XMLport "NPR NpRv Global Vouchers")
    var
        TempNpRvVoucherBuffer: Record "NPR NpRv Voucher Buffer" temporary;
    begin
        SetGlobalLanguage(UserId);

        vouchers.Import();
        vouchers.GetSourceTable(TempNpRvVoucherBuffer);

        if TempNpRvVoucherBuffer.IsEmpty then
            exit;

        TempNpRvVoucherBuffer.FindSet();
        repeat
            FindVoucher(TempNpRvVoucherBuffer);
        until TempNpRvVoucherBuffer.Next() = 0;
    end;

    local procedure FindVoucher(var TempNpRvVoucherBuffer: Record "NPR NpRv Voucher Buffer" temporary)
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
    begin
        if not FindVoucher(TempNpRvVoucherBuffer."Voucher Type", TempNpRvVoucherBuffer."Reference No.", NpRvVoucher) then
            Error(Text000, TempNpRvVoucherBuffer."Reference No.");

        Voucher2Buffer(NpRvVoucher, TempNpRvVoucherBuffer);
        TempNpRvVoucherBuffer.Modify();

        if NpRvVoucher."Starting Date" > CurrentDateTime() then
            Error(Text004, TempNpRvVoucherBuffer."Reference No.");

        if (NpRvVoucher."Ending Date" < CurrentDateTime()) and (NpRvVoucher."Ending Date" <> 0DT) then
            Error(Text005, TempNpRvVoucherBuffer."Reference No.");
    end;

    procedure ReserveVouchers(var vouchers: XMLport "NPR NpRv Global Vouchers")
    var
        TempNpRvVoucherBuffer: Record "NPR NpRv Voucher Buffer" temporary;
    begin
        SetGlobalLanguage(UserId);

        vouchers.Import();
        vouchers.GetSourceTable(TempNpRvVoucherBuffer);

        if TempNpRvVoucherBuffer.IsEmpty then
            exit;

        TempNpRvVoucherBuffer.FindSet();
        repeat
            ReserveVoucher(TempNpRvVoucherBuffer);
        until TempNpRvVoucherBuffer.Next() = 0;
    end;

    local procedure ReserveVoucher(var TempNpRvVoucherBuffer: Record "NPR NpRv Voucher Buffer" temporary)
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Timestamp: DateTime;
        InUseQty: Integer;
    begin
        if not FindVoucher(TempNpRvVoucherBuffer."Voucher Type", TempNpRvVoucherBuffer."Reference No.", NpRvVoucher) then
            Error(Text000, TempNpRvVoucherBuffer."Reference No.");

        Voucher2Buffer(NpRvVoucher, TempNpRvVoucherBuffer);
        TempNpRvVoucherBuffer.Modify();

        NpRvVoucher.CalcFields(Open);
        if not NpRvVoucher.Open then
            Error(Text003, TempNpRvVoucherBuffer."Reference No.");
        InUseQty := NpRvVoucher.CalcInUseQty();

        if InUseQty > 0 then begin
            NpRvSalesLine.SetRange("Register No.", TempNpRvVoucherBuffer."Redeem Register No.");
            NpRvSalesLine.SetRange("Sales Ticket No.", TempNpRvVoucherBuffer."Redeem Sales Ticket No.");
            NpRvSalesLine.SetRange("Sale Date", TempNpRvVoucherBuffer."Redeem Date");
            NpRvSalesLine.SetRange("Voucher Type", NpRvVoucher."Voucher Type");
            NpRvSalesLine.SetRange("Voucher No.", NpRvVoucher."No.");
            if InUseQty = NpRvSalesLine.Count() then
                exit;

            Error(Text001, TempNpRvVoucherBuffer."Reference No.");
        end;

        Timestamp := CurrentDateTime;
        if NpRvVoucher."Starting Date" > Timestamp then
            Error(Text004, TempNpRvVoucherBuffer."Reference No.");

        if (NpRvVoucher."Ending Date" < Timestamp) and (NpRvVoucher."Ending Date" <> 0DT) then
            Error(Text005, TempNpRvVoucherBuffer."Reference No.");


        NpRvSalesLine.Init();
        NpRvSalesLine.Id := CreateGuid();
        NpRvSalesLine."Register No." := TempNpRvVoucherBuffer."Redeem Register No.";
        NpRvSalesLine."Sales Ticket No." := TempNpRvVoucherBuffer."Redeem Sales Ticket No.";
        NpRvSalesLine."Sale Date" := TempNpRvVoucherBuffer."Redeem Date";
        NpRvSalesLine."Sale Line No." := 10000;
        NpRvSalesLine.Type := NpRvSalesLine.Type::Payment;
        NpRvSalesLine."Voucher Type" := NpRvVoucher."Voucher Type";
        NpRvSalesLine."Voucher No." := NpRvVoucher."No.";
        NpRvSalesLine.Description := NpRvVoucher.Description;
        NpRvSalesLine.Insert(true);
    end;

    procedure CancelReserveVouchers(var vouchers: XMLport "NPR NpRv Global Vouchers")
    var
        TempNpRvVoucherBuffer: Record "NPR NpRv Voucher Buffer" temporary;
    begin
        SetGlobalLanguage(UserId);

        vouchers.Import();
        vouchers.GetSourceTable(TempNpRvVoucherBuffer);

        if TempNpRvVoucherBuffer.IsEmpty then
            exit;

        TempNpRvVoucherBuffer.FindSet();
        repeat
            CancelReserveVoucher(TempNpRvVoucherBuffer);
        until TempNpRvVoucherBuffer.Next() = 0;
    end;

    local procedure CancelReserveVoucher(var TempNpRvVoucherBuffer: Record "NPR NpRv Voucher Buffer" temporary)
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        InUseQty: Integer;
    begin
        if not FindVoucher(TempNpRvVoucherBuffer."Voucher Type", TempNpRvVoucherBuffer."Reference No.", NpRvVoucher) then
            exit;

        Voucher2Buffer(NpRvVoucher, TempNpRvVoucherBuffer);
        TempNpRvVoucherBuffer.Modify();

        InUseQty := NpRvVoucher.CalcInUseQty();
        if InUseQty = 0 then
            exit;

        NpRvSalesLine.SetRange("Register No.", TempNpRvVoucherBuffer."Redeem Register No.");
        NpRvSalesLine.SetRange("Sales Ticket No.", TempNpRvVoucherBuffer."Redeem Sales Ticket No.");
        NpRvSalesLine.SetRange("Sale Date", TempNpRvVoucherBuffer."Redeem Date");
        NpRvSalesLine.SetRange("Voucher Type", NpRvVoucher."Voucher Type");
        NpRvSalesLine.SetRange("Voucher No.", NpRvVoucher."No.");
        if not NpRvSalesLine.IsEmpty() then
            NpRvSalesLine.DeleteAll();
    end;

    procedure RedeemVouchers(var vouchers: XMLport "NPR NpRv Global Vouchers")
    var
        TempNpRvVoucherBuffer: Record "NPR NpRv Voucher Buffer" temporary;
    begin
        SetGlobalLanguage(UserId);

        vouchers.Import();
        vouchers.GetSourceTable(TempNpRvVoucherBuffer);

        if TempNpRvVoucherBuffer.IsEmpty then
            exit;

        TempNpRvVoucherBuffer.FindSet();
        repeat
            RedeemVoucher(TempNpRvVoucherBuffer);
        until TempNpRvVoucherBuffer.Next() = 0;

        Commit();

        TempNpRvVoucherBuffer.FindSet();
        repeat
            InvokeRedeemPartnerVouchers(TempNpRvVoucherBuffer);
            SelectLatestVersion();
        until TempNpRvVoucherBuffer.Next() = 0;
    end;

    local procedure RedeemVoucher(var NpRvVoucherBuffer: Record "NPR NpRv Voucher Buffer" temporary)
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        NpRvVoucherEntry: Record "NPR NpRv Voucher Entry";
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        NpRvModuleValidGlobal: Codeunit "NPR NpRv Module Valid.: Global";
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
        NpRvVoucherEntry."POS Store Code" := NpRvVoucherBuffer."POS Store Code";
        NpRvVoucherEntry."Closed by Entry No." := 0;
        NpRvVoucherEntry.Insert();

        if NpRvVoucherEntry."Entry Type" = NpRvVoucherEntry."Entry Type"::Payment then
            NpRvModuleValidGlobal.RedeemVoucher(NpRvVoucherEntry, NpRvVoucher);
        NpRvModuleValidGlobal.RedeemPartnerVouchers(NpRvVoucherEntry, NpRvVoucher);

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
            NpRvSalesLine.SetRange("Sale Date", NpRvVoucherBuffer."Redeem Date");
            NpRvSalesLine.SetRange("Voucher Type", NpRvVoucher."Voucher Type");
            NpRvSalesLine.SetRange("Voucher No.", NpRvVoucher."No.");
            if InUseQty > NpRvSalesLine.Count() then
                Error(Text001, NpRvVoucherBuffer."Reference No.");

            NpRvSalesLine.DeleteAll();
        end;
    end;


    procedure TopUpVouchers(var vouchers: XMLport "NPR NpRv Global Vouchers")
    var
        TempNpRvVoucherBuffer: Record "NPR NpRv Voucher Buffer" temporary;
    begin
        SetGlobalLanguage(UserId);

        vouchers.Import();
        vouchers.GetSourceTable(TempNpRvVoucherBuffer);

        if TempNpRvVoucherBuffer.IsEmpty then
            exit;

        TempNpRvVoucherBuffer.FindSet();
        repeat
            TopUpVoucher(TempNpRvVoucherBuffer);
        until TempNpRvVoucherBuffer.Next() = 0;

        Commit();
    end;

    local procedure TopUpVoucher(var NpRvVoucherBuffer: Record "NPR NpRv Voucher Buffer" temporary)
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

        NpRvVoucherType.Get(NpRvVoucher."Voucher Type");

        NpRvVoucherEntry.Init();
        NpRvVoucherEntry."Entry No." := 0;
        NpRvVoucherEntry."Voucher No." := NpRvVoucher."No.";
        NpRvVoucherEntry."Entry Type" := NpRvVoucherEntry."Entry Type"::"Partner Top-up";
        NpRvVoucherEntry."Voucher Type" := NpRvVoucher."Voucher Type";
        NpRvVoucherEntry.Amount := NpRvVoucherBuffer.Amount;
        NpRvVoucherEntry."Remaining Amount" := NpRvVoucherEntry.Amount;
        NpRvVoucherEntry.Positive := NpRvVoucherEntry.Amount > 0;
        NpRvVoucherEntry."Posting Date" := NpRvVoucherBuffer."Redeem Date";
        NpRvVoucherEntry.Open := NpRvVoucherEntry.Amount <> 0;
        NpRvVoucherEntry."Register No." := NpRvVoucherBuffer."Redeem Register No.";
        NpRvVoucherEntry."Document No." := NpRvVoucherBuffer."Redeem Sales Ticket No.";
        NpRvVoucherEntry."User ID" := NpRvVoucherBuffer."Redeem User ID";
        NpRvVoucherEntry."Partner Code" := NpRvVoucherBuffer."Redeem Partner Code";
        NpRvVoucherEntry."POS Store Code" := NpRvVoucherBuffer."POS Store Code";
        NpRvVoucherEntry."Closed by Entry No." := 0;
        NpRvVoucherEntry.Insert();

        NpRvVoucherMgt.ApplyEntry(NpRvVoucherEntry);
        Voucher2Buffer(NpRvVoucher, NpRvVoucherBuffer);
        NpRvVoucherBuffer.Amount := NpRvVoucherEntry.Amount;
        NpRvVoucherBuffer.Modify();

        NpRvVoucher.CalcFields(Open);
        if not NpRvVoucher.Open then
            NpRvVoucherMgt.ArchiveVouchers(NpRvVoucher);

        InUseQty := NpRvVoucher.CalcInUseQty();
        if InUseQty > 0 then begin
            NpRvSalesLine.SetRange("Register No.", NpRvVoucherBuffer."Redeem Register No.");
            NpRvSalesLine.SetRange("Sales Ticket No.", NpRvVoucherBuffer."Redeem Sales Ticket No.");
            NpRvSalesLine.SetRange("Sale Date", NpRvVoucherBuffer."Redeem Date");
            NpRvSalesLine.SetRange("Voucher Type", NpRvVoucher."Voucher Type");
            NpRvSalesLine.SetRange("Voucher No.", NpRvVoucher."No.");
            if InUseQty > NpRvSalesLine.Count() then
                Error(Text001, NpRvVoucherBuffer."Reference No.");

            NpRvSalesLine.DeleteAll();
        end;
    end;

    internal procedure InvokeRedeemPartnerVouchers(var NpRvVoucherBuffer: Record "NPR NpRv Voucher Buffer" temporary)
    var
        NpRvModuleValidGlobal: Codeunit "NPR NpRv Module Valid.: Global";
        NpRvPartner: Record "NPR NpRv Partner";
        Client: HttpClient;
        RequestMessage: HttpRequestMessage;
        [NonDebuggable]
        RequestHeaders: HttpHeaders;
        ContentHeader: HttpHeaders;
        ResponseMessage: HttpResponseMessage;
        RequestXmlText: Text;
        ResponseText: Text;
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

        RequestMessage.GetHeaders(RequestHeaders);
        RequestHeaders.Remove('Connection');

        NpRvPartner.SetRequestHeadersAuthorization(RequestHeaders);

        RequestMessage.Content.WriteFrom(RequestXmlText);
        RequestMessage.Content.GetHeaders(ContentHeader);
        ContentHeader.Clear();
        ContentHeader.Remove('Content-Type');
        ContentHeader.Add('Content-Type', 'text/xml; charset=utf-8');
        ContentHeader.Add('SOAPAction', 'RedeemPartnerVouchers');

        RequestMessage.Method := 'POST';
        RequestMessage.SetRequestUri(NpRvPartner."Service Url");

        Client.Send(RequestMessage, ResponseMessage);
        if not ResponseMessage.IsSuccessStatusCode then begin
            ResponseMessage.Content.ReadAs(ResponseText);
            NpRvModuleValidGlobal.ThrowGlobalVoucherWSError(ResponseMessage.ReasonPhrase, ResponseText);
        end;
    end;

    procedure RedeemPartnerVouchers(var vouchers: XMLport "NPR NpRv Global Vouchers")
    var
        TempNpRvVoucherBuffer: Record "NPR NpRv Voucher Buffer" temporary;
    begin
        SetGlobalLanguage(UserId);

        vouchers.Import();
        vouchers.GetSourceTable(TempNpRvVoucherBuffer);

        if TempNpRvVoucherBuffer.IsEmpty then
            exit;

        TempNpRvVoucherBuffer.FindSet();
        repeat
            RedeemPartnerVoucher(TempNpRvVoucherBuffer);
        until TempNpRvVoucherBuffer.Next() = 0;
    end;

    local procedure RedeemPartnerVoucher(var TempNpRvVoucherBuffer: Record "NPR NpRv Voucher Buffer" temporary)
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        NpRvVoucherEntry: Record "NPR NpRv Voucher Entry";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        NpRvModuleValidGlobal: Codeunit "NPR NpRv Module Valid.: Global";
        InUseQty: Integer;
    begin
        if not FindVoucher(TempNpRvVoucherBuffer."Voucher Type", TempNpRvVoucherBuffer."Reference No.", NpRvVoucher) then
            exit;

        NpRvVoucher.CalcFields(Open, Amount);
        NpRvVoucher.TestField(Open);
        if NpRvVoucher.Amount < TempNpRvVoucherBuffer.Amount then
            Error(Text002, NpRvVoucher.Amount);

        NpRvVoucherEntry.Init();
        NpRvVoucherEntry."Entry No." := 0;
        NpRvVoucherEntry."Voucher No." := NpRvVoucher."No.";
        NpRvVoucherEntry."Entry Type" := NpRvVoucherEntry."Entry Type"::"Partner Payment";
        NpRvVoucherEntry."Voucher Type" := NpRvVoucher."Voucher Type";
        NpRvVoucherEntry.Amount := -TempNpRvVoucherBuffer.Amount;
        NpRvVoucherEntry."Remaining Amount" := NpRvVoucherEntry.Amount;
        NpRvVoucherEntry.Positive := NpRvVoucherEntry.Amount > 0;
        NpRvVoucherEntry."Posting Date" := TempNpRvVoucherBuffer."Redeem Date";
        NpRvVoucherEntry.Open := NpRvVoucherEntry.Amount <> 0;
        NpRvVoucherEntry."Register No." := TempNpRvVoucherBuffer."Redeem Register No.";
        NpRvVoucherEntry."Document No." := TempNpRvVoucherBuffer."Redeem Sales Ticket No.";
        NpRvVoucherEntry."User ID" := TempNpRvVoucherBuffer."Redeem User ID";
        NpRvVoucherEntry."Partner Code" := TempNpRvVoucherBuffer."Redeem Partner Code";
        NpRvVoucherEntry."POS Store Code" := TempNpRvVoucherBuffer."POS Store Code";
        NpRvVoucherEntry."Closed by Entry No." := 0;
        NpRvVoucherEntry.Insert();

        NpRvModuleValidGlobal.RedeemPartnerVouchers(NpRvVoucherEntry, NpRvVoucher);

        NpRvVoucherMgt.ApplyEntry(NpRvVoucherEntry);

        NpRvVoucher.CalcFields(Open);
        if not NpRvVoucher.Open then
            NpRvVoucherMgt.ArchiveVouchers(NpRvVoucher);
        InUseQty := NpRvVoucher.CalcInUseQty();
        if InUseQty > 0 then begin
            NpRvSalesLine.SetRange("Register No.", TempNpRvVoucherBuffer."Redeem Register No.");
            NpRvSalesLine.SetRange("Sales Ticket No.", TempNpRvVoucherBuffer."Redeem Sales Ticket No.");
            NpRvSalesLine.SetRange("Sale Date", TempNpRvVoucherBuffer."Redeem Date");
            NpRvSalesLine.SetRange("Voucher Type", NpRvVoucher."Voucher Type");
            NpRvSalesLine.SetRange("Voucher No.", NpRvVoucher."No.");
            NpRvSalesLine.DeleteAll();
        end;

        Voucher2Buffer(NpRvVoucher, TempNpRvVoucherBuffer);
        TempNpRvVoucherBuffer.Modify();
    end;

    procedure FindVoucher(VoucherTypeFilter: Text; ReferenceNo: Text[50]; var Voucher: Record "NPR NpRv Voucher"): Boolean
    begin
        if VoucherTypeFilter <> '' then
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

    local procedure Voucher2Buffer(var NpRvVoucher: Record "NPR NpRv Voucher"; var TempNpRvVoucherBuffer: Record "NPR NpRv Voucher Buffer" temporary)
    var
        NPRPOSUnit: Record "NPR POS Unit";
    begin
        NpRvVoucher.CalcFields(Amount, "Issue Date", "Issue Register No.", "Issue Document No.", "Issue User ID", "Issue Partner Code");
        TempNpRvVoucherBuffer."Voucher Type" := NpRvVoucher."Voucher Type";
        TempNpRvVoucherBuffer.Description := NpRvVoucher.Description;
        TempNpRvVoucherBuffer."Starting Date" := NpRvVoucher."Starting Date";
        TempNpRvVoucherBuffer."Ending Date" := NpRvVoucher."Ending Date";
        TempNpRvVoucherBuffer."Account No." := NpRvVoucher."Account No.";
        TempNpRvVoucherBuffer.Amount := NpRvVoucher.Amount;
        TempNpRvVoucherBuffer.Name := NpRvVoucher.Name;
        TempNpRvVoucherBuffer."Name 2" := NpRvVoucher."Name 2";
        TempNpRvVoucherBuffer.Address := NpRvVoucher.Address;
        TempNpRvVoucherBuffer."Address 2" := NpRvVoucher."Address 2";
        TempNpRvVoucherBuffer."Post Code" := NpRvVoucher."Post Code";
        TempNpRvVoucherBuffer.City := NpRvVoucher.City;
        TempNpRvVoucherBuffer.County := NpRvVoucher.County;
        TempNpRvVoucherBuffer."Country/Region Code" := NpRvVoucher."Country/Region Code";
        TempNpRvVoucherBuffer."E-mail" := NpRvVoucher."E-mail";
        TempNpRvVoucherBuffer."Phone No." := NpRvVoucher."Phone No.";
        TempNpRvVoucherBuffer."Voucher Message" := NpRvVoucher."Voucher Message";
        TempNpRvVoucherBuffer."Issue Date" := NpRvVoucher."Issue Date";
        TempNpRvVoucherBuffer."Issue Register No." := NpRvVoucher."Issue Register No.";
        TempNpRvVoucherBuffer."Issue Sales Ticket No." := NpRvVoucher."Issue Document No.";
        TempNpRvVoucherBuffer."Issue User ID" := NpRvVoucher."Issue User ID";
        TempNpRvVoucherBuffer."Issue Partner Code" := NpRvVoucher."Issue Partner Code";
        if NPRPOSUnit.Get(NpRvVoucher."Issue Register No.") then
            TempNpRvVoucherBuffer."POS Store Code" := NPRPOSUnit."POS Store Code";
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

