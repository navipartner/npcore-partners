table 6059878 "NPR Total Discount Benefit"
{
    Caption = 'Total Discount Benefit';
    DataClassification = CustomerContent;
    Access = Internal;

    fields
    {
        field(1; "Total Discount Code"; Code[20])
        {
            Caption = 'Total Discount Code';
            TableRelation = "NPR Total Discount Header".Code;
            DataClassification = CustomerContent;
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }

        field(3; Type; Enum "NPR Total Disc. Benefit Type")
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
                NPRTotalDiscBenefitUtils: Codeunit "NPR Total Disc Benefit Utils";
            begin
                if Rec.Type <> xRec.Type then begin
                    NPRTotalDiscBenefitUtils.CheckIfDiscountTypeAlreadyAssignedToStep(Rec);
                    NPRTotalDiscBenefitUtils.ClearFields(Rec);
                end;

            end;
        }
        field(4; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            TableRelation = if (Type = const(Item)) Item."No."
            else
            if (Type = const("Item List")) "NPR Item Benefit List Header";

            trigger OnValidate()
            var
                NPRTotalDiscBenefitUtils: Codeunit "NPR Total Disc Benefit Utils";
            begin
                if Rec."No." <> xRec."No." then begin

                    Rec."Variant Code" := '';

                    NPRTotalDiscBenefitUtils.CheckNoEmpty(Rec);

                    NPRTotalDiscBenefitUtils.UpdateDescription(Rec);
                    if Rec.Type = Rec.Type::"Item List" then
                        NPRTotalDiscBenefitUtils.CheckTotalDiscountBenefitListQuantity(Rec);


                end;
            end;
        }
        field(5; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = if (Type = const(Item)) "Item Variant".Code where("Item No." = field("No."));
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                NPRTotalDiscBenefitUtils: Codeunit "NPR Total Disc Benefit Utils";
            begin
                if Rec."Variant Code" <> xRec."Variant Code" then begin
                    NPRTotalDiscBenefitUtils.CheckVariantCodeEmpty(Rec);

                    NPRTotalDiscBenefitUtils.UpdateDescription(Rec);
                end;
            end;
        }
        field(6; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;

        }
        field(7; "Value Type"; Enum "NPR Total Disc Ben Value Type")
        {
            Caption = 'Value Type';
            InitValue = Amount;
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                NPRTotalDiscBenefitUtils: Codeunit "NPR Total Disc Benefit Utils";
            begin
                if "Value Type" <> xRec."Value Type" then begin

                    NPRTotalDiscBenefitUtils.CheckValueType(Rec);
                    Value := 0;

                end;
            end;
        }
        field(20; Value; Decimal)
        {
            BlankZero = true;
            Caption = 'Value';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                NPRTotalDiscBenefitUtils: Codeunit "NPR Total Disc Benefit Utils";
            begin
                NPRTotalDiscBenefitUtils.CheckValue(Rec);
            end;
        }
        field(21; "Step Amount"; Decimal)
        {
            Caption = 'Step Amount';
            DataClassification = CustomerContent;
        }

        field(22; Quantity; Decimal)
        {
            Caption = 'Quantity';
            BlankZero = true;
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
                NPRTotalDiscBenefitUtils: Codeunit "NPR Total Disc Benefit Utils";
            begin
                NPRTotalDiscBenefitUtils.CheckQuantity(Rec);
            end;

        }

        field(30; "No Input Needed"; Boolean)
        {
            Caption = 'No Input Needed';
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
                NPRTotalDiscBenefitUtils: Codeunit "NPR Total Disc Benefit Utils";
            begin
                NPRTotalDiscBenefitUtils.CheckNoInput(Rec);
            end;

        }

        field(40; Status; Enum "NPR Total Discount Status")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            Editable = false;
        }



    }

    keys
    {
        key(Key1; "Total Discount Code", "Line No.")
        {
            Clustered = true;
        }
        key(Key2; "Step Amount", Type)
        {

        }
        key(Key3; "Total Discount Code", "Step Amount")
        {

        }
        key(Key4; "Status", "Type", "No.")
        {

        }

        key(Key5; "Total Discount Code", "Step Amount", Type)
        {

        }


    }

    trigger OnInsert()
    var
        NPRTotalDiscBenefitUtils: Codeunit "NPR Total Disc Benefit Utils";
    begin
        NPRTotalDiscBenefitUtils.CheckIfTotalDiscountEditable(Rec);
        NPRTotalDiscBenefitUtils.CheckIfDiscountTypeAlreadyAssignedToStep(Rec);
    end;

    trigger OnModify()
    var
        NPRTotalDiscBenefitUtils: Codeunit "NPR Total Disc Benefit Utils";
    begin
        NPRTotalDiscBenefitUtils.CheckIfTotalDiscountEditable(Rec);
        NPRTotalDiscBenefitUtils.CheckIfDiscountTypeAlreadyAssignedToStep(Rec);

    end;

    trigger OnDelete()
    var
        NPRTotalDiscBenefitUtils: Codeunit "NPR Total Disc Benefit Utils";
    begin
        NPRTotalDiscBenefitUtils.CheckIfTotalDiscountEditable(Rec);
    end;

    trigger OnRename()
    var
        NPRTotalDiscBenefitUtils: Codeunit "NPR Total Disc Benefit Utils";
    begin
        NPRTotalDiscBenefitUtils.CheckIfTotalDiscountEditable(Rec);
    end;

}