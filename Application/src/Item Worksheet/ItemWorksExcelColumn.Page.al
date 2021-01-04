page 6060053 "NPR Item Works. Excel Column"
{
    // NPR5.22\BR\20160321  CASE 182391 Added support for mapping an Excel file
    // NPR5.25\BR \20160712 CASE 246088 Added Action To add Mapping
    // NPR5.48/TS  /20181206 CASE 338656 Added Missing Picture to Action

    Caption = 'Item Worksheet Excel Column';
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR Item Worksh. Excel Column";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Excel Column"; "Excel Column")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Excel Column field';
                }
                field("Excel Header Text"; "Excel Header Text")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Excel Header Text field';
                }
                field("Sample Data Row 1"; "Sample Data Row 1")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Sample Data Row 1 field';
                }
                field("Sample Data Row 2"; "Sample Data Row 2")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Sample Data Row 2 field';
                }
                field("Sample Data Row 3"; "Sample Data Row 3")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Sample Data Row 3 field';
                }
                field("Process as"; "Process as")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Process as field';
                }
                field("Map to Caption"; "Map to Caption")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Map to Caption field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Select Excel to Map")
            {
                Caption = 'Select Excel to Map';
                Image = ImportExcel;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Select Excel to Map action';

                trigger OnAction()
                begin
                    GetCurrentWorksheet;
                    ItemWshtImpExpMgt.SelectExcelToMap(ItemWorksheet);
                end;
            }
            action(InsertMappedFields)
            {
                Caption = 'Insert all Mapped fields in Excel Mapping';
                Image = Add;
                ApplicationArea = All;
                ToolTip = 'Executes the Insert all Mapped fields in Excel Mapping action';

                trigger OnAction()
                var
                    ItemWorksheetManagement: Codeunit "NPR Item Worksheet Mgt.";
                begin
                    GetCurrentWorksheet;
                    ItemWorksheetManagement.AddMappedFieldsToExcel(ItemWorksheet."Item Template Name", ItemWorksheet.Name);
                end;
            }
        }
    }

    var
        ItemWorksheet: Record "NPR Item Worksheet";
        ItemWshtImpExpMgt: Codeunit "NPR Item Wsht. Imp. Exp.";

    procedure GetCurrentWorksheet()
    begin
        ItemWorksheet.Get(GetRangeMax("Worksheet Template Name"), GetRangeMax("Worksheet Name"));
    end;
}

