page 6151556 "NPR NpXml Filters"
{
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
                field("Filter Type"; Rec."Filter Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Filter Type field';

                    trigger OnValidate()
                    begin
                        SetEnabled();
                    end;
                }
                field("Parent Field No."; Rec."Parent Field No.")
                {
                    ApplicationArea = All;
                    Enabled = ParentFieldNoEnabled;
                    Style = Subordinate;
                    StyleExpr = NOT ParentFieldNoEnabled;
                    ToolTip = 'Specifies the value of the Parent Field No. field';
                }
                field("Parent Field Name"; Rec."Parent Field Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Parent Field Name field';
                }
                field("Field No."; Rec."Field No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Field No. field';
                }
                field("Field Name"; Rec."Field Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Field Name field';
                }
                field("Filter Value"; Rec."Filter Value")
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

    trigger OnAfterGetCurrRecord()
    begin
        SetEnabled();
    end;

    trigger OnAfterGetRecord()
    begin
        SetEnabled();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Table No." := TableNo;
        Rec."Parent Table No." := ParentTableNo;
    end;

    var
        TableNo: Integer;
        ParentTableNo: Integer;
        FilterValueEnabled: Boolean;
        ParentFieldNoEnabled: Boolean;

    local procedure SetEnabled()
    begin
        ParentFieldNoEnabled := Rec."Filter Type" = Rec."Filter Type"::TableLink;
        FilterValueEnabled := not ParentFieldNoEnabled;
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

