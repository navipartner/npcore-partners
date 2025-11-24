table 6151258 "NPR Ecom Sales Header"
{
    DataClassification = CustomerContent;
    Caption = 'Ecommerce Sales Header';
#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
    DrillDownPageId = "NPR Ecom Sales Documents";
    LookupPageId = "NPR Ecom Sales Documents";
#endif
    fields
    {
        field(1; "Entry No."; Biginteger)
        {
            DataClassification = CustomerContent;
            Caption = 'Entry No.';
            Autoincrement = true;
        }
        field(2; "External No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'External No.';
        }
        field(30; "Document Type"; Enum "NPR Ecom Sales Doc Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Document Type';
        }
        field(60; "Creation Status"; Enum "NPR EcomSalesDocCrtStatus")
        {
            DataClassification = CustomerContent;
            Caption = 'Creation Status';
        }
        field(70; "Currency Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Currency Code';
            TableRelation = Currency.Code;
        }
        field(80; "Currency Exchange Rate"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Currency Exchange Rate';
        }
        field(90; "External Document No."; Code[35])
        {
            DataClassification = CustomerContent;
            Caption = 'External Document No.';
        }
        field(110; "Your Reference"; Text[35])
        {
            DataClassification = CustomerContent;
            Caption = 'Your Reference';
        }
        field(140; "Price Excl. VAT"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Price Excl. VAT';
        }
        field(160; Amount; Decimal)
        {
            AutoFormatExpression = Rec."Currency Code";
            AutoFormatType = 1;
            Caption = 'Amount';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = sum("NPR Ecom Sales Line"."Line Amount" where("Document Entry No." = field("Entry No.")));
        }
        field(170; "Invoiced Amount"; Decimal)
        {
            Editable = false;
            AutoFormatExpression = Rec."Currency Code";
            AutoFormatType = 1;
            Caption = 'Invoiced Amount';
            FieldClass = FlowField;
            CalcFormula = sum("NPR Ecom Sales Line"."Invoiced Amount" where("Document Entry No." = field("Entry No.")));
        }
        field(180; "Received Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Received Date';
        }
        field(190; "Received Time"; Time)
        {
            DataClassification = CustomerContent;
            Caption = 'Received Time';
        }
        field(200; "Created Doc No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Created Document No.';
        }
        field(210; "Location Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Location Code';
        }
        field(1000; "Created Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Created Date';
        }
        field(1001; "Created Time"; Time)
        {
            DataClassification = CustomerContent;
            Caption = 'Created Time';
        }
        field(1010; "Created By User Name"; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Created By User Name';
            TableRelation = User."User Name";
        }
        field(1020; "Created By User Id"; Guid)
        {
            DataClassification = CustomerContent;
            Caption = 'Created By User Id';
            TableRelation = User;
        }
        field(1130; "Last Error Message"; Text[500])
        {
            DataClassification = CustomerContent;
            Caption = 'Last Error Message';
        }
        field(1140; "Last Error Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Last Error Date';
        }
        field(1141; "Last Error Time"; Time)
        {
            DataClassification = CustomerContent;
            Caption = 'Last Error Time';
        }
        field(1150; "Last Error Rcvd By User Name"; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Last Error Received By User Name';
            TableRelation = User."User Name";
        }
        field(1160; "Last Error Rcvd By User Id"; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Last Error Received By User id';
            TableRelation = User;
        }
        field(1200; "Captured Payment Amount"; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            AutoFormatExpression = Rec."Currency Code";
            AutoFormatType = 1;
            Caption = 'Captured Payment Amount';
            CalcFormula = Sum("NPR Ecom Sales Pmt. Line"."Captured Amount" where("Document Entry No." = field("Entry No.")));
        }
        field(1210; "Payment Amount"; Decimal)
        {
            CalcFormula = Sum("NPR Ecom Sales Pmt. Line".Amount where("Document Entry No." = field("Entry No.")));
            Caption = 'Payment Amount';
            Editable = false;
            FieldClass = FlowField;
            AutoFormatExpression = Rec."Currency Code";
            AutoFormatType = 1;
        }
        field(1211; "Invoiced Payment Amount"; Decimal)
        {
            CalcFormula = Sum("NPR Ecom Sales Pmt. Line"."Invoiced Amount" where("Document Entry No." = field("Entry No.")));
            Caption = 'Invoiced Payment Amount';
            Editable = false;
            FieldClass = FlowField;
            AutoFormatExpression = Rec."Currency Code";
            AutoFormatType = 1;
        }
        field(1220; "Posting Status"; Enum "NPR EcomSalesDocPostStatus")
        {
            DataClassification = CustomerContent;
            Caption = 'Posting Status';
        }
        field(1230; "Process Retry Count"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Process Retry Count';
            BlankZero = true;
        }
        field(2000; "Sell-to Customer No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Sell-to Customer No.';
        }
        field(2010; "Sell-to Customer Type"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Sell-to Customer Type';
            TableRelation = "NPR Magento Tax Class";
        }
        field(2020; "Sell-to Name"; Text[150])
        {
            DataClassification = CustomerContent;
            Caption = 'Sell-to Name';
        }
        field(2040; "Sell-to Address"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Sell-to Address';
        }
        field(2050; "Sell-to Address 2"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Sell-to Address 2';
        }
        field(2060; "Sell-to Post Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Sell-to Post Code';
            TableRelation = "Post Code";
        }
        field(2061; "Sell-to Country Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Sell-to Country Code';
            TableRelation = "Country/Region";
        }
        field(2070; "Sell-to County"; Text[30])
        {
            DataClassification = CustomerContent;
            Caption = 'Sell-to County';
        }
        field(2080; "Sell-to City"; Text[30])
        {
            DataClassification = CustomerContent;
            Caption = 'Sell-to City';
        }
        field(2090; "Sell-to Email"; Text[80])
        {
            DataClassification = CustomerContent;
            Caption = 'Sell-to Email';
        }
        field(2100; "Sell-to Phone No."; Text[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Sell-to Phone No.';
        }
        field(2110; "Sell-to Invoice Email"; Text[80])
        {
            DataClassification = CustomerContent;
            Caption = 'Sell-to Invoice Email';
        }
        field(2120; "Sell-to VAT Registration No."; Text[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Sell-to VAT Registration No';
        }
        field(2130; "Sell-to Contact"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Sell-to Contact';
        }
        field(2140; "Sell-to EAN"; Code[13])
        {
            DataClassification = CustomerContent;
            Caption = 'Sell-to EAN';
        }
        field(3000; "Ship-to Name"; Text[150])
        {
            DataClassification = CustomerContent;
            Caption = 'Ship-to Name';
        }
        field(3020; "Ship-to Address"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Ship-to Address';
        }
        field(3030; "Ship-to Address 2"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Ship-to Customer Address 2';
        }
        field(3040; "Ship-to Post Code"; Text[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Ship-to Post Code';
            TableRelation = "Post Code";
        }
        field(3050; "Ship-to Country Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Ship-to Country Code';
            TableRelation = "Country/Region";
        }
        field(3060; "Ship-to County"; Text[30])
        {
            DataClassification = CustomerContent;
            Caption = 'Ship-to County';
        }
        field(3070; "Ship-to City"; Text[30])
        {
            DataClassification = CustomerContent;
            Caption = 'Ship-to City';
        }
        field(3080; "Ship-to Contact"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Ship-to Contact';
        }
        field(4000; "Shipment Method Code"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Shipment Method Code';
            TableRelation = "NPR Magento Shipment Mapping";
        }
        field(4010; "Shipment Service"; Code[50])
        {
            Caption = 'Shipment Service';
            DataClassification = CustomerContent;
        }
        field(4020; "Customer Template"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Customer Template';
        }
        field(4030; "Configuration Template"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Configuration Template';
        }
        field(4040; "API Version Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'API Version Date';
        }
        field(4050; "Requested API Version Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Requested API Version Date';
        }
        field(5000; "Bucket Id"; Integer)
        {
            Caption = 'Bucket Id';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5049; "Virtual Items Exist"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Virtual Items Exist';
        }
        field(5050; "Vouchers Exist"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Vouchers Exist';
        }
        field(5080; "Voucher Processing Status"; Enum "NPR EcomVoucherStatus")
        {
            DataClassification = CustomerContent;
            Caption = 'Voucher Processing Status';
        }

        field(5090; "Capture Processing Status"; Enum "NPR Ecom Capture Status")
        {
            DataClassification = CustomerContent;
            Caption = 'Capture Processing Status';
        }
        field(5100; "Capture Retry Count"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Capture Retry Count';
            BlankZero = true;
        }
        field(5150; "Last Capture Error Message"; Text[500])
        {
            DataClassification = CustomerContent;
            Caption = 'Last Capture Error Message';
        }
        field(5160; "Virtual Items Process Status"; Enum "NPR EcomVirtualItemDocStatus")
        {
            DataClassification = CustomerContent;
            Caption = 'Virtual Items Processing Status';
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Document Type", "External No.")
        {
        }
        key(CreationStatus; "Document Type", "Creation Status")
        {
        }
        key(DocTypeStatusRetry; "Document Type", "Creation Status", "Process Retry Count")
        {
        }
        key(CreatedDateSorting; SystemCreatedAt)
        {
        }
        key(VoucherProcessing; "Document Type", "Creation Status", "Vouchers Exist", "Capture Processing Status", "Voucher Processing Status", "Bucket Id")
        {
        }
        key(CaptureProcessing; "Creation Status", "Virtual Items Exist", "Capture Processing Status", "Bucket Id", "Capture Retry Count")
        {
        }
        key(VirtualItemProcessing; "Document Type", "Creation Status", "Virtual Items Exist", "Virtual Items Process Status", "Bucket Id", "Process Retry Count")
        {
        }

    }
#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
    trigger OnDelete()
    var
        EcomSalesDocUtils: Codeunit "NPR Ecom Sales Doc Utils";
    begin
        EcomSalesDocUtils.DeleteSalesDocSalesLines(Rec);
        EcomSalesDocUtils.DeleteSalesDocPaymentLines(Rec);
        EcomSalesDocUtils.DeleteMagentoPaymentLines(Rec);
        EcomSalesDocUtils.DeleteVoucherSalesLines(Rec);
    end;
#endif

}