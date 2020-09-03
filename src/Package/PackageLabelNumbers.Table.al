table 6014551 "NPR Package Label Numbers"
{
    // NPR4.000.000, 21-04-09, MH - Created in order to implement multi kolli.
    //                                Package Label numbers is stored in this table.
    // NPR4.000.001, 23-07-09, MH - Added field, Type, inorder to be able to print labels from sales orders.
    // NPR4.01/JDH/20150309  CASE 201022 added extra option on "Type" field

    Caption = 'Package Label Numbers';

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            TableRelation = IF (Type = CONST(Order)) "Sales Header"."No." WHERE("Document Type" = CONST(Order))
            ELSE
            IF (Type = CONST(Shipment)) "Sales Shipment Header";

            trigger OnValidate()
            var
                "Sales Header": Record "Sales Header";
                "Sales Shipment Header": Record "Sales Shipment Header";
            begin
                case Type of
                    Type::Order:
                        begin
                            "Sales Header".Get("Sales Header"."Document Type"::Order, "No.");
                            "Sell-To Name" := "Sales Header"."Sell-to Customer Name";
                        end;
                    Type::Shipment:
                        begin
                            "Sales Shipment Header".Get("No.");
                            "Sell-To Name" := "Sales Shipment Header"."Sell-to Customer Name";
                        end;
                end;
            end;
        }
        field(2; "Package Tracking Num"; Text[30])
        {
            Caption = 'Package Tracking Number';

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
                            "Sell-To Name" := "Sales Header"."Sell-to Customer Name";
                            "Shipping Agent".Get("Sales Header"."Shipping Agent Code");
                            "Track And Trace Link" := StrSubstNo("Shipping Agent"."Internet Address", "Package Tracking Num");
                        end;
                    Type::Shipment:
                        begin
                            "Sales Shipment Header".Get("No.");
                            "Sell-To Name" := "Sales Shipment Header"."Sell-to Customer Name";
                            "Shipping Agent".Get("Sales Shipment Header"."Shipping Agent Code");
                            "Track And Trace Link" := StrSubstNo("Shipping Agent"."Internet Address", "Package Tracking Num");
                        end;
                end;
            end;
        }
        field(3; "Kolli Num"; Integer)
        {
            Caption = 'Kolli Number';
        }
        field(4; Description; Text[250])
        {
            Caption = 'Description';
        }
        field(5; Type; Option)
        {
            Caption = 'Type';
            OptionCaption = 'Order,Shipment,Return Order';
            OptionMembers = "Order",Shipment,ReturnOrder;

            trigger OnValidate()
            begin
                "Type Caption" := Format(Type);
            end;
        }
        field(6; "Type Caption"; Text[30])
        {
            Caption = 'Type Caption';
        }
        field(7; "Print Date"; Date)
        {
            Caption = 'Print Date';
        }
        field(8; "Shipping Agent"; Code[10])
        {
            Caption = 'Shipping Agent';
            TableRelation = "Shipping Agent";
        }
        field(10; "Sell-To Name"; Text[30])
        {
            Caption = 'Sell-To Name';
            FieldClass = Normal;
        }
        field(11; "Sell-To Email"; Text[80])
        {
            Caption = 'Sell-To Email';
        }
        field(20; "Track And Trace Link"; Text[250])
        {
            Caption = 'Track And Trace Link';
        }
        field(30; "DHL AWB Num"; Text[30])
        {
            Caption = 'DHL AWB No.';
        }
        field(31; "DHL Customer No"; Code[20])
        {
            Caption = 'DHL Customer No.';
        }
        field(40; Cancelled; Boolean)
        {
            Caption = 'Cancelled';
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
        "Print Date" := Today;
    end;
}

