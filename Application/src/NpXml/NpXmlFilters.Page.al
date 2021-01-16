page 6151556 "NPR NpXml Filters"
{
    // NC1.00/MH/20150113  CASE 199932 Refactored object from Web - XML
    // NC1.01/MH/20150201  Removed Batch Filter View
    // NC1.08/MH/20150310  CASE 206395 Added function SetEnabled() for usability
    // NC2.00/MHA/20160525  CASE 240005 NaviConnect

    AutoSplitKey = true;
    Caption = 'Xml Filters';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = Administration;
    ApplicationArea = All;
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
                    ToolTip = 'Specifies the value of the Filter Type field';

                    trigger OnValidate()
                    begin
                        //-NC1.08
                        SetEnabled();
                        //+NC1.08
                    end;
                }
                field("Parent Field No."; "Parent Field No.")
                {
                    ApplicationArea = All;
                    Enabled = ParentFieldNoEnabled;
                    Style = Subordinate;
                    StyleExpr = NOT ParentFieldNoEnabled;
                    ToolTip = 'Specifies the value of the Parent Field No. field';
                }
                field("Parent Field Name"; "Parent Field Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Parent Field Name field';
                }
                field("Field No."; "Field No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Field No. field';
                }
                field("Field Name"; "Field Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Field Name field';
                }
                field("Filter Value"; "Filter Value")
                {
                    ApplicationArea = All;
                    Enabled = FilterValueEnabled;
                    Style = Subordinate;
                    StyleExpr = NOT FilterValueEnabled;
                    ToolTip = 'Specifies the value of the Filter Value field';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetCurrRecord()
    begin
        //-NC1.08
        SetEnabled();
        //+NC1.08
    end;

    trigger OnAfterGetRecord()
    begin
        //-NC1.08
        SetEnabled();
        //+NC1.08
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        "Table No." := TableNo;
        "Parent Table No." := ParentTableNo;
    end;

    var
        TableNo: Integer;
        ParentTableNo: Integer;
        FilterValueEnabled: Boolean;
        ParentFieldNoEnabled: Boolean;

    local procedure SetEnabled()
    begin
        //-NC1.08
        ParentFieldNoEnabled := "Filter Type" = "Filter Type"::TableLink;
        FilterValueEnabled := not ParentFieldNoEnabled;
        //+NC1.08
    end;

    procedure SetParentTableNo(NewParentTableNo: Integer)
    begin
        ParentTableNo := NewParentTableNo;
    end;

    procedure SetTableNo(NewTableNo: Integer)
    begin
        TableNo := NewTableNo;
    end;
}

