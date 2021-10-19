codeunit 6059973 "NPR Variety Lookup Functions"
{
    TableNo = "NPR Variety Field Setup";

    trigger OnRun()
    begin
        case Rec."Function Identifier" of
            'ITEM_PER_LOCATION':
                ItemPerLocation(Rec);
        end;
    end;

    var
        BlankLocation: Label '<BLANK>';

    procedure ItemPerLocation(VRTFieldSetup: Record "NPR Variety Field Setup")
    var
        TempInvBuffer: Record "Inventory Buffer" temporary;
        Location: Record Location;
        Item: Record Item;
    begin
        Item.Get(VRTFieldSetup."Item No. (TMPParm)");
        Item.SetRange("Variant Filter", VRTFieldSetup."Variant Code (TMPParm)");
        if Location.FindSet(false, false) then
            repeat
                Item.SetRange("Location Filter", Location.Code);
                Item.CalcFields("Net Change");
                TempInvBuffer.Init();
                TempInvBuffer."Item No." := VRTFieldSetup."Item No. (TMPParm)";
                TempInvBuffer."Variant Code" := VRTFieldSetup."Variant Code (TMPParm)";
                TempInvBuffer."Location Code" := Location.Code;
                TempInvBuffer.Quantity := Item."Net Change";
                TempInvBuffer.Insert();
            until Location.Next() = 0;
        PAGE.RunModal(6059976, TempInvBuffer);
    end;

    procedure LookupTable()
    begin
    end;

    procedure LookupVarietyValues(Item: Record Item; VarietyNo: Option Variety1,Variety2,Variety3,Variety4)
    var
        VarietyValue: Record "NPR Variety Value";
    begin
        case VarietyNo of
            VarietyNo::Variety1:
                begin
                    VarietyValue.SetRange(Type, Item."NPR Variety 1");
                    VarietyValue.SetRange(Table, Item."NPR Variety 1 Table");
                end;
            VarietyNo::Variety2:
                begin
                    VarietyValue.SetRange(Type, Item."NPR Variety 2");
                    VarietyValue.SetRange(Table, Item."NPR Variety 2 Table");
                end;
            VarietyNo::Variety3:
                begin
                    VarietyValue.SetRange(Type, Item."NPR Variety 3");
                    VarietyValue.SetRange(Table, Item."NPR Variety 3 Table");
                end;
            VarietyNo::Variety4:
                begin
                    VarietyValue.SetRange(Type, Item."NPR Variety 4");
                    VarietyValue.SetRange(Table, Item."NPR Variety 4 Table");
                end;
        end;

        PAGE.RunModal(0, VarietyValue);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Variety Matrix Management", 'OnDrillDownEvent', '', false, false)]
    local procedure CU6059971_OnDrillDown(TMPVrtBuffer: Record "NPR Variety Buffer" temporary; VrtFieldSetup: Record "NPR Variety Field Setup")
    begin
        if not (VrtFieldSetup."OnDrillDown Codeunit ID" = CODEUNIT::"NPR Variety Lookup Functions") then
            exit;

        DrillDownItemsPerLocation(TMPVrtBuffer."Item No.", TMPVrtBuffer."Variant Code");
    end;

    local procedure DrillDownItemsPerLocation(ItemNo: Code[20]; VariantCode: Code[10])
    var
        TempInvBuffer: Record "Inventory Buffer" temporary;
        Location: Record Location;
        Item: Record Item;
    begin
        Item.Get(ItemNo);
        Item.SetRange("Variant Filter", VariantCode);
        if Location.FindSet(false, false) then
            repeat
                Item.SetRange("Location Filter", Location.Code);
                Item.CalcFields("Net Change");
                TempInvBuffer.Init();
                TempInvBuffer."Item No." := ItemNo;
                TempInvBuffer."Variant Code" := VariantCode;
                TempInvBuffer."Location Code" := Location.Code;
                TempInvBuffer.Quantity := Item."Net Change";
                TempInvBuffer.Insert();
            until Location.Next() = 0;
        Item.SetFilter("Location Filter", '');
        Item.CalcFields("Net Change");
        if Item."Net Change" <> 0 then begin
            TempInvBuffer.Init();
            TempInvBuffer."Item No." := ItemNo;
            TempInvBuffer."Variant Code" := VariantCode;
            TempInvBuffer."Location Code" := BlankLocation;
            TempInvBuffer.Quantity := Item."Net Change";
            TempInvBuffer.Insert();
        end;
        PAGE.RunModal(6059976, TempInvBuffer);
    end;
}

