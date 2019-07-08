codeunit 6150663 "NPRE Waiter Pad Management"
{
    // NPR5.34/ANEN  /2017012  CASE 270255 Object Created for Hospitality - Version 1.0
    // NPR5.35/ANEN /20170821 CASE 283376 Solution rename to NP Restaurant


    trigger OnRun()
    begin
    end;

    procedure LinkSeatingToWaiterPad(WaiterPadNo: Code[20];SeatingCode: Code[20]) LinkAdded: Boolean
    var
        WaiterPad: Record "NPRE Waiter Pad";
        SeatingWaiterPadLink: Record "NPRE Seating - Waiter Pad Link";
        Seating: Record "NPRE Seating";
    begin
        WaiterPad.Reset;
        WaiterPad.SetRange("No.", WaiterPadNo);
        WaiterPad.FindFirst;

        Seating.Reset;
        Seating.SetRange(Code, SeatingCode);
        Seating.FindFirst;

        SeatingWaiterPadLink.Reset;
        SeatingWaiterPadLink.SetRange("Seating Code", Seating.Code);
        SeatingWaiterPadLink.SetRange("Waiter Pad No.", WaiterPad."No.");
        if not SeatingWaiterPadLink.IsEmpty then begin
          exit(false);
        end else begin
          SeatingWaiterPadLink.Init;
          SeatingWaiterPadLink."Seating Code" := Seating.Code;
          SeatingWaiterPadLink."Waiter Pad No." := WaiterPad."No.";
          SeatingWaiterPadLink.Insert(true);
          exit(true);
        end;
    end;

    procedure RemoveSeatingWaiterPadLink(WaiterPadNo: Code[20];SeatingCode: Code[20]) LinkAdded: Boolean
    var
        SeatingWaiterPadLink: Record "NPRE Seating - Waiter Pad Link";
    begin
        SeatingWaiterPadLink.Reset;
        SeatingWaiterPadLink.SetRange("Seating Code", SeatingCode);
        SeatingWaiterPadLink.SetRange("Waiter Pad No.", WaiterPadNo);

        if SeatingWaiterPadLink.IsEmpty then begin
          exit(false);
        end else begin
          SeatingWaiterPadLink.FindFirst;
          SeatingWaiterPadLink.Delete(true);
          exit(true);
        end;
    end;

    procedure ChangeSeating(WaiterPadNo: Code[20];SeatingCode: Code[20];SeatingCodeNew: Code[20]) Changed: Boolean
    var
        SeatingWaiterPadLink: Record "NPRE Seating - Waiter Pad Link";
    begin
        SeatingWaiterPadLink.Reset;
        SeatingWaiterPadLink.SetRange("Seating Code", SeatingCode);
        SeatingWaiterPadLink.SetRange("Waiter Pad No.", WaiterPadNo);
        if SeatingWaiterPadLink.IsEmpty then begin
          exit(false);
        end else begin
          SeatingWaiterPadLink.FindFirst;
          SeatingWaiterPadLink.Rename(SeatingCodeNew, WaiterPadNo);
          exit(true);
        end;
    end;

    procedure ChangeWaiterPad(SeatingCode: Code[20];WaiterPadNo: Code[20];WaiterPadNoNew: Code[20]) Moved: Boolean
    var
        SeatingWaiterPadLink: Record "NPRE Seating - Waiter Pad Link";
    begin
        SeatingWaiterPadLink.Reset;
        SeatingWaiterPadLink.SetRange("Seating Code", SeatingCode);
        SeatingWaiterPadLink.SetRange("Waiter Pad No.", WaiterPadNo);
        if SeatingWaiterPadLink.IsEmpty then begin
          exit(false);
        end else begin
          SeatingWaiterPadLink.FindFirst;
          SeatingWaiterPadLink.Rename(SeatingCode, WaiterPadNoNew);
          exit(true);
        end;
    end;

    procedure InsertWaiterPad(var WaiterPad: Record "NPRE Waiter Pad";RunInsert: Boolean)
    var
        NoSeriesManagement: Codeunit NoSeriesManagement;
        HospitalitySetup: Record "NPRE Restaurant Setup";
        NewWaiterPadNo: Code[20];
    begin
        HospitalitySetup.Get;
        HospitalitySetup.TestField(HospitalitySetup."Waiter Pad No. Serie");

        NewWaiterPadNo := NoSeriesManagement.GetNextNo(HospitalitySetup."Waiter Pad No. Serie", Today, true);

        WaiterPad."No." := NewWaiterPadNo;
        WaiterPad."Start Date" := WorkDate;
        WaiterPad."Start Time" := Time;
        if RunInsert then WaiterPad.Insert(true);
    end;

    procedure MergeWaiterPad(var WaiterPad: Record "NPRE Waiter Pad";var MergeToWaiterPad: Record "NPRE Waiter Pad") OK: Boolean
    var
        WaiterPadLine: Record "NPRE Waiter Pad Line";
        MergeToWaiterPadLine: Record "NPRE Waiter Pad Line";
        NPHWaiterPadPOSManagement: Codeunit "NPRE Waiter Pad POS Management";
    begin

        WaiterPadLine.Reset;
        WaiterPadLine.SetFilter("Waiter Pad No.", '=%1', WaiterPad."No.");
        if WaiterPadLine.FindSet then begin
          repeat
            MergeToWaiterPadLine.Init;
            MergeToWaiterPadLine.Validate("Waiter Pad No.", MergeToWaiterPad."No.");
            MergeToWaiterPadLine.Insert(true);

            MergeToWaiterPadLine."Sent To. Kitchen Print" := WaiterPadLine."Sent To. Kitchen Print";
            MergeToWaiterPadLine."Print Category" := WaiterPadLine."Print Category";
            MergeToWaiterPadLine."Register No." := WaiterPadLine."Register No.";
            MergeToWaiterPadLine."Start Date" := WaiterPadLine."Start Date";
            MergeToWaiterPadLine."Start Time" := WaiterPadLine."Start Time";
            MergeToWaiterPadLine.Type := WaiterPadLine.Type;
            MergeToWaiterPadLine."No." := WaiterPadLine."No.";
            MergeToWaiterPadLine.Description := WaiterPadLine.Description;
            MergeToWaiterPadLine.Quantity := WaiterPadLine.Quantity;
            MergeToWaiterPadLine."Sale Type" := WaiterPadLine."Sale Type";
            MergeToWaiterPadLine."Description 2" := WaiterPadLine."Description 2";
            MergeToWaiterPadLine."Variant Code" := WaiterPadLine."Variant Code";
            MergeToWaiterPadLine."Order No. from Web" := WaiterPadLine."Order No. from Web";
            MergeToWaiterPadLine."Order Line No. from Web" := WaiterPadLine."Order Line No. from Web";
            MergeToWaiterPadLine."Unit Price" := WaiterPadLine."Unit Price";
            MergeToWaiterPadLine."Discount Type" := WaiterPadLine."Discount Type";
            MergeToWaiterPadLine."Discount Code" := WaiterPadLine."Discount Code";
            MergeToWaiterPadLine."Allow Invoice Discount" := WaiterPadLine."Allow Invoice Discount";
            MergeToWaiterPadLine."Allow Line Discount" := WaiterPadLine."Allow Line Discount";
            MergeToWaiterPadLine."Discount %" := WaiterPadLine."Discount %";
            MergeToWaiterPadLine."Discount Amount" := WaiterPadLine."Discount Amount";
            MergeToWaiterPadLine."Invoice Discount Amount" := WaiterPadLine."Invoice Discount Amount";
            MergeToWaiterPadLine."Currency Code" := WaiterPadLine."Currency Code";
            MergeToWaiterPadLine."Unit of Measure Code" := WaiterPadLine."Unit of Measure Code";

            MergeToWaiterPadLine.Modify(true);


            WaiterPadLine.Delete(true);
          until (0 =  WaiterPadLine.Next);
        end;

        NPHWaiterPadPOSManagement.CloseWaiterPad(WaiterPad);

        exit(true);
    end;
}

