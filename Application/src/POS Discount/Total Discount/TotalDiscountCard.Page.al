page 6150909 "NPR Total Discount Card"
{
    Caption = 'Total Discount Card';
    ContextSensitiveHelpPage = 'docs/retail/discounts/how-to/total_discount/';
    Extensible = False;
    PageType = Card;
    SourceTable = "NPR Total Discount Header";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                grid(Control6150664)
                {
                    GridLayout = Rows;
                    ShowCaption = false;
                    group(Control1)
                    {
                        ShowCaption = false;
                        group(Control6014423)
                        {
                            ShowCaption = false;
                            field("Code"; Rec.Code)
                            {
                                ApplicationArea = NPRRetail;
                                ToolTip = 'Defines the Code of the Total Discount. The Code is generated from the No. Series specified in the Discount Priority Page.';
                                trigger OnAssistEdit()
                                var
                                    NPRTotalDiscHeaderUtils: Codeunit "NPR Total Disc. Header Utils";
                                begin
                                    if NPRTotalDiscHeaderUtils.AssitedEdit(xRec) then
                                        CurrPage.Update();
                                end;
                            }
                            field(Description; Rec.Description)
                            {
                                Importance = Promoted;
                                ApplicationArea = NPRRetail;
                                ToolTip = 'Defines the Description of Total Discount. The Description is going to appear as a title on the benefit items dialog.';
                            }

                        }
                    }

                }

                group(Control2)
                {
                    ShowCaption = false;
                    group(Control6014420)
                    {
                        ShowCaption = false;

                        field(Status; Rec.Status)
                        {
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Defines the Status of the Total Discount. Pending - implies that the discount is still in development and is not active. Active - implies that the discount is operational. Closed - implies that the discount is no longer active.';
                        }
                        field(Priority; Rec.Priority)
                        {
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Defines the Priority of the Total Discount. The Total Discount with the highest priority is applied to the POS Sale. The highest priority is the lowest integer number - 1 is higher priority than 2.';
                        }
                    }
                }
            }
            group("Benefits Calculation")
            {
                Caption = 'Benefits Calculation';
                grid(Control6150644)
                {
                    GridLayout = Rows;
                    ShowCaption = false;
                    group(Control6014223)
                    {
                        ShowCaption = false;
                        field("Step Amount Calculation"; Rec."Step Amount Calculation")
                        {
                            Importance = Promoted;
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Defines how the step amount is going to be calcualted.';
                        }
                        field("Discount Application"; Rec."Discount Application")
                        {
                            Importance = Promoted;
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Defines how the benefits are going to be applied to the POS sale.';
                        }
                    }
                }
            }
            group(Conditions)
            {
                Caption = 'Conditions';
                group(Control6150614)
                {
                    ShowCaption = false;
                    field("Starting date"; Rec."Starting date")
                    {
                        Importance = Promoted;
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Defines the Starting Date of the Total Discount. The discount is going to be applied to POS Sales made on the same day or the days after the specified date.';
                    }
                    field("Ending date"; Rec."Ending date")
                    {
                        Importance = Promoted;
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Defines the Ending Date of the Total Discount. The discount is going to be applied to POS Sales made on the same day or on the days before the specified date.';
                    }
                    field("Starting time"; Rec."Starting time")
                    {
                        Visible = false;
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Defines the Starting Time of the Total Discount. The discount is going to be applied to POS Sales made after the specified Staring Time.';
                    }
                    field("Ending time"; Rec."Ending time")
                    {
                        Visible = false;
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Defines the Ending Time of the Total Discount. The discount is going to be applied to POS Sales made before the specified Ending Time.';
                    }

                    field("Customer Disc. Group Filter"; Rec."Customer Disc. Group Filter")
                    {
                        Visible = true;
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Defines the Customer Disc. Group Filter of the Total Discount. The disocunt is going to be applied to POS Sales that are part of the specified filter.';
                    }
                }
            }

            part(Control6014425; "NPR Total Disc. Time Interv.")
            {
                SubPageLink = "Total Discount Code" = FIELD(Code);
                ApplicationArea = NPRRetail;
            }

            part(SubForm; "NPR Total Discount Subform")
            {
                Caption = 'Total Discount Filters';
                ShowFilter = false;
                SubPageLink = "Total Discount Code" = FIELD(Code);
                UpdatePropagation = Both;
                ApplicationArea = NPRRetail;
            }

            part(Benefits; "NPR Total Disc. Benefit List")
            {
                ShowFilter = false;
                SubPageLink = "Total Discount Code" = FIELD(Code);
                SubPageView = sorting("Step Amount");
                UpdatePropagation = Both;
                ApplicationArea = NPRRetail;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(Dimensions)
            {
                Caption = 'Dimensions';
                Image = Dimensions;
                RunObject = Page "Default Dimensions";
                RunPageLink = "Table ID" = CONST(6059874),
                              "No." = FIELD(Code);
                ShortCutKey = 'Shift+Ctrl+D';
                ToolTip = 'Open the Default Dimensions List';
                ApplicationArea = NPRRetail;
                Visible = false;
            }
        }
        area(processing)
        {
            group("&Function")
            {
                Caption = '&Function';
                group("Total Discount")
                {
                    Caption = 'Total Discount';
                    Image = Administration;
                    action("Transfer Item")
                    {
                        Caption = 'Transfer Item';
                        Image = TransferToLines;
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Transfers the selected items to the Total Discount.';
                        trigger OnAction()
                        var
                            NPRTotalDiscHeaderUtils: Codeunit "NPR Total Disc. Header Utils";
                        begin
                            NPRTotalDiscHeaderUtils.SelectItemAndTransferToTotalDiscount(Rec);
                        end;
                    }
                    action("Transfer Item Category")
                    {
                        Caption = 'Transfer Item Category';
                        Image = TransferToLines;
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Transfers all items from a specific category to the Total Discount.';
                        trigger OnAction()
                        var
                            NPRTotalDiscHeaderUtils: Codeunit "NPR Total Disc. Header Utils";
                        begin
                            NPRTotalDiscHeaderUtils.SelectCategoryAndTransferToTotalDiscount(Rec);
                        end;
                    }
                    action("Transfer Vendor")
                    {
                        Caption = 'Transfer Vendor';
                        Image = TransferToLines;
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Transfers all items from a specific vendor to the Total Discount.';
                        trigger OnAction()
                        var
                            NPRTotalDiscHeaderUtils: Codeunit "NPR Total Disc. Header Utils";
                        begin
                            NPRTotalDiscHeaderUtils.SelectVendorAndTransferToTotalDiscount(Rec);
                        end;
                    }
                }

                separator(Separator1160330020)
                {
                }
                action("Copy Total Discount Lines")
                {
                    Caption = 'Copy Total Discount Lines';
                    Image = CopyDocument;
                    Enabled = Rec.Code <> '';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Copies the Total Discount Lines from an existing Total Discount.';
                    trigger OnAction()
                    var
                        NPRTotalDiscHeaderUtils: Codeunit "NPR Total Disc. Header Utils";
                    begin
                        NPRTotalDiscHeaderUtils.CopyTotalDiscountLinesToCurrent(Rec);
                    end;
                }
            }
        }
    }
}
