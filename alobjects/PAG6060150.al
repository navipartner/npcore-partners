page 6060150 "Event Card"
{
    // NPR5.29/NPKNAV/20170127  CASE 248723 Transport NPR5.29 - 27 januar 2017
    // NPR5.30/TJ  /20170309 CASE 263434 Moved global variable EventCopy to be local on action CopyAttribute
    // NPR5.31/TJ  /20170315 CASE 269162 Property Importance of controls "Bill-to Country/Region Code","Organizer E-Mail" and "Organizer E-Mail Password"
    //                                   changed to Additional (was default)
    //                                   New controls for attributes
    //                                   Changed Attributes action to new attribute funcionality
    //                                   New control Person Responsible Name
    //                                   Moved non editable fields under group Additional Information inside General tab
    //                                   Changed RunPageLink property of action Attributes
    //                                   Added code to Copy Attributes action, OnOpenPage, OnAfterGetRecord and Person Responsible - OnValidate()
    // NPR5.33/TJ  /20170601 CASE 277946 Added code to AttributeValueOnValidate
    // NPR5.33/TJ  /20170606 CASE 277972 Changed page to be opened on Attributes action
    //                                   Removed control "Event Attribute Template Name"
    //                                   Renamed some variables to be gramatically correct
    //                                   Renamed group Attributes to Promoted Attributes 1
    //                                   Added a copy of Promoted Attributes 1 and named it Promoted Attributes 2
    //                                   Recoded how to fetch attributes so its easier to implement future needs if additional group will be needed
    // NPR5.34/TJ  /20170707 CASE 277938 New action Exch. Int. Templates
    // NPR5.35/TJ  /20170731 CASE 275959 Removed control "Bill-to Customer No." and inserted new control "Event Customer No."
    // NPR5.43/TJ  /20170814 CASE 262079 New action Collect Ticket Printouts
    // NPR5.37/TJ  /20170927 CASE 287806 Statistics now shows page Event Statistics (instead default Job Statistics page)
    // NPR5.38/TJ  /20171015 CASE 291965 Added new FactBox Event Attributes Info
    // NPR5.38/TJ  /20171027 CASE 285194 Removed control "Organizer E-Mail Password"
    // NPR5.39/NPKNAV/20180223  CASE 285388 Transport NPR5.39 - 23 February 2018
    // NPR5.41/TJ  /20180418 CASE 310336 Added field "Total Amount"
    // NPR5.48/TJ  /20190131 CASE 342308 Added field "Est. Total Amount Incl. VAT"
    // NPR5.49/TJ  /20190124 CASE 331208 Action Job Task Lines renamed to Event Task Lines and changed page to run
    //                                   Total Amount OnDrillDown trigger customized
    // NPR5.49/TJ  /20190218 CASE 345047 Added field Language Code
    // NPR5.49/TJ  /20190318 CASE 346693 Added action Sales Documents
    // NPR5.53/TJ  /20191119 CASE 374886 All controls are editable per setup based on Locked field
    // NPR5.54/TJ  /20200324 CASE 397743 New field "Admission Code"
    //                                   New action AdmissionScheduleEntry in ActionGroup Tickets
    //                                   Actions TicketAdmissions and AdmissionScheduleLines set to be run with "Admission Code" filter if not empty
    // NPR5.54/TJ  /20200324 CASE 397749 New ActionGroup Tickets with actions TicketSchedules, TicketAdmissions and AdmissionScheduleLines added under RelatedInformation
    // NPR5.55/TJ  /20200326 CASE 397741 Added "Group Source Line No.=CONST(0)" to SubPageLink property of part "<Event Planning Lines Subpage>"
    //                                   Part "<Event Planning Lines Subpage>" renamed to EventPlanningLinesSubpage
    //                                   Added new part "<Event Grouped Plan. Lines Sub>" - new part is only visible when grouped lines exist
    // NPR5.55/TJ  /20200205 CASE 374887 New parameter was added for email sending function
    //                                   Added Tickets to property PromotedActionCategoriesML - this was missed in 397749

    Caption = 'Event Card';
    PageType = Card;
    PromotedActionCategories = 'New,Process,Report,Prices,Tickets';
    RefreshOnActivate = true;
    SourceTable = Job;
    SourceTableView = WHERE(Event = CONST(true));

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    Editable = GlobalEditable;

                    trigger OnAssistEdit()
                    begin
                        if AssistEdit(xRec) then
                            CurrPage.Update;
                    end;
                }
                field("Event Status"; "Event Status")
                {
                    ApplicationArea = All;
                    Editable = GlobalEditable;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    Editable = GlobalEditable;
                }
                field("Event Customer No."; "Event Customer No.")
                {
                    ApplicationArea = All;
                    Editable = GlobalEditable;
                }
                field("Bill-to Contact No."; "Bill-to Contact No.")
                {
                    ApplicationArea = All;
                    Editable = GlobalEditable;
                }
                field("Bill-to Name"; "Bill-to Name")
                {
                    ApplicationArea = All;
                    Editable = GlobalEditable;
                    Importance = Promoted;
                }
                field("Bill-to Address"; "Bill-to Address")
                {
                    ApplicationArea = All;
                    Editable = GlobalEditable;
                }
                field("Bill-to Address 2"; "Bill-to Address 2")
                {
                    ApplicationArea = All;
                    Editable = GlobalEditable;
                }
                field("Bill-to Post Code"; "Bill-to Post Code")
                {
                    ApplicationArea = All;
                    Editable = GlobalEditable;
                }
                field("Bill-to City"; "Bill-to City")
                {
                    ApplicationArea = All;
                    Editable = GlobalEditable;
                }
                field("Bill-to Country/Region Code"; "Bill-to Country/Region Code")
                {
                    ApplicationArea = All;
                    Editable = GlobalEditable;
                    Importance = Additional;
                }
                field("Bill-to Contact"; "Bill-to Contact")
                {
                    ApplicationArea = All;
                    Editable = GlobalEditable;
                }
                field("Bill-to E-Mail"; "Bill-to E-Mail")
                {
                    ApplicationArea = All;
                    Editable = GlobalEditable;
                }
                field("Search Description"; "Search Description")
                {
                    ApplicationArea = All;
                    Editable = GlobalEditable;
                }
                field("Person Responsible"; "Person Responsible")
                {
                    ApplicationArea = All;
                    Editable = GlobalEditable;
                    Importance = Promoted;

                    trigger OnValidate()
                    begin
                        //-NPR5.31 [269162]
                        CalcFields("Person Responsible Name");
                        //+NPR5.31 [269162]
                    end;
                }
                field("Person Responsible Name"; "Person Responsible Name")
                {
                    ApplicationArea = All;
                }
                field(Blocked; Blocked)
                {
                    ApplicationArea = All;
                    Editable = GlobalEditable;
                }
                field("Organizer E-Mail"; "Organizer E-Mail")
                {
                    ApplicationArea = All;
                    Editable = GlobalEditable;
                    Importance = Additional;
                }
                field("Calendar Item Status"; "Calendar Item Status")
                {
                    ApplicationArea = All;
                    Editable = GlobalEditable;
                }
                field("Job Posting Group"; "Job Posting Group")
                {
                    ApplicationArea = All;
                    Editable = GlobalEditable;
                }
                field("Total Amount"; "Total Amount")
                {
                    ApplicationArea = All;

                    trigger OnDrillDown()
                    var
                        JobPlanningLine: Record "Job Planning Line";
                    begin
                        //-NPR5.49 [331208]
                        JobPlanningLine.SetRange("Job No.", Rec."No.");
                        PAGE.Run(PAGE::"Event Planning Lines", JobPlanningLine, JobPlanningLine."Line Amount (LCY)");
                        //+NPR5.49 [331208]
                    end;
                }
                field("Est. Total Amount Incl. VAT"; "Est. Total Amount Incl. VAT")
                {
                    ApplicationArea = All;
                }
                field("Language Code"; "Language Code")
                {
                    ApplicationArea = All;
                    Editable = GlobalEditable;
                    Importance = Additional;
                }
                field(Locked; Locked)
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        //-NPR5.53 [374886]
                        SetGlobalEditable();
                        //+NPR5.53 [374886]
                    end;
                }
                field("Admission Code"; "Admission Code")
                {
                    ApplicationArea = All;
                }
                group("Additional Information")
                {
                    Caption = 'Additional Information';
                    field("Last Date Modified"; "Last Date Modified")
                    {
                        ApplicationArea = All;
                    }
                    field("""Calendar Item ID"" <> ''"; "Calendar Item ID" <> '')
                    {
                        ApplicationArea = All;
                        Caption = 'Appointment Exists';
                        Editable = false;
                    }
                    field("Mail Item Status"; "Mail Item Status")
                    {
                        ApplicationArea = All;
                        Editable = false;
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
                            ApplicationArea = All;
                            Caption = 'Description';
                            Enabled = false;
                            ShowCaption = false;
                            Style = Strong;
                            StyleExpr = TRUE;
                        }
                        field(RowDescription1Set1; RowDescription[1] [1])
                        {
                            ApplicationArea = All;
                            Enabled = false;
                            ShowCaption = false;
                        }
                        field(RowDescription2Set1; RowDescription[2] [1])
                        {
                            ApplicationArea = All;
                            Enabled = false;
                            ShowCaption = false;
                        }
                        field(RowDescription3Set1; RowDescription[3] [1])
                        {
                            ApplicationArea = All;
                            Enabled = false;
                            ShowCaption = false;
                        }
                        field(RowDescription4Set1; RowDescription[4] [1])
                        {
                            ApplicationArea = All;
                            Enabled = false;
                            ShowCaption = false;
                        }
                        field(RowDescription5Set1; RowDescription[5] [1])
                        {
                            ApplicationArea = All;
                            Enabled = false;
                            ShowCaption = false;
                        }
                    }
                    group(Control6014512)
                    {
                        ShowCaption = false;
                        field(ColumnCaption1Set1; ColumnCaption[1] [1])
                        {
                            ApplicationArea = All;
                            Enabled = false;
                            ShowCaption = false;
                            Style = Strong;
                            StyleExpr = TRUE;
                        }
                        field(AttributeValue1_1Set1; AttributeValue[1] [1] [1])
                        {
                            ApplicationArea = All;
                            Enabled = RowEditable1Set1 AND ColumnEditable1Set1;
                            ShowCaption = false;

                            trigger OnValidate()
                            begin
                                //-NPR5.33 [277972]
                                //AttributeValueOnValidate(1,1);
                                AttributeValueOnValidate(1, 1, 1);
                                //+NPR5.33 [277972]
                            end;
                        }
                        field(AttributeValue2_1Set1; AttributeValue[2] [1] [1])
                        {
                            ApplicationArea = All;
                            Enabled = RowEditable2Set1 AND ColumnEditable1Set1;
                            ShowCaption = false;

                            trigger OnValidate()
                            begin
                                //-NPR5.33 [277972]
                                //AttributeValueOnValidate(2,1);
                                AttributeValueOnValidate(2, 1, 1);
                                //+NPR5.33 [277972]
                            end;
                        }
                        field(AttributeValue3_1Set1; AttributeValue[3] [1] [1])
                        {
                            ApplicationArea = All;
                            Enabled = RowEditable3Set1 AND ColumnEditable1Set1;
                            ShowCaption = false;

                            trigger OnValidate()
                            begin
                                //-NPR5.33 [277972]
                                //AttributeValueOnValidate(3,1);
                                AttributeValueOnValidate(3, 1, 1);
                                //+NPR5.33 [277972]
                            end;
                        }
                        field(AttributeValue4_1Set1; AttributeValue[4] [1] [1])
                        {
                            ApplicationArea = All;
                            Enabled = RowEditable4Set1 AND ColumnEditable1Set1;
                            ShowCaption = false;

                            trigger OnValidate()
                            begin
                                //-NPR5.33 [277972]
                                //AttributeValueOnValidate(4,1);
                                AttributeValueOnValidate(4, 1, 1);
                                //+NPR5.33 [277972]
                            end;
                        }
                        field(AttributeValue5_1Set1; AttributeValue[5] [1] [1])
                        {
                            ApplicationArea = All;
                            Enabled = RowEditable5Set1 AND ColumnEditable1Set1;
                            ShowCaption = false;

                            trigger OnValidate()
                            begin
                                //-NPR5.33 [277972]
                                //AttributeValueOnValidate(5,1);
                                AttributeValueOnValidate(5, 1, 1);
                                //+NPR5.33 [277972]
                            end;
                        }
                    }
                    group(Control6014488)
                    {
                        ShowCaption = false;
                        field(ColumnCaption2Set1; ColumnCaption[2] [1])
                        {
                            ApplicationArea = All;
                            Enabled = false;
                            ShowCaption = false;
                            Style = Strong;
                            StyleExpr = TRUE;
                        }
                        field(AttributeValue1_2Set1; AttributeValue[1] [2] [1])
                        {
                            ApplicationArea = All;
                            Enabled = RowEditable1Set1 AND ColumnEditable2Set1;
                            ShowCaption = false;

                            trigger OnValidate()
                            begin
                                //-NPR5.33 [277972]
                                //AttributeValueOnValidate(1,2);
                                AttributeValueOnValidate(1, 2, 1);
                                //+NPR5.33 [277972]
                            end;
                        }
                        field(AttributeValue2_2Set1; AttributeValue[2] [2] [1])
                        {
                            ApplicationArea = All;
                            Enabled = RowEditable2Set1 AND ColumnEditable2Set1;
                            ShowCaption = false;

                            trigger OnValidate()
                            begin
                                //-NPR5.33 [277972]
                                //AttributeValueOnValidate(2,2);
                                AttributeValueOnValidate(2, 2, 1);
                                //+NPR5.33 [277972]
                            end;
                        }
                        field(AttributeValue3_2Set1; AttributeValue[3] [2] [1])
                        {
                            ApplicationArea = All;
                            Enabled = RowEditable3Set1 AND ColumnEditable2Set1;
                            ShowCaption = false;

                            trigger OnValidate()
                            begin
                                //-NPR5.33 [277972]
                                //AttributeValueOnValidate(3,2);
                                AttributeValueOnValidate(3, 2, 1);
                                //+NPR5.33 [277972]
                            end;
                        }
                        field(AttributeValue4_2Set1; AttributeValue[4] [2] [1])
                        {
                            ApplicationArea = All;
                            Enabled = RowEditable4Set1 AND ColumnEditable2Set1;
                            ShowCaption = false;

                            trigger OnValidate()
                            begin
                                //-NPR5.33 [277972]
                                //AttributeValueOnValidate(4,2);
                                AttributeValueOnValidate(4, 2, 1);
                                //+NPR5.33 [277972]
                            end;
                        }
                        field(AttributeValue5_2Set1; AttributeValue[5] [2] [1])
                        {
                            ApplicationArea = All;
                            Enabled = RowEditable5Set1 AND ColumnEditable2Set1;
                            ShowCaption = false;

                            trigger OnValidate()
                            begin
                                //-NPR5.33 [277972]
                                //AttributeValueOnValidate(5,2);
                                AttributeValueOnValidate(5, 2, 1);
                                //+NPR5.33 [277972]
                            end;
                        }
                    }
                    group(Control6014481)
                    {
                        ShowCaption = false;
                        field(ColumnCaption3Set1; ColumnCaption[3] [1])
                        {
                            ApplicationArea = All;
                            Enabled = false;
                            ShowCaption = false;
                            Style = Strong;
                            StyleExpr = TRUE;
                        }
                        field(AttributeValue1_3Set1; AttributeValue[1] [3] [1])
                        {
                            ApplicationArea = All;
                            Enabled = RowEditable1Set1 AND ColumnEditable3Set1;
                            ShowCaption = false;

                            trigger OnValidate()
                            begin
                                //-NPR5.33 [277972]
                                //AttributeValueOnValidate(1,3);
                                AttributeValueOnValidate(1, 3, 1);
                                //+NPR5.33 [277972]
                            end;
                        }
                        field(AttributeValue2_3Set1; AttributeValue[2] [3] [1])
                        {
                            ApplicationArea = All;
                            Enabled = RowEditable2Set1 AND ColumnEditable3Set1;
                            ShowCaption = false;

                            trigger OnValidate()
                            begin
                                //-NPR5.33 [277972]
                                //AttributeValueOnValidate(2,3);
                                AttributeValueOnValidate(2, 3, 1);
                                //+NPR5.33 [277972]
                            end;
                        }
                        field(AttributeValue3_3Set1; AttributeValue[3] [3] [1])
                        {
                            ApplicationArea = All;
                            Enabled = RowEditable3Set1 AND ColumnEditable3Set1;
                            ShowCaption = false;

                            trigger OnValidate()
                            begin
                                //-NPR5.33 [277972]
                                //AttributeValueOnValidate(3,3);
                                AttributeValueOnValidate(3, 3, 1);
                                //+NPR5.33 [277972]
                            end;
                        }
                        field(AttributeValue4_3Set1; AttributeValue[4] [3] [1])
                        {
                            ApplicationArea = All;
                            Enabled = RowEditable4Set1 AND ColumnEditable3Set1;
                            ShowCaption = false;

                            trigger OnValidate()
                            begin
                                //-NPR5.33 [277972]
                                //AttributeValueOnValidate(4,3);
                                AttributeValueOnValidate(4, 3, 1);
                                //+NPR5.33 [277972]
                            end;
                        }
                        field(AttributeValue5_3Set1; AttributeValue[5] [3] [1])
                        {
                            ApplicationArea = All;
                            Enabled = RowEditable5Set1 AND ColumnEditable3Set1;
                            ShowCaption = false;

                            trigger OnValidate()
                            begin
                                //-NPR5.33 [277972]
                                //AttributeValueOnValidate(5,3);
                                AttributeValueOnValidate(5, 3, 1);
                                //+NPR5.33 [277972]
                            end;
                        }
                    }
                    group(Control6014502)
                    {
                        ShowCaption = false;
                        field(ColumnCaption4Set1; ColumnCaption[4] [1])
                        {
                            ApplicationArea = All;
                            Enabled = false;
                            ShowCaption = false;
                            Style = Strong;
                            StyleExpr = TRUE;
                        }
                        field(AttributeValue1_4Set1; AttributeValue[1] [4] [1])
                        {
                            ApplicationArea = All;
                            Enabled = RowEditable1Set1 AND ColumnEditable4Set1;
                            ShowCaption = false;

                            trigger OnValidate()
                            begin
                                //-NPR5.33 [277972]
                                //AttributeValueOnValidate(1,4);
                                AttributeValueOnValidate(1, 4, 1);
                                //+NPR5.33 [277972]
                            end;
                        }
                        field(AttributeValue2_4Set1; AttributeValue[2] [4] [1])
                        {
                            ApplicationArea = All;
                            Enabled = RowEditable2Set1 AND ColumnEditable4Set1;
                            ShowCaption = false;

                            trigger OnValidate()
                            begin
                                //-NPR5.33 [277972]
                                //AttributeValueOnValidate(2,4);
                                AttributeValueOnValidate(2, 4, 1);
                                //+NPR5.33 [277972]
                            end;
                        }
                        field(AttributeValue3_4Set1; AttributeValue[3] [4] [1])
                        {
                            ApplicationArea = All;
                            Enabled = RowEditable3Set1 AND ColumnEditable4Set1;
                            ShowCaption = false;

                            trigger OnValidate()
                            begin
                                //-NPR5.33 [277972]
                                //AttributeValueOnValidate(3,4);
                                AttributeValueOnValidate(3, 4, 1);
                                //+NPR5.33 [277972]
                            end;
                        }
                        field(AttributeValue4_4Set1; AttributeValue[4] [4] [1])
                        {
                            ApplicationArea = All;
                            Enabled = RowEditable4Set1 AND ColumnEditable4Set1;
                            ShowCaption = false;

                            trigger OnValidate()
                            begin
                                //-NPR5.33 [277972]
                                //AttributeValueOnValidate(4,4);
                                AttributeValueOnValidate(4, 4, 1);
                                //+NPR5.33 [277972]
                            end;
                        }
                        field(AttributeValue5_4Set1; AttributeValue[5] [4] [1])
                        {
                            ApplicationArea = All;
                            Enabled = RowEditable5Set1 AND ColumnEditable4Set1;
                            ShowCaption = false;

                            trigger OnValidate()
                            begin
                                //-NPR5.33 [277972]
                                //AttributeValueOnValidate(5,4);
                                AttributeValueOnValidate(5, 4, 1);
                                //+NPR5.33 [277972]
                            end;
                        }
                    }
                    group(Control6014474)
                    {
                        ShowCaption = false;
                        field(ColumnCaption5Set1; ColumnCaption[5] [1])
                        {
                            ApplicationArea = All;
                            Enabled = false;
                            ShowCaption = false;
                            Style = Strong;
                            StyleExpr = TRUE;
                        }
                        field(AttributeValue1_5Set1; AttributeValue[1] [5] [1])
                        {
                            ApplicationArea = All;
                            Enabled = RowEditable1Set1 AND ColumnEditable5Set1;
                            ShowCaption = false;

                            trigger OnValidate()
                            begin
                                //-NPR5.33 [277972]
                                //AttributeValueOnValidate(1,5);
                                AttributeValueOnValidate(1, 5, 1);
                                //+NPR5.33 [277972]
                            end;
                        }
                        field(AttributeValue2_5Set1; AttributeValue[2] [5] [1])
                        {
                            ApplicationArea = All;
                            Enabled = RowEditable2Set1 AND ColumnEditable5Set1;
                            ShowCaption = false;

                            trigger OnValidate()
                            begin
                                //-NPR5.33 [277972]
                                //AttributeValueOnValidate(2,5);
                                AttributeValueOnValidate(2, 5, 1);
                                //+NPR5.33 [277972]
                            end;
                        }
                        field(AttributeValue3_5Set1; AttributeValue[3] [5] [1])
                        {
                            ApplicationArea = All;
                            Enabled = RowEditable3Set1 AND ColumnEditable5Set1;
                            ShowCaption = false;

                            trigger OnValidate()
                            begin
                                //-NPR5.33 [277972]
                                //AttributeValueOnValidate(3,5);
                                AttributeValueOnValidate(3, 5, 1);
                                //+NPR5.33 [277972]
                            end;
                        }
                        field(AttributeValue4_5Set1; AttributeValue[4] [5] [1])
                        {
                            ApplicationArea = All;
                            Enabled = RowEditable4Set1 AND ColumnEditable5Set1;
                            ShowCaption = false;

                            trigger OnValidate()
                            begin
                                //-NPR5.33 [277972]
                                //AttributeValueOnValidate(4,5);
                                AttributeValueOnValidate(4, 5, 1);
                                //+NPR5.33 [277972]
                            end;
                        }
                        field(AttributeValue5_5Set1; AttributeValue[5] [5] [1])
                        {
                            ApplicationArea = All;
                            Enabled = RowEditable5Set1 AND ColumnEditable5Set1;
                            ShowCaption = false;

                            trigger OnValidate()
                            begin
                                //-NPR5.33 [277972]
                                //AttributeValueOnValidate(5,5);
                                AttributeValueOnValidate(5, 5, 1);
                                //+NPR5.33 [277972]
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
                            ApplicationArea = All;
                            Caption = 'Description';
                            Enabled = false;
                            ShowCaption = false;
                            Style = Strong;
                            StyleExpr = TRUE;
                        }
                        field(RowDescription1Set2; RowDescription[1] [2])
                        {
                            ApplicationArea = All;
                            Enabled = false;
                            ShowCaption = false;
                        }
                        field(RowDescription2Set2; RowDescription[2] [2])
                        {
                            ApplicationArea = All;
                            Enabled = false;
                            ShowCaption = false;
                        }
                        field(RowDescription3Set2; RowDescription[3] [2])
                        {
                            ApplicationArea = All;
                            Enabled = false;
                            ShowCaption = false;
                        }
                        field(RowDescription4Set2; RowDescription[4] [2])
                        {
                            ApplicationArea = All;
                            Enabled = false;
                            ShowCaption = false;
                        }
                        field(RowDescription5Set2; RowDescription[5] [2])
                        {
                            ApplicationArea = All;
                            Enabled = false;
                            ShowCaption = false;
                        }
                    }
                    group(Control6014458)
                    {
                        ShowCaption = false;
                        field(ColumnCaption1Set2; ColumnCaption[1] [2])
                        {
                            ApplicationArea = All;
                            Enabled = false;
                            ShowCaption = false;
                            Style = Strong;
                            StyleExpr = TRUE;
                        }
                        field(AttributeValue1_1Set2; AttributeValue[1] [1] [2])
                        {
                            ApplicationArea = All;
                            Enabled = RowEditable1Set2 AND ColumnEditable1Set2;
                            ShowCaption = false;

                            trigger OnValidate()
                            begin
                                AttributeValueOnValidate(1, 1, 2);
                            end;
                        }
                        field(AttributeValue2_1Set2; AttributeValue[2] [1] [2])
                        {
                            ApplicationArea = All;
                            Enabled = RowEditable2Set2 AND ColumnEditable1Set2;
                            ShowCaption = false;

                            trigger OnValidate()
                            begin
                                AttributeValueOnValidate(2, 1, 2);
                            end;
                        }
                        field(AttributeValue3_1Set2; AttributeValue[3] [1] [2])
                        {
                            ApplicationArea = All;
                            Enabled = RowEditable3Set2 AND ColumnEditable1Set2;
                            ShowCaption = false;

                            trigger OnValidate()
                            begin
                                AttributeValueOnValidate(3, 1, 2);
                            end;
                        }
                        field(AttributeValue4_1Set2; AttributeValue[4] [1] [2])
                        {
                            ApplicationArea = All;
                            Enabled = RowEditable4Set2 AND ColumnEditable1Set2;
                            ShowCaption = false;

                            trigger OnValidate()
                            begin
                                AttributeValueOnValidate(4, 1, 2);
                            end;
                        }
                        field(AttributeValue5_1Set2; AttributeValue[5] [1] [2])
                        {
                            ApplicationArea = All;
                            Enabled = RowEditable5Set2 AND ColumnEditable1Set2;
                            ShowCaption = false;

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
                            ApplicationArea = All;
                            Enabled = false;
                            ShowCaption = false;
                            Style = Strong;
                            StyleExpr = TRUE;
                        }
                        field(AttributeValue1_2Set2; AttributeValue[1] [2] [2])
                        {
                            ApplicationArea = All;
                            Enabled = RowEditable1Set2 AND ColumnEditable2Set2;
                            ShowCaption = false;

                            trigger OnValidate()
                            begin
                                AttributeValueOnValidate(1, 2, 2);
                            end;
                        }
                        field(AttributeValue2_2Set2; AttributeValue[2] [2] [2])
                        {
                            ApplicationArea = All;
                            Enabled = RowEditable2Set2 AND ColumnEditable2Set2;
                            ShowCaption = false;

                            trigger OnValidate()
                            begin
                                AttributeValueOnValidate(2, 2, 2);
                            end;
                        }
                        field(AttributeValue3_2Set2; AttributeValue[3] [2] [2])
                        {
                            ApplicationArea = All;
                            Enabled = RowEditable3Set2 AND ColumnEditable2Set2;
                            ShowCaption = false;

                            trigger OnValidate()
                            begin
                                AttributeValueOnValidate(3, 2, 2);
                            end;
                        }
                        field(AttributeValue4_2Set2; AttributeValue[4] [2] [2])
                        {
                            ApplicationArea = All;
                            Enabled = RowEditable4Set2 AND ColumnEditable2Set2;
                            ShowCaption = false;

                            trigger OnValidate()
                            begin
                                AttributeValueOnValidate(4, 2, 2);
                            end;
                        }
                        field(AttributeValue5_2Set2; AttributeValue[5] [2] [2])
                        {
                            ApplicationArea = All;
                            Enabled = RowEditable5Set2 AND ColumnEditable2Set2;
                            ShowCaption = false;

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
                            ApplicationArea = All;
                            Enabled = false;
                            ShowCaption = false;
                            Style = Strong;
                            StyleExpr = TRUE;
                        }
                        field(AttributeValue1_3Set2; AttributeValue[1] [3] [2])
                        {
                            ApplicationArea = All;
                            Enabled = RowEditable1Set2 AND ColumnEditable3Set2;
                            ShowCaption = false;

                            trigger OnValidate()
                            begin
                                AttributeValueOnValidate(1, 3, 2);
                            end;
                        }
                        field(AttributeValue2_3Set2; AttributeValue[2] [3] [2])
                        {
                            ApplicationArea = All;
                            Enabled = RowEditable2Set2 AND ColumnEditable3Set2;
                            ShowCaption = false;

                            trigger OnValidate()
                            begin
                                AttributeValueOnValidate(2, 3, 2);
                            end;
                        }
                        field(AttributeValue3_3Set2; AttributeValue[3] [3] [2])
                        {
                            ApplicationArea = All;
                            Enabled = RowEditable3Set2 AND ColumnEditable3Set2;
                            ShowCaption = false;

                            trigger OnValidate()
                            begin
                                AttributeValueOnValidate(3, 3, 2);
                            end;
                        }
                        field(AttributeValue4_3Set2; AttributeValue[4] [3] [2])
                        {
                            ApplicationArea = All;
                            Enabled = RowEditable4Set2 AND ColumnEditable3Set2;
                            ShowCaption = false;

                            trigger OnValidate()
                            begin
                                AttributeValueOnValidate(4, 3, 2);
                            end;
                        }
                        field(AttributeValue5_3Set2; AttributeValue[5] [3] [2])
                        {
                            ApplicationArea = All;
                            Enabled = RowEditable5Set2 AND ColumnEditable3Set2;
                            ShowCaption = false;

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
                            ApplicationArea = All;
                            Enabled = false;
                            ShowCaption = false;
                            Style = Strong;
                            StyleExpr = TRUE;
                        }
                        field(AttributeValue1_4Set2; AttributeValue[1] [4] [2])
                        {
                            ApplicationArea = All;
                            Enabled = RowEditable1Set2 AND ColumnEditable4Set2;
                            ShowCaption = false;

                            trigger OnValidate()
                            begin
                                AttributeValueOnValidate(1, 4, 2);
                            end;
                        }
                        field(AttributeValue2_4Set2; AttributeValue[2] [4] [2])
                        {
                            ApplicationArea = All;
                            Enabled = RowEditable2Set2 AND ColumnEditable4Set2;
                            ShowCaption = false;

                            trigger OnValidate()
                            begin
                                AttributeValueOnValidate(2, 4, 2);
                            end;
                        }
                        field(AttributeValue3_4Set2; AttributeValue[3] [4] [2])
                        {
                            ApplicationArea = All;
                            Enabled = RowEditable3Set2 AND ColumnEditable4Set2;
                            ShowCaption = false;

                            trigger OnValidate()
                            begin
                                AttributeValueOnValidate(3, 4, 2);
                            end;
                        }
                        field(AttributeValue4_4Set2; AttributeValue[4] [4] [2])
                        {
                            ApplicationArea = All;
                            Enabled = RowEditable4Set2 AND ColumnEditable4Set2;
                            ShowCaption = false;

                            trigger OnValidate()
                            begin
                                AttributeValueOnValidate(4, 4, 2);
                            end;
                        }
                        field(AttributeValue5_4Set2; AttributeValue[5] [4] [2])
                        {
                            ApplicationArea = All;
                            Enabled = RowEditable5Set2 AND ColumnEditable4Set2;
                            ShowCaption = false;

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
                            ApplicationArea = All;
                            Enabled = false;
                            ShowCaption = false;
                            Style = Strong;
                            StyleExpr = TRUE;
                        }
                        field(AttributeValue1_5Set2; AttributeValue[1] [5] [2])
                        {
                            ApplicationArea = All;
                            Enabled = RowEditable1Set2 AND ColumnEditable5Set2;
                            ShowCaption = false;

                            trigger OnValidate()
                            begin
                                AttributeValueOnValidate(1, 5, 2);
                            end;
                        }
                        field(AttributeValue2_5Set2; AttributeValue[2] [5] [2])
                        {
                            ApplicationArea = All;
                            Enabled = RowEditable2Set2 AND ColumnEditable5Set2;
                            ShowCaption = false;

                            trigger OnValidate()
                            begin
                                AttributeValueOnValidate(2, 5, 2);
                            end;
                        }
                        field(AttributeValue3_5Set2; AttributeValue[3] [5] [2])
                        {
                            ApplicationArea = All;
                            Enabled = RowEditable3Set2 AND ColumnEditable5Set2;
                            ShowCaption = false;

                            trigger OnValidate()
                            begin
                                AttributeValueOnValidate(3, 5, 2);
                            end;
                        }
                        field(AttributeValue4_5Set2; AttributeValue[4] [5] [2])
                        {
                            ApplicationArea = All;
                            Enabled = RowEditable4Set2 AND ColumnEditable5Set2;
                            ShowCaption = false;

                            trigger OnValidate()
                            begin
                                AttributeValueOnValidate(4, 5, 2);
                            end;
                        }
                        field(AttributeValue5_5Set2; AttributeValue[5] [5] [2])
                        {
                            ApplicationArea = All;
                            Enabled = RowEditable5Set2 AND ColumnEditable5Set2;
                            ShowCaption = false;

                            trigger OnValidate()
                            begin
                                AttributeValueOnValidate(5, 5, 2);
                            end;
                        }
                    }
                }
            }
            group(Duration)
            {
                Caption = 'Duration';
                Editable = GlobalEditable;
                field("Preparation Period"; "Preparation Period")
                {
                    ApplicationArea = All;
                }
                field("Starting Date"; "Starting Date")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                }
                field("Starting Time"; "Starting Time")
                {
                    ApplicationArea = All;
                }
                field("Ending Date"; "Ending Date")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                }
                field("Ending Time"; "Ending Time")
                {
                    ApplicationArea = All;
                }
                field("Creation Date"; "Creation Date")
                {
                    ApplicationArea = All;
                }
            }
            part(EventPlanningLinesSubpage; "Event Planning Lines Subpage")
            {
                Editable = GlobalEditable;
                SubPageLink = "Job No." = FIELD("No."),
                              "Group Source Line No." = CONST(0);
            }
            part(Control6014530; "Event Grouped Plan. Lines Sub")
            {
                Editable = GlobalEditable;
                SubPageLink = "Job No." = FIELD("No."),
                              "Group Line" = CONST(true);
                Visible = GroupedLineGroupVisible;
            }
            group("Foreign Trade")
            {
                Caption = 'Foreign Trade';
                Editable = GlobalEditable;
                field("Currency Code"; "Currency Code")
                {
                    ApplicationArea = All;
                    Editable = CurrencyCodeEditable;
                    Importance = Promoted;

                    trigger OnValidate()
                    begin
                        CurrencyCheck;
                    end;
                }
                field("Invoice Currency Code"; "Invoice Currency Code")
                {
                    ApplicationArea = All;
                    Editable = InvoiceCurrencyCodeEditable;

                    trigger OnValidate()
                    begin
                        CurrencyCheck;
                    end;
                }
            }
        }
        area(factboxes)
        {
            part(Control6014404; "Comment Sheet")
            {
                SubPageLink = "Table Name" = CONST(Job),
                              "No." = FIELD("No.");
            }
            part(Control1902018507; "Customer Statistics FactBox")
            {
                SubPageLink = "No." = FIELD("Bill-to Customer No.");
                Visible = false;
            }
            part(Control1902136407; "Job No. of Prices FactBox")
            {
                SubPageLink = "No." = FIELD("No."),
                              "Resource Filter" = FIELD("Resource Filter"),
                              "Posting Date Filter" = FIELD("Posting Date Filter"),
                              "Resource Gr. Filter" = FIELD("Resource Gr. Filter"),
                              "Planning Date Filter" = FIELD("Planning Date Filter");
                Visible = true;
            }
            part(Control1905650007; "Job WIP/Recognition FactBox")
            {
                SubPageLink = "No." = FIELD("No."),
                              "Resource Filter" = FIELD("Resource Filter"),
                              "Posting Date Filter" = FIELD("Posting Date Filter"),
                              "Resource Gr. Filter" = FIELD("Resource Gr. Filter"),
                              "Planning Date Filter" = FIELD("Planning Date Filter");
                Visible = false;
            }
            systempart(Control1900383207; Links)
            {
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                Visible = true;
            }
            part(Control6014421; "Event Atributes Info")
            {
                SubPageLink = "Job No." = FIELD("No.");
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
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    RunObject = Page "Event Task Lines";
                    RunPageLink = "Job No." = FIELD("No.");
                    ShortCutKey = 'Shift+Ctrl+T';
                }
                action("&Dimensions")
                {
                    Caption = '&Dimensions';
                    Image = Dimensions;
                    RunObject = Page "Default Dimensions";
                    RunPageLink = "Table ID" = CONST(167),
                                  "No." = FIELD("No.");
                    ShortCutKey = 'Shift+Ctrl+D';
                }
                action("&Statistics")
                {
                    Caption = '&Statistics';
                    Image = Statistics;
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page "Event Statistics";
                    RunPageLink = "No." = FIELD("No.");
                    ShortCutKey = 'F7';
                }
                action(SalesDocuments)
                {
                    Caption = 'Sales &Documents';
                    Image = GetSourceDoc;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    var
                        EventInvoices: Page "Event Invoices";
                    begin
                        //-NPR5.49 [346693]
                        EventInvoices.SetPrJob(Rec);
                        EventInvoices.RunModal;
                        //+NPR5.49 [346693]
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
                }
                action("&Online Map")
                {
                    Caption = '&Online Map';
                    Image = Map;

                    trigger OnAction()
                    begin
                        DisplayMap;
                    end;
                }
                action(ActivityLog)
                {
                    Caption = 'Activity Log';
                    Image = Log;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    var
                        ActivityLog: Record "Activity Log";
                    begin
                        ActivityLog.ShowEntries(RecordId);
                    end;
                }
                action(Attributes)
                {
                    Caption = 'Attributes';
                    Image = BulletList;
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page "Event Attributes";
                    RunPageLink = "Job No." = FIELD("No.");

                    trigger OnAction()
                    begin
                        //-NPR5.33 [277972]
                        /*
                        EventAttributeMatrix.SetJob(Rec."No.");
                        EventAttributeMatrix.RUN;
                        */
                        //+NPR5.33 [277972]

                    end;
                }
                action(WordLayouts)
                {
                    Caption = 'Word Layouts';
                    Image = Quote;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    var
                        EventWordLayouts: Page "Event Word Layouts";
                    begin
                        EventWordLayouts.SetEvent(Rec);
                        EventWordLayouts.RunModal;
                    end;
                }
                action(ExchIntTemplates)
                {
                    Caption = 'Exch. Int. Templates';
                    Image = InteractionTemplate;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    var
                        EventExchIntTempEntries: Page "Event Exch. Int. Temp. Entries";
                        EventExchIntTempEntry: Record "Event Exch. Int. Temp. Entry";
                    begin
                        EventExchIntTempEntry.SetRange("Source Record ID", Rec.RecordId);
                        EventExchIntTempEntries.SetTableView(EventExchIntTempEntry);
                        EventExchIntTempEntries.Run;
                    end;
                }
                action(ExchIntEmailSummary)
                {
                    Caption = 'Exch. Int. E-mail Summary';
                    Image = ValidateEmailLoggingSetup;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    begin
                        EventEWSMgt.ShowExchIntSummary(Rec);
                    end;
                }
            }
            group("&Prices")
            {
                Caption = '&Prices';
                Image = Price;
                action("&Resource")
                {
                    Caption = '&Resource';
                    Image = Resource;
                    Promoted = true;
                    PromotedCategory = Category4;
                    RunObject = Page "Job Resource Prices";
                    RunPageLink = "Job No." = FIELD("No.");
                }
                action("&Item")
                {
                    Caption = '&Item';
                    Image = Item;
                    Promoted = true;
                    PromotedCategory = Category4;
                    RunObject = Page "Job Item Prices";
                    RunPageLink = "Job No." = FIELD("No.");
                }
                action("&G/L Account")
                {
                    Caption = '&G/L Account';
                    Image = JobPrice;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    RunObject = Page "Job G/L Account Prices";
                    RunPageLink = "Job No." = FIELD("No.");
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
                }
                action("Res. Gr. All&ocated per Job")
                {
                    Caption = 'Res. Gr. All&ocated per Job';
                    Image = ResourceGroup;
                    RunObject = Page "Res. Gr. Allocated per Job";
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
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    RunObject = Page "TM Ticket Schedules";
                }
                action(TicketAdmissions)
                {
                    Caption = 'Ticket Admissions';
                    Image = WorkCenter;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;

                    trigger OnAction()
                    var
                        TicketAdmissions: Page "TM Ticket Admissions";
                        Admission: Record "TM Admission";
                    begin
                        //-NPR5.54 [397743]
                        Admission.SetRange("Admission Code", Rec."Admission Code");
                        if Rec."Admission Code" = '' then
                            Admission.SetRange("Admission Code");
                        TicketAdmissions.SetTableView(Admission);
                        TicketAdmissions.Run;
                        //+NPR5.54 [397743]
                    end;
                }
                action(AdmissionScheduleLines)
                {
                    Caption = 'Admission Schedule Lines';
                    Image = CalendarWorkcenter;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;

                    trigger OnAction()
                    var
                        AdmissionScheduleLines: Page "TM Admission Schedule Lines";
                        AdmissionScheduleLine: Record "TM Admission Schedule Lines";
                    begin
                        //-NPR5.54 [397743]
                        AdmissionScheduleLine.SetRange("Admission Code", Rec."Admission Code");
                        if Rec."Admission Code" = '' then
                            AdmissionScheduleLine.SetRange("Admission Code");
                        AdmissionScheduleLines.SetTableView(AdmissionScheduleLine);
                        AdmissionScheduleLines.Run;
                        //+NPR5.54 [397743]
                    end;
                }
                action(AdmissionScheduleEntry)
                {
                    Caption = 'Admission Schedule Entry';
                    Image = WorkCenterLoad;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    RunObject = Page "TM Admission Schedule Entry";
                    RunPageLink = "Admission Code" = FIELD("Admission Code");
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
                    PromotedCategory = Process;
                    RunObject = Page "Job Ledger Entries";
                    RunPageLink = "Job No." = FIELD("No.");
                    RunPageView = SORTING("Job No.", "Job Task No.", "Entry Type", "Posting Date");
                    ShortCutKey = 'Ctrl+F7';
                }
            }
        }
        area(processing)
        {
            group(ActionGroup6014519)
            {
                Caption = 'Tickets';
                action(CollectTicketPrintouts)
                {
                    Caption = 'Collect Ticket Printouts';
                    Image = GetSourceDoc;

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
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    var
                        CopyJobTasks: Page "Copy Job Tasks";
                    begin
                        CopyJobTasks.SetToJob(Rec);
                        CopyJobTasks.RunModal;
                    end;
                }
                action("Copy Job Tasks &to...")
                {
                    Caption = 'Copy Job Tasks &to...';
                    Ellipsis = true;
                    Image = CopyFromTask;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    var
                        CopyJobTasks: Page "Copy Job Tasks";
                    begin
                        CopyJobTasks.SetFromJob(Rec);
                        CopyJobTasks.RunModal;
                    end;
                }
                action(CopyAttribute)
                {
                    Caption = 'Copy Attributes';
                    Ellipsis = true;
                    Image = Copy;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    var
                        EventCopy: Page "Event Copy Attr./Templ.";
                    begin
                        //-NPR5.31 [269162]
                        //EventCopy.SetFromEvent(Rec,0);
                        EventCopy.SetFromEvent("No.", 0);
                        //+NPR5.31 [269162]
                        EventCopy.RunModal;
                        //-NPR5.31 [269162]
                        CurrPage.Update(false);
                        //+NPR5.31 [269162]
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

                        trigger OnAction()
                        begin
                            //-NPR5.55 [374887]
                            //EventEmailMgt.SendEMail(Rec,0);
                            EventEmailMgt.SendEMail(Rec, 0, 0);
                            //+NPR5.55 [374887]
                            CurrPage.Update(false);
                        end;
                    }
                    action(SendEmailToTeam)
                    {
                        Caption = 'Team';
                        Ellipsis = true;
                        Image = TeamSales;

                        trigger OnAction()
                        begin
                            //-NPR5.55 [374887]
                            //EventEmailMgt.SendEMail(Rec,1);
                            EventEmailMgt.SendEMail(Rec, 1, 0);
                            //+NPR5.55 [374887]
                            CurrPage.Update(false);
                        end;
                    }
                }
            }
        }
        area(reporting)
        {
            action("Job Actual to Budget")
            {
                Caption = 'Job Actual to Budget';
                Image = "Report";
                Promoted = true;
                PromotedCategory = "Report";
                RunObject = Report "Job Actual To Budget";
            }
            action("Job Analysis")
            {
                Caption = 'Job Analysis';
                Image = "Report";
                Promoted = true;
                PromotedCategory = "Report";
                RunObject = Report "Job Analysis";
            }
            action("Job - Planning Lines")
            {
                Caption = 'Job - Planning Lines';
                Image = "Report";
                Promoted = true;
                PromotedCategory = "Report";
                RunObject = Report "Job - Planning Lines";
            }
            action("Job - Suggested Billing")
            {
                Caption = 'Job - Suggested Billing';
                Image = "Report";
                Promoted = true;
                PromotedCategory = "Report";
                RunObject = Report "Job Suggested Billing";
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        i: Integer;
    begin
        CurrencyCheck;
        //-NPR5.33 [277972]
        //-NPR5.31 [269162]
        //GetAttributeTemplateSetup();
        //+NPR5.31 [269162]
        Clear(EventAttributeTemplateName);
        EventAttribute.SetRange("Job No.", "No.");
        EventAttribute.SetRange(Promote, true);
        if EventAttribute.FindSet then
            repeat
                i += 1;
                if i <= ArrayLen(EventAttributeTemplateName) then
                    EventAttributeTemplateName[i] := EventAttribute."Template Name";
            until EventAttribute.Next = 0;
        for i := 1 to ArrayLen(EventAttributeTemplateName) do begin
            GetAttributeTemplateSetup(i);
            AssignTemplateSetupToVariables(i);
        end;
        //+NPR5.33 [277972]
        //-NPR5.53 [374886]
        SetGlobalEditable();
        //+NPR5.53 [374886]
        //-NPR5.55 [397741]
        SetGroupedLineGroupVisibility();
        //+NPR5.55 [397741]
    end;

    trigger OnInit()
    begin
        CurrencyCodeEditable := true;
        InvoiceCurrencyCodeEditable := true;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        "Event" := true;
        //-NPR5.53 [374886]
        SetGlobalEditable();
        //+NPR5.53 [374886]
    end;

    var
        [InDataSet]
        InvoiceCurrencyCodeEditable: Boolean;
        [InDataSet]
        CurrencyCodeEditable: Boolean;
        EventCalendarMgt: Codeunit "Event Calendar Management";
        EventEmailMgt: Codeunit "Event Email Management";
        EventMgt: Codeunit "Event Management";
        WrongCompanyErr: Label 'You cannot select a layout that is specific to another company.';
        EventAttrMgt: Codeunit "Event Attribute Management";
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
        EventAttribute: Record "Event Attribute";
        EventAttributeTemplateName: array[2] of Code[20];
        EventTicketMgt: Codeunit "Event Ticket Management";
        EventEWSMgt: Codeunit "Event EWS Management";
        GlobalEditable: Boolean;
        GroupedLineGroupVisible: Boolean;

    local procedure CurrencyCheck()
    begin
        if "Currency Code" <> '' then
            InvoiceCurrencyCodeEditable := false
        else
            InvoiceCurrencyCodeEditable := true;

        if "Invoice Currency Code" <> '' then
            CurrencyCodeEditable := false
        else
            CurrencyCodeEditable := true;
    end;

    local procedure BilltoCustomerNoOnAfterValidat()
    begin
        CurrPage.Update;
    end;

    local procedure GetAttributeTemplateSetup(AttributeSetNo: Integer)
    var
        EventAttrTemplate: Record "Event Attribute Template";
        EventAttrRowValue: Record "Event Attribute Row Value";
        EventAttrColValue: Record "Event Attribute Column Value";
        EventAttributeEntry: Record "Event Attribute Entry";
        i: Integer;
        j: Integer;
    begin
        //-NPR5.33 [277972]
        /*
        AttributesVisible := "Event Attribute Template Name" <> '';
        IF NOT AttributesVisible THEN
          EXIT;
        EventAttrTemplate.GET("Event Attribute Template Name");
        */
        if EventAttributeTemplateName[AttributeSetNo] = '' then
            exit;
        EventAttrTemplate.Get(EventAttributeTemplateName[AttributeSetNo]);
        //+NPR5.33 [277972]
        if EventAttrTemplate."Row Template Name" = '' then
            exit;
        if EventAttrTemplate."Column Template Name" = '' then
            exit;
        EventAttrRowValue.SetRange("Template Name", EventAttrTemplate."Row Template Name");
        EventAttrRowValue.SetRange(Promote, true);
        EventAttrColValue.SetRange("Template Name", EventAttrTemplate."Column Template Name");
        EventAttrColValue.SetRange(Promote, true);
        //-NPR5.33 [277972]
        /*
        FOR j := 1 TO ARRAYLEN(ColumnCaption) DO BEGIN
          ColumnCaption[j] := '';
          ColumnLineNo[j] := 0;
          IF j = 1 THEN
            ColumnEditable[j] := EventAttrColValue.FINDSET
          ELSE
            ColumnEditable[j] := EventAttrColValue.NEXT <> 0;
          IF ColumnEditable[j] THEN BEGIN
            ColumnCaption[j] := EventAttrColValue.Description;
            ColumnLineNo[j] := EventAttrColValue."Line No.";
          END;
        END;
        FOR i := 1 TO ARRAYLEN(RowDescription) DO BEGIN
          RowDescription[i] := '';
          RowLineNo[i] := 0;
          IF i = 1 THEN
            RowEditable[i] := EventAttrRowValue.FINDSET
          ELSE
            RowEditable[i] := EventAttrRowValue.NEXT <> 0;
          IF RowEditable[i] THEN BEGIN
            RowEditable[i] := EventAttrRowValue.Type = EventAttrRowValue.Type::" ";
            RowDescription[i] := EventAttrRowValue.Description;
            RowLineNo[i] := EventAttrRowValue."Line No.";
          END;
          FOR j := 1 TO ARRAYLEN(ColumnCaption) DO BEGIN
            AttributeValue[i][j] := '';
            EventAttributeEntry.SETRANGE("Template Name","Event Attribute Template Name");
            EventAttributeEntry.SETRANGE("Job No.",Rec."No.");
            EventAttributeEntry.SETRANGE("Row Line No.",RowLineNo[i]);
            EventAttributeEntry.SETRANGE("Collumn Line No.",ColumnLineNo[j]);
            IF EventAttributeEntry.FINDFIRST THEN
              AttributeValue[i][j] := EventAttributeEntry."Value Text";
          END;
        END;
        
        RowEditable1Set1 := RowEditable[1][AttributeSetNo];
        RowEditable2Set1 := RowEditable[2][AttributeSetNo];
        RowEditable3Set1 := RowEditable[3][AttributeSetNo];
        RowEditable4Set1 := RowEditable[4][AttributeSetNo];
        RowEditable5Set1 := RowEditable[5][AttributeSetNo];
        RowDescription1Set1 := RowDescription[1][AttributeSetNo];
        RowDescription2Set1 := RowDescription[2][AttributeSetNo];
        RowDescription3Set1 := RowDescription[3][AttributeSetNo];
        RowDescription4Set1 := RowDescription[4][AttributeSetNo];
        RowDescription5Set1 := RowDescription[5][AttributeSetNo];
        
        ColumnEditable1Set1 := ColumnEditable[1][AttributeSetNo];
        ColumnEditable2Set1 := ColumnEditable[2][AttributeSetNo];
        ColumnEditable3Set1 := ColumnEditable[3][AttributeSetNo];
        ColumnEditable4Set1 := ColumnEditable[4][AttributeSetNo];
        ColumnEditable5Set1 := ColumnEditable[5][AttributeSetNo];
        ColumnCaption1Set1 := ColumnCaption[1][AttributeSetNo];
        ColumnCaption2Set1 := ColumnCaption[2][AttributeSetNo];
        ColumnCaption3Set1 := ColumnCaption[3][AttributeSetNo];
        ColumnCaption4Set1 := ColumnCaption[4][AttributeSetNo];
        ColumnCaption5Set1 := ColumnCaption[5][AttributeSetNo];
        */

        for j := 1 to ArrayLen(ColumnCaption, 1) do begin
            ColumnCaption[j] [AttributeSetNo] := '';
            ColumnLineNo[j] [AttributeSetNo] := 0;
            if j = 1 then
                ColumnEditable[j] [AttributeSetNo] := EventAttrColValue.FindSet
            else
                ColumnEditable[j] [AttributeSetNo] := EventAttrColValue.Next <> 0;
            if ColumnEditable[j] [AttributeSetNo] then begin
                ColumnCaption[j] [AttributeSetNo] := EventAttrColValue.Description;
                ColumnLineNo[j] [AttributeSetNo] := EventAttrColValue."Line No.";
            end;
        end;
        for i := 1 to ArrayLen(RowDescription, 1) do begin
            RowDescription[i] [AttributeSetNo] := '';
            RowLineNo[i] [AttributeSetNo] := 0;
            if i = 1 then
                RowEditable[i] [AttributeSetNo] := EventAttrRowValue.FindSet
            else
                RowEditable[i] [AttributeSetNo] := EventAttrRowValue.Next <> 0;
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
                if EventAttributeEntry.FindFirst then
                    AttributeValue[i] [j] [AttributeSetNo] := EventAttributeEntry."Value Text";
            end;
        end;
        //+NPR5.33 [277972]

    end;

    local procedure AttributeValueOnValidate(RowNo: Integer; ColumnNo: Integer; AttributeSetNo: Integer)
    begin
        //-NPR5.33 [277972]
        //-NPR5.33 [277946]
        //EventAttrMgt.CheckAndUpdate("Event Attribute Template Name","No.",RowLineNo[RowNo],CollumnLineNo[CollumnNo],CollumnCaption[CollumnNo],AttributeValue[RowNo][CollumnNo]);
        //EventAttrMgt.CheckAndUpdate("Event Attribute Template Name","No.",RowLineNo[RowNo],ColumnLineNo[ColumnNo],ColumnCaption[ColumnNo],AttributeValue[RowNo][ColumnNo],FALSE,'');
        //+NPR5.33 [277946]
        EventAttrMgt.CheckAndUpdate(EventAttributeTemplateName[AttributeSetNo], "No.", RowLineNo[RowNo] [AttributeSetNo], ColumnLineNo[ColumnNo] [AttributeSetNo], ColumnCaption[ColumnNo] [AttributeSetNo], AttributeValue[RowNo] [ColumnNo] [AttributeSetNo], false, '')
        ;
        //+NPR5.33 [277972]
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
        //-NPR5.53 [374886]
        GlobalEditable := not Locked;
        //+NPR5.53 [374886]
    end;

    local procedure SetGroupedLineGroupVisibility()
    var
        JobPlanningLine: Record "Job Planning Line";
    begin
        //-NPR5.55 [397741]
        JobPlanningLine.SetRange("Job No.", Rec."No.");
        JobPlanningLine.SetFilter("Group Source Line No.", '<>0');
        GroupedLineGroupVisible := not JobPlanningLine.IsEmpty;
        //+NPR5.55 [397741]
    end;
}

