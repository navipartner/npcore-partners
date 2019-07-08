page 6060053 "Item Worksheet Excel Column"
{
    // NPR5.22\BR\20160321  CASE 182391 Added support for mapping an Excel file
    // NPR5.25\BR \20160712 CASE 246088 Added Action To add Mapping
    // NPR5.48/TS  /20181206 CASE 338656 Added Missing Picture to Action

    Caption = 'Item Worksheet Excel Column';
    PageType = List;
    SourceTable = "Item Worksheet Excel Column";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Excel Column";"Excel Column")
                {
                }
                field("Excel Header Text";"Excel Header Text")
                {
                }
                field("Sample Data Row 1";"Sample Data Row 1")
                {
                    Editable = false;
                }
                field("Sample Data Row 2";"Sample Data Row 2")
                {
                    Editable = false;
                }
                field("Sample Data Row 3";"Sample Data Row 3")
                {
                    Editable = false;
                }
                field("Process as";"Process as")
                {
                }
                field("Map to Caption";"Map to Caption")
                {
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

                trigger OnAction()
                var
                    ItemWorksheetManagement: Codeunit "Item Worksheet Management";
                begin
                    GetCurrentWorksheet;
                    ItemWorksheetManagement.AddMappedFieldsToExcel(ItemWorksheet."Item Template Name",ItemWorksheet.Name);
                end;
            }
        }
    }

    var
        ItemWorksheet: Record "Item Worksheet";
        ItemWshtImpExpMgt: Codeunit "Item Wsht. Imp. Exp. Mgt.";

    procedure GetCurrentWorksheet()
    begin
        ItemWorksheet.Get(GetRangeMax("Worksheet Template Name"), GetRangeMax("Worksheet Name"));
    end;
}

