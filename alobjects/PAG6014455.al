page 6014455 "Campaign Discount List"
{
    // NPR4.14/TS/20150818 CASE 220971 Action Card removed from Actions
    // NPR5.29/TJ  /20170123 CASE 263787 Commented out code under action Dimensions-Multiple and set Visible property to FALSE
    // NPR5.42/MHA /20180521  CASE 315554 Added Period Fields to enable Weekly Condition

    Caption = 'Period Discount List';
    CardPageID = "Campaign Discount";
    Editable = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "Period Discount";
    SourceTableView = SORTING("Starting Date","Starting Time","Ending Date","Ending Time");
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Code";Code)
                {
                    Editable = false;
                }
                field(Description;Description)
                {
                    Editable = false;
                }
                field(Status;Status)
                {
                }
                field("Starting Date";"Starting Date")
                {
                }
                field("Ending Date";"Ending Date")
                {
                }
                field("Period Type";"Period Type")
                {
                }
                field("Period Description";"Period Description")
                {
                }
                field(Comment;Comment)
                {
                }
                field("Created Date";"Created Date")
                {
                }
                field("Last Date Modified";"Last Date Modified")
                {
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group(Dimension)
            {
                Caption = 'Dimensions';
                Image = Dimensions;
                action("Dimensions-Single")
                {
                    Caption = 'Dimensions-Single';
                    Image = Dimensions;
                    RunObject = Page "Default Dimensions";
                    RunPageLink = "Table ID"=CONST(6014413),
                                  "No."=FIELD(Code);
                    ShortCutKey = 'Shift+Ctrl+D';
                }
                action("Dimensions-Mulitple")
                {
                    Caption = 'Dimensions-Mulitple';
                    Image = DimensionSets;
                    Visible = false;

                    trigger OnAction()
                    var
                        PeriodDiscount: Record "Period Discount";
                        DefaultDimMultiple: Page "Default Dimensions-Multiple";
                    begin
                        //-NPR5.29 [263787]
                        /*
                        CurrPage.SETSELECTIONFILTER(PeriodDiscount);
                        DefaultDimMultiple.SetMultiPeriodDiscount(PeriodDiscount);
                        DefaultDimMultiple.RUNMODAL;
                        */
                        //+NPR5.29 [263787]

                    end;
                }
            }
        }
    }

    local procedure CodeOnActivate()
    begin
        SetCurrentKey( Code );
        CurrPage.Update;
    end;

    local procedure DescriptionOnActivate()
    begin
        SetCurrentKey( Description );
        CurrPage.Update;
    end;
}

