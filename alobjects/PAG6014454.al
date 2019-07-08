page 6014454 "Campaign Discount Lines"
{
    // //-NPR3.0b ved Simon 2005.08.02
    //   Oversaettelser
    // NPR5.26/BHR/20160712 CASE 246594 Display field Cross reference
    // NPR5.36/TJ  /20170809  CASE 286283 Renamed variables/function into english and into proper naming terminology
    //                                    Removed unused variables/functions
    // NPR5.38/AP  /20171103  CASE 295330 Setting editable=FALSE on "Quantity On Purchase Order" and "Inventory" since they where not
    //                                    corretly set to editable=No on table field properties
    // NPR5.38/TS  /20171207  CASE 299031 Added field Page No. in advert
    // NPR5.38/TS  /20171213  CASE 299274 Added fields Photo,Priority
    // NPR5.38/TS  /20180105  CASE 300893 Renamed OnAfterGetCurrRecord to AfterGetCurrentRecord
    // NPR5.38/TS  /20171213  CASE 299281 Added Field Comment
    // NPR5.40/MMV /20180214  CASE 294655 Performance optimization

    Caption = 'Period Discount Lines';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "Period Discount Line";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Cross-Reference No.";"Cross-Reference No.")
                {
                }
                field("Item No.";"Item No.")
                {

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        Item2: Record Item;
                        ItemList: Page "Item List";
                    begin
                        Item.FilterGroup(2);
                        Item.FilterGroup(0);
                        Clear(ItemList);
                        ItemList.LookupMode(true);
                        ItemList.SetTableView(Item);
                        if Item2.Get(Text) then
                          ItemList.SetRecord(Item2);
                        if ItemList.RunModal = ACTION::LookupOK then begin
                          ItemList.GetRecord(Item);
                          Validate("Item No.",Item."No.");
                          Commit;
                        end;
                    end;
                }
                field("Variant Code";"Variant Code")
                {
                }
                field(Description;Description)
                {
                    Editable = false;
                }
                field("Unit Price";"Unit Price")
                {
                    Editable = false;
                }
                field("Campaign Unit Price";"Campaign Unit Price")
                {
                }
                field("Campaign Profit";"Campaign Profit")
                {
                }
                field(Control1160330002;Comment)
                {
                    Caption = 'Comment';
                }
                field(Inventory;Inventory)
                {
                    Caption = 'Inventory';
                    Editable = false;
                }
                field("Quantity On Purchase Order";"Quantity On Purchase Order")
                {
                    Editable = false;
                }
                field("Campaign Unit Cost";"Campaign Unit Cost")
                {
                }
                field(Profit;Profit)
                {
                    Caption = 'Revenue of period';
                    Visible = false;
                }
                field("Vendor No.";"Vendor No.")
                {
                }
                field("Starting Date";"Starting Date")
                {
                    Visible = false;
                }
                field("Ending Date";"Ending Date")
                {
                    Visible = false;
                }
                field("Unit Price Incl. VAT";"Unit Price Incl. VAT")
                {
                    Visible = false;
                }
                field("Page no. in advert";"Page no. in advert")
                {
                }
                field(Priority;Priority)
                {
                }
                field("Pagenumber in paper";"Pagenumber in paper")
                {
                }
                field(Photo;Photo)
                {
                }
            }
            grid(Control10)
            {
                ShowCaption = false;
                group(Control6150613)
                {
                    ShowCaption = false;
                    field(ItemDescription;ItemDescription)
                    {
                        Caption = 'Description';
                        Editable = false;
                    }
                }
                group(Control6150614)
                {
                    ShowCaption = false;
                    field(DB;DB)
                    {
                        Caption = 'Profit (LCY)';
                        Editable = false;
                    }
                }
                group(Control6150615)
                {
                    ShowCaption = false;
                    field(DG;DG)
                    {
                        Caption = 'Profit (%)';
                        DecimalPlaces = 1:1;
                        Editable = false;
                    }
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Comment)
            {
                Caption = 'Comment';
                Image = Comment;
                RunObject = Page "Retail Comments";
                RunPageLink = "Table ID"=CONST(6014414),
                              "No."=FIELD(Code),
                              "No. 2"=FIELD("Item No.");
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        //-NPR5.40 [294655]
        CalcFields("Unit Price Incl. VAT");
        //CALCFIELDS(Status,"Unit Price Incl. VAT");
        //+NPR5.40 [294655]
        //-NPR5.38 [300893]
        //OnAfterGetCurrRecord;
        AfterGetCurrRecord;
        //+NPR5.38 [300893]
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        //-NPR5.38 [300893]
        //OnAfterGetCurrRecord;
        AfterGetCurrRecord;
        //+NPR5.38 [300893]
    end;

    trigger OnOpenPage()
    begin
          OnActivateForm;
    end;

    var
        VATPostingSetup: Record "VAT Posting Setup";
        ItemDescription: Text[50];
        DB: Decimal;
        DG: Decimal;
        VATPct: Decimal;
        Item: Record Item;

    procedure Calculate()
    var
        ItemGroupMsg: Label 'The item does not belong to any itemgroup';
        ItemGroup: Record "Item Group";
    begin
        if "Campaign Unit Price" <> 0 then begin
          Item.Get("Item No.");
          ItemDescription := Item.Description;
          if Item."Item Group" = '' then begin
            ItemDescription := ItemGroupMsg;
            DB := 0;
            DG := 0;
            exit;
          end;
          if ItemGroup.Get(Item."Item Group") then;
          VATPostingSetup.SetRange(VATPostingSetup."VAT Bus. Posting Group",ItemGroup."VAT Bus. Posting Group");
          VATPostingSetup.SetRange(VATPostingSetup."VAT Prod. Posting Group",ItemGroup."VAT Prod. Posting Group");
          if VATPostingSetup.Find('-') then
            VATPct := VATPostingSetup."VAT %";

          if Item."Price Includes VAT" then begin
            DB := Round(("Campaign Unit Price"/(1 + VATPct / 100) - Item."Unit Cost"),0.001);
            if ("Campaign Unit Price"/(1 + VATPct / 100)) <> 0 then
              DG := Round(DB/("Campaign Unit Price"/(1 + VATPct / 100)) * 100,0.01)
            else
              DG := 0;
          end else begin
            DB := Round(("Campaign Unit Price" - Item."Unit Cost"),0.001);
            DG := Round((DB / "Campaign Unit Price" * 100),0.01);
          end;

        end else begin
          ItemDescription := '';
          DB := 0;
          DG := 0;
        end;
    end;

    procedure GetCurrLine(var PeriodDiscountLine: Record "Period Discount Line")
    begin
        PeriodDiscountLine := Rec;
    end;

    procedure CallShowComment()
    begin
        ShowComment;
    end;

    procedure GetSelectionFilter(var Lines: Record "Period Discount Line")
    var
        t001: Label 'no lines chosen!\choose with the mouse or keyboard';
        t002: Label 'only one item chosen!continue?';
    begin
        CurrPage.SetSelectionFilter(Lines);

        if Lines.Count = 0 then
          Error(t001);

        if Lines.Count = 1 then
          if not Confirm(t002,true) then
            Error('');
    end;

    local procedure AfterGetCurrRecord()
    begin
        xRec := Rec;
        //-NPR5.40 [294655]
        CalcFields("Unit Price Incl. VAT");
        //CALCFIELDS(Status,"Unit Price Incl. VAT");
        //+NPR5.40 [294655]
    end;

    local procedure ItemNoOnActivate()
    begin
        Calculate();
    end;

    local procedure CampaignUnitpriceOnActivate()
    begin
        Calculate();
    end;

    local procedure OnDeactivateForm()
    begin
        ItemDescription := '';
        DB := 0;
        DG := 0;
    end;

    local procedure OnActivateForm()
    begin
        if Code <> '' then
          Calculate();
        CurrPage.Update;
    end;

    local procedure ItemNoOnAfterInput(var Text: Text[1024])
    var
        AlternativeNo: Record "Alternative No.";
    begin
        if not Item.Get(Text) then begin
          AlternativeNo.SetRange("Alt. No.",Text);
          if AlternativeNo.Find('-') then begin
            Text := AlternativeNo.Code;
            "Variant Code" := AlternativeNo."Variant Code";
          end;
        end;
    end;
}

