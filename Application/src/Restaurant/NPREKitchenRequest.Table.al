﻿table 6150678 "NPR NPRE Kitchen Request"
{
    Access = Internal;
    Caption = 'Kitchen Request';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR NPRE Kitchen Req. List";
    LookupPageID = "NPR NPRE Kitchen Req. List";

    fields
    {
        field(1; "Request No."; BigInteger)
        {
            AutoIncrement = true;
            Caption = 'Request No.';
            DataClassification = CustomerContent;
        }
        field(20; "Order ID"; BigInteger)
        {
            Caption = 'Order ID';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Kitchen Order";
        }
        field(30; "Line Status"; Enum "NPR NPRE K.Request Line Status")
        {
            Caption = 'Line Status';
            DataClassification = CustomerContent;
            InitValue = Planned;
        }
        field(40; "Production Status"; Enum "NPR NPRE K.Req.L. Prod.Status")
        {
            Caption = 'Production Status';
            DataClassification = CustomerContent;
        }
        field(45; "Station Production Status"; Enum "NPR NPRE K.Req.L. Prod.Status")
        {
            Caption = 'Station Production Status';
            ValuesAllowed = "Not Started", Started, Finished, Cancelled;
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("NPR NPRE Kitchen Req. Station"."Production Status"
                where("Request No." = field("Request No."), "Production Restaurant Code" = field("Production Restaurant Filter"), "Kitchen Station" = field("Kitchen Station Filter")));
        }
        field(50; "Restaurant Code"; Code[20])
        {
            Caption = 'Restaurant Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Restaurant";
        }
        field(60; "Serving Step"; Code[10])
        {
            Caption = 'Serving Step';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Flow Status".Code where("Status Object" = const(WaiterPadLineMealFlow));
        }
        field(70; "Created Date-Time"; DateTime)
        {
            Caption = 'Created Date-Time';
            DataClassification = CustomerContent;
        }
        field(75; "Expected Dine Date-Time"; DateTime)
        {
            Caption = 'Expected Dine Date-Time';
            DataClassification = CustomerContent;
        }
        field(80; "Serving Requested Date-Time"; DateTime)
        {
            Caption = 'Serving Requested Date-Time';
            DataClassification = CustomerContent;
        }
        field(90; Priority; Integer)
        {
            Caption = 'Priority';
            DataClassification = CustomerContent;
        }
        field(100; Type; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            InitValue = Item;
            OptionCaption = ',Item,,,,,,,,Comment';
            OptionMembers = ,Item,,,,,,,,Comment;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Use Line Type';
        }
        field(101; "Line Type"; Enum "NPR POS Sale Line Type")
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            InitValue = Item;
            ValuesAllowed = Item, Comment;

            trigger OnValidate()
            begin
                if "Line Type" <> xRec."Line Type" then begin
                    TestChangesAllowed();
                    RevertToNewLineState();
                end;
            end;
        }
        field(110; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            TableRelation = IF ("Line Type" = CONST(Item)) Item;

            trigger OnValidate()
            begin
                if "No." <> xRec."No." then begin
                    TestChangesAllowed();
                    RevertToNewLineState();
                    "No." := KitchenOrderLine."No.";
                    if "No." = '' then
                        exit;
                end;

                case "Line Type" of
                    "Line Type"::Item:
                        begin
                            GetItem();
                            Item.TestField(Blocked, false);
                            Validate("Unit of Measure Code", Item."Sales Unit of Measure");
                        end;
                    else
                        Validate("Unit of Measure Code");
                end;
            end;
        }
        field(111; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
            TableRelation = if ("Line Type" = const(Item)) "Item Variant".Code where("Item No." = field("No."));
        }
        field(120; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(130; Quantity; Decimal)
        {
            CalcFormula = Sum("NPR NPRE Kitchen Req.Src. Link".Quantity where("Request No." = field("Request No.")));
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(140; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            DataClassification = CustomerContent;
            TableRelation = if ("Line Type" = const(Item),
                                "No." = filter(<> '')) "Item Unit of Measure".Code where("Item No." = field("No."));

            trigger OnValidate()
            var
                UOMMgt: Codeunit "Unit of Measure Management";
            begin
                case "Line Type" of
                    "Line Type"::Item:
                        begin
                            GetItem();
                            "Qty. per Unit of Measure" := UOMMgt.GetQtyPerUnitOfMeasure(Item, "Unit of Measure Code");
                        end;
                    else
                        "Qty. per Unit of Measure" := 1;
                end;
            end;
        }
        field(150; "Qty. per Unit of Measure"; Decimal)
        {
            Caption = 'Qty. per Unit of Measure';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Editable = false;
            InitValue = 1;
        }
        field(160; "Quantity (Base)"; Decimal)
        {
            CalcFormula = Sum("NPR NPRE Kitchen Req.Src. Link"."Quantity (Base)" where("Request No." = field("Request No.")));
            Caption = 'Quantity (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(170; "On Hold"; Boolean)
        {
            Caption = 'On Hold';
            DataClassification = CustomerContent;
        }
        field(1000; "Kitchen Station Filter"; Code[20])
        {
            Caption = 'Kitchen Station Filter';
            FieldClass = FlowFilter;
            TableRelation = "NPR NPRE Kitchen Station".Code where("Restaurant Code" = field("Production Restaurant Filter"));
        }
        field(1010; "Production Restaurant Filter"; Code[20])
        {
            Caption = 'Production Restaurant Filter';
            FieldClass = FlowFilter;
            TableRelation = "NPR NPRE Restaurant";
        }
        field(1100; "Applicable for Kitchen Station"; Boolean)
        {
            CalcFormula = Exist("NPR NPRE Kitchen Req. Station" where("Request No." = field("Request No."),
                                                                      "Production Restaurant Code" = field("Production Restaurant Filter"),
                                                                      "Kitchen Station" = field("Kitchen Station Filter")));
            Caption = 'Applicable for Kitchen Station';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1110; "No. of Kitchen Stations"; Integer)
        {
            CalcFormula = Count("NPR NPRE Kitchen Req. Station" where("Request No." = field("Request No.")));
            Caption = 'No. of Kitchen Stations';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1120; "Qty. Changed"; Boolean)
        {
            CalcFormula = Exist("NPR NPRE Kitchen Req. Station" where("Request No." = field("Request No."),
                                                                      "Production Restaurant Code" = field("Production Restaurant Filter"),
                                                                      "Kitchen Station" = field("Kitchen Station Filter"),
                                                                      "Qty. Change Not Accepted" = const(true)));
            Caption = 'Qty. Changed';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Request No.")
        {
        }
        key(Key2; "Order ID")
        {
        }
        key(Key3; "Restaurant Code", "Line Status", Priority, "Order ID", "Created Date-Time")
        {
        }
    }

    trigger OnDelete()
    var
        KitchenReqStation: Record "NPR NPRE Kitchen Req. Station";
    begin
        KitchenReqStation.SetRange("Request No.", "Request No.");
        if not KitchenReqStation.IsEmpty then
            KitchenReqStation.DeleteAll();

        DeleteSourceLinks();
    end;

    var
        Item: Record Item;
        KitchenOrderLine: Record "NPR NPRE Kitchen Request";

    local procedure TestChangesAllowed()
    begin
        TestField("Line Status", "Line Status"::"Ready for Serving");
        TestField("Production Status", "Production Status"::"Not Started");
    end;

    local procedure RevertToNewLineState()
    begin
        KitchenOrderLine := Rec;
        Init();
        "Restaurant Code" := KitchenOrderLine."Restaurant Code";
        "Line Type" := KitchenOrderLine."Line Type";
    end;

    local procedure GetItem()
    begin
        TestField("Line Type", "Line Type"::Item);
        TestField("No.");
        if "No." <> Item."No." then
            Item.Get("No.");
    end;

    internal procedure GetNextStationReqLineNo(): Integer
    var
        KitchenReqStation: Record "NPR NPRE Kitchen Req. Station";
    begin
        KitchenReqStation.SetRange("Request No.", "Request No.");
        if not KitchenReqStation.FindLast() then
            KitchenReqStation."Line No." := 0;
        exit(KitchenReqStation."Line No." + 10000);
    end;

    internal procedure InitFromWaiterPadLine(WaiterPadLine: Record "NPR NPRE Waiter Pad Line")
    begin
        Init();
        "Request No." := 0;
        "Line Type" := WaiterPadLine."Line Type";
        "No." := WaiterPadLine."No.";
        "Variant Code" := WaiterPadLine."Variant Code";
        Description := WaiterPadLine.Description;
        "Unit of Measure Code" := WaiterPadLine."Unit of Measure Code";
        "Qty. per Unit of Measure" := WaiterPadLine."Qty. per Unit of Measure";
    end;

    internal procedure SeatingCode(): Code[20]
    var
        SeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
        KitchenReqSourceLink: Record "NPR NPRE Kitchen Req.Src. Link";
    begin
        KitchenReqSourceLink.SetCurrentKey("Request No.");
        KitchenReqSourceLink.SetRange("Request No.", Rec."Request No.");
        if KitchenReqSourceLink.FindLast() then
            case KitchenReqSourceLink."Source Document Type" of
                KitchenReqSourceLink."Source Document Type"::"Waiter Pad":
                    begin
                        SeatingWaiterPadLink.SetRange("Waiter Pad No.", KitchenReqSourceLink."Source Document No.");
                        if SeatingWaiterPadLink.FindFirst() then
                            exit(SeatingWaiterPadLink."Seating Code");
                    end;
            end;
        exit('');
    end;

    internal procedure SeatingNo(): Text[20]
    var
        SeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
        KitchenReqSourceLink: Record "NPR NPRE Kitchen Req.Src. Link";
    begin
        KitchenReqSourceLink.SetCurrentKey("Request No.");
        KitchenReqSourceLink.SetRange("Request No.", Rec."Request No.");
        if KitchenReqSourceLink.FindLast() then
            case KitchenReqSourceLink."Source Document Type" of
                KitchenReqSourceLink."Source Document Type"::"Waiter Pad":
                    begin
                        SeatingWaiterPadLink.SetAutoCalcFields("Seating No.");
                        SeatingWaiterPadLink.SetRange("Waiter Pad No.", KitchenReqSourceLink."Source Document No.");
                        if SeatingWaiterPadLink.FindFirst() then
                            exit(SeatingWaiterPadLink."Seating No.");
                    end;
            end;
        exit('');
    end;

    local procedure DeleteSourceLinks()
    var
        KitchenReqSourceLink: Record "NPR NPRE Kitchen Req.Src. Link";
    begin
        KitchenReqSourceLink.SetCurrentKey("Request No.");
        KitchenReqSourceLink.SetRange("Request No.", "Request No.");
        if not KitchenReqSourceLink.IsEmpty then
            KitchenReqSourceLink.DeleteAll();
    end;
}
