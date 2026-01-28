codeunit 6014400 "NPR Default Dimension Mgt."
{
    Access = Internal;

#if BC17 or BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Codeunit, Codeunit::DimensionManagement, 'OnAfterSetupObjectNoList', '', true, false)]
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::DimensionManagement, OnAfterSetupObjectNoList, '', true, false)]
#endif
    local procedure DimensionMgtOnLoadDimensions(var TempAllObjWithCaption: Record AllObjWithCaption temporary)
    var
        DimMgt: Codeunit DimensionManagement;
    begin
        DimMgt.InsertObject(TempAllObjWithCaption, Database::"Item Category");
        DimMgt.InsertObject(TempAllObjWithCaption, Database::"NPR Mixed Discount");
        DimMgt.InsertObject(TempAllObjWithCaption, Database::"NPR Period Discount");
        DimMgt.InsertObject(TempAllObjWithCaption, Database::"NPR Quantity Discount Header");
        DimMgt.InsertObject(TempAllObjWithCaption, Database::"NPR POS Store");
        DimMgt.InsertObject(TempAllObjWithCaption, Database::"NPR POS Unit");
        DimMgt.InsertObject(TempAllObjWithCaption, Database::"NPR NPRE Seating");
        DimMgt.InsertObject(TempAllObjWithCaption, Database::"NPR MM Recur. Paym. Setup");
    end;

    procedure UpdateGlobalDimCode(GlobalDimCodeNo: Integer; "Table ID": Integer; "No.": Code[20]; NewDimValue: Code[20])
    begin
        case "Table ID" of
            Database::"Item Category":
                UpdateItemCategoryGlobalDimCode(GlobalDimCodeNo, "No.", NewDimValue);
            Database::"NPR Mixed Discount":
                UpdateMixedDiscountGlobalDimCode(GlobalDimCodeNo, "No.", NewDimValue);
            Database::"NPR Period Discount":
                UpdatePeriodDiscountGlobalDimCode(GlobalDimCodeNo, "No.", NewDimValue);
            Database::"NPR Quantity Discount Header":
                UpdateQuantityDiscountGlobalDimCode(GlobalDimCodeNo, "No.", NewDimValue);
            Database::"NPR POS Store":
                UpdatePOSStoreGlobalDimCode(GlobalDimCodeNo, "No.", NewDimValue);
            Database::"NPR POS Unit":
                UpdatePOSUnitGlobalDimCode(GlobalDimCodeNo, "No.", NewDimValue);
            Database::"NPR NPRE Seating":
                UpdateNPRESeatingGlobalDimCode(GlobalDimCodeNo, "No.", NewDimValue);
            Database::"NPR MM Recur. Paym. Setup":
                UpdateRecurPaymSetupGlobalDimCode(GlobalDimCodeNo, "No.", NewDimValue);
        end;
    end;

    procedure UpdateItemCategoryGlobalDimCode(GlobalDimCodeNo: Integer; ItemCategoryCode: Code[20]; NewDimValue: Code[20])
    var
        ItemCategory: Record "Item Category";
    begin
        if ItemCategory.Get(ItemCategoryCode) then begin
            case GlobalDimCodeNo of
                1:
                    ItemCategory."NPR Global Dimension 1 Code" := NewDimValue;
                2:
                    ItemCategory."NPR Global Dimension 2 Code" := NewDimValue;
            end;
            ItemCategory.Modify(true);
        end;
    end;

    procedure UpdateMixedDiscountGlobalDimCode(GlobalDimCodeNo: Integer; MixedDiscountNo: Code[20]; NewDimValue: Code[20])
    var
        MixedDiscount: Record "NPR Mixed Discount";
    begin
        if MixedDiscount.Get(MixedDiscountNo) then begin
            case GlobalDimCodeNo of
                1:
                    MixedDiscount."Global Dimension 1 Code" := NewDimValue;
                2:
                    MixedDiscount."Global Dimension 2 Code" := NewDimValue;
            end;
            MixedDiscount.Modify(true);
        end;
    end;

    procedure UpdatePeriodDiscountGlobalDimCode(GlobalDimCodeNo: Integer; PeriodDiscountNo: Code[20]; NewDimValue: Code[20])
    var
        PeriodDiscount: Record "NPR Period Discount";
    begin
        if PeriodDiscount.Get(PeriodDiscountNo) then begin
            case GlobalDimCodeNo of
                1:
                    PeriodDiscount."Global Dimension 1 Code" := NewDimValue;
                2:
                    PeriodDiscount."Global Dimension 2 Code" := NewDimValue;
            end;
            PeriodDiscount.Modify(true);
        end;
    end;

    procedure UpdateQuantityDiscountGlobalDimCode(GlobalDimCodeNo: Integer; QuantityDiscountNo: Code[20]; NewDimValue: Code[20])
    var
        QuantityDiscount: Record "NPR Quantity Discount Header";
    begin
        if QuantityDiscount.Get(QuantityDiscountNo) then begin
            case GlobalDimCodeNo of
                1:
                    QuantityDiscount."Global Dimension 1 Code" := NewDimValue;
                2:
                    QuantityDiscount."Global Dimension 2 Code" := NewDimValue;
            end;
            QuantityDiscount.Modify(true);
        end;
    end;

    local procedure UpdatePOSStoreGlobalDimCode(GlobalDimCodeNo: Integer; POSStoreCode: Code[20]; NewDimValue: Code[20])
    var
        POSStore: Record "NPR POS Store";
    begin
        if POSStore.Get(POSStoreCode) then begin
            case GlobalDimCodeNo of
                1:
                    POSStore."Global Dimension 1 Code" := NewDimValue;
                2:
                    POSStore."Global Dimension 2 Code" := NewDimValue;
            end;
            POSStore.Modify(true);
        end;
    end;

    local procedure UpdatePOSUnitGlobalDimCode(GlobalDimCodeNo: Integer; POSUnitNo: Code[20]; NewDimValue: Code[20])
    var
        POSUnit: Record "NPR POS Unit";
    begin
        if POSUnit.Get(POSUnitNo) then begin
            case GlobalDimCodeNo of
                1:
                    POSUnit."Global Dimension 1 Code" := NewDimValue;
                2:
                    POSUnit."Global Dimension 2 Code" := NewDimValue;
            end;
            POSUnit.Modify(true);
        end;
    end;

    local procedure UpdateNPRESeatingGlobalDimCode(GlobalDimCodeNo: Integer; SeatingCode: Code[20]; NewDimValue: Code[20])
    var
        NPRESeating: Record "NPR NPRE Seating";
    begin
        SeatingCode := CopyStr(SeatingCode, 1, MaxStrLen(NPRESeating.Code));
        if NPRESeating.Get(SeatingCode) then begin
            case GlobalDimCodeNo of
                1:
                    NPRESeating."Global Dimension 1 Code" := NewDimValue;
                2:
                    NPRESeating."Global Dimension 2 Code" := NewDimValue;
            end;
            NPRESeating.Modify(true);
        end;
    end;

    local procedure UpdateRecurPaymSetupGlobalDimCode(GlobalDimCodeNo: Integer; RecurPaymCode: Code[20]; NewDimValue: Code[20])
    var
        RecurPaymSetup: Record "NPR MM Recur. Paym. Setup";
    begin
        if RecurPaymSetup.Get(RecurPaymCode) then begin
            case GlobalDimCodeNo of
                1:
                    RecurPaymSetup."Global Dimension 1 Code" := NewDimValue;
                2:
                    RecurPaymSetup."Global Dimension 2 Code" := NewDimValue;
            end;
            RecurPaymSetup.Modify(true);
        end;
    end;
}
