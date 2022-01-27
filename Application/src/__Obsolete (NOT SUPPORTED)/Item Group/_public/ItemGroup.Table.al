table 6014410 "NPR Item Group"
{
    Caption = 'Item Group';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteReason = 'Using Item Category table instead.';

    fields
    {
        field(1; "No."; Code[10])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            NotBlank = true;
            ObsoleteState = Removed;
            ObsoleteReason = 'Using Item Category table instead.';
        }
        field(2; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Using Item Category table instead.';
        }
        field(3; "Search Description"; Text[50])
        {
            Caption = 'Search Description';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Using Item Category table instead.';
        }
        field(4; "Parent Item Group No."; Code[10])
        {
            Caption = 'Parent Item Group No.';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Using Item Category table instead.';
        }
        field(5; "Belongs In Main Item Group"; Code[10])
        {
            Caption = 'Belongs in Main Item Group';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Using Item Category table instead.';
        }
        field(7; "Sorting-Key"; Text[250])
        {
            Caption = 'Sorting Key';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Using Item Category table instead.';
        }
        field(8; Blocked; Boolean)
        {
            Caption = 'Blocked';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Using Item Category table instead.';
        }
        field(9; "Created Date"; Date)
        {
            Caption = 'Created Date';
            DataClassification = CustomerContent;
            Editable = false;
            ObsoleteState = Removed;
            ObsoleteReason = 'Using Item Category table instead.';
        }
        field(10; "Last Date Modified"; Date)
        {
            Caption = 'Last Date Modified';
            DataClassification = CustomerContent;
            Editable = false;
            ObsoleteState = Removed;
            ObsoleteReason = 'Using Item Category table instead.';
        }
        field(11; Type; Enum "Item Type")
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Using Item Category table instead.';
        }
        field(12; "VAT Prod. Posting Group"; Code[20])
        {
            Caption = 'VAT Prod. Posting Group';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Using Item Category table instead.';
        }
        field(14; "VAT Bus. Posting Group"; Code[20])
        {
            Caption = 'VAT Bus. Posting Group';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Using Item Category table instead.';
        }
        field(15; "Gen. Bus. Posting Group"; Code[20])
        {
            Caption = 'Gen. Bus. Posting Group';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Using Item Category table instead.';
        }
        field(16; "Gen. Prod. Posting Group"; Code[20])
        {
            Caption = 'Gen. Prod. Posting Group';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Using Item Category table instead.';
        }
        field(17; "Inventory Posting Group"; Code[20])
        {
            Caption = 'Inventory Posting Group';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Using Item Category table instead.';
        }
        field(50; Level; Integer)
        {
            Caption = 'Level';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Using Item Category table instead.';
        }
        field(52; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Using Item Category table instead.';
        }
        field(54; "Main Item Group"; Boolean)
        {
            Caption = 'Main Item Group';
            DataClassification = CustomerContent;
            Editable = true;
            ObsoleteState = Removed;
            ObsoleteReason = 'Using Item Category table instead.';
        }
        field(62; "Item Discount Group"; Code[20])
        {
            Caption = 'Item Discount Group';
            DataClassification = CustomerContent;
            Description = 'NPR5.48';
            ObsoleteState = Removed;
            ObsoleteReason = 'Using Item Category table instead.';
        }
        field(63; "Warranty File"; Option)
        {
            Caption = 'Warranty File';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Move to Warranty File';
            OptionMembers = " ","Flyt til garanti kar.";
            ObsoleteState = Removed;
            ObsoleteReason = 'Using Item Category table instead.';
        }
        field(64; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Using Item Category table instead.';
        }
        field(65; "Costing Method"; Enum "Costing Method")
        {
            Caption = 'Costing Method';
            DataClassification = CustomerContent;
            InitValue = FIFO;
            ObsoleteState = Removed;
            ObsoleteReason = 'Using Item Category table instead.';
        }
        field(70; "Base Unit of Measure"; Code[10])
        {
            Caption = 'Base Unit of Measure';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Using Item Category table instead.';
        }
        field(71; "Sales Unit of Measure"; Code[10])
        {
            Caption = 'Sales Unit of Measure';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Using Item Category table instead.';
        }
        field(72; "Purch. Unit of Measure"; Code[10])
        {
            Caption = 'Purch. Unit of Measure';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Using Item Category table instead.';
        }
        field(73; "Insurance Category"; Code[50])
        {
            Caption = 'Insurance Category';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Using Item Category table instead.';
        }
        field(74; Warranty; Boolean)
        {
            Caption = 'Warranty';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Using Item Category table instead.';
        }
        field(80; "Config. Template Header"; Code[10])
        {
            Caption = 'Config. Template Header';
            DataClassification = CustomerContent;
            Description = 'NPR5.30';
            ObsoleteState = Removed;
            ObsoleteReason = 'Using Item Category table instead.';
        }
        field(85; Picture; BLOB)
        {
            Caption = 'Picture';
            DataClassification = CustomerContent;
            SubType = Bitmap;
            ObsoleteState = Removed;
            ObsoleteReason = 'Using Item Category table instead.';
        }
        field(86; "Picture Extention"; Text[3])
        {
            Caption = 'Picture Extention';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Using Item Category table instead.';
        }

        field(98; "Tax Group Code"; Code[20])
        {
            Caption = 'Tax Group Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.38';
            ObsoleteState = Removed;
            ObsoleteReason = 'Using Item Category table instead.';
        }
        field(310; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.48';
            ObsoleteState = Removed;
            ObsoleteReason = 'Using Item Category table instead.';
        }
        field(316; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Using Item Category table instead.';
        }
        field(317; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Using Item Category table instead.';
        }

        field(320; "Primary Key Length"; Integer)
        {
            Caption = 'Primary Key Length';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Using Item Category table instead.';
        }
        field(321; "Tarif No."; Code[20])
        {
            Caption = 'Tarif No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.48';
            ObsoleteState = Removed;
            ObsoleteReason = 'Using Item Category table instead.';
        }
        field(500; "Used Goods Group"; Boolean)
        {
            Caption = 'Used Goods Group';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Using Item Category table instead.';
        }
        field(5440; "Reordering Policy"; Option)
        {
            Caption = 'Reordering Policy';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Fixed Reorder Qty.,Maximum Qty.,Order,Lot-for-Lot';
            OptionMembers = " ","Fixed Reorder Qty.","Maximum Qty.","Order","Lot-for-Lot";
            ObsoleteState = Removed;
            ObsoleteReason = 'Using Item Category table instead.';
        }
        field(6014607; "Size Dimension"; Code[20])
        {
            Caption = 'Size Dimension';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Using Item Category table instead.';
        }
        field(6014608; "Color Dimension"; Code[20])
        {
            Caption = 'Color Dimension';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Using Item Category table instead.';
        }
        field(6059982; "Variety Group"; Code[20])
        {
            Caption = 'Variety Group';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
            ObsoleteState = Removed;
            ObsoleteReason = 'Using Item Category table instead.';
        }
        field(6060001; "Webshop Picture"; Text[200])
        {
            Caption = 'Webshop Picture';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Using Item Category table instead.';
        }
        field(6060002; Internet; Boolean)
        {
            Caption = 'Internet';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Using Item Category table instead.';
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'Key Removed';
        }
        key(Key2; "Entry No.", "Primary Key Length")
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'Key Removed';
        }
        key(Key3; "Parent Item Group No.")
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'Key Removed';
        }
        key(Key4; "Main Item Group")
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'Key Removed';
        }
        key(Key5; "Sorting-Key")
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'Key Removed';
        }
        key(Key6; Description)
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'Key Removed';
        }
    }
}
