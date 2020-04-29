page 6014455 "Campaign Discount List"
{
    // NPR4.14/TS/20150818 CASE 220971 Action Card removed from Actions
    // NPR5.29/TJ  /20170123 CASE 263787 Commented out code under action Dimensions-Multiple and set Visible property to FALSE
    // NPR5.42/MHA /20180521  CASE 315554 Added Period Fields to enable Weekly Condition
    // NPR5.51/SARA/20190826  CASE 365799 Able to delete more than one lines at a time

    Caption = 'Period Discount List';
    CardPageID = "Campaign Discount";
    Editable = true;
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
                    Editable = false;
                }
                field("Starting Date";"Starting Date")
                {
                    Editable = false;
                }
                field("Ending Date";"Ending Date")
                {
                    Editable = false;
                }
                field("Period Type";"Period Type")
                {
                    Editable = false;
                }
                field("Period Description";"Period Description")
                {
                    Editable = false;
                }
                field(Comment;Comment)
                {
                    Editable = false;
                }
                field("Created Date";"Created Date")
                {
                    Editable = false;
                }
                field("Last Date Modified";"Last Date Modified")
                {
                    Editable = false;
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

