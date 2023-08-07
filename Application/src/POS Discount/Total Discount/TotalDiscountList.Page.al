page 6150908 "NPR Total Discount List"
{
   ApplicationArea = NPRRetail;
    Caption = 'Total Discount List';
    CardPageID = "NPR Total Discount Card";
    ContextSensitiveHelpPage = 'docs/retail/discounts/reference/total_discounts/';
    Editable = true;
    Extensible = False;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "NPR Total Discount Header";
    SourceTableView = SORTING("Starting date", "Starting time", "Ending date", "Ending time");
    UsageCategory = Lists;


    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Code"; Rec.Code)
                {

                    Caption = 'Code';
                    Editable = false;
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Defines the Code of the Total Discount. The Code is generated from the No. Series specified in the Discount Priority Page.';
                }
                field(Status; Rec.Status)
                {

                    Editable = false;
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Defines the Status of the Total Discount. Pending - implies that the discount is still in development and is not active. Active - implies that the discount is operational. Closed - implies that the discount is no longer active.';
                }
                field(Description; Rec.Description)
                {

                    Editable = false;
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Defines the Description of Total Discount. The Description is going to appear as a title on the benefit items dialog.';
                }
                field("Starting date"; Rec."Starting date")
                {

                    Editable = false;
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Defines the Starting Date of the Total Discount. The discount is going to be applied to POS Sales made on the same day or the days after the specified date.';
                }
                field("Starting time"; Rec."Starting time")
                {

                    Editable = false;
                    Visible = false;
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Defines the Starting Time of the Total Discount. The discount is going to be applied to POS Sales made after the specified Staring Time.';
                }
                field("Ending date"; Rec."Ending date")
                {

                    Editable = false;
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Defines the Ending Date of the Total Discount. The discount is going to be applied to POS Sales made on the same day or on the days before the specified date.';
                }
                field("Ending time"; Rec."Ending time")
                {

                    Editable = false;
                    Visible = false;
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Defines the Ending Time of the Total Discount. The discount is going to be applied to POS Sales made before the specified Ending Time.';
                }
                field(Priority; Rec.Priority)
                {

                    Editable = false;
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Defines the Priority of the Total Discount. The Total Discount with the highest priority is applied to the POS Sale. The highest priority is the lowest integer number - 1 is higher priority than 2.';
                }
                field("Creation Date"; Rec."Creation Date")
                {

                    Editable = false;
                    Visible = false;
                    ApplicationArea = NPRRetail;
                    ToolTip = 'The date when the Total Discount was created.';
                }
                field("Last Date Modified"; Rec."Last Date Modified")
                {

                    Editable = false;
                    Visible = false;
                    ApplicationArea = NPRRetail;
                    ToolTip = 'The date of the last modification of the Total Discount.';
                }
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
                ApplicationArea = NPRRetail;
                ToolTip = 'Executes the Dimensions action.';
            }
        }
    }
}

