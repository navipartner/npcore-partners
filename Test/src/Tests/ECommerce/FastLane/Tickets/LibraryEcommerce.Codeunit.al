#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 85161 "NPR Library Ecommerce"
{
    procedure CreateEcomSalesHeader(var EcomSalesHeader: Record "NPR Ecom Sales Header")
    begin
        EcomSalesHeader.Init();
        EcomSalesHeader."External No." := 'TEST-' + Format(Random(9999));
        EcomSalesHeader."Document Type" := EcomSalesHeader."Document Type"::Order;
        EcomSalesHeader."Creation Status" := EcomSalesHeader."Creation Status"::Pending;
        EcomSalesHeader."Bucket Id" := Random(100);
        EcomSalesHeader.Insert(true);
    end;

    procedure CreateCapturedTicketLine(var EcomSalesLine: Record "NPR Ecom Sales Line"; EcomSalesHeader: Record "NPR Ecom Sales Header"; ItemNo: Code[20])
    begin
        CreateTicketLine(EcomSalesLine, EcomSalesHeader, ItemNo, 1, 100);
        EcomSalesLine.Captured := true;
        EcomSalesLine.Modify();
    end;

    procedure CreateTicketLine(var EcomSalesLine: Record "NPR Ecom Sales Line"; EcomSalesHeader: Record "NPR Ecom Sales Header"; ItemNo: Code[20]; Qty: Decimal; UnitPrice: Decimal)
    begin
        if ItemNo = '' then
            ItemNo := CreateDefaultTicketItem();
        EcomSalesLine.Init();
        EcomSalesLine."Document Entry No." := EcomSalesHeader."Entry No.";
        EcomSalesLine."Document Type" := EcomSalesHeader."Document Type";
        EcomSalesLine."External Document No." := CopyStr(EcomSalesHeader."External No.", 1, MaxStrLen(EcomSalesLine."External Document No."));
        EcomSalesLine."Line No." := GetNextLineNo(EcomSalesHeader);
        EcomSalesLine.Type := EcomSalesLine.Type::Item;
        EcomSalesLine.Subtype := EcomSalesLine.Subtype::Ticket;
#pragma warning disable AA0139
        EcomSalesLine."No." := ItemNo;
#pragma warning restore AA0139
        EcomSalesLine.Quantity := Qty;
        EcomSalesLine."Unit Price" := UnitPrice;
        EcomSalesLine."Line Amount" := Qty * UnitPrice;
        EcomSalesLine.Insert(true);
    end;

    local procedure CreateDefaultTicketItem(): Code[20]
    var
        LibTicket: Codeunit "NPR Library - Ticket Module";
    begin
        LibTicket.CreateMinimalSetup();
        exit(LibTicket.CreateItem('', LibTicket.CreateTicketType(LibTicket.GenerateCode10(), '<+7D>', 0, 0, "NPR TM ActivationMethod_Type"::SCAN, 0, 0), 100));
    end;

    procedure CreateAdmissionWithDefaultSchedule(AdmissionCode: Code[20]; DefaultSchedule: Option): Code[20]
    var
        Admission: Record "NPR TM Admission";
    begin
        Admission.Init();
        Admission."Admission Code" := AdmissionCode;
        Admission.Description := AdmissionCode;
        Admission.Type := Admission.Type::LOCATION;
        Admission."Default Schedule" := DefaultSchedule;
        Admission."Capacity Limits By" := Admission."Capacity Limits By"::Override;
        Admission."Capacity Control" := Admission."Capacity Control"::NONE;
        Admission.Insert();
        exit(AdmissionCode);
    end;

    procedure CreateAdmissionWithCapacityControl(AdmissionCode: Code[20]; CapacityControl: Option): Code[20]
    var
        Admission: Record "NPR TM Admission";
    begin
        Admission.Init();
        Admission."Admission Code" := AdmissionCode;
        Admission.Description := AdmissionCode;
        Admission.Type := Admission.Type::LOCATION;
        Admission."Default Schedule" := Admission."Default Schedule"::TODAY;
        Admission."Capacity Limits By" := Admission."Capacity Limits By"::Override;
        Admission."Capacity Control" := CapacityControl;
        Admission.Insert();
        exit(AdmissionCode);
    end;

    procedure InsertEcomDocumentWithReservationToken(ExternalNo: Code[20]; ReservationToken: Text[100]; ItemNo: Code[20]; IncludeLineId: Boolean; var EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        TicketRequest: Record "NPR TM Ticket Reservation Req.";
        Body: JsonObject;
        Lines: JsonArray;
        Payments: JsonArray;
        LineId: Guid;
    begin
        TicketRequest.SetCurrentKey("Session Token ID");
        TicketRequest.SetFilter("Session Token ID", '=%1', ReservationToken);
        TicketRequest.FindFirst();
        if IncludeLineId then
            LineId := TicketRequest.SystemId;
        Body := CreateHeaderJson(ExternalNo);
        Body.Add('ticketReservationToken', ReservationToken);
        AddDefaultSellTo(Body);
        AddSalesLineJson(Lines, ItemNo, 1, 100, 0, LineId);
        Body.Add('salesDocumentLines', Lines);
        Body.Add('payments', Payments);
        ProcessEcomDocument(Body, ExternalNo, EcomSalesHeader);
    end;

    procedure InsertEcomDocument(ExternalNo: Code[20]; ItemNo: Code[20]; var EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        Body: JsonObject;
        Lines: JsonArray;
        Payments: JsonArray;
        EmptyGuid: Guid;
    begin
        Body := CreateHeaderJson(ExternalNo);
        AddDefaultSellTo(Body);
        AddSalesLineJson(Lines, ItemNo, 1, 100, 0, EmptyGuid);
        Body.Add('salesDocumentLines', Lines);
        Body.Add('payments', Payments);
        ProcessEcomDocument(Body, ExternalNo, EcomSalesHeader);
    end;

    procedure InsertEcomDocumentWithVoucherPayment(ExternalNo: Code[20]; ItemNo: Code[20]; CustomerNo: Code[20]; CurrencyCode: Code[10]; NpRvVoucher: Record "NPR NpRv Voucher"; OrderAmountFCY: Decimal; var EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        Body: JsonObject;
        Lines: JsonArray;
        Payments: JsonArray;
        EmptyGuid: Guid;
    begin
        Body := CreateHeaderJson(ExternalNo);
        if CurrencyCode <> '' then
            Body.Add('currencyCode', CurrencyCode);
        AddSellToWithCustomerNo(Body, CustomerNo);
        AddSalesLineJson(Lines, ItemNo, 1, OrderAmountFCY, 0, EmptyGuid);
        Body.Add('salesDocumentLines', Lines);
        AddVoucherPaymentJson(Payments, NpRvVoucher."Reference No.", OrderAmountFCY);
        Body.Add('payments', Payments);
        ProcessEcomDocument(Body, ExternalNo, EcomSalesHeader);
    end;

    local procedure GetNextLineNo(EcomSalesHeader: Record "NPR Ecom Sales Header"): Integer
    var
        EcomSalesLine: Record "NPR Ecom Sales Line";
    begin
        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        if EcomSalesLine.FindLast() then
            exit(EcomSalesLine."Line No." + 10000);
        exit(10000);
    end;

    local procedure CreateHeaderJson(ExternalNo: Code[20]): JsonObject
    var
        Body: JsonObject;
    begin
        Body.Add('externalNo', ExternalNo);
        Body.Add('documentType', 'order');
        exit(Body);
    end;

    local procedure AddDefaultSellTo(var Body: JsonObject)
    var
        SellTo: JsonObject;
    begin
        SellTo.Add('name', 'Test Customer');
        SellTo.Add('address', 'Test Street 1');
        SellTo.Add('postCode', '1234');
        SellTo.Add('city', 'Test City');
        SellTo.Add('countryCode', 'DK');
        SellTo.Add('email', 'test@ecommerce.test');
        Body.Add('sellToCustomer', SellTo);
    end;

    local procedure AddSellToWithCustomerNo(var Body: JsonObject; CustomerNo: Code[20])
    var
        SellTo: JsonObject;
    begin
        SellTo.Add('no', CustomerNo);
        SellTo.Add('name', 'Test Customer');
        SellTo.Add('address', 'Test Street 1');
        SellTo.Add('postCode', '1234');
        SellTo.Add('city', 'Test City');
        SellTo.Add('countryCode', 'DK');
        SellTo.Add('email', 'test@ecommerce.test');
        Body.Add('sellToCustomer', SellTo);
    end;

    local procedure AddSalesLineJson(var Lines: JsonArray; ItemNo: Code[20]; Quantity: Decimal; UnitPrice: Decimal; VatPercent: Decimal; ticketReservationLineId: Guid)
    var
        Line: JsonObject;
    begin
        Line.Add('type', 'item');
        Line.Add('no', ItemNo);
        Line.Add('quantity', Quantity);
        Line.Add('unitPrice', UnitPrice);
        Line.Add('vatPercent', VatPercent);
        Line.Add('lineAmount', Quantity * UnitPrice);
        if not IsNullGuid(TicketReservationLineId) then
            Line.Add('ticketReservationLineId', Format(ticketReservationLineId));
        Lines.Add(Line);
    end;

    local procedure AddVoucherPaymentJson(var Payments: JsonArray; VoucherReference: Code[50]; Amount: Decimal)
    var
        Payment: JsonObject;
    begin
        Payment.Add('paymentMethodType', 'voucher');
        Payment.Add('paymentReference', VoucherReference);
        Payment.Add('paymentAmount', Amount);
        Payments.Add(Payment);
    end;

    local procedure ProcessEcomDocument(Body: JsonObject; ExternalNo: Code[20]; var EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        ApiAgent: Codeunit "NPR EcomSalesDocApiAgentV2";
        Request: Codeunit "NPR API Request";
        BodyToken: JsonToken;
        PathSegments: List of [Text];
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
    begin
        BodyToken := Body.AsToken();
        PathSegments.Add('ecommerce');
        Request.Init("Http Method"::POST, '/ecommerce/v2/sales-documents', PathSegments, QueryParams, Headers, BodyToken);
        ApiAgent.CreateIncomingEcomDocument(Request);

        EcomSalesHeader.SetRange("External No.", ExternalNo);
        EcomSalesHeader.FindFirst();
    end;
}
#endif
