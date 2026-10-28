codeunit 85582 "NPR Ecom Doc Event Subscriber"
{
    Access = Internal;
    EventSubscriberInstance = Manual;

    var
        _Sequence: Text;
        _CreateResponseRaiseCount: Integer;

    procedure Sequence(): Text
    begin
        exit(_Sequence);
    end;

    procedure CreateResponseRaiseCount(): Integer
    begin
        exit(_CreateResponseRaiseCount);
    end;

    procedure HeaderEntry(EcomSalesHeader: Record "NPR Ecom Sales Header"): Text
    begin
        exit('H:' + Format(EcomSalesHeader."Entry No.", 0, 9));
    end;

    procedure PaymentEntry(EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line"): Text
    begin
        exit('P:' + LowerCase(Format(EcomSalesPmtLine.SystemId, 0, 4)));
    end;

    procedure LineEntry(EcomSalesLine: Record "NPR Ecom Sales Line"): Text
    begin
        exit('L:' + LowerCase(Format(EcomSalesLine.SystemId, 0, 4)));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EcomSalesDocApiEvents", OnGetSalesDocumentCustomFieldsJsonObject, '', false, false)]
    local procedure RecordHeader(SalesHeader: Record "NPR Ecom Sales Header"; var SalesDocumentCustomFieldsJsonObject: Codeunit "NPR Json Builder")
    begin
        Append(HeaderEntry(SalesHeader));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EcomSalesDocApiEvents", OnGetPaymentDocumentDetailsCustomFieldsJsonObject, '', false, false)]
    local procedure RecordPayment(EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line"; var PaymentDocumentDetailsCustomFieldsJsonObject: Codeunit "NPR Json Builder")
    begin
        Append(PaymentEntry(EcomSalesPmtLine));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EcomSalesDocApiEvents", OnCreateAddSalesLineDetailsCustomFieldsJsonObject, '', false, false)]
    local procedure RecordLine(EcomSalesLine: Record "NPR Ecom Sales Line"; var SalesLineDetailsCustomFieldsJsonObject: Codeunit "NPR Json Builder")
    begin
        Append(LineEntry(EcomSalesLine));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EcomSalesDocApiEvents", OnGetSalesDocumentCreateResponseBeforeEndObject, '', false, false)]
    local procedure MarkCreateResponse(SalesHeader: Record "NPR Ecom Sales Header"; var SalesDocumentJsonObject: Codeunit "NPR Json Builder")
    begin
        _CreateResponseRaiseCount += 1;
        SalesDocumentJsonObject.AddProperty('versioningProbe', true);
    end;

    local procedure Append(Entry: Text)
    begin
        if _Sequence <> '' then
            _Sequence += ',';
        _Sequence += Entry;
    end;
}
