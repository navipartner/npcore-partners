table 6014551 "NPR Package Label Numbers"
{
    // NPR4.000.000, 21-04-09, MH - Created in order to implement multi kolli.
    //                                Package Label numbers is stored in this table.
    // NPR4.000.001, 23-07-09, MH - Added field, Type, inorder to be able to print labels from sales orders.
    // NPR4.01/JDH/20150309  CASE 201022 added extra option on "Type" field

    Caption = 'Package Label Numbers';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            TableRelation = IF (Type = CONST(Order)) "Sales Header"."No." WHERE("Document Type" = CONST(Order))
            ELSE
            IF (Type = CONST(Shipment)) "Sales Shipment Header";
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                "Sales Header": Record "Sales Header";
                "Sales Shipment Header": Record "Sales Shipment Header";
            begin
                case Type of
                    Type::Order:
                        begin
                            "Sales Header".Get("Sales Header"."Document Type"::Order, "No.");
                            "Sell-To Name" := CopyStr("Sales Header"."Sell-to Customer Name", 1, 30);
                        end;
                    Type::Shipment:
                        begin
                            "Sales Shipment Header".Get("No.");
                            "Sell-To Name" := CopyStr("Sales Shipment Header"."Sell-to Customer Name", 1, 30);
                        end;
                end;
            end;
        }
        field(2; "Package Tracking Num"; Text[30])
        {
            Caption = 'Package Tracking Number';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                "Sales Header": Record "Sales Header";
                "Sales Shipment Header": Record "Sales Shipment Header";
                "Shipping Agent": Record "Shipping Agent";
            begin
                case Type of
                    Type::Order:
                        begin
                            "Sales Header".Get("Sales Header"."Document Type"::Order, "No.");
                            "Sell-To Name" := CopyStr("Sales Header"."Sell-to Customer Name", 1, 30);
                            "Shipping Agent".Get("Sales Header"."Shipping Agent Code");
                            "Track And Trace Link" := StrSubstNo("Shipping Agent"."Internet Address", "Package Tracking Num");
                        end;
                    Type::Shipment:
                        begin
                            "Sales Shipment Header".Get("No.");
                            "Sell-To Name" := CopyStr("Sales Shipment Header"."Sell-to Customer Name", 1, 30);
                            "Shipping Agent".Get("Sales Shipment Header"."Shipping Agent Code");
                            "Track And Trace Link" := StrSubstNo("Shipping Agent"."Internet Address", "Package Tracking Num");
                        end;
                end;
            end;
        }
        field(3; "Kolli Num"; Integer)
        {
            Caption = 'Kolli Number';
            DataClassification = CustomerContent;
        }
        field(4; Description; Text[250])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(5; Type; Option)
        {
            Caption = 'Type';
            OptionCaption = 'Order,Shipment,Return Order';
            OptionMembers = "Order",Shipment,ReturnOrder;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                "Type Caption" := Format(Type);
            end;
        }
        field(6; "Type Caption"; Text[30])
        {
            Caption = 'Type Caption';
            DataClassification = CustomerContent;
        }
        field(7; "Print Date"; Date)
        {
            Caption = 'Print Date';
            DataClassification = CustomerContent;
        }
        field(8; "Shipping Agent"; Code[10])
        {
            Caption = 'Shipping Agent';
            TableRelation = "Shipping Agent";
            DataClassification = CustomerContent;
        }
        field(10; "Sell-To Name"; Text[30])
        {
            Caption = 'Sell-To Name';
            FieldClass = Normal;
            DataClassification = CustomerContent;
        }
        field(11; "Sell-To Email"; Text[80])
        {
            Caption = 'Sell-To Email';
            DataClassification = CustomerContent;
        }
        field(20; "Track And Trace Link"; Text[250])
        {
            Caption = 'Track And Trace Link';
            DataClassification = CustomerContent;
        }
        field(30; "DHL AWB Num"; Text[30])
        {
            Caption = 'DHL AWB No.';
            DataClassification = CustomerContent;
        }
        field(31; "DHL Customer No"; Code[20])
        {
            Caption = 'DHL Customer No.';
            DataClassification = CustomerContent;
        }
        field(40; Cancelled; Boolean)
        {
            Caption = 'Cancelled';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "No.", "Package Tracking Num")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        "Print Date" := Today();
    end;
}

