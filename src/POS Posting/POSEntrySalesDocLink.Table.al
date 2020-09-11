table 6150680 "NPR POS Entry Sales Doc. Link"
{
    // NPR5.50/MMV /20190417 CASE 300557 Created object
    // NPR5.50/TSA /20190531 CASE 355186 Added options for service items
    // NPR5.52/TSA /20191014 CASE 372920 Added options for assembly order and posted assembly order

    Caption = 'POS Entry Sales Doc. Link';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "POS Entry No."; Integer)
        {
            Caption = 'POS Entry No.';
            DataClassification = CustomerContent;
        }
        field(2; "POS Entry Reference Type"; Option)
        {
            Caption = 'POS Entry Reference Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Header,Sales Line';
            OptionMembers = HEADER,SALESLINE;
        }
        field(3; "POS Entry Reference Line No."; Integer)
        {
            Caption = 'POS Entry Reference Line No.';
            DataClassification = CustomerContent;
        }
        field(4; "Sales Document Type"; Enum "NPR POS Sales Document Type")
        {
            Caption = 'Sales Document Type';
            DataClassification = CustomerContent;
        }
        field(5; "Sales Document No"; Code[20])
        {
            Caption = 'Sales Document No';
            DataClassification = CustomerContent;
            TableRelation = IF ("Sales Document Type" = CONST(QUOTE)) "Sales Header"."No." WHERE("Document Type" = CONST(Quote))
            ELSE
            IF ("Sales Document Type" = CONST(ORDER)) "Sales Header"."No." WHERE("Document Type" = CONST(Order))
            ELSE
            IF ("Sales Document Type" = CONST(INVOICE)) "Sales Header"."No." WHERE("Document Type" = CONST(Invoice))
            ELSE
            IF ("Sales Document Type" = CONST(CREDIT_MEMO)) "Sales Header"."No." WHERE("Document Type" = CONST("Credit Memo"))
            ELSE
            IF ("Sales Document Type" = CONST(BLANKET_ORDER)) "Sales Header"."No." WHERE("Document Type" = CONST("Blanket Order"))
            ELSE
            IF ("Sales Document Type" = CONST(RETURN_ORDER)) "Sales Header"."No." WHERE("Document Type" = CONST("Return Order"))
            ELSE
            IF ("Sales Document Type" = CONST(POSTED_INVOICE)) "Sales Invoice Header"."No."
            ELSE
            IF ("Sales Document Type" = CONST(POSTED_CREDIT_MEMO)) "Sales Cr.Memo Header"."No."
            ELSE
            IF ("Sales Document Type" = CONST(SHIPMENT)) "Sales Shipment Header"."No."
            ELSE
            IF ("Sales Document Type" = CONST(RETURN_RECEIPT)) "Return Receipt Header"."No."
            ELSE
            IF ("Sales Document Type" = CONST(SERVICE_ITEM)) "Service Item"."No.";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
    }

    keys
    {
        key(Key1; "POS Entry No.", "POS Entry Reference Type", "POS Entry Reference Line No.", "Sales Document Type", "Sales Document No")
        {
        }
        key(Key2; "Sales Document Type", "Sales Document No")
        {
        }
    }

    fieldgroups
    {
    }

    procedure GetCardpageID(): Integer
    begin
        case "Sales Document Type" of
            "Sales Document Type"::QUOTE:
                exit(PAGE::"Sales Quote");
            "Sales Document Type"::ORDER:
                exit(PAGE::"Sales Order");
            "Sales Document Type"::INVOICE:
                exit(PAGE::"Sales Invoice");
            "Sales Document Type"::CREDIT_MEMO:
                exit(PAGE::"Sales Credit Memo");
            "Sales Document Type"::BLANKET_ORDER:
                exit(PAGE::"Blanket Sales Order");
            "Sales Document Type"::RETURN_ORDER:
                exit(PAGE::"Sales Return Order");
            "Sales Document Type"::POSTED_CREDIT_MEMO:
                exit(PAGE::"Posted Sales Credit Memo");
            "Sales Document Type"::POSTED_INVOICE:
                exit(PAGE::"Posted Sales Invoice");
            "Sales Document Type"::RETURN_RECEIPT:
                exit(PAGE::"Posted Return Receipt");
            "Sales Document Type"::SHIPMENT:
                exit(PAGE::"Posted Sales Shipment");
            //-NPR5.50 [355186]
            "Sales Document Type"::SERVICE_ITEM:
                exit(PAGE::"Service Items");
            //+NPR5.50 [355186]
            //-NPR5.52 [372920]
            "Sales Document Type"::ASSEMBLY_ORDER:
                exit(PAGE::"Assembly Order");
            "Sales Document Type"::POSTED_ASSEMBLY_ORDER:
                exit(PAGE::"Posted Assembly Order");
        //+NPR5.52 [372920]


        end;
    end;

    procedure GetDocumentRecord(var RecordOut: Variant)
    var
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        ReturnReceiptHeader: Record "Return Receipt Header";
        ServiceItem: Record "Service Item";
        AssemblyHeader: Record "Assembly Header";
        PostedAssemblyHeader: Record "Posted Assembly Header";
    begin
        case "Sales Document Type" of
            "Sales Document Type"::QUOTE:
                begin
                    SalesHeader.Get(SalesHeader."Document Type"::Quote, "Sales Document No");
                    RecordOut := SalesHeader;
                end;
            "Sales Document Type"::ORDER:
                begin
                    SalesHeader.Get(SalesHeader."Document Type"::Order, "Sales Document No");
                    RecordOut := SalesHeader;
                end;
            "Sales Document Type"::INVOICE:
                begin
                    SalesHeader.Get(SalesHeader."Document Type"::Invoice, "Sales Document No");
                    RecordOut := SalesHeader;
                end;
            "Sales Document Type"::CREDIT_MEMO:
                begin
                    SalesHeader.Get(SalesHeader."Document Type"::"Credit Memo", "Sales Document No");
                    RecordOut := SalesHeader;
                end;
            "Sales Document Type"::BLANKET_ORDER:
                begin
                    SalesHeader.Get(SalesHeader."Document Type"::"Blanket Order", "Sales Document No");
                    RecordOut := SalesHeader;
                end;
            "Sales Document Type"::RETURN_ORDER:
                begin
                    SalesHeader.Get(SalesHeader."Document Type"::"Return Order", "Sales Document No");
                    RecordOut := SalesHeader;
                end;
            "Sales Document Type"::POSTED_CREDIT_MEMO:
                begin
                    SalesCrMemoHeader.Get("Sales Document No");
                    RecordOut := SalesCrMemoHeader;
                end;
            "Sales Document Type"::POSTED_INVOICE:
                begin
                    SalesInvoiceHeader.Get("Sales Document No");
                    RecordOut := SalesInvoiceHeader;
                end;
            "Sales Document Type"::RETURN_RECEIPT:
                begin
                    ReturnReceiptHeader.Get("Sales Document No");
                    RecordOut := ReturnReceiptHeader;
                end;
            "Sales Document Type"::SHIPMENT:
                begin
                    SalesShipmentHeader.Get("Sales Document No");
                    RecordOut := SalesShipmentHeader;
                end;
            //-NPR5.50 [355186]
            "Sales Document Type"::SERVICE_ITEM:
                begin
                    ServiceItem.Get("Sales Document No");
                    RecordOut := ServiceItem;
                end;
            //+NPR5.50 [355186]

            //-NPR5.52 [372920]
            "Sales Document Type"::ASSEMBLY_ORDER:
                begin
                    AssemblyHeader.Get(AssemblyHeader."Document Type"::Order, "Sales Document No");
                    RecordOut := AssemblyHeader;
                end;

            "Sales Document Type"::POSTED_ASSEMBLY_ORDER:
                begin
                    PostedAssemblyHeader.SetFilter("Order No.", '=%1', "Sales Document No");
                    PostedAssemblyHeader.FindFirst();
                    RecordOut := PostedAssemblyHeader;
                end;
        //+NPR5.52 [372920]

        end;
    end;
}

