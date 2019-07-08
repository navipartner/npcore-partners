table 6150660 "NPRE Waiter Pad"
{
    // NPR5.34/ANEN  /2017012  CASE 270255 Object Created for Hospitality - Version 1.0
    // NPR5.34/ANEN  /20170717  CASE 262628 Added support for status (fld "Status", "Status Description")
    // NPR5.34/MMV /20170726 CASE 285002 Added field 100.
    // NPR5.35/ANEN /20170821 CASE 283376 Solution rename to NP Restaurant

    Caption = 'Waiter Pad';
    DrillDownPageID = "NPRE Waiter Pad List";
    LookupPageID = "NPRE Waiter Pad List";

    fields
    {
        field(1;"No.";Code[20])
        {
            Caption = 'No.';
        }
        field(5;Description;Text[80])
        {
            Caption = 'Description';
        }
        field(14;"Start Date";Date)
        {
            Caption = 'Start Date';
        }
        field(15;"Start Time";Time)
        {
            Caption = 'Start Time';
        }
        field(16;"Current Seating FF";Code[10])
        {
            CalcFormula = Lookup("NPRE Seating - Waiter Pad Link"."Seating Code" WHERE ("Waiter Pad No."=FIELD("No.")));
            Caption = 'Current Seating';
            FieldClass = FlowField;
        }
        field(17;"Multiple Seating FF";Integer)
        {
            CalcFormula = Count("NPRE Seating - Waiter Pad Link" WHERE ("Waiter Pad No."=FIELD("No.")));
            Caption = 'Multiple Seating';
            FieldClass = FlowField;
        }
        field(18;"Close Date";Date)
        {
            Caption = 'Close Date';
        }
        field(19;"Close Time";Time)
        {
            Caption = 'Close Time';
        }
        field(20;Closed;Boolean)
        {
            Caption = 'Closed';
        }
        field(21;"Current Seating Description";Text[50])
        {
            Caption = 'Seating Description';
        }
        field(30;Status;Code[10])
        {
            Caption = 'Status';
            TableRelation = "NPRE Flow Status".Code WHERE ("Status Object"=CONST(WaiterPad));
        }
        field(31;"Status Description FF";Text[50])
        {
            CalcFormula = Lookup("NPRE Flow Status".Description WHERE (Code=FIELD(Status)));
            Caption = 'Status Description';
            FieldClass = FlowField;
        }
        field(60;"Sum Unit Price";Decimal)
        {
            AutoFormatType = 2;
            CalcFormula = Sum("NPRE Waiter Pad Line"."Unit Price" WHERE ("Waiter Pad No."=FIELD("No.")));
            Caption = 'Sum Unit Price';
            DecimalPlaces = 2:2;
            Editable = true;
            FieldClass = FlowField;
            MaxValue = 9999999;
        }
        field(100;"Print Category Filter";Code[10])
        {
            Caption = 'Print Category Filter';
            FieldClass = FlowFilter;
        }
    }

    keys
    {
        key(Key1;"No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        OnDeleteWaiterPad(Rec);
    end;

    trigger OnInsert()
    var
        WaiterPadManagement: Codeunit "NPRE Waiter Pad Management";
    begin
        UpdateCurrentSeatingDescription;
    end;

    trigger OnModify()
    begin
        UpdateCurrentSeatingDescription;
    end;

    procedure UpdateCurrentSeatingDescription()
    var
        NPHSeatingWaiterPadLink: Record "NPRE Seating - Waiter Pad Link";
    begin
        CalcFields("Current Seating FF");
        if "Current Seating FF" <> '' then begin
          if NPHSeatingWaiterPadLink.Get("Current Seating FF", "No.") then begin
            NPHSeatingWaiterPadLink.CalcFields("Seating Description FF");
            "Current Seating Description" := NPHSeatingWaiterPadLink."Seating Description FF";
          end;
        end;
    end;

    local procedure OnDeleteWaiterPad(var NPHWaiterPad: Record "NPRE Waiter Pad")
    var
        NPHWaiterPadLine: Record "NPRE Waiter Pad Line";
        NPHSeatingWaiterPadLink: Record "NPRE Seating - Waiter Pad Link";
    begin
        if not (NPHWaiterPad."No." <> '') then exit;

        NPHWaiterPadLine.Reset;
        NPHWaiterPadLine.SetFilter("Waiter Pad No.", '=%1', NPHWaiterPad."No.");
        if not NPHWaiterPadLine.IsEmpty then NPHWaiterPadLine.DeleteAll;

        NPHSeatingWaiterPadLink.Reset;
        NPHSeatingWaiterPadLink.SetFilter("Waiter Pad No.", '=%1', NPHWaiterPad."No.");
        if not NPHSeatingWaiterPadLink.IsEmpty then NPHSeatingWaiterPadLink.DeleteAll;
    end;
}

