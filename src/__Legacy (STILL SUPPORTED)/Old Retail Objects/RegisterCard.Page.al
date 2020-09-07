page 6014406 "NPR Register Card"
{
    // //-NPR3.0n d.56.05.05 v. Simon Sch¢bel
    //   Oversættelser
    // 
    // NPR4.10/VB/20150601  CASE 213003 Added field Control Add-in Type
    // NPR4.10/JDH/20150519 CASE 214307 Possible to set opening balance to 0
    // NPR4.12/VB/20150708  CASE 213003 Added functionality to detect decimal and thousands separator
    // NPR4.13/MMV/20150715 CASE 215400 Removed field 600 "Exchange label terms" from page (Not used anywhere according to OMA)
    //                                  Added new field 620 Exchange Label Exchange Period to allow for register specific exchange periods. Name/Type matches retail setup equivalent
    // NPR4.14/JS/20150922  CASE 223584 Added field Enable Contactless under Accessories to allow the customer to switch contactless on and off.
    // NPR4.14/VB/20151001  CASE 224232 Added field Client Formatting Culture ID, grouped fields for number formatting together
    // NPR4.16/JDH/20151115 CASE 225415 Removed all unused fields (all undocumented in code by purpose)
    // NPR4.18/MMV/20151230 CASE 226140 Removed about 10 deprecated fields
    // NPR4.18/MMV/20160202  CASE 224257 New Tax Free integration fields.
    // NPR5.22/VB/20151130  CASE 226832 Added fields 830, 831, and 832 to support changed POS device protocol functionality
    // NPR5.22/VB/20160105  CASE 230373 Refactoring due to client-side formatting of decimal and date/time values
    // NPR5.00/NPKNAV/20160113  CASE 226725 NP Retail 2016
    // NPR5.22/VB/20160407 CASE 237866 Added field "Line Order on Screen"
    // NPR4.21/MMV/20160210 CASE 224257 Added missing tax free field.
    // NPR4.21/MMV/20160223 CASE 223223 Added field 340
    // NPR5.25/TTH/20160623 CASE 238859 Added Swipp Fields
    // NPR5.28/MMV /20161107 CASE 254575 Added new field 273 "Sales Ticket Email Output".
    // NPR5.28/VB/20161107 CASE 257796 Added field 834 : "Skip Infobox Update in Sale"
    // NPR5.28/VB/20161122 CASE 259086 Removed Control Add-in Type field
    // NPR5.29/CLVA/20161222 CASE 251884 Added field Adyen Payment Type
    // NPR5.29/MMV /20161216 CASE 241549 Removed deprecated print/report code.
    // NPR5.30/MMV /20170207 CASE 261964 Refactored tax free integration.
    // NPR5.30/TJ  /20170213 CASE 264909 Removed Swipp group with controls
    // NPR5.30/TJ  /20170215 CASE 265504 Changed page ENU caption
    // NPR5.31/MHA /20170113 CASE 263093 Added field 325 "Customer Disc. Group" to Group Sale
    // NPR5.32/AP  /20170525 CASE 248534 Removed section "Posting Groups" containing "Gen. Business Posting Group", "VAT Gen. Business Post.Gr" and "Gen. Business Posting Override"
    //                                   These are either moved to POS Store or deprecated
    // NPR5.35/TJ  /20170823 CASE 286283 Renamed variables/function into english and into proper naming terminology
    //                                   Removed unused variables
    // NPR5.36/BR  /20170914 CASE 289641 Added field VAT Customer No.
    // NPR5.36/AP  /20170926 CASE 291427 Remove warning message for deprecated fields "Gen. Business Posting Group", "VAT Gen. Business Post.Gr"
    //                                   Deleted local text constant "WarningGroup" on OnClodePage
    // NPR5.40/TS  /20180308 CASE 307432 Removed reference to Field Import credit card transact. and Auto Open/Close Terminal
    // NPR5.46/MMV /20180918 CASE 290734 Removed deprecated fields, most from standard POS
    // NPR5.49/VB  /20181106 CASE 335141 Introducing the POS Theme functionality
    // NPR5.49/TJ  /20190201 CASE 335739 Fields 20,819,820,821,822,833 and 6150721 moved to new table
    //                                   Picture actions and decimal detect action moved to new page
    // NPR5.52/ALPO/20190926 CASE 368673 Active event (from Event Management module) on cash register: new control "Active Event No."
    // NPR5.53/ALPO/20191013 CASE 371955 Removed field 25 "Rounding": moved to "POS Posting Profile" (Table 6150653)
    // NPR5.53/ALPO/20191023 CASE 373743 Removed field 21 "Sales Ticket Series": moved to "POS Audit Profile" (Table 6150650)
    // NPR5.53/ALPO/20191025 CASE 371956 Dimensions: POS Store & POS Unit integration; discontinue dimensions on Cash Register

    Caption = 'Cash Register Setup';
    RefreshOnActivate = true;
    SourceTable = "NPR Register";

    layout
    {
        area(content)
        {
            group(Register)
            {
                Caption = 'Register';
                field("Register No."; "Register No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                }
                field("Logon-User Name"; "Logon-User Name")
                {
                    ApplicationArea = All;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        RetailFormCode.RegisterLogonnameAutofill(Rec);
                    end;
                }
                field("Register Type"; "Register Type")
                {
                    ApplicationArea = All;
                }
                field("Shop id"; "Shop id")
                {
                    ApplicationArea = All;
                }
                field("Sales Ticket Print Output"; "Sales Ticket Print Output")
                {
                    ApplicationArea = All;
                }
                field("Sales Ticket Email Output"; "Sales Ticket Email Output")
                {
                    ApplicationArea = All;
                }
                field("Primary Payment Type"; "Primary Payment Type")
                {
                    ApplicationArea = All;
                }
                field("Return Payment Type"; "Return Payment Type")
                {
                    ApplicationArea = All;
                }
                field("Connected To Server"; "Connected To Server")
                {
                    ApplicationArea = All;
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                }
            }
            group(Accessories)
            {
                Caption = 'Accessories';
                group(Control6150627)
                {
                    ShowCaption = false;
                    field("Customer Display"; "Customer Display")
                    {
                        ApplicationArea = All;
                        Importance = Promoted;

                        trigger OnValidate()
                        begin
                            if "Customer Display" then begin
                                FieldDisplay1 := true;
                                FieldDisplay2 := true;
                                FieldDisplayMetode := true;
                            end else begin
                                FieldDisplay1 := false;
                                FieldDisplay2 := false;
                                FieldDisplayMetode := false;
                            end;
                        end;
                    }
                    field("Display 1"; "Display 1")
                    {
                        ApplicationArea = All;
                        Editable = FieldDisplay1;
                    }
                    field("Display 2"; "Display 2")
                    {
                        ApplicationArea = All;
                        Editable = FieldDisplay2;
                    }
                }
            }
            group(Contact)
            {
                Caption = 'Contact';
                group(Control6150661)
                {
                    ShowCaption = false;
                    field(Name; Name)
                    {
                        ApplicationArea = All;
                        Importance = Promoted;
                    }
                    field("Name 2"; "Name 2")
                    {
                        ApplicationArea = All;
                    }
                    field(Address; Address)
                    {
                        ApplicationArea = All;
                    }
                    field("Post Code"; "Post Code")
                    {
                        ApplicationArea = All;
                    }
                    field(City; City)
                    {
                        ApplicationArea = All;
                    }
                    field("Phone No."; "Phone No.")
                    {
                        ApplicationArea = All;
                    }
                    field("E-mail"; "E-mail")
                    {
                        ApplicationArea = All;
                    }
                    field(Website; Website)
                    {
                        ApplicationArea = All;
                    }
                }
                group(Control6150669)
                {
                    ShowCaption = false;
                    field("Bank Name"; "Bank Name")
                    {
                        ApplicationArea = All;
                    }
                    field("Bank Registration No."; "Bank Registration No.")
                    {
                        ApplicationArea = All;
                    }
                    field("Bank Account No."; "Bank Account No.")
                    {
                        ApplicationArea = All;
                    }
                    field("Automatic Payment No."; "Automatic Payment No.")
                    {
                        ApplicationArea = All;
                    }
                    field("VAT No."; "VAT No.")
                    {
                        ApplicationArea = All;
                    }
                }
            }
            group(Receipt)
            {
                Caption = 'Receipt';
                field("Sales Ticket Line Text off"; "Sales Ticket Line Text off")
                {
                    ApplicationArea = All;
                    Importance = Promoted;

                    trigger OnAssistEdit()
                    var
                        RetailComment: Record "NPR Retail Comment";
                    begin
                        RetailComment.SetRange("Table ID", DATABASE::"NPR Register");
                        RetailComment.SetRange("No.", "Register No.");
                        RetailComment.SetRange(Integer, 300);
                        PAGE.RunModal(PAGE::"NPR Retail Comments", RetailComment)
                    end;
                }
                field("Sales Ticket Line Text1"; "Sales Ticket Line Text1")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                }
                field("Sales Ticket Line Text2"; "Sales Ticket Line Text2")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                }
                field("Sales Ticket Line Text3"; "Sales Ticket Line Text3")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                }
                field("Sales Ticket Line Text4"; "Sales Ticket Line Text4")
                {
                    ApplicationArea = All;
                }
                field("Sales Ticket Line Text5"; "Sales Ticket Line Text5")
                {
                    ApplicationArea = All;
                }
                field("Sales Ticket Line Text6"; "Sales Ticket Line Text6")
                {
                    ApplicationArea = All;
                }
                field("Sales Ticket Line Text7"; "Sales Ticket Line Text7")
                {
                    ApplicationArea = All;
                }
                field(BonText; BonText)
                {
                    ApplicationArea = All;
                    Caption = 'Show Ticket Line Text';
                    Width = 2500;
                }
            }
            group("Touch Screen")
            {
                Caption = 'Touch Screen';
                group(Control6150695)
                {
                    ShowCaption = false;
                    field("Touch Screen Login autopopup"; "Touch Screen Login autopopup")
                    {
                        ApplicationArea = All;
                    }
                    field("Touch Screen Extended info"; "Touch Screen Extended info")
                    {
                        ApplicationArea = All;
                    }
                    field("Touch Screen Customerclub"; "Touch Screen Customerclub")
                    {
                        ApplicationArea = All;
                    }
                    field("Touch Screen Login Type"; "Touch Screen Login Type")
                    {
                        ApplicationArea = All;
                    }
                    field("Skip Infobox Update in Sale"; "Skip Infobox Update in Sale")
                    {
                        ApplicationArea = All;
                    }
                }
            }
            group(Posting)
            {
                Caption = 'Posting';
                group(Control6150705)
                {
                    ShowCaption = false;
                    field(Account; '')
                    {
                        ApplicationArea = All;
                        Caption = 'Account';
                        ShowCaption = false;
                        Style = Strong;
                        StyleExpr = TRUE;
                    }
                    field(Control6150706; Account)
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                    }
                    field("Gift Voucher Account"; "Gift Voucher Account")
                    {
                        ApplicationArea = All;
                    }
                    field("Gift Voucher Discount Account"; "Gift Voucher Discount Account")
                    {
                        ApplicationArea = All;
                    }
                    field("City Gift Voucher Account"; "City Gift Voucher Account")
                    {
                        ApplicationArea = All;
                    }
                    field("City Gift Voucher Discount"; "City Gift Voucher Discount")
                    {
                        ApplicationArea = All;
                    }
                    field("Credit Voucher Account"; "Credit Voucher Account")
                    {
                        ApplicationArea = All;
                    }
                    field("Difference Account"; "Difference Account")
                    {
                        ApplicationArea = All;
                    }
                    field("Difference Account - Neg."; "Difference Account - Neg.")
                    {
                        ApplicationArea = All;
                    }
                    field("Register Change Account"; "Register Change Account")
                    {
                        ApplicationArea = All;
                    }
                    field("Location Code"; "Location Code")
                    {
                        ApplicationArea = All;
                    }
                    field("VAT Customer No."; "VAT Customer No.")
                    {
                        ApplicationArea = All;
                    }
                }
                group(Control6150716)
                {
                    ShowCaption = false;
                    field("End of Day Balancing"; '')
                    {
                        ApplicationArea = All;
                        Caption = 'End of Day Balancing';
                        ShowCaption = false;
                        Style = Strong;
                        StyleExpr = TRUE;
                    }
                    field("Balancing every"; "Balancing every")
                    {
                        ApplicationArea = All;
                    }
                    field("Balanced Type"; "Balanced Type")
                    {
                        ApplicationArea = All;
                        Importance = Promoted;
                    }
                    field("Balance Account"; "Balance Account")
                    {
                        ApplicationArea = All;
                        Importance = Promoted;
                    }
                    field("End of day - Exchange Amount"; "End of day - Exchange Amount")
                    {
                        ApplicationArea = All;
                    }
                }
            }
            group(Sale)
            {
                Caption = 'Sale';
                field("Customer Price Group"; "Customer Price Group")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                }
                field("Customer Disc. Group"; "Customer Disc. Group")
                {
                    ApplicationArea = All;
                }
                field("Customer No. auto debit sale"; "Customer No. auto debit sale")
                {
                    ApplicationArea = All;
                }
                field("Exchange Label Exchange Period"; "Exchange Label Exchange Period")
                {
                    ApplicationArea = All;
                }
                field("Lock Register To Salesperson"; "Lock Register To Salesperson")
                {
                    ApplicationArea = All;
                }
                field("Use Sales Statistics"; "Use Sales Statistics")
                {
                    ApplicationArea = All;
                }
                field("Active Event No."; "Active Event No.")
                {
                    ApplicationArea = All;
                }
            }
            group(Integration)
            {
                Caption = 'Integration';
                group(mPos)
                {
                    Caption = 'mPos';
                    field("mPos Payment Type"; "mPos Payment Type")
                    {
                        ApplicationArea = All;
                    }
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(RegisterActions)
            {
                Caption = 'Register';
                action(Autofill)
                {
                    Caption = 'Autofill';
                    Image = Interaction;
                    Promoted = true;
                    PromotedIsBig = true;
                    ApplicationArea=All;

                    trigger OnAction()
                    begin
                        RetailFormCode.RegisterLogonnameAutofill(Rec);
                    end;
                }
                action("Create new register")
                {
                    Caption = 'Create New Register';
                    Image = Register;
                    ApplicationArea=All;

                    trigger OnAction()
                    begin
                        CreateNewRegister;
                    end;
                }
            }
            group(Functions)
            {
                Caption = 'Functions';
                action("User Setup")
                {
                    Caption = 'User Setup';
                    Image = UserSetup;
                    RunObject = Page "User Setup";
                    RunPageLink = "NPR Backoffice Register No." = FIELD("Register No.");
                    ApplicationArea=All;
                }
                action(Skuffer)
                {
                    Caption = 'Drawers';
                    Image = "Action";
                    RunObject = Page "NPR Alternative Number";
                    RunPageLink = Code = FIELD("Register No."),
                                  Type = CONST(Register);
                    RunPageView = SORTING(Type, Code, "Alt. No.");
                    ApplicationArea=All;
                }
                action("Show Registers Periods")
                {
                    Caption = 'Show Register Periods';
                    Image = Register;
                    RunObject = Page "NPR Register Period List";
                    RunPageLink = "Register No." = FIELD("Register No.");
                    ApplicationArea=All;
                }
                action("Set Saldo Inicial ")
                {
                    Caption = 'Set Saldo Inicial';
                    Image = AmountByPeriod;
                    ApplicationArea=All;

                    trigger OnAction()
                    var
                        InputDialog: Page "NPR Input Dialog";
                        Amount: Decimal;
                        ID: Integer;
                    begin
                        InputDialog.LookupMode := true;
                        InputDialog.SetInput(1, Amount, Text10600007);
                        repeat
                            if InputDialog.RunModal = ACTION::LookupOK then
                                ID := InputDialog.InputDecimal(1, Amount);
                        //-NPR4.10
                        //UNTIL (Amount > 0) OR (ID = 0);
                        until (Amount >= 0) or (ID = 0);
                        //+NPR4.10

                        "Opening Cash" := Amount;
                        "Closing Cash" := Amount;
                        Modify;
                    end;
                }
            }
            group(Dimensions)
            {
                Caption = 'Dimensions';
                action("Default Dimensions")
                {
                    Caption = 'Dimensions';
                    Image = DefaultDimension;
                    Visible = false;
                    ApplicationArea=All;

                    trigger OnAction()
                    begin
                        DimsAreDiscontinuedOnRegister;  //NPR5.53 [371956]
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        if "Customer Display" then begin
            FieldDisplay1 := true;
            FieldDisplay2 := true;
            //-NPR5.29 [241549]
            //  FieldDisplayMetode:=TRUE;
            //+NPR5.29 [241549]
        end else begin
            FieldDisplay1 := false;
            FieldDisplay2 := false;
            //-NPR5.29 [241549]
            //  FieldDisplayMetode:=FALSE;
            //+NPR5.29 [241549]
        end;

        //-NPR5.29 [241549]
        // IF (("Customer Display" AND (DisplayWriteMethod=DisplayWriteMethod::"2")) OR ("Customer Display" AND (DisplayWriteMethod=DisplayWriteMethod::"3")))=TRUE THEN
        //  FieldDisplayPort:=TRUE
        // ELSE
        //  FieldDisplayPort:=FALSE;
        //
        // IF ("Customer Display" AND (DisplayWriteMethod=DisplayWriteMethod::"1"))=TRUE THEN
        //  FieldDisplaytxtPath:=TRUE
        // ELSE
        //  FieldDisplaytxtPath:=FALSE;
        //
        //
        // IF "Label Printer"=TRUE THEN BEGIN
        //  FieldlabelPrinterType:=TRUE;
        //  FieldLabelPrinterPort :=   TRUE;
        //  FieldlabelType :=  TRUE;
        //  FieldlabelwriteMethode:=TRUE;
        // END ELSE BEGIN
        //  FieldlabelPrinterType:=FALSE;
        //  FieldLabelPrinterPort :=  FALSE;
        //  FieldlabelType :=FALSE;
        //  FieldlabelwriteMethode:=FALSE;
        //
        // END;
        //
        // IF ("Label Printer" AND ((LabelWriteMethode=LabelWriteMethode::"0") OR (LabelWriteMethode=LabelWriteMethode::"2"))) =TRUE THEN BEGIN
        //  FieldlabelPrinterType:=TRUE;
        //  FieldLabelPrinterPort :=   TRUE;
        //  FieldLabelSize:=TRUE;
        //  FieldDisplaytxtPath:=TRUE;
        //  FieldlabelType:=TRUE;
        // END ELSE BEGIN
        //  FieldlabelPrinterType:=FALSE;
        //  FieldLabelPrinterPort :=  FALSE;
        //  FieldLabelSize:=FALSE;
        //  FieldDisplaytxtPath:=FALSE;
        //  FieldlabelType:=FALSE;
        // END;
        //+NPR5.29 [241549]

        UpdateBonTxt;
    end;

    trigger OnClosePage()
    begin
        //-NPR5.36
        //IF ("Gen. Business Posting Group" = '') OR ("VAT Gen. Business Post.Gr" = '') THEN
        //  MESSAGE(WarningGroup);
        //+NPR5.36
    end;

    trigger OnModifyRecord(): Boolean
    begin
        UpdateBonTxt;
    end;

    trigger OnOpenPage()
    begin
        //CurrForm.DimBtn.VISIBLE(ShowDimCtrls);

        //CurrForm.DisplayMetode.EDITABLE(FALSE);
        //CurrForm."Display Port".EDITABLE(FALSE);
        //CurrForm.DisplayTxtPath.EDITABLE(FALSE);
        FieldDisplayMetode := false;
        FieldDisplayPort := false;
        FieldDisplayTxtPath := false;
    end;

    var
        RetailSetup: Record "NPR Retail Setup";
        RetailFormCode: Codeunit "NPR Retail Form Code";
        BonText: Text[1024];
        Text10600005: Label '[more...]';
        Text10600007: Label 'Saldo Inicial';
        [InDataSet]
        FieldDisplay1: Boolean;
        [InDataSet]
        FieldDisplay2: Boolean;
        [InDataSet]
        FieldDisplayMetode: Boolean;
        [InDataSet]
        FieldDisplayPort: Boolean;
        [InDataSet]
        FieldDisplayTxtPath: Boolean;

    procedure UpdateBonTxt()
    var
        RetailComment: Record "NPR Retail Comment";
        i: Integer;
    begin
        Clear(BonText);
        case "Sales Ticket Line Text off" of
            "Sales Ticket Line Text off"::Comment:
                begin
                    RetailComment.SetRange("Table ID", 6014401);
                    RetailComment.SetRange("No.", "Register No.");
                    RetailComment.SetRange(Integer, 300);
                    RetailComment.SetRange("Hide on printout", false);
                    i := 1;
                    if RetailComment.Find('-') then begin
                        repeat
                            BonText += RetailComment.Comment + ' \';
                            i += 1;
                            if (i = 18) then
                                BonText += StrSubstNo(Text10600005, 17, RetailComment.Count);
                        until ((RetailComment.Next = 0) or (i >= 18));
                    end;
                end;
            "Sales Ticket Line Text off"::"NP Config":
                begin
                    RetailSetup.Get;
                    BonText += RetailSetup."Sales Ticket Line Text1";
                    if (RetailSetup."Sales Ticket Line Text2" <> '') then
                        BonText += '\';
                    BonText += RetailSetup."Sales Ticket Line Text2";
                    if (RetailSetup."Sales Ticket Line Text3" <> '') then
                        BonText += '\';
                    BonText += RetailSetup."Sales Ticket Line Text3";
                    if (RetailSetup."Sales Ticket Line Text4" <> '') then
                        BonText += '\';
                    BonText += RetailSetup."Sales Ticket Line Text4";
                    if (RetailSetup."Sales Ticket Line Text5" <> '') then
                        BonText += '\';
                    BonText += RetailSetup."Sales Ticket Line Text5";
                    if (RetailSetup."Sales Ticket Line Text6" <> '') then
                        BonText += '\';
                    BonText += RetailSetup."Sales Ticket Line Text6";
                    if (RetailSetup."Sales Ticket Line Text7" <> '') then
                        BonText += '\';
                    BonText += RetailSetup."Sales Ticket Line Text7";
                end;
            "Sales Ticket Line Text off"::Register:
                begin
                    BonText += "Sales Ticket Line Text1";
                    if ("Sales Ticket Line Text2" <> '') then
                        BonText += '\';
                    BonText += "Sales Ticket Line Text2";
                    if ("Sales Ticket Line Text3" <> '') then
                        BonText += '\';
                    BonText += "Sales Ticket Line Text3";
                    if ("Sales Ticket Line Text4" <> '') then
                        BonText += '\';
                    BonText += "Sales Ticket Line Text4";
                    if ("Sales Ticket Line Text5" <> '') then
                        BonText += '\';
                    BonText += "Sales Ticket Line Text5";
                    if ("Sales Ticket Line Text6" <> '') then
                        BonText += '\';
                    BonText += "Sales Ticket Line Text6";
                    if ("Sales Ticket Line Text7" <> '') then
                        BonText += '\';
                    BonText += "Sales Ticket Line Text7";
                    if ("Sales Ticket Line Text8" <> '') then
                        BonText += '\';
                    BonText += "Sales Ticket Line Text8";
                    if ("Sales Ticket Line Text9" <> '') then
                        BonText += '\';
                    BonText += "Sales Ticket Line Text9";
                end;
        end;
    end;
}

