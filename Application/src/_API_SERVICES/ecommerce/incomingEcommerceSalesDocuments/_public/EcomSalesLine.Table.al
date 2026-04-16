table 6151259 "NPR Ecom Sales Line"
{
    DataClassification = CustomerContent;
    Caption = 'Ecommerce Sales Line';
#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
    DrillDownPageId = "NPR Ecom Sales Lines";
    LookupPageId = "NPR Ecom Sales Lines";
#endif

    fields
    {
        field(1; "External Document No."; Text[20])
        {
            DataClassification = CustomerContent;
            Caption = 'External Document No.';
        }
        field(2; "Document Type"; Enum "NPR Ecom Sales Doc Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Document Type';
        }
        field(3; "Line No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Line No.';
            BlankZero = true;
        }
        field(4; Type; Enum "NPR Ecom Sales Line Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Type';
        }
        field(5; "No."; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'No.';
        }
        field(7; "Document Entry No."; BigInteger)
        {
            DataClassification = CustomerContent;
            Caption = 'Document Entry No.';
            BlankZero = true;
            TableRelation = "NPR Ecom Sales Header"."Entry No.";
        }
        field(21; "Variant Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Variant Code';
        }
        field(22; "Barcode No."; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Barcode No.';
        }
        field(6; Description; Text[150])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }
        field(8; "Unit Price"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Unit Price';
            BlankZero = true;
        }
        field(10; Quantity; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Quantity';
            BlankZero = true;
        }
        field(11; "Unit of Measure Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Unit of Measure Code';
        }
        field(14; "VAT %"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'VAT %';
            BlankZero = true;
        }
        field(15; "Line Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Line Amount';
            BlankZero = true;
        }
        field(17; "Requested Delivery Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Requested Delivery Date';
        }
        field(18; "Created From Pmt. Line Id"; Guid)
        {
            DataClassification = CustomerContent;
            Caption = 'Created From Payment Line Id';
        }
        field(19; "Invoiced Qty."; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Invoiced Qty.';
            BlankZero = true;
        }
        field(20; "Invoiced Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Invoiced Amount';
            BlankZero = true;
        }
        field(23; "Virtual Item Process Status"; Enum "NPR EcomVirtualItemProcestatus")
        {
            DataClassification = CustomerContent;
            Caption = 'Virtual Item Process Status';
        }
        field(24; "Virtual Item Process ErrMsg"; Text[500])
        {
            DataClassification = CustomerContent;
            Caption = 'Virtual Item Process Error Message';
        }
        field(25; Captured; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Captured';
        }
        field(16; "Voucher Type"; Code[20])
        {
            Caption = 'Voucher Type';
            DataClassification = CustomerContent;
        }
        field(40; "External Line ID"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'External Line ID';
        }
        field(41; "Parent Ext. Line ID"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Parent Ext. Line ID';
            TableRelation = "NPR Ecom Sales Line"."External Line ID" where("Document Entry No." = field("Document Entry No."));
            ValidateTableRelation = false;
        }
        field(42; Indentation; Integer)
        {
            Caption = 'Indentation';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
        field(50; "Is Attraction Wallet"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Is Attraction Wallet';
        }
        field(51; "Attr. Wallet Processing Status"; Enum "NPR EcomVirtualItemProcestatus")
        {
            DataClassification = CustomerContent;
            Caption = 'Attr. Wallet Processing Status';
        }
        field(52; "Attr. Wallet Process ErrMsg"; Text[500])
        {
            DataClassification = CustomerContent;
            Caption = 'Attr. Wallet Process Error Message';
        }
        field(53; "Attr. Wallet Retry Count"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Attr. Wallet Retry Count';
            BlankZero = true;
        }
        field(5000; "Bucket Id"; Integer)
        {
            Caption = 'Bucket';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5010; "Virtual Item Proc Retry Count"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Virtual Item Process Retry Count';
            BlankZero = true;
        }
#if not BC17
        field(5020; "Line Discount Amount"; Decimal)
        {
            Caption = 'Line Discount Amount';
            DataClassification = CustomerContent;
            BlankZero = true;
        }
        field(5030; "Description 2"; Text[150])
        {
            DataClassification = CustomerContent;
            Caption = 'Description 2';
        }
        field(30; "Shopify ID"; Text[30])
        {
            Caption = 'Shopify ID';
            DataClassification = CustomerContent;
        }
#endif
        field(5040; Subtype; Enum "NPR Ecom Sales Line Subtype")
        {
            DataClassification = CustomerContent;
            Caption = 'Subtype';
        }
        field(5041; "Ticket Reservation Line Id"; Guid)
        {
            DataClassification = CustomerContent;
            Caption = 'Ticket Reservation Line Id';
        }
        field(5042; "Membership Id"; Guid)
        {
            DataClassification = CustomerContent;
            Caption = 'Membership Id';
        }
        field(5043; "Member First Name"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Member First Name';
        }
        field(5044; "Member Last Name"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Member Last Name';
        }
        field(5045; "Member Middle Name"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Member Middle Name';
        }
        field(5046; "Member Email"; Text[80])
        {
            DataClassification = CustomerContent;
            Caption = 'Member Email';
        }
        field(5047; "Member Phone No."; Text[30])
        {
            DataClassification = CustomerContent;
            Caption = 'Member Phone No.';
        }
        field(5048; "Member Birthday"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Member Birthday';
        }
        field(5049; "Member Gender"; Text[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Member Gender';
        }
        field(5050; "Member Address"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Member Address';
        }
        field(5051; "Member City"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Member City';
        }
        field(5052; "Member Country"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Member Country';
        }
        field(5053; "Member Post Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Member Post Code';
        }
        field(5054; "Member Newsletter"; Text[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Member Newsletter';
        }
        field(5055; "Member GDPR Approval"; Text[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Member GDPR Approval';
        }
        field(5056; "Membership Activation Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Membership Activation Date';
        }
    }

    keys
    {
        key(Key1; "Document Entry No.", "Line No.")
        {
            Clustered = true;
        }
        key(Key2; "Document Type", "External Document No.")
        {
        }
        key(Key3; "External Document No.", "Document Type", "Bucket Id", Type)
        {
        }
        key(Key4; "External Document No.", "Document Type", Type, "Virtual Item Process Status", Captured)
        {
        }
        key(Key5; "Document Entry No.", Type, Captured, "Virtual Item Process Status", "Virtual Item Proc Retry Count")
        {
        }
        key(Key6; "Document Entry No.", Subtype, Captured, "Virtual Item Process Status", "Virtual Item Proc Retry Count")
        {
        }
        key(WalletProcessing; "Document Entry No.", "Is Attraction Wallet", "Attr. Wallet Processing Status") { }
        key(BundleLines; "Document Entry No.", "Parent Ext. Line ID", "External Line ID", "Is Attraction Wallet", Subtype, "Virtual Item Process Status") { }
    }

    internal procedure IsVirtualItem(): Boolean
    begin
        exit(Subtype in [Subtype::Voucher, Subtype::Ticket, Subtype::Membership, Subtype::Coupon]);
    end;
}