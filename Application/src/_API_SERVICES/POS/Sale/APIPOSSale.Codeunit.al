#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6248255 "NPR API POS Sale"
{
    Access = Internal;

    procedure SearchSale(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        POSUnitFilter: Text;
        POSSale: Record "NPR POS Sale";
        WithLines: Boolean;
    begin
        if (not Request.QueryParams().ContainsKey('posunit')) then
            exit(Response.RespondBadRequest('Missing required query parameter: posunit'));
        POSUnitFilter := Request.QueryParams().Get('posunit');

        if Request.QueryParams().ContainsKey('withLines') then
            Evaluate(WithLines, Request.QueryParams().Get('withLines'));

        SelectLatestVersion();
        POSSale.ReadIsolation := IsolationLevel::ReadCommitted;
        POSSale.SetLoadFields(SystemId, "Sales Ticket No.", "Register No.", "Customer No.", "SystemCreatedAt");
        POSSale.SetFilter("Register No.", '=%1', POSUnitFilter);
        if not (POSSale.FindLast()) then
            exit(Response.RespondResourceNotFound());

        exit(Response.RespondOK(POSSaleAsJson(POSSale, WithLines)));
    end;

    internal procedure GetSale(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        saleId: Text;
        POSSale: Record "NPR POS Sale";
        WithLines: Boolean;
    begin
        saleId := Request.Paths().Get(3);
        if saleId = '' then
            exit(Response.RespondBadRequest('Missing required path parameter: saleId'));

        if Request.QueryParams().ContainsKey('withLines') then
            Evaluate(WithLines, Request.QueryParams().Get('withLines'));

        SelectLatestVersion();
        POSSale.ReadIsolation := IsolationLevel::ReadCommitted;
        POSSale.SetLoadFields(SystemId, "Sales Ticket No.", "Register No.", Date, "Start Time", "Customer No.");
        if not POSSale.GetBySystemId(saleId) then
            exit(Response.RespondResourceNotFound());

        exit(Response.RespondOK(POSSaleAsJson(POSSale, WithLines)));
    end;

    local procedure POSSaleAsJson(POSSale: Record "NPR POS Sale"; WithLines: Boolean) Json: Codeunit "NPR Json Builder"
    var
        POSSaleLine: Record "NPR POS Sale Line";
    begin
        Json.StartObject('')
            .AddProperty('saleId', Format(POSSale.SystemId, 0, 4).ToLower())
            .AddProperty('receiptNo', POSSale."Sales Ticket No.")
            .AddProperty('posUnit', POSSale."Register No.")
            .AddProperty('startTime', Format(POSSale.SystemCreatedAt, 0, 9))
            .AddProperty('customerNo', POSSale."Customer No.");

        if (WithLines) then begin
            POSSaleLine.SetRange("Register No.", POSSale."Register No.");
            POSSaleLine.SetRange("Sales Ticket No.", POSSale."Sales Ticket No.");
            POSSaleLine.SetFilter("Line Type", '<>%1', POSSaleLine."Line Type"::"POS Payment");
            POSSaleLine.SetLoadFields("Line No.", "Line Type", "No.", "Variant Code", "Description", "Quantity", "Unit Price", "Discount %", "Discount Amount", "VAT %", "Amount Including VAT", "Amount");
            POSSaleLine.ReadIsolation := IsolationLevel::ReadCommitted;
            Json.StartArray('saleLines');
            if POSSaleLine.FindSet() then
                repeat
                    Json.StartObject('')
                        .AddProperty('sortKey', POSSaleLine."Line No.")
                        .AddProperty('type', POSSaleLine."Line Type".Names.Get(POSSaleLine."Line Type".Ordinals().IndexOf(POSSaleLine."Line Type".AsInteger())))
                        .AddProperty('code', POSSaleLine."No.")
                        .AddProperty('variantCode', POSSaleLine."Variant Code")
                        .AddProperty('description', POSSaleLine.Description)
                        .AddProperty('quantity', POSSaleLine.Quantity)
                        .AddProperty('unitPrice', POSSaleLine."Unit Price")
                        .AddProperty('discountPct', POSSaleLine."Discount %")
                        .AddProperty('discountAmount', POSSaleLine."Discount Amount")
                        .AddProperty('vatPercent', POSSaleLine."VAT %")
                        .AddProperty('amountInclVat', POSSaleLine."Amount Including VAT")
                        .AddProperty('amount', POSSaleLine.Amount)
                    .EndObject();
                until POSSaleLine.Next() = 0;
            Json.EndArray();


            POSSaleLine.SetFilter("Line Type", '=%1', POSSaleLine."Line Type"::"POS Payment");
            POSSaleLine.SetLoadFields("Line No.", "Line Type", "No.", "Description", "Amount Including VAT");
            Json.StartArray('paymentLines');
            if POSSaleLine.FindSet() then
                repeat
                    Json.StartObject('')
                        .AddProperty('sortKey', POSSaleLine."Line No.")
                        .AddProperty('code', POSSaleLine."No.")
                        .AddProperty('description', POSSaleLine.Description)
                        .AddProperty('amountInclVat', POSSaleLine."Amount Including VAT")
                    .EndObject();
                until POSSaleLine.Next() = 0;
            Json.EndArray();
        end;
        Json.EndObject();
    end;
}
#endif