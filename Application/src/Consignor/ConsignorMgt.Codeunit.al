codeunit 6184601 "NPR Consignor Mgt." implements "NPR IShipping Provider Interface"
{
    Access = Internal;

    var
        PackageProviderSetup: Record "NPR Shipping Provider Setup";
        PackageMgt: Codeunit "NPR Package Management";
        Text001: Label 'Not available for Consignor';

    [EventSubscriber(ObjectType::Table, Database::"NPR Consignor Entry", 'OnAfterInsertEvent', '', true, true)]
    local procedure OnAfterInsertConsignorEntry(var Rec: Record "NPR Consignor Entry"; RunTrigger: Boolean)
    begin
        if not RunTrigger then
            exit;
        if Rec.IsTemporary then
            exit;

        ScheduleJobQueueEntries();
    end;

    local procedure ScheduleJobQueueEntries()
    var
        JobQueueEntry: Record "Job Queue Entry";
        NpXmlTemplate: Record "NPR NpXml Template";
        JobQueueMgt: Codeunit "NPR Job Queue Management";
    begin
        if not JobQueueEntry.WritePermission then
            exit;

        NpXmlTemplate.SetRange("Table No.", Database::"NPR Consignor Entry");
        NpXmlTemplate.SetRange("Transaction Task", true);
        NpXmlTemplate.SetFilter("Task Processor Code", '<>%1', '');
        if not NpXmlTemplate.FindFirst() then
            exit;

        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"NPR Nc Task List Processing");
        JobQueueEntry.SetFilter("Parameter String", '*processor?' + NpXmlTemplate."Task Processor Code" + '*');
        if JobQueueEntry.IsEmpty then
            exit;

        JobQueueEntry.FindSet();
        repeat
            JobQueueMgt.StartJobQueueEntry(JobQueueEntry, JobQueueMgt.NowWithDelayInSeconds(1));
        until JobQueueEntry.Next() = 0;
    end;

    procedure CheckBalance()
    begin
        Message(Text001);
    end;

    procedure SendDocument(var ShipmentDocument: Record "NPR Shipping Provider Document")
    begin
        Message(Text001);
    end;

    procedure PrintDocument(var ShipmentDocument: Record "NPR Shipping Provider Document")
    begin
        Message(Text001);
    end;

    procedure PrintShipmentDocument(var SalesShipmentHeader: Record "Sales Shipment Header")
    var
        ConsignorEntry: Record "NPR Consignor Entry";
    begin
        ConsignorEntry.InsertFromShipmentHeader(SalesShipmentHeader."No.");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterPostSalesDoc', '', false, false)]
    local procedure C80OnAfterPostSalesDoc(var SalesHeader: Record "Sales Header"; var GenJnlPostLine: codeunit "Gen. Jnl.-Post Line"; SalesShptHdrNo: Code[20]; RetRcpHdrNo: Code[20]; SalesInvHdrNo: Code[20]; SalesCrMemoHdrNo: Code[20]);
    var
        SalesShptHeader: Record "Sales Shipment Header";
        SalesSetup: Record "Sales & Receivables Setup";
        ShipmentDocument: Record "NPR Shipping Provider Document";
        ConsignorEntry: Record "NPR Consignor Entry";
        RecRef: RecordRef;

    begin
        if not InitPackageProvider() then
            exit;

        if not SalesHeader.Ship then
            exit;

        if (SalesHeader."Document Type" = SalesHeader."Document Type"::Order) or
            ((SalesHeader."Document Type" = SalesHeader."Document Type"::Invoice) and SalesSetup."Shipment on Invoice") then begin
            if SalesShptHeader.Get(SalesShptHdrNo) then begin
                RecRef.GetTable(SalesShptHeader);
                PackageMgt.PostDimension(RecRef);
                PackageMgt.AddEntry(RecRef, GuiAllowed, false, ShipmentDocument);
                ConsignorEntry.InsertFromShipmentHeader(SalesShptHeader."No.");

            end;
        end;
    end;

    local procedure InitPackageProvider(): Boolean;
    begin
        if not PackageProviderSetup.Get() then
            exit(false);

        if not PackageProviderSetup."Enable Shipping" then
            exit(false);

        if PackageProviderSetup."Shipping Provider" <> PackageProviderSetup."Shipping Provider"::Consignor then
            exit(false);

        exit(true);
    end;

}
