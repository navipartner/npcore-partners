table 6151371 "NPR CS Setup"
{
    Caption = 'CS Setup';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteReason = 'Object moved to NP Warehouse App.';


    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(11; "Enable Capture Service"; Boolean)
        {
            Caption = 'Enable Capture Service';
            DataClassification = CustomerContent;
        }
        field(12; "Log Communication"; Boolean)
        {
            Caption = 'Log Communication';
            DataClassification = CustomerContent;
        }
        field(14; "Filter Worksheets by Location"; Boolean)
        {
            Caption = 'Filter Worksheets by Location';
            DataClassification = CustomerContent;
            Description = 'Filtering Worksheets by User Location';
        }
        field(15; "Error On Invalid Barcode"; Boolean)
        {
            Caption = 'Error On Invalid Barcode';
            DataClassification = CustomerContent;
            Description = 'Show alert on IOS if barcode is invalid';
        }
        field(16; "Price Calc. Customer No."; Code[20])
        {
            Caption = 'Price Calc. Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer;
        }
        field(17; "Max Records In Search Result"; Integer)
        {
            Caption = 'Max Records In Search Result';
            DataClassification = CustomerContent;
            InitValue = 100;
        }
        field(18; "Aggregate Stock-Take Summarize"; Boolean)
        {
            Caption = 'Aggregate Stock-Take Summarize';
            DataClassification = CustomerContent;
        }
        field(19; "Warehouse Type"; Option)
        {
            Caption = 'Warehouse Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Basic,Advanced,Advanced (Bins)';
            OptionMembers = Basic," Advanced"," Advanced (Bins)";
        }
        field(20; "Media Library"; Option)
        {
            Caption = 'Media Library';
            DataClassification = CustomerContent;
            OptionCaption = 'Dynamics NAV,Magento';
            OptionMembers = "Dynamics NAV",Magento;
        }
        field(22; "Stock-Take Template"; Code[10])
        {
            Caption = 'Stock-Take Template';
            DataClassification = CustomerContent;
        }
        field(23; "Zero Def. Qty. to Handle"; Boolean)
        {
            Caption = 'Zero Def. Qty. to Handle';
            DataClassification = CustomerContent;
        }
        field(24; "Item Reclass. Jour Temp Name"; Code[10])
        {
            Caption = 'Item Reclass. Jour Temp Name';
            DataClassification = CustomerContent;
            TableRelation = "Item Journal Template";
        }
        field(25; "Item Reclass. Jour Batch Name"; Code[10])
        {
            Caption = 'Item Reclass. Jour Batch Name';
            DataClassification = CustomerContent;
            TableRelation = "Item Journal Batch".Name WHERE("Journal Template Name" = FIELD("Item Reclass. Jour Temp Name"));
        }
        field(26; "Create Worksheet after Trans."; Boolean)
        {
            Caption = 'Create Worksheet after Trans.';
            DataClassification = CustomerContent;
        }
        field(27; "Phys. Inv Jour Temp Name"; Code[10])
        {
            Caption = 'Phys. Inv Jour Temp Name';
            DataClassification = CustomerContent;
            TableRelation = "Item Journal Template";
        }
        field(28; "Phys. Inv Jour No. Series"; Code[20])
        {
            Caption = 'Phys. Inv Jour No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(29; "Sum Qty. to Handle"; Boolean)
        {
            Caption = 'Sum Qty. to Handle';
            DataClassification = CustomerContent;
        }
        field(38; "Post with Job Queue"; Boolean)
        {
            Caption = 'Post with Job Queue';
            DataClassification = CustomerContent;
        }
        field(39; "Job Queue Category Code"; Code[10])
        {
            Caption = 'Job Queue Category Code';
            DataClassification = CustomerContent;
            TableRelation = "Job Queue Category";
        }
        field(40; "Job Queue Priority for Post"; Integer)
        {
            Caption = 'Job Queue Priority for Post';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Target field Prioriti on Job Queue Entry is removed!';
        }
        field(41; "Notify On Success"; Boolean)
        {
            Caption = 'Notify On Success';
            DataClassification = CustomerContent;
        }
        field(42; "Run in User Session"; Boolean)
        {
            Caption = 'Run in User Session';
            DataClassification = CustomerContent;
        }
        field(43; "Earliest Start Date/Time"; DateTime)
        {
            Caption = 'Earliest Start Date/Time';
            DataClassification = CustomerContent;
        }
        field(44; "Batch Size"; Integer)
        {
            Caption = 'Batch Size';
            DataClassification = CustomerContent;
            MaxValue = 1000;
            MinValue = 10;
        }
        field(45; "Import Tags to Shipping Doc."; Boolean)
        {
            Caption = 'Import Tags to Shipping Doc.';
            DataClassification = CustomerContent;
        }
        field(46; "Use Whse. Receipt"; Boolean)
        {
            Caption = 'Use Whse. Receipt';
            DataClassification = CustomerContent;
        }
        field(50; "Disregard Unknown RFID Tags"; Boolean)
        {
            Caption = 'Disregard Unknown RFID Tags';
            DataClassification = CustomerContent;
            Description = 'NPR5.55 clean rfid tag values not found in our setup while scanning';
        }
        field(51; "Exclude Invt. Posting Groups"; Text[100])
        {
            Caption = 'Exclude Invt. Posting Groups';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
        }
    }

    fieldgroups
    {
    }
}