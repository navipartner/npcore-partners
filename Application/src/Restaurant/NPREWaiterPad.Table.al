table 6150660 "NPR NPRE Waiter Pad"
{
    Caption = 'Waiter Pad';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR NPRE Waiter Pad List";
    LookupPageID = "NPR NPRE Waiter Pad List";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
        }
        field(5; Description; Text[80])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
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
        field(16; "Current Seating FF"; Code[10])
        {
            CalcFormula = Lookup("NPR NPRE Seat.: WaiterPadLink"."Seating Code" WHERE("Waiter Pad No." = FIELD("No.")));
            Caption = 'Current Seating';
            Editable = false;
            FieldClass = FlowField;
        }
        field(17; "Multiple Seating FF"; Integer)
        {
            CalcFormula = Count("NPR NPRE Seat.: WaiterPadLink" WHERE("Waiter Pad No." = FIELD("No."),
                                                                        Closed = FIELD(Closed)));
            Caption = 'Multiple Seating';
            Editable = false;
            FieldClass = FlowField;
        }
        field(18; "Close Date"; Date)
        {
            Caption = 'Close Date';
            DataClassification = CustomerContent;
        }
        field(19; "Close Time"; Time)
        {
            Caption = 'Close Time';
            DataClassification = CustomerContent;
        }
        field(20; Closed; Boolean)
        {
            Caption = 'Closed';
            DataClassification = CustomerContent;
        }
        field(21; "Current Seating Description"; Text[50])
        {
            Caption = 'Seating Description';
            DataClassification = CustomerContent;
        }
        field(30; Status; Code[10])
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Flow Status".Code WHERE("Status Object" = CONST(WaiterPad));
        }
        field(31; "Status Description FF"; Text[50])
        {
            CalcFormula = Lookup("NPR NPRE Flow Status".Description WHERE(Code = FIELD(Status)));
            Caption = 'Status Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(40; "Number of Guests"; Integer)
        {
            Caption = 'Number of Guests';
            DataClassification = CustomerContent;
            Description = 'NPR5.53';
        }
        field(41; "Billed Number of Guests"; Integer)
        {
            Caption = 'Billed Number of Guests';
            DataClassification = CustomerContent;
            Description = 'NPR5.53';
        }
        field(42; "No. of Guests on POS Sales"; Integer)
        {
            CalcFormula = Sum("NPR Sale POS"."NPRE Number of Guests" WHERE("NPRE Pre-Set Waiter Pad No." = FIELD("No.")));
            Caption = 'No. of Guests on POS Sales';
            Description = 'NPR5.55';
            Editable = false;
            FieldClass = FlowField;
        }
        field(50; "Serving Step Code"; Code[10])
        {
            Caption = 'Serving Step Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.53';
            TableRelation = "NPR NPRE Flow Status".Code WHERE("Status Object" = CONST(WaiterPadLineMealFlow));
        }
        field(51; "Serving Step Description"; Text[50])
        {
            CalcFormula = Lookup("NPR NPRE Flow Status".Description WHERE(Code = FIELD("Serving Step Code")));
            Caption = 'Serving Step Description';
            Description = 'NPR5.53';
            Editable = false;
            FieldClass = FlowField;
        }
        field(52; "Last Req. Serving Step Code"; Code[10])
        {
            Caption = 'Last Req. Serving Step Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.53';
            TableRelation = "NPR NPRE Flow Status".Code WHERE("Status Object" = CONST(WaiterPadLineMealFlow));
        }
        field(53; "Last Req. Serving Step Descr."; Text[50])
        {
            CalcFormula = Lookup("NPR NPRE Flow Status".Description WHERE(Code = FIELD("Last Req. Serving Step Code")));
            Caption = 'Last Req. Serving Step Descr.';
            Description = 'NPR5.53';
            Editable = false;
            FieldClass = FlowField;
        }
        field(60; "Sum Unit Price"; Decimal)
        {
            AutoFormatType = 2;
            CalcFormula = Sum("NPR NPRE Waiter Pad Line"."Unit Price" WHERE("Waiter Pad No." = FIELD("No.")));
            Caption = 'Sum Unit Price';
            DecimalPlaces = 2 : 2;
            Editable = true;
            FieldClass = FlowField;
            MaxValue = 9999999;
        }
        field(70; "Pre-receipt Printed"; Boolean)
        {
            Caption = 'Pre-receipt Printed';
            DataClassification = CustomerContent;
            Description = 'NPR5.55';
        }
        field(100; "Print Category Filter"; Code[20])
        {
            Caption = 'Print Category Filter';
            FieldClass = FlowFilter;
            TableRelation = "NPR NPRE Print/Prod. Cat.";
        }
    }

    keys
    {
        key(Key1; "No.")
        {
        }
    }

    trigger OnDelete()
    begin
        OnDeleteWaiterPad(Rec);
    end;

    trigger OnInsert()
    var
        WaiterPadManagement: Codeunit "NPR NPRE Waiter Pad Mgt.";
    begin
        UpdateCurrentSeatingDescription;
    end;

    trigger OnModify()
    begin
        UpdateCurrentSeatingDescription;
    end;

    procedure UpdateCurrentSeatingDescription()
    var
        NPHSeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
    begin
        CalcFields("Current Seating FF");
        if "Current Seating FF" <> '' then begin
            if NPHSeatingWaiterPadLink.Get("Current Seating FF", "No.") then begin
                NPHSeatingWaiterPadLink.CalcFields("Seating Description FF");
                "Current Seating Description" := NPHSeatingWaiterPadLink."Seating Description FF";
            end;
        end;
    end;

    local procedure OnDeleteWaiterPad(var NPHWaiterPad: Record "NPR NPRE Waiter Pad")
    var
        NPHWaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        NPHSeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
        POSInfoWaiterPadLink: Record "NPR POS Info NPRE Waiter Pad";
    begin
        if not (NPHWaiterPad."No." <> '') then exit;

        NPHWaiterPadLine.Reset;
        NPHWaiterPadLine.SetRange("Waiter Pad No.", NPHWaiterPad."No.");
        if not NPHWaiterPadLine.IsEmpty then
            NPHWaiterPadLine.DeleteAll(true);

        NPHSeatingWaiterPadLink.Reset;
        NPHSeatingWaiterPadLink.SetFilter("Waiter Pad No.", '=%1', NPHWaiterPad."No.");
        if not NPHSeatingWaiterPadLink.IsEmpty then NPHSeatingWaiterPadLink.DeleteAll;

        POSInfoWaiterPadLink.SetRange("Waiter Pad No.", NPHWaiterPad."No.");
        if not POSInfoWaiterPadLink.IsEmpty then
            POSInfoWaiterPadLink.DeleteAll;
    end;
}