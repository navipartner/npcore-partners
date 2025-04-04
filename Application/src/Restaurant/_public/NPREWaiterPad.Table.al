﻿table 6150660 "NPR NPRE Waiter Pad"
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
        field(5; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(10; "Customer Type"; Option)
        {
            Caption = 'Customer Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Ordinary,Cash';
            OptionMembers = Ord,Cash;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Not used';
        }
        field(11; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer."No.";
        }
        field(14; "Start Date"; Date)
        {
            Caption = 'Start Date';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-08-28';
            ObsoleteReason = 'Replaced by SystemCreatedAt field.';
        }
        field(15; "Start Time"; Time)
        {
            Caption = 'Start Time';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-08-28';
            ObsoleteReason = 'Replaced by SystemCreatedAt field.';
        }
        field(16; "Current Seating FF"; Code[20])
        {
            CalcFormula = Lookup("NPR NPRE Seat.: WaiterPadLink"."Seating Code" WHERE("Waiter Pad No." = FIELD("No."), Primary = Const(true)));
            Caption = 'Current Seating Code';
            Editable = false;
            FieldClass = FlowField;
        }
        field(17; "Multiple Seating FF"; Integer)
        {
            CalcFormula = Count("NPR NPRE Seat.: WaiterPadLink" WHERE("Waiter Pad No." = FIELD("No."), Closed = FIELD(Closed)));
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
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Replaced by procedure GetCurrentSeating(), as the field could contain an outdated value';
        }
        field(22; "Close Reason"; Enum "NPR NPRE W/Pad Closing Reason")
        {
            Caption = 'Close Reason';
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
            CalcFormula = Lookup("NPR NPRE Flow Status".Description WHERE(Code = FIELD(Status), "Status Object" = CONST(WaiterPad)));
            Caption = 'Status Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(40; "Number of Guests"; Integer)
        {
            Caption = 'Number of Guests';
            DataClassification = CustomerContent;
        }
        field(41; "Billed Number of Guests"; Integer)
        {
            Caption = 'Billed Number of Guests';
            DataClassification = CustomerContent;
        }
        field(42; "No. of Guests on POS Sales"; Integer)
        {
            CalcFormula = Sum("NPR POS Sale"."NPRE Number of Guests" WHERE("NPRE Pre-Set Waiter Pad No." = FIELD("No.")));
            Caption = 'No. of Guests on POS Sales';
            Editable = false;
            FieldClass = FlowField;
        }
        field(50; "Serving Step Code"; Code[10])
        {
            Caption = 'Serving Step Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Flow Status".Code WHERE("Status Object" = CONST(WaiterPadLineMealFlow), Auxiliary = Const(false));

            trigger OnValidate()
            var
                ServingStep: Record "NPR NPRE Flow Status";
                WPStatus: Record "NPR NPRE Flow Status";
                WPStatusNew: Record "NPR NPRE Flow Status";
                WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
                UpdateStatus: Boolean;
            begin
                if ServingStep.Get("Serving Step Code", ServingStep."Status Object"::WaiterPadLineMealFlow) then
                    if ServingStep."Waiter Pad Status Code" <> '' then begin
                        UpdateStatus := Status = '';
                        if not UpdateStatus then begin
                            WPStatus.Get(Status, WPStatus."Status Object"::WaiterPad);
                            WPStatusNew.Get(ServingStep."Waiter Pad Status Code", WPStatusNew."Status Object"::WaiterPad);
                            UpdateStatus := WPStatusNew."Flow Order" >= WPStatus."Flow Order";
                        end;
                        if UpdateStatus then
                            WaiterPadMgt.SetWaiterPadStatus(Rec, ServingStep."Waiter Pad Status Code");
                    end;
            end;
        }
        field(51; "Serving Step Description"; Text[50])
        {
            CalcFormula = Lookup("NPR NPRE Flow Status".Description WHERE(Code = FIELD("Serving Step Code"), "Status Object" = CONST(WaiterPadLineMealFlow)));
            Caption = 'Serving Step Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(52; "Last Req. Serving Step Code"; Code[10])
        {
            Caption = 'Last Req. Serving Step Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Flow Status".Code WHERE("Status Object" = CONST(WaiterPadLineMealFlow));
        }
        field(53; "Last Req. Serving Step Descr."; Text[50])
        {
            CalcFormula = Lookup("NPR NPRE Flow Status".Description WHERE(Code = FIELD("Last Req. Serving Step Code"), "Status Object" = CONST(WaiterPadLineMealFlow)));
            Caption = 'Last Req. Serving Step Descr.';
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
        }
        field(80; "Assigned Waiter Code"; Code[20])
        {
            Caption = 'Assigned Waiter Code';
            DataClassification = CustomerContent;
            TableRelation = "Salesperson/Purchaser";

            trigger OnValidate()
            var
                KitchenOrderMgt: Codeunit "NPR NPRE Kitchen Order Mgt.";
            begin
                KitchenOrderMgt.UpdateKitchenReqSourceWaiter(Enum::"NPR NPRE K.Req.Source Doc.Type"::"Waiter Pad", 0, "No.", 0, "Assigned Waiter Code");
            end;
        }
        field(100; "Print Category Filter"; Code[20])
        {
            Caption = 'Print Category Filter';
            FieldClass = FlowFilter;
            TableRelation = "NPR NPRE Print/Prod. Cat.";
        }
        field(220; "Customer Phone No."; Text[30])
        {
            Caption = 'Customer Phone No.';
            DataClassification = CustomerContent;
            ExtendedDatatype = PhoneNo;
        }
        field(221; "Customer E-Mail"; Text[80])
        {
            Caption = 'Customer Email';
            DataClassification = CustomerContent;
            ExtendedDatatype = EMail;

            trigger OnValidate()
            var
                MailManagement: Codeunit "Mail Management";
            begin
                if "Customer E-Mail" <> '' then
                    MailManagement.CheckValidEmailAddresses("Customer E-Mail");
            end;
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

    internal procedure GetCurrentSeating(var Seating: Record "NPR NPRE Seating")
    begin
        Rec.CalcFields("Current Seating FF");
        if not Seating.Get(Rec."Current Seating FF") then
            Clear(Seating);
    end;

    local procedure OnDeleteWaiterPad(var WaiterPad: Record "NPR NPRE Waiter Pad")
    var
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        SeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
        POSInfoWaiterPadLink: Record "NPR POS Info NPRE Waiter Pad";
    begin
        if WaiterPad."No." = '' then
            exit;
        WaiterPad.TestField(Closed, true);

        WaiterPadLine.Reset();
        WaiterPadLine.SetRange("Waiter Pad No.", WaiterPad."No.");
        if not WaiterPadLine.IsEmpty then
            WaiterPadLine.DeleteAll(true);

        SeatingWaiterPadLink.Reset();
        SeatingWaiterPadLink.SetRange("Waiter Pad No.", WaiterPad."No.");
        if not SeatingWaiterPadLink.IsEmpty then
            SeatingWaiterPadLink.DeleteAll();

        POSInfoWaiterPadLink.SetRange("Waiter Pad No.", WaiterPad."No.");
        if not POSInfoWaiterPadLink.IsEmpty then
            POSInfoWaiterPadLink.DeleteAll();
    end;

    internal procedure CloseWaiterPad()
    var
        WaiterPadManagement: Codeunit "NPR NPRE Waiter Pad Mgt.";
        ConfirmCloseQst: Label 'Once closed, you won''t be able to reopen the waiter pad again.\Please note that the system won''t notify kitchen about this action, nor cancel any outstanding kitchen requests sent earlier. They will remain active. If you want the system to automatically cancel all kitchen requests, created for this waiter pad, please open the waiter pad in a POS sale, and cancel the sale. In that case the waiter pad may be closed automatically by the system as well.\Are you sure you want to continue and close the waiter pad %1?';
    begin
        if not Confirm(ConfirmCloseQst, false, Rec."No.") then
            exit;
        WaiterPadManagement.TryCloseWaiterPad(Rec, true, "NPR NPRE W/Pad Closing Reason"::"Manually Closed");
    end;

    internal procedure RGBColorCodeHex(IncludeHashMark: Boolean): Text
    var
        ColorTable: Record "NPR NPRE Color Table";
        FlowStatus: Record "NPR NPRE Flow Status";
        CurrentColorPriority: Integer;
        HasBeenAssigned: Boolean;
    begin
        HasBeenAssigned := false;
        if FlowStatus.get("Serving Step Code", FlowStatus."Status Object"::WaiterPadLineMealFlow) then
            FlowStatus.GetColorTable(CurrentColorPriority, HasBeenAssigned, ColorTable);
        if FlowStatus.get(Status, FlowStatus."Status Object"::WaiterPad) then
            FlowStatus.GetColorTable(CurrentColorPriority, HasBeenAssigned, ColorTable);

        exit(ColorTable.RGBHexCode(IncludeHashMark));
    end;

    internal procedure WaiterPadFrontEndStatus() StatusCode: Code[10]
    var
        ServingStep: Record "NPR NPRE Flow Status";
        WaiterPadStatus: Record "NPR NPRE Flow Status";
    begin
        if ServingStep.get("Serving Step Code", ServingStep."Status Object"::WaiterPadLineMealFlow) then
            if ServingStep."Available in Front-End" then
                StatusCode := ServingStep.Code;

        if WaiterPadStatus.get(Status, WaiterPadStatus."Status Object"::WaiterPad) then
            if WaiterPadStatus."Available in Front-End" then
                if (WaiterPadStatus."Flow Order" > ServingStep."Flow Order") or (StatusCode = '') then
                    StatusCode := WaiterPadStatus.Code;

        exit(StatusCode);
    end;
}
