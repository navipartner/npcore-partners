codeunit 6059896 "NPR Data Log Processing Mgt."
{
    TableNo = "NPR Data Log Processing Entry";

    trigger OnRun()
    begin
        RunDataLogProcessing(Rec);
    end;

    procedure RunDataLogProcessing(var DataLogProcessingEntry: Record "NPR Data Log Processing Entry")
    var
        DataLogSubscriber: Record "NPR Data Log Subscriber";
        DataLogRecord: Record "NPR Data Log Record";
    begin
        DataLogProcessingEntry."Processing Started at" := CurrentDateTime;
        DataLogProcessingEntry.Modify(true);
        Commit();

        DataLogSubscriber.Get(DataLogProcessingEntry."Subscriber Code", DataLogProcessingEntry."Table Number", '');
        DataLogSubscriber.TestField("Data Processing Codeunit ID");
        DataLogRecord.Get(DataLogProcessingEntry."Data Log Entry No.");
        CODEUNIT.Run(DataLogSubscriber."Data Processing Codeunit ID", DataLogRecord);

        DataLogProcessingEntry."Processing Completed at" := CurrentDateTime;
        DataLogProcessingEntry.Modify(true);
        Commit();
    end;
}