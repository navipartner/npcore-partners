page 6014423 "Report Selection - Retail"
{
    // NPR4.15/JDH/20150909 CASE 222525 Translated to English + changed caption values
    // NPR4.18/MMV/20151217 CASE 225584 Added fields 12, 13.
    // NPR4.18/MMV/20151230 CASE 229221 Blanked "Report Type" options: Label (Single) & Byttem�rke (Single) - They are deprecated.
    // NPR5.22/MMV/20160408 CASE 232067 Added "Report Type" options: "CustomerLocationOnSave" & "CustomerLocationOnTrigger"
    //                                  Added missing "Report Type" option captions.
    //                                  Renamed english page caption to match other report selection pages.
    // NPR5.23/MMV/20160510 CASE 240211 Added field 15.
    //                                  Added "Report Type" option: "Sign"
    // NPR5.29/MMV /20161215 CASE 253966 Added "Report Type" option: "Bin Label".
    // NPR5.29/MMV /20161215 CASE 241549 Deprecated several options and fields.
    //                                   Set Data Port fields to visible = FALSE as default.
    //                                   Changed default field ordering to match Object Output page.
    // NPR5.32/MMV /20170501 CASE 241995 Renamed option in report type.
    // NPR5.39/MMV /20180208 CASE 304165 New types for POS Entry prints.
    // NPR5.40/MMV /20180328 CASE 276562 Renamed option
    // NPR5.42/ZESO/20180517 CASE 312186 Added new option Large Balancing (POS Entry) to variable ReportType2.
    // NPR5.50/TSA /20190423 CASE 352483 Added Report Type "Begin Workshift (POS Entry)"

    Caption = 'Report Selection - Retail';
    DelayedInsert = true;
    Editable = true;
    PageType = Worksheet;
    SaveValues = true;
    SourceTable = "Report Selection Retail";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(Control6150624)
            {
                ShowCaption = false;
                field(ReportType2;ReportType2)
                {
                    OptionCaption = 'Sales Receipt,Register Balancing,Price Label,Signature Receipt,Gift Voucher,,Credit Voucher,,Terminal Receipt,Large Sales Receipt,,,Exchange Label,,Customer Sales Receipt,Rental,Tailor,Order,Photo Label,,,,Warranty Certificate,Shelf Label,,,,,CustomerLocationOnSave,CustomerLocationOnTrigger,Sign,Bin Label,Sales Receipt (POS Entry),Large Sales Receipt (POS Entry),Balancing (POS Entry),Sales Doc. Confirmation (POS Entry),Large Balancing (POS Entry),Begin Workshift (POS Entry)';
                    ShowCaption = false;

                    trigger OnValidate()
                    begin
                        SetUsageFilter;
                        ReportUsage2OnAfterValidate;
                    end;
                }
            }
            repeater(Control6150626)
            {
                ShowCaption = false;
                field(Sequence;Sequence)
                {
                }
                field("Register No.";"Register No.")
                {
                }
                field("Report ID";"Report ID")
                {
                }
                field("Report Name";"Report Name")
                {
                }
                field("XML Port ID";"XML Port ID")
                {
                    Visible = false;
                }
                field("XML Port Name";"XML Port Name")
                {
                    Visible = false;
                }
                field("Codeunit ID";"Codeunit ID")
                {
                }
                field("Codeunit Name";"Codeunit Name")
                {
                }
                field("Print Template";"Print Template")
                {
                    Width = 20;
                }
                field("Filter Object ID";"Filter Object ID")
                {
                }
                field("Record Filter";"Record Filter")
                {
                    AssistEdit = true;

                    trigger OnAssistEdit()
                    var
                        TableFilter: Record "Table Filter";
                        TableFilterPage: Page "Table Filter";
                        AllObjWithCaption: Record AllObjWithCaption;
                        TableCaption: Text;
                    begin
                        //-NPR4.18
                        AllObjWithCaption.SetRange("Object Type", AllObjWithCaption."Object Type"::Table);
                        AllObjWithCaption.SetRange("Object ID", "Filter Object ID");
                        if AllObjWithCaption.FindFirst then
                          TableCaption := AllObjWithCaption."Object Caption";


                        TableFilter.FilterGroup(2);
                        TableFilter.SetRange("Table Number", "Filter Object ID");
                        TableFilter.FilterGroup(0);
                        TableFilterPage.SetTableView(TableFilter);
                        TableFilterPage.SetSourceTable(Format("Record Filter"),"Filter Object ID", TableCaption);
                        if ACTION::OK = TableFilterPage.RunModal then
                          Evaluate("Record Filter",TableFilterPage.CreateTextTableFilter(false));
                        //+NPR4.18
                    end;
                }
                field(Optional;Optional)
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("Function")
            {
                Caption = 'Functions';
                action(List)
                {
                    Caption = '&List';
                    Image = Report2;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    RunObject = Page "Retail Report Selection List";
                    ShortCutKey = 'F5';
                }
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        NewRecord;
    end;

    trigger OnOpenPage()
    begin
        SetUsageFilter;
    end;

    var
        ReportType2: Option "Sales Receipt","Register Balancing","Price Label","Signature Receipt","Gift Voucher",,"Credit Voucher",,"Terminal Receipt","Large Sales Receipt",,,"Exchange Label",,"Customer Sales Receipt",Rental,Tailor,"Order","Photo Label",,,,"Warranty Certificate","Shelf Label",,,,,CustomerLocationOnSave,CustomerLocationOnTrigger,Sign,"Bin Label","Sales Receipt (POS Entry)","Large Sales Receipt (POS Entry)","Balancing (POS Entry)","Sales Doc. Confirmation (POS Entry)","Large Balancing (POS Entry)","Begin Workshift (POS Entry)";

    local procedure SetUsageFilter()
    begin
        FilterGroup(2);
        SetRange("Report Type",ReportType2);
        FilterGroup(0);
    end;

    local procedure ReportUsage2OnAfterValidate()
    begin
        CurrPage.Update;
    end;
}

