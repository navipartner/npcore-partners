table 6014695 "NPR Main Item Variation"
{
    Access = Internal;
    Caption = 'Main Item Variation';
    DataClassification = CustomerContent;
    LookupPageID = "NPR Main Item Variations";
    DrillDownPageId = "NPR Main Item Variations";

    fields
    {
        field(1; "Main Item No."; Code[20])
        {
            Caption = 'Main Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item."No.";
        }
        field(2; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item."No.";

            trigger OnValidate()
            var
                Item: Record Item;
            begin
                CheckMainItemVariation();

                Item.Get("Item No.");
                Description := Item.Description;
                AddNewItemVariation(Item);
            end;
        }
        field(10; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Main Item No.", "Item No.")
        {
            Clustered = true;
        }
        key(Key2; "Item No.") { }
    }

    trigger OnDelete()
    begin
        RemoveItemVariation();
    end;

    trigger OnRename()
    var
        CannotRenameErr: Label 'You cannot rename a %1.';
    begin
        Error(CannotRenameErr, TableCaption);
    end;

    procedure CheckMainItemVariation()
    var
        ItemIsMainErr: Label 'Item No. %1 has already been set up as a main item. It cannot be selected as a variation item for another main item.';
        ItemIsVariationErr: Label 'Item No. %1 has already been set up as a variation item for another main item (%2).';
        VariationOfItselfErr: Label 'Item No. %1 cannot be a variation of itself.';
        MainItemVariation: Record "NPR Main Item Variation";
        Handled: Boolean;
    begin
        TestField("Main Item No.");
        TestField("Item No.");

        if "Item No." = "Main Item No." then
            Error(VariationOfItselfErr, "Item No.");

        MainItemVariation.SetRange("Main Item No.", "Item No.");
        if not MainItemVariation.IsEmpty() then
            Error(ItemIsMainErr, "Item No.");

        MainItemVariation.SetCurrentKey("Item No.");
        MainItemVariation.SetRange("Item No.", "Item No.");
        MainItemVariation.SetFilter("Main Item No.", '<>%1', "Main Item No.");
        if MainItemVariation.FindFirst() then
            Error(ItemIsVariationErr, "Item No.", MainItemVariation."Main Item No.");

        MainItemVariation.SetRange("Main Item No.");
        MainItemVariation.SetRange("Item No.", "Main Item No.");
        if MainItemVariation.FindFirst() then
            Error(ItemIsVariationErr, "Main Item No.", MainItemVariation."Main Item No.");

        MainItemVariationMgt.OnCheckMainItemVariation(Rec, Handled);
    end;

    procedure AddNewItemVariation(Item: Record Item)
    var
        AuxItem: Record "NPR Auxiliary Item";
    begin
        AuxItem."Item No." := Item."No.";
        if not AuxItem.Find() then begin
            AuxItem.Init();
            AuxItem.Insert();
        end;
        AddNewItemVariation(AuxItem);
    end;

    procedure AddNewItemVariation(var VariationAuxItem: Record "NPR Auxiliary Item")
    var
        MainAuxItem: Record "NPR Auxiliary Item";
        Handled: Boolean;
    begin
        TestField("Main Item No.");

        VariationAuxItem."Main Item/Variation" := VariationAuxItem."Main Item/Variation"::Variation;
        VariationAuxItem."Main Item No." := "Main Item No.";
        VariationAuxItem.Modify(true);

        MainAuxItem."Item No." := "Main Item No.";
        if not MainAuxItem.Find() then begin
            MainAuxItem.Init();
            MainAuxItem.Insert();
        end;
        MainAuxItem."Main Item/Variation" := MainAuxItem."Main Item/Variation"::"Main Item";
        MainAuxItem."Main Item No." := "Main Item No.";
        MainAuxItem.Modify(true);

        MainItemVariationMgt.OnAddNewItemVariation(Rec, VariationAuxItem, Handled);
    end;

    LOCAL procedure RemoveItemVariation()
    var
        MainAuxItem: Record "NPR Auxiliary Item";
        VariationAuxItem: Record "NPR Auxiliary Item";
        Handled: Boolean;
    begin
        if VariationAuxItem.Get("Item No.") then begin
            VariationAuxItem."Main Item/Variation" := VariationAuxItem."Main Item/Variation"::" ";
            VariationAuxItem."Main Item No." := '';
            VariationAuxItem.Modify(true);
        end;

        if not MainAuxItem.Get("Main Item No.") then
            exit;
        VariationAuxItem.SetCurrentKey("Main Item No.", "Main Item/Variation");
        VariationAuxItem.SetRange("Main Item/Variation", VariationAuxItem."Main Item/Variation"::Variation);
        VariationAuxItem.SetRange("Main Item No.", "Main Item No.");
        if VariationAuxItem.IsEmpty() then begin
            MainAuxItem."Main Item/Variation" := MainAuxItem."Main Item/Variation"::" ";
            MainAuxItem."Main Item No." := '';
            MainAuxItem.Modify(true);
        end else
            if MainAuxItem."Main Item/Variation" <> MainAuxItem."Main Item/Variation"::"Main Item" then begin
                MainAuxItem."Main Item/Variation" := MainAuxItem."Main Item/Variation"::"Main Item";
                MainAuxItem."Main Item No." := "Main Item No.";
                MainAuxItem.Modify(true);
            end;

        MainItemVariationMgt.OnRemoveItemVariation(Rec, Handled);
    end;

    var
        MainItemVariationMgt: Codeunit "NPR Main Item Variation Mgt.";
}