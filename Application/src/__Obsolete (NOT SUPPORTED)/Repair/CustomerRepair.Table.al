table 6014504 "NPR Customer Repair"
{
    Access = Internal;
    Caption = 'Customer Repair';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteReason = 'Repairs are not supported in core anymore.';

    fields
    {
        field(1; "No."; Code[10])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
        }
        field(2; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
        }
        field(3; Name; Text[100])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;

        }
        field(4; Address; Text[100])
        {
            Caption = 'Address';
            DataClassification = CustomerContent;
        }
        field(5; "Address 2"; Text[50])
        {
            Caption = 'Address 2';
            DataClassification = CustomerContent;
        }
        field(6; "Post Code"; Code[20])
        {
            Caption = 'Post Code';
            DataClassification = CustomerContent;
        }
        field(7; City; Text[30])
        {
            Caption = 'City';
            DataClassification = CustomerContent;
        }
        field(8; "Invoice To"; Code[20])
        {
            Caption = 'Invoice To';
            DataClassification = CustomerContent;
        }
        field(9; "Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
            DataClassification = CustomerContent;
        }
        field(10; "Customer Address"; Text[100])
        {
            Caption = 'Customer Address';
            DataClassification = CustomerContent;
        }
        field(11; "Customer Address 2"; Text[50])
        {
            Caption = 'Customer Address 2';
            DataClassification = CustomerContent;
        }
        field(12; "Customer Post Code"; Code[20])
        {
            Caption = 'Customer Post Code';
            DataClassification = CustomerContent;
        }
        field(13; "Customer City"; Text[30])
        {
            Caption = 'Customer City';
            DataClassification = CustomerContent;
        }
        field(14; "Repairer No."; Code[20])
        {
            Caption = 'Repairer No.';
            DataClassification = CustomerContent;
        }
        field(15; "Repairer Name"; Text[100])
        {
            Caption = 'Repairer Name';
            DataClassification = CustomerContent;
        }
        field(16; "Repairer Address"; Text[100])
        {
            Caption = 'Repairer Address';
            DataClassification = CustomerContent;
        }
        field(17; "Repairer Address2"; Text[50])
        {
            Caption = 'Repairer Address2';
            DataClassification = CustomerContent;
        }
        field(18; "Repairer Post Code"; Code[20])
        {
            Caption = 'Repairer Post Code';
            DataClassification = CustomerContent;
        }
        field(19; "Repairer City"; Text[30])
        {
            Caption = 'Repairer City';
            DataClassification = CustomerContent;
        }
        field(20; "In-house Repairer"; Boolean)
        {
            Caption = 'In-house Repairer';
            DataClassification = CustomerContent;
        }
        field(21; "To Ship"; Boolean)
        {
            Caption = 'To Ship';
            DataClassification = CustomerContent;
        }
        field(22; "Prices Including VAT"; Decimal)
        {
            Caption = 'Prices Including VAT';
            DataClassification = CustomerContent;
        }
        field(23; "Unit Cost"; Decimal)
        {
            Caption = 'Unit Cost';
            DataClassification = CustomerContent;
        }
        field(24; Worranty; Boolean)
        {
            Caption = 'Guarantee';
            DataClassification = CustomerContent;
        }
        field(25; "Handed In Date"; Date)
        {
            Caption = 'Handed In Date';
            DataClassification = CustomerContent;
        }
        field(26; "Expected Completion Date"; Date)
        {
            Caption = 'Expected Completion Date';
            DataClassification = CustomerContent;
        }
        field(27; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            DataClassification = CustomerContent;
        }
        field(28; "Phone No."; Text[30])
        {
            Caption = 'Phone No.';
            DataClassification = CustomerContent;
        }
        field(29; "Alt. Telephone"; Code[20])
        {
            Caption = 'Alt. Telephone ';
            DataClassification = CustomerContent;
        }
        field(30; "Fax No."; Text[30])
        {
            Caption = 'Fax No.';
            DataClassification = CustomerContent;
        }
        field(31; "Contact after"; Time)
        {
            Caption = 'Contact After';
            DataClassification = CustomerContent;
        }
        field(32; Status; Option)
        {
            Caption = 'Status';
            InitValue = "To be sent";
            OptionCaption = 'At Vendor,Awaits Approval,Approved,Awaits Claiming,Return No Repair,Ready No Repair,Claimed,To be sent';
            OptionMembers = "At Vendor","Awaits Approval",Approved,"Awaits Claiming","Return No Repair","Ready No Repair",Claimed,"To be sent";
            DataClassification = CustomerContent;
        }
        field(33; Brand; Text[50])
        {
            Caption = 'Brand';
            DataClassification = CustomerContent;
        }
        field(34; "Serial No."; Code[30])
        {
            Caption = 'Serial No.';
            DataClassification = CustomerContent;
        }
        field(35; "Alt. Serial No."; Code[30])
        {
            Caption = 'Alt. Serial No.';
            DataClassification = CustomerContent;
        }
        field(36; Accessories; Text[50])
        {
            Caption = 'Accessories';
            DataClassification = CustomerContent;
        }
        field(37; "Accessories 1"; Text[50])
        {
            Caption = 'Accessories 1';
            DataClassification = CustomerContent;
        }
        field(38; "Offer (more than LCY)"; Decimal)
        {
            Caption = 'Offer (more than LCY)';
            DataClassification = CustomerContent;
        }
        field(39; Delivered; Boolean)
        {
            Caption = 'Delivered';
            DataClassification = CustomerContent;
        }
        field(40; "Price when Not Accepted"; Decimal)
        {
            Caption = 'Price when Not Accepted';
            DataClassification = CustomerContent;
        }
        field(41; "Service nr."; Code[20])
        {
            Caption = 'Service No.';
            DataClassification = CustomerContent;
        }
        field(42; Type; Option)
        {
            Caption = 'Type';
            InitValue = "Vendor's Guarantee";
            OptionCaption = 'Offer,Our Gurantee,Vendor''s Guarantee,Fixed Price,To Repair,Maximum Price/Offer';
            OptionMembers = Offer,"Our Gurantee","Vendor's Guarantee","Fixed Price","To Repair","Maximum Price/Offer";
            DataClassification = CustomerContent;
        }
        field(43; "Customer Answer"; Date)
        {
            Caption = 'Customer Answer';
            DataClassification = CustomerContent;
        }
        field(44; "Approved by repairer"; Date)
        {
            Caption = 'Approved by Repairer';
            DataClassification = CustomerContent;
        }
        field(45; "Requested Returned, No Repair"; Date)
        {
            Caption = 'Requested Returned, No Repair';
            DataClassification = CustomerContent;
        }
        field(46; "Return from Repair"; Date)
        {
            Caption = 'Return from Repair';
            DataClassification = CustomerContent;
        }
        field(47; Claimed; Date)
        {
            Caption = 'Claimed';
            DataClassification = CustomerContent;
        }
        field(48; "Offer Sent"; Date)
        {
            Caption = 'Offer Sent';
            DataClassification = CustomerContent;
        }
        field(49; "Reported Ready and Sent"; Date)
        {
            Caption = 'Reported Ready and Sent';
            DataClassification = CustomerContent;
        }
        field(50; Deposit; Decimal)
        {
            Caption = 'Deposit';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(51; "Last Date Modified"; Date)
        {
            Caption = 'Last Date Modified';
            DataClassification = CustomerContent;
        }
        field(52; "Date Delivered"; Date)
        {
            Caption = 'Date Delivered';
            DataClassification = CustomerContent;
        }
        field(53; "Delivering Salespers."; Code[20])
        {
            Caption = 'Delivering Salespers.';
            DataClassification = CustomerContent;
        }
        field(54; "Delivering Sales Ticket No."; Code[20])
        {
            Caption = 'Delivering Sales Ticket No.';
            DataClassification = CustomerContent;
        }
        field(55; "Contact Person"; Text[80])
        {
            Caption = 'Contact Person';
            DataClassification = CustomerContent;
        }
        field(56; Model; Text[50])
        {
            Caption = 'Model';
            DataClassification = CustomerContent;
        }
        field(57; "Delivered Register No."; Code[10])
        {
            Caption = 'Delivered POS Unit No.';
            DataClassification = CustomerContent;
        }
        field(58; "Audit Roll Line No."; Integer)
        {
            Caption = 'Audit Roll Line No.';
            DataClassification = CustomerContent;
        }
        field(59; "Audit Roll Trans. Type"; Integer)
        {
            Caption = 'Audit Roll Trans. Type';
            DataClassification = CustomerContent;
        }
        field(60; Register; Code[10])
        {
            Caption = 'POS Unit';
            DataClassification = CustomerContent;
        }
        field(61; Location; Code[10])
        {
            Caption = 'Location';
            DataClassification = CustomerContent;
        }
        field(100; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Description = '---';
            DataClassification = CustomerContent;
        }
        field(105; "Picture Documentation1"; BLOB)
        {
            Caption = 'Picture Documentation1';
            SubType = Bitmap;
            DataClassification = CustomerContent;
        }
        field(106; "Picture Documentation2"; BLOB)
        {
            Caption = 'Picture Documentation2';
            SubType = Bitmap;
            DataClassification = CustomerContent;
        }
        field(107; "Picture Documentation3"; BLOB)
        {
            Caption = 'Picture Documentation3';
            DataClassification = CustomerContent;
        }
        field(108; Comment; Boolean)
        {
            CalcFormula = Exist("NPR Retail Comment" WHERE("Table ID" = CONST(6014504),
                                                        "No." = FIELD("No.")));
            Caption = 'Comment';
            FieldClass = FlowField;
        }
        field(109; "Customer Type"; Option)
        {
            Caption = 'Customer Type';
            OptionCaption = 'Ordinary,Cash';
            OptionMembers = Ordinary,Cash;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Validate("Customer No.", '');
            end;
        }
        field(110; "Mobile Phone No."; Code[20])
        {
            Caption = 'Mobile Phone No.';
            DataClassification = CustomerContent;
        }
        field(111; "E-mail"; Text[250])
        {
            Caption = 'E-mail';
            DataClassification = CustomerContent;
        }
        field(112; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Global Dimension 1 Code';
            DataClassification = CustomerContent;
        }
        field(113; "Register No."; Code[10])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
        }
        field(114; "Costs Paid by Offer"; Boolean)
        {
            Caption = 'Costs Paid by Offer';
            DataClassification = CustomerContent;
        }
        field(115; "Delivery reff."; Code[20])
        {
            Caption = 'Delivery Reff.';
            DataClassification = CustomerContent;
        }
        field(116; "Global Dimension 2 Code"; Code[20])
        {
            Caption = 'Global Dimension 2 Code';
            DataClassification = CustomerContent;
        }
        field(117; "Warranty Text"; Text[100])
        {
            Caption = 'Warranty Text';
            DataClassification = CustomerContent;
        }
        field(120; Finalized; Boolean)
        {
            Caption = 'Finalized';
            Description = 'NPK70.00.01.01';
            DataClassification = CustomerContent;
        }
        field(125; "Picture Path 1"; Text[100])
        {
            Caption = 'Picture Path 1';
            Description = 'NPR5.26';
            DataClassification = CustomerContent;
        }
        field(130; "Picture Path 2"; Text[100])
        {
            Caption = 'Picture Path 2';
            Description = 'NPR5.26';
            DataClassification = CustomerContent;
        }
        field(140; "Related to Invoice No."; Code[20])
        {
            Caption = 'Related to Invoice No.';
            Description = 'NPR5.26';
            DataClassification = CustomerContent;
        }
        field(150; "Item Description"; Text[100])
        {
            Caption = 'Item Description';
            Description = 'NPR5.27';
            DataClassification = CustomerContent;
        }
        field(160; "Bag No"; Text[50])
        {
            Caption = 'Bag No';
            DataClassification = CustomerContent;
        }
        field(165; "Primary key length"; Integer)
        {
            Caption = 'Primary Key Length';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                "Primary key length" := StrLen("No.");
            end;
        }
        field(170; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                Item: Record Item;
            begin
                if Item.Get("Item No.") then
                    "Item Description" := Item.Description;
            end;
        }
        field(175; "Customer Type1"; Option)
        {
            Caption = 'Customer Type1';
            Description = 'Field Added to replace Customer Radio Button';
            OptionCaption = ' ,Contact,Customer';
            OptionMembers = " ",Contact,Customer;
            DataClassification = CustomerContent;
        }
        field(5402; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
        }
        field(6060000; "Customer Internet number"; Integer)
        {
            Caption = 'Customer Internet Number';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
        }
        key(Key2; Status)
        {
        }
        key(Key3; "Primary key length")
        {
        }
    }

    fieldgroups
    {
    }
}

