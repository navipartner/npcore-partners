codeunit 6151346 "CS Counting schedule Execute"
{
    // NPR5.53/CLVA  /20191125  CASE 377467 Object created - NP Capture Service

    TableNo = "CS Counting schedule";

    trigger OnRun()
    var
        POSStore: Record "POS Store";
        Location: Record Location;
        CSHelperFunctions: Codeunit "CS Helper Functions";
    begin
        POSStore.Get(Rec."POS Store");
        Location.Get(POSStore."Location Code");
        CSHelperFunctions.CreateNewCountingV2(Location);
    end;
}

