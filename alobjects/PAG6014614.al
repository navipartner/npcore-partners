page 6014614 "Discount FactBox"
{
    // NPR5.41/TS /20180330 CASE FactBox created to show if Item has Mix or Period Discount.
    // NPR5.45/TS  /20180824  CASE Added MultipleUnitPrice
    // NPR5.48/TS  /20181218  CASE Corrected MultipleUnit Price

    Caption = 'Discount FactBox';
    InsertAllowed = false;
    PageType = CardPart;
    SourceTable = Item;

    layout
    {
        area(content)
        {
            field("Mix Discount";MixDiscount)
            {
                Caption = 'Mix Discount';

                trigger OnAssistEdit()
                var
                    MixedDiscountLines: Page "Mixed Discount Lines";
                    MixedDiscountLine: Record "Mixed Discount Line";
                begin
                    MixedDiscountLines.Editable(false);
                    MixedDiscountLine.Reset;
                    MixedDiscountLine.SetRange("No.","No.");
                    MixedDiscountLines.SetTableView(MixedDiscountLine);
                    MixedDiscountLines.RunModal;
                end;
            }
            field("Period Discount";PeriodDiscount)
            {
                Caption = 'Period Discount';

                trigger OnDrillDown()
                var
                    CampaignDiscountLines: Page "Campaign Discount Lines";
                    PeriodDiscountLine: Record "Period Discount Line";
                begin
                    CampaignDiscountLines.Editable(false);
                    PeriodDiscountLine.Reset;
                    PeriodDiscountLine.SetRange("Item No.","No.");
                    CampaignDiscountLines.SetTableView(PeriodDiscountLine);
                    CampaignDiscountLines.RunModal;
                end;
            }
            field("Multiple Unit Price";MultipleUnitPrice)
            {
                Caption = 'Multiple Unit Price';

                trigger OnAssistEdit()
                var
                    QuantityDiscountHeader: Record "Quantity Discount Header";
                    QuantityDiscountCard: Page "Quantity Discount Card";
                begin
                    //-NPR5.45 [308196]
                    QuantityDiscountCard.Editable(false);
                    QuantityDiscountHeader.Reset;
                    //-NPR5.48 [340047]
                    //QuantityDiscountHeader.SETFILTER("Main No.", "No.");
                    QuantityDiscountHeader.SetFilter("Item No.", "No.");
                    //+NPR5.48 [340047]
                    QuantityDiscountCard.SetTableView(QuantityDiscountHeader);
                    QuantityDiscountCard.RunModal;
                    //+NPR5.45 [308196]
                end;
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        HasDiscounts();
        //-NPR5.45 [308196]
        HasMultipleUnitPrice();
        //+NPR5.45 [308196]
    end;

    var
        MixDiscount: Boolean;
        PeriodDiscount: Boolean;
        MultipleUnitPrice: Boolean;

    procedure HasDiscounts()
    var
        PeriodDiscountLine: Record "Period Discount Line";
        MixDiscountLine: Record "Mixed Discount Line";
        MixDiscountHeader: Record "Mixed Discount";
    begin
        MixDiscount := false;
        PeriodDiscount := false;
        PeriodDiscountLine.SetRange(PeriodDiscountLine.Status, PeriodDiscountLine.Status::Active);
        PeriodDiscountLine.SetFilter(PeriodDiscountLine."Starting Date", '<=%1', Today);
        PeriodDiscountLine.SetFilter(PeriodDiscountLine."Ending Date", '>=%1', Today);
        PeriodDiscountLine.SetFilter(PeriodDiscountLine."Item No.", "No.");
        if PeriodDiscountLine.FindFirst then
          PeriodDiscount := true;

        PeriodDiscountLine.Reset;
        PeriodDiscountLine.SetRange(PeriodDiscountLine.Status, PeriodDiscountLine.Status::Active);
        PeriodDiscountLine.SetFilter(PeriodDiscountLine."Starting Date", '>%1', Today);
        PeriodDiscountLine.SetFilter(PeriodDiscountLine."Item No.", "No.");
        if PeriodDiscountLine.FindFirst then
         PeriodDiscount := true;

        MixDiscountLine.Reset;
        MixDiscountLine.SetFilter(MixDiscountLine."No.", "No.");
        if MixDiscountLine.FindFirst then
          repeat
            MixDiscountHeader.Reset;
            if MixDiscountHeader.Get(MixDiscountLine.Code)  and ((MixDiscountHeader."Starting date" <= Today) and
              (MixDiscountHeader."Ending date" >=Today)) and (MixDiscountHeader.Status = MixDiscountHeader.Status::Active)then begin
              MixDiscount := true;
            end;
          until MixDiscountLine.Next = 0;

        if not MixDiscount then begin
          MixDiscountLine.Reset;
          MixDiscountLine.SetFilter(MixDiscountLine."No.", "No.");
          if MixDiscountLine.FindFirst then
            repeat
            MixDiscountHeader.Reset;
            if MixDiscountHeader.Get(MixDiscountLine.Code)  and (MixDiscountHeader."Starting date" > Today) and
              (MixDiscountHeader.Status = MixDiscountHeader.Status::Active)then begin
               MixDiscount := true;
            end;
            until MixDiscountLine.Next = 0;
        end;
    end;

    local procedure HasMultipleUnitPrice()
    var
        QuantityDiscountHeader: Record "Quantity Discount Header";
    begin
        //-NPR5.45 [308196]
        MultipleUnitPrice := false;
        //-NPR5.48 [340047]
        //QuantityDiscountHeader.SETFILTER("Main No.", "No.");
        //QuantityDiscountHeader.SETFILTER("Starting Date", '>%1', TODAY);
        QuantityDiscountHeader.SetFilter("Item No.", "No.");
        QuantityDiscountHeader.SetRange(Status,QuantityDiscountHeader.Status::Active);
        //+NPR5.48 [340047]
        if QuantityDiscountHeader.FindFirst then
          MultipleUnitPrice := true;
        //+NPR5.45 [308196]
    end;
}

