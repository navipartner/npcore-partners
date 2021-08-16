codeunit 85040 "NPR Library FR NF525"
{
    procedure CreateAuditProfileAndFRSetup(var POSAuditProfile: Record "NPR POS Audit Profile"; ItemVATIdentifierFilter: Text; var POSUnit: Record "NPR POS Unit")
    var
        FRAuditSetup: Record "NPR FR Audit Setup";
        FRAuditNoSeries: Record "NPR FR Audit No. Series";
        TempBlob: Codeunit "Temp Blob";
        RecRef: RecordRef;
        DateFormulaVariable: DateFormula;
        OutStream: OutStream;
        InStream: InStream;
        test: integer;
        test2: Boolean;
        NoSeriesLine: Record "No. Series Line";
        POSStore: Record "NPR POS Store";
    begin
        POSAuditProfile.Init();
        POSAuditProfile.Code := 'NF525_TEST';
        POSAuditProfile."Allow Printing Receipt Copy" := POSAuditProfile."Allow Printing Receipt Copy"::Always;
        POSAuditProfile."Allow Zero Amount Sales" := false;
        POSAuditProfile."Audit Handler" := 'FR_NF525';
        POSAuditProfile."Audit Log Enabled" := true;
        POSAuditProfile."Print Receipt On Sale Cancel" := false;
        POSAuditProfile."Fill Sale Fiscal No. On" := POSAuditProfile."Fill Sale Fiscal No. On"::Successful;
        POSAuditProfile."Require Item Return Reason" := true;
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

        GetTestCert(TempBlob);

        FRAuditSetup.DeleteAll();
        FRAuditSetup.Init;
        FRAuditSetup."Auto Archive URL" := 'http://localhost';
        FRAuditSetup."Auto Archive SAS" := 'N/A';
        FRAuditSetup."Auto Archive API Key" := 'N/A';
        FRAuditSetup.SetVATIDFilter(ItemVATIdentifierFilter);
        TempBlob.CreateInStream(InStream);
        FRAuditSetup."Signing Certificate".CreateOutStream(OutStream);
        CopyStream(OutStream, InStream);

        FRAuditSetup."Signing Certificate Password" := GetTestCertPassword();
        FRAuditSetup."Signing Certificate Thumbprint" := GetTestCertThumbprint();

        Evaluate(DateFormulaVariable, '1M');
        FRAuditSetup."Monthly Workshift Duration" := DateFormulaVariable;
        Evaluate(DateFormulaVariable, '1Y');
        FRAuditSetup."Yearly Workshift Duration" := DateFormulaVariable;
        FRAuditSetup.Insert();

        FRAuditNoSeries.Init();
        FRAuditNoSeries."POS Unit No." := POSUnit."No.";
        FRAuditNoSeries."Grand Period No. Series" := CreateNumberSeries();
        FRAuditNoSeries."JET No. Series" := CreateNumberSeries();
        FRAuditNoSeries."Period No. Series" := CreateNumberSeries();
        FRAuditNoSeries."Reprint No. Series" := CreateNumberSeries();
        FRAuditNoSeries."Yearly Period No. Series" := CreateNumberSeries();
        FRAuditNoSeries.Insert();

        POSStore.Get(POSUnit."POS Store Code");
        POSStore."Registration No." := 'Test';
        POSStore."Country/Region Code" := 'FR';
        POSStore.Modify();
    end;

    procedure CreateNumberSeries(): Text
    var
        LibraryUtility: Codeunit "Library - Utility";
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        LibraryUtility.CreateNoSeries(NoSeries, true, false, false);
        LibraryUtility.CreateNoSeriesLine(NoSeriesLine, NoSeries.Code, 'TEST_1', 'TEST_99999999');
        exit(NoSeries.Code);
    end;

    procedure GetTestCert(var TempBlob: Codeunit "Temp Blob");
    var
        Base64: Codeunit "Base64 Convert";
        ReadBase64File: Codeunit "Read File in Base64 Encoding";
        OStream: OutStream;
    begin
        TempBlob.CreateOutStream(OStream, TextEncoding::UTF8);
        base64.FromBase64('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', OStream);
    end;


    procedure GetTestCertPassword(): Text
    begin
        exit('vivelafrance');
    end;

    procedure GetTestCertThumbprint(): Text
    begin
        exit('1A7D023966670E053A3F7F967813574E31A940F2');
    end;
}