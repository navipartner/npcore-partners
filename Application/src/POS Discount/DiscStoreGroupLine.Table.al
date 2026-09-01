table 6059938 "NPR Disc. Store Group Line"
{
    Access = Internal;
    Caption = 'Discount Store Group Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Disc. Store Group Code"; Code[20])
        {
            Caption = 'Disc. Store Group Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR Disc. Store Group"."Code";
        }
        field(10; "POS Store Group Code"; Code[20])
        {
            Caption = 'POS Store Group Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Store Group"."No.";
            NotBlank = true;

            trigger OnValidate()
            var
                POSStoreGroupLine: Record "NPR POS Store Group Line";
                POSStoreGroup: Record "NPR POS Store Group";
                EmptyLinesErr: Label '%1 has no stores assigned. Please add stores to the %1 before selecting it.', Comment = '%1 = POS Store Group table caption';
            begin
                POSStoreGroupLine.SetRange("No.", "POS Store Group Code");
                if POSStoreGroupLine.IsEmpty() then
                    Error(EmptyLinesErr, POSStoreGroup.TableCaption);
                CalcFields("POS Store Group Description");
            end;
        }
        field(20; "POS Store Group Description"; Text[100])
        {
            Caption = 'POS Store Group Description';
            FieldClass = FlowField;
            CalcFormula = lookup("NPR POS Store Group".Description where("No." = field("POS Store Group Code")));
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Disc. Store Group Code", "POS Store Group Code")
        {
            Clustered = true;
        }
        key(Key2; SystemRowVersion)
        {
        }
    }

    trigger OnDelete()
    var
        RemainingLines: Record "NPR Disc. Store Group Line";
        DiscStoreGroup: Record "NPR Disc. Store Group";
        PeriodDiscount: Record "NPR Period Discount";
        MixedDiscount: Record "NPR Mixed Discount";
        QuantityDiscountHeader: Record "NPR Quantity Discount Header";
        TotalDiscountHeader: Record "NPR Total Discount Header";
        CannotDeleteLastLineErr: Label 'You cannot delete the last store group from %1 %2 because it is assigned to one or more discounts.', Comment = '%1 = Disc. Store Group table caption, %2 = Disc. Store Group Code';
    begin
        RemainingLines.SetRange("Disc. Store Group Code", "Disc. Store Group Code");
        RemainingLines.SetFilter("POS Store Group Code", '<>%1', "POS Store Group Code");
        if not RemainingLines.IsEmpty() then
            exit;

        PeriodDiscount.SetRange("Disc. Store Group Code", "Disc. Store Group Code");
        if not PeriodDiscount.IsEmpty() then
            Error(CannotDeleteLastLineErr, DiscStoreGroup.TableCaption, "Disc. Store Group Code");

        MixedDiscount.SetRange("Disc. Store Group Code", "Disc. Store Group Code");
        if not MixedDiscount.IsEmpty() then
            Error(CannotDeleteLastLineErr, DiscStoreGroup.TableCaption, "Disc. Store Group Code");

        QuantityDiscountHeader.SetRange("Disc. Store Group Code", "Disc. Store Group Code");
        if not QuantityDiscountHeader.IsEmpty() then
            Error(CannotDeleteLastLineErr, DiscStoreGroup.TableCaption, "Disc. Store Group Code");

        TotalDiscountHeader.SetRange("Disc. Store Group Code", "Disc. Store Group Code");
        if not TotalDiscountHeader.IsEmpty() then
            Error(CannotDeleteLastLineErr, DiscStoreGroup.TableCaption, "Disc. Store Group Code");
    end;
}
