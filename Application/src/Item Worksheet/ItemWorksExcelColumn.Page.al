page 6060053 "NPR Item Works. Excel Column"
{
    Caption = 'Item Worksheet Excel Column';
    PageType = List;
    SourceTable = "NPR Item Worksh. Excel Column";
    UsageCategory = Lists;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Excel Column"; Rec."Excel Column")
                {

                    ToolTip = 'Specifies the value of the Excel Column field.';
                    ApplicationArea = NPRRetail;
                }
                field("Excel Header Text"; Rec."Excel Header Text")
                {

                    ToolTip = 'Specifies the value of the Excel Header Text field.';
                    ApplicationArea = NPRRetail;
                }
                field("Sample Data Row 1"; Rec."Sample Data Row 1")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Sample Data Row 1 field.';
                    ApplicationArea = NPRRetail;
                }
                field("Sample Data Row 2"; Rec."Sample Data Row 2")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Sample Data Row 2 field.';
                    ApplicationArea = NPRRetail;
                }
                field("Sample Data Row 3"; Rec."Sample Data Row 3")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Sample Data Row 3 field.';
                    ApplicationArea = NPRRetail;
                }
                field("Process as"; Rec."Process as")
                {

                    ToolTip = 'Specifies the value of the Process as field.';
                    ApplicationArea = NPRRetail;
                }
                field("Map to Caption"; Rec."Map to Caption")
                {

                    ToolTip = 'Specifies the value of the Map to Caption field.';
                    ApplicationArea = NPRRetail;
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
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Executes the Select Excel to Map action.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    GetCurrentWorksheet();
                    ItemWshtImpExpMgt.SelectExcelToMap(ItemWorksheet);
                end;
            }
            action(InsertMappedFields)
            {

                Caption = 'Insert all Mapped fields in Excel Mapping';
                Image = Add;
                ToolTip = 'Executes the Insert all Mapped fields in Excel Mapping action.';
                ApplicationArea = NPRRetail;

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

