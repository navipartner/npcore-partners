table 6150664 "NPR NPRE Flow Status"
{
    // NPR5.34/ANEN/20170717  CASE 262628 Added support for status
    // NPR5.34/NPKNAV/20170801 CASE 283328 Transport NPR5.34 - 1 August 2017
    // NPR5.35/ANEN/20170821 CASE 283376 Solution rename to NP Restaurant
    // NPR5.53/ALPO/20200102 CASE 360258 Possibility to send to kitchen only selected waiter pad lines or lines of specific print category
    // NPR5.54/ALPO/20200226 CASE 392956 Send to kitchen print waiter pad lines with no print category assigned
    // NPR5.55/ALPO/20200708 CASE 382428 Kitchen Display System (KDS) for NP Restaurant (further enhancements)

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
        WaiterPadMgt.ClearAssignedPrintCategories(RecordId);  //NPR5.55 [382428]
    end;

    trigger OnRename()
    begin
        WaiterPadMgt.MoveAssignedPrintCategories(xRec.RecordId, RecordId);  //NPR5.55 [382428]
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
        //-NPR5.53 [360258]
        //Return not assigned group filter for empty Code
        PrintCategory.Reset;
        //-NPR5.55 [382428]-revoked
        /*
        FlowStatusPrCategory.SETRANGE("Flow Status Object","Status Object");
        IF Code <> '' THEN
          FlowStatusPrCategory.SETRANGE("Flow Status Code",Code)
        ELSE
          FlowStatusPrCategory.SETFILTER("Flow Status Code",'<>%1','');
        IF FlowStatusPrCategory.FINDSET THEN
          REPEAT
            IF PrintCategory.GET(FlowStatusPrCategory."Print Category Code") THEN
              PrintCategory.MARK := TRUE;
          UNTIL FlowStatusPrCategory.NEXT = 0;
        */
        //+NPR5.55 [382428]-revoked
        //-NPR5.55 [382428]
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
        //+NPR5.55 [382428]

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

        //-NPR5.54 [392956]
        if (Code = '') and (PrintCategoryString <> '') and not PrintCategory.Get('') then
            PrintCategoryString := StrSubstNo('%1|%2', EmptyCodeINQuotes, PrintCategoryString);
        //+NPR5.54 [392956]
        exit(PrintCategoryString);
        //+NPR5.53 [360258]

    end;
}

