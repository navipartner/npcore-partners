page 6014406 "NPR Register Card"
{
    UsageCategory = None;
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
                field("Register No."; Rec."Register No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Logon-User Name"; Rec."Logon-User Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Logon-User Name field';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        RetailFormCode.RegisterLogonnameAutofill(Rec);
                    end;
                }
                field("Shop id"; Rec."Shop id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shop id field';
                }
                field("Sales Ticket Print Output"; Rec."Sales Ticket Print Output")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Ticket Print-Out field';
                }
                field("Sales Ticket Email Output"; Rec."Sales Ticket Email Output")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Ticket Email Output field';
                }
                field("Primary Payment Type"; Rec."Primary Payment Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Primary Payment Type field';
                }
                field("Return Payment Type"; Rec."Return Payment Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Return Payment Type field';
                }
                field("Connected To Server"; Rec."Connected To Server")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Connected to Server field';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Status field';
                }
            }
            group(Accessories)
            {
                Caption = 'Accessories';
                group(Control6150627)
                {
                    ShowCaption = false;
                    field("Customer Display"; Rec."Customer Display")
                    {
                        ApplicationArea = All;
                        Importance = Promoted;
                        ToolTip = 'Specifies the value of the Customer Display field';

                        trigger OnValidate()
                        begin
                            if Rec."Customer Display" then begin
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
                    field("Display 1"; Rec."Display 1")
                    {
                        ApplicationArea = All;
                        Editable = FieldDisplay1;
                        ToolTip = 'Specifies the value of the Display 1 field';
                    }
                    field("Display 2"; Rec."Display 2")
                    {
                        ApplicationArea = All;
                        Editable = FieldDisplay2;
                        ToolTip = 'Specifies the value of the Display 2 field';
                    }
                }
            }
            group(Contact)
            {
                Caption = 'Contact';
                group(Control6150669)
                {
                    ShowCaption = false;
                    field("Bank Name"; Rec."Bank Name")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Bank Name field';
                    }
                    field("Bank Registration No."; Rec."Bank Registration No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Bank Registration No. field';
                    }
                    field("Bank Account No."; Rec."Bank Account No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Bank Account No. field';
                    }
                    field("Automatic Payment No."; Rec."Automatic Payment No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Automatic Payment No. field';
                    }
                    field("VAT No."; Rec."VAT No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the VAT No. field';
                    }
                }
            }
            group(Receipt)
            {
                Caption = 'Receipt';
                field("Sales Ticket Line Text off"; Rec."Sales Ticket Line Text off")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies the value of the Sales Ticket Line Text off field';

                    trigger OnAssistEdit()
                    var
                        RetailComment: Record "NPR Retail Comment";
                    begin
                        RetailComment.SetRange("Table ID", DATABASE::"NPR Register");
                        RetailComment.SetRange("No.", Rec."Register No.");
                        RetailComment.SetRange(Integer, 300);
                        PAGE.RunModal(PAGE::"NPR Retail Comments", RetailComment)
                    end;
                }
                field("Sales Ticket Line Text1"; Rec."Sales Ticket Line Text1")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies the value of the Sales Ticket Line Text1 field';
                }
                field("Sales Ticket Line Text2"; Rec."Sales Ticket Line Text2")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies the value of the Sales Ticket Line Text2 field';
                }
                field("Sales Ticket Line Text3"; Rec."Sales Ticket Line Text3")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies the value of the Sales Ticket Line Text3 field';
                }
                field("Sales Ticket Line Text4"; Rec."Sales Ticket Line Text4")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Ticket Line Text 4 field';
                }
                field("Sales Ticket Line Text5"; Rec."Sales Ticket Line Text5")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Ticket Line Text 5 field';
                }
                field("Sales Ticket Line Text6"; Rec."Sales Ticket Line Text6")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Ticket Line Text6 field';
                }
                field("Sales Ticket Line Text7"; Rec."Sales Ticket Line Text7")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Ticket Line Text7 field';
                }
                field(BonText; BonText)
                {
                    ApplicationArea = All;
                    Caption = 'Show Ticket Line Text';
                    Width = 2500;
                    ToolTip = 'Specifies the value of the Show Ticket Line Text field';
                }
            }
            group("Touch Screen")
            {
                Caption = 'Touch Screen';
                group(Control6150695)
                {
                    ShowCaption = false;
                    field("Touch Screen Login autopopup"; Rec."Touch Screen Login autopopup")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Login - Auto popup field';
                    }
                    field("Touch Screen Extended info"; Rec."Touch Screen Extended info")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Touch Screen Auto Unwrap If Single field';
                    }
                    field("Touch Screen Customerclub"; Rec."Touch Screen Customerclub")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Touch Screen Customerclub field';
                    }
                    field("Touch Screen Login Type"; Rec."Touch Screen Login Type")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Login Type field';
                    }
                    field("Skip Infobox Update in Sale"; Rec."Skip Infobox Update in Sale")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Skip Infobox Update in Sale field';
                    }
                }
            }
            group(Posting)
            {
                Caption = 'Posting';
                group(Control6150705)
                {
                    ShowCaption = false;
                    field(Account; Rec.Account)
                    {
                        Style = Strong;
                        StyleExpr = TRUE;
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Account field';
                    }
                    field("Gift Voucher Account"; Rec."Gift Voucher Account")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Gift Voucher Account field';
                    }
                    field("Gift Voucher Discount Account"; Rec."Gift Voucher Discount Account")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Gift Voucher Discount Account field';
                    }
                    field("City Gift Voucher Account"; Rec."City Gift Voucher Account")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the City gift voucher account field';
                    }
                    field("City Gift Voucher Discount"; Rec."City Gift Voucher Discount")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the City Gift Voucher Discount field';
                    }
                    field("Credit Voucher Account"; Rec."Credit Voucher Account")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Credit Voucher Account field';
                    }
                    field("Difference Account"; Rec."Difference Account")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Difference Account field';
                    }
                    field("Difference Account - Neg."; Rec."Difference Account - Neg.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Difference Account - Neg. field';
                    }
                    field("Register Change Account"; Rec."Register Change Account")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Register Change Account field';
                    }
                    field("Location Code"; Rec."Location Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Location Code field';
                    }
                    field("VAT Customer No."; Rec."VAT Customer No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the VAT Customer No. field';
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
                        ToolTip = 'Specifies the value of the End of Day Balancing field';
                    }
                    field("Balancing every"; Rec."Balancing every")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Registerstatement field';
                    }
                    field("Balanced Type"; Rec."Balanced Type")
                    {
                        ApplicationArea = All;
                        Importance = Promoted;
                        ToolTip = 'Specifies the value of the Balanced Type field';
                    }
                    field("Balance Account"; Rec."Balance Account")
                    {
                        ApplicationArea = All;
                        Importance = Promoted;
                        ToolTip = 'Specifies the value of the Balance Account field';
                    }
                    field("End of day - Exchange Amount"; Rec."End of day - Exchange Amount")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Exchange Amount field';
                    }
                }
            }
            group(Sale)
            {
                Caption = 'Sale';
                field("Customer Price Group"; Rec."Customer Price Group")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies the value of the Item price group field';
                }
                field("Customer Disc. Group"; Rec."Customer Disc. Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer Disc. Group field';
                }
                field("Customer No. auto debit sale"; Rec."Customer No. auto debit sale")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ask for customer field';
                }
                field("Exchange Label Exchange Period"; Rec."Exchange Label Exchange Period")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Exchange Label Exchange Period field';
                }
                field("Lock Register To Salesperson"; Rec."Lock Register To Salesperson")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Lock Register To Salesperson field';
                }
                field("Use Sales Statistics"; Rec."Use Sales Statistics")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Use Sales Statistics field';
                }
                field("Active Event No."; Rec."Active Event No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Active Event No. field';
                }
            }
            group(Integration)
            {
                Caption = 'Integration';
                group(mPos)
                {
                    Caption = 'mPos';
                    field("mPos Payment Type"; Rec."mPos Payment Type")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the mPos Payment Type field';
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
                    PromotedOnly = true;
                    PromotedIsBig = true;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Autofill action';

                    trigger OnAction()
                    begin
                        RetailFormCode.RegisterLogonnameAutofill(Rec);
                    end;
                }
                action("Create new register")
                {
                    Caption = 'Create New Register';
                    Image = Register;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Create New Register action';

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
                    ApplicationArea = All;
                    ToolTip = 'Executes the User Setup action';
                }
                action(Skuffer)
                {
                    Caption = 'Drawers';
                    Image = "Action";
                    RunObject = Page "NPR Alternative Number";
                    RunPageLink = Code = FIELD("Register No."),
                                  Type = CONST(Register);
                    RunPageView = SORTING(Type, Code, "Alt. No.");
                    ApplicationArea = All;
                    ToolTip = 'Executes the Drawers action';
                }
                action("Show Registers Periods")
                {
                    Caption = 'Show Register Periods';
                    Image = Register;
                    RunObject = Page "NPR Register Period List";
                    RunPageLink = "Register No." = FIELD("Register No.");
                    ApplicationArea = All;
                    ToolTip = 'Executes the Show Register Periods action';
                }
                action("Set Saldo Inicial ")
                {
                    Caption = 'Set Saldo Inicial';
                    Image = AmountByPeriod;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Set Saldo Inicial action';

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
                        until (Amount >= 0) or (ID = 0);

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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Dimensions action';

                    trigger OnAction()
                    begin
                        Rec.DimsAreDiscontinuedOnRegister();
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        if Rec."Customer Display" then begin
            FieldDisplay1 := true;
            FieldDisplay2 := true;
        end else begin
            FieldDisplay1 := false;
            FieldDisplay2 := false;
        end;

        UpdateBonTxt();
    end;

    trigger OnModifyRecord(): Boolean
    begin
        UpdateBonTxt();
    end;

    trigger OnOpenPage()
    begin
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
        case Rec."Sales Ticket Line Text off" of
            Rec."Sales Ticket Line Text off"::Comment:
                begin
                    RetailComment.SetRange("Table ID", 6014401);
                    RetailComment.SetRange("No.", Rec."Register No.");
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
            Rec."Sales Ticket Line Text off"::"NP Config":
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
            Rec."Sales Ticket Line Text off"::Register:
                begin
                    BonText += Rec."Sales Ticket Line Text1";
                    if ("Sales Ticket Line Text2" <> '') then
                        BonText += '\';
                    BonText += Rec."Sales Ticket Line Text2";
                    if ("Sales Ticket Line Text3" <> '') then
                        BonText += '\';
                    BonText += Rec."Sales Ticket Line Text3";
                    if ("Sales Ticket Line Text4" <> '') then
                        BonText += '\';
                    BonText += Rec."Sales Ticket Line Text4";
                    if ("Sales Ticket Line Text5" <> '') then
                        BonText += '\';
                    BonText += Rec."Sales Ticket Line Text5";
                    if ("Sales Ticket Line Text6" <> '') then
                        BonText += '\';
                    BonText += Rec."Sales Ticket Line Text6";
                    if ("Sales Ticket Line Text7" <> '') then
                        BonText += '\';
                    BonText += Rec."Sales Ticket Line Text7";
                    if ("Sales Ticket Line Text8" <> '') then
                        BonText += '\';
                    BonText += Rec."Sales Ticket Line Text8";
                    if ("Sales Ticket Line Text9" <> '') then
                        BonText += '\';
                    BonText += Rec."Sales Ticket Line Text9";
                end;
        end;
    end;
}

