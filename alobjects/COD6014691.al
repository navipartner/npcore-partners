codeunit 6014691 "Trigger Stargate Assembly Sync"
{
    // NPR5.23/MMV/20160526 CASE 241574 Created CU.
    // Can be called from a POS touch button to manually sync stargate assemblies as a temporary fix.


    trigger OnRun()
    var
        StargateDummyRequest: Codeunit "Stargate Dummy Request";
    begin
        StargateDummyRequest.RunRequest();
    end;

    var
        SyncTxt: Label 'Stargate assemblies synced successfully';
}

