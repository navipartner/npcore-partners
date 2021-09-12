table 6151061 "NPR Retail Repl. Demand Line"
{
    Caption = 'Retail Replenishment Demand Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(5; "Item No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            TableRelation = Item;

            trigger OnValidate()
            begin

                if "Item No." <> xRec."Item No." then begin
                    "Variant Code" := '';
                end;
                GetItem();
                Item.TestField(Blocked, false);
                UpdateDescription();
                "Item Category Code" := Item."Item Category Code";
                Item.TestField("Base Unit of Measure");
            end;
        }
        field(6; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(8; "Demanded Quantity"; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                "Quantity (Base)" := CalcBaseQty("Demanded Quantity");
                TestField(Confirmed, false);
            end;
        }
        field(9; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            DataClassification = CustomerContent;
            TableRelation = Vendor;
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                ItemVend: Record "Item Vendor";
            begin

                Item.Get("Item No.");
                if ItemVend.Get("Vendor No.", "Item No.", "Variant Code") then begin
                    "Vendor Item No." := CopyStr(ItemVend."Vendor Item No.", 1, MaxStrLen("Vendor Item No."));
                end else begin
                    if "Vendor No." = Item."Vendor No." then
                        "Vendor Item No." := CopyStr(Item."Vendor Item No.", 1, MaxStrLen("Vendor Item No."))
                    else
                        "Vendor Item No." := '';
                end;
                "Supply From" := "Vendor No.";
            end;
        }
        field(10; "Direct Unit Cost"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 2;
            Caption = 'Direct Unit Cost';
            DataClassification = CustomerContent;
        }
        field(12; "Due Date"; Date)
        {
            Caption = 'Due Date';
            DataClassification = CustomerContent;
        }
        field(13; "Requester ID"; Code[50])
        {
            Caption = 'Requester ID';
            NotBlank = true;
            TableRelation = User."User Name";
            ValidateTableRelation = false;
            DataClassification = EndUserIdentifiableInformation;

            trigger OnValidate()
            var
                UserSelection: Codeunit "User Selection";
            begin
                UserSelection.ValidateUserName("Requester ID");
            end;
        }
        field(14; Confirmed; Boolean)
        {
            Caption = 'Confirmed';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestField("Reordering Policy");
            end;
        }
        field(15; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
        }
        field(16; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
        }
        field(17; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
            TableRelation = Location WHERE("Use As In-Transit" = CONST(false));

            trigger OnValidate()
            begin

                "Bin Code" := '';

                CheckSKU();
            end;
        }
        field(18; "Recurring Method"; Option)
        {
            BlankZero = true;
            Caption = 'Recurring Method';
            DataClassification = CustomerContent;
            OptionCaption = ',Fixed,Variable';
            OptionMembers = ,"Fixed",Variable;
        }
        field(19; "Expiration Date"; Date)
        {
            Caption = 'Expiration Date';
            DataClassification = CustomerContent;
        }
        field(20; "Recurring Frequency"; DateFormula)
        {
            Caption = 'Recurring Frequency';
            DataClassification = CustomerContent;
        }
        field(21; "Order Date"; Date)
        {
            Caption = 'Order Date';
            DataClassification = CustomerContent;
        }
        field(22; "Vendor Item No."; Text[20])
        {
            Caption = 'Vendor Item No.';
            DataClassification = CustomerContent;
        }
        field(23; "Sales Order No."; Code[20])
        {
            Caption = 'Sales Order No.';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "Sales Header"."No." WHERE("Document Type" = CONST(Order));
        }
        field(24; "Sales Order Line No."; Integer)
        {
            Caption = 'Sales Order Line No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(25; "Sell-to Customer No."; Code[20])
        {
            Caption = 'Sell-to Customer No.';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = Customer;
        }
        field(26; "Ship-to Code"; Code[10])
        {
            Caption = 'Ship-to Code';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "Ship-to Address".Code WHERE("Customer No." = FIELD("Sell-to Customer No."));
        }
        field(28; "Order Address Code"; Code[10])
        {
            Caption = 'Order Address Code';
            DataClassification = CustomerContent;
            TableRelation = "Order Address".Code WHERE("Vendor No." = FIELD("Vendor No."));
        }
        field(29; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = CustomerContent;
            TableRelation = Currency;
        }
        field(30; "Currency Factor"; Decimal)
        {
            Caption = 'Currency Factor';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 15;
            MinValue = 0;
        }
        field(43; "Units per Parcel"; Decimal)
        {
            Caption = 'Units per Parcel';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Description = 'NPR5.39';
            MinValue = 0;
        }
        field(68; Inventory; Decimal)
        {
            CalcFormula = Sum("Item Ledger Entry".Quantity WHERE("Item No." = FIELD("Item No."),
                                                                  "Location Code" = FIELD("Location Code"),
                                                                  "Variant Code" = FIELD("Variant Code")));
            Caption = 'Inventory';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(84; "Qty. on Purch. Order"; Decimal)
        {
            AccessByPermission = TableData "Purch. Rcpt. Header" = R;
            CalcFormula = Sum("Purchase Line"."Outstanding Qty. (Base)" WHERE("Document Type" = CONST(Order),
                                                                               Type = CONST(Item),
                                                                               "No." = FIELD("Item No."),
                                                                               "Location Code" = FIELD("Location Code"),
                                                                               "Variant Code" = FIELD("Variant Code")));
            Caption = 'Qty. on Purch. Order';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(85; "Qty. on Sales Order"; Decimal)
        {
            AccessByPermission = TableData "Sales Shipment Header" = R;
            CalcFormula = Sum("Sales Line"."Outstanding Qty. (Base)" WHERE("Document Type" = CONST(Order),
                                                                            Type = CONST(Item),
                                                                            "No." = FIELD("Item No."),
                                                                            "Location Code" = FIELD("Location Code"),
                                                                            "Variant Code" = FIELD("Variant Code")));
            Caption = 'Qty. on Sales Order';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "Dimension Set Entry";

            trigger OnLookup()
            begin
                //ShowDimensions;
            end;
        }
        field(5402; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(5403; "Bin Code"; Code[20])
        {
            Caption = 'Bin Code';
            DataClassification = CustomerContent;
        }
        field(5404; "Qty. per Unit of Measure"; Decimal)
        {
            Caption = 'Qty. per Unit of Measure';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Editable = false;
            InitValue = 1;
        }
        field(5407; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            DataClassification = CustomerContent;
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(5408; "Quantity (Base)"; Decimal)
        {
            Caption = 'Quantity (Base)';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
        field(5440; "Reordering Policy"; Enum "Reordering Policy")
        {
            AccessByPermission = TableData "Req. Wksh. Template" = R;
            CalcFormula = Lookup("Stockkeeping Unit"."Reordering Policy" WHERE("Item No." = FIELD("Item No."),
                                                                                "Variant Code" = FIELD("Variant Code"),
                                                                                "Location Code" = FIELD("Location Code")));
            Caption = 'Reordering Policy';
            Editable = false;
            FieldClass = FlowField;
        }
        field(5520; "Demand Type"; Integer)
        {
            Caption = 'Demand Type';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = AllObjWithCaption."Object ID" WHERE("Object Type" = CONST(Table));
        }
        field(5521; "Demand Subtype"; Option)
        {
            Caption = 'Demand Subtype';
            DataClassification = CustomerContent;
            Editable = false;
            OptionCaption = '0,1,2,3,4,5,6,7,8,9';
            OptionMembers = "0","1","2","3","4","5","6","7","8","9";
        }
        field(5522; "Demand Order No."; Code[20])
        {
            Caption = 'Demand Order No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5525; "Demand Line No."; Integer)
        {
            Caption = 'Demand Line No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5526; "Demand Ref. No."; Integer)
        {
            Caption = 'Demand Ref. No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5527; Status; Option)
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            Editable = false;
            OptionCaption = 'Created,No SKU,No Planning,Adjusted,Ready,Approved,Completed';
            OptionMembers = "0","1","2","3","7","8","9";
        }
        field(5530; "Demand Date"; Date)
        {
            Caption = 'Demand Date';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5532; "Demand Quantity"; Decimal)
        {
            Caption = 'Demand Quantity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(5533; "Demand Quantity (Base)"; Decimal)
        {
            Caption = 'Demand Quantity (Base)';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(5538; "Needed Quantity"; Decimal)
        {
            BlankZero = true;
            Caption = 'Needed Quantity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(5539; "Needed Quantity (Base)"; Decimal)
        {
            BlankZero = true;
            Caption = 'Needed Quantity (Base)';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(5540; Reserve; Boolean)
        {
            Caption = 'Reserve';
            DataClassification = CustomerContent;
        }
        field(5541; "Qty. per UOM (Demand)"; Decimal)
        {
            Caption = 'Qty. per UOM (Demand)';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(5542; "Unit Of Measure Code (Demand)"; Code[10])
        {
            Caption = 'Unit Of Measure Code (Demand)';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(5552; "Supply From"; Code[20])
        {
            Caption = 'Supply From';
            DataClassification = CustomerContent;
        }
        field(5553; "Original Item No."; Code[20])
        {
            Caption = 'Original Item No.';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = Item;
        }
        field(5554; "Original Variant Code"; Code[10])
        {
            Caption = 'Original Variant Code';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Original Item No."));
        }
        field(5560; Level; Integer)
        {
            Caption = 'Level';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5563; "Demand Qty. Available"; Decimal)
        {
            Caption = 'Demand Qty. Available';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(5590; "User ID"; Code[50])
        {
            Caption = 'User ID';
            Editable = false;
            TableRelation = User."User Name";
            ValidateTableRelation = false;
            DataClassification = EndUserIdentifiableInformation;

            trigger OnValidate()
            var
                UserSelection: Codeunit "User Selection";
            begin
                UserSelection.ValidateUserName("User ID");
            end;
        }
        field(5701; "Item Category Code"; Code[20])
        {
            Caption = 'Item Category Code';
            DataClassification = CustomerContent;
            TableRelation = "Item Category";
        }
        field(5702; Nonstock; Boolean)
        {
            Caption = 'Nonstock';
            DataClassification = CustomerContent;
        }
        field(5703; "Purchasing Code"; Code[10])
        {
            Caption = 'Purchasing Code';
            DataClassification = CustomerContent;
            TableRelation = Purchasing;
        }
        field(5705; "Product Group Code"; Code[10])
        {
            Caption = 'Product Group Code';
            DataClassification = CustomerContent;
            ObsoleteState = No;
            //ObsoleteReason = 'Product Groups became first level children of Item Categories.';
            //ObsoleteTag = '15.0';
        }
        field(5706; "Transfer-from Code"; Code[10])
        {
            Caption = 'Transfer-from Code';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = Location WHERE("Use As In-Transit" = CONST(false));
        }
        field(5707; "Transfer Shipment Date"; Date)
        {
            AccessByPermission = TableData "Transfer Header" = R;
            Caption = 'Transfer Shipment Date';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(7002; "Line Discount %"; Decimal)
        {
            Caption = 'Line Discount %';
            DataClassification = CustomerContent;
            MaxValue = 100;
            MinValue = 0;
        }
        field(6151050; "Item Hierachy"; Code[20])
        {
            Caption = 'Item Hierachy';
            DataClassification = CustomerContent;
            TableRelation = "NPR Item Hierarchy";
        }
        field(6151055; "Distribution Group"; Code[20])
        {
            Caption = 'Distribution Group';
            DataClassification = CustomerContent;
            TableRelation = "NPR Distrib. Group";
        }
        field(6151056; "Store No."; Code[10])
        {
            Caption = 'Store No.';
            DataClassification = CustomerContent;
        }
        field(6151057; "Campaign Unit Price"; Decimal)
        {
            Caption = 'Period Price';
            DataClassification = CustomerContent;
            MaxValue = 9999999;
            MinValue = 0;
        }
        field(6151058; "Campaign Unit Cost"; Decimal)
        {
            Caption = 'Period Cost';
            DataClassification = CustomerContent;
        }
        field(6151061; "Page no. in advert"; Integer)
        {
            Caption = 'Page no. in advert';
            DataClassification = CustomerContent;
        }
        field(6151062; Priority; Code[10])
        {
            Caption = 'Priority';
            DataClassification = CustomerContent;
        }
        field(6151063; "Pagenumber in paper"; Text[30])
        {
            Caption = 'Pagenumber in paper';
            DataClassification = CustomerContent;
        }
        field(6151064; Photo; Boolean)
        {
            Caption = 'Photo';
            DataClassification = CustomerContent;
        }
        field(6151071; "Discount Comment"; Text[50])
        {
            Caption = 'Discount Comment';
            DataClassification = CustomerContent;
            Description = 'NPR5.39';
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Item No.")
        {
        }
        key(Key3; "Location Code")
        {
        }
    }

    fieldgroups
    {
    }

    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";

    local procedure CheckSKU()
    begin
    end;

    local procedure CalcBaseQty(Qty: Decimal): Decimal
    begin
        TestField("Qty. per Unit of Measure");
        exit(Round(Qty * "Qty. per Unit of Measure", 0.00001));
    end;

    local procedure GetItem()
    begin
        TestField("Item No.");
        if "Item No." <> Item."No." then
            Item.Get("Item No.");
    end;

    local procedure UpdateDescription()
    var
        ItemTranslation: Record "Item Translation";
        Vend: Record Vendor;
    begin
        if "Variant Code" = '' then begin
            GetItem();
            Description := Item.Description;
        end else begin
            ItemVariant.Get("Item No.", "Variant Code");
            Description := ItemVariant.Description;
        end;
        if "Vendor No." <> '' then begin
            Vend.Get("Vendor No.");
            if Vend."Language Code" <> '' then
                if ItemTranslation.Get("Item No.", "Variant Code", Vend."Language Code") then begin
                    Description := ItemTranslation.Description;
                end;
        end;
    end;
}