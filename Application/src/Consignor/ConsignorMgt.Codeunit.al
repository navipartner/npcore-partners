codeunit 6184601 "NPR Consignor Mgt." implements "NPR IShipping Provider Interface"
{
    Access = Internal;
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

        NpXmlTemplate.SetRange("Table No.", DATABASE::"NPR Consignor Entry");
        NpXmlTemplate.SetRange("Transaction Task", true);
        NpXmlTemplate.SetFilter("Task Processor Code", '<>%1', '');
        if not NpXmlTemplate.FindFirst() then
            exit;

        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", CODEUNIT::"NPR Nc Task List Processing");
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
        message(Text001);
    end;

    Procedure SendDocument(var ShipmentDocument: Record "NPR shipping provider Document")
    begin
        message(Text001);
    end;

    procedure PrintDocument(var ShipmentDocument: Record "NPR shipping provider Document")
    begin
        message(Text001);
    end;

    procedure PrintShipmentDocument(var SalesShipmentHeader: Record "Sales Shipment Header")
    begin
        message(Text001);
    end;

    var
        Text001: Label 'Not available for Consignor';
}
