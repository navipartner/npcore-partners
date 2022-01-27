table 6150675 "NPR NPRE Kitchen Req.Src. Link"
{
    Access = Internal;
    Caption = 'Kitchen Request Source Link';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR NPRE Kitchen Req.Src.Links";
    LookupPageID = "NPR NPRE Kitchen Req.Src.Links";

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(10; "Request No."; BigInteger)
        {
            Caption = 'Request No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Kitchen Request";
        }
        field(20; "Source Document Type"; Option)
        {
            Caption = 'Source Document Type';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Waiter Pad';
            OptionMembers = " ","Waiter Pad";
        }
        field(21; "Source Document Subtype"; Option)
        {
            Caption = 'Source Document Subtype';
            DataClassification = CustomerContent;
            OptionCaption = '0,1,2,3,4,5,6,7,8,9,10';
            OptionMembers = "0","1","2","3","4","5","6","7","8","9","10";
        }
        field(22; "Source Document No."; Code[20])
        {
            Caption = 'Source Document No.';
            DataClassification = CustomerContent;
            TableRelation = IF ("Source Document Type" = CONST("Waiter Pad")) "NPR NPRE Waiter Pad";
        }
        field(23; "Source Document Line No."; Integer)
        {
            Caption = 'Source Document Line No.';
            DataClassification = CustomerContent;
            TableRelation = IF ("Source Document Type" = CONST("Waiter Pad")) "NPR NPRE Waiter Pad Line"."Line No." WHERE("Waiter Pad No." = FIELD("Source Document No."));
        }
        field(30; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                "Quantity (Base)" := CalcBaseQty(Quantity);
            end;
        }
        field(40; "Quantity (Base)"; Decimal)
        {
            Caption = 'Quantity (Base)';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                GetKitchenRequest();
                KitchenRequest.TestField("Qty. per Unit of Measure", 1);
                Validate(Quantity, "Quantity (Base)");
            end;
        }
        field(50; Context; Option)
        {
            Caption = 'Context';
            DataClassification = CustomerContent;
            OptionCaption = 'Ordering,Line Splitting';
            OptionMembers = Ordering,"Line Splitting";
        }
        field(55; "Restaurant Code"; Code[20])
        {
            Caption = 'Restaurant Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Restaurant";
        }
        field(60; "Serving Step"; Code[10])
        {
            Caption = 'Serving Step';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Flow Status".Code WHERE("Status Object" = CONST(WaiterPadLineMealFlow));
        }
        field(70; "Created Date-Time"; DateTime)
        {
            Caption = 'Created Date-Time';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Request No.")
        {
            SumIndexFields = Quantity, "Quantity (Base)";
        }
        key(Key3; "Source Document Type", "Source Document Subtype", "Source Document No.", "Source Document Line No.", "Serving Step", "Request No.")
        {
        }
    }

    var
        UnsupportedSourceRec: Label 'Unsupported source record %1. This is a critical programming error. Please contact system vendor.';
        KitchenRequest: Record "NPR NPRE Kitchen Request";

    procedure InitSource(SourceRecID: RecordID)
    var
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        RecRef: RecordRef;
    begin
        case SourceRecID.TableNo of
            DATABASE::"NPR NPRE Waiter Pad Line":
                begin
                    RecRef.Get(SourceRecID);
                    RecRef.SetTable(WaiterPadLine);
                    "Source Document Type" := "Source Document Type"::"Waiter Pad";
                    "Source Document Subtype" := 0;
                    "Source Document No." := WaiterPadLine."Waiter Pad No.";
                    "Source Document Line No." := WaiterPadLine."Line No.";
                end;

            else
                Error(UnsupportedSourceRec, SourceRecID.TableNo);
        end;
    end;

    local procedure CalcBaseQty(Qty: Decimal): Decimal
    begin
        GetKitchenRequest();
        KitchenRequest.TestField("Qty. per Unit of Measure");
        exit(Round(Qty * KitchenRequest."Qty. per Unit of Measure", 0.00001));
    end;

    local procedure GetKitchenRequest()
    begin
        if "Request No." = KitchenRequest."Request No." then
            exit;
        TestField("Request No.");
        KitchenRequest.Get("Request No.");
    end;
}
