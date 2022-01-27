page 6060150 "NPR Event Card"
{
    Extensible = False;
    Caption = 'Event Card';
    PageType = Card;
    UsageCategory = Administration;
    PromotedActionCategories = 'New,Process,Report,Prices,Tickets';
    RefreshOnActivate = true;
    SourceTable = Job;
    SourceTableView = WHERE("NPR Event" = CONST(true));
    ApplicationArea = NPRRetail;
    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; Rec."No.")
                {

                    Editable = GlobalEditable;
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';
                    ApplicationArea = NPRRetail;

                    trigger OnAssistEdit()
                    begin
                        if Rec.AssistEdit(xRec) then
                            CurrPage.Update();
                    end;
                }
                field("Event Status"; Rec."NPR Event Status")
                {

                    Editable = GlobalEditable;
                    ToolTip = 'Specifies a status for the current event. You can change the status for the event as it progresses. Final calculations can be made on completed events.';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    Editable = GlobalEditable;
                    ToolTip = 'Specifies a short description of the event.';
                    ApplicationArea = NPRRetail;
                }
                field("Event Customer No."; Rec."NPR Event Customer No.")
                {

                    Editable = GlobalEditable;
                    ToolTip = 'Specifies the number of the customer who pays for the event.';
                    ApplicationArea = NPRRetail;
                }
                field("Bill-to Contact No."; Rec."Bill-to Contact No.")
                {

                    Editable = GlobalEditable;
                    ToolTip = 'Specifies the number of the contact person at the customer''s billing address.';
                    ApplicationArea = NPRRetail;
                }
                field("Bill-to Name"; Rec."Bill-to Name")
                {

                    Editable = GlobalEditable;
                    Importance = Promoted;
                    ToolTip = 'Specifies the name of the customer who pays for the event.';
                    ApplicationArea = NPRRetail;
                }
                field("Bill-to Address"; Rec."Bill-to Address")
                {

                    Editable = GlobalEditable;
                    ToolTip = 'Specifies the address of the customer to whom you will send the invoice.';
                    ApplicationArea = NPRRetail;
                }
                field("Bill-to Address 2"; Rec."Bill-to Address 2")
                {

                    Editable = GlobalEditable;
                    ToolTip = 'Specifies an additional line of the address.';
                    ApplicationArea = NPRRetail;
                }
                field("Bill-to Post Code"; Rec."Bill-to Post Code")
                {

                    Editable = GlobalEditable;
                    ToolTip = 'Specifies the postal code of the customer who pays for the event.';
                    ApplicationArea = NPRRetail;
                }
                field("Bill-to City"; Rec."Bill-to City")
                {

                    Editable = GlobalEditable;
                    ToolTip = 'Specifies the city of the address.';
                    ApplicationArea = NPRRetail;
                }
                field("Bill-to Country/Region Code"; Rec."Bill-to Country/Region Code")
                {

                    Editable = GlobalEditable;
                    Importance = Additional;
                    ToolTip = 'Specifies the country/region code of the customer''s billing address.';
                    ApplicationArea = NPRRetail;
                }
                field("Bill-to Contact"; Rec."Bill-to Contact")
                {

                    Editable = GlobalEditable;
                    ToolTip = 'Specifies the name of the contact person at the customer who pays for the event.';
                    ApplicationArea = NPRRetail;
                }
                field("Bill-to E-Mail"; Rec."NPR Bill-to E-Mail")
                {

                    Editable = GlobalEditable;
                    ToolTip = 'Specifies the e-mail of the customer who pays for the event.';
                    ApplicationArea = NPRRetail;
                }
                field("Search Description"; Rec."Search Description")
                {

                    Editable = GlobalEditable;
                    ToolTip = 'Specifies an additional description of the event for searching purposes.';
                    ApplicationArea = NPRRetail;
                }
                field("Person Responsible"; Rec."Person Responsible")
                {

                    Editable = GlobalEditable;
                    Importance = Promoted;
                    ToolTip = 'Specifies the person at your company who is responsible for the event.';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        Rec.CalcFields("NPR Person Responsible Name");
                    end;
                }
                field("Person Responsible Name"; Rec."NPR Person Responsible Name")
                {

                    ToolTip = 'Specifies the name of the person at your company who is responsible for the event.';
                    ApplicationArea = NPRRetail;
                }
                field(Blocked; Rec.Blocked)
                {

                    Editable = GlobalEditable;
                    ToolTip = 'Specifies that the related record is blocked from being posted in transactions, for example a customer that is declared insolvent or an item that is placed in quarantine.';
                    ApplicationArea = NPRRetail;
                }
                field("Organizer E-Mail"; Rec."NPR Organizer E-Mail")
                {

                    Editable = GlobalEditable;
                    Importance = Additional;
                    ToolTip = 'Specifies an e-mail of the organization or a person that will hold exchange items for this event. Exchange items are e-mails, appointments and meeting requests.';
                    ApplicationArea = NPRRetail;
                }
                field("Calendar Item Status"; Rec."NPR Calendar Item Status")
                {

                    Editable = GlobalEditable;
                    ToolTip = 'Shows information about last action taken towards exchange calendar and suggest whether an update to the calendar is needed.';
                    ApplicationArea = NPRRetail;
                }
                field("Job Posting Group"; Rec."Job Posting Group")
                {

                    Editable = GlobalEditable;
                    ToolTip = 'Specifies the posting group that links transactions made for the event with the appropriate general ledger accounts according to the general posting setup.';
                    ApplicationArea = NPRRetail;
                }
                field("Total Amount"; Rec."NPR Total Amount")
                {

                    ToolTip = 'Shows the sum of Line Amount (LCY) on the event lines.';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    var
                        JobPlanningLine: Record "Job Planning Line";
                    begin
                        JobPlanningLine.SetRange("Job No.", Rec."No.");
                        PAGE.Run(PAGE::"NPR Event Planning Lines", JobPlanningLine, JobPlanningLine."Line Amount (LCY)");
                    end;
                }
                field("Est. Total Amount Incl. VAT"; Rec."NPR Est. Total Amt. Incl. VAT")
                {

                    ToolTip = 'Shows the sum of Est. Line Amt. Incl. VAT (LCY) on the event lines.';
                    ApplicationArea = NPRRetail;
                }
                field("Language Code"; Rec."Language Code")
                {

                    Editable = GlobalEditable;
                    Importance = Additional;
                    ToolTip = 'Specifies the language for this event. Related with extended text funcionality for resources, items and g/l accounts on event lines.';
                    ApplicationArea = NPRRetail;
                }
                field(Locked; Rec."NPR Locked")
                {

                    ToolTip = 'Specifies if the event is locked to prevent accidental changes on it. Please note that this will not block you from deleting the event';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        SetGlobalEditable();
                    end;
                }
                field("Admission Code"; Rec."NPR Admission Code")
                {

                    ToolTip = 'Specifies Admission Code when integrating with ticket module. Setting a value in this field will filter pages Ticket Admissions, Admission Schedule Lines and Admission Schedule Entry accessed through actions Ticket Admissions, Admission Schedule Lines and Admission Schedule Entry.';
                    ApplicationArea = NPRRetail;
                }
                group("Additional Information")
                {
                    Caption = 'Additional Information';
                    field("Last Date Modified"; Rec."Last Date Modified")
                    {

                        ToolTip = 'Specifies when the event card was last modified.';
                        ApplicationArea = NPRRetail;
                    }
                    field("Calendar Item ID"; Rec."NPR Calendar Item ID" <> '')
                    {

                        Caption = 'Appointment Exists';
                        Editable = false;
                        ToolTip = 'Shows if an exchange appointment has been created for the event. It is automatically updated when using actions like Send to Calendar… and Remove from Calendar…';
                        ApplicationArea = NPRRetail;
                    }
                    field("Mail Item Status"; Rec."NPR Mail Item Status")
                    {

                        Editable = false;
                        ToolTip = 'Shows information about last e-mail sent through actions under Send E-Mail to. It is automatically updated through those actions.';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
            group("Promoted Attributes 1")
            {
                Caption = 'Promoted Attributes 1';
                Editable = GlobalEditable;
                Visible = AttributeVisibleSet1;
                grid(Control6014503)
                {
                    ShowCaption = false;
                    group(Control6014495)
                    {
                        ShowCaption = false;
                        field(AttributeDescriptionSet1; EventAttributeTemplateName[1])
                        {

                            Caption = 'Description';
                            Enabled = false;
                            ShowCaption = false;
                            Style = Strong;
                            StyleExpr = TRUE;
                            ToolTip = 'Specifies the name of first promoted attribute template. System finds templates by sorting all the attribute templates per Template Name that are marked as Promoted.';
                            ApplicationArea = NPRRetail;
                        }
                        field(RowDescription1Set1; RowDescription[1] [1])
                        {

                            Enabled = false;
                            ShowCaption = false;
                            ToolTip = 'Specifies the name of the first promoted row value on the row template set for current attribute template. System finds row values based on order you have defined rows that are marked as Promoted.';
                            ApplicationArea = NPRRetail;
                        }
                        field(RowDescription2Set1; RowDescription[2] [1])
                        {

                            Enabled = false;
                            ShowCaption = false;
                            ToolTip = 'Specifies the name of the second promoted row value on the row template set for current attribute template. System finds row values based on order you have defined rows that are marked as Promoted.';
                            ApplicationArea = NPRRetail;
                        }
                        field(RowDescription3Set1; RowDescription[3] [1])
                        {

                            Enabled = false;
                            ShowCaption = false;
                            ToolTip = 'Specifies the name of the third promoted row value on the row template set for current attribute template. System finds row values based on order you have defined rows that are marked as Promoted.';
                            ApplicationArea = NPRRetail;
                        }
                        field(RowDescription4Set1; RowDescription[4] [1])
                        {

                            Enabled = false;
                            ShowCaption = false;
                            ToolTip = 'Specifies the name of the fourth promoted row value on the row template set for current attribute template. System finds row values based on order you have defined rows that are marked as Promoted.';
                            ApplicationArea = NPRRetail;
                        }
                        field(RowDescription5Set1; RowDescription[5] [1])
                        {

                            Enabled = false;
                            ShowCaption = false;
                            ToolTip = 'Specifies the name of the fifth promoted row value on the row template set for current attribute template. System finds row values based on order you have defined rows that are marked as Promoted.';
                            ApplicationArea = NPRRetail;
                        }
                    }
                    group(Control6014512)
                    {
                        ShowCaption = false;
                        field(ColumnCaption1Set1; ColumnCaption[1] [1])
                        {

                            Enabled = false;
                            ShowCaption = false;
                            Style = Strong;
                            StyleExpr = TRUE;
                            ToolTip = 'Specifies the name of the first promoted column value on the column template set for current attribute template. System finds column values based on order you have defined columns that are marked as Promoted.';
                            ApplicationArea = NPRRetail;
                        }
                        field(AttributeValue1_1Set1; AttributeValue[1] [1] [1])
                        {

                            Enabled = RowEditable1Set1 AND ColumnEditable1Set1;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the AttributeValue[1] [1] [1] field';
                            ApplicationArea = NPRRetail;

                            trigger OnValidate()
                            begin
                                AttributeValueOnValidate(1, 1, 1);
                            end;
                        }
                        field(AttributeValue2_1Set1; AttributeValue[2] [1] [1])
                        {

                            Enabled = RowEditable2Set1 AND ColumnEditable1Set1;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the AttributeValue[2] [1] [1] field';
                            ApplicationArea = NPRRetail;

                            trigger OnValidate()
                            begin
                                AttributeValueOnValidate(2, 1, 1);
                            end;
                        }
                        field(AttributeValue3_1Set1; AttributeValue[3] [1] [1])
                        {

                            Enabled = RowEditable3Set1 AND ColumnEditable1Set1;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the AttributeValue[3] [1] [1] field';
                            ApplicationArea = NPRRetail;

                            trigger OnValidate()
                            begin
                                AttributeValueOnValidate(3, 1, 1);
                            end;
                        }
                        field(AttributeValue4_1Set1; AttributeValue[4] [1] [1])
                        {

                            Enabled = RowEditable4Set1 AND ColumnEditable1Set1;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the AttributeValue[4] [1] [1] field';
                            ApplicationArea = NPRRetail;

                            trigger OnValidate()
                            begin
                                AttributeValueOnValidate(4, 1, 1);
                            end;
                        }
                        field(AttributeValue5_1Set1; AttributeValue[5] [1] [1])
                        {

                            Enabled = RowEditable5Set1 AND ColumnEditable1Set1;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the AttributeValue[5] [1] [1] field';
                            ApplicationArea = NPRRetail;

                            trigger OnValidate()
                            begin
                                AttributeValueOnValidate(5, 1, 1);
                            end;
                        }
                    }
                    group(Control6014488)
                    {
                        ShowCaption = false;
                        field(ColumnCaption2Set1; ColumnCaption[2] [1])
                        {

                            Enabled = false;
                            ShowCaption = false;
                            Style = Strong;
                            StyleExpr = TRUE;
                            ToolTip = 'Specifies the name of the second promoted column value on the column template set for current attribute template. System finds column values based on order you have defined columns that are marked as Promoted.';
                            ApplicationArea = NPRRetail;
                        }
                        field(AttributeValue1_2Set1; AttributeValue[1] [2] [1])
                        {

                            Enabled = RowEditable1Set1 AND ColumnEditable2Set1;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the AttributeValue[1] [2] [1] field';
                            ApplicationArea = NPRRetail;

                            trigger OnValidate()
                            begin
                                AttributeValueOnValidate(1, 2, 1);
                            end;
                        }
                        field(AttributeValue2_2Set1; AttributeValue[2] [2] [1])
                        {

                            Enabled = RowEditable2Set1 AND ColumnEditable2Set1;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the AttributeValue[2] [2] [1] field';
                            ApplicationArea = NPRRetail;

                            trigger OnValidate()
                            begin
                                AttributeValueOnValidate(2, 2, 1);
                            end;
                        }
                        field(AttributeValue3_2Set1; AttributeValue[3] [2] [1])
                        {

                            Enabled = RowEditable3Set1 AND ColumnEditable2Set1;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the AttributeValue[3] [2] [1] field';
                            ApplicationArea = NPRRetail;

                            trigger OnValidate()
                            begin
                                AttributeValueOnValidate(3, 2, 1);
                            end;
                        }
                        field(AttributeValue4_2Set1; AttributeValue[4] [2] [1])
                        {

                            Enabled = RowEditable4Set1 AND ColumnEditable2Set1;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the AttributeValue[4] [2] [1] field';
                            ApplicationArea = NPRRetail;

                            trigger OnValidate()
                            begin
                                AttributeValueOnValidate(4, 2, 1);
                            end;
                        }
                        field(AttributeValue5_2Set1; AttributeValue[5] [2] [1])
                        {

                            Enabled = RowEditable5Set1 AND ColumnEditable2Set1;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the AttributeValue[5] [2] [1] field';
                            ApplicationArea = NPRRetail;

                            trigger OnValidate()
                            begin
                                AttributeValueOnValidate(5, 2, 1);
                            end;
                        }
                    }
                    group(Control6014481)
                    {
                        ShowCaption = false;
                        field(ColumnCaption3Set1; ColumnCaption[3] [1])
                        {

                            Enabled = false;
                            ShowCaption = false;
                            Style = Strong;
                            StyleExpr = TRUE;
                            ToolTip = 'Specifies the name of the third promoted column value on the column template set for current attribute template. System finds column values based on order you have defined columns that are marked as Promoted.';
                            ApplicationArea = NPRRetail;
                        }
                        field(AttributeValue1_3Set1; AttributeValue[1] [3] [1])
                        {

                            Enabled = RowEditable1Set1 AND ColumnEditable3Set1;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the AttributeValue[1] [3] [1] field';
                            ApplicationArea = NPRRetail;

                            trigger OnValidate()
                            begin
                                AttributeValueOnValidate(1, 3, 1);
                            end;
                        }
                        field(AttributeValue2_3Set1; AttributeValue[2] [3] [1])
                        {

                            Enabled = RowEditable2Set1 AND ColumnEditable3Set1;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the AttributeValue[2] [3] [1] field';
                            ApplicationArea = NPRRetail;

                            trigger OnValidate()
                            begin
                                AttributeValueOnValidate(2, 3, 1);
                            end;
                        }
                        field(AttributeValue3_3Set1; AttributeValue[3] [3] [1])
                        {

                            Enabled = RowEditable3Set1 AND ColumnEditable3Set1;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the AttributeValue[3] [3] [1] field';
                            ApplicationArea = NPRRetail;

                            trigger OnValidate()
                            begin
                                AttributeValueOnValidate(3, 3, 1);
                            end;
                        }
                        field(AttributeValue4_3Set1; AttributeValue[4] [3] [1])
                        {

                            Enabled = RowEditable4Set1 AND ColumnEditable3Set1;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the AttributeValue[4] [3] [1] field';
                            ApplicationArea = NPRRetail;

                            trigger OnValidate()
                            begin
                                AttributeValueOnValidate(4, 3, 1);
                            end;
                        }
                        field(AttributeValue5_3Set1; AttributeValue[5] [3] [1])
                        {

                            Enabled = RowEditable5Set1 AND ColumnEditable3Set1;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the AttributeValue[5] [3] [1] field';
                            ApplicationArea = NPRRetail;

                            trigger OnValidate()
                            begin
                                AttributeValueOnValidate(5, 3, 1);
                            end;
                        }
                    }
                    group(Control6014502)
                    {
                        ShowCaption = false;
                        field(ColumnCaption4Set1; ColumnCaption[4] [1])
                        {

                            Enabled = false;
                            ShowCaption = false;
                            Style = Strong;
                            StyleExpr = TRUE;
                            ToolTip = 'Specifies the name of the fourth promoted column value on the column template set for current attribute template. System finds column values based on order you have defined columns that are marked as Promoted.';
                            ApplicationArea = NPRRetail;
                        }
                        field(AttributeValue1_4Set1; AttributeValue[1] [4] [1])
                        {

                            Enabled = RowEditable1Set1 AND ColumnEditable4Set1;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the AttributeValue[1] [4] [1] field';
                            ApplicationArea = NPRRetail;

                            trigger OnValidate()
                            begin
                                AttributeValueOnValidate(1, 4, 1);
                            end;
                        }
                        field(AttributeValue2_4Set1; AttributeValue[2] [4] [1])
                        {

                            Enabled = RowEditable2Set1 AND ColumnEditable4Set1;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the AttributeValue[2] [4] [1] field';
                            ApplicationArea = NPRRetail;

                            trigger OnValidate()
                            begin
                                AttributeValueOnValidate(2, 4, 1);
                            end;
                        }
                        field(AttributeValue3_4Set1; AttributeValue[3] [4] [1])
                        {

                            Enabled = RowEditable3Set1 AND ColumnEditable4Set1;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the AttributeValue[3] [4] [1] field';
                            ApplicationArea = NPRRetail;

                            trigger OnValidate()
                            begin
                                AttributeValueOnValidate(3, 4, 1);
                            end;
                        }
                        field(AttributeValue4_4Set1; AttributeValue[4] [4] [1])
                        {

                            Enabled = RowEditable4Set1 AND ColumnEditable4Set1;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the AttributeValue[4] [4] [1] field';
                            ApplicationArea = NPRRetail;

                            trigger OnValidate()
                            begin
                                AttributeValueOnValidate(4, 4, 1);
                            end;
                        }
                        field(AttributeValue5_4Set1; AttributeValue[5] [4] [1])
                        {

                            Enabled = RowEditable5Set1 AND ColumnEditable4Set1;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the AttributeValue[5] [4] [1] field';
                            ApplicationArea = NPRRetail;

                            trigger OnValidate()
                            begin
                                AttributeValueOnValidate(5, 4, 1);
                            end;
                        }
                    }
                    group(Control6014474)
                    {
                        ShowCaption = false;
                        field(ColumnCaption5Set1; ColumnCaption[5] [1])
                        {

                            Enabled = false;
                            ShowCaption = false;
                            Style = Strong;
                            StyleExpr = TRUE;
                            ToolTip = 'Specifies the name of the fifth promoted column value on the column template set for current attribute template. System finds column values based on order you have defined columns that are marked as Promoted.';
                            ApplicationArea = NPRRetail;
                        }
                        field(AttributeValue1_5Set1; AttributeValue[1] [5] [1])
                        {

                            Enabled = RowEditable1Set1 AND ColumnEditable5Set1;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the AttributeValue[1] [5] [1] field';
                            ApplicationArea = NPRRetail;

                            trigger OnValidate()
                            begin
                                AttributeValueOnValidate(1, 5, 1);
                            end;
                        }
                        field(AttributeValue2_5Set1; AttributeValue[2] [5] [1])
                        {

                            Enabled = RowEditable2Set1 AND ColumnEditable5Set1;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the AttributeValue[2] [5] [1] field';
                            ApplicationArea = NPRRetail;

                            trigger OnValidate()
                            begin
                                AttributeValueOnValidate(2, 5, 1);
                            end;
                        }
                        field(AttributeValue3_5Set1; AttributeValue[3] [5] [1])
                        {

                            Enabled = RowEditable3Set1 AND ColumnEditable5Set1;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the AttributeValue[3] [5] [1] field';
                            ApplicationArea = NPRRetail;

                            trigger OnValidate()
                            begin
                                AttributeValueOnValidate(3, 5, 1);
                            end;
                        }
                        field(AttributeValue4_5Set1; AttributeValue[4] [5] [1])
                        {

                            Enabled = RowEditable4Set1 AND ColumnEditable5Set1;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the AttributeValue[4] [5] [1] field';
                            ApplicationArea = NPRRetail;

                            trigger OnValidate()
                            begin
                                AttributeValueOnValidate(4, 5, 1);
                            end;
                        }
                        field(AttributeValue5_5Set1; AttributeValue[5] [5] [1])
                        {

                            Enabled = RowEditable5Set1 AND ColumnEditable5Set1;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the AttributeValue[5] [5] [1] field';
                            ApplicationArea = NPRRetail;

                            trigger OnValidate()
                            begin
                                AttributeValueOnValidate(5, 5, 1);
                            end;
                        }
                    }
                }
            }
            group("Promoted Attributes 2")
            {
                Caption = 'Promoted Attributes 2';
                Editable = GlobalEditable;
                Visible = AttributeVisibleSet2;
                grid(Control6014513)
                {
                    ShowCaption = false;
                    group(Control6014505)
                    {
                        ShowCaption = false;
                        field(AttributeDescriptionSet2; EventAttributeTemplateName[2])
                        {

                            Caption = 'Description';
                            Enabled = false;
                            ShowCaption = false;
                            Style = Strong;
                            StyleExpr = TRUE;
                            ToolTip = 'Specifies the name of second promoted attribute template. System finds templates by sorting all the attribute templates per Template Name that are marked as Promoted.';
                            ApplicationArea = NPRRetail;
                        }
                        field(RowDescription1Set2; RowDescription[1] [2])
                        {

                            Enabled = false;
                            ShowCaption = false;
                            ToolTip = 'Specifies the name of the first promoted row value on the row template set for current attribute template. System finds row values based on order you have defined rows that are marked as Promoted.';
                            ApplicationArea = NPRRetail;
                        }
                        field(RowDescription2Set2; RowDescription[2] [2])
                        {

                            Enabled = false;
                            ShowCaption = false;
                            ToolTip = 'Specifies the name of the second promoted row value on the row template set for current attribute template. System finds row values based on order you have defined rows that are marked as Promoted.';
                            ApplicationArea = NPRRetail;
                        }
                        field(RowDescription3Set2; RowDescription[3] [2])
                        {

                            Enabled = false;
                            ShowCaption = false;
                            ToolTip = 'Specifies the name of the third promoted row value on the row template set for current attribute template. System finds row values based on order you have defined rows that are marked as Promoted.';
                            ApplicationArea = NPRRetail;
                        }
                        field(RowDescription4Set2; RowDescription[4] [2])
                        {

                            Enabled = false;
                            ShowCaption = false;
                            ToolTip = 'Specifies the name of the fourth promoted row value on the row template set for current attribute template. System finds row values based on order you have defined rows that are marked as Promoted.';
                            ApplicationArea = NPRRetail;
                        }
                        field(RowDescription5Set2; RowDescription[5] [2])
                        {

                            Enabled = false;
                            ShowCaption = false;
                            ToolTip = 'Specifies the name of the fifth promoted row value on the row template set for current attribute template. System finds row values based on order you have defined rows that are marked as Promoted.';
                            ApplicationArea = NPRRetail;
                        }
                    }
                    group(Control6014458)
                    {
                        ShowCaption = false;
                        field(ColumnCaption1Set2; ColumnCaption[1] [2])
                        {

                            Enabled = false;
                            ShowCaption = false;
                            Style = Strong;
                            StyleExpr = TRUE;
                            ToolTip = 'Specifies the name of the first promoted column value on the column template set for current attribute template. System finds column values based on order you have defined columns that are marked as Promoted.';
                            ApplicationArea = NPRRetail;
                        }
                        field(AttributeValue1_1Set2; AttributeValue[1] [1] [2])
                        {

                            Enabled = RowEditable1Set2 AND ColumnEditable1Set2;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the AttributeValue[1] [1] [2] field';
                            ApplicationArea = NPRRetail;

                            trigger OnValidate()
                            begin
                                AttributeValueOnValidate(1, 1, 2);
                            end;
                        }
                        field(AttributeValue2_1Set2; AttributeValue[2] [1] [2])
                        {

                            Enabled = RowEditable2Set2 AND ColumnEditable1Set2;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the AttributeValue[2] [1] [2] field';
                            ApplicationArea = NPRRetail;

                            trigger OnValidate()
                            begin
                                AttributeValueOnValidate(2, 1, 2);
                            end;
                        }
                        field(AttributeValue3_1Set2; AttributeValue[3] [1] [2])
                        {

                            Enabled = RowEditable3Set2 AND ColumnEditable1Set2;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the AttributeValue[3] [1] [2] field';
                            ApplicationArea = NPRRetail;

                            trigger OnValidate()
                            begin
                                AttributeValueOnValidate(3, 1, 2);
                            end;
                        }
                        field(AttributeValue4_1Set2; AttributeValue[4] [1] [2])
                        {

                            Enabled = RowEditable4Set2 AND ColumnEditable1Set2;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the AttributeValue[4] [1] [2] field';
                            ApplicationArea = NPRRetail;

                            trigger OnValidate()
                            begin
                                AttributeValueOnValidate(4, 1, 2);
                            end;
                        }
                        field(AttributeValue5_1Set2; AttributeValue[5] [1] [2])
                        {

                            Enabled = RowEditable5Set2 AND ColumnEditable1Set2;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the AttributeValue[5] [1] [2] field';
                            ApplicationArea = NPRRetail;

                            trigger OnValidate()
                            begin
                                AttributeValueOnValidate(5, 1, 2);
                            end;
                        }
                    }
                    group(Control6014451)
                    {
                        ShowCaption = false;
                        field(ColumnCaption2Set2; ColumnCaption[2] [2])
                        {

                            Enabled = false;
                            ShowCaption = false;
                            Style = Strong;
                            StyleExpr = TRUE;
                            ToolTip = 'Specifies the name of the second promoted column value on the column template set for current attribute template. System finds column values based on order you have defined columns that are marked as Promoted.';
                            ApplicationArea = NPRRetail;
                        }
                        field(AttributeValue1_2Set2; AttributeValue[1] [2] [2])
                        {

                            Enabled = RowEditable1Set2 AND ColumnEditable2Set2;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the AttributeValue[1] [2] [2] field';
                            ApplicationArea = NPRRetail;

                            trigger OnValidate()
                            begin
                                AttributeValueOnValidate(1, 2, 2);
                            end;
                        }
                        field(AttributeValue2_2Set2; AttributeValue[2] [2] [2])
                        {

                            Enabled = RowEditable2Set2 AND ColumnEditable2Set2;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the AttributeValue[2] [2] [2] field';
                            ApplicationArea = NPRRetail;

                            trigger OnValidate()
                            begin
                                AttributeValueOnValidate(2, 2, 2);
                            end;
                        }
                        field(AttributeValue3_2Set2; AttributeValue[3] [2] [2])
                        {

                            Enabled = RowEditable3Set2 AND ColumnEditable2Set2;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the AttributeValue[3] [2] [2] field';
                            ApplicationArea = NPRRetail;

                            trigger OnValidate()
                            begin
                                AttributeValueOnValidate(3, 2, 2);
                            end;
                        }
                        field(AttributeValue4_2Set2; AttributeValue[4] [2] [2])
                        {

                            Enabled = RowEditable4Set2 AND ColumnEditable2Set2;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the AttributeValue[4] [2] [2] field';
                            ApplicationArea = NPRRetail;

                            trigger OnValidate()
                            begin
                                AttributeValueOnValidate(4, 2, 2);
                            end;
                        }
                        field(AttributeValue5_2Set2; AttributeValue[5] [2] [2])
                        {

                            Enabled = RowEditable5Set2 AND ColumnEditable2Set2;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the AttributeValue[5] [2] [2] field';
                            ApplicationArea = NPRRetail;

                            trigger OnValidate()
                            begin
                                AttributeValueOnValidate(5, 2, 2);
                            end;
                        }
                    }
                    group(Control6014444)
                    {
                        ShowCaption = false;
                        field(ColumnCaption3Set2; ColumnCaption[3] [2])
                        {

                            Enabled = false;
                            ShowCaption = false;
                            Style = Strong;
                            StyleExpr = TRUE;
                            ToolTip = 'Specifies the name of the third promoted column value on the column template set for current attribute template. System finds column values based on order you have defined columns that are marked as Promoted.';
                            ApplicationArea = NPRRetail;
                        }
                        field(AttributeValue1_3Set2; AttributeValue[1] [3] [2])
                        {

                            Enabled = RowEditable1Set2 AND ColumnEditable3Set2;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the AttributeValue[1] [3] [2] field';
                            ApplicationArea = NPRRetail;

                            trigger OnValidate()
                            begin
                                AttributeValueOnValidate(1, 3, 2);
                            end;
                        }
                        field(AttributeValue2_3Set2; AttributeValue[2] [3] [2])
                        {

                            Enabled = RowEditable2Set2 AND ColumnEditable3Set2;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the AttributeValue[2] [3] [2] field';
                            ApplicationArea = NPRRetail;

                            trigger OnValidate()
                            begin
                                AttributeValueOnValidate(2, 3, 2);
                            end;
                        }
                        field(AttributeValue3_3Set2; AttributeValue[3] [3] [2])
                        {

                            Enabled = RowEditable3Set2 AND ColumnEditable3Set2;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the AttributeValue[3] [3] [2] field';
                            ApplicationArea = NPRRetail;

                            trigger OnValidate()
                            begin
                                AttributeValueOnValidate(3, 3, 2);
                            end;
                        }
                        field(AttributeValue4_3Set2; AttributeValue[4] [3] [2])
                        {

                            Enabled = RowEditable4Set2 AND ColumnEditable3Set2;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the AttributeValue[4] [3] [2] field';
                            ApplicationArea = NPRRetail;

                            trigger OnValidate()
                            begin
                                AttributeValueOnValidate(4, 3, 2);
                            end;
                        }
                        field(AttributeValue5_3Set2; AttributeValue[5] [3] [2])
                        {

                            Enabled = RowEditable5Set2 AND ColumnEditable3Set2;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the AttributeValue[5] [3] [2] field';
                            ApplicationArea = NPRRetail;

                            trigger OnValidate()
                            begin
                                AttributeValueOnValidate(5, 3, 2);
                            end;
                        }
                    }
                    group(Control6014437)
                    {
                        ShowCaption = false;
                        field(ColumnCaption4Set2; ColumnCaption[4] [2])
                        {

                            Enabled = false;
                            ShowCaption = false;
                            Style = Strong;
                            StyleExpr = TRUE;
                            ToolTip = 'Specifies the name of the fourth promoted column value on the column template set for current attribute template. System finds column values based on order you have defined columns that are marked as Promoted.';
                            ApplicationArea = NPRRetail;
                        }
                        field(AttributeValue1_4Set2; AttributeValue[1] [4] [2])
                        {

                            Enabled = RowEditable1Set2 AND ColumnEditable4Set2;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the AttributeValue[1] [4] [2] field';
                            ApplicationArea = NPRRetail;

                            trigger OnValidate()
                            begin
                                AttributeValueOnValidate(1, 4, 2);
                            end;
                        }
                        field(AttributeValue2_4Set2; AttributeValue[2] [4] [2])
                        {

                            Enabled = RowEditable2Set2 AND ColumnEditable4Set2;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the AttributeValue[2] [4] [2] field';
                            ApplicationArea = NPRRetail;

                            trigger OnValidate()
                            begin
                                AttributeValueOnValidate(2, 4, 2);
                            end;
                        }
                        field(AttributeValue3_4Set2; AttributeValue[3] [4] [2])
                        {

                            Enabled = RowEditable3Set2 AND ColumnEditable4Set2;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the AttributeValue[3] [4] [2] field';
                            ApplicationArea = NPRRetail;

                            trigger OnValidate()
                            begin
                                AttributeValueOnValidate(3, 4, 2);
                            end;
                        }
                        field(AttributeValue4_4Set2; AttributeValue[4] [4] [2])
                        {

                            Enabled = RowEditable4Set2 AND ColumnEditable4Set2;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the AttributeValue[4] [4] [2] field';
                            ApplicationArea = NPRRetail;

                            trigger OnValidate()
                            begin
                                AttributeValueOnValidate(4, 4, 2);
                            end;
                        }
                        field(AttributeValue5_4Set2; AttributeValue[5] [4] [2])
                        {

                            Enabled = RowEditable5Set2 AND ColumnEditable4Set2;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the AttributeValue[5] [4] [2] field';
                            ApplicationArea = NPRRetail;

                            trigger OnValidate()
                            begin
                                AttributeValueOnValidate(5, 4, 2);
                            end;
                        }
                    }
                    group(Control6014430)
                    {
                        ShowCaption = false;
                        field(ColumnCaption5Set2; ColumnCaption[5] [2])
                        {

                            Enabled = false;
                            ShowCaption = false;
                            Style = Strong;
                            StyleExpr = TRUE;
                            ToolTip = 'Specifies the name of the fifth promoted column value on the column template set for current attribute template. System finds column values based on order you have defined columns that are marked as Promoted.';
                            ApplicationArea = NPRRetail;
                        }
                        field(AttributeValue1_5Set2; AttributeValue[1] [5] [2])
                        {

                            Enabled = RowEditable1Set2 AND ColumnEditable5Set2;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the AttributeValue[1] [5] [2] field';
                            ApplicationArea = NPRRetail;

                            trigger OnValidate()
                            begin
                                AttributeValueOnValidate(1, 5, 2);
                            end;
                        }
                        field(AttributeValue2_5Set2; AttributeValue[2] [5] [2])
                        {

                            Enabled = RowEditable2Set2 AND ColumnEditable5Set2;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the AttributeValue[2] [5] [2] field';
                            ApplicationArea = NPRRetail;

                            trigger OnValidate()
                            begin
                                AttributeValueOnValidate(2, 5, 2);
                            end;
                        }
                        field(AttributeValue3_5Set2; AttributeValue[3] [5] [2])
                        {

                            Enabled = RowEditable3Set2 AND ColumnEditable5Set2;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the AttributeValue[3] [5] [2] field';
                            ApplicationArea = NPRRetail;

                            trigger OnValidate()
                            begin
                                AttributeValueOnValidate(3, 5, 2);
                            end;
                        }
                        field(AttributeValue4_5Set2; AttributeValue[4] [5] [2])
                        {

                            Enabled = RowEditable4Set2 AND ColumnEditable5Set2;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the AttributeValue[4] [5] [2] field';
                            ApplicationArea = NPRRetail;

                            trigger OnValidate()
                            begin
                                AttributeValueOnValidate(4, 5, 2);
                            end;
                        }
                        field(AttributeValue5_5Set2; AttributeValue[5] [5] [2])
                        {

                            Enabled = RowEditable5Set2 AND ColumnEditable5Set2;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the AttributeValue[5] [5] [2] field';
                            ApplicationArea = NPRRetail;

                            trigger OnValidate()
                            begin
                                AttributeValueOnValidate(5, 5, 2);
                            end;
                        }
                    }
                }
            }
            group("Duration")
            {
                Caption = 'Duration';
                Editable = GlobalEditable;
                field("Preparation Period"; Rec."NPR Preparation Period")
                {

                    ToolTip = 'Specifies the length of the period it takes for organizer to preapre everything for the event. Used as a check when specifying starting date for the event.';
                    ApplicationArea = NPRRetail;
                }
                field("Starting Date"; Rec."Starting Date")
                {

                    Importance = Promoted;
                    ToolTip = 'Specifies the date on which the event actually starts.';
                    ApplicationArea = NPRRetail;
                }
                field("Starting Time"; Rec."NPR Starting Time")
                {

                    ToolTip = 'Specifies the time at which the event actually starts.';
                    ApplicationArea = NPRRetail;
                }
                field("Ending Date"; Rec."Ending Date")
                {

                    Importance = Promoted;
                    ToolTip = 'Specifies the date on which the event is expected to be completed.';
                    ApplicationArea = NPRRetail;
                }
                field("Ending Time"; Rec."NPR Ending Time")
                {

                    ToolTip = 'Specifies the time at which the event is expected to be completed.';
                    ApplicationArea = NPRRetail;
                }
                field("Creation Date"; Rec."Creation Date")
                {

                    ToolTip = 'Specifies the date on which you set up the event.';
                    ApplicationArea = NPRRetail;
                }
            }
            part(EventPlanningLinesSubpage; "NPR Event Plan. Lines Sub.")
            {
                Editable = GlobalEditable;
                SubPageLink = "Job No." = FIELD("No."),
                              "NPR Group Source Line No." = CONST(0);
                ApplicationArea = NPRRetail;

            }
            part(Control6014530; "NPR Event Group.Plan. Line Sub")
            {
                Editable = GlobalEditable;
                SubPageLink = "Job No." = FIELD("No."),
                              "NPR Group Line" = CONST(true);
                Visible = GroupedLineGroupVisible;
                ApplicationArea = NPRRetail;

            }
            group("Foreign Trade")
            {
                Caption = 'Foreign Trade';
                Editable = GlobalEditable;
                field("Currency Code"; Rec."Currency Code")
                {

                    Editable = CurrencyCodeEditable;
                    Importance = Promoted;
                    ToolTip = 'Specifies the currency code for the event. By default, the currency code is empty. If you enter a foreign currency code, it results in the event being planned and invoiced in that currency.';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        CurrencyCheck();
                    end;
                }
                field("Invoice Currency Code"; Rec."Invoice Currency Code")
                {

                    Editable = InvoiceCurrencyCodeEditable;
                    ToolTip = 'Specifies the currency code you want to apply when creating invoices for an event. By default, the invoice currency code for an event is based on what currency code is defined on the customer card.';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        CurrencyCheck();
                    end;
                }
            }
        }
        area(factboxes)
        {
            part(Control6014404; "NPR Event Comment Sheet")
            {
                SubPageLink = "Table Name" = CONST(Job), "No." = FIELD("No.");
                ApplicationArea = NPRRetail;

            }
            part(Control1902018507; "Customer Statistics FactBox")
            {
                SubPageLink = "No." = FIELD("Bill-to Customer No.");
                Visible = false;
                ApplicationArea = NPRRetail;

            }
            part(Control1902136407; "Job No. of Prices FactBox")
            {
                SubPageLink = "No." = FIELD("No."),
                              "Resource Filter" = FIELD("Resource Filter"),
                              "Posting Date Filter" = FIELD("Posting Date Filter"),
                              "Resource Gr. Filter" = FIELD("Resource Gr. Filter"),
                              "Planning Date Filter" = FIELD("Planning Date Filter");
                Visible = true;
                ApplicationArea = NPRRetail;

            }
            part(Control1905650007; "Job WIP/Recognition FactBox")
            {
                SubPageLink = "No." = FIELD("No."),
                              "Resource Filter" = FIELD("Resource Filter"),
                              "Posting Date Filter" = FIELD("Posting Date Filter"),
                              "Resource Gr. Filter" = FIELD("Resource Gr. Filter"),
                              "Planning Date Filter" = FIELD("Planning Date Filter");
                Visible = false;
                ApplicationArea = NPRRetail;

            }
            systempart(Control1900383207; Links)
            {
                Visible = false;
                ApplicationArea = NPRRetail;

            }
            systempart(Control1905767507; Notes)
            {
                Visible = true;
                ApplicationArea = NPRRetail;

            }
            part(Control6014421; "NPR Event Atributes Info")
            {
                SubPageLink = "Job No." = FIELD("No.");
                ApplicationArea = NPRRetail;

            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Event")
            {
                Caption = '&Event';
                Image = Job;
                action("Event &Task Lines")
                {
                    Caption = 'Event &Task Lines';
                    Image = TaskList;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    RunObject = Page "NPR Event Task Lines";
                    RunPageLink = "Job No." = FIELD("No.");
                    ShortCutKey = 'Shift+Ctrl+T';

                    ToolTip = 'Plan how you want to set up your planning information. In this window you can specify the tasks involved in an event. To start planning an event or to post usage for an event, you must set up at least one event task.';
                    ApplicationArea = NPRRetail;
                }
                action("&Dimensions")
                {
                    Caption = '&Dimensions';
                    Image = Dimensions;
                    RunObject = Page "Default Dimensions";
                    RunPageLink = "Table ID" = CONST(167),
                                  "No." = FIELD("No.");
                    ShortCutKey = 'Shift+Ctrl+D';

                    ToolTip = 'View or edit dimensions, such as area, project, or department, that you can assign to journal lines to distribute costs and analyze transaction history.';
                    ApplicationArea = NPRRetail;
                }
                action("&Statistics")
                {
                    Caption = '&Statistics';
                    Image = Statistics;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    RunObject = Page "NPR Event Statistics";
                    RunPageLink = "No." = FIELD("No.");
                    ShortCutKey = 'F7';

                    ToolTip = 'View this event''s statistics.';
                    ApplicationArea = NPRRetail;
                }
                action(SalesDocuments)
                {
                    Caption = 'Sales &Documents';
                    Image = GetSourceDoc;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;

                    ToolTip = 'View sales documents that are related to the selected event.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        EventInvoices: Page "NPR Event Invoices";
                    begin
                        EventInvoices.SetPrJob(Rec);
                        EventInvoices.RunModal();
                    end;
                }
                separator(Separator64)
                {
                }
                action("Co&mments")
                {
                    Caption = 'Co&mments';
                    Image = ViewComments;
                    RunObject = Page "Comment Sheet";
                    RunPageLink = "Table Name" = CONST(Job),
                                  "No." = FIELD("No.");

                    ToolTip = 'View or add comments for the record.';
                    ApplicationArea = NPRRetail;
                }
                action("&Online Map")
                {
                    Caption = '&Online Map';
                    Image = Map;

                    ToolTip = 'View online map for addresses assigned to this event.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Rec.DisplayMap();
                    end;
                }
                action(ActivityLog)
                {
                    Caption = 'Activity Log';
                    Image = Log;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;

                    ToolTip = 'View more details about potential errors/actions that occur on this event.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        ActivityLog: Record "Activity Log";
                    begin
                        ActivityLog.ShowEntries(Rec.RecordId);
                    end;
                }
                action(Attributes)
                {
                    Caption = 'Attributes';
                    Image = BulletList;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    RunObject = Page "NPR Event Attributes";
                    RunPageLink = "Job No." = FIELD("No.");

                    ToolTip = 'View or add attributes which will be associated with this event. Attributes are custom made labels that let you track different statistics per event or can be used as a set of multiple cross-labels for which you can define values.';
                    ApplicationArea = NPRRetail;
                }

                action(ReportLayout)
                {
                    Caption = 'Report Layouts';
                    Image = Print;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;

                    ToolTip = 'View or add a report with specific layout/data for this event.';
                    ApplicationArea = NPRRetail;
                    RunObject = page "NPR Event Report Layouts";
                    RunPageLink = "Event No." = field("No.");
                }
                action(ExchIntTemplates)
                {
                    Caption = 'Exch. Int. Templates';
                    Image = InteractionTemplate;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    ToolTip = 'View or add different templates to be used for Microsoft Exchange integration. These include e-mails, meeting requests and appointments.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        EventExchIntTempEntries: Page "NPR Event Exch.Int.Tmp.Entries";
                        EventExchIntTempEntry: Record "NPR Event Exch.Int.Temp.Entry";
                    begin
                        EventExchIntTempEntry.SetRange("Source Record ID", Rec.RecordId);
                        EventExchIntTempEntries.SetTableView(EventExchIntTempEntry);
                        EventExchIntTempEntries.Run();
                    end;
                }
                action(ExchIntEmailSummary)
                {
                    Caption = 'Exch. Int. E-mail Summary';
                    Image = ValidateEmailLoggingSetup;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;

                    ToolTip = 'View a summary that shows a nice overview of who the sender and receipients are when using Microsoft Exchange integration. Removes the uncertainty of not knowing to whom the e-mail or a meeting request will be send to.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        EventEWSMgt.ShowExchIntSummary(Rec);
                    end;
                }
            }
            group(Prices)
            {
                Visible = ExtendedPriceEnabled;
                action(SalesPriceLists)
                {

                    Caption = 'Sales Price Lists (Prices)';
                    Image = Price;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    ToolTip = 'View or set up different prices for products that you sell to the customer. A product price is automatically granted on invoice lines when the specified criteria are met, such as customer, quantity, or ending date.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        PriceUXManagement: Codeunit "Price UX Management";
                        AmountType: Enum "Price Amount Type";
                        PriceType: Enum "Price Type";
                    begin
                        PriceUXManagement.ShowPriceLists(Rec, PriceType::Sale, AmountType::Price);
                    end;
                }
                action(SalesPriceListsDiscounts)
                {

                    Caption = 'Sales Price Lists (Discounts)';
                    Image = LineDiscount;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    ToolTip = 'View or set up different discounts for products that you sell to the customer. A product line discount is automatically granted on invoice lines when the specified criteria are met, such as customer, quantity, or ending date.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        PriceUXManagement: Codeunit "Price UX Management";
                        AmountType: Enum "Price Amount Type";
                        PriceType: Enum "Price Type";
                    begin
                        PriceUXManagement.ShowPriceLists(Rec, PriceType::Sale, AmountType::Discount);
                    end;
                }
                action(PurchasePriceLists)
                {

                    Caption = 'Purchase Price Lists (Prices)';
                    Image = Price;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    ToolTip = 'View or set up different prices for products that you buy from the vendor. A product price is automatically granted on invoice lines when the specified criteria are met, such as vendor, quantity, or ending date.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        PriceUXManagement: Codeunit "Price UX Management";
                        AmountType: Enum "Price Amount Type";
                        PriceType: Enum "Price Type";
                    begin
                        PriceUXManagement.ShowPriceLists(Rec, PriceType::Purchase, AmountType::Price);
                    end;
                }
                action(PurchasePriceListsDiscounts)
                {

                    Caption = 'Purchase Price Lists (Discounts)';
                    Image = LineDiscount;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    ToolTip = 'View or set up different discounts for products that you buy from the vendor. A product discount is automatically granted on invoice lines when the specified criteria are met, such as vendor, quantity, or ending date.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        PriceUXManagement: Codeunit "Price UX Management";
                        AmountType: Enum "Price Amount Type";
                        PriceType: Enum "Price Type";
                    begin
                        PriceUXManagement.ShowPriceLists(Rec, PriceType::Purchase, AmountType::Discount);
                    end;
                }
            }
            group("Plan&ning")
            {
                Caption = 'Plan&ning';
                Image = Planning;
                action("Resource &Allocated per Job")
                {
                    Caption = 'Resource &Allocated per Job';
                    Image = ViewJob;
                    RunObject = Page "Resource Allocated per Job";

                    ToolTip = 'View this event''s resource allocation.';
                    ApplicationArea = NPRRetail;
                }
                action("Res. Gr. All&ocated per Job")
                {
                    Caption = 'Res. Gr. All&ocated per Job';
                    Image = ResourceGroup;
                    RunObject = Page "Res. Gr. Allocated per Job";

                    ToolTip = 'View the event''s resource group allocation.';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Tickets)
            {
                Caption = 'Tickets';
                action(TicketSchedules)
                {
                    Caption = 'Ticket Schedules';
                    Image = Workdays;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    RunObject = Page "NPR TM Ticket Schedules";

                    ToolTip = 'View or set ticket schedules in ticket module.';
                    ApplicationArea = NPRRetail;
                }
                action(TicketAdmissions)
                {
                    Caption = 'Ticket Admissions';
                    Image = WorkCenter;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;

                    ToolTip = 'View or set ticket admissions in ticket module. List will be filtered based on value in Admission Code field.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        TicketAdmissions: Page "NPR TM Ticket Admissions";
                        Admission: Record "NPR TM Admission";
                    begin
                        Admission.SetRange("Admission Code", Rec."NPR Admission Code");
                        if Rec."NPR Admission Code" = '' then
                            Admission.SetRange("Admission Code");
                        TicketAdmissions.SetTableView(Admission);
                        TicketAdmissions.Run();
                    end;
                }
                action(AdmissionScheduleLines)
                {
                    Caption = 'Admission Schedule Lines';
                    Image = CalendarWorkcenter;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;

                    ToolTip = 'View or set admissions schedule lines in ticket module. List will be filtered based on value in Admission Code field.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        AdmissionScheduleLines: Page "NPR TM Admis. Schedule Lines";
                        AdmissionScheduleLine: Record "NPR TM Admis. Schedule Lines";
                    begin
                        AdmissionScheduleLine.SetRange("Admission Code", Rec."NPR Admission Code");
                        if Rec."NPR Admission Code" = '' then
                            AdmissionScheduleLine.SetRange("Admission Code");
                        AdmissionScheduleLines.SetTableView(AdmissionScheduleLine);
                        AdmissionScheduleLines.Run();
                    end;
                }
                action(AdmissionScheduleEntry)
                {
                    Caption = 'Admission Schedule Entry';
                    Image = WorkCenterLoad;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    RunObject = Page "NPR TM Admis. Schedule Entry";
                    RunPageLink = "Admission Code" = FIELD("NPR Admission Code");

                    ToolTip = 'View or set admissions schedule entries in ticket module. List will be filtered based on value in Admission Code field.';
                    ApplicationArea = NPRRetail;
                }
            }
            group(History)
            {
                Caption = 'History';
                Image = History;
                action("Ledger E&ntries")
                {
                    Caption = 'Ledger E&ntries';
                    Image = JobLedger;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    RunObject = Page "Job Ledger Entries";
                    RunPageLink = "Job No." = FIELD("No.");
                    RunPageView = SORTING("Job No.", "Job Task No.", "Entry Type", "Posting Date");
                    ShortCutKey = 'Ctrl+F7';

                    ToolTip = 'View the history of transactions that have been posted for the selected record.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
        area(processing)
        {
            group(ActionGroup6014519)
            {
                Caption = 'Tickets';
                ToolTip = 'Groups processing actions for tickets.';
                action(CollectTicketPrintouts)
                {
                    Caption = 'Collect Ticket Printouts';
                    Image = GetSourceDoc;

                    ToolTip = 'Collects tickets printouts for all issued tickets. Used for tickets which have a layout defined in Magento.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        EventTicketMgt.CollectTickets(Rec);
                    end;
                }
            }
            group("&Copy")
            {
                Caption = '&Copy';
                Image = Copy;
                action("Copy Job Tasks &from...")
                {
                    Caption = 'Copy Job Tasks &from...';
                    Ellipsis = true;
                    Image = CopyToTask;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    ToolTip = 'Open the Copy Job Tasks page.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        CopyJobTasks: Page "Copy Job Tasks";
                    begin
                        CopyJobTasks.SetToJob(Rec);
                        CopyJobTasks.RunModal();
                    end;
                }
                action("Copy Job Tasks &to...")
                {
                    Caption = 'Copy Job Tasks &to...';
                    Ellipsis = true;
                    Image = CopyFromTask;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    ToolTip = 'Open the Copy Jobs To page.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        CopyJobTasks: Page "Copy Job Tasks";
                    begin
                        CopyJobTasks.SetFromJob(Rec);
                        CopyJobTasks.RunModal();
                    end;
                }
                action(CopyAttribute)
                {
                    Caption = 'Copy Attributes';
                    Ellipsis = true;
                    Image = Copy;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    ToolTip = 'Opens the Event Copy Attr./Templ. page.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        EventCopy: Page "NPR Event Copy Attr./Templ.";
                    begin
                        EventCopy.SetFromEvent(Rec."No.", 0);
                        EventCopy.RunModal();
                        CurrPage.Update(false);
                    end;
                }
            }
            group(Outlook)
            {
                Caption = 'Outlook';
                action(SendToCalendar)
                {
                    Caption = 'Send to Calendar';
                    Ellipsis = true;
                    Image = Calendar;

                    ToolTip = 'Creates an exchange calendar item. This can be either an appointment or a meeting request. Calendar item will be created in the senders calendar. You can use Exch. Int. E-mail Summary action to check who the sender is.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        EventCalendarMgt.SendToCalendar(Rec);
                        CurrPage.Update(false);
                    end;
                }
                action(RemoveFromCalendar)
                {
                    Caption = 'Remove from Calendar';
                    Ellipsis = true;
                    Image = RemoveContacts;

                    ToolTip = 'Removes an exchange calendar created by Send to Calendar action. You''ll be prompted to select which one (if multiple) and to specify a reson for removal.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        EventCalendarMgt.RemoveFromCalendar(Rec);
                        CurrPage.Update(false);
                    end;
                }
                action(GetResponse)
                {
                    Caption = 'Get Attendee Response';
                    Image = Answers;

                    ToolTip = 'Checks for the attendee response on the meeting request previously sent. Response from each resource is checked and status is updated in the lines.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        EventCalendarMgt.GetCalendarAttendeeResponses(Rec);
                        CurrPage.Update(false);
                    end;
                }
                group("Send E-Mail to")
                {
                    Caption = 'Send E-Mail to';
                    Image = SendMail;
                    action(SendEmailToCustomer)
                    {
                        Caption = 'Customer';
                        Ellipsis = true;
                        Image = Customer;

                        ToolTip = 'Sends an e-mail to the customer who is paying for the event. E-mail sent is fully customizable. Use Exch. Int. Templates action to define subject and body of the e-mail, Word Layouts action to set attachment and Exch. Int. E-mail Summary to check who the sender/receipient is before sending it.';
                        ApplicationArea = NPRRetail;

                        trigger OnAction()
                        var
                            EventEmailMgt: Codeunit "NPR Event Email Management";
                        begin
                            EventEmailMgt.SendEMail(Rec, 0, 0);
                            CurrPage.Update(false);
                        end;
                    }
                    action(SendEmailToTeam)
                    {
                        Caption = 'Team';
                        Ellipsis = true;
                        Image = TeamSales;

                        ToolTip = 'Sends an e-mail to the team responsible to prepare the event. E-mail sent is fully customizable. Use Exch. Int. Templates action to define subject and body of the e-mail, Word Layouts action to set attachment and Exch. Int. E-mail Summary to check who the sender/receipient is before sending it.';
                        ApplicationArea = NPRRetail;

                        trigger OnAction()
                        var
                            EventEmailMgt: Codeunit "NPR Event Email Management";
                        begin
                            EventEmailMgt.SendEMail(Rec, 1, 0);
                            CurrPage.Update(false);
                        end;
                    }
                }
            }
        }
        area(reporting)
        {
            action("Job Analysis")
            {
                Caption = 'Job Analysis';
                Image = "Report";
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = "Report";
                RunObject = Report "Job Analysis";

                ToolTip = 'Analyze the event, such as the budgeted prices, usage prices, and contract prices, and then compares the three sets of prices.';
                ApplicationArea = NPRRetail;
            }
            action("Job - Planning Lines")
            {
                Caption = 'Job - Planning Lines';
                Image = "Report";
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = "Report";
                RunObject = Report "Job - Planning Lines";

                ToolTip = 'View all planning lines for the event. You use this window to plan what items, resources, and general ledger expenses that you expect to use on an event (budget) or you can specify what you actually agreed with your customer that he should pay for the event (billable).';
                ApplicationArea = NPRRetail;
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        i: Integer;
    begin
        CurrencyCheck();
        Clear(EventAttributeTemplateName);
        EventAttribute.SetRange("Job No.", Rec."No.");
        EventAttribute.SetRange(Promote, true);
        if EventAttribute.FindSet() then
            repeat
                i += 1;
                if i <= ArrayLen(EventAttributeTemplateName) then
                    EventAttributeTemplateName[i] := EventAttribute."Template Name";
            until EventAttribute.Next() = 0;
        for i := 1 to ArrayLen(EventAttributeTemplateName) do begin
            GetAttributeTemplateSetup(i);
            AssignTemplateSetupToVariables(i);
        end;
        SetGlobalEditable();
        SetGroupedLineGroupVisibility();
    end;

    trigger OnInit()
    begin
        CurrencyCodeEditable := true;
        InvoiceCurrencyCodeEditable := true;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."NPR Event" := true;
        SetGlobalEditable();
    end;

    trigger OnOpenPage()
    var
        PriceCalculationMgt: Codeunit "Price Calculation Mgt.";
    begin
        ExtendedPriceEnabled := PriceCalculationMgt.IsExtendedPriceCalculationEnabled();
    end;

    var
        [InDataSet]
        InvoiceCurrencyCodeEditable: Boolean;
        [InDataSet]
        CurrencyCodeEditable: Boolean;
        EventCalendarMgt: Codeunit "NPR Event Calendar Mgt.";
        EventAttrMgt: Codeunit "NPR Event Attribute Mgt.";
        [InDataSet]
        AttributeVisibleSet1: Boolean;
        AttributeValue: array[5, 5, 2] of Text;
        RowDescription: array[5, 2] of Text;
        RowDescription1Set1: Text;
        RowDescription2Set1: Text;
        RowDescription3Set1: Text;
        RowDescription4Set1: Text;
        RowDescription5Set1: Text;
        RowEditable: array[5, 2] of Boolean;
        [InDataSet]
        RowEditable1Set1: Boolean;
        [InDataSet]
        RowEditable2Set1: Boolean;
        [InDataSet]
        RowEditable3Set1: Boolean;
        [InDataSet]
        RowEditable4Set1: Boolean;
        [InDataSet]
        RowEditable5Set1: Boolean;
        ColumnCaption: array[5, 2] of Text;
        ColumnCaption1Set1: Text;
        ColumnCaption2Set1: Text;
        ColumnCaption3Set1: Text;
        ColumnCaption4Set1: Text;
        ColumnCaption5Set1: Text;
        ColumnEditable: array[5, 2] of Boolean;
        [InDataSet]
        ColumnEditable1Set1: Boolean;
        [InDataSet]
        ColumnEditable2Set1: Boolean;
        [InDataSet]
        ColumnEditable3Set1: Boolean;
        [InDataSet]
        ColumnEditable4Set1: Boolean;
        [InDataSet]
        ColumnEditable5Set1: Boolean;
        ColumnLineNo: array[5, 2] of Integer;
        RowLineNo: array[5, 2] of Integer;
        [InDataSet]
        AttributeVisibleSet2: Boolean;
        RowDescription1Set2: Text;
        RowDescription2Set2: Text;
        RowDescription3Set2: Text;
        RowDescription4Set2: Text;
        RowDescription5Set2: Text;
        [InDataSet]
        RowEditable1Set2: Boolean;
        [InDataSet]
        RowEditable2Set2: Boolean;
        [InDataSet]
        RowEditable3Set2: Boolean;
        [InDataSet]
        RowEditable4Set2: Boolean;
        [InDataSet]
        RowEditable5Set2: Boolean;
        ColumnCaption1Set2: Text;
        ColumnCaption2Set2: Text;
        ColumnCaption3Set2: Text;
        ColumnCaption4Set2: Text;
        ColumnCaption5Set2: Text;
        [InDataSet]
        ColumnEditable1Set2: Boolean;
        [InDataSet]
        ColumnEditable2Set2: Boolean;
        [InDataSet]
        ColumnEditable3Set2: Boolean;
        [InDataSet]
        ColumnEditable4Set2: Boolean;
        [InDataSet]
        ColumnEditable5Set2: Boolean;
        EventAttribute: Record "NPR Event Attribute";
        EventAttributeTemplateName: array[2] of Code[20];
        EventTicketMgt: Codeunit "NPR Event Ticket Mgt.";
        EventEWSMgt: Codeunit "NPR Event EWS Management";
        GlobalEditable: Boolean;
        GroupedLineGroupVisible: Boolean;
        ExtendedPriceEnabled: Boolean;

    local procedure CurrencyCheck()
    begin
        if Rec."Currency Code" <> '' then
            InvoiceCurrencyCodeEditable := false
        else
            InvoiceCurrencyCodeEditable := true;

        if Rec."Invoice Currency Code" <> '' then
            CurrencyCodeEditable := false
        else
            CurrencyCodeEditable := true;
    end;

    local procedure GetAttributeTemplateSetup(AttributeSetNo: Integer)
    var
        EventAttrTemplate: Record "NPR Event Attribute Template";
        EventAttrRowValue: Record "NPR Event Attr. Row Value";
        EventAttrColValue: Record "NPR Event Attr. Column Value";
        EventAttributeEntry: Record "NPR Event Attribute Entry";
        i: Integer;
        j: Integer;
    begin
        if EventAttributeTemplateName[AttributeSetNo] = '' then
            exit;
        EventAttrTemplate.Get(EventAttributeTemplateName[AttributeSetNo]);
        if EventAttrTemplate."Row Template Name" = '' then
            exit;
        if EventAttrTemplate."Column Template Name" = '' then
            exit;
        EventAttrRowValue.SetRange("Template Name", EventAttrTemplate."Row Template Name");
        EventAttrRowValue.SetRange(Promote, true);
        EventAttrColValue.SetRange("Template Name", EventAttrTemplate."Column Template Name");
        EventAttrColValue.SetRange(Promote, true);

        for j := 1 to ArrayLen(ColumnCaption, 1) do begin
            ColumnCaption[j] [AttributeSetNo] := '';
            ColumnLineNo[j] [AttributeSetNo] := 0;
            if j = 1 then
                ColumnEditable[j] [AttributeSetNo] := EventAttrColValue.FindSet()
            else
                ColumnEditable[j] [AttributeSetNo] := EventAttrColValue.Next() <> 0;
            if ColumnEditable[j] [AttributeSetNo] then begin
                ColumnCaption[j] [AttributeSetNo] := EventAttrColValue.Description;
                ColumnLineNo[j] [AttributeSetNo] := EventAttrColValue."Line No.";
            end;
        end;
        for i := 1 to ArrayLen(RowDescription, 1) do begin
            RowDescription[i] [AttributeSetNo] := '';
            RowLineNo[i] [AttributeSetNo] := 0;
            if i = 1 then
                RowEditable[i] [AttributeSetNo] := EventAttrRowValue.FindSet()
            else
                RowEditable[i] [AttributeSetNo] := EventAttrRowValue.Next() <> 0;
            if RowEditable[i] [AttributeSetNo] then begin
                RowEditable[i] [AttributeSetNo] := EventAttrRowValue.Type = EventAttrRowValue.Type::" ";
                RowDescription[i] [AttributeSetNo] := EventAttrRowValue.Description;
                RowLineNo[i] [AttributeSetNo] := EventAttrRowValue."Line No.";
            end;
            for j := 1 to ArrayLen(ColumnCaption, 1) do begin
                AttributeValue[i] [j] [AttributeSetNo] := '';
                EventAttributeEntry.SetRange("Template Name", EventAttributeTemplateName[AttributeSetNo]);
                EventAttributeEntry.SetRange("Job No.", Rec."No.");
                EventAttributeEntry.SetRange("Row Line No.", RowLineNo[i] [AttributeSetNo]);
                EventAttributeEntry.SetRange("Column Line No.", ColumnLineNo[j] [AttributeSetNo]);
                EventAttributeEntry.SetRange(Filter, false);
                if EventAttributeEntry.FindFirst() then
                    AttributeValue[i] [j] [AttributeSetNo] := EventAttributeEntry."Value Text";
            end;
        end;
    end;

    local procedure AttributeValueOnValidate(RowNo: Integer; ColumnNo: Integer; AttributeSetNo: Integer)
    begin
        EventAttrMgt.CheckAndUpdate(EventAttributeTemplateName[AttributeSetNo], Rec."No.", RowLineNo[RowNo] [AttributeSetNo], ColumnLineNo[ColumnNo] [AttributeSetNo], ColumnCaption[ColumnNo] [AttributeSetNo], AttributeValue[RowNo] [ColumnNo] [AttributeSetNo], false, '');
        CurrPage.Update(false);
    end;

    local procedure AssignTemplateSetupToVariables(AttributeSetNo: Integer)
    begin
        case AttributeSetNo of
            1:
                begin
                    AttributeVisibleSet1 := EventAttributeTemplateName[AttributeSetNo] <> '';
                    if not AttributeVisibleSet1 then
                        exit;
                    RowEditable1Set1 := RowEditable[1] [AttributeSetNo];
                    RowEditable2Set1 := RowEditable[2] [AttributeSetNo];
                    RowEditable3Set1 := RowEditable[3] [AttributeSetNo];
                    RowEditable4Set1 := RowEditable[4] [AttributeSetNo];
                    RowEditable5Set1 := RowEditable[5] [AttributeSetNo];
                    RowDescription1Set1 := RowDescription[1] [AttributeSetNo];
                    RowDescription2Set1 := RowDescription[2] [AttributeSetNo];
                    RowDescription3Set1 := RowDescription[3] [AttributeSetNo];
                    RowDescription4Set1 := RowDescription[4] [AttributeSetNo];
                    RowDescription5Set1 := RowDescription[5] [AttributeSetNo];
                    ColumnEditable1Set1 := ColumnEditable[1] [AttributeSetNo];
                    ColumnEditable2Set1 := ColumnEditable[2] [AttributeSetNo];
                    ColumnEditable3Set1 := ColumnEditable[3] [AttributeSetNo];
                    ColumnEditable4Set1 := ColumnEditable[4] [AttributeSetNo];
                    ColumnEditable5Set1 := ColumnEditable[5] [AttributeSetNo];
                    ColumnCaption1Set1 := ColumnCaption[1] [AttributeSetNo];
                    ColumnCaption2Set1 := ColumnCaption[2] [AttributeSetNo];
                    ColumnCaption3Set1 := ColumnCaption[3] [AttributeSetNo];
                    ColumnCaption4Set1 := ColumnCaption[4] [AttributeSetNo];
                    ColumnCaption5Set1 := ColumnCaption[5] [AttributeSetNo];
                end;
            2:
                begin
                    AttributeVisibleSet2 := EventAttributeTemplateName[AttributeSetNo] <> '';
                    if not AttributeVisibleSet2 then
                        exit;
                    RowEditable1Set2 := RowEditable[1] [AttributeSetNo];
                    RowEditable2Set2 := RowEditable[2] [AttributeSetNo];
                    RowEditable3Set2 := RowEditable[3] [AttributeSetNo];
                    RowEditable4Set2 := RowEditable[4] [AttributeSetNo];
                    RowEditable5Set2 := RowEditable[5] [AttributeSetNo];
                    RowDescription1Set2 := RowDescription[1] [AttributeSetNo];
                    RowDescription2Set2 := RowDescription[2] [AttributeSetNo];
                    RowDescription3Set2 := RowDescription[3] [AttributeSetNo];
                    RowDescription4Set2 := RowDescription[4] [AttributeSetNo];
                    RowDescription5Set2 := RowDescription[5] [AttributeSetNo];
                    ColumnEditable1Set2 := ColumnEditable[1] [AttributeSetNo];
                    ColumnEditable2Set2 := ColumnEditable[2] [AttributeSetNo];
                    ColumnEditable3Set2 := ColumnEditable[3] [AttributeSetNo];
                    ColumnEditable4Set2 := ColumnEditable[4] [AttributeSetNo];
                    ColumnEditable5Set2 := ColumnEditable[5] [AttributeSetNo];
                    ColumnCaption1Set2 := ColumnCaption[1] [AttributeSetNo];
                    ColumnCaption2Set2 := ColumnCaption[2] [AttributeSetNo];
                    ColumnCaption3Set2 := ColumnCaption[3] [AttributeSetNo];
                    ColumnCaption4Set2 := ColumnCaption[4] [AttributeSetNo];
                    ColumnCaption5Set2 := ColumnCaption[5] [AttributeSetNo];
                end;
        end;
    end;

    procedure GetArrayLen(Dimension: Integer): Integer
    begin
        exit(ArrayLen(AttributeValue, Dimension));
    end;

    local procedure SetGlobalEditable()
    begin
        GlobalEditable := not Rec."NPR Locked";
    end;

    local procedure SetGroupedLineGroupVisibility()
    var
        JobPlanningLine: Record "Job Planning Line";
    begin
        JobPlanningLine.SetRange("Job No.", Rec."No.");
        JobPlanningLine.SetFilter("NPR Group Source Line No.", '<>0');
        GroupedLineGroupVisible := not JobPlanningLine.IsEmpty();
    end;
}

