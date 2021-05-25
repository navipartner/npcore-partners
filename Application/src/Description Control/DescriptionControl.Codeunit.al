codeunit 6059969 "NPR Description Control"
{
    local procedure InitDescriptionControl()
    var
        DescriptionControl: Record "NPR Description Control";
    begin
        if not DescriptionControl.IsEmpty then
            exit;


        DescriptionControl.LockTable();

        DescriptionControl.Code := 'VAR_FIRST';
        DescriptionControl."Setup Type" := DescriptionControl."Setup Type"::Simple;
        DescriptionControl."Description 1 Var (Simple)" := DescriptionControl."Description 1 Var (Simple)"::VariantDescription1;
        DescriptionControl."Description 2 Var (Simple)" := DescriptionControl."Description 2 Var (Simple)"::ItemDescription1;
        DescriptionControl."Description 1 Std (Simple)" := DescriptionControl."Description 1 Std (Simple)"::ItemDescription1;
        DescriptionControl."Description 2 Std (Simple)" := DescriptionControl."Description 2 Std (Simple)"::ItemDescription2;
        DescriptionControl.Insert();

        DescriptionControl.Code := 'VAR_LAST';
        DescriptionControl."Setup Type" := DescriptionControl."Setup Type"::Simple;
        DescriptionControl."Description 1 Var (Simple)" := DescriptionControl."Description 1 Var (Simple)"::ItemDescription1;
        DescriptionControl."Description 2 Var (Simple)" := DescriptionControl."Description 2 Var (Simple)"::VariantDescription1;
        DescriptionControl."Description 1 Std (Simple)" := DescriptionControl."Description 1 Std (Simple)"::ItemDescription1;
        DescriptionControl."Description 2 Std (Simple)" := DescriptionControl."Description 2 Std (Simple)"::ItemDescription2;
        DescriptionControl.Insert();

        DescriptionControl.Code := 'NO_VARIANT';
        DescriptionControl."Setup Type" := DescriptionControl."Setup Type"::Simple;
        DescriptionControl."Description 1 Var (Simple)" := DescriptionControl."Description 1 Var (Simple)"::ItemDescription1;
        DescriptionControl."Description 2 Var (Simple)" := DescriptionControl."Description 2 Var (Simple)"::ItemDescription2;
        DescriptionControl."Description 1 Std (Simple)" := DescriptionControl."Description 1 Std (Simple)"::ItemDescription1;
        DescriptionControl."Description 2 Std (Simple)" := DescriptionControl."Description 2 Std (Simple)"::ItemDescription2;
        DescriptionControl.Insert();

        DescriptionControl.Code := 'VARIANT';
        DescriptionControl."Setup Type" := DescriptionControl."Setup Type"::Simple;
        DescriptionControl."Description 1 Var (Simple)" := DescriptionControl."Description 1 Var (Simple)"::VariantDescription1;
        DescriptionControl."Description 2 Var (Simple)" := DescriptionControl."Description 2 Var (Simple)"::VariantDescription2;
        DescriptionControl."Description 1 Std (Simple)" := DescriptionControl."Description 1 Std (Simple)"::ItemDescription1;
        DescriptionControl."Description 2 Std (Simple)" := DescriptionControl."Description 2 Std (Simple)"::ItemDescription2;
        DescriptionControl.Insert();

    end;

    procedure GetItemRefDescription(ItemNo: Code[20]; VariantCode: Code[10]): Text[100]
    var
        VRTSetup: Record "NPR Variety Setup";
        Item: Record Item;
        ItemVariant: Record "Item Variant";
    begin
        VRTSetup.Get();
        Item.Get(ItemNo);
        if VariantCode = '' then begin
            case VRTSetup."Item Cross Ref. Description(I)" of
                VRTSetup."Item Cross Ref. Description(I)"::ItemDescription1:
                    exit(Item.Description);
                VRTSetup."Item Cross Ref. Description(I)"::ItemDescription2:
                    exit(Item."Description 2");
            end;
        end else begin
            ItemVariant.Get(ItemNo, VariantCode);
            case VRTSetup."Item Cross Ref. Description(V)" of
                VRTSetup."Item Cross Ref. Description(V)"::ItemDescription1:
                    exit(Item.Description);
                VRTSetup."Item Cross Ref. Description(V)"::ItemDescription2:
                    exit(Item."Description 2");
                VRTSetup."Item Cross Ref. Description(V)"::VariantDescription1:
                    exit(ItemVariant.Description);
                VRTSetup."Item Cross Ref. Description(V)"::VariantDescription2:
                    exit(ItemVariant."Description 2");
            end;
        end;
    end;

    procedure GetDescriptionPOS(var Rec: Record "NPR POS Sale Line"; XRec: Record "NPR POS Sale Line"; Item: Record Item)
    begin
        if Rec."Custom Descr" then
            exit;

        if Rec.Type <> Rec.Type::Item then
            exit;

        InitDescriptionControl();

        if (Rec.Description = '') or (Rec.Description = ' ') then
            Rec.Description := CopyStr(Item.Description, 1, 30);

        Rec."Description 2" := CopyStr(Item."Description 2", 1, 30);

    end;

    [EventSubscriber(ObjectType::Table, 5777, 'OnAfterValidateEvent', 'Item No.', true, true)]
    local procedure T5777OnAfterValidateEventItemNo(var Rec: Record "Item Reference"; var xRec: Record "Item Reference"; CurrFieldNo: Integer)
    begin
        if (Rec."Item No." <> xRec."Item No.") or (Rec.Description = '') then
            Rec.Description := GetItemRefDescription(Rec."Item No.", Rec."Variant Code");
    end;

    [EventSubscriber(ObjectType::Table, 5777, 'OnAfterValidateEvent', 'Variant Code', true, true)]
    local procedure T5777OnAfterValidateEventVariantCode(var Rec: Record "Item Reference"; var xRec: Record "Item Reference"; CurrFieldNo: Integer)
    begin
        if (Rec."Variant Code" <> xRec."Variant Code") or (Rec.Description = '') then
            Rec.Description := GetItemRefDescription(Rec."Item No.", Rec."Variant Code");
    end;
}

