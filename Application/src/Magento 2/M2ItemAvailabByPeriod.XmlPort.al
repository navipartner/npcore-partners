xmlport 6151147 "NPR M2 Item Availab. By Period"
{
    // NPR5.49/TSA /20190305 CASE 345373 Initial Version
    // NPR5.50/TSA /20190528 CASE 345373 Fixed Location Code Filter
    // MAG2.25/TSA /20200303 CASE 380946 Changed request params to lessen data set, increase performance
    // MAG2.26/TSA /20200428 CASE 401839 Added PlannedReleases and ProjectedInventory for working with reservations
    // MAG2.26/TSA /20200430 CASE 402599 Added EstimateDateFromVendor, FromVendorCode, EstimatedDateFromLocation, FromLocationCode to the list section as well

    Caption = 'Item Availability By Period';
    Encoding = UTF8;
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;

    schema
    {
        textelement(ItemAvailability)
        {
            MaxOccurs = Once;
            tableelement(tmpdaterequest; Date)
            {
                MaxOccurs = Once;
                XmlName = 'Request';
                UseTemporary = true;
                fieldelement(PeriodStart; TmpDateRequest."Period Start")
                {
                }
                fieldelement(PeriodEnd; TmpDateRequest."Period End")
                {
                }
                textelement(ViewBy)
                {
                    MaxOccurs = Once;

                    trigger OnAfterAssignVariable()
                    begin

                        InvalidViewByOption := false;
                        case UpperCase(ViewBy) of
                            'DATE':
                                TmpDateRequest."Period Type" := TmpDateRequest."Period Type"::Date;
                            'WEEK':
                                TmpDateRequest."Period Type" := TmpDateRequest."Period Type"::Week;
                            'MONTH':
                                TmpDateRequest."Period Type" := TmpDateRequest."Period Type"::Month;
                            'QUARTER':
                                TmpDateRequest."Period Type" := TmpDateRequest."Period Type"::Quarter;
                            'YEAR':
                                TmpDateRequest."Period Type" := TmpDateRequest."Period Type"::Year;
                            else
                                InvalidViewByOption := true;
                        end;
                    end;
                }
                textelement(ViewAs)
                {
                    MaxOccurs = Once;

                    trigger OnAfterAssignVariable()
                    begin

                        case UpperCase(ViewAs) of
                            'NETCHANGE':
                                ViewAsOption := ViewAsOption::NETCHANGE;
                            'BALANCEATDATE':
                                ViewAsOption := ViewAsOption::BALANCEATDATE;
                            else
                                ViewAsOption := ViewAsOption::UNDEFINED;
                        end;
                    end;
                }
                textelement(locationcodein)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    XmlName = 'LocationCode';
                }
                textelement(customernumberin)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    XmlName = 'CustomerNumber';
                }
                textelement(requestitems)
                {
                    MaxOccurs = Once;
                    XmlName = 'Items';
                    tableelement(tmpitemrequest; "Item Reference")
                    {
                        XmlName = 'Item';
                        UseTemporary = true;
                        fieldattribute(ItemNumber; TmpItemRequest."Item No.")
                        {
                        }
                        fieldattribute(VariantCode; TmpItemRequest."Variant Code")
                        {
                            Occurrence = Optional;
                        }
                    }
                }
            }
            textelement(Response)
            {
                MaxOccurs = Once;
                MinOccurs = Zero;
                textelement(Status)
                {
                    MaxOccurs = Once;
                    textelement(ResponseCode)
                    {
                        MaxOccurs = Once;
                    }
                    textelement(ResponseMessage)
                    {
                        MaxOccurs = Once;
                    }
                    textelement(ExecutionTime)
                    {
                        MaxOccurs = Once;
                    }
                }
                textelement(Availability)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    textelement(responseitems)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                        XmlName = 'Items';
                        tableelement(tmpitemresponse; "Item Reference")
                        {
                            MinOccurs = Zero;
                            XmlName = 'Item';
                            UseTemporary = true;
                            fieldattribute(ItemNumber; TmpItemResponse."Item No.")
                            {
                            }
                            fieldattribute(VariantCode; TmpItemResponse."Variant Code")
                            {
                            }
                            textelement(PeriodStart)
                            {
                                MaxOccurs = Once;
                                tableelement(itemavailabilitybyperiodstart; Date)
                                {
                                    LinkTable = TmpItemResponse;
                                    MinOccurs = Zero;
                                    XmlName = 'Period';
                                    fieldattribute(PeriodStart; ItemAvailabilityByPeriodStart."Period Start")
                                    {
                                    }
                                    fieldattribute(PeriodEnd; ItemAvailabilityByPeriodStart."Period End")
                                    {
                                    }
                                    fieldattribute(PeriodName; ItemAvailabilityByPeriodStart."Period Name")
                                    {
                                    }
                                    textattribute(txtgrossrequirmentstart)
                                    {
                                        XmlName = 'GrossRequirment';

                                        trigger OnBeforePassVariable()
                                        begin
                                            TxtGrossRequirmentStart := Format(GrossRequirement, 0, 9);
                                        end;
                                    }
                                    textattribute(txtscheduledinboundstart)
                                    {
                                        XmlName = 'ScheduledInbound';

                                        trigger OnBeforePassVariable()
                                        begin
                                            TxtScheduledInboundStart := Format(ScheduledRcpt, 0, 9);
                                        end;
                                    }
                                    textattribute(txtplannedreleasesstart)
                                    {
                                        XmlName = 'PlannedReleases';

                                        trigger OnBeforePassVariable()
                                        begin
                                            TxtPlannedReleasesStart := Format(PlannedOrderReleases, 0, 9); //-+MAG2.26 [401839]
                                        end;
                                    }
                                    textattribute(txtplannedreceiptsstart)
                                    {
                                        XmlName = 'PlannedReceipts';

                                        trigger OnBeforePassVariable()
                                        begin
                                            TxtPlannedReceiptsStart := Format(PlannedOrderRcpt, 0, 9); //-+MAG2.26 [401839]
                                        end;
                                    }
                                    textattribute(txtavailableinventorystart)
                                    {
                                        XmlName = 'AvailableInventory';

                                        trigger OnBeforePassVariable()
                                        begin
                                            TxtAvailableInventoryStart := Format(QtyAvailable, 0, 9);
                                        end;
                                    }
                                    textattribute(txtexpectedinventorystart)
                                    {
                                        XmlName = 'ExpectedInventory';

                                        trigger OnBeforePassVariable()
                                        begin
                                            TxtExpectedInventoryStart := Format(ExpectedInventory, 0, 9);
                                        end;
                                    }
                                    textattribute(txtprojectedinventorystart)
                                    {
                                        XmlName = 'ProjectedInventory';

                                        trigger OnBeforePassVariable()
                                        begin
                                            TxtProjectedInventoryStart := Format(ProjAvailableBalance, 0, 9); //-+MAG2.26 [401839]
                                        end;
                                    }
                                    textattribute(txtinventorystart)
                                    {
                                        XmlName = 'Inventory';

                                        trigger OnBeforePassVariable()
                                        begin
                                            TxtInventoryStart := Format(ItemByPeriod.Inventory, 0, 9);
                                        end;
                                    }
                                    textattribute(txtnetchangestart)
                                    {
                                        XmlName = 'NetChange';

                                        trigger OnBeforePassVariable()
                                        begin
                                            TxtNetChangeStart := Format(ItemByPeriod."Net Change", 0, 9);
                                        end;
                                    }
                                    textattribute(txtqtyonsalesorderstart)
                                    {
                                        XmlName = 'QtyOnSalesOrder';

                                        trigger OnBeforePassVariable()
                                        begin
                                            TxtQtyOnSalesOrderStart := Format(ItemByPeriod."Qty. on Sales Order");
                                        end;
                                    }
                                    textattribute(txtqtyonpurchaseorderstart)
                                    {
                                        XmlName = 'QtyOnPurchaseOrder';

                                        trigger OnBeforePassVariable()
                                        begin
                                            TxtQtyOnPurchaseOrderStart := Format(ItemByPeriod."Qty. on Purch. Order");
                                        end;
                                    }
                                    textattribute(estimatedatefromvendorstart)
                                    {
                                        XmlName = 'EstimatedDateFromVendor';
                                    }
                                    textattribute(fromvendorcodestart)
                                    {
                                        XmlName = 'FromVendorCode';
                                    }
                                    textattribute(estimateddatefromlocationstart)
                                    {
                                        XmlName = 'EstimatedDateFromLocation';
                                    }
                                    textattribute(fromlocationcodestart)
                                    {
                                        XmlName = 'FromLocationCode';
                                    }

                                    trigger OnAfterGetRecord()
                                    var
                                        Customer: Record Customer;
                                        Item: Record Item;
                                    begin

                                        ItemByPeriod.SetFilter("No.", '=%1', TmpItemResponse."Item No.");
                                        ItemByPeriod.SetFilter("Variant Filter", '=%1', TmpItemResponse."Variant Code");
                                        if (LocationCodeIn <> '') then
                                            ItemByPeriod.SetFilter("Location Filter", '=%1', LocationCodeIn);

                                        ItemByPeriod.FindFirst();

                                        case ViewAsOption of
                                            ViewAsOption::BALANCEATDATE:
                                                ItemByPeriod.SetFilter("Date Filter", '%1..%2', 0D, ItemAvailabilityByPeriodStart."Period Start");
                                            ViewAsOption::NETCHANGE:
                                                ItemByPeriod.SetFilter("Date Filter", '%1..%2', ItemAvailabilityByPeriodStart."Period Start", ItemAvailabilityByPeriodStart."Period Start");
                                        end;


                                        ItemAvailFormsMgt.CalcAvailQuantities(
                                          ItemByPeriod,
                                          ViewAsOption = ViewAsOption::BALANCEATDATE,
                                          GrossRequirement,
                                          PlannedOrderRcpt,
                                          ScheduledRcpt,
                                          PlannedOrderReleases,
                                          ProjAvailableBalance,
                                          ExpectedInventory,
                                          QtyAvailable);


                                        //-MAG2.25 [380946]
                                        M2ServiceLibrary.GetEstimatedDeliveryDate(
                                          TmpItemResponse."Item No.",
                                          CustomerNumberIn,
                                          ItemAvailabilityByPeriodStart."Period Start",
                                          EstimateDateFromVendorStart,
                                          FromVendorCodeStart,
                                          EstimatedDateFromLocationStart,
                                          FromLocationCodeStart);
                                        //+MAG2.25 [380946]
                                    end;
                                }
                            }
                            textelement(Periods)
                            {
                                MaxOccurs = Once;
                                tableelement(itemavailabilitybyperiod; Date)
                                {
                                    LinkTable = TmpItemResponse;
                                    MinOccurs = Zero;
                                    XmlName = 'Period';
                                    fieldattribute(PeriodStart; ItemAvailabilityByPeriod."Period Start")
                                    {
                                    }
                                    fieldattribute(PeriodEnd; ItemAvailabilityByPeriod."Period End")
                                    {
                                    }
                                    fieldattribute(PeriodName; ItemAvailabilityByPeriod."Period Name")
                                    {
                                    }
                                    textattribute(txtgrossrequirment)
                                    {
                                        XmlName = 'GrossRequirment';

                                        trigger OnBeforePassVariable()
                                        begin
                                            TxtGrossRequirment := Format(GrossRequirement, 0, 9);
                                        end;
                                    }
                                    textattribute(txtscheduledinbound)
                                    {
                                        XmlName = 'ScheduledInbound';

                                        trigger OnBeforePassVariable()
                                        begin
                                            TxtScheduledInbound := Format(ScheduledRcpt, 0, 9);
                                        end;
                                    }
                                    textattribute(txtplannedreleases)
                                    {
                                        XmlName = 'PlannedReleases';

                                        trigger OnBeforePassVariable()
                                        begin
                                            TxtPlannedReleases := Format(PlannedOrderReleases, 0, 9); //-+MAG2.26 [401839]
                                        end;
                                    }
                                    textattribute(txtplannedreceipts)
                                    {
                                        XmlName = 'PlannedReceipts';

                                        trigger OnBeforePassVariable()
                                        begin
                                            TxtPlannedReceipts := Format(PlannedOrderRcpt, 0, 9); //-+MAG2.26 [401839]
                                        end;
                                    }
                                    textattribute(txtavailableinventory)
                                    {
                                        XmlName = 'AvailableInventory';

                                        trigger OnBeforePassVariable()
                                        begin
                                            TxtAvailableInventory := Format(QtyAvailable, 0, 9);
                                        end;
                                    }
                                    textattribute(txtexpectedinventory)
                                    {
                                        XmlName = 'ExpectedInventory';

                                        trigger OnBeforePassVariable()
                                        begin
                                            TxtExpectedInventory := Format(ExpectedInventory, 0, 9);
                                        end;
                                    }
                                    textattribute(txtprojectedinventory)
                                    {
                                        XmlName = 'ProjectedInventory';

                                        trigger OnBeforePassVariable()
                                        begin
                                            TxtProjectedInventory := Format(ProjAvailableBalance, 0, 9); //-+MAG2.26 [401839]
                                        end;
                                    }
                                    textattribute(txtinventory)
                                    {
                                        XmlName = 'Inventory';

                                        trigger OnBeforePassVariable()
                                        begin
                                            TxtInventory := Format(ItemByPeriod.Inventory, 0, 9);
                                        end;
                                    }
                                    textattribute(txtnetchange)
                                    {
                                        XmlName = 'NetChange';

                                        trigger OnBeforePassVariable()
                                        begin
                                            TxtNetChange := Format(ItemByPeriod."Net Change", 0, 9);
                                        end;
                                    }
                                    textattribute(txtqtyonsalesorder)
                                    {
                                        XmlName = 'QtyOnSalesOrder';

                                        trigger OnBeforePassVariable()
                                        begin
                                            TxtQtyOnSalesOrder := Format(ItemByPeriod."Qty. on Sales Order");
                                        end;
                                    }
                                    textattribute(txtqtyonpurchaseorder)
                                    {
                                        XmlName = 'QtyOnPurchaseOrder';

                                        trigger OnBeforePassVariable()
                                        begin
                                            TxtQtyOnPurchaseOrder := Format(ItemByPeriod."Qty. on Purch. Order");
                                        end;
                                    }
                                    textattribute(estimatedatefromvendor)
                                    {
                                        XmlName = 'EstimatedDateFromVendor';
                                    }
                                    textattribute(fromvendorcode)
                                    {
                                        XmlName = 'FromVendorCode';
                                    }
                                    textattribute(estimateddatefromlocation)
                                    {
                                        XmlName = 'EstimatedDateFromLocation';
                                    }
                                    textattribute(fromlocationcode)
                                    {
                                        XmlName = 'FromLocationCode';
                                    }

                                    trigger OnAfterGetRecord()
                                    var
                                        Customer: Record Customer;
                                    begin

                                        ItemByPeriod.SetFilter("No.", '=%1', TmpItemResponse."Item No.");
                                        ItemByPeriod.SetFilter("Variant Filter", '=%1', TmpItemResponse."Variant Code");
                                        if (LocationCodeIn <> '') then
                                            ItemByPeriod.SetFilter("Location Filter", '=%1', LocationCodeIn);

                                        ItemByPeriod.FindFirst();

                                        case ViewAsOption of
                                            ViewAsOption::BALANCEATDATE:
                                                ItemByPeriod.SetFilter("Date Filter", '%1..%2', 0D, ItemAvailabilityByPeriod."Period End");
                                            ViewAsOption::NETCHANGE:
                                                ItemByPeriod.SetFilter("Date Filter", '%1..%2', ItemAvailabilityByPeriod."Period Start", ItemAvailabilityByPeriod."Period End");
                                        end;

                                        ItemAvailFormsMgt.CalcAvailQuantities(
                                          ItemByPeriod,
                                          ViewAsOption = ViewAsOption::BALANCEATDATE,
                                          GrossRequirement,
                                          PlannedOrderRcpt,
                                          ScheduledRcpt,
                                          PlannedOrderReleases,
                                          ProjAvailableBalance,
                                          ExpectedInventory,
                                          QtyAvailable);

                                        //-MAG2.26 [402599]
                                        M2ServiceLibrary.GetEstimatedDeliveryDate(
                                          TmpItemResponse."Item No.",
                                          CustomerNumberIn,
                                          NormalDate(ItemAvailabilityByPeriod."Period End"),
                                          EstimateDateFromVendor,
                                          FromVendorCode,
                                          EstimatedDateFromLocation,
                                          FromLocationCode);
                                        //+MAG2.26 [402599]
                                    end;
                                }
                            }
                        }
                        textelement(AccumulatedExecutionTime)
                        {
                            MaxOccurs = Once;

                            trigger OnBeforePassVariable()
                            begin
                                AccumulatedExecutionTime := StrSubstNo('%1 (ms)', Format(Time - StartTime, 0, 9));
                            end;
                        }
                    }
                }
            }
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    trigger OnInitXmlPort()
    begin
        StartTime := Time;
    end;

    var
        StartTime: Time;
        ViewAsOption: Option UNDEFINED,NETCHANGE,BALANCEATDATE;
        InvalidViewByOption: Boolean;
        ItemByPeriod: Record Item;
        ItemAvailFormsMgt: Codeunit "Item Availability Forms Mgt";
        M2ServiceLibrary: Codeunit "NPR M2 Service Lib.";
        GrossRequirement: Decimal;
        PlannedOrderRcpt: Decimal;
        ScheduledRcpt: Decimal;
        PlannedOrderReleases: Decimal;
        ProjAvailableBalance: Decimal;
        ExpectedInventory: Decimal;
        QtyAvailable: Decimal;

    procedure CalculateAvailability()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        Location: Record Location;
        Customer: Record Customer;
        ItemExists: Boolean;
        PartialResult: Boolean;
        InvalidDate: Boolean;
        PeriodStart: Date;
        PeriodEnd: Date;
    begin

        //-MAG2.25 [380946]
        if (CustomerNumberIn <> '') then
            if (Customer.Get(CustomerNumberIn)) then
                if (Customer."Location Code" <> '') then
                    if (LocationCodeIn = '') then
                        LocationCodeIn := Customer."Location Code";
        //+MAG2.25 [380946]

        TmpItemRequest.Reset;
        TmpItemRequest.FindSet();
        repeat
            TmpItemResponse.TransferFields(TmpItemRequest, true);

            ItemExists := Item.Get(TmpItemRequest."Item No.");
            if ((ItemExists) and (TmpItemRequest."Variant Code" <> '')) then
                ItemExists := ItemVariant.Get(TmpItemRequest."Item No.", TmpItemRequest."Variant Code");

            if (ItemExists) then
                TmpItemResponse.Insert();

            if (not ItemExists) then
                PartialResult := true;

        until (TmpItemRequest.Next() = 0);

        TmpDateRequest.FindFirst();

        InvalidDate := (TmpDateRequest."Period Start" = 0D) or (TmpDateRequest."Period End" = 0D);
        if (not InvalidDate) then begin

            //-MAG2.25 [380946]
            ItemAvailabilityByPeriodStart.SetFilter("Period Start", '%1..%1', TmpDateRequest."Period Start");
            ItemAvailabilityByPeriodStart.SetFilter("Period Type", '=%1', TmpDateRequest."Period Type"::Date);
            //+MAG2.25 [380946]

            // Align to first & last date within period
            case TmpDateRequest."Period Type" of
                TmpDateRequest."Period Type"::Date:
                    begin
                        PeriodStart := TmpDateRequest."Period Start";
                        PeriodEnd := TmpDateRequest."Period End";
                    end;
                TmpDateRequest."Period Type"::Week:
                    begin
                        PeriodStart := CalcDate('<-1W+CW+1D>', TmpDateRequest."Period Start");
                        PeriodEnd := CalcDate('<CW>', TmpDateRequest."Period End");
                    end;

                TmpDateRequest."Period Type"::Month:
                    begin
                        PeriodStart := CalcDate('<-1M+CM+1D>', TmpDateRequest."Period Start");
                        PeriodEnd := CalcDate('<CM>', TmpDateRequest."Period End");
                    end;

                TmpDateRequest."Period Type"::Quarter:
                    begin
                        PeriodStart := CalcDate('<-1Q+CQ+1D>', TmpDateRequest."Period Start");
                        PeriodEnd := CalcDate('<CQ>', TmpDateRequest."Period End");
                    end;
                TmpDateRequest."Period Type"::Year:
                    begin
                        PeriodStart := CalcDate('<-1Y+CY+1D>', TmpDateRequest."Period Start");
                        PeriodEnd := CalcDate('<CY>', TmpDateRequest."Period End");
                    end;
            end;
            TmpDateRequest."Period Start" := PeriodStart;
            TmpDateRequest."Period End" := PeriodEnd;

            ItemAvailabilityByPeriod.SetFilter("Period Start", '%1..%2', TmpDateRequest."Period Start", TmpDateRequest."Period End");
            ItemAvailabilityByPeriod.SetFilter("Period Type", '=%1', TmpDateRequest."Period Type");

        end;

        ResponseCode := 'OK';
        ResponseMessage := '';

        if (PartialResult) then begin
            ResponseCode := 'WARNING';
            ResponseMessage := 'Partial result, some items were not found.'
        end;

        if (LocationCodeIn <> '') and (not Location.Get(LocationCodeIn)) then begin
            ResponseCode := 'ERROR';
            ResponseMessage := 'Invalid location code.'
        end;

        if (InvalidDate) then begin
            ResponseCode := 'ERROR';
            ResponseMessage := 'Period date range is invalid.'
        end;

        if (TmpDateRequest."Period End" < TmpDateRequest."Period Start") or (TmpDateRequest."Period Start" > TmpDateRequest."Period End") then begin
            ResponseCode := 'ERROR';
            ResponseMessage := 'Period date range is invalid.'
        end;

        if (ViewAsOption = ViewAsOption::UNDEFINED) then begin
            ResponseCode := 'ERROR';
            ResponseMessage := 'Invalid ViewAs option. Use one of NetChange|BalanceAtDate.'
        end;

        if (InvalidViewByOption) then begin
            ResponseCode := 'ERROR';
            ResponseMessage := 'Invalid ViewBy option. Use one of Date|Week|Month|Quarter|Year.'
        end;

        if (ResponseCode = 'ERROR') then
            if (TmpItemResponse.IsTemporary()) then
                TmpItemResponse.DeleteAll();

        if (StartTime <> 0T) then
            ExecutionTime := StrSubstNo('%1 (ms)', Format(Time - StartTime, 0, 9));
    end;

    local procedure SetErrorResponse()
    begin
    end;
}

