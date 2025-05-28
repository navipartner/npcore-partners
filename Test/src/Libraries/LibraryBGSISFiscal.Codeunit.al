codeunit 85172 "NPR Library BG SIS Fiscal"
{
    EventSubscriberInstance = Manual;

    internal procedure CreateAuditProfileAndBGSISSetups(var POSAuditProfile: Record "NPR POS Audit Profile"; var VATPostingSetup: Record "VAT Posting Setup"; var POSUnit: Record "NPR POS Unit")
    begin
        InsertPOSAuditProfile(POSAuditProfile);
        AllowGapsInNoSeries(POSAuditProfile."Sales Ticket No. Series");

        EnableBGSISFiscalization();

        UpdatePOSAuditProfileOnPOSUnit(POSUnit, POSAuditProfile.Code);
        InsertBGSISPOSUnitMapping(POSUnit."No.");

        SetVATPctOnVATPostingSetup(VATPostingSetup, 20);
        InsertBGSISVATPostingMapping(VATPostingSetup);
        InsertBGSISPOSPaymentMethodMapping();
        InsertBGSISReturnReasonMapping();
    end;

    internal procedure GetPrintReceiptMockResponse() ResponseText: Text
    begin
        ResponseText :=
            '{' +
            '   "ZreportNum": "398",' +
            '   "dayReceiptNumber": "5",' +
            '   "grandReceiptNum": "7446",' +
            '   "guid": "",' +
            '   "id": "1",' +
            '   "jsonrpc": "2.0",' +
            '   "min2block": "4320",' +
            '   "reason2block": "0",' +
            '   "receiptTimestamp": "37,58,10;15,12,23",' +
            '   "result": "OK"' +
            '}';
    end;

    internal procedure GetMfcInfoMockResponse() ResponseText: Text
    begin
        ResponseText :=
            '{' +
            '   "FDNumber" : "BN610291",' +
            '   "FMNumber" : "51610291",' +
            '   "FiscalReceiptNumber" : "7",' +
            '   "IDNumber" : "200510279",' +
            '   "LastEODTimestamp" : "13/12/23",' +
            '   "RTC" : "13:26:51;15/12/23",' +
            '   "ZreportNum" : "398",' +
            '   "dayReceiptNumber" : "7",' +
            '   "grandReceiptNum" : "7448",' +
            '   "id" : "1",' +
            '   "jsonrpc" : "2.0"' +
            '}';
    end;

    internal procedure GetPrintXReportMockResponse() ResponseText: Text
    begin
        ResponseText :=
            '{' +
            '   "id" : "1",' +
            '   "jsonrpc" : "2.0",' +
            '   "result" : "OK"' +
            '}';
    end;

    internal procedure GetPrintZReportMockResponse() ResponseText: Text
    begin
        ResponseText :=
            '{' +
            '   "id" : "1",' +
            '   "jsonrpc" : "2.0",' +
            '   "result" : "OK"' +
            '}';
    end;

    internal procedure GetPrintDuplicateMockResponse() ResponseText: Text
    begin
        ResponseText :=
            '{' +
            '   "id" : "1",' +
            '   "jsonrpc" : "2.0",' +
            '   "result" : "OK"' +
            '}';
    end;

    internal procedure GetCashHandlingMockResponse() ResponseText: Text
    begin
        ResponseText :=
            '{' +
            '   "ZreportNum": "398",' +
            '   "dayReceiptNumber" : "7",' +
            '   "grandReceiptNum": "7450",' +
            '   "id": "1",' +
            '   "jsonrpc": "2.0",' +
            '   "min2block": "4320",' +
            '   "reason2block": "0",' +
            '   "result": "OK"' +
            '}';
    end;

    internal procedure GetGetCashBalanceMockResponse() ResponseText: Text
    begin
        ResponseText :=
            '{' +
            '   "cashBalance" : "100.00",' +
            '   "id" : "1",' +
            '   "jsonrpc" : "2.0",' +
            '}';
    end;

    internal procedure GetGetCashierDataMockResponse() ResponseText: Text
    begin
        ResponseText :=
            '{' +
            '   "cashBalance" : "0.00",' +
            '   "cashInAmount" : "0.00",' +
            '   "cashOutAmount" : "0.00",' +
            '   "id" : "1",' +
            '   "jsonrpc" : "2.0",' +
            '   "medium0" : "0.00",' +
            '   "medium1" : "0.00",' +
            '   "medium2" : "0.00",' +
            '   "medium3" : "0.00",' +
            '   "medium4" : "0.00",' +
            '   "medium5" : "0.00",' +
            '   "medium6" : "0.00",' +
            '   "medium7" : "0.00",' +
            '   "medium8" : "0.00",' +
            '   "operatorName" : "Д. Димчо",' +
            '   "operatorNumber" : "0001",' +
            '   "stornoAmount" : "0.00",' +
            '   "terminalNumber" : "    01"' +
            '}';
    end;

    internal procedure GetSetCashierMockResponse() ResponseText: Text
    begin
        ResponseText :=
            '{' +
            '   "id" : "1",' +
            '   "jsonrpc" : "2.0",' +
            '   "result" : "OK"' +
            '}';
    end;

    internal procedure GetDeleteCashierMockResponse() ResponseText: Text
    begin
        ResponseText :=
            '{' +
            '   "id" : "1",' +
            '   "jsonrpc" : "2.0",' +
            '   "result" : "OK"' +
            '}';
    end;

    internal procedure GetTrySetCashierMockResponse() ResponseText: Text
    begin
        ResponseText :=
            '{' +
            '   "id" : "1",' +
            '   "jsonrpc" : "2.0",' +
            '   "result" : "OK"' +
            '}';
    end;

    internal procedure GetEJReprintMockResponse() ResponseText: Text
    begin
        ResponseText :=
            '{' +
            '   "id" : "1",' +
            '   "jsonrpc" : "2.0",' +
            '   "result" : "OK"' +
            '}';
    end;

    internal procedure GetReprintFiscalReceiptMockResponse() ResponseText: Text
    begin
        ResponseText :=
            '{' +
            '   "id" : "1",' +
            '   "jsonrpc" : "2.0",' +
            '   "result" : "OK"' +
            '}';
    end;

    internal procedure GetPrintMFReportMockResponse() ResponseText: Text
    begin
        ResponseText :=
            '{' +
            '   "data" : "CvEu0ODi7e4g7+7r5Swg8+suIjMt8uggzODw8iIgTm8gMQrB08vR0sDSOjIwMDUxMDI3OQrL6OTrIPEuIMrg4ejr5SAwNzc3CvEuIMrg4ejr5QrHxMTRIE5vIEJHMTMxMDcxNTg3CiMwMDAxICAgICAgICAgICAgxC4gxOjs9+4gICAgICAgICAgICAgICAgIDAxCgogICAgICAgICAgICAgICAgICDExdLAycvFzSAgICAgICAgICAgICAgICAgIAogICAgICAgICAgztLXxdIgzcAg1MjRysDLzcAgz8DMxdIgICAgICAgICAgIAoKztIgwcvOyiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIDAzNjEKxM4gwcvOyiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIDAzNjEKCiAgICAgICAgICAgICAgICAgIMLawsXExc3AICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgIMIgxcrRz8vOwNLA1sjfICAgICAgICAgICAgICAgCjE2LjA5LjIwMjIgICAgICAgICAgICAgICAgICAgICAgICAgIDExOjAzOjAwCgrExNEgNiAgICAgICAgICAgICAgICAgICAgICAgICAgIM7SIMHLzsogMDAwMQoxOC4xMS4yMDIyICAgICAgICAgICAgICAgICAgICAgICAgICAxNToxMToyOArE0M7Bzcgg18jRy8AgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICDAID0gIDAlCiAgICAgIMEgPSAyMCUKICAgICAgwiA9IDIwJQogICAgICDDID0gIDklCgrBy87KIDAzNjEgICAgICAgICAgICAgICAgMTAuMTAuMjAyMyAyMzo1OTo1OQrOwc7QztIqwCAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgMC4wMArOwc7QztIqwSAgICAgICAgICAgICAgICAgICAgICAgICAgICAgMjY0OC45OQrOwc7QztIqwiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgMC4wMArOwc7QztIqwyAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgMC4wMArOwdnOIM7BztDO0iAgICAgICAgICAgICAgICAgICAgICAgICAgMjY0OC45OQrR0s7Qzc4gzsHO0M7SKsAgICAgICAgICAgICAgICAgICAgICAgICAgMC4wMArR0s7Qzc4gzsHO0M7SKsEgICAgICAgICAgICAgICAgICAgICAgMTEwMC4wMArR0s7Qzc4gzsHO0M7SKsIgICAgICAgICAgICAgICAgICAgICAgICAgMC4wMArR0s7Qzc4gzsHO0M7SKsMgICAgICAgICAgICAgICAgICAgICAgICAgMC4wMArOwdkg0dLO0M3OIM7BztDO0iAgICAgICAgICAgICAgICAgICAgMTEwMC4wMApOIM/O0csuxM7K08zFzdI6MDAwMDAwNjU5MCAgICAgICAgysvFzSBOOjAwMQoKICB+ICB+ICB+ICB+ICB+ICB+ICB+ICB+ICB+ICB+ICB+ICB+ICB+ICB+ICAKICAgICAgICAgICAgICDR08zAIM7BztDO0iwgxMTRICAgICAgICAgICAgICAKzsHO0M7SKsAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIDAuMDAKxMTRKsAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIDAuMDAKzsHO0M7SKsEgICAgICAgICAgICAgICAgICAgICAgICAgICAgIDI2NDguOTkKxMTRKsEgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICA0NDEuNTAKzsHO0M7SKsIgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIDAuMDAKxMTRKsIgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIDAuMDAKzsHO0M7SKsMgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIDAuMDAKxMTRKsMgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIDAuMDAKzsHZziDOwc7QztIgICAgICAgICAgICAgICAgICAgICAgICAgIDI2NDguOTkKzsHZziDExNEgICAgICAgICAgICAgICAgICAgICAgICAgICAgICA0NDEuNTAKICAgICAgICAgICAgINHSztDNziDOwc7QztIsIMTE0SAgICAgICAgICAgICAKzsHO0M7SKsAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIDAuMDAKxMTRKsAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIDAuMDAKzsHO0M7SKsEgICAgICAgICAgICAgICAgICAgICAgICAgICAgIDExMDAuMDAKxMTRKsEgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAxODMuMzMKzsHO0M7SKsIgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIDAuMDAKxMTRKsIgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIDAuMDAKzsHO0M7SKsMgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIDAuMDAKxMTRKsMgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIDAuMDAKzsHZINHSztDNziDOwc7QztIgICAgICAgICAgICAgICAgICAgIDExMDAuMDAKzsHZziDExNEgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAxODMuMzMKTiDPztHLLsTOytPMxc3SOjAwMDAwMDY1OTAgICDKy8XNIE46MDAxLT4wMDEKCjAwMDAwMDc0NTcgICAgICAxOC4xMi4yMDIzICAgICAgICAxNzoyMTo1MQpCTjYxMDI5MSAgICAgICAgICAgICAgICAgICAgICAgICAgICA1MTYxMDI5MQo4MzEwRTRCOEZFMkQ5RjZCRTUxNUI1QjEwQ0ExMzlENjk3MkY1MkZBCg==",' +
            '   "id" : "1",' +
            '   "jsonrpc" : "2.0",' +
            '   "result" : "OK"' +
            '}';
    end;

    local procedure InsertPOSAuditProfile(var POSAuditProfile: Record "NPR POS Audit Profile")
    var
        BGSISAuditMgt: Codeunit "NPR BG SIS Audit Mgt.";
    begin
        POSAuditProfile.Init();
        POSAuditProfile.Code := CopyStr(BGSISAuditMgt.HandlerCode(), 1, MaxStrLen(POSAuditProfile.Code));
        POSAuditProfile."Audit Handler" := CopyStr(BGSISAuditMgt.HandlerCode(), 1, MaxStrLen(POSAuditProfile."Audit Handler"));
        POSAuditProfile."Audit Log Enabled" := true;
        POSAuditProfile."Fill Sale Fiscal No. On" := POSAuditProfile."Fill Sale Fiscal No. On"::Successful;
        POSAuditProfile."Require Item Return Reason" := true;
        POSAuditProfile."Balancing Fiscal No. Series" := CreateNumberSeries();
        POSAuditProfile."Sale Fiscal No. Series" := CreateNumberSeries();
        POSAuditProfile."Sales Ticket No. Series" := CreateNumberSeries();
        POSAuditProfile."Credit Sale Fiscal No. Series" := CreateNumberSeries();
        POSAuditProfile.Insert();
    end;

    local procedure AllowGapsInNoSeries(SeriesCode: Code[20])
    var
        NoSeriesLine: Record "No. Series Line";
    begin
        NoSeriesLine.SetRange("Series Code", SeriesCode);
        NoSeriesLine.SetRange(Open, true);
        NoSeriesLine.FindLast();
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        NoSeriesLine.Validate(Implementation, NoSeriesLine.Implementation::Sequence);
#ELSE
        NoSeriesLine.Validate("Allow Gaps in Nos.", true);
#ENDIF
        NoSeriesLine.Modify();
    end;

    local procedure InsertBGSISPOSUnitMapping(POSUnitNo: Code[10])
    var
        BGSISPOSUnitMapping: Record "NPR BG SIS POS Unit Mapping";
    begin
        BGSISPOSUnitMapping.Init();
        BGSISPOSUnitMapping."POS Unit No." := POSUnitNo;
        BGSISPOSUnitMapping."Fiscal Printer IP Address" := '83.145.254.20:5064'; // dummy IP address
        BGSISPOSUnitMapping."Printer Model" := BGSISPOSUnitMapping."Printer Model"::"MF-P1200DN 179";
        BGSISPOSUnitMapping."Fiscal Printer Device No." := 'BN610291';
        BGSISPOSUnitMapping."Fiscal Printer Memory No." := '51610291';
        BGSISPOSUnitMapping.Insert();
    end;

    local procedure EnableBGSISFiscalization()
    var
        BGFiscalizationSetup: Record "NPR BG Fiscalization Setup";
    begin
        if not BGFiscalizationSetup.Get() then
            BGFiscalizationSetup.Insert();

        BGFiscalizationSetup.Validate("BG SIS Fiscal Enabled", true);
        BGFiscalizationSetup.Modify();
    end;

    local procedure UpdatePOSAuditProfileOnPOSUnit(var POSUnit: Record "NPR POS Unit"; POSAuditProfileCode: Code[20])
    begin
        POSUnit."POS Audit Profile" := POSAuditProfileCode;
        POSUnit.Modify();
    end;

    local procedure SetVATPctOnVATPostingSetup(var VATPostingSetup: Record "VAT Posting Setup"; VATPct: Decimal)
    begin
        VATPostingSetup."VAT %" := VATPct;
        VATPostingSetup.Modify();
    end;

    local procedure InsertBGSISVATPostingMapping(var VATPostingSetup: Record "VAT Posting Setup")
    var
        BGSISVATPostSetupMap: Record "NPR BG SIS VAT Post. Setup Map";
    begin
        if not BGSISVATPostSetupMap.Get(VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group") then begin
            BGSISVATPostSetupMap.Init();
            BGSISVATPostSetupMap."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
            BGSISVATPostSetupMap."VAT Prod. Posting Group" := VATPostingSetup."VAT Prod. Posting Group";
            BGSISVATPostSetupMap."BG SIS VAT Category" := BGSISVATPostSetupMap."BG SIS VAT Category"::"B Category"; // general goods and services
            BGSISVATPostSetupMap.Insert();
        end;
    end;

    local procedure InsertBGSISPOSPaymentMethodMapping()
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
        BGSISPOSPaymMethMap: Record "NPR BG SIS POS Paym. Meth. Map";
    begin
        POSPaymentMethod.FindSet();
        repeat
            if not BGSISPOSPaymMethMap.Get(POSPaymentMethod.Code) then begin
                BGSISPOSPaymMethMap.Init();
                BGSISPOSPaymMethMap."POS Payment Method Code" := POSPaymentMethod.Code;
                BGSISPOSPaymMethMap."BG SIS Payment Method" := BGSISPOSPaymMethMap."BG SIS Payment Method"::Cash;
                BGSISPOSPaymMethMap.Insert();
            end;
        until POSPaymentMethod.Next() = 0;
    end;

    local procedure InsertBGSISReturnReasonMapping()
    var
        ReturnReason: Record "Return Reason";
        BGSISReturnReasonMap: Record "NPR BG SIS Return Reason Map";
    begin
        ReturnReason.FindSet();
        repeat
            if not BGSISReturnReasonMap.Get(ReturnReason.Code) then begin
                BGSISReturnReasonMap.Init();
                BGSISReturnReasonMap."Return Reason Code" := ReturnReason.Code;
                BGSISReturnReasonMap."BG SIS Return Reason" := BGSISReturnReasonMap."BG SIS Return Reason"::"Refund/Return";
                BGSISReturnReasonMap.Insert();
            end;
        until ReturnReason.Next() = 0;
    end;

    local procedure CreateNumberSeries(): Code[20]
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
        LibraryUtility: Codeunit "Library - Utility";
    begin
        LibraryUtility.CreateNoSeries(NoSeries, true, false, false);
        LibraryUtility.CreateNoSeriesLine(NoSeriesLine, NoSeries.Code, 'TEST_1', 'TEST_99999999');
        exit(NoSeries.Code);
    end;
}