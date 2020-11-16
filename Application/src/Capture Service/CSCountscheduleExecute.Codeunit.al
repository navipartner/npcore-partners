codeunit 6151346 "NPR CS Count. schedule Execute"
{
    // NPR5.53/CLVA  /20191125  CASE 377467 Object created - NP Capture Service

    TableNo = "NPR CS Counting schedule";

    trigger OnRun()
    var
        POSStore: Record "NPR POS Store";
        Location: Record Location;
        CSHelperFunctions: Codeunit "NPR CS Helper Functions";
    begin
        POSStore.Get(Rec."POS Store");
        Location.Get(POSStore."Location Code");
        CSHelperFunctions.CreateNewCountingV2(Location);
    end;
}

