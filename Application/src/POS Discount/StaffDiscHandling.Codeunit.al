codeunit 6014475 "NPR Staff Disc. Handling"
{
    TableNo = Item;

    trigger OnRun()
    var
        StaffSetup: Record "NPR Staff Setup";
        "Sales Price": Record "Sales Price";
        Found: Boolean;
    begin
        StaffSetup.Get;
        "Sales Price".SetRange("Item No.", "No.");
        "Sales Price".SetRange("Sales Type", "Sales Price"."Sales Type"::"Customer Price Group");
        "Sales Price".SetRange("Sales Code", StaffSetup."Staff Price Group");
        Found := "Sales Price".Find('-');

        case StaffSetup."Internal Unit Price" of
            StaffSetup."Internal Unit Price"::"Unit Cost":
                "Sales Price".Validate("Unit Price", "Unit Cost");
            StaffSetup."Internal Unit Price"::"Last Direct":
                "Sales Price".Validate("Unit Price", "Last Direct Cost");
        end;

        "Sales Price".Validate("Price Includes VAT", "Price Includes VAT");

        if Found then
            "Sales Price".Modify(true)
        else begin
            "Sales Price".Validate("Item No.", "No.");
            "Sales Price".Validate("Sales Type", "Sales Price"."Sales Type"::"Customer Price Group");
            "Sales Price".Validate("Sales Code", StaffSetup."Staff Price Group");
            "Sales Price".Insert(true);
        end;
    end;
}

