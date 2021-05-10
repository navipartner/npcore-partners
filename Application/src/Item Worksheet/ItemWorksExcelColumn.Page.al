page 6060053 "NPR Item Works. Excel Column"
{
    Caption = 'Item Worksheet Excel Column';
    PageType = List;
    SourceTable = "NPR Item Worksh. Excel Column";
    UsageCategory = Lists;
    ApplicationArea = All;
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Excel Column"; Rec."Excel Column")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Excel Column field.';
                }
                field("Excel Header Text"; Rec."Excel Header Text")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Excel Header Text field.';
                }
                field("Sample Data Row 1"; Rec."Sample Data Row 1")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Sample Data Row 1 field.';
                }
                field("Sample Data Row 2"; Rec."Sample Data Row 2")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Sample Data Row 2 field.';
                }
                field("Sample Data Row 3"; Rec."Sample Data Row 3")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Sample Data Row 3 field.';
                }
                field("Process as"; Rec."Process as")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Process as field.';
                }
                field("Map to Caption"; Rec."Map to Caption")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Map to Caption field.';
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
                ApplicationArea = All;
                Caption = 'Select Excel to Map';
                Image = ImportExcel;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Executes the Select Excel to Map action.';

                trigger OnAction()
                begin
                    GetCurrentWorksheet();
                    ItemWshtImpExpMgt.SelectExcelToMap(ItemWorksheet);
                end;
            }
            action(InsertMappedFields)
            {
                ApplicationArea = All;
                Caption = 'Insert all Mapped fields in Excel Mapping';
                Image = Add;
                ToolTip = 'Executes the Insert all Mapped fields in Excel Mapping action.';

                trigger OnAction()
                var
                    ItemWorksheetManagement: Codeunit "NPR Item Worksheet Mgt.";
                begin
                    GetCurrentWorksheet();
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
        ItemWorksheet.Get(Rec.GetRangeMax("Worksheet Template Name"), Rec.GetRangeMax("Worksheet Name"));
    end;
}

