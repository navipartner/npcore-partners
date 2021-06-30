codeunit 6151153 "NPR M2 Service Lib."
{
    procedure GetEstimatedDeliveryDate(ItemNo: Code[20]; CustomerNo: Code[20]; ReferenceDate: Date; var EstimatedDateFromVendor: Text[20]; var VendorCode: Text[20]; var EstimatedDateFromLocation: Text[20]; var LocationCode: Text[20]): Boolean
    var
        Item: Record Item;
        Customer: Record Customer;
        Location: Record Location;
        ParamRecArray: Array[2] of Record "Customized Calendar Change" temporary;
        CalendarManagement: Codeunit "Calendar Management";
        DateFromVendor: Date;
        DateFromLocation: Date;
    begin

        if (not Item.Get(ItemNo)) then
            exit(false);

        if (not Customer.Get(CustomerNo)) then
            exit(false);

        if (not Location.Get(Customer."Location Code")) then
            exit(false);

        VendorCode := Item."Vendor No.";
        LocationCode := Customer."Location Code";

        DateFromVendor := ReferenceDate;

        DateFromVendor := CalcDate(Item."Lead Time Calculation", DateFromVendor);
        DateFromVendor := GetNextWorkDay(DateFromVendor, ParamRecArray[1]."Source Type"::Customer, Customer."No.");

        ParamRecArray[1]."Source Type" := ParamRecArray[1]."Source Type"::Company;

        ParamRecArray[2]."Source Type" := ParamRecArray[1]."Source Type"::Location;
        ParamRecArray[2]."Source Code" := Customer."Location Code";

        DateFromVendor := CalendarManagement.CalcDateBOC(Format(Location."Inbound Whse. Handling Time", 0, 9), DateFromVendor, ParamRecArray, false);
        DateFromVendor := CalendarManagement.CalcDateBOC(Format(Location."Outbound Whse. Handling Time", 0, 9), DateFromVendor, ParamRecArray, false);

        DateFromVendor := CalcDate(Customer."Shipping Time", DateFromVendor);
        DateFromVendor := GetNextWorkDay(DateFromVendor, ParamRecArray[1]."Source Type"::Customer, Customer."No.");
        EstimatedDateFromVendor := Format(DateFromVendor, 0, 9);


        DateFromLocation := ReferenceDate;
        DateFromLocation := CalendarManagement.CalcDateBOC(Format(Location."Outbound Whse. Handling Time", 0, 9), DateFromLocation, ParamRecArray, true);

        DateFromLocation := CalcDate(Customer."Shipping Time", DateFromLocation);
        DateFromLocation := GetNextWorkDay(DateFromLocation, ParamRecArray[1]."Source Type"::Customer, Customer."No.");
        EstimatedDateFromLocation := Format(DateFromLocation, 0, 9);

        exit(true);
    end;

    local procedure GetNextWorkDay(ReferenceDate: Date; SourceType: Enum "Calendar Source Type"; SourceNo: Code[20]): Date
    var
        CalendarManagement: Codeunit "Calendar Management";
        NonWorkingDescription: Text;
        CalendarCode: Code[10];
        SearchLength: Integer;
        TempCustomizedCalendarChange: Record "Customized Calendar Change" temporary;
    begin

        CalendarCode := GetCalendarCode(SourceType, SourceNo, '');
        if (CalendarCode = '') then
            CalendarCode := GetCalendarCode(SourceType::Company, '', '');

        if (CalendarCode = '') then
            exit(ReferenceDate);

        repeat
            TempCustomizedCalendarChange."Source Type" := SourceType;
            TempCustomizedCalendarChange."Source Code" := SourceNo;
            TempCustomizedCalendarChange."Base Calendar Code" := CalendarCode;
            TempCustomizedCalendarChange."Date" := ReferenceDate;
            TempCustomizedCalendarChange.Description := NonWorkingDescription;
            TempCustomizedCalendarChange.Insert();

            CalendarManagement.CheckDateStatus(TempCustomizedCalendarChange);
            if (TempCustomizedCalendarChange.Nonworking) then
                ReferenceDate += 1;
            SearchLength += 1;
        until (not TempCustomizedCalendarChange.Nonworking) or (SearchLength > 100);

        exit(ReferenceDate);
    end;

    local procedure GetCalendarCode(SourceType: Enum "Calendar Source Type"; SourceCode: Code[20]; AdditionalSourceCode: Code[20]): Code[10]
    var
        Customer: Record Customer;
        Vendor: Record Vendor;
        Location: Record Location;
        CompanyInfo: Record "Company Information";
        Shippingagent: Record "Shipping Agent Services";
        ServMgtSetup: Record "Service Mgt. Setup";
    begin

        case SourceType of
            SourceType::Company:
                if CompanyInfo.Get() then
                    exit(CompanyInfo."Base Calendar Code");

            SourceType::Customer:
                if Customer.Get(SourceCode) then
                    exit(Customer."Base Calendar Code");

            SourceType::Vendor:
                if Vendor.Get(SourceCode) then
                    exit(Vendor."Base Calendar Code");

            SourceType::"Shipping Agent":
                begin
                    if Shippingagent.Get(SourceCode, AdditionalSourceCode) then
                        exit(Shippingagent."Base Calendar Code");

                    if CompanyInfo.Get() then
                        exit(CompanyInfo."Base Calendar Code");
                end;

            SourceType::Location:
                begin
                    if Location.Get(SourceCode) then
                        if Location."Base Calendar Code" <> '' then
                            exit(Location."Base Calendar Code");
                    if CompanyInfo.Get() then
                        exit(CompanyInfo."Base Calendar Code");
                end;

            SourceType::Service:
                if ServMgtSetup.Get() then
                    exit(ServMgtSetup."Base Calendar Code");
        end;
    end;
}