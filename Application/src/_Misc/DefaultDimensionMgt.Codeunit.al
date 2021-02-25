codeunit 6014400 "NPR Default Dimension Mgt."
{
    procedure UpdateGlobalDimCode(GlobalDimCodeNo: Integer; "Table ID": Integer; "No.": Code[20]; NewDimValue: Code[20])
    begin
        case "Table ID" of
            DATABASE::"NPR Item Group":
                UpdateItemGroupGlobalDimCode(GlobalDimCodeNo, "No.", NewDimValue);
            DATABASE::"NPR Mixed Discount":
                UpdateMixedDiscountGlobalDimCode(GlobalDimCodeNo, "No.", NewDimValue);
            DATABASE::"NPR Period Discount":
                UpdatePeriodDiscountGlobalDimCode(GlobalDimCodeNo, "No.", NewDimValue);
            DATABASE::"NPR Quantity Discount Header":
                UpdateQuantityDiscountGlobalDimCode(GlobalDimCodeNo, "No.", NewDimValue);
            DATABASE::"NPR POS Store":
                UpdatePOSStoreGlobalDimCode(GlobalDimCodeNo, "No.", NewDimValue);
            DATABASE::"NPR POS Unit":
                UpdatePOSUnitGlobalDimCode(GlobalDimCodeNo, "No.", NewDimValue);
            DATABASE::"NPR NPRE Seating":
                UpdateNPRESeatingGlobalDimCode(GlobalDimCodeNo, "No.", NewDimValue);
        end;
    end;

    
    procedure UpdateItemGroupGlobalDimCode(GlobalDimCodeNo: Integer; ItemGroupNo: Code[20]; NewDimValue: Code[20])
    var
        ItemGroup: Record "NPR Item Group";
    begin
        if ItemGroup.Get(ItemGroupNo) then begin
            case GlobalDimCodeNo of
                1:
                    ItemGroup."Global Dimension 1 Code" := NewDimValue;
                2:
                    ItemGroup."Global Dimension 2 Code" := NewDimValue;
            end;
            ItemGroup.Modify(true);
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
}