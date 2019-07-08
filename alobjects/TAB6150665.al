table 6150665 "NPRE Seating"
{
    // NPR5.34/ANEN  /2017012  CASE 270255 Object Created for Hospitality - Version 1.0
    // NPR5.34/ANEN  /20170717  CASE 262628 Added support for status (fld "Status", "Status Description")
    // NPR5.35/ANEN /20170821 CASE 283376 Solution rename to NP Restaurant

    Caption = 'Seating';
    DrillDownPageID = "NPRE Seating List";
    LookupPageID = "NPRE Seating List";

    fields
    {
        field(1;"Code";Code[10])
        {
            Caption = 'Code';
        }
        field(3;"Seating Location";Code[10])
        {
            Caption = 'Seating Location';
            TableRelation = "NPRE Seating Location".Code;
        }
        field(10;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(20;"Fixed Capasity";Boolean)
        {
            Caption = 'Fixed Capasity';
        }
        field(21;Capacity;Integer)
        {
            Caption = 'Capacity';
        }
        field(30;Status;Code[10])
        {
            Caption = 'Status';
            TableRelation = "NPRE Flow Status".Code WHERE ("Status Object"=CONST(Seating));
        }
        field(31;"Status Description FF";Text[50])
        {
            CalcFormula = Lookup("NPRE Flow Status".Description WHERE (Code=FIELD(Status)));
            Caption = 'Status Description';
            FieldClass = FlowField;
        }
        field(100;"Current Waiter Pad FF";Code[20])
        {
            CalcFormula = Lookup("NPRE Seating - Waiter Pad Link"."Waiter Pad No." WHERE ("Seating Code"=FIELD(Code)));
            Caption = 'Current Waiter Pad';
            FieldClass = FlowField;
        }
        field(101;"Multiple Waiter Pad FF";Integer)
        {
            CalcFormula = Count("NPRE Seating - Waiter Pad Link" WHERE ("Seating Code"=FIELD(Code)));
            Caption = 'Multiple Waiter Pad';
            FieldClass = FlowField;
        }
        field(102;"Current Waiter Pad Description";Text[50])
        {
            Caption = 'Waiter Pad Description';
        }
    }

    keys
    {
        key(Key1;"Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        UpdateCurrentWaiterPadDescription;
    end;

    trigger OnModify()
    begin
        UpdateCurrentWaiterPadDescription;
    end;

    procedure UpdateCurrentWaiterPadDescription()
    var
        NPHSeatingWaiterPadLink: Record "NPRE Seating - Waiter Pad Link";
    begin
        CalcFields("Current Waiter Pad FF");
        if "Current Waiter Pad FF" <> '' then begin
          if NPHSeatingWaiterPadLink.Get(Code, "Current Waiter Pad FF") then begin
            NPHSeatingWaiterPadLink.CalcFields("Waiter Pad Description FF");
            "Current Waiter Pad Description" := NPHSeatingWaiterPadLink."Waiter Pad Description FF";
          end;
        end;
    end;
}

