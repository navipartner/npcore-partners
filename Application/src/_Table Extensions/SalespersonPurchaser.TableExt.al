tableextension 6014416 "NPR Salesperson/Purchaser" extends "Salesperson/Purchaser"
{
    fields
    {
        field(6014400; "NPR Register Password"; Code[20])
        {
            Caption = 'POS Unit Password';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';

            trigger OnValidate()
            var
                RegisterCodeAlreadyUsedErr: Label 'Register Code %1 already exists.', Comment = '%1 = Register Code';
            begin
                Rec.SetRange("NPR Register Password", Rec."NPR Register Password");
                if not Rec.IsEmpty() then
                    Error(RegisterCodeAlreadyUsedErr, Rec."NPR Register Password");
            end;
        }
        field(6014402; "NPR Hide Register Imbalance"; Boolean)
        {
            Caption = 'Hide Register Imbalance';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
        }
        field(6014403; "NPR Sales (LCY)"; Decimal)
        {
            CalcFormula = Sum("NPR Aux. Value Entry"."Sales Amount (Actual)"
                            WHERE(
                                "Item Ledger Entry Type" = CONST(Sale),
                                "Salespers./Purch. Code" = FIELD(Code),
                                "Posting Date" = FIELD("Date Filter"),
                                "Item Category Code" = FIELD("NPR Item Category Filter"),
                                "Global Dimension 1 Code" = FIELD("NPR Global Dimension 1 Filter"),
                                "Item No." = FIELD("NPR Item Filter")));
            Caption = 'Sales (LCY)';
            Description = 'NPR7.100.000';
            FieldClass = FlowField;
        }
        field(6014404; "NPR Discount Amount"; Decimal)
        {
            CalcFormula = - Sum("NPR Aux. Value Entry"."Discount Amount"
                                WHERE(
                                    "Item Ledger Entry Type" = CONST(Sale),
                                    "Salespers./Purch. Code" = FIELD(Code),
                                    "Posting Date" = FIELD("Date Filter"),
                                    "Item Category Code" = FIELD("NPR Item Category Filter"),
                                    "Global Dimension 1 Code" = FIELD("NPR Global Dimension 1 Filter")));
            Caption = 'Discount Amount';
            Description = 'NPR7.100.000';
            FieldClass = FlowField;
        }
        field(6014405; "NPR COGS (LCY)"; Decimal)
        {
            CalcFormula = - Sum("NPR Aux. Value Entry"."Cost Amount (Actual)"
                                WHERE(
                                    "Item Ledger Entry Type" = CONST(Sale),
                                    "Salespers./Purch. Code" = FIELD(Code),
                                    "Posting Date" = FIELD("Date Filter"),
                                    "Item Category Code" = FIELD("NPR Item Category Filter"),
                                    "Global Dimension 1 Code" = FIELD("NPR Global Dimension 1 Filter")));
            Caption = 'COGS (LCY)';
            Description = 'NPR7.100.000';
            FieldClass = FlowField;
        }
        field(6014406; "NPR Item Category Filter"; Code[20])
        {
            Caption = 'Item Category Filter';
            Description = 'NPR7.100.000';
            FieldClass = FlowFilter;
        }
        field(6014407; "NPR Sales (Qty.)"; Decimal)
        {
            CalcFormula = - Sum("NPR Aux. Value Entry"."Valued Quantity"
                                WHERE(
                                    "Item Ledger Entry Type" = CONST(Sale),
                                    "Salespers./Purch. Code" = FIELD(Code),
                                    "Posting Date" = FIELD("Date Filter"),
                                    "Item Category Code" = FIELD("NPR Item Category Filter"),
                                    "Global Dimension 1 Code" = FIELD("NPR Global Dimension 1 Filter"),
                                    "Item No." = FIELD("NPR Item Filter")));
            Caption = 'Sales (Qty.)';
            Description = 'NPR7.100.000';
            FieldClass = FlowField;
        }
        field(6014408; "NPR Reverse Sales Ticket"; Option)
        {
            Caption = 'Reverse Sales Ticket';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
            OptionCaption = 'Yes,No';
            OptionMembers = Yes,No;
            ObsoleteState = Removed;
            ObsoleteReason = 'Won''t be used anymore';
        }
        field(6014410; "NPR Register Filter"; Code[10])
        {
            Caption = 'Register Filter';
            Description = 'NPR7.100.000';
            FieldClass = FlowFilter;
            TableRelation = "NPR POS Unit";
        }
        field(6014411; "NPR Global Dimension 1 Filter"; Code[20])
        {
            Caption = 'Global Dimension 1 Filter';
            Description = 'NPR7.100.000';
            FieldClass = FlowFilter;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
        }
        field(6014412; "NPR Item Group Sales (LCY)"; Decimal)
        {
            CalcFormula = Sum("NPR Aux. Value Entry"."Sales Amount (Actual)"
                            WHERE("Item Ledger Entry Type" = CONST(Sale),
                                "Salespers./Purch. Code" = FIELD(Code),
                                "Posting Date" = FIELD("Date Filter"),
                                "Item Category Code" = FIELD("NPR Item Category Filter"),
                                "Global Dimension 1 Code" = FIELD("NPR Global Dimension 1 Filter"),
                                "Group Sale" = CONST(true)));
            Caption = 'Item Group Sales (LCY)';
            Description = 'NPR7.100.000';
            FieldClass = FlowField;
        }
        field(6014413; "NPR Item Filter"; Code[20])
        {
            Caption = 'Item Filter';
            Description = 'NPR7.100.000';
            FieldClass = FlowFilter;
        }
        field(6014416; "NPR Locked-to Register No."; Code[10])
        {
            Caption = 'Locked-to POS Unit No.';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
        }
        field(6014420; "NPR Maximum Cash Returnsale"; Decimal)
        {
            Caption = 'Maximum Cash Returnsale';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
        }
        field(6014421; "NPR Picture"; BLOB)
        {
            Caption = 'Picture';
            DataClassification = CustomerContent;
            Description = 'NPR5.26';
            SubType = Bitmap;
            ObsoleteState = Removed;
            ObsoleteReason = 'Standard field used instead.';
        }
        field(6014422; "NPR Supervisor POS"; Boolean)
        {
            Caption = 'Supervisor';
            DataClassification = CustomerContent;
            Description = 'NPR5.38';
        }

        field(6151479; "NPR Replication Counter"; BigInteger)
        {
            Caption = 'Replication Counter';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key("NPR Key1"; "NPR Replication Counter")
        {
        }
    }

    trigger OnAfterDelete()
    var
        POSEntry: Record "NPR POS Entry";
        SalesPersonDeleteErr: Label 'you cannot delete Salesperson/purchaser %1 before the sale is posted in the Audit roll!', Comment = '%1 = Salesperson/purchaser';
    begin
        POSEntry.SetRange("Salesperson Code", Rec.Code);
        POSEntry.SetFilter("Post Entry Status", '%1|%2', POSEntry."Post Entry Status"::Unposted, POSEntry."Post Entry Status"::"Error while Posting");
        if not POSEntry.IsEmpty() then
            Error(SalesPersonDeleteErr, Rec.Code);
    end;
}