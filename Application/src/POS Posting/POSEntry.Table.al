table 6150621 "NPR POS Entry"
{
    Caption = 'POS Entry';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR POS Entries";
    LookupPageID = "NPR POS Entries";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(3; "POS Store Code"; Code[10])
        {
            Caption = 'POS Store Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Store";
        }
        field(4; "POS Unit No."; Code[10])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Unit";
        }
        field(5; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }
        field(6; "Fiscal No."; Code[20])
        {
            Caption = 'Fiscal No.';
            DataClassification = CustomerContent;
        }
        field(7; "POS Period Register No."; Integer)
        {
            Caption = 'POS Period Register No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Period Register";
        }
        field(9; "Entry Type"; Option)
        {
            Caption = 'Entry Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Comment,Direct Sale,Other,Credit Sale,Balancing,Cancelled Sale';
            OptionMembers = Comment,"Direct Sale",Other,"Credit Sale",Balancing,"Cancelled Sale";
        }
        field(10; "Entry Date"; Date)
        {
            Caption = 'Entry Date';
            DataClassification = CustomerContent;
        }
        field(11; "Starting Time"; Time)
        {
            Caption = 'Starting Time';
            DataClassification = CustomerContent;
        }
        field(12; "Ending Time"; Time)
        {
            Caption = 'Ending Time';
            DataClassification = CustomerContent;
        }
        field(14; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(20; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer;
        }
        field(30; "System Entry"; Boolean)
        {
            Caption = 'System Entry';
            DataClassification = CustomerContent;
        }
        field(40; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
        }
        field(41; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
        }
        field(43; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            DataClassification = CustomerContent;
            TableRelation = "Salesperson/Purchaser";
        }
        field(47; "No. Printed"; Integer)
        {
            Caption = 'No. Printed';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(52; "Post Item Entry Status"; Option)
        {
            Caption = 'Post Item Entry Status';
            DataClassification = CustomerContent;
            OptionCaption = 'Unposted,Error while Posting,Posted,Not To Be Posted';
            OptionMembers = Unposted,"Error while Posting",Posted,"Not To Be Posted";
        }
        field(53; "Post Entry Status"; Option)
        {
            Caption = 'Post Entry Status';
            DataClassification = CustomerContent;
            OptionCaption = 'Unposted,Error while Posting,Posted,Not To Be Posted';
            OptionMembers = Unposted,"Error while Posting",Posted,"Not To Be Posted";
        }
        field(54; "POS Posting Log Entry No."; Integer)
        {
            Caption = 'POS Posting Log Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Posting Log";
        }
        field(60; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
        }
        field(61; "Document Date"; Date)
        {
            Caption = 'Document Date';
            DataClassification = CustomerContent;
        }
        field(70; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = CustomerContent;
            TableRelation = Currency;
        }
        field(71; "Currency Factor"; Decimal)
        {
            Caption = 'Currency Factor';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 15;
            Editable = false;
            InitValue = 1;
            MinValue = 1;
        }
        field(100; "Item Sales (LCY)"; Decimal)
        {
            Caption = 'Item Sales (LCY)';
            DataClassification = CustomerContent;
        }
        field(101; "Discount Amount"; Decimal)
        {
            Caption = 'Discount Amount';
            DataClassification = CustomerContent;
        }
        field(102; "Sales Quantity"; Decimal)
        {
            Caption = 'Sales Quantity';
            DataClassification = CustomerContent;
        }
        field(103; "Return Sales Quantity"; Decimal)
        {
            Caption = 'Return Sales Quantity';
            DataClassification = CustomerContent;
        }
        field(104; "Amount Excl. Tax"; Decimal)
        {
            Caption = 'Amount Excl. Tax';
            DataClassification = CustomerContent;
        }
        field(105; "Tax Amount"; Decimal)
        {
            Caption = 'Tax Amount';
            DataClassification = CustomerContent;
        }
        field(106; "Amount Incl. Tax"; Decimal)
        {
            Caption = 'Amount Incl. Tax';
            DataClassification = CustomerContent;
        }
        field(108; "No. of Sales Lines"; Integer)
        {
            Caption = 'No. of Sales Lines';
            DataClassification = CustomerContent;
        }
        field(109; "Item Returns (LCY)"; Decimal)
        {
            Caption = 'Item Returns (LCY)';
            DataClassification = CustomerContent;
        }
        field(110; "Rounding Amount (LCY)"; Decimal)
        {
            Caption = 'Rounding Amount (LCY)';
            DataClassification = CustomerContent;
        }
        field(111; "Amount Incl. Tax & Round"; Decimal)
        {
            Caption = 'Amount Incl. Tax & Round';
            DataClassification = CustomerContent;
        }
        field(114; "Tax Area Code"; Code[20])
        {
            Caption = 'Tax Area Code';
            DataClassification = CustomerContent;
            TableRelation = "Tax Area";
        }
        field(160; "POS Sale ID"; Integer)
        {
            Caption = 'POS Sale ID';
            DataClassification = CustomerContent;
        }
        field(170; "Retail ID"; Guid)
        {
            Caption = 'Retail ID';
            DataClassification = CustomerContent;
        }
        field(180; "Event No."; Code[20])
        {
            Caption = 'Active Event No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.53 [376035]';
            TableRelation = Job WHERE("NPR Event" = CONST(true));
        }
        field(200; "Customer Posting Group"; Code[10])
        {
            Caption = 'Customer Posting Group';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "Customer Posting Group";
        }
        field(201; "Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
            DataClassification = CustomerContent;
            TableRelation = "Country/Region";
        }
        field(202; "Transaction Type"; Code[10])
        {
            Caption = 'Transaction Type';
            DataClassification = CustomerContent;
            TableRelation = "Transaction Type";
        }
        field(203; "Transport Method"; Code[10])
        {
            Caption = 'Transport Method';
            DataClassification = CustomerContent;
            TableRelation = "Transport Method";
        }
        field(204; "Exit Point"; Code[10])
        {
            Caption = 'Exit Point';
            DataClassification = CustomerContent;
            TableRelation = "Entry/Exit Point";
        }
        field(205; "Area"; Code[10])
        {
            Caption = 'Area';
            DataClassification = CustomerContent;
            TableRelation = Area;
        }
        field(206; "Transaction Specification"; Code[10])
        {
            Caption = 'Transaction Specification';
            DataClassification = CustomerContent;
            TableRelation = "Transaction Specification";
        }
        field(207; "Prices Including VAT"; Boolean)
        {
            Caption = 'Prices Including VAT';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                SalesLine: Record "Sales Line";
                Currency: Record Currency;
                RecalculatePrice: Boolean;
            begin
            end;
        }
        field(208; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            DataClassification = CustomerContent;
            TableRelation = "Reason Code";
        }
        field(210; "From External Source"; Boolean)
        {
            Caption = 'From External Source';
            DataClassification = CustomerContent;
        }
        field(211; "External Source Name"; Text[50])
        {
            Caption = 'External Source Name';
            DataClassification = CustomerContent;
        }
        field(212; "External Source Entry No."; Integer)
        {
            Caption = 'External Source Entry No.';
            DataClassification = CustomerContent;
        }
        field(230; "No. of Print Output Entries"; Integer)
        {
            CalcFormula = Count("NPR POS Entry Output Log" WHERE("POS Entry No." = FIELD("Entry No."),
                                                              "Output Method" = CONST(Print)));
            Caption = 'No. of Print Output Entries';
            Editable = false;
            FieldClass = FlowField;
        }
        field(240; "Fiscal No. Series"; Code[20])
        {
            Caption = 'Fiscal No. Series';
            DataClassification = CustomerContent;
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "Dimension Set Entry";

            trigger OnLookup()
            begin
                ShowDimensions;
            end;
        }
        field(500; "Sales Document Type"; Enum "Sales Document Type")
        {
            Caption = 'Sales Document Type';
            DataClassification = CustomerContent;
        }
        field(501; "Sales Document No."; Code[20])
        {
            Caption = 'Sales Document No.';
            DataClassification = CustomerContent;
            TableRelation = "Sales Header"."No." WHERE("Document Type" = FIELD("Sales Document Type"));
        }
        field(600; "Sale Lines"; Integer)
        {
            CalcFormula = Count("NPR POS Sales Line" WHERE("POS Entry No." = FIELD("Entry No.")));
            Caption = 'Sale Lines';
            Description = 'NPR5.53';
            Editable = false;
            FieldClass = FlowField;
        }
        field(610; "Payment Lines"; Integer)
        {
            CalcFormula = Count("NPR POS Payment Line" WHERE("POS Entry No." = FIELD("Entry No.")));
            Caption = 'Payment Lines';
            Description = 'NPR5.53';
            Editable = false;
            FieldClass = FlowField;
        }
        field(620; "Tax Lines"; Integer)
        {
            CalcFormula = Count("NPR POS Tax Amount Line" WHERE("POS Entry No." = FIELD("Entry No.")));
            Caption = 'Tax Lines';
            Description = 'NPR5.53';
            Editable = false;
            FieldClass = FlowField;
        }
        field(630; "Customer Sales (LCY)"; Decimal)
        {
            CalcFormula = Sum("NPR POS Sales Line"."Amount Incl. VAT" WHERE("POS Entry No." = FIELD("Entry No."),
                                                                         Type = FILTER(Customer)));
            Caption = 'Customer Sales (LCY)';
            Description = 'NPR5.53';
            Editable = false;
            FieldClass = FlowField;
        }
        field(640; "G/L Sales (LCY)"; Decimal)
        {
            CalcFormula = Sum("NPR POS Sales Line"."Amount Incl. VAT" WHERE("POS Entry No." = FIELD("Entry No."),
                                                                         Type = FILTER("G/L Account")));
            Caption = 'G/L Sales (LCY)';
            Description = 'NPR5.53';
            Editable = false;
            FieldClass = FlowField;
        }
        field(650; "Payment Amount"; Decimal)
        {
            CalcFormula = Sum("NPR POS Payment Line".Amount WHERE("POS Entry No." = FIELD("Entry No.")));
            Caption = 'Payment Amount';
            Description = 'NPR5.53';
            Editable = false;
            FieldClass = FlowField;
        }
        field(710; "NPRE Number of Guests"; Integer)
        {
            Caption = 'Number of Guests';
            DataClassification = CustomerContent;
            Description = 'NPR5.53';
        }
        field(5052; "Contact No."; Code[20])
        {
            Caption = 'Contact No.';
            DataClassification = CustomerContent;
            TableRelation = Contact;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Retail ID")
        {
        }
        key(Key3; "POS Store Code", "POS Unit No.", "Document No.")
        {
        }
        key(Key4; "Document No.")
        {
        }

        key(Key5; "Customer No.", "Post Entry Status")
        { }

        key(Key6; "Salesperson Code", "Post Entry Status")
        {
        }
        key(Key7; "Posting Date", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code")
        {
            SumIndexFields = "Amount Excl. Tax", "Amount Incl. Tax";
            MaintainSqlIndex = false;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        POSSalesLine: Record "NPR POS Sales Line";
        POSPaymentLine: Record "NPR POS Payment Line";
        POSBalancingLine: Record "NPR POS Balancing Line";
        POSEntryCommentLine: Record "NPR POS Entry Comm. Line";
        POSTaxAmountLine: Record "NPR POS Tax Amount Line";
    begin
        POSSalesLine.SetRange("POS Entry No.", "Entry No.");
        POSSalesLine.DeleteAll;
        POSPaymentLine.SetRange("POS Entry No.", "Entry No.");
        POSPaymentLine.DeleteAll;
        POSBalancingLine.SetRange("POS Entry No.", "Entry No.");
        POSBalancingLine.DeleteAll;
        POSEntryCommentLine.SetRange("POS Entry No.", "Entry No.");
        POSEntryCommentLine.DeleteAll;
        POSTaxAmountLine.SetRange("POS Entry No.", "Entry No.");
        POSTaxAmountLine.DeleteAll;
    end;

    procedure Recalculate()
    var
        POSEntryManagement: Codeunit "NPR POS Entry Management";
        EntryModified: Boolean;
    begin
        EntryModified := false;
        POSEntryManagement.RecalculatePOSEntry(Rec, EntryModified);
        OnAfterRecalculate(EntryModified);
        if EntryModified then
            Modify(true);
    end;

    procedure ShowDimensions()
    var
        DimMgt: Codeunit DimensionManagement;
    begin
        if (("Post Entry Status" = "Post Entry Status"::Posted) and ("Post Item Entry Status" = "Post Item Entry Status"::Posted)) then begin
            DimMgt.ShowDimensionSet("Dimension Set ID", StrSubstNo('%1 %2', TableCaption, "Entry No."));
        end else begin
            "Dimension Set ID" :=
              DimMgt.EditDimensionSet(
                "Dimension Set ID", StrSubstNo('%1 %2', TableCaption, "Entry No."), "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
            Modify();
        end;
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnAfterRecalculate(var Modified: Boolean)
    begin
    end;
}

