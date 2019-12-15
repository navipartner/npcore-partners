xmlport 6151147 "M2 Item Availability By Period"
{
    // NPR5.49/TSA /20190305 CASE 345373 Initial Version
    // NPR5.50/TSA /20190528 CASE 345373 Fixed Location Code Filter

    Caption = 'Item Availability By Period';
    Encoding = UTF8;
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;

    schema
    {
        textelement(ItemAvailability)
        {
            MaxOccurs = Once;
            tableelement(tmpdaterequest;Date)
            {
                MaxOccurs = Once;
                XmlName = 'Request';
                UseTemporary = true;
                fieldelement(PeriodStart;TmpDateRequest."Period Start")
                {
                }
                fieldelement(PeriodEnd;TmpDateRequest."Period End")
                {
                }
                textelement(ViewBy)
                {

                    trigger OnAfterAssignVariable()
                    begin

                        InvalidViewByOption := false;
                        case UpperCase (ViewBy) of
                          'DATE'    : TmpDateRequest."Period Type" := TmpDateRequest."Period Type"::Date;
                          'WEEK'    : TmpDateRequest."Period Type" := TmpDateRequest."Period Type"::Week;
                          'MONTH'   : TmpDateRequest."Period Type" := TmpDateRequest."Period Type"::Month;
                          'QUARTER' : TmpDateRequest."Period Type" := TmpDateRequest."Period Type"::Quarter;
                          'YEAR'    : TmpDateRequest."Period Type" := TmpDateRequest."Period Type"::Year;
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

                        case UpperCase (ViewAs) of
                          'NETCHANGE'     : ViewAsOption := ViewAsOption::NETCHANGE;
                          'BALANCEATDATE' : ViewAsOption := ViewAsOption::BALANCEATDATE;
                          else
                            ViewAsOption := ViewAsOption::UNDEFINED;
                        end;
                    end;
                }
                textelement(LocationCode)
                {
                    MaxOccurs = Once;
                }
                textelement(requestitems)
                {
                    MaxOccurs = Once;
                    XmlName = 'Items';
                    tableelement(tmpitemrequest;"Item Cross Reference")
                    {
                        XmlName = 'Item';
                        UseTemporary = true;
                        fieldattribute(ItemNumber;TmpItemRequest."Item No.")
                        {
                        }
                        fieldattribute(VariantCode;TmpItemRequest."Variant Code")
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
                        tableelement(tmpitemresponse;"Item Cross Reference")
                        {
                            MinOccurs = Zero;
                            XmlName = 'Item';
                            UseTemporary = true;
                            fieldattribute(ItemNumber;TmpItemResponse."Item No.")
                            {
                            }
                            fieldattribute(VariantCode;TmpItemResponse."Variant Code")
                            {
                            }
                            tableelement(itemavailabilitybyperiod;Date)
                            {
                                LinkTable = TmpItemResponse;
                                MinOccurs = Zero;
                                XmlName = 'Period';
                                fieldattribute(PeriodStart;ItemAvailabilityByPeriod."Period Start")
                                {
                                }
                                fieldattribute(PeriodEnd;ItemAvailabilityByPeriod."Period End")
                                {
                                }
                                fieldattribute(PeriodName;ItemAvailabilityByPeriod."Period Name")
                                {
                                }
                                textattribute(txtgrossrequirment)
                                {
                                    XmlName = 'GrossRequirment';

                                    trigger OnBeforePassVariable()
                                    begin
                                        TxtGrossRequirment := Format (GrossRequirement, 0, 9);
                                    end;
                                }
                                textattribute(txtscheduledinbound)
                                {
                                    XmlName = 'ScheduledInbound';

                                    trigger OnBeforePassVariable()
                                    begin
                                        TxtScheduledInbound := Format (ScheduledRcpt, 0, 9);
                                    end;
                                }
                                textattribute(txtavailableinventory)
                                {
                                    XmlName = 'AvailableInventory';

                                    trigger OnBeforePassVariable()
                                    begin
                                        TxtAvailableInventory := Format (QtyAvailable, 0, 9);
                                    end;
                                }
                                textattribute(txtexpectedinventory)
                                {
                                    XmlName = 'ExpectedInventory';

                                    trigger OnBeforePassVariable()
                                    begin
                                        TxtExpectedInventory := Format (ExpectedInventory, 0, 9);
                                    end;
                                }
                                textattribute(txtinventory)
                                {
                                    XmlName = 'Inventory';

                                    trigger OnBeforePassVariable()
                                    begin
                                        TxtInventory := Format (ItemByPeriod.Inventory, 0, 9);
                                    end;
                                }
                                textattribute(txtnetchange)
                                {
                                    XmlName = 'NetChange';

                                    trigger OnBeforePassVariable()
                                    begin
                                        TxtNetChange := Format (ItemByPeriod."Net Change", 0, 9);
                                    end;
                                }
                                textattribute(txtqtyonsalesorder)
                                {
                                    XmlName = 'QtyOnSalesOrder';

                                    trigger OnBeforePassVariable()
                                    begin
                                        TxtQtyOnSalesOrder := Format (ItemByPeriod."Qty. on Sales Order");
                                    end;
                                }
                                textattribute(txtqtyonpurchaseorder)
                                {
                                    XmlName = 'QtyOnPurchaseOrder';

                                    trigger OnBeforePassVariable()
                                    begin
                                        TxtQtyOnPurchaseOrder := Format (ItemByPeriod."Qty. on Purch. Order");
                                    end;
                                }

                                trigger OnAfterGetRecord()
                                begin

                                    ItemByPeriod.SetFilter ("No.", '=%1', TmpItemResponse."Item No.");
                                    ItemByPeriod.SetFilter ("Variant Filter", '=%1', TmpItemResponse."Variant Code");
                                    if (LocationCode <> '') then
                                      ItemByPeriod.SetFilter ("Location Filter", '=%1', LocationCode);

                                    ItemByPeriod.FindFirst ();

                                    case ViewAsOption of
                                      ViewAsOption::BALANCEATDATE : ItemByPeriod.SetFilter ("Date Filter", '%1..%2', 0D, ItemAvailabilityByPeriod."Period End");
                                      ViewAsOption::NETCHANGE     : ItemByPeriod.SetFilter ("Date Filter", '%1..%2', ItemAvailabilityByPeriod."Period Start", ItemAvailabilityByPeriod."Period End");
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
                                end;
                            }
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
        ItemExists: Boolean;
        PartialResult: Boolean;
        InvalidDate: Boolean;
        PeriodStart: Date;
        PeriodEnd: Date;
    begin

        TmpItemRequest.Reset;
        TmpItemRequest.FindSet();
        repeat
          TmpItemResponse.TransferFields (TmpItemRequest, true);

          ItemExists := Item.Get (TmpItemRequest."Item No.");
          if ((ItemExists) and (TmpItemRequest."Variant Code" <> '')) then
            ItemExists := ItemVariant.Get (TmpItemRequest."Item No.", TmpItemRequest."Variant Code");

          if (ItemExists) then
            TmpItemResponse.Insert ();

          if (not ItemExists) then
            PartialResult := true;

        until (TmpItemRequest.Next () = 0);

        TmpDateRequest.FindFirst ();

        InvalidDate := (TmpDateRequest."Period Start" = 0D) or (TmpDateRequest."Period End" = 0D);
        if (not InvalidDate) then begin

          // Align to first & last date within period
          case TmpDateRequest."Period Type" of
            TmpDateRequest."Period Type"::Date :
              begin
                PeriodStart := TmpDateRequest."Period Start";
                PeriodEnd := TmpDateRequest."Period End";
              end;
            TmpDateRequest."Period Type"::Week :
              begin
                PeriodStart := CalcDate('<-1W+CW+1D>', TmpDateRequest."Period Start");
                PeriodEnd := CalcDate('<CW>', TmpDateRequest."Period End");
              end;

            TmpDateRequest."Period Type"::Month :
              begin
                PeriodStart := CalcDate('<-1M+CM+1D>', TmpDateRequest."Period Start");
                PeriodEnd := CalcDate('<CM>', TmpDateRequest."Period End");
              end;

            TmpDateRequest."Period Type"::Quarter :
              begin
                PeriodStart := CalcDate('<-1Q+CQ+1D>', TmpDateRequest."Period Start");
                PeriodEnd := CalcDate('<CQ>', TmpDateRequest."Period End");
              end;
            TmpDateRequest."Period Type"::Year :
              begin
                PeriodStart := CalcDate('<-1Y+CY+1D>', TmpDateRequest."Period Start");
                PeriodEnd := CalcDate('<CY>', TmpDateRequest."Period End");
              end;
          end;
          TmpDateRequest."Period Start" := PeriodStart;
          TmpDateRequest."Period End" := PeriodEnd;

          ItemAvailabilityByPeriod.SetFilter ("Period Start", '%1..%2', TmpDateRequest."Period Start", TmpDateRequest."Period End");
          ItemAvailabilityByPeriod.SetFilter ("Period Type", '=%1', TmpDateRequest."Period Type");

        end;

        ResponseCode := 'OK';
        ResponseMessage := '';

        if (PartialResult) then begin
          ResponseCode := 'WARNING';
          ResponseMessage := 'Partial result, some items were not found.'
        end;

        if (LocationCode <>'') and (not Location.Get (LocationCode)) then begin
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
          if (TmpItemResponse.IsTemporary ()) then
            TmpItemResponse.DeleteAll ();

        if (StartTime <> 0T) then
          ExecutionTime := StrSubstNo ('%1 (ms)', Format (Time - StartTime, 0, 9));
    end;

    local procedure SetErrorResponse()
    begin
    end;
}

