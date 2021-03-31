page 6014405 "NPR Register List"
{
    Caption = 'Cash Register List';
    CardPageID = "NPR Register Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR Register";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field("Register No."; "Register No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Location Code field';
                }
                field("Opening Cash"; "Opening Cash")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Opening Cash field';
                }
                field("Closing Cash"; "Closing Cash")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Closing Cash field';
                }
                field("Customer Display"; "Customer Display")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer Display field';
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
                    ShortCutKey = 'Shift+Ctrl+D';
                    Visible = false;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Dimensions-Single action';

                    trigger OnAction()
                    begin
                        DimsAreDiscontinuedOnRegister;  //NPR5.53 [371956]
                    end;
                }
                action("Dimensions-Mulitple")
                {
                    Caption = 'Dimensions-Mulitple';
                    Image = DimensionSets;
                    Visible = false;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Dimensions-Mulitple action';

                    trigger OnAction()
                    var
                        Register: Record "NPR Register";
                        DefaultDimMultiple: Page "Default Dimensions-Multiple";
                    begin
                        DimsAreDiscontinuedOnRegister;  //NPR5.53 [371956]
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
                    RunObject = Page "NPR CashKeeper Setup";
                    RunPageLink = "Register No." = FIELD("Register No.");
                    ApplicationArea = All;
                    ToolTip = 'Executes the CashKeeper Setup action';
                }
                action("2nd Display Setup")
                {
                    Caption = '2nd Display Setup';
                    Image = Add;
                    RunObject = Page "NPR POS Display Profile";
                    RunPageLink = "Register No." = FIELD("Register No.");
                    ApplicationArea = All;
                    ToolTip = 'Executes the 2nd Display Setup action';
                }
                action("mPos Setup")
                {
                    Caption = 'mPos Setup';
                    Image = Add;
                    RunObject = Page "NPR MPOS App Setup Card";
                    RunPageLink = "Register No." = FIELD("Register No.");
                    ApplicationArea = All;
                    ToolTip = 'Executes the mPos Setup action';
                }
            }
        }
    }

    var
        selectionfilter: Boolean;

    procedure getRecords(var "record": Record "NPR Register")
    var
        RetailTableCode: Codeunit "NPR Retail Table Code";
    begin

        CurrPage.SetSelectionFilter(Rec);
        if Find('-') then
            repeat
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

