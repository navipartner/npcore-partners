codeunit 85065 "NPR Library RS Fiscal"
{
    procedure CreateAuditProfileAndRSSetup(var POSAuditProfile: Record "NPR POS Audit Profile"; var VATPostingSetup: Record "VAT Posting Setup"; var POSUnit: Record "NPR POS Unit")
    var
        NoSeriesLine: Record "No. Series Line";
        POSPaymentMethod: Record "NPR POS Payment Method";
        POSStore: Record "NPR POS Store";
        RSFiscalisationSetup: Record "NPR RS Fiscalisation Setup";
        RSPaymentMethodMapping: Record "NPR RS Payment Method Mapping";
        RSPOSPaymMethMapping: Record "NPR RS POS Paym. Meth. Mapping";
        RSPOSUnitMapping: Record "NPR RS POS Unit Mapping";
        RSVATPostSetupMapping: Record "NPR RS VAT Post. Setup Mapping";
        PaymentMethod: Record "Payment Method";
        RSTaxCommunicationMgt: Codeunit "NPR RS Tax Communication Mgt.";

    begin
        POSAuditProfile.Init();
        POSAuditProfile.Code := HandlerCode();
        POSAuditProfile."Allow Printing Receipt Copy" := POSAuditProfile."Allow Printing Receipt Copy"::Always;
        POSAuditProfile."Audit Handler" := HandlerCode();
        POSAuditProfile."Audit Log Enabled" := true;
        POSAuditProfile."Fill Sale Fiscal No. On" := POSAuditProfile."Fill Sale Fiscal No. On"::Successful;
        POSAuditProfile."Balancing Fiscal No. Series" := CreateNumberSeries();
        POSAuditProfile."Sale Fiscal No. Series" := CreateNumberSeries();
        POSAuditProfile."Sales Ticket No. Series" := CreateNumberSeries();
        POSAuditProfile."Credit Sale Fiscal No. Series" := CreateNumberSeries();
        NoSeriesLine.SetRange("Series Code", POSAuditProfile."Sales Ticket No. Series");
        NoSeriesLine.SetRange(Open, true);
        NoSeriesLine.FindLast();
        NoSeriesLine.Validate("Allow Gaps in Nos.", true);
        NoSeriesLine.Modify();
        POSAuditProfile.Insert();
        POSUnit."POS Audit Profile" := POSAuditProfile.Code;
        POSUnit.Modify();

        RSPOSUnitMapping.Init();
        RSPOSUnitMapping."POS Unit Code" := POSUnit."No.";
        RSPOSUnitMapping."RS Sandbox Token" := '4e3f2b87-9353-41f9-b53a-4efe640280f2';
        RSPOSUnitMapping."RS Sandbox PIN" := 7766;
        RSPOSUnitMapping."RS Sandbox JID" := 'YJLQTEQR';
        RSPOSUnitMapping.Insert();

        VATPostingSetup."VAT %" := 9;
        VATPostingSetup.Modify();
        if not RSVATPostSetupMapping.Get(VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group") then begin
            RSVATPostSetupMapping.Init();
            RSVATPostSetupMapping."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
            RSVATPostSetupMapping."VAT Prod. Posting Group" := VATPostingSetup."VAT Prod. Posting Group";
            RSVATPostSetupMapping."RS Tax Category Name" := 'VAT';
            RSVATPostSetupMapping."RS Tax Category Label" := 'A';
            RSVATPostSetupMapping.Insert();
        end;

        POSPaymentMethod.FindSet();
        repeat
            if not RSPOSPaymMethMapping.Get(POSPaymentMethod.Code) then begin
                RSPOSPaymMethMapping.Init();
                RSPOSPaymMethMapping."POS Payment Method Code" := POSPaymentMethod.Code;
                RSPOSPaymMethMapping."RS Payment Method" := RSPOSPaymMethMapping."RS Payment Method"::Other;
                RSPOSPaymMethMapping.Insert();
            end;
        until POSPaymentMethod.Next() = 0;

        PaymentMethod.FindSet();
        repeat
            if not RSPaymentMethodMapping.Get(PaymentMethod.Code) then begin
                RSPaymentMethodMapping.Init();
                RSPaymentMethodMapping."Payment Method Code" := PaymentMethod.Code;
                RSPaymentMethodMapping."RS Payment Method" := RSPaymentMethodMapping."RS Payment Method"::Other;
                RSPaymentMethodMapping.Insert();
            end;
        until PaymentMethod.Next() = 0;

        RSFiscalisationSetup.DeleteAll();
        RSFiscalisationSetup.Init();
        RSFiscalisationSetup.Validate("Enable RS Fiscal", true);
        RSFiscalisationSetup."Report E-Mail Selection" := RSFiscalisationSetup."Report E-Mail Selection"::Both;
        RSFiscalisationSetup."Sandbox URL" := 'http://devesdc.sandbox.suf.purs.gov.rs:8888';
        RSFiscalisationSetup."Configuration URL" := 'https://api.sandbox.suf.purs.gov.rs/';
        RSFiscalisationSetup.Insert();

        RSTaxCommunicationMgt.PullAndFillSUFConfiguration();
        RSTaxCommunicationMgt.PullAndFillAllowedTaxRates();

        POSStore.Get(POSUnit."POS Store Code");
        POSStore."Registration No." := 'Test';
        POSStore."Country/Region Code" := 'RS';
        POSStore.Modify();
    end;

    procedure CreateNumberSeries(): Text
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
        LibraryUtility: Codeunit "Library - Utility";
    begin
        LibraryUtility.CreateNoSeries(NoSeries, true, false, false);
        LibraryUtility.CreateNoSeriesLine(NoSeriesLine, NoSeries.Code, 'TEST_1', 'TEST_99999999');
        exit(NoSeries.Code);
    end;

    procedure HandlerCode(): Text
    var
        HandlerCodeTxt: Label 'RS_FISKALIZACIJA', Locked = true, MaxLength = 20;
    begin
        exit(HandlerCodeTxt);
    end;
}