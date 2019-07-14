tableextension 50075 tableextension50075 extends "Inventory Profile" 
{
    // NPR5.38.01/JKL/20180112/ Case 289017 added function TransferFromRetailReplnmDemand
    // NPR5.40/TJ  /20180303  CASE 307053 Removed function separator <<--NP FUNC--> and renumbered function TransferFromRetailReplnmDemand from id 25

    procedure TransferFromRetailReplnmDemand(var ReplenishmentDemandLine: Record "Retai Repl. Demand Line")
    begin
        //-NPR5.40 [289017]
        ReplenishmentDemandLine.TestField("Item No.");
        "Source Type" := 0;
        "Source ID" := Format(ReplenishmentDemandLine."Entry No.");
        "Item No." := ReplenishmentDemandLine."Item No.";
        "Variant Code" := ReplenishmentDemandLine."Variant Code";
        "Location Code" := ReplenishmentDemandLine."Location Code";
        "Bin Code" := ReplenishmentDemandLine."Bin Code";
        "Untracked Quantity" := ReplenishmentDemandLine."Demanded Quantity";
        Quantity := ReplenishmentDemandLine."Demanded Quantity";
        "Remaining Quantity" := ReplenishmentDemandLine."Demanded Quantity";
        "Quantity (Base)" := ReplenishmentDemandLine."Quantity (Base)";
        "Remaining Quantity (Base)" := ReplenishmentDemandLine."Quantity (Base)";
        "Unit of Measure Code" := ReplenishmentDemandLine."Unit of Measure Code";
        "Qty. per Unit of Measure" := ReplenishmentDemandLine."Qty. per Unit of Measure";
        IsSupply := "Untracked Quantity" < 0;
        "Due Date" := ReplenishmentDemandLine."Due Date";
        "Planning Flexibility" := "Planning Flexibility"::None;
        "Order Priority" := 1000;
        //+NPR5.40 [289017]
    end;
}

