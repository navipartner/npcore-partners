page 6014601 "NPR Item Availability FactBox"
{
    // NPR5.31/BR  /20170426  CASE 272849  Object Created
    // NPR5.43/BHR /20180626  CASE 319926  Add field "Qty. on Sales Order","Qty. on Purch. Order"
    // NPR5.44/TS  /20180706  CASE 320700  Added Field Sales (Qty )

    Caption = 'Item Availability Details';
    PageType = CardPart;
    RefreshOnActivate = true;
    ShowFilter = true;
    SourceTable = Item;

    layout
    {
        area(content)
        {
            field("No.";"No.")
            {
                Caption = 'Item No.';
                Lookup = false;

                trigger OnDrillDown()
                begin
                    ShowDetails;
                end;
            }
            field(Availability;StrSubstNo('%1',CalcAvailability))
            {
                Caption = 'Availability';
                DecimalPlaces = 2:0;
                DrillDown = true;
                Editable = true;

                trigger OnDrillDown()
                begin
                    ItemAvailFormsMgt.ShowItemAvailFromItem(Rec,ItemAvailFormsMgt.ByEvent);
                    CurrPage.Update(true);
                end;
            }
            field(Inventory;Inventory)
            {
            }
            field("Qty. on Sales Order";"Qty. on Sales Order")
            {
            }
            field("Qty. on Purch. Order";"Qty. on Purch. Order")
            {
            }
            field("Sales (Qty.)";"Sales (Qty.)")
            {
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetCurrRecord()
    begin
        CalcFields("Has Variants");
        HasVariants := "Has Variants";
    end;

    trigger OnAfterGetRecord()
    begin
        LocationFilter := GetFilter("Location Filter");
    end;

    var
        ItemAvailFormsMgt: Codeunit "Item Availability Forms Mgt";
        TextAllLocations: Label 'All Locations';
        [InDataSet]
        HasVariants: Boolean;
        [InDataSet]
        LocationFilter: Text;

    local procedure ShowDetails()
    var
        Item: Record Item;
    begin
        PAGE.Run(PAGE::"Item Card",Item);
    end;

    procedure CalcAvailability(): Decimal
    var
        AvailableToPromise: Codeunit "Available to Promise";
        GrossRequirement: Decimal;
        ScheduledReceipt: Decimal;
        PeriodType: Option Day,Week,Month,Quarter,Year;
        AvailabilityDate: Date;
        LookaheadDateformula: DateFormula;
    begin
        AvailabilityDate := WorkDate;

        SetRange("Date Filter",0D,AvailabilityDate);
        SetRange("Drop Shipment Filter",false);

        exit(
          AvailableToPromise.QtyAvailabletoPromise(
            Rec,
            GrossRequirement,
            ScheduledReceipt,
            AvailabilityDate,
            PeriodType,
            LookaheadDateformula));
    end;
}

