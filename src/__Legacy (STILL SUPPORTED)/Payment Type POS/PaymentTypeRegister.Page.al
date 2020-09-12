page 6014435 "NPR Payment Type - Register"
{
    // NPR5.29/TJ  /20170123 CASE 263787 Commented out code under action Dimensions-Multiple and set Visible property to FALSE

    Caption = 'Payment Type Register';
    CardPageID = "NPR Payment Type - Card";
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "NPR Payment Type POS";
    SourceTableView = SORTING("No.")
                      ORDER(Ascending)
                      WHERE(Status = CONST(Active));

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Processing Type"; "Processing Type")
                {
                    ApplicationArea = All;
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
                    RunPageLink = "Table ID" = CONST(6014402),
                                  "No." = FIELD("No.");
                    ShortCutKey = 'Shift+Ctrl+D';
                    ApplicationArea = All;
                }
                action("Dimensions-Mulitple")
                {
                    Caption = 'Dimensions-Mulitple';
                    Image = DimensionSets;
                    Visible = false;
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        PaymentType: Record "NPR Payment Type POS";
                        DefaultDimMultiple: Page "Default Dimensions-Multiple";
                    begin
                        //-NPR5.29 [263787]
                        /*
                        CurrPage.SETSELECTIONFILTER(PaymentType);
                        DefaultDimMultiple.SetMultiPaymentTypePOS(PaymentType);
                        DefaultDimMultiple.RUNMODAL;
                        */
                        //+NPR5.29 [263787]

                    end;
                }
            }
        }
    }
}

