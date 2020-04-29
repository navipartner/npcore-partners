codeunit 6059973 "Variety Lookup Functions"
{
    // NPR5.28/JDH /20161128 CASE 255961 Lookup of Inventory per Variant added

    TableNo = "Variety Field Setup";

    trigger OnRun()
    begin
        case "Function Identifier" of
          'ITEM_PER_LOCATION': ItemPerLocation(Rec);
        end;
    end;

    var
        BlankLocation: Label '<BLANK>';

    procedure ItemPerLocation(VRTFieldSetup: Record "Variety Field Setup")
    var
        TMPInvBuffer: Record "Inventory Buffer" temporary;
        Location: Record Location;
        Item: Record Item;
    begin
        Item.Get(VRTFieldSetup."Item No. (TMPParm)");
        Item.SetRange("Variant Filter", VRTFieldSetup."Variant Code (TMPParm)");
        if Location.FindSet(false, false) then repeat
          Item.SetRange("Location Filter", Location.Code);
          Item.CalcFields("Net Change");
          TMPInvBuffer.Init;
          TMPInvBuffer."Item No." := VRTFieldSetup."Item No. (TMPParm)";
          TMPInvBuffer."Variant Code" := VRTFieldSetup."Variant Code (TMPParm)";
          TMPInvBuffer."Location Code" := Location.Code;
          TMPInvBuffer.Quantity := Item."Net Change";
          TMPInvBuffer.Insert;
        until Location.Next = 0;
        PAGE.RunModal(6059976, TMPInvBuffer);
    end;

    procedure LookupTable()
    begin
    end;

    procedure LookupVarietyValues(Item: Record Item;VarietyNo: Option Variety1,Variety2,Variety3,Variety4)
    var
        VarietyValue: Record "Variety Value";
    begin
        case VarietyNo of
          VarietyNo::Variety1:
            begin
              VarietyValue.SetRange(Type, Item."Variety 1");
              VarietyValue.SetRange(Table, Item."Variety 1 Table");
            end;
          VarietyNo::Variety2:
            begin
              VarietyValue.SetRange(Type, Item."Variety 2");
              VarietyValue.SetRange(Table, Item."Variety 2 Table");
            end;
          VarietyNo::Variety3:
            begin
              VarietyValue.SetRange(Type, Item."Variety 3");
              VarietyValue.SetRange(Table, Item."Variety 3 Table");
            end;
          VarietyNo::Variety4:
            begin
              VarietyValue.SetRange(Type, Item."Variety 4");
              VarietyValue.SetRange(Table, Item."Variety 4 Table");
            end;
        end;

        PAGE.RunModal(0, VarietyValue);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6059971, 'OnDrillDownEvent', '', false, false)]
    local procedure CU6059971_OnDrillDown(TMPVrtBuffer: Record "Variety Buffer" temporary;VrtFieldSetup: Record "Variety Field Setup")
    begin
        //-NPR5.28 [255961]
        if not (VrtFieldSetup."OnDrillDown Codeunit ID" = CODEUNIT::"Variety Lookup Functions") then
          exit;

        DrillDownItemsPerLocation(TMPVrtBuffer."Item No.", TMPVrtBuffer."Variant Code");
        //+NPR5.28 [255961]
    end;

    local procedure DrillDownItemsPerLocation(ItemNo: Code[20];VariantCode: Code[10])
    var
        TMPInvBuffer: Record "Inventory Buffer" temporary;
        Location: Record Location;
        Item: Record Item;
    begin
        //-NPR5.28 [255961]
        Item.Get(ItemNo);
        Item.SetRange("Variant Filter", VariantCode);
        if Location.FindSet(false, false) then repeat
          Item.SetRange("Location Filter", Location.Code);
          Item.CalcFields("Net Change");
          TMPInvBuffer.Init;
          TMPInvBuffer."Item No." := ItemNo;
          TMPInvBuffer."Variant Code" := VariantCode;
          TMPInvBuffer."Location Code" := Location.Code;
          TMPInvBuffer.Quantity := Item."Net Change";
          TMPInvBuffer.Insert;
        until Location.Next = 0;
        Item.SetFilter("Location Filter", '');
        Item.CalcFields("Net Change");
        if Item."Net Change" <> 0 then begin
          TMPInvBuffer.Init;
          TMPInvBuffer."Item No." := ItemNo;
          TMPInvBuffer."Variant Code" := VariantCode;
          TMPInvBuffer."Location Code" := BlankLocation;
          TMPInvBuffer.Quantity := Item."Net Change";
          TMPInvBuffer.Insert;
        end;
        PAGE.RunModal(6059976, TMPInvBuffer);
        //+NPR5.28 [255961]
    end;
}

