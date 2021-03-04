page 6151557 "NPR NpXml Batch Filters"
{
    AutoSplitKey = true;
    Caption = 'Xml Batch Filters';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = Administration;
    ApplicationArea = All;
    ShowFilter = false;
    SourceTable = "NPR NpXml Filter";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Filter Type"; "Filter Type")
                {
                    ApplicationArea = All;
                    OptionCaption = ',Constant,Filter';
                    ToolTip = 'Specifies the value of the Filter Type field';
                }
                field("Parent Field No."; "Parent Field No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Parent Field No. field';
                }
                field("Parent Field Name"; "Parent Field Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Parent Field Name field';
                }
                field("Filter Value"; "Filter Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Filter Value field';
                }
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        "Parent Table No." := ParentTableNo;
        "Filter Type" := "Filter Type"::Constant;
    end;

    var
        ParentTableNo: Integer;

    procedure SetParentTableNo(NewParentTableNo: Integer)
    begin
        ParentTableNo := NewParentTableNo;
    end;
}

