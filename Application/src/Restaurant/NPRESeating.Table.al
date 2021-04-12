table 6150665 "NPR NPRE Seating"
{
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
        }
        field(3; "Seating Location"; Code[10])
        {
            Caption = 'Seating Location';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Seating Location".Code;
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
        }
        field(30; Status; Code[10])
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Flow Status".Code WHERE("Status Object" = CONST(Seating));
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
            Description = 'NPR5.55';
        }
        field(51; "Blocking Reason"; Text[100])
        {
            Caption = 'Blocking Reason';
            DataClassification = CustomerContent;
            Description = 'NPR5.55';
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
        field(102; "Current Waiter Pad Description"; Text[50])
        {
            Caption = 'Waiter Pad Description';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Code")
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
        UpdateCurrentWaiterPadDescription;
        DimMgt.UpdateDefaultDim(
          DATABASE::"NPR NPRE Seating", Code,
          "Global Dimension 1 Code", "Global Dimension 2 Code");
    end;

    trigger OnModify()
    begin
        UpdateCurrentWaiterPadDescription;
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
}