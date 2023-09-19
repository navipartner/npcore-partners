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
            Editable = false;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(3; "POS Store Code"; Code[10])
        {
            Caption = 'POS Store Code';
            Editable = false;
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Store";
        }
        field(4; "POS Unit No."; Code[10])
        {
            Caption = 'POS Unit No.';
            Editable = false;
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Unit";
        }
        field(5; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(6; "Fiscal No."; Code[20])
        {
            Caption = 'Fiscal No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(7; "POS Period Register No."; Integer)
        {
            Caption = 'POS Period Register No.';
            Editable = false;
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Period Register";
        }
        field(9; "Entry Type"; Option)
        {
            Caption = 'Entry Type';
            Editable = false;
            DataClassification = CustomerContent;
            OptionCaption = 'Comment,Direct Sale,Other,Credit Sale,Balancing,Cancelled Sale';
            OptionMembers = Comment,"Direct Sale",Other,"Credit Sale",Balancing,"Cancelled Sale";
        }
        field(10; "Entry Date"; Date)
        {
            Caption = 'Entry Date';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(11; "Starting Time"; Time)
        {
            Caption = 'Starting Time';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(12; "Ending Time"; Time)
        {
            Caption = 'Ending Time';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(14; Description; Text[100])
        {
            Caption = 'Description';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(20; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            Editable = false;
            DataClassification = CustomerContent;
            TableRelation = Customer;
        }
        field(30; "System Entry"; Boolean)
        {
            Caption = 'System Entry';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(40; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Editable = true;
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, "Shortcut Dimension 1 Code");
            end;
        }

        field(41; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Editable = true;
            Caption = 'Shortcut Dimension 2 Code';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2, "Shortcut Dimension 2 Code");
            end;
        }
        field(43; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            Editable = false;
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
            Editable = false;
            DataClassification = CustomerContent;
            OptionCaption = 'Unposted,Error while Posting,Posted,Not To Be Posted';
            OptionMembers = Unposted,"Error while Posting",Posted,"Not To Be Posted";
        }
        field(53; "Post Entry Status"; Option)
        {
            Caption = 'Post Entry Status';
            Editable = false;
            DataClassification = CustomerContent;
            OptionCaption = 'Unposted,Error while Posting,Posted,Not To Be Posted';
            OptionMembers = Unposted,"Error while Posting",Posted,"Not To Be Posted";
        }
        field(54; "POS Posting Log Entry No."; Integer)
        {
            Caption = 'POS Finance Posting Log Entry No.';
            Editable = false;
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Posting Log";
        }
        field(55; "Post Sales Document Status"; Option)
        {
            Caption = 'Post Sales Document Status';
            Editable = false;
            DataClassification = CustomerContent;
            OptionCaption = 'Not To Be Posted,Unposted,Error while Posting,Posted';
            OptionMembers = "Not To Be Posted",Unposted,"Error while Posting",Posted;
        }
        field(60; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(61; "Document Date"; Date)
        {
            Caption = 'Document Date';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(70; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            Editable = false;
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
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(101; "Discount Amount"; Decimal)
        {
            Caption = 'Discount Amount';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(102; "Sales Quantity"; Decimal)
        {
            Caption = 'Sales Quantity';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(103; "Return Sales Quantity"; Decimal)
        {
            Caption = 'Return Sales Quantity';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(104; "Amount Excl. Tax"; Decimal)
        {
            Caption = 'Amount Excl. Tax';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(105; "Tax Amount"; Decimal)
        {
            Caption = 'Tax Amount';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(106; "Amount Incl. Tax"; Decimal)
        {
            Caption = 'Amount Incl. Tax';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(108; "No. of Sales Lines"; Integer)
        {
            Caption = 'No. of Sales Lines';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(109; "Item Returns (LCY)"; Decimal)
        {
            Caption = 'Item Returns (LCY)';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(110; "Rounding Amount (LCY)"; Decimal)
        {
            Caption = 'Rounding Amount (LCY)';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(111; "Amount Incl. Tax & Round"; Decimal)
        {
            Caption = 'Amount Incl. Tax & Round';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(112; "Discount Amount Incl. VAT"; Decimal)
        {
            Caption = 'Discount Amount Incl. VAT';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(114; "Tax Area Code"; Code[20])
        {
            Caption = 'Tax Area Code';
            Editable = false;
            DataClassification = CustomerContent;
            TableRelation = "Tax Area";
        }
        field(128; "External Document No."; Code[35])
        {
            Caption = 'External Document No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(160; "POS Sale ID"; Integer)
        {
            Caption = 'POS Sale ID';
            Editable = false;
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Replaced by SystemID';
        }
        field(170; "Retail ID"; Guid)
        {
            Caption = 'Retail ID';
            Editable = false;
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Replaced by SystemID';
        }
        field(180; "Event No."; Code[20])
        {
            Caption = 'Active Event No.';
            Editable = false;
            DataClassification = CustomerContent;
            Description = 'NPR5.53 [376035]';
            TableRelation = Job WHERE("NPR Event" = CONST(true));
        }
        field(181; "Event Task No."; Code[20])
        {
            Caption = 'Event Task No.';
            Editable = false;
            DataClassification = CustomerContent;
            TableRelation = "Job Task"."Job Task No." where("Job No." = field("Event No."));
        }
        field(200; "Customer Posting Group"; Code[20])
        {
            Caption = 'Customer Posting Group';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "Customer Posting Group";
        }
        field(201; "Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
            Editable = false;
            DataClassification = CustomerContent;
            TableRelation = "Country/Region";
        }
        field(202; "Transaction Type"; Code[10])
        {
            Caption = 'Transaction Type';
            Editable = false;
            DataClassification = CustomerContent;
            TableRelation = "Transaction Type";
        }
        field(203; "Transport Method"; Code[10])
        {
            Caption = 'Transport Method';
            Editable = false;
            DataClassification = CustomerContent;
            TableRelation = "Transport Method";
        }
        field(204; "Exit Point"; Code[10])
        {
            Caption = 'Exit Point';
            Editable = false;
            DataClassification = CustomerContent;
            TableRelation = "Entry/Exit Point";
        }
        field(205; "Area"; Code[10])
        {
            Caption = 'Area';
            Editable = false;
            DataClassification = CustomerContent;
            TableRelation = Area;
        }
        field(206; "Transaction Specification"; Code[10])
        {
            Caption = 'Transaction Specification';
            Editable = false;
            DataClassification = CustomerContent;
            TableRelation = "Transaction Specification";
        }
        field(207; "Prices Including VAT"; Boolean)
        {
            Caption = 'Prices Including VAT';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(208; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            Editable = false;
            DataClassification = CustomerContent;
            TableRelation = "Reason Code";
        }
        field(210; "From External Source"; Boolean)
        {
            Caption = 'From External Source';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(211; "External Source Name"; Text[50])
        {
            Caption = 'External Source Name';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(212; "External Source Entry No."; Integer)
        {
            Caption = 'External Source Entry No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(213; "Is Pay-in Pay-out"; Boolean)
        {
            Caption = 'Is Pay-in Pay-out';
            FieldClass = FlowField;
            CalcFormula = exist("NPR POS Entry Sales Line" where("POS Entry No." = FIELD("Entry No."),
                                                                Type = filter(Payout)));
            Editable = false;
        }
        field(214; "Prioritized Posting"; Boolean)
        {
            Caption = 'Prioritized Posting';
            FieldClass = FlowField;
            CalcFormula = exist("NPR POS Entry Sales Line" where("POS Entry No." = FIELD("Entry No."), "Exclude from Posting" = const(false),
                                                                Type = filter(Payout | Customer)));
            Editable = false;
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
            Editable = false;
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
                ShowDimensions();
            end;
        }
        field(500; "Sales Document Type"; Enum "Sales Document Type")
        {
            Caption = 'Sales Document Type';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(501; "Sales Document No."; Code[20])
        {
            Caption = 'Sales Document No.';
            Editable = false;
            DataClassification = CustomerContent;
            TableRelation = "Sales Header"."No." WHERE("Document Type" = FIELD("Sales Document Type"));
        }
        field(600; "Sale Lines"; Integer)
        {
            CalcFormula = Count("NPR POS Entry Sales Line" WHERE("POS Entry No." = FIELD("Entry No.")));
            Caption = 'Sale Lines';
            Description = 'NPR5.53';
            Editable = false;
            FieldClass = FlowField;
        }
        field(610; "Payment Lines"; Integer)
        {
            CalcFormula = Count("NPR POS Entry Payment Line" WHERE("POS Entry No." = FIELD("Entry No.")));
            Caption = 'Payment Lines';
            Description = 'NPR5.53';
            Editable = false;
            FieldClass = FlowField;
        }
        field(611; "EFT Transaction Requests"; Integer)
        {
            CalcFormula = Count("NPR EFT Transaction Request" WHERE("Sales Ticket No." = FIELD("Document No."), "Register No." = FIELD("POS Unit No.")));
            Caption = 'EFT Transaction Requests';
            Editable = false;
            FieldClass = FlowField;
        }

        field(620; "Tax Lines"; Integer)
        {
            CalcFormula = Count("NPR POS Entry Tax Line" WHERE("POS Entry No." = FIELD("Entry No.")));
            Caption = 'Tax Lines';
            Description = 'NPR5.53';
            Editable = false;
            FieldClass = FlowField;
        }
        field(630; "Customer Sales (LCY)"; Decimal)
        {
            CalcFormula = Sum("NPR POS Entry Sales Line"."Amount Incl. VAT" WHERE("POS Entry No." = FIELD("Entry No."),
                                                                         Type = FILTER(Customer)));
            Caption = 'Customer Sales (LCY)';
            Description = 'NPR5.53';
            Editable = false;
            FieldClass = FlowField;
        }
        field(640; "G/L Sales (LCY)"; Decimal)
        {
            CalcFormula = Sum("NPR POS Entry Sales Line"."Amount Incl. VAT" WHERE("POS Entry No." = FIELD("Entry No."),
                                                                         Type = FILTER("G/L Account")));
            Caption = 'G/L Sales (LCY)';
            Description = 'NPR5.53';
            Editable = false;
            FieldClass = FlowField;
        }
        field(650; "Payment Amount"; Decimal)
        {
            CalcFormula = Sum("NPR POS Entry Payment Line".Amount WHERE("POS Entry No." = FIELD("Entry No.")));
            Caption = 'Payment Amount';
            Description = 'NPR5.53';
            Editable = false;
            FieldClass = FlowField;
        }
        field(710; "NPRE Number of Guests"; Integer)
        {
            Caption = 'Number of Guests';
            Editable = false;
            DataClassification = CustomerContent;
            Description = 'NPR5.53';
        }
        field(800; "Clean Cash Transactions"; Integer)
        {
            Editable = false;
            Caption = 'Clean Cash Transactions';
            FieldClass = FlowField;
            CalcFormula = count("NPR CleanCash Trans. Request" where("POS Entry No." = field("Entry No.")));
        }
        field(810; "DE POS Audit Log"; Boolean)
        {
            Editable = false;
            Caption = 'DE POS Audit Log Aux. Info';
            FieldClass = FlowField;
            CalcFormula = exist("NPR DE POS Audit Log Aux. Info" where("POS Entry No." = field("Entry No.")));
        }
        field(820; "FR POS Audit Log"; Boolean)
        {
            Editable = false;
            Caption = 'FR POS Audit Log Aux. Info';
            FieldClass = FlowField;
            ObsoleteState = Pending;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Replaced with table NPR FR POS Audit Log Add. Info';
            CalcFormula = exist("NPR FR POS Audit Log Aux. Info" where("POS Entry No." = field("Entry No.")));
        }
        field(830; "RS POS Audit Log"; Boolean)
        {
            Editable = false;
            Caption = 'RS POS Audit Log Aux. Info';
            FieldClass = FlowField;
            CalcFormula = exist("NPR RS POS Audit Log Aux. Info" where("Audit Entry Type" = const("POS Entry"), "POS Entry No." = field("Entry No.")));
        }
        field(840; "Total Item Sales (LCY)"; Decimal)
        {
            CalcFormula = Sum("NPR POS Entry Sales Line"."Amount Incl. VAT" WHERE("POS Entry No." = FIELD("Entry No."),
                                                                         Type = FILTER("Item")));
            Caption = 'Total Item Sales (LCY)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(5052; "Contact No."; Code[20])
        {
            Caption = 'Contact No.';
            Editable = false;
            DataClassification = CustomerContent;
            TableRelation = Contact;
        }
        field(5700; "Responsibility Center"; Code[10])
        {
            Caption = 'Responsibility Center';
            Editable = false;
            DataClassification = CustomerContent;
            TableRelation = "Responsibility Center";
        }
        field(6000; "Images Exist"; Boolean)
        {
            Caption = 'Images Exist';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = exist("NPR POS Entry Media Info" WHERE("Pos Entry No." = FIELD("Entry No.")));
        }
        field(6001; "Costumer Input"; Boolean)
        {
            Caption = 'Customer Input';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = exist("NPR POS Costumer Input" WHERE("POS Entry No." = FIELD("Entry No.")));
        }
        field(6002; "POS Info Exist"; Boolean)
        {
            Caption = 'POS Info Exist';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = exist("NPR POS Info POS Entry" WHERE("POS Entry No." = FIELD("Entry No.")));
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Retail ID")
        {
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Replaced by SystemID';
        }
        key(Key3; "POS Store Code", "POS Unit No.", "Document No.")
        {
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        key(Key4; "Document No.")
        {
#if not (BC17 or BC18)
            IncludedFields = "Entry Type";
#endif
        }

        key(Key5; "Customer No.", "Post Entry Status")
        {
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }

        key(Key6; "Salesperson Code", "Post Entry Status")
        {
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        key(Key7; "Posting Date", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code")
        {
            MaintainSqlIndex = false;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'sift performance not worth the locking';
        }
        key(Key8; "Fiscal No.")
        { }

        key(Key9; "POS Store Code", "Post Entry Status")
        { }
        key(Key10; "POS Store Code", "POS Unit No.")
        {
#if not (BC17 or BC18)
            IncludedFields = "System Entry", "Entry Type", "Entry Date";
#endif
        }
        key(Key11; "POS Period Register No.")
        { }
        key(Key12; "Customer No.", "Sales Document Type", "Document Date")
        { }
        key(Key13; "Posting Date", "Sales Document Type", "Sales Document No.")
        { }
        key(Key14; "Post Item Entry Status") { }
        key(Key15; "Posting Date", "Amount Excl. Tax", "Return Sales Quantity", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code") { }
        key(Key16; "Post Entry Status") { }
        key(Key17; "Post Sales Document Status") { }
    }

    fieldgroups
    {
        fieldgroup(Brick; Description, "Document No.", "Amount Incl. Tax", "Customer No.", "Posting Date")
        { }
    }

    trigger OnDelete()
    var
        POSSalesLine: Record "NPR POS Entry Sales Line";
        POSPaymentLine: Record "NPR POS Entry Payment Line";
        POSBalancingLine: Record "NPR POS Balancing Line";
        POSEntryCommentLine: Record "NPR POS Entry Comm. Line";
        POSEntryTaxCalc: codeunit "NPR POS Entry Tax Calc.";
    begin
        POSSalesLine.SetRange("POS Entry No.", "Entry No.");
        POSSalesLine.DeleteAll();
        POSPaymentLine.SetRange("POS Entry No.", "Entry No.");
        POSPaymentLine.DeleteAll();
        POSBalancingLine.SetRange("POS Entry No.", "Entry No.");
        POSBalancingLine.DeleteAll();
        POSEntryCommentLine.SetRange("POS Entry No.", "Entry No.");
        POSEntryCommentLine.DeleteAll();
        POSEntryTaxCalc.DeleteAllLines(Rec."Entry No.");
    end;

    internal procedure Recalculate()
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

    internal procedure ShowDimensions()
    var
        DimMgt: Codeunit DimensionManagement;
        DimSetIdLbl: Label '%1 %2', Locked = true;
    begin
        if (("Post Entry Status" = "Post Entry Status"::Posted) and ("Post Item Entry Status" = "Post Item Entry Status"::Posted)) then begin
            DimMgt.ShowDimensionSet("Dimension Set ID", StrSubstNo(DimSetIdLbl, TableCaption, "Entry No."));
        end else begin
            "Dimension Set ID" :=
              DimMgt.EditDimensionSet(
                "Dimension Set ID", StrSubstNo(DimSetIdLbl, TableCaption, "Entry No."), "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
            Modify();
        end;
    end;

    internal procedure IsSaleTransaction(): Boolean
    begin
        exit("Entry Type" in ["Entry Type"::"Direct Sale", "Entry Type"::"Credit Sale"]);
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnAfterRecalculate(var Modified: Boolean)
    begin
    end;

    internal procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    var
        DimMgt: Codeunit DimensionManagement;
    begin
        DimMgt.ValidateShortcutDimValues(FieldNumber, ShortcutDimCode, Rec."Dimension Set ID");
    end;
}
