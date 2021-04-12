table 6150664 "NPR NPRE Flow Status"
{
    Caption = 'Status';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR NPRE Select Flow Status";
    LookupPageID = "NPR NPRE Select Flow Status";

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(2; "Status Object"; Option)
        {
            Caption = 'Status Object';
            DataClassification = CustomerContent;
            OptionCaption = 'Seating,Waiter Pad,Waiter Pad Line Meal Flow,Waiter Pad Line Status';
            OptionMembers = Seating,WaiterPad,WaiterPadLineMealFlow,WaiterPadLineStatus;
            trigger OnValidate()
            begin
                IF "Status Object" <> "Status Object"::WaiterPadLineMealFlow THEN
                    "Waiter Pad Status Code" := '';
            end;
        }
        field(5; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(6; "Flow Order"; Integer)
        {
            Caption = 'Flow Order';
            DataClassification = CustomerContent;
        }
        field(10; "Waiter Pad Status Code"; Code[10])
        {
            Caption = 'Waiter Pad Status Code';
            DataClassification = CustomerContent;
            TableRelation = if ("Status Object" = CONST(WaiterPadLineMealFlow)) "NPR NPRE Flow Status".Code WHERE("Status Object" = CONST(WaiterPad));
            trigger OnValidate()
            begin
                if "Waiter Pad Status Code" <> '' then
                    TestField("Status Object", "Status Object"::WaiterPadLineMealFlow);
            end;
        }
        field(90; "Available in Front-End"; Boolean)
        {
            Caption = 'Available in Front-End';
            DataClassification = CustomerContent;
        }
        field(100; Color; Text[30])
        {
            Caption = 'Color';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Color Table".Description;
        }
        field(110; "Icon Class"; Text[30])
        {
            Caption = 'Icon Class';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Code", "Status Object")
        {
        }
        key(Key2; "Status Object", "Flow Order")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Code", Description, "Flow Order")
        {
        }
    }
    trigger OnInsert()
    begin
        CheckSameCodeDoesNotExist(Rec);
    end;

    trigger OnDelete()
    begin
        WaiterPadMgt.ClearAssignedPrintCategories(RecordId);
    end;

    trigger OnRename()
    begin
        CheckSameCodeDoesNotExist(Rec);
        WaiterPadMgt.MoveAssignedPrintCategories(xRec.RecordId, RecordId);
    end;

    var
        InQuotes: Label '''%1''', Locked = true;
        EmptyCodeINQuotes: Label '''''', Locked = true;
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";

    procedure AssignedPrintCategoriesAsFilterString(): Text
    var
        AssignedPrintCategory: Record "NPR NPRE Assign. Print Cat.";
        PrintCategory: Record "NPR NPRE Print/Prod. Cat.";
        PrintCategoryString: Text;
    begin
        //Return not assigned group filter for empty Code
        PrintCategory.Reset();
        AssignedPrintCategory.SetRange("Table No.", DATABASE::"NPR NPRE Flow Status");
        if Code <> '' then
            AssignedPrintCategory.SetRange("Record ID", RecordId)
        else
            AssignedPrintCategory.SetFilter("Record ID", '<>%1', RecordId);
        if AssignedPrintCategory.FindSet() then
            repeat
                if PrintCategory.Get(AssignedPrintCategory."Print/Prod. Category Code") then
                    PrintCategory.Mark := true;
            until AssignedPrintCategory.Next() = 0;

        PrintCategoryString := '';
        if Code <> '' then
            PrintCategory.MarkedOnly(true);
        if PrintCategory.FindSet() then
            repeat
                if (Code <> '') or not PrintCategory.Mark then begin
                    if PrintCategoryString <> '' then
                        PrintCategoryString := PrintCategoryString + '|';
                    PrintCategoryString := PrintCategoryString + StrSubstNo(InQuotes, PrintCategory.Code);
                end;
            until PrintCategory.Next() = 0;

        if (Code = '') and (PrintCategoryString <> '') and not PrintCategory.Get('') then
            PrintCategoryString := StrSubstNo('%1|%2', EmptyCodeINQuotes, PrintCategoryString);

        exit(PrintCategoryString);
    end;

    local procedure CheckSameCodeDoesNotExist(FlowStatus: Record "NPR NPRE Flow Status")
    var
        FlowStatus2: Record "NPR NPRE Flow Status";
        SameAlreadyExistsTxt: Label 'En entry of type %1 with the same code already exists. Entries of type %1 and %2 must have mutually unique codes.';
    begin
        if not (FlowStatus."Status Object" in [FlowStatus."Status Object"::WaiterPad, FlowStatus."Status Object"::WaiterPadLineMealFlow]) then
            exit;
        if FlowStatus."Status Object" = FlowStatus."Status Object"::WaiterPad then
            FlowStatus2."Status Object" := FlowStatus2."Status Object"::WaiterPadLineMealFlow
        else
            FlowStatus2."Status Object" := FlowStatus2."Status Object"::WaiterPad;
        FlowStatus2."Code" := FlowStatus."Code";
        if FlowStatus2.Find() then
            Error(SameAlreadyExistsTxt, FlowStatus2."Status Object", FlowStatus."Status Object");
    end;
}