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

        MainItemVariationMgt.OnCheckMainItemVariation2(Rec, Handled);
    end;

    procedure AddNewItemVariation(var VariationItem: Record Item)
    var
        MainItem: Record Item;
        Handled: Boolean;
    begin
        TestField("Main Item No.");

        VariationItem."NPR Main Item/Variation" := VariationItem."NPR Main Item/Variation"::Variation;
        VariationItem."NPR Main Item No." := "Main Item No.";
        VariationItem.Modify(true);

        MainItem.Get("Main Item No.");
        MainItem."NPR Main Item/Variation" := MainItem."NPR Main Item/Variation"::"Main Item";
        MainItem."NPR Main Item No." := "Main Item No.";
        MainItem.Modify(true);

        MainItemVariationMgt.OnAddNewItemVariation2(Rec, VariationItem, Handled);
    end;

    LOCAL procedure RemoveItemVariation()
    var
        MainItem: Record Item;
        VariationItem: Record Item;
        Handled: Boolean;
    begin
        if VariationItem.Get("Item No.") then begin
            VariationItem."NPR Main Item/Variation" := VariationItem."NPR Main Item/Variation"::" ";
            VariationItem."NPR Main Item No." := '';
            VariationItem.Modify(true);
        end;

        if not MainItem.Get("Main Item No.") then
            exit;
        VariationItem.SetCurrentKey("NPR Main Item No.", "NPR Main Item/Variation");
        VariationItem.SetRange("NPR Main Item/Variation", VariationItem."NPR Main Item/Variation"::Variation);
        VariationItem.SetRange("NPR Main Item No.", "Main Item No.");
        if VariationItem.IsEmpty() then begin
            MainItem."NPR Main Item/Variation" := MainItem."NPR Main Item/Variation"::" ";
            MainItem."NPR Main Item No." := '';
            MainItem.Modify(true);
        end else
            if MainItem."NPR Main Item/Variation" <> MainItem."NPR Main Item/Variation"::"Main Item" then begin
                MainItem."NPR Main Item/Variation" := MainItem."NPR Main Item/Variation"::"Main Item";
                MainItem."NPR Main Item No." := "Main Item No.";
                MainItem.Modify(true);
            end;

        MainItemVariationMgt.OnRemoveItemVariation2(Rec, Handled);
    end;

    var
        MainItemVariationMgt: Codeunit "NPR Main Item Variation Mgt.";
}