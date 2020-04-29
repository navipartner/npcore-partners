page 6151556 "NpXml Filters"
{
    // NC1.00/MH/20150113  CASE 199932 Refactored object from Web - XML
    // NC1.01/MH/20150201  Removed Batch Filter View
    // NC1.08/MH/20150310  CASE 206395 Added function SetEnabled() for usability
    // NC2.00/MHA/20160525  CASE 240005 NaviConnect

    AutoSplitKey = true;
    Caption = 'Xml Filters';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "NpXml Filter";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Filter Type";"Filter Type")
                {

                    trigger OnValidate()
                    begin
                        //-NC1.08
                        SetEnabled();
                        //+NC1.08
                    end;
                }
                field("Parent Field No.";"Parent Field No.")
                {
                    Enabled = ParentFieldNoEnabled;
                    Style = Subordinate;
                    StyleExpr = NOT ParentFieldNoEnabled;
                }
                field("Parent Field Name";"Parent Field Name")
                {
                }
                field("Field No.";"Field No.")
                {
                }
                field("Field Name";"Field Name")
                {
                }
                field("Filter Value";"Filter Value")
                {
                    Enabled = FilterValueEnabled;
                    Style = Subordinate;
                    StyleExpr = NOT FilterValueEnabled;
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

