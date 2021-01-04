page 6014454 "NPR Campaign Discount Lines"
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
    // NPR5.54/BHR /20200129  CASE 387439 removed unused functions and fields as per case.

    Caption = 'Period Discount Lines';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = Administration;
    SourceTable = "NPR Period Discount Line";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Cross-Reference No."; "Cross-Reference No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cross-Reference No. field';
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item No. field';

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
                            Validate("Item No.", Item."No.");
                            Commit;
                        end;
                    end;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variant Code field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Unit Price"; "Unit Price")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Unit Price field';
                }
                field("Campaign Unit Price"; "Campaign Unit Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Period Price field';
                }
                field("Campaign Profit"; "Campaign Profit")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Campaign Profit field';
                }
                field(Control1160330002; Comment)
                {
                    ApplicationArea = All;
                    Caption = 'Comment';
                    ToolTip = 'Specifies the value of the Comment field';
                }
                field(Inventory; Inventory)
                {
                    ApplicationArea = All;
                    Caption = 'Inventory';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Inventory field';
                }
                field("Quantity On Purchase Order"; "Quantity On Purchase Order")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Quantity in Purchase Order field';
                }
                field("Campaign Unit Cost"; "Campaign Unit Cost")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Period Cost field';
                }
                field(Profit; Profit)
                {
                    ApplicationArea = All;
                    Caption = 'Revenue of period';
                    Visible = false;
                    ToolTip = 'Specifies the value of the Revenue of period field';
                }
                field("Vendor No."; "Vendor No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Vendor No. field';
                }
                field("Starting Date"; "Starting Date")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Starting Date field';
                }
                field("Ending Date"; "Ending Date")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Closing Date field';
                }
                field("Unit Price Incl. VAT"; "Unit Price Incl. VAT")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Price Includes VAT field';
                }
                field("Page no. in advert"; "Page no. in advert")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Page no. in advert field';
                }
                field(Priority; Priority)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Priority field';
                }
                field("Pagenumber in paper"; "Pagenumber in paper")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Pagenumber in paper field';
                }
                field(Photo; Photo)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Photo field';
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
                RunObject = Page "NPR Retail Comments";
                RunPageLink = "Table ID" = CONST(6014414),
                              "No." = FIELD(Code),
                              "No. 2" = FIELD("Item No.");
                ApplicationArea = All;
                ToolTip = 'Executes the Comment action';
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

    var
        Item: Record Item;

    procedure GetCurrLine(var PeriodDiscountLine: Record "NPR Period Discount Line")
    begin
        PeriodDiscountLine := Rec;
    end;

    local procedure AfterGetCurrRecord()
    begin
        xRec := Rec;
        //-NPR5.40 [294655]
        CalcFields("Unit Price Incl. VAT");
        //CALCFIELDS(Status,"Unit Price Incl. VAT");
        //+NPR5.40 [294655]
    end;
}

