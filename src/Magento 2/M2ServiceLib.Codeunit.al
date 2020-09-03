codeunit 6151153 "NPR M2 Service Lib."
{
    // 
    // MAG2.25/TSA /20200214 CASE 349999 Initial Version


    trigger OnRun()
    begin
    end;

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

        // EstimatedDateFromVendor := Reference Date +
        //                <Item Card> Lead Time Calculation +
        //                <Location Code (from Customer Card)>
        //                                <Location> Inbound Whse. Handling Time -> Apply Location Base Calendar to get first working day +
        //                                <Location> Outbound Whse. Handling Time -> Apply Location Base Calendar to get first working day +
        //                <Customer Card (shipping tab)> Shipping Time -> Apply Customer Base Calendar (shipping tab) to get first working day

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


        // EstimatedDateFromLocation := Reference Date +
        //                <Location Code (from Customer Card)>
        //                                <Location> Outbound Whse. Handling Time -> Apply Location Base Calendar to get first working day +
        //                <Customer Card (shipping tab)> Shipping Time -> Apply Customer Base Calendar to get first working day

        DateFromLocation := ReferenceDate;
        DateFromLocation := CalendarManagement.CalcDateBOC(Format(Location."Outbound Whse. Handling Time", 0, 9), DateFromLocation, ParamRecArray, true);

        DateFromLocation := CalcDate(Customer."Shipping Time", DateFromLocation);
        DateFromLocation := GetNextWorkDay(DateFromLocation, ParamRecArray[1]."Source Type"::Customer, Customer."No.");
        EstimatedDateFromLocation := Format(DateFromLocation, 0, 9);

        exit(true);
    end;

    local procedure GetNextWorkDay(ReferenceDate: Date; SourceType: Option Company,Customer,Vendor,Location,"Shipping Agent",Service; SourceNo: Code[20]): Date
    var
        CalendarManagement: Codeunit "Calendar Management";
        NonWorkingDescription: Text;
        CalendarCode: Code[10];
        IsWorkingDay: Boolean;
        SearchLength: Integer;
        CustomizedCalendarChangeTemp: Record "Customized Calendar Change" temporary;
    begin

        CalendarCode := GetCalendarCode(SourceType, SourceNo, '');
        if (CalendarCode = '') then
            CalendarCode := GetCalendarCode(SourceType::Company, '', '');

        if (CalendarCode = '') then
            exit(ReferenceDate);

        repeat
            CustomizedCalendarChangeTemp."Source Type" := SourceType;
            CustomizedCalendarChangeTemp."Source Code" := SourceNo;
            CustomizedCalendarChangeTemp."Base Calendar Code" := CalendarCode;
            CustomizedCalendarChangeTemp."Date" := ReferenceDate;
            CustomizedCalendarChangeTemp.Description := NonWorkingDescription;
            CustomizedCalendarChangeTemp.Insert();

            CalendarManagement.CheckDateStatus(CustomizedCalendarChangeTemp);
            if (CustomizedCalendarChangeTemp.Nonworking) then
                ReferenceDate += 1;
            SearchLength += 1;
        until (not CustomizedCalendarChangeTemp.Nonworking) or (SearchLength > 100);

        exit(ReferenceDate);
    end;

    local procedure GetCalendarCode(SourceType: Option Company,Customer,Vendor,Location,"Shipping Agent",Service; SourceCode: Code[20]; AdditionalSourceCode: Code[20]): Code[10]
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
                if CompanyInfo.Get then
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

                    if CompanyInfo.Get then
                        exit(CompanyInfo."Base Calendar Code");
                end;

            SourceType::Location:
                begin
                    if Location.Get(SourceCode) then
                        if Location."Base Calendar Code" <> '' then
                            exit(Location."Base Calendar Code");
                    if CompanyInfo.Get then
                        exit(CompanyInfo."Base Calendar Code");
                end;

            SourceType::Service:
                if ServMgtSetup.Get then
                    exit(ServMgtSetup."Base Calendar Code");
        end;
    end;
}

