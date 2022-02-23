table 6184601 "NPR Consignor Entry"
{
    Access = Internal;
    Caption = 'Consignor Entry';
    DataClassification = CustomerContent;

    fields
    {
        field(1; Type; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Order,Shipment,Invoice';
            OptionMembers = "Order",Shipment,Invoice;
        }
        field(2; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            TableRelation = IF (Type = CONST(Order)) "Sales Header"."No."
            ELSE
            IF (Type = CONST(Shipment)) "Sales Shipment Header"."No."
            ELSE
            IF (Type = CONST(Invoice)) "Sales Invoice Header";
        }
        field(3; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(4; Weight; Decimal)
        {
            Caption = 'Weight';
            DataClassification = CustomerContent;
        }
        field(5; Actor; Code[30])
        {
            Caption = 'Actor';
            DataClassification = CustomerContent;
        }
        field(6; "Units per Parcel"; Decimal)
        {
            Caption = 'Units per Parcel';
            DataClassification = CustomerContent;
            InitValue = 1;
        }
        field(7; "Created Date Time"; DateTime)
        {
            Caption = 'Created Date Time';
            DataClassification = CustomerContent;
        }
        field(8; "Created By"; Code[20])
        {
            Caption = 'Created By';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(11; "Request XML"; BLOB)
        {
            Caption = 'Request XML';
            DataClassification = CustomerContent;
        }
        field(12; "Response XML"; BLOB)
        {
            Caption = 'Response XML';
            DataClassification = CustomerContent;
        }
        field(13; "Track and Trace"; Text[60])
        {
            Caption = 'Track and Trace';
            DataClassification = CustomerContent;
        }
        field(14; Ready; Boolean)
        {
            Caption = 'Ready';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; Type, "Code", "Line No.")
        {
        }
        key(Key2; "Created Date Time")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        "Created Date Time" := CurrentDateTime;
        "Created By" := CopyStr(UserId, 1, MaxStrLen("Created By"));
    end;

    var
        Text001: Label 'Status must be released';

    procedure InsertFromSalesHeader(InCode: Code[20])
    var
        SalesLine: Record "Sales Line";
        TempWeight: Decimal;
    begin
        if not CheckSalesHeader(InCode) then
            exit;
        Init();
        Type := Type::Order;
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
        SalesLine.SetRange("Document No.", InCode);
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.SetFilter("Net Weight", '<>0');
        if SalesLine.FindSet() then
            repeat
                TempWeight += SalesLine."Net Weight" * SalesLine.Quantity;
            until SalesLine.Next() = 0;
        Weight := TempWeight;
        InsertHeader(InCode);
    end;

    procedure InsertFromShipmentHeader(InCode: Code[20])
    var
        SalesShipmentLine: Record "Sales Shipment Line";
        TempWeight: Decimal;
    begin
        if not CheckShipmentHeader(InCode) then
            exit;
        Init();
        Type := Type::Shipment;
        SalesShipmentLine.SetRange("Document No.", InCode);
        SalesShipmentLine.SetRange(Type, SalesShipmentLine.Type::Item);
        SalesShipmentLine.SetFilter("Net Weight", '<>0');
        if SalesShipmentLine.FindSet() then
            repeat
                TempWeight += SalesShipmentLine."Net Weight" * SalesShipmentLine.Quantity;
            until SalesShipmentLine.Next() = 0;

        Weight := TempWeight;
        InsertHeader(InCode);
    end;

    procedure InsertFromPostedInvoiceHeader(InCode: Code[20])
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
        TempWeight: Decimal;
    begin
        if not CheckPostedInvoiceHeader(InCode) then
            exit;
        Init();
        Type := Type::Invoice;
        SalesInvoiceLine.SetRange("Document No.", InCode);
        SalesInvoiceLine.SetRange(Type, SalesInvoiceLine.Type::Item);
        SalesInvoiceLine.SetFilter("Net Weight", '<>0');
        if SalesInvoiceLine.FindSet() then
            repeat
                TempWeight += SalesInvoiceLine."Net Weight" * SalesInvoiceLine.Quantity;
            until SalesInvoiceLine.Next() = 0;
        Weight := TempWeight;
        InsertHeader(InCode);
    end;

    local procedure InsertHeader(InCode: Code[20])
    var
        ShippingProviderSetup: Record "NPR Shipping Provider Setup";
    begin
        if not ShippingProviderSetup.Get() then
            exit;

        if ShippingProviderSetup."Shipping Provider" <> ShippingProviderSetup."Shipping Provider"::Consignor then
            exit;

        Code := InCode;
        Ready := true;
        Insert(true);
    end;

    local procedure CheckSalesHeader(InCode: Code[20]): Boolean
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.Get(SalesHeader."Document Type"::Order, InCode);

        if SalesHeader.Status <> SalesHeader.Status::Released then
            Error(Text001);

        if SalesHeader."Shipping Agent Code" = '' then
            exit(false);

        if SalesHeader."Shipping Agent Service Code" = '' then
            exit(false);

        exit(true);
    end;

    local procedure CheckShipmentHeader(InCode: Code[20]): Boolean
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
    begin
        SalesShipmentHeader.Get(InCode);

        if SalesShipmentHeader."Shipping Agent Code" = '' then
            exit(false);

        exit(true);
    end;

    local procedure CheckPostedInvoiceHeader(InCode: Code[20]): Boolean
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        SalesInvoiceHeader.Get(InCode);

        if SalesInvoiceHeader."Shipping Agent Code" = '' then
            exit(false);

        exit(true);
    end;
}

