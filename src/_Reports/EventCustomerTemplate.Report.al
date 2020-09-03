report 6060150 "NPR Event Customer Template"
{
    // NPR5.29/NPKNAV/20170127  CASE 248723 Transport NPR5.29 - 27 januar 2017
    // NPR5.30/TJ  /20170301 CASE 265580 Fixed DataItemLink property on data item Job Planning Line to properly show only lines for appropriate job
    // NPR5.30/TJ  /20170302 CASE 267566 Added new dataitems and controls, cleaned unused fields from datasets
    //                                   Removed word layout from report definition
    //                                   Formatting date based on windows language setting
    // NPR5.31/TJ  /20170419 CASE 269162 Changed how attributes are fetched
    // NPR5.33/TJ  /20170606 CASE 277946 Function EventAttributeEntryAction has additional arguments
    // NPR5.33/TJ  /20170606 CASE 277972 Changed how attributes are fetched
    //                                   Removed some global variables and moved code from Event Attribute - OnPreDataItem and Event Attribute - OnAfterGetRecord to Event Attribute Management codeunit
    //                                   Renamed DataItem Event Attribute to Event Attribute Set 1
    //                                   Added new dataitem Event Attribute Set 2
    //                                   Renamed some variables to be gramatically correct
    // NPR5.35/TJ  /20170818 CASE 287270 Fixed a problem with report creation when there are no attributes on the event
    // NPR5.38/TJ  /20171006 CASE 291965 Added new columns to dataitems Job and ItemLine
    //                                   Item lines that will not be contracted are shown with 0 value
    // NPR5.41/TJ  /20180409 CASE 310426 Not showing rows for attributes which don't have values for any column
    // NPR5.48/TJ  /20181217 CASE 310452 Fixed deployed under 5.41 was pointing to wrong case no. Using proper case no. now
    // NPR5.48/TJ  /20181217 CASE 310426 Using new field Comments for Customer
    // NPR5.51/TJ  /20190611 CASE 357701 Field Picture_Job removed from dataset
    // NPR5.54/TJ  /20200302 CASE 392832 Added "Description 2", "Planning Date", "Starting Time" and "Ending Time" under ItemLine
    //                                   Added "Creation Date" and "VAT Registration No." under Job
    //                                   Formatting all time fields with new FormatTime function
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Event Customer Template.rdlc';

    Caption = 'Event Customer Template';

    dataset
    {
        dataitem(Job; Job)
        {
            RequestFilterFields = "No.";
            column(No_Job; Job."No.")
            {
            }
            column(Description_Job; Job.Description)
            {
            }
            column(BilltoCustomerNo_Job; Job."Bill-to Customer No.")
            {
            }
            column(StartingDate_Job; FormatDate(Job."Starting Date"))
            {
            }
            column(EndingDate_Job; FormatDate(Job."Ending Date"))
            {
            }
            column(PersonResponsibleName_Job; Resource.Name)
            {
            }
            column(JobPostingGroup_Job; Job."Job Posting Group")
            {
            }
            column(Blocked_Job; Job.Blocked)
            {
            }
            column(LastDateModified_Job; FormatDate(Job."Last Date Modified"))
            {
            }
            column(BilltoName_Job; Job."Bill-to Name")
            {
            }
            column(BilltoAddress_Job; Job."Bill-to Address")
            {
            }
            column(BilltoAddress2_Job; Job."Bill-to Address 2")
            {
            }
            column(BilltoCity_Job; Job."Bill-to City")
            {
            }
            column(BilltoPostCode_Job; Job."Bill-to Post Code")
            {
            }
            column(BilltoCountryRegionCode_Job; Job."Bill-to Country/Region Code")
            {
            }
            column(CurrencyCode_Job; Job."Currency Code")
            {
            }
            column(BilltoContactNo_Job; Job."Bill-to Contact No.")
            {
            }
            column(BilltoContact_Job; Job."Bill-to Contact")
            {
            }
            column(InvoiceCurrencyCode_Job; Job."Invoice Currency Code")
            {
            }
            column(StartingTime_Job; FormatTime(Job."NPR Starting Time"))
            {
            }
            column(EndingTime_Job; FormatTime(Job."NPR Ending Time"))
            {
            }
            column(PreparationPeriod_Job; Job."NPR Preparation Period")
            {
            }
            column(EventStatus_Job; Job."NPR Event Status")
            {
            }
            column(SalespersonName_Job; SalespersonPurchaser.Name)
            {
            }
            column(BilltoEMail_Job; Job."NPR Bill-to E-Mail")
            {
            }
            column(PhoneNo_Job; Customer."Phone No.")
            {
            }
            column(CommentsForCustomer_Job; CommentsForCustomer)
            {
            }
            column(CreationDate_Job; FormatDate(Job."Creation Date"))
            {
            }
            column(VATRegistrationNo_Job; Customer."VAT Registration No.")
            {
            }
            dataitem("Job Task"; "Job Task")
            {
                DataItemLink = "Job No." = FIELD("No.");
                column(JobTaskNo_JobTask; "Job Task"."Job Task No.")
                {
                }
                column(Description_JobTask; "Job Task".Description)
                {
                }
                column(JobTaskType_JobTask; "Job Task"."Job Task Type")
                {
                }
                column(JobPostingGroup_JobTask; "Job Task"."Job Posting Group")
                {
                }
                column(ScheduleTotalCost_JobTask; "Job Task"."Schedule (Total Cost)")
                {
                }
                column(ScheduleTotalPrice_JobTask; "Job Task"."Schedule (Total Price)")
                {
                }
                column(UsageTotalCost_JobTask; "Job Task"."Usage (Total Cost)")
                {
                }
                column(UsageTotalPrice_JobTask; "Job Task"."Usage (Total Price)")
                {
                }
                column(ContractTotalCost_JobTask; "Job Task"."Contract (Total Cost)")
                {
                }
                column(ContractTotalPrice_JobTask; "Job Task"."Contract (Total Price)")
                {
                }
                column(ContractInvoicedPrice_JobTask; "Job Task"."Contract (Invoiced Price)")
                {
                }
                column(ContractInvoicedCost_JobTask; "Job Task"."Contract (Invoiced Cost)")
                {
                }
                column(OutstandingOrders_JobTask; "Job Task"."Outstanding Orders")
                {
                }
                column(AmtRcdNotInvoiced_JobTask; "Job Task"."Amt. Rcd. Not Invoiced")
                {
                }
                column(RemainingTotalCost_JobTask; "Job Task"."Remaining (Total Cost)")
                {
                }
                column(RemainingTotalPrice_JobTask; "Job Task"."Remaining (Total Price)")
                {
                }
                column(StartDate_JobTask; FormatDate("Job Task"."Start Date"))
                {
                }
                column(EndDate_JobTask; FormatDate("Job Task"."End Date"))
                {
                }
                dataitem(TextLine; "Job Planning Line")
                {
                    DataItemLink = "Job No." = FIELD("Job No."), "Job Task No." = FIELD("Job Task No.");
                    DataItemTableView = WHERE(Type = CONST(Text));
                    RequestFilterHeading = 'Text Line';
                    column(Description_TextLine; TextLine.Description)
                    {
                    }
                    column(PlanningDate_TextLine; FormatDate(TextLine."Planning Date"))
                    {
                    }
                    column(StartingTime_TextLine; FormatTime(TextLine."NPR Starting Time"))
                    {
                    }
                    column(EndingTime_TextLine; FormatTime(TextLine."NPR Ending Time"))
                    {
                    }
                }
                dataitem(ResourceLine; "Job Planning Line")
                {
                    DataItemLink = "Job No." = FIELD("Job No."), "Job Task No." = FIELD("Job Task No.");
                    DataItemTableView = WHERE(Type = CONST(Resource));
                    RequestFilterHeading = 'Resource Line';
                    column(PlanningDate_ResourceLine; FormatDate(ResourceLine."Planning Date"))
                    {
                    }
                    column(Description_ResourceLine; ResourceLine.Description)
                    {
                    }
                    column(StartingTime_ResourceLine; FormatTime(ResourceLine."NPR Starting Time"))
                    {
                    }
                    column(EndingTime_ResourceLine; FormatTime(ResourceLine."NPR Ending Time"))
                    {
                    }
                    column(Quantity_ResourceLine; ResourceLine.Quantity)
                    {
                    }
                    column(UnitofMeasureCode_ResourceLine; ResourceLine."Unit of Measure Code")
                    {
                    }
                    column(ResourceEMail_ResourceLine; ResourceLine."NPR Resource E-Mail")
                    {
                    }
                }
                dataitem(ItemLine; "Job Planning Line")
                {
                    DataItemLink = "Job No." = FIELD("Job No."), "Job Task No." = FIELD("Job Task No.");
                    DataItemTableView = WHERE(Type = CONST(Item));
                    RequestFilterHeading = 'Item Line';
                    column(PlanningDate_ItemLine; FormatDate(ItemLine."Planning Date"))
                    {
                    }
                    column(StartingTime_ItemLine; FormatTime(ItemLine."NPR Starting Time"))
                    {
                    }
                    column(EndingTime_ItemLine; FormatTime(ItemLine."NPR Ending Time"))
                    {
                    }
                    column(No_ItemLine; ItemLine."No.")
                    {
                    }
                    column(Description_ItemLine; ItemLine.Description)
                    {
                    }
                    column(Description2_ItemLine; ItemLine."Description 2")
                    {
                    }
                    column(Quantity_ItemLine; ItemLine.Quantity)
                    {
                    }
                    column(UnitPrice_ItemLine; ItemLine."Unit Price")
                    {
                    }
                    column(LineDiscountAmount_ItemLine; ItemLine."Line Discount Amount")
                    {
                    }
                    column(LineDiscount_ItemLine; ItemLine."Line Discount %")
                    {
                    }
                    column(LineAmount_ItemLine; ItemLine."Line Amount")
                    {
                    }
                    column(UnitofMeasureCode_ItemLine; ItemLine."Unit of Measure Code")
                    {
                    }
                    column(TotalAmount_ItemLine; TotalAmount)
                    {
                    }
                    column(EstUnitPriceInclVAT_ItemLine; ItemLine."NPR Est. Unit Price Incl. VAT")
                    {
                    }
                    column(EstLineAmountInclVAT_ItemLine; ItemLine."NPR Est. Line Amount Incl. VAT")
                    {
                    }
                    column(EstVATPct_ItemLine; ItemLine."NPR Est. VAT %")
                    {
                    }
                    column(EstTotalAmtInclVAT_ItemLine; EstTotalAmtInclVAT)
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        //-NPR5.38 [291695]
                        if not ItemLine."Contract Line" then begin
                            ItemLine."Unit Price" := 0;
                            ItemLine."Line Discount Amount" := 0;
                            ItemLine."Line Discount %" := 0;
                            ItemLine."Line Amount" := 0;
                            ItemLine."NPR Est. Unit Price Incl. VAT" := 0;
                            ItemLine."NPR Est. Line Amount Incl. VAT" := 0;
                            ItemLine."NPR Est. VAT %" := 0;
                        end;
                        //+NPR5.38 [291695]
                    end;

                    trigger OnPreDataItem()
                    begin
                        //-NPR5.30 [267566]
                        ItemLineTotal.SetRange("Job No.", Job."No.");
                        ItemLineTotal.SetRange("Job Task No.", "Job Task"."Job Task No.");
                        ItemLineTotal.SetRange(Type, ItemLineTotal.Type::Item);
                        if ItemLineTotal.FindSet then
                            repeat
                                //-NPR5.38 [291695]
                                if ItemLineTotal."Contract Line" then begin
                                    //+NPR5.38 [291695]
                                    TotalAmount += ItemLineTotal."Line Amount";
                                    //-NPR5.38 [291695]
                                    EstTotalAmtInclVAT += ItemLineTotal."NPR Est. Line Amount Incl. VAT";
                                end;
                            //+NPR5.38 [291695]
                            until ItemLineTotal.Next = 0;
                        //+NPR5.30 [267566]
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    //-NPR5.30 [267566]
                    TotalAmount := 0;
                    //+NPR5.30 [267566]
                end;
            }
            dataitem("Event Attribute Set 1"; "NPR Event Attr. Row Value")
            {
                DataItemTableView = SORTING("Template Name", "Line No.");
                column(AtributeDescription_EventAttributeSet1; "Event Attribute Set 1".Description)
                {
                }
                column(ColumnCaption1_EventAttributeSet1; ColumnCaption[1])
                {
                }
                column(ColumnCaption2_EventAttributeSet1; ColumnCaption[2])
                {
                }
                column(ColumnCaption3_EventAttributeSet1; ColumnCaption[3])
                {
                }
                column(ColumnCaption4_EventAttributeSet1; ColumnCaption[4])
                {
                }
                column(ColumnCaption5_EventAttributeSet1; ColumnCaption[5])
                {
                }
                column(AttributeValue1_EventAttributeSet1; AttributeValue[1])
                {
                }
                column(AttributeValue2_EventAttributeSet1; AttributeValue[2])
                {
                }
                column(AttributeValue3_EventAttributeSet1; AttributeValue[3])
                {
                }
                column(AttributeValue4_EventAttributeSet1; AttributeValue[4])
                {
                }
                column(AttributeValue5_EventAttributeSet1; AttributeValue[5])
                {
                }

                trigger OnAfterGetRecord()
                var
                    i: Integer;
                    SkipRow: Boolean;
                begin
                    //-NPR5.33 [277972]
                    /*
                    //-NPR5.31 [269162]
                    IF EventAttrCollumnValue.FINDSET THEN
                      REPEAT
                        i += 1;
                        AttributeValue[i] := '';
                        CollumnCaption[i] := EventAttrCollumnValue.Description;
                        //-NPR5.33 [277946]
                        //EventAttrMgt.EventAttributeEntryAction(2,EventAttributeTemplate.Name,Job."No.","Line No.",EventAttrCollumnValue."Line No.",EventAttrCollumnValue.Description,AttributeValue[i]);
                        EventAttrMgt.EventAttributeEntryAction(2,EventAttributeTemplate.Name,Job."No.","Line No.",EventAttrCollumnValue."Line No.",EventAttrCollumnValue.Description,AttributeValue[i],FALSE,'');
                        //-NPR5.33 [277946]
                      UNTIL (EventAttrCollumnValue.NEXT = 0) OR (i = ARRAYLEN(AttributeValue));
                    //+NPR5.31 [269162]
                    */
                    EventAttrMgt.EventTemplateReportEventAttributeSetOnAfterGetRecord("Event Attribute Set 1", AttributeValue, ColumnCaption, Job."No.");
                    //+NPR5.33 [277972]
                    //-NPR5.41 [310452]
                    SkipRow := true;
                    for i := 1 to ArrayLen(AttributeValue) do
                        SkipRow := SkipRow and (AttributeValue[i] = '');
                    if SkipRow then
                        CurrReport.Skip;
                    //+NPR5.41 [310452]

                end;

                trigger OnPreDataItem()
                begin
                    //-NPR5.33 [277972]
                    /*
                    //-NPR5.31 [269162]
                    IF Job."Event Attribute Template Name" = '' THEN
                      CurrReport.BREAK;
                    EventAttributeTemplate.GET(Job."Event Attribute Template Name");
                    SETRANGE("Template Name",EventAttributeTemplate."Row Template Name");
                    SETRANGE(Promote,TRUE);
                    EventAttrCollumnValue.SETRANGE("Template Name",EventAttributeTemplate."Column Template Name");
                    EventAttrCollumnValue.SETRANGE(Promote,TRUE);
                    //+NPR5.31 [269162]
                    */
                    Clear(AttributeValue);
                    Clear(ColumnCaption);
                    //-NPR5.35 [287270]
                    //EventAttrMgt.EventTemplateReportEventAttributeSetOnPreDataItem(EventAttributeTempName1,"Event Attribute Set 1");
                    if not EventAttrMgt.EventTemplateReportEventAttributeSetOnPreDataItem(EventAttributeTempName1, "Event Attribute Set 1") then
                        CurrReport.Break;
                    //+NPR5.35 [287270]
                    //+NPR5.33 [277972]

                end;
            }
            dataitem("Event Attribute Set 2"; "NPR Event Attr. Row Value")
            {
                DataItemTableView = SORTING("Template Name", "Line No.");
                column(AtributeDescription_EventAttributeSet2; "Event Attribute Set 2".Description)
                {
                }
                column(ColumnCaption1_EventAttributeSet2; ColumnCaption[1])
                {
                }
                column(ColumnCaption2_EventAttributeSet2; ColumnCaption[2])
                {
                }
                column(ColumnCaption3_EventAttributeSet2; ColumnCaption[3])
                {
                }
                column(ColumnCaption4_EventAttributeSet2; ColumnCaption[4])
                {
                }
                column(ColumnCaption5_EventAttributeSet2; ColumnCaption[5])
                {
                }
                column(AttributeValue1_EventAttributeSet2; AttributeValue[1])
                {
                }
                column(AttributeValue2_EventAttributeSet2; AttributeValue[2])
                {
                }
                column(AttributeValue3_EventAttributeSet2; AttributeValue[3])
                {
                }
                column(AttributeValue4_EventAttributeSet2; AttributeValue[4])
                {
                }
                column(AttributeValue5_EventAttributeSet2; AttributeValue[5])
                {
                }

                trigger OnAfterGetRecord()
                var
                    i: Integer;
                    SkipRow: Boolean;
                begin
                    //-NPR5.33 [277972]
                    EventAttrMgt.EventTemplateReportEventAttributeSetOnAfterGetRecord("Event Attribute Set 2", AttributeValue, ColumnCaption, Job."No.");
                    //+NPR5.33 [277972]
                    //-NPR5.41 [310452]
                    SkipRow := true;
                    for i := 1 to ArrayLen(AttributeValue) do
                        SkipRow := SkipRow and (AttributeValue[i] = '');
                    if SkipRow then
                        CurrReport.Skip;
                    //+NPR5.41 [310452]
                end;

                trigger OnPreDataItem()
                begin
                    //-NPR5.33 [277972]
                    Clear(AttributeValue);
                    Clear(ColumnCaption);
                    Clear(EventAttrMgt);
                    //-NPR5.35 [287270]
                    //EventAttrMgt.EventTemplateReportEventAttributeSetOnPreDataItem(EventAttributeTempName2,"Event Attribute Set 2");
                    if not EventAttrMgt.EventTemplateReportEventAttributeSetOnPreDataItem(EventAttributeTempName2, "Event Attribute Set 2") then
                        CurrReport.Break;
                    //+NPR5.35 [287270]
                    //+NPR5.33 [277972]
                end;
            }
            dataitem("Comment Line"; "Comment Line")
            {
                DataItemLink = "No." = FIELD("No.");
                DataItemTableView = SORTING("Table Name", "No.", "Line No.") WHERE("Table Name" = CONST(Job));
                column(Comment_CommentLine; "Comment Line".Comment)
                {
                }
            }

            trigger OnAfterGetRecord()
            begin
                //-NPR5.30 [267566]
                if not Customer.Get("Bill-to Customer No.") then
                    Clear(Customer);
                if not SalespersonPurchaser.Get(Customer."Salesperson Code") then
                    Clear(SalespersonPurchaser);
                if not Resource.Get("Person Responsible") then
                    Clear(Resource);
                //+NPR5.30 [267566]
                //-NPR5.33 [277972]
                EventAttribute.SetRange("Job No.", "No.");
                EventAttribute.SetRange(Promote, true);
                if EventAttribute.FindSet then
                    EventAttributeTempName1 := EventAttribute."Template Name";
                if EventAttribute.Next <> 0 then
                    EventAttributeTempName2 := EventAttribute."Template Name";
                //+NPR5.33 [277972]
                //-NPR5.48 [310426]
                CommentsForCustomer := '';
                CommentLine.SetRange("Table Name", CommentLine."Table Name"::Job);
                CommentLine.SetRange("No.", Job."No.");
                if CommentLine.FindSet then
                    repeat
                        CommentsForCustomer += CommentLine.Comment;
                    until CommentLine.Next = 0;
                //+NPR5.48 [310426]
            end;
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }

    var
        Customer: Record Customer;
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        Resource: Record Resource;
        FromToText: Label 'From %1 to %2: ';
        TotalAmount: Decimal;
        ItemLineTotal: Record "Job Planning Line";
        AttributeValue: array[5] of Text;
        ColumnCaption: array[5] of Text;
        EventAttribute: Record "NPR Event Attribute";
        EventAttributeTempName1: Code[20];
        EventAttributeTempName2: Code[20];
        EventAttrMgt: Codeunit "NPR Event Attribute Mgt.";
        EstTotalAmtInclVAT: Decimal;
        CommentsForCustomer: Text;
        CommentLine: Record "Comment Line";

    local procedure FormatDate(Date: Date): Text
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        if Date <> 0D then
            exit(TypeHelper.FormatDate(Date, WindowsLanguage));
        exit('');
    end;

    local procedure FormatTime(Time: Time): Text
    begin
        //-NPR5.54 [392832]
        if Time <> 0T then
            exit(Format(Time, 0, '<Hours24,2><Filler Character,0>:<Minutes,2>'));
        exit('');
        //+NPR5.54 [392832]
    end;
}

