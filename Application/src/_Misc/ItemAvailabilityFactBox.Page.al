page 6014601 "NPR Item Availability FactBox"
{
    Caption = 'Item Availability Details';
    PageType = CardPart;
    RefreshOnActivate = true;
    ShowFilter = true;
    SourceTable = Item;

    layout
    {
        area(content)
        {
            field("No."; Rec."No.")
            {
                ApplicationArea = All;
                Caption = 'Item No.';
                Lookup = false;
                ToolTip = 'Specifies the value of the Item No. field';

                trigger OnDrillDown()
                begin
                    ShowDetails;
                end;
            }
            field(Availability; StrSubstNo('%1', CalcAvailability))
            {
                ApplicationArea = All;
                Caption = 'Availability';
                DrillDown = true;
                Editable = true;
                ToolTip = 'Specifies the value of the Availability field';

                trigger OnDrillDown()
                begin
                    ItemAvailFormsMgt.ShowItemAvailFromItem(Rec, ItemAvailFormsMgt.ByEvent);
                    CurrPage.Update(true);
                end;
            }
            field(Inventory; Rec.Inventory)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Inventory field';
            }
            field("Qty. on Sales Order"; Rec."Qty. on Sales Order")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Qty. on Sales Order field';
            }
            field("Qty. on Purch. Order"; Rec."Qty. on Purch. Order")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Qty. on Purch. Order field';
            }
            field("Sales (Qty.)"; Rec."Sales (Qty.)")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Sales (Qty.) field';
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        Rec.CalcFields("NPR Has Variants");
        HasVariants := "NPR Has Variants";
    end;

    trigger OnAfterGetRecord()
    begin
        LocationFilter := Rec.GetFilter("Location Filter");
    end;

    var
        ItemAvailFormsMgt: Codeunit "Item Availability Forms Mgt";
        [InDataSet]
        HasVariants: Boolean;
        [InDataSet]
        LocationFilter: Text;

    local procedure ShowDetails()
    var
        Item: Record Item;
    begin
        PAGE.Run(PAGE::"Item Card", Item);
    end;

    procedure CalcAvailability(): Decimal
    var
        AvailableToPromise: Codeunit "Available to Promise";
        LookaheadDateformula: DateFormula;
        AvailabilityDate: Date;
        GrossRequirement: Decimal;
        ScheduledReceipt: Decimal;
        PeriodType: Option Day,Week,Month,Quarter,Year;
    begin
        AvailabilityDate := WorkDate;

        Rec.SetRange("Date Filter", 0D, AvailabilityDate);
        Rec.SetRange("Drop Shipment Filter", false);

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

