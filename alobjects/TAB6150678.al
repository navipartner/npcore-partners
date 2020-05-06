table 6150678 "NPRE Kitchen Request"
{
    // NPR5.54/ALPO/20200401 CASE 382428 Kitchen Display System (KDS) for NP Restaurant

    Caption = 'Kitchen Request';
    DrillDownPageID = "NPRE Kitchen Request List";
    LookupPageID = "NPRE Kitchen Request List";

    fields
    {
        field(1;"Request No.";BigInteger)
        {
            AutoIncrement = true;
            Caption = 'Request No.';
        }
        field(10;"Source Document Type";Option)
        {
            Caption = 'Source Document Type';
            OptionCaption = ' ,Waiter Pad';
            OptionMembers = " ","Waiter Pad";
        }
        field(11;"Source Document Subtype";Option)
        {
            Caption = 'Source Document Subtype';
            OptionCaption = '0,1,2,3,4,5,6,7,8,9,10';
            OptionMembers = "0","1","2","3","4","5","6","7","8","9","10";
        }
        field(12;"Source Document No.";Code[20])
        {
            Caption = 'Source Document No.';
            TableRelation = IF ("Source Document Type"=CONST("Waiter Pad")) "NPRE Waiter Pad";
        }
        field(13;"Source Document Line No.";Integer)
        {
            Caption = 'Source Document Line No.';
            TableRelation = IF ("Source Document Type"=CONST("Waiter Pad")) "NPRE Waiter Pad Line"."Line No." WHERE ("Waiter Pad No."=FIELD("Source Document No."));
        }
        field(20;"Order ID";BigInteger)
        {
            Caption = 'Order ID';
            TableRelation = "NPRE Kitchen Order";
        }
        field(30;"Line Status";Option)
        {
            Caption = 'Line Status';
            InitValue = Planned;
            OptionCaption = 'Ready for Serving,Serving Requested,Planned,Served,Cancelled';
            OptionMembers = "Ready for Serving","Serving Requested",Planned,Served,Cancelled;
        }
        field(40;"Production Status";Option)
        {
            Caption = 'Production Status';
            OptionCaption = 'Not Started,Started,On Hold,Finished,Cancelled';
            OptionMembers = "Not Started",Started,"On Hold",Finished,Cancelled;
        }
        field(50;"Restaurant Code";Code[20])
        {
            Caption = 'Restaurant Code';
            TableRelation = "NPRE Restaurant";
        }
        field(60;"Serving Step";Code[10])
        {
            Caption = 'Serving Step';
            TableRelation = "NPRE Flow Status".Code WHERE ("Status Object"=CONST(WaiterPadLineMealFlow));
        }
        field(70;"Created Date-Time";DateTime)
        {
            Caption = 'Created Date-Time';
        }
        field(80;"Serving Requested Date-Time";DateTime)
        {
            Caption = 'Serving Requested Date-Time';
        }
        field(90;Priority;Integer)
        {
            Caption = 'Priority';
        }
        field(100;Type;Option)
        {
            Caption = 'Type';
            InitValue = Item;
            OptionCaption = ',Item,,,,,,,,Comment';
            OptionMembers = ,Item,,,,,,,,Comment;

            trigger OnValidate()
            begin
                if Type <> xRec.Type then begin
                  TestChangesAllowed;
                  RevertToNewLineState;
                end;
            end;
        }
        field(110;"No.";Code[20])
        {
            Caption = 'No.';
            TableRelation = IF (Type=CONST(Item)) Item;

            trigger OnValidate()
            begin
                if "No." <> xRec."No." then begin
                  TestChangesAllowed;
                  RevertToNewLineState;
                  "No." := KitchenOrderLine."No.";
                  if "No." = '' then
                    exit;
                  if Type <> Type::Comment then
                    Quantity := KitchenOrderLine.Quantity;
                end;

                case Type of
                  Type::Item: begin
                    GetItem;
                    Item.TestField(Blocked,false);
                    Validate("Unit of Measure Code",Item."Sales Unit of Measure");
                  end;
                  else
                    Validate("Unit of Measure Code");
                end;
            end;
        }
        field(111;"Variant Code";Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = IF (Type=CONST(Item)) "Item Variant".Code WHERE ("Item No."=FIELD("No."));
        }
        field(120;Description;Text[80])
        {
            Caption = 'Description';
        }
        field(130;Quantity;Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0:5;

            trigger OnValidate()
            begin
                "Quantity (Base)" := CalcBaseQty(Quantity);
            end;
        }
        field(140;"Unit of Measure Code";Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = IF (Type=CONST(Item),
                                "No."=FILTER(<>'')) "Item Unit of Measure".Code WHERE ("Item No."=FIELD("No."));

            trigger OnValidate()
            var
                UOMMgt: Codeunit "Unit of Measure Management";
            begin
                case Type of
                  Type::Item: begin
                    GetItem;
                    "Qty. per Unit of Measure" := UOMMgt.GetQtyPerUnitOfMeasure(Item,"Unit of Measure Code");
                  end;
                  else
                    "Qty. per Unit of Measure" := 1;
                end;
                Validate(Quantity);
            end;
        }
        field(150;"Qty. per Unit of Measure";Decimal)
        {
            Caption = 'Qty. per Unit of Measure';
            DecimalPlaces = 0:5;
            Editable = false;
            InitValue = 1;
        }
        field(160;"Quantity (Base)";Decimal)
        {
            Caption = 'Quantity (Base)';
            DecimalPlaces = 0:5;

            trigger OnValidate()
            begin
                TestField("Qty. per Unit of Measure",1);
                Validate(Quantity,"Quantity (Base)");
            end;
        }
        field(170;"On Hold";Boolean)
        {
            Caption = 'On Hold';
        }
        field(1000;"Kitchen Station Filter";Code[20])
        {
            Caption = 'Kitchen Station Filter';
            FieldClass = FlowFilter;
            TableRelation = "NPRE Kitchen Station".Code WHERE ("Restaurant Code"=FIELD("Production Restaurant Filter"));
        }
        field(1010;"Production Restaurant Filter";Code[20])
        {
            Caption = 'Production Restaurant Filter';
            FieldClass = FlowFilter;
            TableRelation = "NPRE Restaurant";
        }
        field(1100;"Applicable for Kitchen Station";Boolean)
        {
            CalcFormula = Exist("NPRE Kitchen Request Station" WHERE ("Request No."=FIELD("Request No."),
                                                                      "Production Restaurant Code"=FIELD("Production Restaurant Filter"),
                                                                      "Kitchen Station"=FIELD("Kitchen Station Filter")));
            Caption = 'Applicable for Kitchen Station';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1110;"No. of Kitchen Stations";Integer)
        {
            CalcFormula = Count("NPRE Kitchen Request Station" WHERE ("Request No."=FIELD("Request No.")));
            Caption = 'No. of Kitchen Stations';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1;"Request No.")
        {
        }
        key(Key2;"Order ID")
        {
        }
        key(Key3;"Restaurant Code","Line Status",Priority,"Order ID","Created Date-Time")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        KitchenReqStation: Record "NPRE Kitchen Request Station";
    begin
        KitchenReqStation.SetRange("Request No.","Request No.");
        if not KitchenReqStation.IsEmpty then
          KitchenReqStation.DeleteAll;
    end;

    var
        Item: Record Item;
        KitchenOrderLine: Record "NPRE Kitchen Request";
        ChangesAllowedTestSuppressed: Boolean;

    local procedure CalcBaseQty(Qty: Decimal): Decimal
    begin
        TestField("Qty. per Unit of Measure");
        exit(Round(Qty * "Qty. per Unit of Measure",0.00001));
    end;

    local procedure TestChangesAllowed()
    begin
        TestField("Line Status","Line Status"::"Ready for Serving");
        TestField("Production Status","Production Status"::"Not Started");
    end;

    procedure SuppressChangesAllowedTest(Suppress: Boolean)
    begin
        ChangesAllowedTestSuppressed := Suppress;
    end;

    local procedure RevertToNewLineState()
    begin
        KitchenOrderLine := Rec;
        Init;
        "Source Document Type" := KitchenOrderLine."Source Document Type";
        "Source Document Subtype" := KitchenOrderLine."Source Document Subtype";
        "Source Document No." := KitchenOrderLine."Source Document No.";
        "Source Document Line No." := KitchenOrderLine."Source Document Line No.";
        "Restaurant Code" := KitchenOrderLine."Restaurant Code";
        Type := KitchenOrderLine.Type;
    end;

    local procedure GetItem()
    begin
        TestField(Type,Type::Item);
        TestField("No.");
        if "No." <> Item."No." then
          Item.Get("No.");
    end;

    procedure GetNextStationReqLineNo(): Integer
    var
        KitchenReqStation: Record "NPRE Kitchen Request Station";
    begin
        KitchenReqStation.SetRange("Request No.","Request No.");
        if not KitchenReqStation.FindLast then
          KitchenReqStation."Line No." := 0;
        exit(KitchenReqStation."Line No." + 10000);
    end;

    procedure InitFromWaiterPadLine(WaiterPadLine: Record "NPRE Waiter Pad Line")
    begin
        Init;
        "Request No." := 0;
        "Source Document Type" := "Source Document Type"::"Waiter Pad";
        "Source Document Subtype" := 0;
        "Source Document No." := WaiterPadLine."Waiter Pad No.";
        "Source Document Line No." := WaiterPadLine."Line No.";
        Type := WaiterPadLine.Type;
        "No." := WaiterPadLine."No.";
        "Variant Code" := WaiterPadLine."Variant Code";
        Description := WaiterPadLine.Description;
        Quantity := WaiterPadLine.Quantity;
        Validate("Unit of Measure Code",WaiterPadLine."Unit of Measure Code");
    end;
}

