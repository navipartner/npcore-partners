table 6150661 "NPR NPRE Waiter Pad Line"
{
    Caption = 'Waiter Pad Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Waiter Pad No."; Code[20])
        {
            Caption = 'Waiter Pad No.';
            DataClassification = CustomerContent;
            Description = 'Key';
            TableRelation = "NPR NPRE Waiter Pad"."No.";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
            Description = 'Key';
        }
        field(11; "Register No."; Code[10])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(14; "Start Date"; Date)
        {
            Caption = 'Start Date';
            DataClassification = CustomerContent;
        }
        field(15; "Start Time"; Time)
        {
            Caption = 'Start Time';
            DataClassification = CustomerContent;
        }
        field(20; "Marked Qty"; Decimal)
        {
            Caption = 'Qty. to ticket';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Description = 'Only used in temp mode';
            MaxValue = 99.999;
        }
        field(29; "Amount Excl. VAT"; Decimal)
        {
            Caption = 'Amount Excl. VAT';
            DataClassification = CustomerContent;
        }
        field(30; "Amount Incl. VAT"; Decimal)
        {
            Caption = 'Amount Incl. VAT';
            DataClassification = CustomerContent;
        }
        field(40; "Meal Flow"; Code[10])
        {
            Caption = 'Meal Flow';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Replaced with table 6150674 "NPR NPRE Assigned Flow Status"';
            TableRelation = "NPR NPRE Flow Status".Code WHERE("Status Object" = CONST(WaiterPadLineMealFlow));
        }
        field(41; "Meal Flow Description"; Text[50])
        {
            Caption = 'Meal Flow Description';
            ObsoleteState = Removed;
            ObsoleteReason = 'Replaced with table 6150674 "NPR NPRE Assigned Flow Status"';
            FieldClass = FlowField;
        }
        field(42; "Meal Flow Order"; Integer)
        {
            Caption = 'Meal Flow Order';
            ObsoleteState = Removed;
            ObsoleteReason = 'Replaced with table 6150674 "NPR NPRE Assigned Flow Status"';
            FieldClass = FlowField;
        }
        field(45; "Line Status"; Code[10])
        {
            Caption = 'Line Status';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Flow Status".Code WHERE("Status Object" = CONST(WaiterPadLineStatus));
        }
        field(46; "Line Status Description"; Text[50])
        {
            CalcFormula = Lookup("NPR NPRE Flow Status".Description WHERE(Code = FIELD("Line Status")));
            Caption = 'Line Status Description';
            FieldClass = FlowField;
        }
        field(50; Type; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            InitValue = Item;
            OptionCaption = 'G/L,Item,Item Group,Repair,,Payment,Open/Close,Inventory,Customer,Comment';
            OptionMembers = "G/L Entry",Item,"Item Group",Repair,,Payment,"Open/Close","BOM List",Customer,Comment;
        }
        field(51; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            TableRelation = IF (Type = CONST("G/L Entry")) "G/L Account"."No."
            ELSE
            IF (Type = CONST("Item Group")) "NPR Item Group"."No."
            ELSE
            IF (Type = CONST(Repair)) "NPR Customer Repair"."No."
            ELSE
            IF (Type = CONST(Payment)) "NPR POS Payment Method".Code WHERE("Block POS Payment" = const(false))
            ELSE
            IF (Type = CONST(Customer)) Customer."No."
            ELSE
            IF (Type = CONST(Item)) Item."No.";
            ValidateTableRelation = false;
        }
        field(52; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(53; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            MaxValue = 99.999;

            trigger OnValidate()
            begin
                TestIsOpen();
                "Quantity (Base)" := CalcBaseQty(Quantity);
            end;
        }
        field(54; Marked; Boolean)
        {
            Caption = 'Marked';
            DataClassification = CustomerContent;
            Description = 'Only used in temp mode';
        }
        field(55; "Sale Type"; Option)
        {
            Caption = 'Sale Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Sale,Payment,Debit Sale,Gift Voucher,Credit Voucher,Deposit,Out payment,Comment,Cancelled,Open/Close';
            OptionMembers = Sale,Payment,"Debit Sale","Gift Voucher","Credit Voucher",Deposit,"Out payment",Comment,Cancelled,"Open/Close";
        }
        field(56; "Description 2"; Text[50])
        {
            Caption = 'Description 2';
            DataClassification = CustomerContent;
            Description = 'NPR5.23';
        }
        field(57; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
            TableRelation = IF (Type = CONST(Item)) "Item Variant".Code WHERE("Item No." = FIELD("No."));
        }
        field(58; "Order No. from Web"; Code[20])
        {
            Caption = 'Order No. from Web';
            DataClassification = CustomerContent;
        }
        field(59; "Order Line No. from Web"; Integer)
        {
            BlankZero = true;
            Caption = 'Order Line No. from Web';
            DataClassification = CustomerContent;
        }
        field(60; "Unit Price"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit Price';
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 2;
            Editable = true;
            MaxValue = 9999999;
        }
        field(61; "Discount Type"; Option)
        {
            Caption = 'Discount Type';
            DataClassification = CustomerContent;
            Description = 'NPR5.30';
            OptionCaption = ' ,Period,Mixed,Multiple Unit,Salesperson Discount,Inventory,,Rounding,Combination,Customer';
            OptionMembers = " ",Campaign,Mix,Quantity,Manual,"BOM List",,Rounding,Combination,Customer;
        }
        field(62; "Discount Code"; Code[20])
        {
            Caption = 'Discount Code';
            DataClassification = CustomerContent;
        }
        field(63; "Allow Invoice Discount"; Boolean)
        {
            Caption = 'Allow Invoice Discount';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(64; "Allow Line Discount"; Boolean)
        {
            Caption = 'Allow Line Discount';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(65; "Discount %"; Decimal)
        {
            Caption = 'Discount %';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 1;
            MaxValue = 100;
            MinValue = 0;
        }
        field(66; "Discount Amount"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Discount';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
        field(67; "Invoice Discount Amount"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Invoice Discount Amount';
            DataClassification = CustomerContent;
        }
        field(68; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = Currency;
        }
        field(69; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            DataClassification = CustomerContent;
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("No."));

            trigger OnValidate()
            var
                UOMMgt: Codeunit "Unit of Measure Management";
            begin
                case Type of
                    Type::Item:
                        begin
                            GetItem;
                            "Qty. per Unit of Measure" := UOMMgt.GetQtyPerUnitOfMeasure(Item, "Unit of Measure Code");
                        end;
                    else
                        "Qty. per Unit of Measure" := 1;
                end;
                Validate(Quantity);
            end;
        }
        field(70; "Price Includes VAT"; Boolean)
        {
            Caption = 'Price Includes VAT';
            DataClassification = CustomerContent;
            Description = 'NPR5.54';
        }
        field(71; "VAT Bus. Posting Group"; Code[10])
        {
            Caption = 'VAT Bus. Posting Group';
            DataClassification = CustomerContent;
            Description = 'NPR5.54';
            TableRelation = "VAT Business Posting Group";
        }
        field(72; "VAT Prod. Posting Group"; Code[10])
        {
            Caption = 'VAT Prod. Posting Group';
            DataClassification = CustomerContent;
            Description = 'NPR5.54';
            TableRelation = "VAT Product Posting Group";
        }
        field(80; "Sale Line Retail ID"; Guid)
        {
            Caption = 'Sale Line Retail ID';
            DataClassification = CustomerContent;
            Description = 'NPR5.55';
        }
        field(81; "Sale Retail ID"; Guid)
        {
            Caption = 'Sale Retail ID';
            DataClassification = CustomerContent;
            Description = 'NPR5.55';
        }
        field(90; "Qty. per Unit of Measure"; Decimal)
        {
            Caption = 'Qty. per Unit of Measure';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Description = 'NPR5.55';
            Editable = false;
            InitValue = 1;
        }
        field(91; "Quantity (Base)"; Decimal)
        {
            Caption = 'Quantity (Base)';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Description = 'NPR5.55';

            trigger OnValidate()
            begin
                TestField("Qty. per Unit of Measure", 1);
                Validate(Quantity, "Quantity (Base)");
            end;
        }
        field(92; "Billed Qty. (Base)"; Decimal)
        {
            Caption = 'Billed Qty. (Base)';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Description = 'NPR5.55';

            trigger OnValidate()
            begin
                TestField("Qty. per Unit of Measure");
                "Billed Quantity" := Round("Billed Qty. (Base)" / "Qty. per Unit of Measure", 0.00001);
            end;
        }
        field(93; "Qty. On POS Sale Line (Base)"; Decimal)
        {
            CalcFormula = Sum("NPR Sale Line POS"."Quantity (Base)" WHERE("Retail ID" = FIELD("Sale Line Retail ID")));
            Caption = 'Qty. On POS Sale Line (Base)';
            DecimalPlaces = 0 : 5;
            Description = 'NPR5.55';
            Editable = false;
            FieldClass = FlowField;
        }
        field(94; "Billed Quantity"; Decimal)
        {
            Caption = 'Billed Quantity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Description = 'NPR5.55';

            trigger OnValidate()
            begin
                "Billed Qty. (Base)" := CalcBaseQty("Billed Quantity");
            end;
        }
        field(100; "Print Category Filter"; Code[20])
        {
            Caption = 'Print Category Filter';
            Description = 'NPR5.53';
            FieldClass = FlowFilter;
            TableRelation = "NPR NPRE Print/Prod. Cat.";
        }
        field(101; "Serving Step Filter"; Code[10])
        {
            Caption = 'Serving Step Filter';
            Description = 'NPR5.53';
            FieldClass = FlowFilter;
            TableRelation = "NPR NPRE Flow Status".Code WHERE("Status Object" = CONST(WaiterPadLineMealFlow));
        }
        field(102; "Print Type Filter"; Option)
        {
            Caption = 'Print Type Filter';
            Description = 'NPR5.53';
            FieldClass = FlowFilter;
            OptionCaption = 'Kitchen Order,Serving Request';
            OptionMembers = "Kitchen Order","Serving Request";
        }
        field(103; "Output Type Filter"; Option)
        {
            Caption = 'Output Type Filter';
            Description = 'NPR5.55';
            FieldClass = FlowFilter;
            OptionCaption = 'Print,KDS';
            OptionMembers = Print,KDS;
        }
        field(121; "Sent to Kitchen"; Boolean)
        {
            CalcFormula = Exist("NPR NPRE W.Pad Prnt LogEntry" WHERE("Waiter Pad No." = FIELD("Waiter Pad No."),
                                                                        "Waiter Pad Line No." = FIELD("Line No."),
                                                                        "Print Type" = FIELD("Print Type Filter"),
                                                                        "Print Category Code" = FIELD("Print Category Filter"),
                                                                        "Flow Status Object" = CONST(WaiterPadLineMealFlow),
                                                                        "Flow Status Code" = FIELD("Serving Step Filter"),
                                                                        "Output Type" = FIELD("Output Type Filter")));
            Caption = 'Sent to Kitchen';
            Description = 'NPR5.53';
            Editable = false;
            FieldClass = FlowField;
        }
        field(122; "Kitchen Order Sent"; Boolean)
        {
            CalcFormula = Exist("NPR NPRE W.Pad Prnt LogEntry" WHERE("Waiter Pad No." = FIELD("Waiter Pad No."),
                                                                        "Waiter Pad Line No." = FIELD("Line No."),
                                                                        "Print Type" = CONST("Kitchen Order"),
                                                                        "Print Category Code" = FIELD("Print Category Filter"),
                                                                        "Flow Status Object" = CONST(WaiterPadLineMealFlow),
                                                                        "Flow Status Code" = FIELD("Serving Step Filter"),
                                                                        "Output Type" = FIELD("Output Type Filter")));
            Caption = 'Kitchen Order Sent';
            Description = 'NPR5.53';
            Editable = false;
            FieldClass = FlowField;
        }
        field(123; "Serving Requested"; Boolean)
        {
            CalcFormula = Exist("NPR NPRE W.Pad Prnt LogEntry" WHERE("Waiter Pad No." = FIELD("Waiter Pad No."),
                                                                        "Waiter Pad Line No." = FIELD("Line No."),
                                                                        "Print Type" = CONST("Serving Request"),
                                                                        "Print Category Code" = FIELD("Print Category Filter"),
                                                                        "Flow Status Object" = CONST(WaiterPadLineMealFlow),
                                                                        "Flow Status Code" = FIELD("Serving Step Filter"),
                                                                        "Output Type" = FIELD("Output Type Filter")));
            Caption = 'Serving Requested';
            Description = 'NPR5.53';
            Editable = false;
            FieldClass = FlowField;
        }
        field(124; "Sent to Kitchen Qty. (Base)"; Decimal)
        {
            CalcFormula = Sum("NPR NPRE W.Pad Prnt LogEntry"."Sent Quanity (Base)" WHERE("Waiter Pad No." = FIELD("Waiter Pad No."),
                                                                                            "Waiter Pad Line No." = FIELD("Line No."),
                                                                                            "Print Type" = FIELD("Print Type Filter"),
                                                                                            "Print Category Code" = FIELD("Print Category Filter"),
                                                                                            "Flow Status Object" = CONST(WaiterPadLineMealFlow),
                                                                                            "Flow Status Code" = FIELD("Serving Step Filter"),
                                                                                            "Output Type" = FIELD("Output Type Filter")));
            Caption = 'Sent to Kitchen Qty. (Base)';
            DecimalPlaces = 0 : 5;
            Description = 'NPR5.55';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Waiter Pad No.", "Line No.")
        {
        }
    }

    trigger OnDelete()
    var
        POSInfoWaiterPadLink: Record "NPR POS Info NPRE Waiter Pad";
    begin
        WaiterPadMgt.ClearAssignedPrintCategories(RecordId);
        WaiterPadMgt.ClearAssignedFlowStatuses(RecordId, FlowStatus."Status Object"::WaiterPadLineMealFlow);

        POSInfoWaiterPadLink.SetRange("Waiter Pad No.", "Waiter Pad No.");
        POSInfoWaiterPadLink.SetRange("Waiter Pad Line No.", "Line No.");
        if not POSInfoWaiterPadLink.IsEmpty then
            POSInfoWaiterPadLink.DeleteAll;
    end;

    trigger OnInsert()
    var
        BongLine: Record "NPR NPRE Waiter Pad Line";
    begin
        BongLine.Reset;
        BongLine.SetRange("Waiter Pad No.", Rec."Waiter Pad No.");
        if BongLine.IsEmpty then begin
            "Line No." := 10000;
        end else begin
            BongLine.FindLast;
            "Line No." := BongLine."Line No." + 10000;
        end;
    end;

    trigger OnRename()
    begin
        WaiterPadMgt.MoveAssignedPrintCategories(xRec.RecordId, RecordId);
        WaiterPadMgt.MoveAssignedFlowStatuses(xRec.RecordId, RecordId, FlowStatus."Status Object"::WaiterPadLineMealFlow);
    end;

    var
        FlowStatus: Record "NPR NPRE Flow Status";
        Item: Record Item;
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
        OpenCheckSuspended: Boolean;

    procedure AssignedPrintCategoriesAsString(): Text
    begin
        exit(WaiterPadMgt.AssignedPrintCategoriesAsFilterString(RecordId, GetFilter("Serving Step Filter")));
    end;

    procedure ShowPrintCategories()
    begin
        TestField("Waiter Pad No.");
        TestField("Line No.");
        WaiterPadMgt.SelectPrintCategories(RecordId);
    end;

    procedure NoOfPrintCategories(): Integer
    var
        AssignedPrintCategory: Record "NPR NPRE Assign. Print Cat.";
    begin
        WaiterPadMgt.FilterAssignedPrintCategories(RecordId, AssignedPrintCategory);
        CopyFilter("Print Category Filter", AssignedPrintCategory."Print/Prod. Category Code");
        exit(AssignedPrintCategory.Count);
    end;

    procedure TotalNoOfPrintCategories(): Integer
    var
        AssignedPrintCategory: Record "NPR NPRE Assign. Print Cat.";
    begin
        WaiterPadMgt.FilterAssignedPrintCategories(RecordId, AssignedPrintCategory);
        exit(AssignedPrintCategory.Count);
    end;

    procedure AssignedFlowStatusesAsString(StatusObject: Option): Text
    var
        AssignedFlowStatus: Record "NPR NPRE Assigned Flow Status";
    begin
        exit(WaiterPadMgt.AssignedFlowStatusesAsFilterString(RecordId, StatusObject, AssignedFlowStatus));
    end;

    procedure ShowFlowStatuses(StatusObject: Option)
    var
        AssignedFlowStatus: Record "NPR NPRE Assigned Flow Status";
    begin
        TestField("Waiter Pad No.");
        TestField("Line No.");
        WaiterPadMgt.SelectFlowStatuses(RecordId, StatusObject, AssignedFlowStatus);
    end;

    procedure NoOfServingSteps(): Integer
    var
        AssignedFlowStatus: Record "NPR NPRE Assigned Flow Status";
    begin
        WaiterPadMgt.FilterAssignedFlowStatuses(RecordId, AssignedFlowStatus."Flow Status Object"::WaiterPadLineMealFlow, AssignedFlowStatus);
        CopyFilter("Serving Step Filter", AssignedFlowStatus."Flow Status Code");
        exit(AssignedFlowStatus.Count);
    end;

    procedure TotalNoOfServingSteps(): Integer
    var
        AssignedFlowStatus: Record "NPR NPRE Assigned Flow Status";
    begin
        WaiterPadMgt.FilterAssignedFlowStatuses(RecordId, AssignedFlowStatus."Flow Status Object"::WaiterPadLineMealFlow, AssignedFlowStatus);
        exit(AssignedFlowStatus.Count);
    end;

    local procedure CalcBaseQty(Qty: Decimal): Decimal
    begin
        TestField("Qty. per Unit of Measure");
        exit(Round(Qty * "Qty. per Unit of Measure", 0.00001));
    end;

    local procedure GetItem()
    begin
        TestField(Type, Type::Item);
        TestField("No.");
        if "No." <> Item."No." then
            Item.Get("No.");
    end;

    local procedure GetWaiterPad()
    begin
        if "Waiter Pad No." = '' then
            Clear(WaiterPad)
        else
            if "Waiter Pad No." <> WaiterPad."No." then
                WaiterPad.Get("Waiter Pad No.");
    end;

    procedure RemainingQtyToBill(): Decimal
    begin
        exit(Quantity - "Billed Quantity");
    end;

    procedure TestIsOpen()
    begin
        if OpenCheckSuspended then
            exit;
        GetWaiterPad;
        WaiterPad.TestField(Closed, false);
    end;

    procedure SuspendOpenCheck(Suspend: Boolean)
    begin
        OpenCheckSuspended := Suspend;
    end;

    procedure IsClosed(): Boolean
    begin
        GetWaiterPad;
        exit(WaiterPad.Closed);
    end;
}