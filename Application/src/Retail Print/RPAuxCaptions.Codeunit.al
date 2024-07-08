codeunit 6014551 "NPR RP Aux: Captions"
{
    Access = Internal;

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
        Caption_TotalInclVAT: Label 'Total Incl. VAT';
        Caption_TotalExclVAT: Label 'Total Excl. VAT';
        Caption_Address: Label 'Address';
        Caption_CustomerSignature: Label 'Customer Signature';
        Caption_LineDisc: Label 'Line Discount';
        Caption_WarrantyProof: Label 'Proof of Warranty';
        Caption_TestEnvironment: Label 'TEST - NOT VALID SALES';

    local procedure AddFunction(var tmpRetailList: Record "NPR Retail List" temporary; Choice: Text)
    begin
        tmpRetailList.Number += 1;
#pragma warning disable AA0139
        tmpRetailList.Choice := Choice;
#pragma warning restore AA0139
        tmpRetailList.Insert();
    end;

    local procedure BuildFunctionCodeunitList(var tmpAllObj: Record AllObj temporary)
    var
        AllObj: Record AllObj;
    begin
        AllObj.Get(AllObj."Object Type"::Codeunit, CODEUNIT::"NPR RP Aux: Captions");
        tmpAllObj.Init();
        tmpAllObj := AllObj;
        tmpAllObj.Insert();
    end;

    local procedure BuildFunctionList(CodeunitID: Integer; var tmpRetailList: Record "NPR Retail List" temporary)
    begin
        if CodeunitID <> CODEUNIT::"NPR RP Aux: Captions" then
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
        AddFunction(tmpRetailList, 'CAPTION_LINEDISCOUNT');
        AddFunction(tmpRetailList, 'CAPTION_WARRANTYPROOF');
        AddFunction(tmpRetailList, 'CAPTION_TESTENVIRONMENT');
    end;

    local procedure DoFunction(CodeunitID: Integer; FunctionName: Text; var TemplateLine: Record "NPR RP Template Line"; var Handled: Boolean)
    begin
        if CodeunitID <> CODEUNIT::"NPR RP Aux: Captions" then
            exit;

        Handled := true;

        case FunctionName of
            'CAPTION_TOTAL':
                TemplateLine."Processing Value" := Caption_Total;
            'CAPTION_VAT':
                TemplateLine."Processing Value" := Caption_Vat;
            'CAPTION_TOTALINCLVAT':
                TemplateLine."Processing Value" := Caption_TotalInclVAT;
            'CAPTION_TOTALEXCLVAT':
                TemplateLine."Processing Value" := Caption_TotalExclVAT;
            'CAPTION_SETTLEMENT':
                TemplateLine."Processing Value" := Caption_Settlement;
            'CAPTION_ROUNDING':
                TemplateLine."Processing Value" := Caption_Rounding;
            'CAPTION_RETURNORDER':
                TemplateLine."Processing Value" := Caption_ReturnOrder;
            'CAPTION_SHIPMENT':
                TemplateLine."Processing Value" := Caption_Shipment;
            'CAPTION_POSTEDINVOICE':
                TemplateLine."Processing Value" := Caption_PostedInvoice;
            'CAPTION_CRMEMOINVOICE':
                TemplateLine."Processing Value" := Caption_CrMemoInvoice;
            'CAPTION_COPY':
                TemplateLine."Processing Value" := Caption_COPY;
            'CAPTION_VALIDYEARS':
                TemplateLine."Processing Value" := Caption_ValidYears;
            'CAPTION_VOUCHERLEGAL':
                TemplateLine."Processing Value" := Caption_VoucherLegal;
            'CAPTION_STAMP_SIGNATURE':
                TemplateLine."Processing Value" := Caption_StampSignature;
            'CAPTION_ADDRESS':
                TemplateLine."Processing Value" := Caption_Address;
            'CAPTION_CUSTOMERSIGNATURE':
                TemplateLine."Processing Value" := Caption_CustomerSignature;
            'CAPTION_LINEDISCOUNT':
                TemplateLine."Processing Value" := Caption_LineDisc;
            'CAPTION_WARRANTYPROOF':
                TemplateLine."Processing Value" := Caption_WarrantyProof;
            'CAPTION_TESTENVIRONMENT':
                TemplateLine."Processing Value" := Caption_TestEnvironment;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR RP Matrix Print Mgt.", 'OnBuildFunctionCodeunitList', '', false, false)]
    local procedure OnMatrixBuildFunctionCodeunitList(var tmpAllObj: Record AllObj)
    begin
        BuildFunctionCodeunitList(tmpAllObj);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR RP Matrix Print Mgt.", 'OnBuildFunctionList', '', false, false)]
    local procedure OnMatrixBuildFunctionList(CodeunitID: Integer; var tmpRetailList: Record "NPR Retail List")
    begin
        BuildFunctionList(CodeunitID, tmpRetailList);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR RP Matrix Print Mgt.", 'OnFunction', '', false, false)]
    local procedure OnMatrixFunction(CodeunitID: Integer; FunctionName: Text; RecID: RecordId; var Handled: Boolean; var Skip: Boolean; var TemplateLine: Record "NPR RP Template Line")
    begin
        DoFunction(CodeunitID, FunctionName, TemplateLine, Handled);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR RP Line Print Mgt.", 'OnBuildFunctionCodeunitList', '', false, false)]
    local procedure OnLineBuildFunctionCodeunitList(var tmpAllObj: Record AllObj)
    begin
        BuildFunctionCodeunitList(tmpAllObj);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR RP Line Print Mgt.", 'OnBuildFunctionList', '', false, false)]
    local procedure OnLineBuildFunctionList(CodeunitID: Integer; var tmpRetailList: Record "NPR Retail List")
    begin
        BuildFunctionList(CodeunitID, tmpRetailList);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR RP Line Print Mgt.", 'OnFunction', '', false, false)]
    local procedure OnLineFunction(CodeunitID: Integer; FunctionName: Text; RecID: RecordId; var Handled: Boolean; var Skip: Boolean; var TemplateLine: Record "NPR RP Template Line")
    begin
        DoFunction(CodeunitID, FunctionName, TemplateLine, Handled);
    end;
}

