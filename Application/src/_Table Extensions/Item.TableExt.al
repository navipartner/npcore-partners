tableextension 6014427 "NPR Item" extends Item
{
    fields
    {
        field(6014400; "NPR Item Group"; Code[10])
        {
            Caption = 'Item Group';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
            TableRelation = "NPR Item Group";
        }
        field(6014401; "NPR Group sale"; Boolean)
        {
            Caption = 'Various item sales';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
        }
        field(6014408; "NPR Season"; Code[10])
        {
            Caption = 'Season';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
            ObsoleteState = Removed;
            ObsoleteReason = 'This field won"t be used anymore';
            ObsoleteTag = 'Refactoring 2/2/2021';
        }
        field(6014409; "NPR Create Alt. No. Automatic"; Boolean)
        {
            CalcFormula = Lookup("NPR Variety Setup"."Create Alt. No. automatic");
            Caption = 'Create Alt. No. Automatic';
            Description = 'NPR5.30';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6014410; "NPR Label Barcode"; Code[20])
        {
            Caption = 'Label barcode';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
            TableRelation = IF ("NPR Create Alt. No. Automatic" = CONST(false)) "Item Cross Reference"."Cross-Reference No." WHERE("Cross-Reference Type" = CONST("Bar Code"),
                                                                                                                              "Item No." = FIELD("No."),
                                                                                                                              "Cross-Reference No." = FILTER(<> ''),
                                                                                                                              "Variant Code" = CONST(''))
            ELSE
            IF ("NPR Create Alt. No. Automatic" = CONST(true)) "NPR Alternative No."."Alt. No." WHERE(Type = CONST(Item),
                                                                                                                                                                                                                    Code = FIELD("No."),
                                                                                                                                                                                                                    "Alt. No." = FILTER(<> ''),
                                                                                                                                                                                                                    "Variant Code" = CONST(''));
        }
        field(6014418; "NPR Explode BOM auto"; Boolean)
        {
            Caption = 'Auto-explode BOM';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
        }
        field(6014419; "NPR Guarantee voucher"; Boolean)
        {
            Caption = 'Guarantee voucher';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
        }
        field(6014424; "NPR Cannot edit unit price"; Boolean)
        {
            Caption = 'Can''t edit unit price';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
        }
        field(6014428; "NPR Primary Key Length"; Integer)
        {
            Caption = 'Primary Key Length';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
        }
        field(6014435; "NPR Last Changed at"; DateTime)
        {
            Caption = 'Last Changed at';
            DataClassification = CustomerContent;
            Description = 'NPR5.48';
            ObsoleteState = Removed;
        }
        field(6014440; "NPR Last Changed by"; Code[50])
        {
            Caption = 'Last Changed by';
            DataClassification = CustomerContent;
            Description = 'NPR5.48';
            ObsoleteState = Removed;
        }
        field(6014500; "NPR Second-hand number"; Code[20])
        {
            Caption = 'Second-hand number';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
        }
        field(6014502; "NPR Condition"; Option)
        {
            Caption = 'Condition';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
            OptionCaption = 'New,Mint,Mint boxed,A,B,C,D,E,F,B+';
            OptionMembers = New,Mint,"Mint boxed",A,B,C,D,E,F,"B+";
            ObsoleteState = Removed;
            ObsoleteReason = 'This field won"t be used anymore';
            ObsoleteTag = 'Refactoring 2/2/2021';
        }
        field(6014503; "NPR Second-hand"; Boolean)
        {
            Caption = 'Second-hand';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
        }
        field(6014504; "NPR Guarantee Index"; Option)
        {
            Caption = 'Guarantee Index';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
            OptionCaption = ' ,Move to Warranty';
            OptionMembers = " ","Flyt til garanti kar.";
        }
        field(6014506; "NPR Has Accessories"; Boolean)
        {
            CalcFormula = Exist("NPR Accessory/Spare Part" WHERE(Code = FIELD("No.")));
            Caption = 'Has Accessories';
            Description = 'NPR5.40';
            FieldClass = FlowField;
        }
        field(6014508; "NPR Insurrance category"; Code[50])
        {
            Caption = 'Insurance Section';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
            TableRelation = "NPR Insurance Category";
        }
        field(6014509; "NPR Item Brand"; Code[10])
        {
            Caption = 'Item brand';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
        }
        field(6014512; "NPR No Print on Reciept"; Boolean)
        {
            Caption = 'No Print on Reciept';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
        }
        field(6014513; "NPR Print Tags"; Text[100])
        {
            Caption = 'Print Tags';
            DataClassification = CustomerContent;
        }
        field(6014514; "NPR NPRE Item Routing Profile"; Code[20])
        {
            Caption = 'Rest. Item Routing Profile';
            DataClassification = CustomerContent;
            Description = 'NPR5.55';
            TableRelation = "NPR NPRE Item Routing Profile";
        }
        field(6014609; "NPR Has Variants"; Boolean)
        {
            CalcFormula = Exist("Item Variant" WHERE("Item No." = FIELD("No.")));
            Caption = 'Has Variants';
            Description = 'NPR7.100.000';
            FieldClass = FlowField;
        }
        field(6014625; "NPR Std. Sales Qty."; Decimal)
        {
            Caption = 'Std. Sales Qty.';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
        }
        field(6014630; "NPR Blocked on Pos"; Boolean)
        {
            Caption = 'Blocked on Pos';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.001';
        }
        field(6014635; "NPR Sale Blocked"; Boolean)
        {
            Caption = 'Sale Blocked';
            DataClassification = CustomerContent;
            Description = 'NPR5.38';
        }
        field(6014640; "NPR Purchase Blocked"; Boolean)
        {
            Caption = 'Purchase Blocked';
            DataClassification = CustomerContent;
            Description = 'NPR5.38';
        }
        field(6014641; "NPR Custom Discount Blocked"; Boolean)
        {
            Caption = 'Custom Discount Blocked';
            DataClassification = CustomerContent;
            Description = 'NPR5.42 [297569]';
        }
        field(6014642; "NPR Shelf Label Type"; Code[50])
        {
            Caption = 'Shelf Label Type';
            DataClassification = CustomerContent;
            Description = 'NPR5.51';
            ObsoleteState = Removed;
        }
        field(6059784; "NPR Ticket Type"; Code[10])
        {
            Caption = 'Ticket Type';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000,Ticket';
            TableRelation = "NPR TM Ticket Type";
        }
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
        field(6059981; "NPR Cross Variety No."; Option)
        {
            Caption = 'Cross Variety No.';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
            OptionCaption = 'Variety 1,Variety 2,Variety 3,Variety 4';
            OptionMembers = Variety1,Variety2,Variety3,Variety4;
        }
        field(6059982; "NPR Variety Group"; Code[20])
        {
            Caption = 'Variety Group';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
            TableRelation = "NPR Variety Group";
        }
        field(6060054; "NPR Item Status"; Code[10])
        {
            Caption = 'Item Status';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            TableRelation = "NPR Item Status";
        }
        field(6151125; "NPR Item AddOn No."; Code[20])
        {
            Caption = 'Item AddOn No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.48';
            TableRelation = "NPR NpIa Item AddOn";
        }
        field(6151400; "NPR Magento Item"; Boolean)
        {
            Caption = 'Magento Item';
            DataClassification = CustomerContent;
            Description = 'MAG2.00';
        }
        field(6151405; "NPR Magento Status"; Option)
        {
            BlankZero = true;
            Caption = 'Magento Status';
            DataClassification = CustomerContent;
            Description = 'MAG2.00';
            InitValue = Active;
            OptionCaption = ',Active,Inactive';
            OptionMembers = ,Active,Inactive;
        }
        field(6151410; "NPR Attribute Set ID"; Integer)
        {
            Caption = 'Attribute Set ID';
            DataClassification = CustomerContent;
            Description = 'MAG2.00';
            TableRelation = "NPR Magento Attribute Set";
        }
        field(6151415; "NPR Magento Description"; BLOB)
        {
            Caption = 'Magento Description';
            DataClassification = CustomerContent;
            Description = 'MAG2.00';
        }
        field(6151420; "NPR Magento Name"; Text[250])
        {
            Caption = 'Magento Name';
            DataClassification = CustomerContent;
            Description = 'MAG2.00';
        }
        field(6151425; "NPR Magento Short Description"; BLOB)
        {
            Caption = 'Magento Short Description';
            DataClassification = CustomerContent;
            Description = 'MAG2.00';
        }
        field(6151430; "NPR Magento Brand"; Code[20])
        {
            Caption = 'Magento Brand';
            DataClassification = CustomerContent;
            Description = 'MAG2.00';
            TableRelation = "NPR Magento Brand";
        }
        field(6151435; "NPR Seo Link"; Text[250])
        {
            Caption = 'Seo Link';
            DataClassification = CustomerContent;
            Description = 'MAG2.00';
        }
        field(6151440; "NPR Meta Title"; Text[100])
        {
            Caption = 'Meta Title';
            DataClassification = CustomerContent;
            Description = 'MAG2.00,MAG2.07,MAG2.22';
        }
        field(6151445; "NPR Meta Description"; Text[250])
        {
            Caption = 'Meta Description';
            DataClassification = CustomerContent;
            Description = 'MAG2.00';
        }
        field(6151450; "NPR Product New From"; Date)
        {
            Caption = 'Product New From';
            DataClassification = CustomerContent;
            Description = 'MAG2.00';
        }
        field(6151455; "NPR Product New To"; Date)
        {
            Caption = 'Product New To';
            DataClassification = CustomerContent;
            Description = 'MAG2.00';
        }
        field(6151460; "NPR Special Price"; Decimal)
        {
            Caption = 'Special Price';
            DataClassification = CustomerContent;
            Description = 'MAG2.00';
        }
        field(6151465; "NPR Special Price From"; Date)
        {
            Caption = 'Special Price From';
            DataClassification = CustomerContent;
            Description = 'MAG2.00';
        }
        field(6151470; "NPR Special Price To"; Date)
        {
            Caption = 'Special Price To';
            DataClassification = CustomerContent;
            Description = 'MAG2.00';
        }
        field(6151475; "NPR Featured From"; Date)
        {
            Caption = 'Featured From';
            DataClassification = CustomerContent;
            Description = 'MAG2.00';
        }
        field(6151480; "NPR Featured To"; Date)
        {
            Caption = 'Featured To';
            DataClassification = CustomerContent;
            Description = 'MAG2.00';
        }
        field(6151485; "NPR Backorder"; Boolean)
        {
            Caption = 'Backorder';
            DataClassification = CustomerContent;
            Description = 'MAG2.00';
        }
        field(6151490; "NPR Display Only"; Boolean)
        {
            Caption = 'Display Only';
            DataClassification = CustomerContent;
            Description = 'MAG2.00';
        }
        field(6151495; "NPR Custom Options"; Integer)
        {
            CalcFormula = Count("NPR Magento Item Custom Option" WHERE("Item No." = FIELD("No."),
                                                                    Enabled = CONST(true)));
            Caption = 'Custom Options';
            Description = 'MAG2.00';
            Editable = false;
            FieldClass = FlowField;
        }

        field(6151496; "NPR Has Mixed Discount"; Boolean)
        {
            Caption = 'Has Mixed Discount';
            FieldClass = FlowField;
            CalcFormula = Exist("NPR Mixed Discount Line" where("No." = field("No.")));
            Editable = false;
        }
        field(6151497; "NPR Has Quantity Discount"; Boolean)
        {
            Caption = 'Has Quantity Discount';
            FieldClass = FlowField;
            CalcFormula = Exist("NPR Quantity Discount Line" where("Item No." = field("No.")));
            Editable = false;
        }
        field(6151498; "NPR Has Period Discount"; Boolean)
        {
            Caption = 'Has Period Discount';
            FieldClass = FlowField;
            CalcFormula = Exist("NPR Period Discount Line" where("Item No." = field("No.")));
            Editable = false;
        }
        field(6151500; "NPR Magento Pict. Variety Type"; Option)
        {
            Caption = 'Magento Picture Variety Type';
            DataClassification = CustomerContent;
            Description = 'MAG2.22';
            OptionCaption = 'None,Variety 1,Variety 2,Variety 3,Variety 4';
            OptionMembers = "None","Variety 1","Variety 2","Variety 3","Variety 4";
        }
        field(6151501; "NPR Display only Text"; text[250])
        {
            Caption = 'Display Only Text';
            DataClassification = CustomerContent;
            Description = 'MAG3.00';
        }
    }
    keys
    {
        key(Key1; "NPR Group sale", "NPR Item Group")
        {
        }
        key(Key2; "NPR Primary Key Length")
        {
        }
    }


}

