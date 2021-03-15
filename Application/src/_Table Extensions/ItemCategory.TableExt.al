tableextension 6014400 "NPR Item Category" extends "Item Category"
{
    fields
    {
        field(6014400; "NPR Item Template Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Item Template Code';
            TableRelation = "Config. Template Header" where("Table ID" = const(27));
        }
        field(6014401; "NPR Gen. Bus. Posting Group"; Code[20])
        {
            Caption = 'Gen. Bus. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "Gen. Business Posting Group";

            trigger OnValidate()
            var
                GenBusinessPostingGroup: Record "Gen. Business Posting Group";
                ItemCategoryMgt: Codeunit "NPR Item Category Mgt.";
            begin
                if "NPR Gen. Bus. Posting Group" <> '' then begin
                    GenBusinessPostingGroup.Get("NPR Gen. Bus. Posting Group");
                    Validate("NPR VAT Bus. Posting Group", GenBusinessPostingGroup."Def. VAT Bus. Posting Group");
                end else
                    "NPR VAT Bus. Posting Group" := '';

                ItemCategoryMgt.CheckItemCategory(Rec, FieldNo("NPR Gen. Bus. Posting Group"));
            end;
        }
        field(6014402; "NPR Gen. Prod. Posting Group"; Code[20])
        {
            Caption = 'Gen. Prod. Posting Group';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                GenProductPostingGroup: Record "Gen. Product Posting Group";
                ItemCategoryMgt: Codeunit "NPR Item Category Mgt.";
            begin
                if "NPR Gen. Prod. Posting Group" <> '' then begin
                    GenProductPostingGroup.Get("NPR Gen. Prod. Posting Group");
                    Validate("NPR VAT Prod. Posting Group", GenProductPostingGroup."Def. VAT Prod. Posting Group");
                end else
                    "NPR VAT Prod. Posting Group" := '';

                ItemCategoryMgt.CheckItemCategory(Rec, FieldNo("NPR Gen. Prod. Posting Group"));
            end;
        }
        field(6014403; "NPR VAT Prod. Posting Group"; Code[20])
        {
            Caption = 'VAT Prod. Posting Group';
            DataClassification = CustomerContent;
        }
        field(6014404; "NPR VAT Bus. Posting Group"; Code[20])
        {
            Caption = 'VAT Bus. Posting Group';
            DataClassification = CustomerContent;
        }
        field(6014405; "NPR Inventory Posting Group"; Code[20])
        {
            Caption = 'Inventory Posting Group';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                ItemCategoryMgt: Codeunit "NPR Item Category Mgt.";
            begin
                ItemCategoryMgt.CheckItemCategory(Rec, FieldNo("NPR Inventory Posting Group"));
            end;
        }
        field(6014406; "NPR Main Category"; Boolean)
        {
            Caption = 'Main Category';
            DataClassification = CustomerContent;
        }
        field(6014407; "NPR Main Category Code"; Code[10])
        {
            Caption = 'Main Category Code';
            DataClassification = CustomerContent;
            TableRelation = "Item Category" where("NPR Main Category" = const(true));
        }
        field(6014408; "NPR Blocked"; Boolean)
        {
            Caption = 'Blocked';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                ItemCategoryMgt: Codeunit "NPR Item Category Mgt.";
            begin
                ItemCategoryMgt.CheckItemCategory(Rec, FieldNo("NPR Blocked"));

                ItemCategoryMgt.SetBlockedOnChildren(Code, "NPR Blocked", false);
            end;
        }
        field(6014409; "NPR Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                NPRValidateShortcutDimCode(1, "NPR Global Dimension 1 Code");
            end;
        }
        field(6014410; "NPR Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                NPRValidateShortcutDimCode(2, "NPR Global Dimension 1 Code");
            end;
        }
        field(6014411; "NPR Date Filter"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
        field(6014412; "NPR Location Filter"; code[10])
        {
            Caption = 'Location Filter';
            FieldClass = FlowFilter;
            TableRelation = Location;
        }
        field(6014413; "NPR Salesperson/Purch. Filter"; Code[20])
        {
            Caption = 'Salesperson Filter';
            FieldClass = FlowFilter;
            TableRelation = "Salesperson/Purchaser";
        }
        field(6014414; "NPR Vendor Filter"; Code[20])
        {
            Caption = 'Vendor Filter';
            FieldClass = FlowFilter;
            TableRelation = Vendor;
        }
        field(6014415; "NPR Global Dimension 1 Filter"; Code[20])
        {
            CaptionClass = '1,3,1';
            Caption = 'Global Dimension 1 Filter';
            FieldClass = FlowFilter;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
        }
        field(6014416; "NPR Global Dimension 2 Filter"; Code[20])
        {
            CaptionClass = '1,3,2';
            Caption = 'Global Dimension 2 Filter';
            FieldClass = FlowFilter;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
        }

        field(6014417; "NPR Sales (Qty.)"; Decimal)
        {
            Caption = 'Sales (Qty.)';
            FieldClass = FlowField;
            CalcFormula = - Sum("NPR Aux. Item Ledger Entry".Quantity
                                WHERE(
                                    "Entry Type" = CONST(Sale),
                                    "Posting Date" = FIELD("NPR Date Filter"),
                                    "Vendor No." = FIELD("NPR Vendor Filter"),
                                    "Global Dimension 1 Code" = FIELD("NPR Global Dimension 1 Filter"),
                                    "Global Dimension 2 Code" = FIELD("NPR Global Dimension 2 Filter"),
                                    "Location Code" = field("NPR Location Filter")));
        }
        field(6014418; "NPR Sales (LCY)"; Decimal)
        {
            Caption = 'Sales (LCY)';
            FieldClass = FlowField;
            CalcFormula = Sum("NPR Aux. Value Entry"."Sales Amount (Actual)"
                            WHERE(
                                "Item Ledger Entry Type" = CONST(Sale),
                                "Item Category Code" = FIELD("Code"),
                                "Posting Date" = FIELD("NPR Date Filter"),
                                "Vendor No." = FIELD("NPR Vendor Filter"),
                                "Salespers./Purch. Code" = FIELD("NPR Salesperson/Purch. Filter"),
                                "Global Dimension 1 Code" = FIELD("NPR Global Dimension 1 Filter"),
                                "Global Dimension 2 Code" = FIELD("NPR Global Dimension 2 Filter"),
                                "Location Code" = field("NPR Location Filter")));
        }
        field(6014419; "NPR Consumption (Amount)"; Decimal)
        {
            Caption = 'Consumption (Amount)';
            FieldClass = FlowField;
            CalcFormula = - Sum("NPR Aux. Value Entry"."Cost Amount (Actual)"
                                WHERE(
                                    "Item Ledger Entry Type" = CONST(Sale),
                                    "Item Category Code" = FIELD("Code"),
                                    "Posting Date" = FIELD("NPR Date Filter"),
                                    "Vendor No." = FIELD("NPR Vendor Filter"),
                                    "Salespers./Purch. Code" = FIELD("NPR Salesperson/Purch. Filter"),
                                    "Global Dimension 1 Code" = FIELD("NPR Global Dimension 1 Filter"),
                                    "Global Dimension 2 Code" = FIELD("NPR Global Dimension 2 Filter"),
                                    "Location Code" = field("NPR Location Filter")));
        }
        field(6014420; "NPR Movement"; Decimal)
        {
            Caption = 'Movement';
            FieldClass = FlowField;
            CalcFormula = Sum("NPR Aux. Item Ledger Entry".Quantity
                            WHERE(
                                "Item Category Code" = FIELD("Code"),
                                "Vendor No." = FIELD("NPR Vendor Filter"),
                                "Posting Date" = FIELD("NPR Date Filter"),
                                "Global Dimension 1 Code" = FIELD("NPR Global Dimension 1 Filter"),
                                "Global Dimension 2 Code" = FIELD("NPR Global Dimension 2 Filter"),
                                "Location Code" = field("NPR Location Filter")));
        }
        field(6014421; "NPR Purchases (Qty.)"; Decimal)
        {
            Caption = 'Purchases (Qty.)';
            FieldClass = FlowField;
            CalcFormula = Sum("NPR Aux. Item Ledger Entry".Quantity
                            WHERE(
                                "Entry Type" = CONST(Purchase),
                                "Item Category Code" = FIELD("Code"),
                                "Posting Date" = FIELD("NPR Date Filter"),
                                "Vendor No." = FIELD("NPR Vendor Filter"),
                                "Global Dimension 1 Code" = FIELD("NPR Global Dimension 1 Filter"),
                                "Global Dimension 2 Code" = FIELD("NPR Global Dimension 2 Filter"),
                                "Location Code" = field("NPR Location Filter")));
        }
        field(6014422; "NPR Purchases (LCY)"; Decimal)
        {
            Caption = 'Purchases (LCY)';
            FieldClass = FlowField;
            CalcFormula = Sum("NPR Aux. Value Entry"."Cost Amount (Actual)"
                            WHERE(
                                "Item Ledger Entry Type" = CONST(Purchase),
                                "Item Category Code" = FIELD("Code"),
                                "Posting Date" = FIELD("NPR Date Filter"),
                                "Vendor No." = FIELD("NPR Vendor Filter"),
                                "Salespers./Purch. Code" = FIELD("NPR Salesperson/Purch. Filter"),
                                "Global Dimension 1 Code" = FIELD("NPR Global Dimension 1 Filter"),
                                "Global Dimension 2 Code" = FIELD("NPR Global Dimension 2 Filter"),
                                "Location Code" = field("NPR Location Filter")));
        }
        field(6014423; "NPR Inventory Value"; Decimal)
        {
            Caption = 'Inventory Value';
            FieldClass = FlowField;
            CalcFormula = Sum("NPR Aux. Value Entry"."Cost Amount (Actual)"
                            WHERE(
                                "Item Category Code" = FIELD("Code"),
                                "Vendor No." = FIELD("NPR Vendor Filter"),
                                "Posting Date" = FIELD("NPR Date Filter"),
                                "Global Dimension 1 Code" = FIELD("NPR Global Dimension 1 Filter"),
                                "Global Dimension 2 Code" = FIELD("NPR Global Dimension 2 Filter"),
                                "Location Code" = field("NPR Location Filter")));
        }
    }

    procedure NPRValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    var
        DimMgt: Codeunit DimensionManagement;
    begin
        DimMgt.ValidateDimValueCode(FieldNumber, ShortcutDimCode);
        if not IsTemporary() then begin
            DimMgt.SaveDefaultDim(DATABASE::"Item Category", Code, FieldNumber, ShortcutDimCode);
            Modify();
        end;
    end;
}