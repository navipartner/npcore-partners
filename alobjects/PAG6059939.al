page 6059939 "Sales Price Maintenance Setup"
{
    // NPR5.25/CLVA/20160628 CASE 244461 : Sales Price Maintenance
    // NPR5.33/NPKNAV/20170630  CASE 272906 Transport NPR5.33 - 30 June 2017
    // NPR5.43/TS  /20180607 CASE 318039 Update Items that are defined on the Sales Price
    // NPR5.51/CLVA/20190704 CASE 360328 Removed Sales Price check
    // NPR5.52/TJ  /20190225 CASE 345782 Update price is using codeunit 6014481

    AutoSplitKey = true;
    Caption = 'Sales Price Maintenance Setup';
    PageType = List;
    SourceTable = "Sales Price Maintenance Setup";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Id;Id)
                {
                }
                field("Sales Type";"Sales Type")
                {
                }
                field("Sales Code";"Sales Code")
                {
                }
                field("Currency Code";"Currency Code")
                {
                }
                field("Prices Including VAT";"Prices Including VAT")
                {
                }
                field("VAT Bus. Posting Gr. (Price)";"VAT Bus. Posting Gr. (Price)")
                {
                }
                field("Allow Invoice Disc.";"Allow Invoice Disc.")
                {
                }
                field("Allow Line Disc.";"Allow Line Disc.")
                {
                }
                field("Internal Unit Price";"Internal Unit Price")
                {
                }
                field(Factor;Factor)
                {
                }
                field("Exclude Item Groups";"Exclude Item Groups")
                {
                }
                field("Exclude All Item Groups";"Exclude All Item Groups")
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Create Sales Prices for All Items")
            {
                Caption = 'Create Sales Prices for All Items';
                Image = PriceAdjustment;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    SalesPrice: Record "Sales Price";
                    Item: Record Item;
                begin
                    //-NPR5.43 [318039]
                    CreateSalesPrices();
                    //+NPR5.43 [318039]
                end;
            }
            action("Update Existing Sales Prices")
            {
                Caption = 'Update Existing Sales Prices';
                Image = Price;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    //-NPR5.43 [318039]
                    UpdateSalesPrices();
                    //+NPR5.43 [318039]
                end;
            }
        }
    }

    var
        Text00001: Label 'Do you want to create Sales Prices for all Items? Existing Sales Prices will be overwritten';
        Text00002: Label 'Sales Prices have been created.';
        Text00003: Label 'Sales Prices have been updated.';

    local procedure CreateSalesPrices()
    var
        SalesPrice: Record "Sales Price";
        Item: Record Item;
    begin
        //-NPR5.43 [318039]
        if not Confirm(Text00001,true) then
          exit;
        if Item.FindSet then
          repeat
            if FindSalesPrices(Item) then
              SalesPrice.DeleteAll;
            SalesPrice.Init;
            SalesPrice.Validate("Item No.",Item."No.");
            SalesPrice."Sales Type" := "Sales Type";
            SalesPrice.Validate("Sales Code","Sales Code");
            SalesPrice."Starting Date" := Item."Special Price From";
            SalesPrice."Minimum Quantity" := 0;
            case "Internal Unit Price" of
              "Internal Unit Price"::"Unit Cost": SalesPrice."Unit Price" := Item."Unit Cost" * Factor;
              "Internal Unit Price"::"Unit Price": SalesPrice."Unit Price" := Item."Unit Price" * Factor;
              "Internal Unit Price"::"Last Direct Cost": SalesPrice."Unit Price" := Item."Last Direct Cost" * Factor;
              "Internal Unit Price"::"Standard Cost": SalesPrice."Unit Price" := Item."Standard Cost" * Factor;
            end;
            SalesPrice."Ending Date" := Item."Special Price To";
            SalesPrice."VAT Bus. Posting Gr. (Price)" := Item."VAT Bus. Posting Gr. (Price)" ;
            SalesPrice."Price Includes VAT" := SalesPrice."Price Includes VAT";
            SalesPrice.Insert(true);
          until Item.Next =0;
        Message(Text00002);
        //+NPR5.43 [318039]
    end;

    local procedure UpdateSalesPrices()
    var
        SalesPrice: Record "Sales Price";
        Item: Record Item;
        SalesPriceMaintenance: Codeunit "Sales Price Maintenance Event";
    begin
        //-NPR5.52 [345782]
        /*
        //-NPR5.43 [318039]
        SalesPrice.SETRANGE("Sales Type","Sales Type");
        SalesPrice.SETRANGE("Sales Code","Sales Code");
        IF SalesPrice.FINDSET THEN
          REPEAT
            IF Item.GET(SalesPrice."Item No.") THEN BEGIN
              CASE "Internal Unit Price" OF
                "Internal Unit Price"::"Unit Cost": SalesPrice."Unit Price" := Item."Unit Cost" * Factor;
                "Internal Unit Price"::"Unit Price": SalesPrice."Unit Price" := Item."Unit Price" * Factor;
                "Internal Unit Price"::"Last Direct Cost": SalesPrice."Unit Price" := Item."Last Direct Cost" * Factor;
                "Internal Unit Price"::"Standard Cost": SalesPrice."Unit Price" := Item."Standard Cost" * Factor;
              END;
              SalesPrice.MODIFY(TRUE);
            END;
          UNTIL SalesPrice.NEXT = 0;
        */
        if Item.FindSet then
          repeat
            //-NPR5.51 [360328]
            //IF FindSalesPrices(Item) THEN
              SalesPriceMaintenance.UpdateSalesPricesForStaff(Item);
            //+NPR5.51 [360328]
          until Item.Next = 0;
        //+NPR5.52 [345782]
        Message(Text00003);
        //+NPR5.43 [318039]

    end;

    local procedure FindSalesPrices(Item: Record Item): Boolean
    var
        SalesPrice: Record "Sales Price";
    begin
        //-NPR5.43 [318039]
        SalesPrice.SetRange("Item No.",Item."No.");
        SalesPrice.SetRange("Sales Type","Sales Type");
        SalesPrice.SetRange("Sales Code","Sales Code");
        SalesPrice.SetRange("Variant Code",'');
        exit(not SalesPrice.IsEmpty);
        //+NPR5.43 [318039]
    end;
}

