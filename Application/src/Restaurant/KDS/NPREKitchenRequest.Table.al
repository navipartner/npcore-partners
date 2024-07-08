table 6150678 "NPR NPRE Kitchen Request"
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
            ValuesAllowed = "Not Started", Started, "On Hold", Finished, Cancelled;
        }
        field(45; "Station Production Status"; Enum "NPR NPRE K.Req.L. Prod.Status")
        {
            Caption = 'Station Production Status';
            ValuesAllowed = "Not Started", Pending, Started, Finished, Cancelled;
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
        field(85; "Served Date-Time"; DateTime)
        {
            Caption = 'Served Date-Time';
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
            var
                xKitchenOrderLine: Record "NPR NPRE Kitchen Request";
            begin
                if "Line Type" <> xRec."Line Type" then begin
                    TestChangesAllowed();
                    RevertToNewLineState(xKitchenOrderLine);
                end;
            end;
        }
        field(110; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            TableRelation = IF ("Line Type" = CONST(Item)) Item;

            trigger OnValidate()
            var
                xKitchenOrderLine: Record "NPR NPRE Kitchen Request";
            begin
                if "No." <> xRec."No." then begin
                    TestChangesAllowed();
                    RevertToNewLineState(xKitchenOrderLine);
                    "No." := xKitchenOrderLine."No.";
                    if "No." = '' then
                        exit;
                end;

                case "Line Type" of
                    "Line Type"::Item:
                        begin
                            GetItem();
                            _Item.TestField(Blocked, false);
                            Validate("Unit of Measure Code", _Item."Sales Unit of Measure");
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
            CalcFormula = Sum("NPR NPRE Kitchen Req.Src. Link".Quantity
                          where("Request No." = field("Request No."),
                                "Source Document Type" = field("Source Document Type Filter"),
                                "Source Document Subtype" = field("Source Document Subtype Filter"),
                                "Source Document No." = field("Source Document No. Filter"),
                                "Source Document Line No." = field("Source Doc. Line No. Filter")));
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
                            "Qty. per Unit of Measure" := UOMMgt.GetQtyPerUnitOfMeasure(_Item, "Unit of Measure Code");
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
            CalcFormula = Sum("NPR NPRE Kitchen Req.Src. Link"."Quantity (Base)"
                          where("Request No." = field("Request No."),
                                "Source Document Type" = field("Source Document Type Filter"),
                                "Source Document Subtype" = field("Source Document Subtype Filter"),
                                "Source Document No." = field("Source Document No. Filter"),
                                "Source Document Line No." = field("Source Doc. Line No. Filter")));
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
        field(180; "Parent Request No."; BigInteger)
        {
            Caption = 'Request No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Kitchen Request";
        }
        field(190; Indentation; Integer)
        {
            Caption = 'Indentation';
            DataClassification = CustomerContent;
            MinValue = 0;
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
        field(1020; "Source Document Type Filter"; Enum "NPR NPRE K.Req.Source Doc.Type")
        {
            Caption = 'Source Document Type Filter';
            FieldClass = FlowFilter;
        }
        field(1021; "Source Document Subtype Filter"; Option)
        {
            Caption = 'Source Document Subtype Filter';
            FieldClass = FlowFilter;
            OptionCaption = '0,1,2,3,4,5,6,7,8,9,10';
            OptionMembers = "0","1","2","3","4","5","6","7","8","9","10";
        }
        field(1022; "Source Document No. Filter"; Code[20])
        {
            Caption = 'Source Document No. Filter';
            FieldClass = FlowFilter;
            TableRelation = If ("Source Document Type Filter" = const("Waiter Pad")) "NPR NPRE Waiter Pad";
        }
        field(1023; "Source Doc. Line No. Filter"; Integer)
        {
            Caption = 'Source Doc. Line No. Filter';
            FieldClass = FlowFilter;
            TableRelation = If ("Source Document Type Filter" = const("Waiter Pad")) "NPR NPRE Waiter Pad Line"."Line No." where("Waiter Pad No." = field("Source Document No. Filter"));
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
        field(1130; "Modifications Exist"; Boolean)
        {
            CalcFormula = exist("NPR NPRE Kitchen Req. Modif." where("Request No." = field("Request No.")));
            Caption = 'Modifications Exist"';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Request No.") { }
        key(Key2; "Order ID") { }
        key(Key3; "Restaurant Code", "Line Status", Priority, "Order ID", "Created Date-Time") { }
        key(Key4; "Parent Request No.", "Line Status") { }
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

    local procedure TestChangesAllowed()
    begin
        TestField("Line Status", "Line Status"::"Ready for Serving");
        TestField("Production Status", "Production Status"::"Not Started");
    end;

    local procedure RevertToNewLineState(var xKitchenOrderLine: Record "NPR NPRE Kitchen Request")
    begin
        xKitchenOrderLine := Rec;
        Init();
        "Restaurant Code" := xKitchenOrderLine."Restaurant Code";
        "Line Type" := xKitchenOrderLine."Line Type";
    end;

    local procedure GetItem()
    begin
        TestField("Line Type", "Line Type"::Item);
        TestField("No.");
        if "No." <> _Item."No." then
            _Item.Get("No.");
    end;

    internal procedure GetNextStationReqLineNo(): Integer
    var
        KitchenReqStation: Record "NPR NPRE Kitchen Req. Station";
    begin
        KitchenReqStation.LockTable();
        KitchenReqStation.SetRange("Request No.", "Request No.");
        if not KitchenReqStation.FindLast() then
            KitchenReqStation."Line No." := 0;
        exit(KitchenReqStation."Line No." + 10000);
    end;

    internal procedure InitFromWaiterPadLine(WaiterPadLine: Record "NPR NPRE Waiter Pad Line")
    var
        ParentKitchenRequest: Record "NPR NPRE Kitchen Request";
    begin
        Init();
        "Request No." := 0;
        "Parent Request No." := GetParentRequestNo(WaiterPadLine);
        if "Parent Request No." = 0 then
            Indentation := 0
        else
            if ParentKitchenRequest.Get("Parent Request No.") then
                Indentation := ParentKitchenRequest.Indentation + 1;
        "Line Type" := WaiterPadLine."Line Type";
        "No." := WaiterPadLine."No.";
        "Variant Code" := WaiterPadLine."Variant Code";
        Description := WaiterPadLine.Description;
        "Unit of Measure Code" := WaiterPadLine."Unit of Measure Code";
        "Qty. per Unit of Measure" := WaiterPadLine."Qty. per Unit of Measure";
    end;

    local procedure GetParentRequestNo(WaiterPadLine: Record "NPR NPRE Waiter Pad Line"): BigInteger
    var
        KitchenReqSourceLink: Record "NPR NPRE Kitchen Req.Src. Link";
    begin
        if WaiterPadLine."Attached to Line No." <> 0 then begin
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21)
            KitchenReqSourceLink.ReadIsolation := IsolationLevel::ReadUncommitted;
#ENDIF
            KitchenReqSourceLink.SetCurrentKey(
                "Source Document Type", "Source Document Subtype", "Source Document No.", "Source Document Line No.", "Serving Step", "Request No.");
            KitchenReqSourceLink.SetRange("Source Document Type", KitchenReqSourceLink."Source Document Type"::"Waiter Pad");
            KitchenReqSourceLink.SetRange("Source Document Subtype", 0);
            KitchenReqSourceLink.SetRange("Source Document No.", WaiterPadLine."Waiter Pad No.");
            KitchenReqSourceLink.SetRange("Source Document Line No.", WaiterPadLine."Attached to Line No.");
            if KitchenReqSourceLink.FindFirst() then
                exit(KitchenReqSourceLink."Request No.");
        end;
        exit(0);
    end;

    local procedure DeleteSourceLinks()
    var
        KitchenReqSourceLink: Record "NPR NPRE Kitchen Req.Src. Link";
    begin
        KitchenReqSourceLink.SetCurrentKey("Request No.");
        KitchenReqSourceLink.SetRange("Request No.", "Request No.");
        if not KitchenReqSourceLink.IsEmpty() then
            KitchenReqSourceLink.DeleteAll();
    end;

    internal procedure SetSourceDocLinkFilter(KitchenReqSourceLink: Record "NPR NPRE Kitchen Req.Src. Link")
    begin
        SetRange("Source Document Type Filter", KitchenReqSourceLink."Source Document Type");
        SetRange("Source Document Subtype Filter", KitchenReqSourceLink."Source Document Subtype");
        SetRange("Source Document No. Filter", KitchenReqSourceLink."Source Document No.");
        SetRange("Source Doc. Line No. Filter", KitchenReqSourceLink."Source Document Line No.");
    end;

    internal procedure ClearSourceDocLinkFilter()
    begin
        SetRange("Source Document Type Filter");
        SetRange("Source Document Subtype Filter");
        SetRange("Source Document No. Filter");
        SetRange("Source Doc. Line No. Filter");
    end;

    internal procedure GetSeatingAndWaiter(var AssignedWaiters: Text; var SeatingCodes: Text; var SeatingNos: Text)
    var
        KitchenReqSourceLink: Record "NPR NPRE Kitchen Req.Src. Link";
        AssignedWaiterList: List of [Code[20]];
        SeatingCodeList: List of [Code[20]];
        SeatingNoList: List of [Code[20]];
    begin
        AssignedWaiters := '';
        SeatingCodes := '';
        SeatingNos := '';

#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21)
        KitchenReqSourceLink.ReadIsolation := IsolationLevel::ReadUncommitted;
#ENDIF
        KitchenReqSourceLink.SetCurrentKey("Request No.");
        KitchenReqSourceLink.SetRange("Request No.", "Request No.");
        KitchenReqSourceLink.SetAutoCalcFields("Seating No.");
        if not KitchenReqSourceLink.FindSet() then
            exit;
        repeat
            if KitchenReqSourceLink."Assigned Waiter Code" <> '' then
                if not AssignedWaiterList.Contains(KitchenReqSourceLink."Assigned Waiter Code") then
                    AssignedWaiterList.Add(KitchenReqSourceLink."Assigned Waiter Code");
            if KitchenReqSourceLink."Seating Code" <> '' then
                if not SeatingCodeList.Contains(KitchenReqSourceLink."Seating Code") then begin
                    SeatingCodeList.Add(KitchenReqSourceLink."Seating Code");
                    if not SeatingNoList.Contains(KitchenReqSourceLink."Seating No.") then
                        SeatingNoList.Add(KitchenReqSourceLink."Seating No.");
                end;
        until KitchenReqSourceLink.Next() = 0;

        AssignedWaiters := ListToText(AssignedWaiterList);
        SeatingCodes := ListToText(SeatingCodeList);
        SeatingNos := ListToText(SeatingNoList);
    end;

    local procedure ListToText(ListOfCodes: List of [Code[20]]): Text
    var
        Result: TextBuilder;
        Entry: Text;
    begin
        if ListOfCodes.Count() = 0 then
            exit('');
        foreach Entry in ListOfCodes do
            Result.Append(Entry + ',');
        exit(Result.ToText(1, Result.Length - 1));
    end;

    procedure IsFilteredByRestaurant() IsFiltered: Boolean
    begin
        IsFiltered := GetFilter("Restaurant Code") <> '';
        if not IsFiltered then begin
            FilterGroup(2);
            IsFiltered := GetFilter("Restaurant Code") <> '';
            FilterGroup(0);
        end;
    end;

    procedure GetRestaurantFromFilter() RestaurantCode: Code[20]
    begin
        RestaurantCode := GetFilterRestCode();
        if RestaurantCode = '' then begin
            FilterGroup(2);
            RestaurantCode := GetFilterRestCode();
            if RestaurantCode = '' then
                RestaurantCode := GetFilterRestCodeByApplyingFilter();
            FilterGroup(0);
        end;
    end;

    local procedure GetFilterRestCode(): Code[20]
    var
        MinValue: Code[20];
        MaxValue: Code[20];
    begin
        if GetFilter("Restaurant Code") <> '' then begin
            if TryGetFilterRestCodeRange(MinValue, MaxValue) then
                if MinValue = MaxValue then
                    exit(MaxValue);
        end;
    end;

    [TryFunction]
    local procedure TryGetFilterRestCodeRange(var MinValue: Code[20]; var MaxValue: Code[20])
    begin
        MinValue := GetRangeMin("Restaurant Code");
        MaxValue := GetRangeMax("Restaurant Code");
    end;

    local procedure GetFilterRestCodeByApplyingFilter(): Code[20]
    var
        KitchenOrderLine: Record "NPR NPRE Kitchen Request";
        MinValue: Code[20];
        MaxValue: Code[20];
    begin
        if GetFilter("Restaurant Code") <> '' then begin
            KitchenOrderLine.CopyFilters(Rec);
            KitchenOrderLine.SetCurrentKey("Restaurant Code");
            if KitchenOrderLine.FindFirst() then
                MinValue := KitchenOrderLine."Restaurant Code";
            if KitchenOrderLine.FindLast() then
                MaxValue := KitchenOrderLine."Restaurant Code";
            if MinValue = MaxValue then
                exit(MaxValue);
        end;
    end;

    var
        _Item: Record Item;
}
