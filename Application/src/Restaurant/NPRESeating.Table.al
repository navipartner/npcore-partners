table 6150665 "NPR NPRE Seating"
{
    Access = Internal;
    Caption = 'Seating';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR NPRE Seating List";
    LookupPageID = "NPR NPRE Seating List";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                UpdateSeatingNo();
            end;
        }
        field(3; "Seating Location"; Code[10])
        {
            Caption = 'Seating Location';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Seating Location".Code;
        }
        field(5; "Seating No."; Text[20])
        {
            Caption = 'Seating No.';
            DataClassification = CustomerContent;
        }
        field(10; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(20; "Fixed Capasity"; Boolean)
        {
            Caption = 'Fixed Capasity';
            DataClassification = CustomerContent;
        }
        field(21; Capacity; Integer)
        {
            Caption = 'Capacity';
            DataClassification = CustomerContent;
            MinValue = 0;

            trigger OnValidate()
            begin
                if Capacity <> 0 then begin
                    if Capacity > "Max Party Size" then
                        "Max Party Size" := Capacity;
                    if Capacity < "Min Party Size" then
                        "Min Party Size" := Capacity;
                end;
            end;
        }
        field(22; "Min Party Size"; Integer)
        {
            Caption = 'Min Party Size';
            DataClassification = CustomerContent;
            MinValue = 0;

            trigger OnValidate()
            var
                CannotBeBiggerThanErr: Label 'cannot be bigger than %1', Comment = '%1 - field name the value is compared to';
            begin
                if "Min Party Size" > Capacity then
                    FieldError("Min Party Size", StrSubStNo(CannotBeBiggerThanErr, FieldCaption(Capacity)));
                if "Min Party Size" > "Max Party Size" then
                    FieldError("Min Party Size", StrSubStNo(CannotBeBiggerThanErr, FieldCaption("Max Party Size")));
            end;
        }
        field(23; "Max Party Size"; Integer)
        {
            Caption = 'Max Party Size';
            DataClassification = CustomerContent;
            MinValue = 0;

            trigger OnValidate()
            var
                CannotBeLessThanErr: Label 'cannot be less than %1', Comment = '%1 - field name the value is compared to';
            begin
                if "Max Party Size" < Capacity then
                    FieldError("Max Party Size", StrSubStNo(CannotBeLessThanErr, FieldCaption(Capacity)));
                if "Max Party Size" < "Min Party Size" then
                    FieldError("Max Party Size", StrSubStNo(CannotBeLessThanErr, FieldCaption("Min Party Size")));
            end;
        }
        field(30; Status; Code[10])
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Flow Status".Code WHERE("Status Object" = CONST(Seating));

            trigger OnValidate()
            var
                SeatingMgt: Codeunit "NPR NPRE Seating Mgt.";
                NewStatusCode: Code[10];
            begin
                NewStatusCode := Status;
                Status := xRec.Status;
                SeatingMgt.SetSeatingStatus(Rec, xRec, NewStatusCode);
            end;
        }
        field(31; "Status Description FF"; Text[50])
        {
            CalcFormula = Lookup("NPR NPRE Flow Status".Description WHERE(Code = FIELD(Status)));
            Caption = 'Status Description';
            FieldClass = FlowField;
        }
        field(40; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, "Global Dimension 1 Code");
            end;
        }
        field(41; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2, "Global Dimension 2 Code");
            end;
        }
        field(50; Blocked; Boolean)
        {
            Caption = 'Blocked';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                SeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
                SeatingMgt: Codeunit "NPR NPRE Seating Mgt.";
                NewBlocked: Boolean;
            begin
                NewBlocked := Blocked;
                if Blocked then
                    SeatingMgt.SetSeatingIsBlocked(Rec, xRec)
                else begin
                    SeatingWaiterPadLink.SetRange("Seating Code", Code);
                    SeatingWaiterPadLink.SetRange(Closed, false);
                    if SeatingWaiterPadLink.IsEmpty() then
                        SeatingMgt.SetSeatingIsOccupied(Rec, xRec)
                    else
                        SeatingMgt.SetSeatingIsReady(Rec, xRec);
                end;
                Blocked := NewBlocked;
            end;
        }
        field(51; "Blocking Reason"; Text[100])
        {
            Caption = 'Blocking Reason';
            DataClassification = CustomerContent;
        }
        field(100; "Current Waiter Pad FF"; Code[20])
        {
            CalcFormula = Lookup("NPR NPRE Seat.: WaiterPadLink"."Waiter Pad No." WHERE("Seating Code" = FIELD(Code), Closed = CONST(false)));
            Caption = 'Current Waiter Pad';
            FieldClass = FlowField;
        }
        field(101; "Multiple Waiter Pad FF"; Integer)
        {
            CalcFormula = Count("NPR NPRE Seat.: WaiterPadLink" WHERE("Seating Code" = FIELD(Code), Closed = CONST(false)));
            Caption = 'Multiple Waiter Pad';
            FieldClass = FlowField;
        }
        field(102; "Current Waiter Pad Description"; Text[80])
        {
            Caption = 'Waiter Pad Description';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Code")
        { }
        key(Key2; "Seating Location", "Seating No.")
        { }
    }

    fieldgroups
    {
        fieldgroup(DropDown; Code, "Seating No.", Description)
        {
        }
    }

    trigger OnDelete()
    var
        LocationLayout: Record "NPR NPRE Location Layout";
    begin
        DimMgt.DeleteDefaultDim(DATABASE::"NPR NPRE Seating", Code);
        if LocationLayout.Get("Code") then
            LocationLayout.Delete();
    end;

    trigger OnInsert()
    begin
        UpdateCurrentWaiterPadDescription();
        UpdateSeatingNo();
        DimMgt.UpdateDefaultDim(
          DATABASE::"NPR NPRE Seating", Code,
          "Global Dimension 1 Code", "Global Dimension 2 Code");
    end;

    trigger OnModify()
    begin
        UpdateCurrentWaiterPadDescription();
    end;

    trigger OnRename()
    var
        LocationLayout: Record "NPR NPRE Location Layout";
    begin
        if LocationLayout.Get(xRec.Code) then
            LocationLayout.Rename(Rec.Code);
    end;

    var
        DimMgt: Codeunit DimensionManagement;

    procedure UpdateCurrentWaiterPadDescription()
    var
        SeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
    begin
        CalcFields("Current Waiter Pad FF");
        if "Current Waiter Pad FF" <> '' then begin
            if SeatingWaiterPadLink.Get(Code, "Current Waiter Pad FF") then begin
                SeatingWaiterPadLink.CalcFields("Waiter Pad Description FF");
                "Current Waiter Pad Description" := SeatingWaiterPadLink."Waiter Pad Description FF";
            end;
        end;
    end;

    local procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        DimMgt.ValidateDimValueCode(FieldNumber, ShortcutDimCode);
        DimMgt.SaveDefaultDim(DATABASE::"NPR NPRE Seating", Code, FieldNumber, ShortcutDimCode);
        Modify();
    end;

    procedure RGBColorCodeHex(IncludeHashMark: Boolean): Text
    var
        ColorTable: Record "NPR NPRE Color Table";
        FlowStatus: Record "NPR NPRE Flow Status";
        SeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        CurrentColorPriority: Integer;
        HasBeenAssigned: Boolean;
    begin
        HasBeenAssigned := false;
        if FlowStatus.get(Status, FlowStatus."Status Object"::Seating) then
            FlowStatus.GetColorTable(CurrentColorPriority, HasBeenAssigned, ColorTable);

        SeatingWaiterPadLink.SetCurrentKey(Closed);
        SeatingWaiterPadLink.SetRange("Seating Code", Code);
        SeatingWaiterPadLink.SetRange(Closed, false);
        if SeatingWaiterPadLink.FindSet() then
            repeat
                if WaiterPad.Get(SeatingWaiterPadLink."Waiter Pad No.") then begin
                    if FlowStatus.Get(WaiterPad."Serving Step Code", FlowStatus."Status Object"::WaiterPadLineMealFlow) then
                        FlowStatus.GetColorTable(CurrentColorPriority, HasBeenAssigned, ColorTable);
                    if FlowStatus.Get(WaiterPad.Status, FlowStatus."Status Object"::WaiterPad) then
                        FlowStatus.GetColorTable(CurrentColorPriority, HasBeenAssigned, ColorTable);
                end;
            until SeatingWaiterPadLink.Next() = 0;

        exit(ColorTable.RGBHexCode(IncludeHashMark));
    end;

    local procedure UpdateSeatingNo()
    begin
        if ("Seating No." = xRec."Code") or ("Seating No." = '') then
            "Seating No." := "Code";
    end;

    procedure GetSeatingRestaurant(): Code[20]
    var
        SeatingLocation: Record "NPR NPRE Seating Location";
    begin
        if not SeatingLocation.Get("Seating Location") then
            exit('');
        exit(SeatingLocation."Restaurant Code");
    end;
}
