codeunit 6151021 "NpRv Ext. Voucher Webservice"
{
    // NPR5.48/MHA /20180920  CASE 302179 Object created
    // NPR5.48/MHA /20190123  CASE 341711 Added "Send via E-mail" and "Send via SMS"
    // NPR5.52/MHA /20191015  CASE 372315 Added functions GetVouchersByCustomerNo(), GetVouchersByEmail()


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
        Text006: Label 'Voucher %1 is reserved on different document_no';
        Text007: Label 'Voucher %1 is being used on Sales Order %2';

    local procedure "--- Check Voucher"()
    begin
    end;

    [Scope('Personalization')]
    procedure CheckVouchers(var vouchers: XMLport "NpRv Ext. Vouchers")
    var
        NpRvExtVoucherBuffer: Record "NpRv Ext. Voucher Buffer" temporary;
    begin
        SetGlobalLanguage(UserId);

        vouchers.Import;
        vouchers.GetSourceTable(NpRvExtVoucherBuffer);
        if NpRvExtVoucherBuffer.IsEmpty then
          exit;

        NpRvExtVoucherBuffer.FindSet;
        repeat
          CheckVoucher(NpRvExtVoucherBuffer);
        until NpRvExtVoucherBuffer.Next = 0;
    end;

    local procedure CheckVoucher(var NpRvExtVoucherBuffer: Record "NpRv Ext. Voucher Buffer" temporary)
    var
        NpRvVoucher: Record "NpRv Voucher";
    begin
        if not FindVoucher(NpRvExtVoucherBuffer."Voucher Type",NpRvExtVoucherBuffer."Reference No.",NpRvVoucher) then
          Error(Text000,NpRvExtVoucherBuffer."Reference No.");

        Voucher2Buffer(NpRvVoucher,NpRvExtVoucherBuffer);
    end;

    procedure GetVouchersByCustomerNo(CustomerNo: Text;var vouchers: XMLport "NpRv Ext. Vouchers")
    var
        NpRvVoucher: Record "NpRv Voucher";
        NpRvExtVoucherBuffer: Record "NpRv Ext. Voucher Buffer" temporary;
        DocNo: Text;
        LineNo: Integer;
    begin
        //-NPR5.52 [372315]
        Clear(vouchers);
        if StrLen(CustomerNo) > MaxStrLen(NpRvVoucher."Customer No.") then
          exit;

        DocNo := Format(CreateGuid);
        NpRvVoucher.SetRange("Customer No.",UpperCase(CustomerNo));
        if NpRvVoucher.FindSet then
          repeat
            LineNo += 10000;

            NpRvExtVoucherBuffer.Init;
            NpRvExtVoucherBuffer."Document No." := DocNo;
            NpRvExtVoucherBuffer."Line No." := LineNo;
            NpRvExtVoucherBuffer.Insert;
            Voucher2Buffer(NpRvVoucher,NpRvExtVoucherBuffer);
          until NpRvVoucher.Next = 0;

        vouchers.SetSourceTable(NpRvExtVoucherBuffer);
        //+NPR5.52 [372315]
    end;

    procedure GetVouchersByEmail(Email: Text;var vouchers: XMLport "NpRv Ext. Vouchers")
    var
        NpRvVoucher: Record "NpRv Voucher";
        NpRvExtVoucherBuffer: Record "NpRv Ext. Voucher Buffer" temporary;
        DocNo: Text;
        LineNo: Integer;
    begin
        //-NPR5.52 [372315]
        Clear(vouchers);
        if StrLen(Email) > MaxStrLen(NpRvVoucher."E-mail") then
          exit;

        DocNo := Format(CreateGuid);
        NpRvVoucher.SetFilter("E-mail",'@' + ConvertStr(Email,'@','?'));
        if NpRvVoucher.FindSet then
          repeat
            LineNo += 10000;

            NpRvExtVoucherBuffer.Init;
            NpRvExtVoucherBuffer."Document No." := DocNo;
            NpRvExtVoucherBuffer."Line No." := LineNo;
            NpRvExtVoucherBuffer.Insert;
            Voucher2Buffer(NpRvVoucher,NpRvExtVoucherBuffer);
          until NpRvVoucher.Next = 0;

        vouchers.SetSourceTable(NpRvExtVoucherBuffer);
        //+NPR5.52 [372315]
    end;

    local procedure "--- Create Voucher"()
    begin
    end;

    [Scope('Personalization')]
    procedure CreateVouchers(var vouchers: XMLport "NpRv Ext. Vouchers")
    var
        NpRvExtVoucherBuffer: Record "NpRv Ext. Voucher Buffer" temporary;
    begin
        vouchers.Import;
        vouchers.GetSourceTable(NpRvExtVoucherBuffer);

        if NpRvExtVoucherBuffer.IsEmpty then
          exit;

        NpRvExtVoucherBuffer.FindSet;
        repeat
          CreateVoucher(NpRvExtVoucherBuffer);
        until NpRvExtVoucherBuffer.Next = 0;
    end;

    local procedure CreateVoucher(var NpRvExtVoucherBuffer: Record "NpRv Ext. Voucher Buffer" temporary)
    var
        NpRvVoucher: Record "NpRv Voucher";
        NpRvVoucherEntry: Record "NpRv Voucher Entry";
        NpRvVoucherType: Record "NpRv Voucher Type";
        Amount: Decimal;
    begin
        NpRvExtVoucherBuffer.TestField("Voucher Type");
        if NpRvExtVoucherBuffer."Reference No." <> '' then begin
          if FindVoucher(NpRvExtVoucherBuffer."Voucher Type",NpRvExtVoucherBuffer."Reference No.",NpRvVoucher) then begin
            Voucher2Buffer(NpRvVoucher,NpRvExtVoucherBuffer);
            exit;
          end;
        end;

        NpRvVoucher.Init;
        NpRvVoucher."No." := '';
        NpRvVoucher."Reference No." := NpRvExtVoucherBuffer."Reference No.";
        Buffer2Voucher(NpRvExtVoucherBuffer,NpRvVoucher);
        NpRvVoucher.Insert(true);

        Voucher2Buffer(NpRvVoucher,NpRvExtVoucherBuffer);
    end;

    local procedure "--- Reserve Voucher"()
    begin
    end;

    [Scope('Personalization')]
    procedure ReserveVouchers(var vouchers: XMLport "NpRv Ext. Vouchers")
    var
        NpRvExtVoucherBuffer: Record "NpRv Ext. Voucher Buffer" temporary;
    begin
        SetGlobalLanguage(UserId);

        vouchers.Import;
        vouchers.GetSourceTable(NpRvExtVoucherBuffer);

        if NpRvExtVoucherBuffer.IsEmpty then
          exit;

        NpRvExtVoucherBuffer.FindSet;
        repeat
          ReserveVoucher(NpRvExtVoucherBuffer);
        until NpRvExtVoucherBuffer.Next = 0;
    end;

    local procedure ReserveVoucher(var NpRvExtVoucherBuffer: Record "NpRv Ext. Voucher Buffer" temporary)
    var
        NpRvVoucher: Record "NpRv Voucher";
        NpRvExtVoucherSalesLine: Record "NpRv Ext. Voucher Sales Line";
        LineNo: Integer;
        Timestamp: DateTime;
        InUseQty: Integer;
    begin
        if not FindVoucher(NpRvExtVoucherBuffer."Voucher Type",NpRvExtVoucherBuffer."Reference No.",NpRvVoucher) then
          Error(Text000,NpRvExtVoucherBuffer."Reference No.");

        NpRvVoucher.CalcFields(Open);
        if not NpRvVoucher.Open then
          Error(Text003,NpRvExtVoucherBuffer."Reference No.");

        InUseQty := NpRvVoucher.CalcInUseQty();
        if InUseQty > 0 then begin
          NpRvExtVoucherSalesLine.SetRange("External Document No.",NpRvExtVoucherBuffer."Document No.");
          NpRvExtVoucherSalesLine.SetRange("Voucher Type",NpRvVoucher."Voucher Type");
          NpRvExtVoucherSalesLine.SetRange("Voucher No.",NpRvVoucher."No.");
          if InUseQty = NpRvExtVoucherSalesLine.Count then begin
            Voucher2Buffer(NpRvVoucher,NpRvExtVoucherBuffer);
            exit;
          end;

          Error(Text001,NpRvExtVoucherBuffer."Reference No.");
        end;

        Timestamp := CurrentDateTime;
        if NpRvVoucher."Starting Date" >  Timestamp then
          Error(Text004,NpRvExtVoucherBuffer."Reference No.");

        if (NpRvVoucher."Ending Date" < Timestamp) and (NpRvVoucher."Ending Date" <> 0DT) then
          Error(Text005,NpRvExtVoucherBuffer."Reference No.");

        NpRvExtVoucherSalesLine.SetRange("External Document No.",NpRvExtVoucherBuffer."Document No.");
        if NpRvExtVoucherSalesLine.FindLast then;
        LineNo := NpRvExtVoucherSalesLine."Line No." + 10000;

        NpRvExtVoucherSalesLine.Init;
        NpRvExtVoucherSalesLine."External Document No." := NpRvExtVoucherBuffer."Document No.";
        NpRvExtVoucherSalesLine."Line No." := LineNo;
        NpRvExtVoucherSalesLine.Type := NpRvExtVoucherSalesLine.Type::Payment;
        NpRvExtVoucherSalesLine."Voucher Type" := NpRvVoucher."Voucher Type";
        NpRvExtVoucherSalesLine."Voucher No." := NpRvVoucher."No.";
        NpRvExtVoucherSalesLine."Reference No." := NpRvExtVoucherBuffer."Reference No.";
        NpRvExtVoucherSalesLine.Description := NpRvVoucher.Description;
        NpRvExtVoucherSalesLine.Insert;

        Voucher2Buffer(NpRvVoucher,NpRvExtVoucherBuffer);
    end;

    local procedure "--- Cancel Voucher Reservation"()
    begin
    end;

    [Scope('Personalization')]
    procedure CancelVoucherReservations(var vouchers: XMLport "NpRv Ext. Vouchers")
    var
        NpRvExtVoucherBuffer: Record "NpRv Ext. Voucher Buffer" temporary;
    begin
        SetGlobalLanguage(UserId);

        vouchers.Import;
        vouchers.GetSourceTable(NpRvExtVoucherBuffer);
        if NpRvExtVoucherBuffer.IsEmpty then
          exit;

        NpRvExtVoucherBuffer.FindSet;
        repeat
          CancelVoucherReservation(NpRvExtVoucherBuffer);
        until NpRvExtVoucherBuffer.Next = 0;
    end;

    local procedure CancelVoucherReservation(var NpRvExtVoucherBuffer: Record "NpRv Ext. Voucher Buffer" temporary)
    var
        NpRvVoucher: Record "NpRv Voucher";
        NpRvExtVoucherSalesLine: Record "NpRv Ext. Voucher Sales Line";
    begin
        if not FindVoucher(NpRvExtVoucherBuffer."Voucher Type",NpRvExtVoucherBuffer."Reference No.",NpRvVoucher) then
          Error(Text000,NpRvExtVoucherBuffer."Reference No.");

        NpRvExtVoucherSalesLine.SetRange("Reference No.",NpRvExtVoucherBuffer."Reference No.");
        NpRvExtVoucherSalesLine.SetRange(Type,NpRvExtVoucherSalesLine.Type::Payment);
        if NpRvExtVoucherSalesLine.FindSet then
          repeat
            if NpRvExtVoucherSalesLine."External Document No." <> NpRvExtVoucherBuffer."Document No." then
              Error(Text006,NpRvExtVoucherBuffer."Reference No.");
            if NpRvExtVoucherSalesLine."Document No." <> '' then
              Error(Text007,NpRvExtVoucherBuffer."Reference No.",NpRvExtVoucherSalesLine."Document No.");
            NpRvExtVoucherSalesLine.Delete;
          until NpRvExtVoucherSalesLine.Next = 0;

        Voucher2Buffer(NpRvVoucher,NpRvExtVoucherBuffer);
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

    local procedure Voucher2Buffer(var NpRvVoucher: Record "NpRv Voucher";var NpRvExtVoucherBuffer: Record "NpRv Ext. Voucher Buffer")
    begin
        NpRvVoucher.CalcFields(Amount,"Issue Date","Issue Register No.","Issue Document No.","Issue User ID");
        NpRvVoucher.CalcFields(Open);
        NpRvExtVoucherBuffer."Reference No." := NpRvVoucher."Reference No.";
        NpRvExtVoucherBuffer."Voucher Type" := NpRvVoucher."Voucher Type";
        NpRvExtVoucherBuffer.Description := NpRvVoucher.Description;
        NpRvExtVoucherBuffer."Starting Date" := NpRvVoucher."Starting Date";
        NpRvExtVoucherBuffer."Ending Date" := NpRvVoucher."Ending Date";
        NpRvExtVoucherBuffer."Account No." := NpRvVoucher."Account No.";
        NpRvExtVoucherBuffer.Open := NpRvVoucher.Open;
        NpRvExtVoucherBuffer."In-use Quantity" := NpRvVoucher.CalcInUseQty();
        NpRvExtVoucherBuffer.Amount := NpRvVoucher.Amount;
        NpRvExtVoucherBuffer.Name := NpRvVoucher.Name;
        NpRvExtVoucherBuffer."Name 2" := NpRvVoucher."Name 2";
        NpRvExtVoucherBuffer.Address := NpRvVoucher.Address;
        NpRvExtVoucherBuffer."Address 2" := NpRvVoucher."Address 2";
        NpRvExtVoucherBuffer."Post Code" := NpRvVoucher."Post Code";
        NpRvExtVoucherBuffer.City := NpRvVoucher.City;
        NpRvExtVoucherBuffer.County := NpRvVoucher.County;
        NpRvExtVoucherBuffer."Country/Region Code" := NpRvVoucher."Country/Region Code";
        NpRvExtVoucherBuffer."E-mail" := NpRvVoucher."E-mail";
        NpRvExtVoucherBuffer."Phone No." := NpRvVoucher."Phone No.";
        //-NPR5.48 [341711]
        NpRvExtVoucherBuffer."Send via Print" := NpRvVoucher."Send via Print";
        NpRvExtVoucherBuffer."Send via E-mail" := NpRvVoucher."Send via E-mail";
        NpRvExtVoucherBuffer."Send via SMS" := NpRvVoucher."Send via SMS";
        //+NPR5.48 [341711]
        NpRvExtVoucherBuffer."Voucher Message" := NpRvVoucher."Voucher Message";
        NpRvExtVoucherBuffer."Issue Date" := NpRvVoucher."Issue Date";
        NpRvExtVoucherBuffer."Issue Register No." := NpRvVoucher."Issue Register No.";
        NpRvExtVoucherBuffer."Issue Sales Ticket No." := NpRvVoucher."Issue Document No.";
        NpRvExtVoucherBuffer."Issue User ID" := NpRvVoucher."Issue User ID";
        NpRvExtVoucherBuffer.Modify;
    end;

    local procedure Buffer2Voucher(var NpRvExtVoucherBuffer: Record "NpRv Ext. Voucher Buffer";var NpRvVoucher: Record "NpRv Voucher")
    begin
        NpRvVoucher."Starting Date" := NpRvExtVoucherBuffer."Starting Date";
        NpRvVoucher.Validate("Voucher Type",NpRvExtVoucherBuffer."Voucher Type");
        if NpRvExtVoucherBuffer.Description <> '' then
          NpRvVoucher.Description := NpRvExtVoucherBuffer.Description;
        if NpRvExtVoucherBuffer."Ending Date" <> 0DT then
          NpRvVoucher."Ending Date" := NpRvExtVoucherBuffer."Ending Date";
        if NpRvExtVoucherBuffer."Account No." <> '' then
          NpRvVoucher."Account No." := NpRvExtVoucherBuffer."Account No.";
        NpRvVoucher.Name := NpRvExtVoucherBuffer.Name;
        NpRvVoucher."Name 2" := NpRvExtVoucherBuffer."Name 2";
        NpRvVoucher.Address := NpRvExtVoucherBuffer.Address;
        NpRvVoucher."Address 2" := NpRvExtVoucherBuffer."Address 2";
        NpRvVoucher."Post Code" := NpRvExtVoucherBuffer."Post Code";
        NpRvVoucher.City := NpRvExtVoucherBuffer.City;
        NpRvVoucher.County := NpRvExtVoucherBuffer.County;
        NpRvVoucher."Country/Region Code" := NpRvExtVoucherBuffer."Country/Region Code";
        NpRvVoucher."E-mail" := NpRvExtVoucherBuffer."E-mail";
        NpRvVoucher."Phone No." := NpRvExtVoucherBuffer."Phone No.";
        //-NPR5.48 [341711]
        NpRvVoucher."Send via Print" := NpRvExtVoucherBuffer."Send via Print";
        NpRvVoucher."Send via E-mail" := NpRvExtVoucherBuffer."Send via E-mail";
        NpRvVoucher."Send via SMS" := NpRvExtVoucherBuffer."Send via SMS";
        if (not NpRvVoucher."Send via Print") and (not NpRvVoucher."Send via SMS") and (NpRvVoucher."E-mail" <> '') then
          NpRvVoucher."Send via E-mail" := true;
        //+NPR5.48 [341711]
        if NpRvExtVoucherBuffer."Voucher Message" <> '' then
          NpRvVoucher."Voucher Message" := NpRvExtVoucherBuffer."Voucher Message";
        NpRvVoucher."Issue Date" := NpRvExtVoucherBuffer."Issue Date";
        NpRvVoucher."Issue Register No." := NpRvExtVoucherBuffer."Issue Register No.";
        NpRvVoucher."Issue Document No." := NpRvExtVoucherBuffer."Issue Sales Ticket No.";
        NpRvVoucher."Issue User ID" := NpRvExtVoucherBuffer."Issue User ID";
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

