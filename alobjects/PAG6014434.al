page 6014434 "Payment Type - List"
{
    // NPR7.000.000,TS,30.10.2012 : On the fornm this code was written on the deactivate trigger of the control G/L Account ,Cost Account
    // 
    // G/L Account - OnDeactivate()
    //   OpdaterFinKtoNavn(' ');
    // 
    // Cost Account - OnDeactivate()
    //   OpdaterFinKtoNavn(' ');
    // 
    // NPR4.12/JDH/20150703 CASE 217125 Added extra fields, + disabled existing non important fields
    // NPR5.27/TSA/20160928 CASE 253683 removed field "Amount in Audit Roll" from page. visible false seems not to be work
    // NPR5.29/TJ  /20170123 CASE 263787 Commented out code under action Dimensions-Multiple and set Visible property to FALSE
    // NPR5.47/TS  /20181022 CASE 309123 Removed unused fields

    Caption = 'Payment Type List';
    CardPageID = "Payment Type - Card";
    Editable = false;
    PageType = List;
    SourceTable = "Payment Type POS";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field("No.";"No.")
                {
                }
                field(Description;Description)
                {
                }
                field("Processing Type";"Processing Type")
                {
                }
                field("G/L Account No.";"G/L Account No.")
                {

                    trigger OnValidate()
                    begin

                        OpdaterFinKtoNavn("G/L Account No.");
                    end;
                }
                field(Status;Status)
                {
                }
                field(Prefix;Prefix)
                {
                    Visible = false;
                }
                field("Cost Account No.";"Cost Account No.")
                {
                    Visible = false;
                }
                field("Location Code";"Location Code")
                {
                    Visible = false;
                }
                field("Fee G/L Acc. No.";"Fee G/L Acc. No.")
                {
                }
                field("Fee Pct.";"Fee Pct.")
                {
                }
                field("Fee Item No.";"Fee Item No.")
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
                    RunPageLink = "Table ID"=CONST(6014402),
                                  "No."=FIELD("No.");
                    ShortCutKey = 'Shift+Ctrl+D';
                }
                action("Dimensions-Mulitple")
                {
                    Caption = 'Dimensions-Mulitple';
                    Image = DimensionSets;
                    Visible = false;

                    trigger OnAction()
                    var
                        PaymentType: Record "Payment Type POS";
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

    var
        Kontonr: Code[20];
        KontoNavn: Text[50];

    procedure OpdaterFinKtoNavn(KtnNr: Code[20])
    var
        FinKtoRec: Record "G/L Account";
    begin
        if FinKtoRec.Get(KtnNr) then begin
          Kontonr := KtnNr;
          KontoNavn := FinKtoRec.Name;
        end else begin
          Kontonr := '';
          KontoNavn := '';
        end;
        //CurrForm.UPDATE;
         CurrPage.Update;
    end;

    procedure GetItemNo(var BetalingsValg: Record "Payment Type POS")
    begin
        BetalingsValg := Rec;
        exit;
    end;

    procedure Scroll(step: Integer)
    begin
        Next(step);
        //CurrForm.UPDATE(FALSE);
        CurrPage.Update(false);
    end;

    procedure hideControls()
    begin
        /*
        CurrForm.frameKONTO.VISIBLE(FALSE);
        CurrForm.btnOK.VISIBLE(FALSE);
        CurrForm.btnCANCEL.VISIBLE(FALSE);
        CurrForm.btnHELP.VISIBLE(FALSE);
         */

    end;

    procedure maxTable(thisWidth: Integer;thisHeight: Integer)
    begin
        //CurrForm.tableBetValg.WIDTH  := thisWidth;
        //CurrForm.tableBetValg.HEIGHT := thisHeight;
    end;
}

