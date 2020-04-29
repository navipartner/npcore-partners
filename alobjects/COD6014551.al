codeunit 6014551 "RP Aux - Captions"
{
    // NPR5.36/MMV /20170906 CASE 289514 Added line discount caption
    // NPR5.38/MMV /20171207 CASE 294044 Added warranty caption
    // NPR5.43/EMGO/20180528 CASE 316833 Added Test Environment caption


    trigger OnRun()
    begin
    end;

    var
        Caption_Total: Label 'Total';
        Caption_Vat: Label 'VAT';
        Caption_Settlement: Label 'Settlement';
        Caption_Rounding: Label 'Rounding';
        Caption_ReturnOrder: Label 'Return Order';
        Caption_Shipment: Label 'Shipment';
        Caption_PostedInvoice: Label 'Posted Invoice';
        Caption_CrMemoInvoice: Label 'Credit Memo Invoice';
        Caption_COPY: Label '*** COPY ***';
        Caption_ValidYears: Label 'Validity Period (Years)';
        Caption_VoucherLegal: Label 'Invalid without company stamp and signature.';
        Caption_StampSignature: Label 'Stamp and Signature';
        Caption_GiftVoucher: Label 'Gift Voucher';
        Caption_CreditVoucher: Label 'Credit Voucher';
        Caption_TotalInclVAT: Label 'Total Incl. VAT';
        Caption_TotalExclVAT: Label 'Total Excl. VAT';
        Caption_Address: Label 'Address';
        Caption_CustomerSignature: Label 'Customer Signature';
        Caption_LineDisc: Label 'Line Discount';
        Caption_WarrantyProof: Label 'Proof of Warranty';
        Caption_TestEnvironment: Label 'TEST - NOT VALID SALES';

    local procedure "// Locals"()
    begin
    end;

    local procedure AddFunction(var tmpRetailList: Record "Retail List" temporary;Choice: Text)
    begin
        tmpRetailList.Number += 1;
        tmpRetailList.Choice := Choice;
        tmpRetailList.Insert;
    end;

    local procedure "// Event Subscribers"()
    begin
    end;

    [EventSubscriber(ObjectType::Table, 6014445, 'OnBuildFunctionCodeunitList', '', false, false)]
    local procedure OnBuildFunctionCodeunitList(var tmpAllObj: Record AllObj temporary)
    var
        AllObj: Record AllObj;
    begin
        AllObj.Get(AllObj."Object Type"::Codeunit, CODEUNIT::"RP Aux - Captions");
        tmpAllObj.Init;
        tmpAllObj := AllObj;
        tmpAllObj.Insert;
    end;

    [EventSubscriber(ObjectType::Table, 6014445, 'OnBuildFunctionList', '', false, false)]
    local procedure OnBuildFunctionList(CodeunitID: Integer;var tmpRetailList: Record "Retail List" temporary)
    begin
        if CodeunitID <> CODEUNIT::"RP Aux - Captions" then
          exit;

        AddFunction(tmpRetailList, 'CAPTION_TOTAL');
        AddFunction(tmpRetailList, 'CAPTION_VAT');
        AddFunction(tmpRetailList, 'CAPTION_TOTALINCLVAT');
        AddFunction(tmpRetailList, 'CAPTION_TOTALEXCLVAT');
        AddFunction(tmpRetailList, 'CAPTION_SETTLEMENT');
        AddFunction(tmpRetailList, 'CAPTION_ROUNDING');
        AddFunction(tmpRetailList, 'CAPTION_RETURNORDER');
        AddFunction(tmpRetailList, 'CAPTION_SHIPMENT');
        AddFunction(tmpRetailList, 'CAPTION_POSTEDINVOICE');
        AddFunction(tmpRetailList, 'CAPTION_CRMEMOINVOICE');
        AddFunction(tmpRetailList, 'CAPTION_COPY');
        AddFunction(tmpRetailList, 'CAPTION_VALIDYEARS');
        AddFunction(tmpRetailList, 'CAPTION_VOUCHERLEGAL');
        AddFunction(tmpRetailList, 'CAPTION_STAMP_SIGNATURE');
        AddFunction(tmpRetailList, 'CAPTION_GIFTVOUCHER');
        AddFunction(tmpRetailList, 'CAPTION_CREDITVOUCHER');
        AddFunction(tmpRetailList, 'CAPTION_ADDRESS');
        AddFunction(tmpRetailList, 'CAPTION_CUSTOMERSIGNATURE');
        //-NPR5.36 [289514]
        AddFunction(tmpRetailList, 'CAPTION_LINEDISCOUNT');
        //+NPR5.36 [289514]
        //-NPR5.38 [294044]
        AddFunction(tmpRetailList, 'CAPTION_WARRANTYPROOF');
        //+NPR5.38 [294044]
        //-NPR5.43 [316833]
        AddFunction(tmpRetailList, 'CAPTION_TESTENVIRONMENT');
        //+NPR5.43 [316833]
    end;

    [EventSubscriber(ObjectType::Table, 6014445, 'OnFunction', '', false, false)]
    local procedure OnFunction(CodeunitID: Integer;FunctionName: Text;var TemplateLine: Record "RP Template Line";RecID: RecordID;var Skip: Boolean;var Handled: Boolean)
    begin
        if CodeunitID <> CODEUNIT::"RP Aux - Captions" then
          exit;

        Handled := true;

        with TemplateLine do
          case FunctionName of
            'CAPTION_TOTAL' : "Processing Value" := Caption_Total;
            'CAPTION_VAT' : "Processing Value" := Caption_Vat;
            'CAPTION_TOTALINCLVAT' : "Processing Value" := Caption_TotalInclVAT;
            'CAPTION_TOTALEXCLVAT' : "Processing Value" := Caption_TotalExclVAT;
            'CAPTION_SETTLEMENT' : "Processing Value" := Caption_Settlement;
            'CAPTION_ROUNDING' : "Processing Value" := Caption_Rounding;
            'CAPTION_RETURNORDER' : "Processing Value" := Caption_ReturnOrder;
            'CAPTION_SHIPMENT' : "Processing Value" := Caption_Shipment;
            'CAPTION_POSTEDINVOICE' : "Processing Value" := Caption_PostedInvoice;
            'CAPTION_CRMEMOINVOICE' : "Processing Value" := Caption_CrMemoInvoice;
            'CAPTION_COPY' : "Processing Value" := Caption_COPY;
            'CAPTION_VALIDYEARS' : "Processing Value" := Caption_ValidYears;
            'CAPTION_VOUCHERLEGAL' : "Processing Value" := Caption_VoucherLegal;
            'CAPTION_STAMP_SIGNATURE' : "Processing Value" := Caption_StampSignature;
            'CAPTION_GIFTVOUCHER' : "Processing Value" := Caption_GiftVoucher;
            'CAPTION_CREDITVOUCHER' : "Processing Value" := Caption_CreditVoucher;
            'CAPTION_ADDRESS' : "Processing Value" := Caption_Address;
            'CAPTION_CUSTOMERSIGNATURE' : "Processing Value" := Caption_CustomerSignature;
            //-NPR5.36 [289514]
            'CAPTION_LINEDISCOUNT' : "Processing Value" := Caption_LineDisc;
            //+NPR5.36 [289514]
            //-NPR5.38 [294044]
            'CAPTION_WARRANTYPROOF' : "Processing Value" := Caption_WarrantyProof;
            //+NPR5.38 [294044]
            //-NPR5.43 [316833]
            'CAPTION_TESTENVIRONMENT' : "Processing Value" := Caption_TestEnvironment;
            //+NPR5.43 [316833]
          end;
    end;
}

