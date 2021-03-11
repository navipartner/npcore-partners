table 6060046 "NPR Regist. Item Worksh Line"
{
    Caption = 'Registered Item Worksheet Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Registered Worksheet No."; Integer)
        {
            Caption = 'Registered Worksheet No.';
            DataClassification = CustomerContent;
        }
        field(3; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(4; "Action"; Option)
        {
            Caption = 'Action';
            DataClassification = CustomerContent;
            OptionCaption = 'Skip,Create New,Update Only,Update and Create Variants';
            OptionMembers = Skip,CreateNew,UpdateOnly,UpdateAndCreateVariants;
        }
        field(5; "Existing Item No."; Code[20])
        {
            Caption = 'Existing Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item;
        }
        field(6; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item;
            ValidateTableRelation = false;
        }
        field(7; "Vendor Item No."; Text[20])
        {
            Caption = 'Vendor Item No.';
            DataClassification = CustomerContent;
        }
        field(8; "Internal Bar Code"; Code[50])
        {
            Caption = 'Internal Bar Code';
            DataClassification = CustomerContent;
        }
        field(9; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            DataClassification = CustomerContent;
        }
        field(10; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(11; "Description 2"; Text[50])
        {
            Caption = 'Description 2';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(12; "No. 2"; Code[20])
        {
            Caption = 'No. 2';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(13; Type; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            InitValue = Undefined;
            OptionCaption = 'Inventory,Service,,,,,,,,Undefined';
            OptionMembers = Inventory,Service,,,,,,,,Undefined;
        }
        field(15; "Shelf No."; Code[10])
        {
            Caption = 'Shelf No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(17; "Direct Unit Cost"; Decimal)
        {
            AutoFormatExpression = "Purchase Price Currency Code";
            AutoFormatType = 2;
            Caption = 'Direct Unit Cost';
            DataClassification = CustomerContent;
        }
        field(18; "Unit Price (LCY)"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit Price';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
        field(20; "Use Variant"; Boolean)
        {
            Caption = 'Use Variant';
            DataClassification = CustomerContent;
        }
        field(22; "Base Unit of Measure"; Code[10])
        {
            Caption = 'Base Unit of Measure';
            DataClassification = CustomerContent;
            TableRelation = "Unit of Measure";
            ValidateTableRelation = false;
        }
        field(23; "Inventory Posting Group"; Code[20])
        {
            Caption = 'Inventory Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "Inventory Posting Group";
            ValidateTableRelation = false;
        }
        field(24; "Costing Method"; Enum "Costing Method")
        {
            Caption = 'Costing Method';
            DataClassification = CustomerContent;
        }
        field(25; "Item Disc. Group"; Code[20])
        {
            Caption = 'Item Disc. Group';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            TableRelation = "Item Discount Group";
            ValidateTableRelation = false;
        }
        field(26; "Allow Invoice Disc."; Option)
        {
            Caption = 'Allow Invoice Disc.';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            InitValue = Undefined;
            OptionCaption = 'No,Yes,Undefined';
            OptionMembers = No,Yes,Undefined;
        }
        field(27; "Statistics Group"; Integer)
        {
            Caption = 'Statistics Group';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(28; "Commission Group"; Integer)
        {
            Caption = 'Commission Group';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(29; "Price/Profit Calculation"; Option)
        {
            Caption = 'Price/Profit Calculation';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            InitValue = Undefined;
            OptionCaption = 'Profit=Price-Cost,Price=Cost+Profit,No Relationship,,,,,,,Undefined';
            OptionMembers = "Profit=Price-Cost","Price=Cost+Profit","No Relationship",,,,,,,Undefined;
        }
        field(30; "Profit %"; Decimal)
        {
            Caption = 'Profit %';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Description = 'NPR5.25';
        }
        field(33; "Lead Time Calculation"; DateFormula)
        {
            AccessByPermission = TableData "Purch. Rcpt. Header" = R;
            Caption = 'Lead Time Calculation';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(34; "Reorder Point"; Decimal)
        {
            AccessByPermission = TableData "Req. Wksh. Template" = R;
            Caption = 'Reorder Point';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Description = 'NPR5.25';
        }
        field(35; "Vendors Bar Code"; Code[20])
        {
            Caption = 'Vendors Bar Code';
            DataClassification = CustomerContent;
        }
        field(36; "Maximum Inventory"; Decimal)
        {
            AccessByPermission = TableData "Req. Wksh. Template" = R;
            Caption = 'Maximum Inventory';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Description = 'NPR5.25';
        }
        field(37; "Reorder Quantity"; Decimal)
        {
            AccessByPermission = TableData "Req. Wksh. Template" = R;
            Caption = 'Reorder Quantity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Description = 'NPR5.25';
        }
        field(38; "Unit List Price"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit List Price';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            MinValue = 0;
        }
        field(39; "Duty Due %"; Decimal)
        {
            Caption = 'Duty Due %';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Description = 'NPR5.25';
            MaxValue = 100;
            MinValue = 0;
        }
        field(40; "Duty Code"; Code[10])
        {
            Caption = 'Duty Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(43; "Units per Parcel"; Decimal)
        {
            Caption = 'Units per Parcel';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Description = 'NPR5.25';
            MinValue = 0;
        }
        field(44; "Unit Volume"; Decimal)
        {
            Caption = 'Unit Volume';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Description = 'NPR5.25';
            MinValue = 0;
        }
        field(45; Durability; Code[10])
        {
            Caption = 'Durability';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(46; "Freight Type"; Code[10])
        {
            Caption = 'Freight Type';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(47; "Tariff No."; Code[20])
        {
            Caption = 'Tariff No.';
            DataClassification = CustomerContent;
            TableRelation = "Tariff Number";
            ValidateTableRelation = false;
        }
        field(48; "Duty Unit Conversion"; Decimal)
        {
            Caption = 'Duty Unit Conversion';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Description = 'NPR5.25';
        }
        field(49; "Country/Region Purchased Code"; Code[10])
        {
            Caption = 'Country/Region Purchased Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            TableRelation = "Country/Region";
            ValidateTableRelation = false;
        }
        field(50; "Budget Quantity"; Decimal)
        {
            Caption = 'Budget Quantity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Description = 'NPR5.25';
        }
        field(51; "Budgeted Amount"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Budgeted Amount';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(52; "Budget Profit"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Budget Profit';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(54; Blocked; Option)
        {
            Caption = 'Blocked';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            InitValue = Undefined;
            OptionCaption = 'No,Yes,Undefined';
            OptionMembers = No,Yes,Undefined;
        }
        field(87; "Price Includes VAT"; Option)
        {
            Caption = 'Price Includes VAT';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            InitValue = Undefined;
            OptionCaption = 'No,Yes,Undefined';
            OptionMembers = No,Yes,Undefined;
        }
        field(89; "VAT Bus. Posting Group"; Code[20])
        {
            Caption = 'VAT Bus. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "VAT Business Posting Group";
            ValidateTableRelation = false;
        }
        field(90; "VAT Bus. Posting Gr. (Price)"; Code[20])
        {
            Caption = 'VAT Bus. Posting Gr. (Price)';
            DataClassification = CustomerContent;
            TableRelation = "VAT Business Posting Group";
            ValidateTableRelation = false;
        }
        field(91; "Gen. Prod. Posting Group"; Code[20])
        {
            Caption = 'Gen. Prod. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "Gen. Product Posting Group";
            ValidateTableRelation = false;
        }
        field(95; "Country/Region of Origin Code"; Code[10])
        {
            Caption = 'Country/Region of Origin Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            TableRelation = "Country/Region";
            ValidateTableRelation = false;
        }
        field(96; "Automatic Ext. Texts"; Option)
        {
            Caption = 'Automatic Ext. Texts';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            InitValue = Undefined;
            OptionCaption = 'No,Yes,Undefined';
            OptionMembers = No,Yes,Undefined;
        }
        field(97; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
            ValidateTableRelation = false;
        }
        field(98; "Tax Group Code"; Code[20])
        {
            Caption = 'Tax Group Code';
            DataClassification = CustomerContent;
            TableRelation = "Tax Group";
            ValidateTableRelation = false;
        }
        field(99; "VAT Prod. Posting Group"; Code[20])
        {
            Caption = 'VAT Prod. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "VAT Product Posting Group";
            ValidateTableRelation = false;
        }
        field(100; Reserve; Option)
        {
            AccessByPermission = TableData "Purch. Rcpt. Header" = R;
            Caption = 'Reserve';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            InitValue = Undefined;
            OptionCaption = 'Never,Optional,Always,,,,,,,Undefined';
            OptionMembers = Never,Optional,Always,,,,,,,Undefined;
        }
        field(105; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
            ValidateTableRelation = false;
        }
        field(106; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
            ValidateTableRelation = false;
        }
        field(120; "Stockout Warning"; Option)
        {
            Caption = 'Stockout Warning';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            InitValue = Undefined;
            OptionCaption = 'Default,No,Yes,,,,,,,Undefined';
            OptionMembers = Default,No,Yes,,,,,,,Undefined;
        }
        field(121; "Prevent Negative Inventory"; Option)
        {
            Caption = 'Prevent Negative Inventory';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            InitValue = Undefined;
            OptionCaption = 'Default,No,Yes,,,,,,,Undefined';
            OptionMembers = Default,No,Yes,,,,,,,Undefined;
        }
        field(150; Status; Option)
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            OptionCaption = 'Unvalidated,Error,Warning,Validated,Processed';
            OptionMembers = Unvalidated,Error,Warning,Validated,Processed;
        }
        field(151; "Status Comment"; Text[250])
        {
            Caption = 'Status Comment';
            DataClassification = CustomerContent;
        }
        field(200; "Variety 1"; Code[10])
        {
            Caption = 'Variety 1';
            DataClassification = CustomerContent;
            Description = 'Variety';
            TableRelation = "NPR Variety";
            ValidateTableRelation = false;
        }
        field(201; "Variety 1 Table (Base)"; Code[40])
        {
            Caption = 'Variety 1 Table';
            DataClassification = CustomerContent;
            Description = 'Variety';
            TableRelation = "NPR Variety Table".Code WHERE(Type = FIELD("Variety 1"));
            ValidateTableRelation = false;
        }
        field(202; "Create Copy of Variety 1 Table"; Boolean)
        {
            Caption = 'Create Copy of Variety 1 Table';
            DataClassification = CustomerContent;
            Description = 'Variety';
        }
        field(203; "Variety 1 Table (New)"; Code[20])
        {
            Caption = 'Variety 1 Table (New)';
            DataClassification = CustomerContent;
            Description = 'Variety';
        }
        field(204; "Variety 1 Lock Table"; Boolean)
        {
            Caption = 'Variety 1 Lock Table';
            DataClassification = CustomerContent;
            Description = 'Variety';
        }
        field(210; "Variety 2"; Code[10])
        {
            Caption = 'Variety 2';
            DataClassification = CustomerContent;
            Description = 'Variety';
            TableRelation = "NPR Variety";
            ValidateTableRelation = false;
        }
        field(211; "Variety 2 Table (Base)"; Code[40])
        {
            Caption = 'Variety 2 Table';
            DataClassification = CustomerContent;
            Description = 'Variety';
            TableRelation = "NPR Variety Table".Code WHERE(Type = FIELD("Variety 2"));
            ValidateTableRelation = false;
        }
        field(212; "Create Copy of Variety 2 Table"; Boolean)
        {
            Caption = 'Create Copy of Variety 2 Table';
            DataClassification = CustomerContent;
            Description = 'Variety';
        }
        field(213; "Variety 2 Table (New)"; Code[20])
        {
            Caption = 'Variety 2 Table (New)';
            DataClassification = CustomerContent;
            Description = 'Variety';
        }
        field(214; "Variety 2 Lock Table"; Boolean)
        {
            Caption = 'Variety 2 Lock Table';
            DataClassification = CustomerContent;
            Description = 'Variety';
        }
        field(220; "Variety 3"; Code[10])
        {
            Caption = 'Variety 3';
            DataClassification = CustomerContent;
            Description = 'Variety';
            TableRelation = "NPR Variety";
            ValidateTableRelation = false;
        }
        field(221; "Variety 3 Table (Base)"; Code[40])
        {
            Caption = 'Variety 3 Table';
            DataClassification = CustomerContent;
            Description = 'Variety';
            TableRelation = "NPR Variety Table".Code WHERE(Type = FIELD("Variety 3"));
            ValidateTableRelation = false;
        }
        field(222; "Create Copy of Variety 3 Table"; Boolean)
        {
            Caption = 'Create Copy of Variety 3 Table';
            DataClassification = CustomerContent;
            Description = 'Variety';
        }
        field(223; "Variety 3 Table (New)"; Code[20])
        {
            Caption = 'Variety 3 Table (New)';
            DataClassification = CustomerContent;
            Description = 'Variety';
        }
        field(224; "Variety 3 Lock Table"; Boolean)
        {
            Caption = 'Variety 3 Lock Table';
            DataClassification = CustomerContent;
            Description = 'Variety';
        }
        field(230; "Variety 4"; Code[10])
        {
            Caption = 'Variety 4';
            DataClassification = CustomerContent;
            Description = 'Variety';
            TableRelation = "NPR Variety";
            ValidateTableRelation = false;
        }
        field(231; "Variety 4 Table (Base)"; Code[40])
        {
            Caption = 'Variety 4 Table';
            DataClassification = CustomerContent;
            Description = 'Variety';
            TableRelation = "NPR Variety Table".Code WHERE(Type = FIELD("Variety 4"));
            ValidateTableRelation = false;
        }
        field(232; "Create Copy of Variety 4 Table"; Boolean)
        {
            Caption = 'Create Copy of Variety 4 Table';
            DataClassification = CustomerContent;
            Description = 'Variety';
        }
        field(233; "Variety 4 Table (New)"; Code[20])
        {
            Caption = 'Variety 4 Table (New)';
            DataClassification = CustomerContent;
            Description = 'Variety';
        }
        field(234; "Variety 4 Lock Table"; Boolean)
        {
            Caption = 'Variety 4 Lock Table';
            DataClassification = CustomerContent;
            Description = 'Variety';
        }
        field(240; "Cross Variety No."; Option)
        {
            Caption = 'Cross Variety No.';
            DataClassification = CustomerContent;
            Description = 'Variety';
            OptionCaption = 'Variety 1,Variety 2,Variety 3,Variety 4';
            OptionMembers = Variety1,Variety2,Variety3,Variety4;
        }
        field(250; "Variety Group"; Code[20])
        {
            Caption = 'Variety Group';
            DataClassification = CustomerContent;
            Description = 'Variety';
            TableRelation = "NPR Variety Group";
            ValidateTableRelation = false;
        }
        field(300; "Variant Code"; Code[20])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
        }
        field(400; "Sales Price Currency Code"; Code[10])
        {
            Caption = 'Sales Price Currency Code';
            DataClassification = CustomerContent;
            TableRelation = Currency;
            ValidateTableRelation = false;
        }
        field(410; "Purchase Price Currency Code"; Code[10])
        {
            Caption = 'Purchase Price Currency Code';
            DataClassification = CustomerContent;
            TableRelation = Currency;
            ValidateTableRelation = false;
        }
        field(910; "Assembly Policy"; Option)
        {
            AccessByPermission = TableData "BOM Component" = R;
            Caption = 'Assembly Policy';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            InitValue = Undefined;
            OptionCaption = 'Assemble-to-Stock,Assemble-to-Order,,,,,,,,Undefined';
            OptionMembers = "Assemble-to-Stock","Assemble-to-Order",,,,,,,,Undefined;
        }
        field(1217; GTIN; Code[14])
        {
            Caption = 'GTIN';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            Numeric = true;
        }
        field(5401; "Lot Size"; Decimal)
        {
            AccessByPermission = TableData "Production Order" = R;
            Caption = 'Lot Size';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Description = 'NPR5.25';
            MinValue = 0;
        }
        field(5402; "Serial Nos."; Code[20])
        {
            Caption = 'Serial Nos.';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            TableRelation = "No. Series";
            ValidateTableRelation = false;
        }
        field(5407; "Scrap %"; Decimal)
        {
            AccessByPermission = TableData "Production Order" = R;
            Caption = 'Scrap %';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
            Description = 'NPR5.25';
            MaxValue = 100;
            MinValue = 0;
        }
        field(5409; "Inventory Value Zero"; Option)
        {
            Caption = 'Inventory Value Zero';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            InitValue = Undefined;
            OptionCaption = 'No,Yes,Undefined';
            OptionMembers = No,Yes,Undefined;
        }
        field(5410; "Discrete Order Quantity"; Integer)
        {
            Caption = 'Discrete Order Quantity';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            MinValue = 0;
        }
        field(5411; "Minimum Order Quantity"; Decimal)
        {
            AccessByPermission = TableData "Req. Wksh. Template" = R;
            Caption = 'Minimum Order Quantity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Description = 'NPR5.25';
            MinValue = 0;
        }
        field(5412; "Maximum Order Quantity"; Decimal)
        {
            AccessByPermission = TableData "Req. Wksh. Template" = R;
            Caption = 'Maximum Order Quantity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Description = 'NPR5.25';
            MinValue = 0;
        }
        field(5413; "Safety Stock Quantity"; Decimal)
        {
            AccessByPermission = TableData "Req. Wksh. Template" = R;
            Caption = 'Safety Stock Quantity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Description = 'NPR5.25';
            MinValue = 0;
        }
        field(5414; "Order Multiple"; Decimal)
        {
            AccessByPermission = TableData "Req. Wksh. Template" = R;
            Caption = 'Order Multiple';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Description = 'NPR5.25';
            MinValue = 0;
        }
        field(5415; "Safety Lead Time"; DateFormula)
        {
            AccessByPermission = TableData "Req. Wksh. Template" = R;
            Caption = 'Safety Lead Time';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(5417; "Flushing Method"; Option)
        {
            AccessByPermission = TableData "Production Order" = R;
            Caption = 'Flushing Method';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            InitValue = Undefined;
            OptionCaption = 'Manual,Forward,Backward,Pick + Forward,Pick + Backward,,,,,Undefined';
            OptionMembers = Manual,Forward,Backward,"Pick + Forward","Pick + Backward",,,,,Undefined;
        }
        field(5419; "Replenishment System"; Option)
        {
            AccessByPermission = TableData "Req. Wksh. Template" = R;
            Caption = 'Replenishment System';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            InitValue = Undefined;
            OptionCaption = 'Purchase,Prod. Order,,Assembly,,,,,,Undefined';
            OptionMembers = Purchase,"Prod. Order",,Assembly,,,,,,Undefined;
        }
        field(5425; "Sales Unit of Measure"; Code[10])
        {
            Caption = 'Sales Unit of Measure';
            DataClassification = CustomerContent;
            TableRelation = "Unit of Measure";
            ValidateTableRelation = false;
        }
        field(5426; "Purch. Unit of Measure"; Code[10])
        {
            Caption = 'Purch. Unit of Measure';
            DataClassification = CustomerContent;
            TableRelation = "Unit of Measure";
            ValidateTableRelation = false;
        }
        field(5440; "Reordering Policy"; Option)
        {
            AccessByPermission = TableData "Req. Wksh. Template" = R;
            Caption = 'Reordering Policy';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            InitValue = Undefined;
            OptionCaption = ' ,Fixed Reorder Qty.,Maximum Qty.,Order,Lot-for-Lot,,,,,Undefined';
            OptionMembers = " ","Fixed Reorder Qty.","Maximum Qty.","Order","Lot-for-Lot",,,,,Undefined;
        }
        field(5441; "Include Inventory"; Option)
        {
            AccessByPermission = TableData "Req. Wksh. Template" = R;
            Caption = 'Include Inventory';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            InitValue = Undefined;
            OptionCaption = 'No,Yes,Undefined';
            OptionMembers = No,Yes,Undefined;
        }
        field(5442; "Manufacturing Policy"; Option)
        {
            AccessByPermission = TableData "Req. Wksh. Template" = R;
            Caption = 'Manufacturing Policy';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            InitValue = Undefined;
            OptionCaption = 'Make-to-Stock,Make-to-Order,,,,,,,,Undefined';
            OptionMembers = "Make-to-Stock","Make-to-Order",,,,,,,,Undefined;
        }
        field(5443; "Rescheduling Period"; DateFormula)
        {
            AccessByPermission = TableData "Req. Wksh. Template" = R;
            Caption = 'Rescheduling Period';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(5444; "Lot Accumulation Period"; DateFormula)
        {
            AccessByPermission = TableData "Req. Wksh. Template" = R;
            Caption = 'Lot Accumulation Period';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(5445; "Dampener Period"; DateFormula)
        {
            AccessByPermission = TableData "Req. Wksh. Template" = R;
            Caption = 'Dampener Period';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(5446; "Dampener Quantity"; Decimal)
        {
            AccessByPermission = TableData "Req. Wksh. Template" = R;
            Caption = 'Dampener Quantity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Description = 'NPR5.25';
            MinValue = 0;
        }
        field(5447; "Overflow Level"; Decimal)
        {
            AccessByPermission = TableData "Req. Wksh. Template" = R;
            Caption = 'Overflow Level';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Description = 'NPR5.25';
            MinValue = 0;
        }
        field(5701; "Manufacturer Code"; Code[10])
        {
            Caption = 'Manufacturer Code';
            DataClassification = CustomerContent;
            TableRelation = Manufacturer;
            ValidateTableRelation = false;
        }
        field(5702; "Item Category Code"; Code[20])
        {
            Caption = 'Item Category Code';
            DataClassification = CustomerContent;
            TableRelation = "Item Category";
            ValidateTableRelation = false;
        }
        field(5704; "Product Group Code"; Code[10])
        {
            Caption = 'Product Group Code';
            DataClassification = CustomerContent;
            ObsoleteState = No;
            //ObsoleteReason = 'Product Groups became first level children of Item Categories.';
            //ObsoleteTag = '15.0';
        }
        field(5900; "Service Item Group"; Code[10])
        {
            Caption = 'Service Item Group';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            TableRelation = "Service Item Group".Code;
            ValidateTableRelation = false;
        }
        field(6500; "Item Tracking Code"; Code[10])
        {
            Caption = 'Item Tracking Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            TableRelation = "Item Tracking Code";
            ValidateTableRelation = false;
        }
        field(6501; "Lot Nos."; Code[20])
        {
            Caption = 'Lot Nos.';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            TableRelation = "No. Series";
            ValidateTableRelation = false;
        }
        field(6502; "Expiration Calculation"; DateFormula)
        {
            Caption = 'Expiration Calculation';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(7301; "Special Equipment Code"; Code[10])
        {
            Caption = 'Special Equipment Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            TableRelation = "Special Equipment";
            ValidateTableRelation = false;
        }
        field(7302; "Put-away Template Code"; Code[10])
        {
            Caption = 'Put-away Template Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            TableRelation = "Put-away Template Header";
            ValidateTableRelation = false;
        }
        field(7307; "Put-away Unit of Measure Code"; Code[10])
        {
            AccessByPermission = TableData "Posted Invt. Put-away Header" = R;
            Caption = 'Put-away Unit of Measure Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(7380; "Phys Invt Counting Period Code"; Code[10])
        {
            Caption = 'Phys Invt Counting Period Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            TableRelation = "Phys. Invt. Counting Period";
            ValidateTableRelation = false;
        }
        field(7384; "Use Cross-Docking"; Option)
        {
            AccessByPermission = TableData "Bin Content" = R;
            Caption = 'Use Cross-Docking';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            InitValue = Undefined;
            OptionCaption = 'No,Yes,Undefined';
            OptionMembers = No,Yes,Undefined;
        }
        field(8001; "Custom Text 1"; Text[50])
        {
            Caption = 'Custom Text 1';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(8002; "Custom Text 2"; Text[50])
        {
            Caption = 'Custom Text 2';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(8003; "Custom Text 3"; Text[50])
        {
            Caption = 'Custom Text 3';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(8004; "Custom Text 4"; Text[50])
        {
            Caption = 'Custom Text 4';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(8005; "Custom Text 5"; Text[50])
        {
            Caption = 'Custom Text 5';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(8011; "Custom Price 1"; Decimal)
        {
            Caption = 'Custom Price 1';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(8012; "Custom Price 2"; Decimal)
        {
            Caption = 'Custom Price 2';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(8013; "Custom Price 3"; Decimal)
        {
            Caption = 'Custom Price 3';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(8014; "Custom Price 4"; Decimal)
        {
            Caption = 'Custom Price 4';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(8015; "Custom Price 5"; Decimal)
        {
            Caption = 'Custom Price 5';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(8100; "Sales Price Start Date"; Date)
        {
            Caption = 'Sales Price Start Date';
            DataClassification = CustomerContent;
            Description = 'NPR5.38';
        }
        field(8101; "Purchase Price Start Date"; Date)
        {
            Caption = 'Purchase Price Start Date';
            DataClassification = CustomerContent;
            Description = 'NPR5.38';
        }
        field(6014400; "Item Group"; Code[10])
        {
            Caption = 'Item Group';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Using Item Category Code instead.';
        }
        field(6014401; "Group sale"; Option)
        {
            Caption = 'Various item sales';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            InitValue = Undefined;
            OptionCaption = 'No,Yes,Undefined';
            OptionMembers = No,Yes,Undefined;
        }
        field(6014408; Season; Code[3])
        {
            Caption = 'Season';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(6014410; "Label Barcode"; Code[20])
        {
            Caption = 'Label barcode';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(6014418; "Explode BOM auto"; Option)
        {
            Caption = 'Auto-explode BOM';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            InitValue = Undefined;
            OptionCaption = 'No,Yes,Undefined';
            OptionMembers = No,Yes,Undefined;
        }
        field(6014419; "Guarantee voucher"; Option)
        {
            Caption = 'Guarantee voucher';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            InitValue = Undefined;
            OptionCaption = 'No,Yes,Undefined';
            OptionMembers = No,Yes,Undefined;
        }
        field(6014424; "Cannot edit unit price"; Option)
        {
            Caption = 'Can''t edit unit price';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            InitValue = Undefined;
            OptionCaption = 'No,Yes,Undefined';
            OptionMembers = No,Yes,Undefined;
        }
        field(6014500; "Second-hand number"; Code[20])
        {
            Caption = 'Second-hand number';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(6014502; Condition; Option)
        {
            Caption = 'Condition';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            InitValue = Undefined;
            OptionCaption = 'New,Mint,Mint boxed,A,B,C,D,E,F,Undefined';
            OptionMembers = New,Mint,"Mint boxed",A,B,C,D,E,F,Undefined;
        }
        field(6014503; "Second-hand"; Option)
        {
            Caption = 'Second-hand';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            InitValue = Undefined;
            OptionCaption = 'No,Yes,Undefined';
            OptionMembers = No,Yes,Undefined;
        }
        field(6014504; "Guarantee Index"; Option)
        {
            Caption = 'Guarantee Index';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            InitValue = Undefined;
            OptionCaption = ' ,Flyt til garanti kar.,,,,,,,,Undefined';
            OptionMembers = " ","Flyt til garanti kar.",,,,,,,,Undefined;
        }
        field(6014508; "Insurrance category"; Code[50])
        {
            Caption = 'Insurance Section';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            TableRelation = "NPR Insurance Category";
            ValidateTableRelation = false;
        }
        field(6014509; "Item Brand"; Code[10])
        {
            Caption = 'Item brand';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(6014511; "Type Retail"; Code[10])
        {
            Caption = 'Type Retail';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(6014512; "No Print on Reciept"; Option)
        {
            Caption = 'No Print on Reciept';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            InitValue = Undefined;
            OptionCaption = 'No,Yes,Undefined';
            OptionMembers = No,Yes,Undefined;
        }
        field(6014513; "Print Tags"; Text[100])
        {
            Caption = 'Print Tags';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(6014607; "Change quantity by Photoorder"; Option)
        {
            Caption = 'Change quantity by Photoorder';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            InitValue = Undefined;
            OptionCaption = 'No,Yes,Undefined';
            OptionMembers = No,Yes,Undefined;
        }
        field(6014625; "Std. Sales Qty."; Decimal)
        {
            Caption = 'Std. Sales Qty.';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(6014630; "Blocked on Pos"; Option)
        {
            Caption = 'Blocked on Pos';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            InitValue = Undefined;
            OptionCaption = 'No,Yes,Undefined';
            OptionMembers = No,Yes,Undefined;
        }
        field(6059784; "Ticket Type"; Code[10])
        {
            Caption = 'Ticket Type';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            TableRelation = "NPR TM Ticket Type";
            ValidateTableRelation = false;
        }
        field(6151400; "Magento Item"; Option)
        {
            Caption = 'Magento Item';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            OptionCaption = 'No,Yes,Undefined';
            OptionMembers = No,Yes,Undefined;
        }
        field(6151405; "Magento Status"; Option)
        {
            BlankZero = true;
            Caption = 'Magento Status';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            InitValue = Active;
            OptionCaption = ',Active,Inactive';
            OptionMembers = ,Active,Inactive;
        }
        field(6151410; "Attribute Set ID"; Integer)
        {
            Caption = 'Attribute Set ID';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            TableRelation = "NPR Magento Attribute Set";
        }
        field(6151415; "Magento Description"; BLOB)
        {
            Caption = 'Magento Description';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(6151420; "Magento Name"; Text[250])
        {
            Caption = 'Magento Name';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(6151425; "Magento Short Description"; BLOB)
        {
            Caption = 'Magento Short Description';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(6151430; "Magento Brand"; Code[20])
        {
            Caption = 'Magento Brand';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            TableRelation = "NPR Magento Brand";
            ValidateTableRelation = false;
        }
        field(6151435; "Seo Link"; Text[250])
        {
            Caption = 'Seo Link';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(6151440; "Meta Title"; Text[70])
        {
            Caption = 'Meta Title';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(6151445; "Meta Description"; Text[250])
        {
            Caption = 'Meta Description';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(6151450; "Product New From"; Date)
        {
            Caption = 'Product New From';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(6151455; "Product New To"; Date)
        {
            Caption = 'Product New To';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(6151460; "Special Price"; Decimal)
        {
            Caption = 'Special Price';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(6151465; "Special Price From"; Date)
        {
            Caption = 'Special Price From';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(6151470; "Special Price To"; Date)
        {
            Caption = 'Special Price To';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(6151475; "Featured From"; Date)
        {
            Caption = 'Featured From';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(6151480; "Featured To"; Date)
        {
            Caption = 'Featured To';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(6151485; Backorder; Option)
        {
            Caption = 'Backorder';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            OptionCaption = 'No,Yes,Undefined';
            OptionMembers = No,Yes,Undefined;
        }
        field(6151490; "Display Only"; Option)
        {
            Caption = 'Display Only';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            OptionCaption = 'No,Yes,Undefined';
            OptionMembers = No,Yes,Undefined;
        }
        field(99000750; "Routing No."; Code[20])
        {
            Caption = 'Routing No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            TableRelation = "Routing Header";
            ValidateTableRelation = false;
        }
        field(99000751; "Production BOM No."; Code[20])
        {
            Caption = 'Production BOM No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            TableRelation = "Production BOM Header";
            ValidateTableRelation = false;
        }
        field(99000757; "Overhead Rate"; Decimal)
        {
            AccessByPermission = TableData "Production Order" = R;
            AutoFormatType = 2;
            Caption = 'Overhead Rate';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(99000773; "Order Tracking Policy"; Option)
        {
            Caption = 'Order Tracking Policy';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            InitValue = Undefined;
            OptionCaption = 'None,Tracking Only,Tracking & Action Msg.,,,,,,,Undefined';
            OptionMembers = "None","Tracking Only","Tracking & Action Msg.",,,,,,,Undefined;
        }
        field(99000875; Critical; Option)
        {
            Caption = 'Critical';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            InitValue = Undefined;
            OptionCaption = 'No,Yes,Undefined';
            OptionMembers = No,Yes,Undefined;
        }
        field(99008500; "Common Item No."; Code[20])
        {
            Caption = 'Common Item No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
    }

    keys
    {
        key(Key1; "Registered Worksheet No.", "Line No.")
        {
        }
    }

    trigger OnDelete()
    var
        ItemWorksheetVar: Record "NPR Item Worksh. Variant Line";
        ItemWorksheetVrtValue: Record "NPR Item Worksh. Variety Value";
    begin
        RegItemWshtVariantLine.Reset();
        RegItemWshtVariantLine.SetRange("Registered Worksheet No.", "Registered Worksheet No.");
        RegItemWshtVariantLine.SetRange("Registered Worksheet Line No.", "Line No.");
        RegItemWshtVariantLine.DeleteAll();

        RegItemWshtVarietyValue.Reset();
        RegItemWshtVarietyValue.SetRange("Registered Worksheet No.", "Registered Worksheet No.");
        RegItemWshtVarietyValue.SetRange("Registered Worksheet Line No.", "Line No.");
        RegItemWshtVarietyValue.DeleteAll();
    end;

    var
        RegItemWshtVariantLine: Record "NPR Reg. Item Wsht Var. Line";
        RegItemWshtVarietyValue: Record "NPR Reg. Item Wsht Var. Value";
}