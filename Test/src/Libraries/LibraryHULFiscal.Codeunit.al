codeunit 85225 "NPR Library HU L Fiscal"
{
    EventSubscriberInstance = Manual;

    #region Setup Creating Procedures
    internal procedure CreateHULFiscalizationSetup()
    var
        HULFiscalizationSetup: Record "NPR HU L Fiscalization Setup";
    begin
        if not HULFiscalizationSetup.Get() then
            HULFiscalizationSetup.Init();
        HULFiscalizationSetup."HU Laurel Fiscal Enabled" := true;
        if not HULFiscalizationSetup.Insert() then
            HULFiscalizationSetup.Modify();
    end;

    internal procedure CreateHULPOSAuditProfileAndSetToPOSUnit(var POSUnit: Record "NPR POS Unit")
    var
        POSAuditProfile: Record "NPR POS Audit Profile";
    begin
        POSAuditProfile.Init();
        POSAuditProfile.Code := HandlerCode();
        POSAuditProfile."Allow Printing Receipt Copy" := POSAuditProfile."Allow Printing Receipt Copy"::Always;
        POSAuditProfile."Audit Handler" := HandlerCode();
        POSAuditProfile."Audit Log Enabled" := true;
        POSAuditProfile."Require Item Return Reason" := true;
        POSAuditProfile."Fill Sale Fiscal No. On" := POSAuditProfile."Fill Sale Fiscal No. On"::Successful;
        POSAuditProfile."Balancing Fiscal No. Series" := CreateNumberSeries();
        POSAuditProfile."Sale Fiscal No. Series" := CreateNumberSeries();
        POSAuditProfile."Sales Ticket No. Series" := CreateNumberSeries();
        POSAuditProfile."Credit Sale Fiscal No. Series" := CreateNumberSeries();
        POSAuditProfile.Insert();

        POSUnit."POS Audit Profile" := POSAuditProfile.Code;
        POSUnit.Modify();

        SetAllowedGapsInNosForNoSeries(POSAuditProfile."Sales Ticket No. Series");
    end;

    internal procedure CreateHULPOSUnitMapping(POSUnitNo: Code[10])
    var
        HULPOSUnitMapping: Record "NPR HU L POS Unit Mapping";
    begin
        if not HULPOSUnitMapping.Get(POSUnitNo) then begin
            HULPOSUnitMapping.Init();
            HULPOSUnitMapping."POS Unit No." := POSUnitNo;
            HULPOSUnitMapping."Laurel License" := GetLaurelLicence();
            HULPOSUnitMapping.Insert();
        end;
    end;

    internal procedure CreateHULVATPostingSetupMapping(var VATPostingSetup: Record "VAT Posting Setup")
    var
        HULVATPostSetupMapp: Record "NPR HU L VAT Post. Setup Mapp.";
    begin
        VATPostingSetup."VAT %" := 27;
        VATPostingSetup.Modify();
        if not HULVATPostSetupMapp.Get(VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group") then begin
            HULVATPostSetupMapp.Init();
            HULVATPostSetupMapp."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
            HULVATPostSetupMapp."VAT Prod. Posting Group" := VATPostingSetup."VAT Prod. Posting Group";
            HULVATPostSetupMapp."Laurel VAT Index" := HULVATPostSetupMapp."Laurel VAT Index"::"VAT Category C";
            HULVATPostSetupMapp.Insert();
        end;
    end;

    internal procedure CreateHULPOSPaymentMethodMapping(var POSPaymentMethod: Record "NPR POS Payment Method")
    var
        HULPOSPaymMethMapp: Record "NPR HU L POS Paym. Meth. Mapp.";
    begin
        POSPaymentMethod."Rounding Precision" := 5;
        POSPaymentMethod."Rounding Type" := POSPaymentMethod."Rounding Type"::Nearest;
        POSPaymentMethod.Modify();
        if not HULPOSPaymMethMapp.Get(POSPaymentMethod.Code) then begin
            HULPOSPaymMethMapp.Init();
            HULPOSPaymMethMapp."POS Payment Method Code" := POSPaymentMethod.Code;
            HULPOSPaymMethMapp."Payment Fiscal Type" := HULPOSPaymMethMapp."Payment Fiscal Type"::CASH;
            HULPOSPaymMethMapp."Payment Fiscal Subtype" := HULPOSPaymMethMapp."Payment Fiscal Subtype"::"Non-categorized";
            HULPOSPaymMethMapp."Payment Currency Type" := HULPOSPaymMethMapp."Payment Currency Type"::"Ft.";
            HULPOSPaymMethMapp.Insert();
        end
    end;

    internal procedure CreateHULReturnReasonMapping(ReturnReasonCode: Code[10])
    var
        HULReturnReasonMapp: Record "NPR HU L Return Reason Mapp.";
    begin
        if not HULReturnReasonMapp.Get(ReturnReasonCode) then begin
            HULReturnReasonMapp.Init();
            HULReturnReasonMapp."Return Reason Code" := ReturnReasonCode;
            HULReturnReasonMapp."HU L Return Reason Code" := HULReturnReasonMapp."HU L Return Reason Code"::V1;
            HULReturnReasonMapp.Insert();
        end;
    end;

    internal procedure CreateCustomer(var Customer: Record Customer; VATBusPostingGroup: Code[20])
    var
        LibrarySales: Codeunit "Library - Sales";
    begin
        LibrarySales.CreateCustomer(Customer);
        Customer."VAT Bus. Posting Group" := VATBusPostingGroup;
        Customer.Address := 'Test Address 123';
        Customer.City := 'Budapest';
        Customer."Post Code" := '1007';
        Customer.Modify();
    end;
    #endregion Setup Creating Procedures

    #region Helper Procedures
    local procedure CreateNumberSeries(): Text
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
        LibraryUtility: Codeunit "Library - Utility";
    begin
        LibraryUtility.CreateNoSeries(NoSeries, true, false, false);
        LibraryUtility.CreateNoSeriesLine(NoSeriesLine, NoSeries.Code, 'TEST_1', 'TEST_99999999');
        exit(NoSeries.Code);
    end;

    internal procedure CreateSalesperson(var Salesperson: Record "Salesperson/Purchaser")
    begin
        if not Salesperson.Get('1') then begin
            Salesperson.Init();
            Salesperson.Validate(Code, '1');
            Salesperson.Validate(Name, 'Test');
            Salesperson.Insert();
        end;
        Salesperson."NPR Register Password" := '1';
        Salesperson.Modify();
    end;

    local procedure SetAllowedGapsInNosForNoSeries(NoSeriesCode: Code[20])
    var
        NoSeriesLine: Record "No. Series Line";
    begin
        NoSeriesLine.SetRange("Series Code", NoSeriesCode);
        NoSeriesLine.SetRange(Open, true);
        NoSeriesLine.FindLast();
#if not (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        NoSeriesLine.Validate(Implementation, NoSeriesLine.Implementation::Sequence);
#else
        NoSeriesLine.Validate("Allow Gaps in Nos.", true);
#endif
        NoSeriesLine.Modify();
    end;
    #endregion Helper Procedures

    #region Mock Responses
    internal procedure GetPrintReceiptMockResponse() ResponseObj: JsonObject
    var
        ResponseText: Text;
    begin
        ResponseText :=
               '{' +
               '   "ResponseMessage": {' +
               '       "command": "printReceipt",' +
               '       "result": {' +
               '           "receiptData": {' +
               '               "sBBOXID": "Y11900016",' +
               '               "iClosureNr": "118",' +
               '               "iNr": "3",' +
               '               "sTimestamp": "2020.02.28 12:50:29",' +
               '               "sDocumentNumber": "0118/00003"' +
               '           },' +
               '           "iErrCode": "0",' +
               '           "sErrMsg": "",' +
               '           "retState": "0"' +
               '       }' +
               '   },' +
               '   "Success": true,' +
               '   "ErrorMessage": ""' +
               '}';
        ResponseObj.ReadFrom(ResponseText);
    end;

    internal procedure GetCashMgtMoneyInMockResponse() ResponseObj: JsonObject
    var
        ResponseText: Text;
    begin
        ResponseText :=
            '{' +
            '   "ResponseMessage": {' +
            '       "command": "moneyIn",' +
            '       "result": {' +
            '           "receiptData": {' +
            '               "sBBOXID": "Y11900016",' +
            '               "iClosureNr": "94",' +
            '               "iNr": "20",' +
            '               "sTimestamp": "2020.02.12 08:32:59",' +
            '               "sDocumentNumber": "M/Y11900016/0094/00012"' +
            '           },' +
            '           "iErrCode": "0",' +
            '           "sErrMsg": "",' +
            '           "retState": "0"' +
            '       }' +
            '   },' +
            '   "Success": true,' +
            '   "ErrorMessage": ""' +
            '}';
        ResponseObj.ReadFrom(ResponseText);
    end;

    internal procedure GetCashMgtMoneyOutMockResponse() ResponseObj: JsonObject
    var
        ResponseText: Text;
    begin
        ResponseText :=
            '{' +
            '   "ResponseMessage": {' +
            '       "command": "moneyOut",' +
            '       "result": {' +
            '           "receiptData": {' +
            '               "sBBOXID": "Y11900016",' +
            '               "iClosureNr": "94",' +
            '               "iNr": "20",' +
            '               "sTimestamp": "2020.02.12 08:32:59",' +
            '               "sDocumentNumber": "M/Y11900016/0094/00012"' +
            '           },' +
            '           "iErrCode": "0",' +
            '           "sErrMsg": "",' +
            '           "retState": "0"' +
            '       }' +
            '   },' +
            '   "Success": true,' +
            '   "ErrorMessage": ""' +
            '}';
        ResponseObj.ReadFrom(ResponseText);
    end;

    internal procedure GetOpenFiscalDayMockResponse() ResponseObj: JsonObject
    var
        ResponseText: Text;
    begin
        ResponseText :=
             '{' +
             '   "ResponseMessage": {' +
             '       "command": "openDay",' +
             '       "result": {' +
             '           "receiptData": {' +
             '               "sBBOXID": "Y11900016",' +
             '               "iClosureNr": "111",' +
             '               "iNr": "1",' +
             '               "sTimestamp": "2020.02.19 16:31:12",' +
             '               "sDocumentNumber": "NY/0111"' +
             '           },' +
             '           "iErrCode": "0",' +
             '           "sErrMsg": "",' +
             '           "retState": "0"' +
             '       }' +
             '   },' +
             '   "Success": true,' +
             '   "ErrorMessage": ""' +
             '}';
        ResponseObj.ReadFrom(ResponseText);
    end;

    internal procedure GetCloseFiscalDayMockResponse() ResponseObj: JsonObject
    var
        ResponseText: Text;
    begin
        ResponseText :=
             '{' +
             '   "ResponseMessage": {' +
             '       "command": "closeDay",' +
             '       "result": {' +
             '           "receiptData": {' +
             '               "sBBOXID": "Y11900016",' +
             '               "iClosureNr": "105",' +
             '               "iNr": "1",' +
             '               "sTimestamp": "2020.02.19 10:31:10",' +
             '               "sDocumentNumber": "Z/0105"' +
             '           },' +
             '           "iErrCode": "0",' +
             '           "sErrMsg": "",' +
             '           "retState": "0"' +
             '       }' +
             '   },' +
             '   "Success": true,' +
             '   "ErrorMessage": ""' +
             '}';
        ResponseObj.ReadFrom(ResponseText);
    end;

    internal procedure GetDailyTotalsMockResponse() ResponseObj: JsonObject
    var
        ResponseText: Text;
    begin
        ResponseText :=
             '{' +
             '   "ResponseMessage": {' +
             '       "command": "getDailyTotal",' +
             '       "result": {' +
             '           "pTotal": "7400.00",' +
             '           "iVoids": "0",' +
             '           "iRefunds": "0",' +
             '           "iNonFis": "0",' +
             '           "iNonFisAb": "0",' +
             '           "pGT": "100584181.00",' +
             '           "sBBOXID": "Y11900016",' +
             '           "iClosureNr": "94",' +
             '           "iReceiptNr": "17",' +
             '           "iInvNr": "0",' +
             '           "pVoidTotal": "0.00",' +
             '           "pRefundTotal": "0.00",' +
             '           "iCancelledVoids": "0",' +
             '           "iCancelledRefunds": "0",' +
             '           "iMoneyIn": "0",' +
             '           "iMoneyInAb": "0",' +
             '           "iMoneyOut": "0",' +
             '           "iMoneyOutAb": "0",' +
             '           "iMediaEx": "0",' +
             '           "iMediaExAb": "0",' +
             '           "iCancelledReceipts": "15",' +
             '           "iCancelledInvoices": "0",' +
             '           "iErrCode": "0",' +
             '           "sErrMsg": "",' +
             '           "retState": "0"' +
             '       }' +
             '   },' +
             '   "Success": true,' +
             '   "ErrorMessage": ""' +
             '}';
        ResponseObj.ReadFrom(ResponseText);
    end;
    #endregion Mock Responses

    #region Fiscalization Specific Values
    local procedure HandlerCode(): Code[20]
    var
        HandlerCodeTxt: Label 'HU_LAUREL', Locked = true, MaxLength = 20;
    begin
        exit(HandlerCodeTxt);
    end;

    local procedure GetLaurelLicence(): Text[30]
    begin
        exit('LIC-12345-1245')
    end;
    #endregion Fiscalization Specific Values
}