codeunit 85595 "NPR Ecom Doc V1 Subscriber"
{
    Access = Internal;
    EventSubscriberInstance = Manual;

    var
        _Sequence: Text;
        _WriteMode: Boolean;
        _SkipCustomerContact: Boolean;

    procedure Sequence(): Text
    begin
        exit(_Sequence);
    end;

    procedure SetWriteMode(WriteMode: Boolean)
    begin
        _WriteMode := WriteMode;
    end;

    procedure SetSkipCustomerContact(SkipCustomerContact: Boolean)
    begin
        _SkipCustomerContact := SkipCustomerContact;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EcomSalesDocApiEvents", OnAfterDeserializeIncomingEcomSalesHeader, '', false, false)]
    local procedure RecordDeserializeHeader(var EcomSalesHeader: Record "NPR Ecom Sales Header"; RequestBody: JsonToken)
    begin
        Append('DH');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EcomSalesDocApiEvents", OnBeforeProcessIncomingSalesHeaderInsertIncSalesHeader, '', false, false)]
    local procedure RecordInsertHeader(var EcomSalesHeader: Record "NPR Ecom Sales Header"; RequestBody: JsonToken)
    begin
        Append('IH');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EcomSalesDocApiEvents", OnAfterDeserializeIncomingEcomSalesLine, '', false, false)]
    local procedure RecordDeserializeLine(SalesLineJsonToken: JsonToken; var EcomSalesLine: Record "NPR Ecom Sales Line")
    begin
        Append('DL:' + Format(EcomSalesLine."Line No.", 0, 9));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EcomSalesDocApiEvents", OnBeforeInsertIncomingSalesLineBeforeInsert, '', false, false)]
    local procedure RecordInsertLine(SalesLineJsonToken: JsonToken; EcomSalesHeader: Record "NPR Ecom Sales Header"; var EcomSalesLine: Record "NPR Ecom Sales Line")
    begin
        Append('IL:' + Format(EcomSalesLine."Line No.", 0, 9));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EcomSalesDocApiEvents", OnAfterDeserializeIncomingEcomSalesPaymentLine, '', false, false)]
    local procedure RecordDeserializePayment(PaymentLineJsonToken: JsonToken; var EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line")
    begin
        Append('DP:' + Format(EcomSalesPmtLine."Line No.", 0, 9));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EcomSalesDocApiEvents", OnBeforeInsertIncomingSalesPaymentLineBeforeInsert, '', false, false)]
    local procedure RecordInsertPayment(PaymentLineJsonToken: JsonToken; EcomSalesHeader: Record "NPR Ecom Sales Header"; var EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line")
    begin
        Append('IP:' + Format(EcomSalesPmtLine."Line No.", 0, 9));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EcomSalesDocApiEvents", OnBeforeModifyIncomingSalesDocumentCommentBeforeModifyRecordLink, '', false, false)]
    local procedure RecordComment(SalesLineJsonToken: JsonToken; EcomSalesHeader: Record "NPR Ecom Sales Header"; var RecordLink: Record "Record Link")
    begin
        Append('C');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EcomSalesDocApiEvents", OnGetSalesDocumentCreateResponseBeforeEndObject, '', false, false)]
    local procedure RecordCreateResponse(SalesHeader: Record "NPR Ecom Sales Header"; var SalesDocumentJsonObject: Codeunit "NPR Json Builder")
    begin
        Append('R');
        SalesDocumentJsonObject.AddProperty('v1CreateProbe', true);
    end;

#pragma warning disable AL0432
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EcomSalesDocApiEvents", OnGetSalesDocumentJsonObjectAfterSalesHeaderInformation, '', false, false)]
    local procedure RecordGetHeader(SalesHeader: Record "NPR Ecom Sales Header"; var SalesDocumentJsonObject: Codeunit "NPR Json Builder")
    begin
        Append('GH:' + Format(SalesHeader."Entry No.", 0, 9));
        if _WriteMode then
            SalesDocumentJsonObject.AddProperty('v1AfterHeader', true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EcomSalesDocApiEvents", OnCreateAddSalesLineDetailsJsonObjectBeforeEndObject, '', false, false)]
    local procedure RecordGetLine(EcomSalesLine: Record "NPR Ecom Sales Line"; var SalesLineDetailsJsonObject: Codeunit "NPR Json Builder")
    begin
        Append('GL:' + LowerCase(Format(EcomSalesLine.SystemId, 0, 4)));
        if _WriteMode then
            SalesLineDetailsJsonObject.AddProperty('v1Line', true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EcomSalesDocApiEvents", OnGetSalesDocumentJsonObjectAfterSalesHeaderInformationBeforeEndObject, '', false, false)]
    local procedure RecordGetEnd(SalesHeader: Record "NPR Ecom Sales Header"; var SalesDocumentJsonObject: Codeunit "NPR Json Builder")
    begin
        Append('GE:' + Format(SalesHeader."Entry No.", 0, 9));
        if _WriteMode then
            SalesDocumentJsonObject.AddProperty('v1BeforeEnd', true);
    end;
#pragma warning restore AL0432

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EcomSalesDocApiEvents", OnGetSalesDocumentCustomFieldsJsonObject, '', false, false)]
    local procedure RecordHeaderCustomFields(SalesHeader: Record "NPR Ecom Sales Header"; var SalesDocumentCustomFieldsJsonObject: Codeunit "NPR Json Builder")
    begin
        Append('XH');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EcomSalesDocApiEvents", OnGetPaymentDocumentDetailsCustomFieldsJsonObject, '', false, false)]
    local procedure RecordPaymentCustomFields(EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line"; var PaymentDocumentDetailsCustomFieldsJsonObject: Codeunit "NPR Json Builder")
    begin
        Append('XP');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EcomSalesDocApiEvents", OnCreateAddSalesLineDetailsCustomFieldsJsonObject, '', false, false)]
    local procedure RecordLineCustomFields(EcomSalesLine: Record "NPR Ecom Sales Line"; var SalesLineDetailsCustomFieldsJsonObject: Codeunit "NPR Json Builder")
    begin
        Append('XL');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EcomSalesDocApiEvents", OnAfterReserveVoucher, '', false, false)]
    local procedure RecordReserveVoucher(EcomSalesHeader: Record "NPR Ecom Sales Header"; EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line"; var VoucherSalesLine: Record "NPR NpRv Sales Line")
    begin
        Append('RV');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Ecom Sales Doc Events", OnSetSalesDocCreationStatusErrorBeforeModifyRecord, '', false, false)]
    local procedure RecordStatusError(var EcomSalesHeader: Record "NPR Ecom Sales Header"; ErrorMessage: Text[500]; UpdateStatus: Boolean; ModifyRecord: Boolean)
    begin
        Append('SE:' + Format(UpdateStatus, 0, 9));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Ecom Sales Doc Events", OnSetSalesDocCreationStatusCreatedBeforeModifyRecord, '', false, false)]
    local procedure RecordStatusCreated(var EcomSalesHeader: Record "NPR Ecom Sales Header"; ModifyRecord: Boolean)
    begin
        Append('SC');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Ecom Sales Doc Events", OnHandleResponseBeforeModifyRecord, '', false, false)]
    local procedure RecordHandleResponse(Success: Boolean; var EcomSalesHeader: Record "NPR Ecom Sales Header"; UpdateRetryCount: Boolean)
    begin
        Append('HR:' + Format(Success, 0, 9) + ':' + Format(UpdateRetryCount, 0, 9));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CustCont-Update", 'OnBeforeOnInsert', '', false, false)]
    local procedure SkipCustomerContact(var Customer: Record Customer; var IsHandled: Boolean)
    begin
        if _SkipCustomerContact then
            IsHandled := true;
    end;

    local procedure Append(Entry: Text)
    begin
        if _Sequence <> '' then
            _Sequence += ',';
        _Sequence += Entry;
    end;
}
