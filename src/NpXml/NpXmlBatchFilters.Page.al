page 6151557 "NPR NpXml Batch Filters"
{
    // NC1.00/MH/20150113  CASE 199932 Refactored object from Web - XML
    // NC1.01/MH/20150201  CASE 199932 Renamed Page from "Template Filters" to "Batch Filters".
    // NC2.00/MHA/20160525  CASE 240005 NaviConnect

    AutoSplitKey = true;
    Caption = 'Xml Batch Filters';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = Administration;
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
                }
                field("Parent Field No."; "Parent Field No.")
                {
                    ApplicationArea = All;
                }
                field("Parent Field Name"; "Parent Field Name")
                {
                    ApplicationArea = All;
                }
                field("Filter Value"; "Filter Value")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
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

