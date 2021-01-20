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

    trigger OnDelete()
    begin
        WaiterPadMgt.ClearAssignedPrintCategories(RecordId);
    end;

    trigger OnRename()
    begin
        WaiterPadMgt.MoveAssignedPrintCategories(xRec.RecordId, RecordId);
    end;

    var
        InQuotes: Label '''%1''';
        EmptyCodeINQuotes: Label '''''', Comment = '{Fixed}';
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";

    procedure AssignedPrintCategoriesAsFilterString(): Text
    var
        AssignedPrintCategory: Record "NPR NPRE Assign. Print Cat.";
        PrintCategory: Record "NPR NPRE Print/Prod. Cat.";
        PrintCategoryString: Text;
    begin
        //Return not assigned group filter for empty Code
        PrintCategory.Reset;
        AssignedPrintCategory.SetRange("Table No.", DATABASE::"NPR NPRE Flow Status");
        if Code <> '' then
            AssignedPrintCategory.SetRange("Record ID", RecordId)
        else
            AssignedPrintCategory.SetFilter("Record ID", '<>%1', RecordId);
        if AssignedPrintCategory.FindSet then
            repeat
                if PrintCategory.Get(AssignedPrintCategory."Print/Prod. Category Code") then
                    PrintCategory.Mark := true;
            until AssignedPrintCategory.Next = 0;

        PrintCategoryString := '';
        if Code <> '' then
            PrintCategory.MarkedOnly(true);
        if PrintCategory.FindSet then
            repeat
                if (Code <> '') or not PrintCategory.Mark then begin
                    if PrintCategoryString <> '' then
                        PrintCategoryString := PrintCategoryString + '|';
                    PrintCategoryString := PrintCategoryString + StrSubstNo(InQuotes, PrintCategory.Code);
                end;
            until PrintCategory.Next = 0;

        if (Code = '') and (PrintCategoryString <> '') and not PrintCategory.Get('') then
            PrintCategoryString := StrSubstNo('%1|%2', EmptyCodeINQuotes, PrintCategoryString);
        exit(PrintCategoryString);
    end;
}