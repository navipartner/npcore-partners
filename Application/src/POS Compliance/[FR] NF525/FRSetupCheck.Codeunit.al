codeunit 6184889 "NPR FR Setup Check"
{
    Access = Internal;

    trigger OnRun()
    var
        POSEntry: Record "NPR POS Entry";
        POSAuditLog: Record "NPR POS Audit Log";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSEntryPaymentLine: Record "NPR POS Entry Payment Line";
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        NoSeriesLine: Record "No. Series Line";
    begin
        //Cleanup
        POSEntry.DeleteAll();
        POSAuditLog.DeleteAll();
        POSEntrySalesLine.DeleteAll();
        POSEntryPaymentLine.DeleteAll();
        POSWorkshiftCheckpoint.DeleteAll();

        //No. Series initial value
        NoSeriesLine.SetFilter("Starting No.", '<>%1', '');
        if not NoSeriesLine.FindSet() then
            exit;
        repeat
            NoSeriesLine."Last No. Used" := NoSeriesLine."Starting No.";
            NoSeriesLine.Modify();
        until NoSeriesLine.Next() = 0;
    end;

    procedure RunCheck()
    var
        POSUnit: Record "NPR POS Unit";
        POSAuditLog: Record "NPR POS Audit Log";
        POSSession: Codeunit "NPR POS Session";
        POSSetup: Codeunit "NPR POS Setup";
        FRAuditSetup: Record "NPR FR Audit Setup";
        FRAuditNoSeries: Record "NPR FR Audit No. Series";
        POSEndofDayProfile: Record "NPR POS End of Day Profile";
        POSAuditProfile: Record "NPR POS Audit Profile";
        FRAuditNoSeries2: Record "NPR FR Audit No. Series";
        POSStore: Record "NPR POS Store";
        CompanyInformation: Record "Company Information";
        RecRef: RecordRef;
        FieldRef: FieldRef;
        VATIDFilter: Text;
        NoVATIDFilterErr: Label '%1 must not be empty.';
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        FRAuditMgt: Codeunit "NPR FR Audit Mgt.";
        ERROR_JET_INIT: Label 'JET has not been initialized for %1 %2. This must be done to comply with french NF525 regulations.';
        ReportSelectionRetail: Record "NPR Report Selection Retail";
        BigInt: BigInteger;
        NumberValue: Text;
    begin
        //Error upon POS login if any configuration is missing or clearly not set according to compliance

        POSSession.GetSetup(POSSetup);
        POSSetup.GetPOSUnit(POSUnit);
        if not FRAuditMgt.IsEnabled(POSUnit."POS Audit Profile") then
            exit;

        if not FRAuditMgt.GetJETInitRecord(POSAuditLog, POSUnit."No.", false) then
            Error(ERROR_JET_INIT, POSUnit.TableCaption, POSUnit."No.");

        FRAuditSetup.Get();
        FRAuditSetup.TestField("Monthly Workshift Duration");
        FRAuditSetup.TestField("Yearly Workshift Duration");
        FRAuditSetup.TestField("Signing Certificate Thumbprint");

        VATIDFilter := FRAuditSetup.GetItemVATIDFilter();
        if VATIDFilter = '' then
            Error(NoVATIDFilterErr, FRAuditSetup.FieldCaption("Item VAT ID Filter"));

        FRAuditNoSeries.Get(POSUnit."No.");
        FRAuditNoSeries.TestField("Reprint No. Series");
        NoSeries.Get(FRAuditNoSeries."Reprint No. Series");
        NoSeriesManagement.SetNoSeriesLineFilter(NoSeriesLine, FRAuditNoSeries."Reprint No. Series", Today);
        NoSeriesLine.FindFirst();
        NoSeriesLine.TestField("Allow Gaps in Nos.", false);
        NumberValue := NoSeriesLine."Last No. Used";
        if NumberValue = '' then
            NumberValue := NoSeriesLine."Starting No.";
        if not Evaluate(BigInt, NumberValue) then
            NoSeriesLine.FieldError("Last No. Used");

        FRAuditNoSeries.TestField("JET No. Series");
        NoSeries.Get(FRAuditNoSeries."JET No. Series");
        NoSeriesManagement.SetNoSeriesLineFilter(NoSeriesLine, FRAuditNoSeries."JET No. Series", Today);
        NoSeriesLine.FindFirst();
        NoSeriesLine.TestField("Allow Gaps in Nos.", false);
        NumberValue := NoSeriesLine."Last No. Used";
        if NumberValue = '' then
            NumberValue := NoSeriesLine."Starting No.";
        if not Evaluate(BigInt, NumberValue) then
            NoSeriesLine.FieldError("Last No. Used");

        FRAuditNoSeries.TestField("Period No. Series");
        NoSeries.Get(FRAuditNoSeries."Period No. Series");
        NoSeriesManagement.SetNoSeriesLineFilter(NoSeriesLine, FRAuditNoSeries."Period No. Series", Today);
        NoSeriesLine.FindFirst();
        NoSeriesLine.TestField("Allow Gaps in Nos.", false);
        NumberValue := NoSeriesLine."Last No. Used";
        if NumberValue = '' then
            NumberValue := NoSeriesLine."Starting No.";
        if not Evaluate(BigInt, NumberValue) then
            NoSeriesLine.FieldError("Last No. Used");

        FRAuditNoSeries.TestField("Grand Period No. Series");
        NoSeries.Get(FRAuditNoSeries."Grand Period No. Series");
        NoSeriesManagement.SetNoSeriesLineFilter(NoSeriesLine, FRAuditNoSeries."Grand Period No. Series", Today);
        NoSeriesLine.FindFirst();
        NoSeriesLine.TestField("Allow Gaps in Nos.", false);
        NumberValue := NoSeriesLine."Last No. Used";
        if NumberValue = '' then
            NumberValue := NoSeriesLine."Starting No.";
        if not Evaluate(BigInt, NumberValue) then
            NoSeriesLine.FieldError("Last No. Used");

        FRAuditNoSeries.TestField("Yearly Period No. Series");
        NoSeries.Get(FRAuditNoSeries."Yearly Period No. Series");
        NoSeriesManagement.SetNoSeriesLineFilter(NoSeriesLine, FRAuditNoSeries."Yearly Period No. Series", Today);
        NoSeriesLine.FindFirst();
        NoSeriesLine.TestField("Allow Gaps in Nos.", false);
        NumberValue := NoSeriesLine."Last No. Used";
        if NumberValue = '' then
            NumberValue := NoSeriesLine."Starting No.";
        if not Evaluate(BigInt, NumberValue) then
            NoSeriesLine.FieldError("Last No. Used");

        FRAuditNoSeries2.SetFilter("POS Unit No.", '<>%1', POSUnit."No.");

        FRAuditNoSeries2.SetRange("Reprint No. Series", FRAuditNoSeries."Reprint No. Series");
        if not FRAuditNoSeries2.IsEmpty then
            FRAuditNoSeries.FieldError("Reprint No. Series");
        FRAuditNoSeries2.SetRange("Reprint No. Series");

        FRAuditNoSeries2.SetRange("JET No. Series", FRAuditNoSeries."JET No. Series");
        if not FRAuditNoSeries2.IsEmpty then
            FRAuditNoSeries.FieldError("JET No. Series");
        FRAuditNoSeries2.SetRange("JET No. Series");

        FRAuditNoSeries2.SetRange("Period No. Series", FRAuditNoSeries."Period No. Series");
        if not FRAuditNoSeries2.IsEmpty then
            FRAuditNoSeries.FieldError("Period No. Series");
        FRAuditNoSeries2.SetRange("Period No. Series");

        FRAuditNoSeries2.SetRange("Grand Period No. Series", FRAuditNoSeries."Grand Period No. Series");
        if not FRAuditNoSeries2.IsEmpty then
            FRAuditNoSeries.FieldError("Grand Period No. Series");
        FRAuditNoSeries2.SetRange("Grand Period No. Series");

        FRAuditNoSeries2.SetRange("Yearly Period No. Series", FRAuditNoSeries."Yearly Period No. Series");
        if not FRAuditNoSeries2.IsEmpty then
            FRAuditNoSeries.FieldError("Yearly Period No. Series");
        FRAuditNoSeries2.SetRange("Yearly Period No. Series");

        POSAuditProfile.Get(POSUnit."POS Audit Profile");

        POSAuditProfile.TestField("Sale Fiscal No. Series");
        NoSeries.Get(POSAuditProfile."Sale Fiscal No. Series");
        NoSeriesManagement.SetNoSeriesLineFilter(NoSeriesLine, POSAuditProfile."Sale Fiscal No. Series", Today);
        NoSeriesLine.FindFirst();
        NoSeriesLine.TestField("Allow Gaps in Nos.", false);
        NumberValue := NoSeriesLine."Last No. Used";
        if NumberValue = '' then
            NumberValue := NoSeriesLine."Starting No.";
        if not Evaluate(BigInt, NumberValue) then
            NoSeriesLine.FieldError("Last No. Used");

        POSAuditProfile.TestField("Credit Sale Fiscal No. Series");
        NoSeries.Get(POSAuditProfile."Credit Sale Fiscal No. Series");
        NoSeriesManagement.SetNoSeriesLineFilter(NoSeriesLine, POSAuditProfile."Credit Sale Fiscal No. Series", Today);
        NoSeriesLine.FindFirst();
        NoSeriesLine.TestField("Allow Gaps in Nos.", false);
        NumberValue := NoSeriesLine."Last No. Used";
        if NumberValue = '' then
            NumberValue := NoSeriesLine."Starting No.";
        if not Evaluate(BigInt, NumberValue) then
            NoSeriesLine.FieldError("Last No. Used");

        POSAuditProfile.TestField("Balancing Fiscal No. Series");
        NoSeries.Get(POSAuditProfile."Balancing Fiscal No. Series");
        NoSeriesManagement.SetNoSeriesLineFilter(NoSeriesLine, POSAuditProfile."Balancing Fiscal No. Series", Today);
        NoSeriesLine.FindFirst();
        NoSeriesLine.TestField("Allow Gaps in Nos.", false);
        NumberValue := NoSeriesLine."Last No. Used";
        if NumberValue = '' then
            NumberValue := NoSeriesLine."Starting No.";
        if not Evaluate(BigInt, NumberValue) then
            NoSeriesLine.FieldError("Last No. Used");

        POSAuditProfile.TestField("Fill Sale Fiscal No. On", POSAuditProfile."Fill Sale Fiscal No. On"::Successful);
        POSAuditProfile.TestField("Print Receipt On Sale Cancel", false);
        POSAuditProfile.TestField("Allow Zero Amount Sales", false);
        POSAuditProfile.TestField("Allow Printing Receipt Copy", POSAuditProfile."Allow Printing Receipt Copy"::Always);
        POSAuditProfile.TestField("Require Item Return Reason", true);

        POSEndofDayProfile.Get(POSUnit."POS End of Day Profile");
        POSEndofDayProfile.TestField(POSEndofDayProfile."End of Day Type", POSEndofDayProfile."End of Day Type"::INDIVIDUAL);
        POSEndofDayProfile.TestField(POSEndofDayProfile."End of Day Frequency", POSEndofDayProfile."End of Day Frequency"::DAILY);

        POSStore.Get(POSUnit."POS Store Code");
        POSStore.TestField("Registration No."); //siret
        POSStore.TestField("Country/Region Code");
        POSStore.TestField(Name);
        POSStore.TestField(Address);

        CompanyInformation.Get();
        CompanyInformation.TestField("VAT Registration No.");
        RecRef.GetTable(CompanyInformation);
        if RecRef.FieldExist(10802) then begin
            FieldRef := RecRef.Field(10802);
            FieldRef.TestField();
        end;

        ReportSelectionRetail.SetRange("Report Type", ReportSelectionRetail."Report Type"::"Sales Receipt (POS Entry)");
        ReportSelectionRetail.SetRange("Print Template", 'EPSON_RECEIPT_FR');
        ReportSelectionRetail.FindFirst();

        ReportSelectionRetail.SetRange("Report Type", ReportSelectionRetail."Report Type"::"Balancing (POS Entry)");
        ReportSelectionRetail.SetRange("Print Template", 'EPSON_Z_REPORT_FR');
        ReportSelectionRetail.FindFirst();
    end;
}