page 6014405 "Register List"
{
    // 
    // NPK, MIM 26-07-07: Rettet design til at overholde GUI Guide retningslinjer.
    // 
    // NPR4.21/RMT/20160210 CASE 234145 make sure register no is always an integer
    // 
    // NPR5.29/CLVA/20160822 CASE 244944 Added Action CashKeeper Setup
    // NPR5.29/CLVA/20161123 CASE 256153 Added Action 2nd Display Setup
    // NPR5.29/TJ  /20170123 CASE 263787 Commented out code under action Dimensions-Multiple and set Visible property to FALSE
    // NPR5.30/TJ  /20170215 CASE 265504 Changed page ENU caption
    // NPR5.31/CLVA/20161205 CASE 251884 Added Action mPos Setup
    // NPR5.46/MMV /20180918 CASE 290734 Removed deprecated fields, most from standard POS

    Caption = 'Cash Register List';
    CardPageID = "Register Card";
    Editable = false;
    PageType = List;
    SourceTable = Register;
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field("Register No.";"Register No.")
                {
                }
                field(Description;Description)
                {
                }
                field(Status;Status)
                {
                }
                field("Global Dimension 1 Code";"Global Dimension 1 Code")
                {
                }
                field("Global Dimension 2 Code";"Global Dimension 2 Code")
                {
                }
                field("Location Code";"Location Code")
                {
                }
                field("Opening Cash";"Opening Cash")
                {
                }
                field("Closing Cash";"Closing Cash")
                {
                }
                field(Balanced;Balanced)
                {
                }
                field("Customer Display";"Customer Display")
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
                    RunPageLink = "Table ID"=CONST(6014401),
                                  "No."=FIELD("Register No.");
                    ShortCutKey = 'Shift+Ctrl+D';
                }
                action("Dimensions-Mulitple")
                {
                    Caption = 'Dimensions-Mulitple';
                    Image = DimensionSets;
                    Visible = false;

                    trigger OnAction()
                    var
                        Register: Record Register;
                        DefaultDimMultiple: Page "Default Dimensions-Multiple";
                    begin
                        //-NPR5.29 [263787]
                        /*
                        CurrPage.SETSELECTIONFILTER(Register);
                        DefaultDimMultiple.SetMultiRegister(Register);
                        DefaultDimMultiple.RUNMODAL;
                        */
                        //+NPR5.29 [263787]

                    end;
                }
                action("CashKeeper Setup")
                {
                    Caption = 'CashKeeper Setup';
                    Image = Add;
                    RunObject = Page "CashKeeper Setup";
                    RunPageLink = "Register No."=FIELD("Register No.");
                }
                action("2nd Display Setup")
                {
                    Caption = '2nd Display Setup';
                    Image = add;
                    RunObject = Page "Display Setup";
                    RunPageLink = "Register No."=FIELD("Register No.");
                }
                action("mPos Setup")
                {
                    Caption = 'mPos Setup';
                    Image = add;
                    RunObject = Page "MPOS App Setup Card";
                    RunPageLink = "Register No."=FIELD("Register No.");
                }
            }
        }
    }

    var
        selectionfilter: Boolean;

    procedure getRecords(var "record": Record Register)
    var
        RetailTableCode: Codeunit "Retail Table Code";
    begin

        CurrPage.SetSelectionFilter(Rec);
        if Find('-') then repeat
          record.Init;
          record := Rec;
          //-NPR4.21
          RetailTableCode.RegisterCheckNo(record."Register No.");
          //+NPR4.21
          record.Insert;
        until Next = 0;

        MarkedOnly(false);
    end;
}

