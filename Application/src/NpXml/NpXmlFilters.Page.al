page 6151556 "NPR NpXml Filters"
{
    Extensible = False;
    AutoSplitKey = true;
    Caption = 'Xml Filters';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = Administration;

    SourceTable = "NPR NpXml Filter";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Filter Type"; Rec."Filter Type")
                {

                    ToolTip = 'Specifies the value of the Filter Type field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        SetEnabled();
                    end;
                }
                field("Parent Field No."; Rec."Parent Field No.")
                {

                    Enabled = ParentFieldNoEnabled;
                    Style = Subordinate;
                    StyleExpr = NOT ParentFieldNoEnabled;
                    ToolTip = 'Specifies the value of the Parent Field No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Parent Field Name"; Rec."Parent Field Name")
                {

                    ToolTip = 'Specifies the value of the Parent Field Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Field No."; Rec."Field No.")
                {

                    ToolTip = 'Specifies the value of the Field No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Field Name"; Rec."Field Name")
                {

                    ToolTip = 'Specifies the value of the Field Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Filter Value"; Rec."Filter Value")
                {

                    Enabled = FilterValueEnabled;
                    Style = Subordinate;
                    StyleExpr = NOT FilterValueEnabled;
                    ToolTip = 'Specifies the value of the Filter Value field';
                    ApplicationArea = NPRRetail;
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

