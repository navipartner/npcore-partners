tableextension 6014442 "NPR Item Variant" extends "Item Variant"
{
    fields
    {
        field(6059970; "NPR Variety 1"; Code[10])
        {
            Caption = 'Variety 1';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
            TableRelation = "NPR Variety";
        }
        field(6059971; "NPR Variety 1 Table"; Code[40])
        {
            Caption = 'Variety 1 Table';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
            TableRelation = "NPR Variety Table".Code WHERE(Type = FIELD("NPR Variety 1"));
        }
        field(6059972; "NPR Variety 1 Value"; Code[50])
        {
            Caption = 'Variety 1 Value';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
            TableRelation = "NPR Variety Value".Value WHERE(Type = FIELD("NPR Variety 1"),
                                                         Table = FIELD("NPR Variety 1 Table"));
        }
        field(6059973; "NPR Variety 2"; Code[10])
        {
            Caption = 'Variety 2';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
            TableRelation = "NPR Variety";
        }
        field(6059974; "NPR Variety 2 Table"; Code[40])
        {
            Caption = 'Variety 2 Table';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
            TableRelation = "NPR Variety Table".Code WHERE(Type = FIELD("NPR Variety 2"));
        }
        field(6059975; "NPR Variety 2 Value"; Code[50])
        {
            Caption = 'Variety 2 Value';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
            TableRelation = "NPR Variety Value".Value WHERE(Type = FIELD("NPR Variety 2"),
                                                         Table = FIELD("NPR Variety 2 Table"));
        }
        field(6059976; "NPR Variety 3"; Code[10])
        {
            Caption = 'Variety 3';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
            TableRelation = "NPR Variety";
        }
        field(6059977; "NPR Variety 3 Table"; Code[40])
        {
            Caption = 'Variety 3 Table';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
            TableRelation = "NPR Variety Table".Code WHERE(Type = FIELD("NPR Variety 3"));
        }
        field(6059978; "NPR Variety 3 Value"; Code[50])
        {
            Caption = 'Variety 3 Value';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
            TableRelation = "NPR Variety Value".Value WHERE(Type = FIELD("NPR Variety 3"),
                                                         Table = FIELD("NPR Variety 3 Table"));
        }
        field(6059979; "NPR Variety 4"; Code[10])
        {
            Caption = 'Variety 4';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
            TableRelation = "NPR Variety";
        }
        field(6059980; "NPR Variety 4 Table"; Code[40])
        {
            Caption = 'Variety 4 Table';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
            TableRelation = "NPR Variety Table".Code WHERE(Type = FIELD("NPR Variety 4"));
        }
        field(6059981; "NPR Variety 4 Value"; Code[50])
        {
            Caption = 'Variety 4 Value';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
            TableRelation = "NPR Variety Value".Value WHERE(Type = FIELD("NPR Variety 4"),
                                                         Table = FIELD("NPR Variety 4 Table"));
        }
        field(6059982; "NPR Blocked"; Boolean)
        {
            Caption = 'Blocked';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
#IF NOT (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
            ObsoleteState = Pending;
            ObsoleteTag = '2024-02-28';
            ObsoleteReason = 'Replaced with standard Microsoft field "Blocked"';
#ENDIF
        }

        field(6151479; "NPR Replication Counter"; BigInteger)
        {
            Caption = 'Replication Counter';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Replaced by SystemRowVersion';
        }
#if not BC17
        field(6151552; "NPR Spfy Store Filter"; Code[20])
        {
            Caption = 'Shopify Store Filter';
            FieldClass = FlowFilter;
            TableRelation = "NPR Spfy Store".Code;
        }
        field(6151553; "NPR Spfy Not Available"; Boolean)
        {
            Caption = 'Not Available in Shopify';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("NPR Spfy Item Variant Modif."."Not Available" where("Item No." = field("Item No."),
                                                                "Variant Code" = field(Code),
                                                                "Shopify Store Code" = field("NPR Spfy Store Filter")));
        }
        field(6151554; "NPR Do Not Track Inventory"; Boolean)
        {
            Caption = 'Do Not Track Inventory';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("NPR Spfy Item Variant Modif."."Do Not Track Inventory" where("Item No." = field("Item No."),
                                                                "Variant Code" = field(Code),
                                                                "Shopify Store Code" = field("NPR Spfy Store Filter")));
        }
#endif
    }

    keys
    {
        key("NPR Key1"; "NPR Replication Counter")
        {
            ObsoleteState = Pending;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Replaced by SystemRowVersion';
        }
#IF NOT (BC17 or BC18 or BC19 or BC20)
        key("NPR Key2"; SystemRowVersion)
        {
        }
#ENDIF
    }
}
