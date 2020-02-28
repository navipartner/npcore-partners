table 6150664 "NPRE Flow Status"
{
    // NPR5.34/ANEN/20170717  CASE 262628 Added support for status
    // NPR5.34/NPKNAV/20170801 CASE 283328 Transport NPR5.34 - 1 August 2017
    // NPR5.35/ANEN/20170821 CASE 283376 Solution rename to NP Restaurant
    // NPR5.53/ALPO/20200102 CASE 360258 Possibility to send to kitchen only selected waiter pad lines or lines of specific print category

    Caption = 'Status';
    DrillDownPageID = "NPRE Flow Status";
    LookupPageID = "NPRE Flow Status";

    fields
    {
        field(1;"Code";Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2;"Status Object";Option)
        {
            Caption = 'Status Object';
            OptionCaption = 'Seating,Waiter Pad,Waiter Pad Line Meal Flow,Waiter Pad Line Status';
            OptionMembers = Seating,WaiterPad,WaiterPadLineMealFlow,WaiterPadLineStatus;
        }
        field(5;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(6;"Flow Order";Integer)
        {
            Caption = 'Flow Order';
        }
    }

    keys
    {
        key(Key1;"Code","Status Object")
        {
        }
        key(Key2;"Status Object","Flow Order")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown;"Code",Description,"Flow Order")
        {
        }
    }

    var
        InQuotes: Label '''%1''';

    procedure AssignedPrintCategoriesAsFilterString(): Text
    var
        FlowStatusPrCategory: Record "NPRE Flow Status Pr.Category";
        PrintCategory: Record "NPRE Print Category";
        PrintCategoryString: Text;
    begin
        //-NPR5.53 [360258]
        //Return not assigned group filter for empty Code
        PrintCategory.Reset;
        FlowStatusPrCategory.SetRange("Flow Status Object","Status Object");
        if Code <> '' then
          FlowStatusPrCategory.SetRange("Flow Status Code",Code)
        else
          FlowStatusPrCategory.SetFilter("Flow Status Code",'<>%1','');
        if FlowStatusPrCategory.FindSet then
          repeat
            PrintCategory.Code := FlowStatusPrCategory."Print Category Code";
            PrintCategory.Mark := true;
          until FlowStatusPrCategory.Next = 0;

        PrintCategoryString := '';
        if Code <> '' then
          PrintCategory.MarkedOnly(true);
        if PrintCategory.FindSet then
          repeat
            if (Code <> '') or not PrintCategory.Mark then begin
              if PrintCategoryString <> '' then
                PrintCategoryString := PrintCategoryString + '|';
              PrintCategoryString := PrintCategoryString + StrSubstNo(InQuotes,PrintCategory.Code);
            end;
          until PrintCategory.Next = 0;
        exit(PrintCategoryString);
        //+NPR5.53 [360258]
    end;
}

