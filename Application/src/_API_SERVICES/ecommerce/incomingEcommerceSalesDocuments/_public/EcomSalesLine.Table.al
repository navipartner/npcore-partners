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
    }
}